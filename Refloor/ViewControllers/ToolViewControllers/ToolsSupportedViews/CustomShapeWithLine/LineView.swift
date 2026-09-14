//
//  LineView.swift
//  RefloorEx
//
//  Created by sbek on 31/03/20.
//  Copyright © 2020 Arun Rajendrababu. All rights reserved.
//

import UIKit
protocol LineViewDelegate {
    func LineViewArea_PerimeterResult(area:CGFloat,Perimeter:Float)
    func LineViewTempAreaResult(area:CGFloat,isClosed:Bool,Perimeter:Float)
    func LineDrawingStarted()
    func didAutoSwitchDrawingMode(to mode: DrawingMode)
}

enum DrawingMode {
    case line
    case curve
    case vertical
    case horizontal
}
struct DrawingState {
    struct PointState {
        let point: CGPoint
        let isCorved: Bool
        let lineValue: Float
    }
    struct OpeningState {
        let center: CGPoint
        let transform: CGAffineTransform
        let customWidth: CGFloat
        let customHeight: CGFloat
        let isVertical: Bool
        let color: UIColor
        let object: OpeningCustomObject
        let addViewHeight: String
        let transitionHeightId: Int
    }
    let points: [PointState]
    let openings: [OpeningState]
    let isClosed: Bool
}

class LineView: UIView {
    
    var undoStack: [DrawingState] = []
    var redoStack: [DrawingState] = []
    var currentDrawingMode: DrawingMode = .vertical
    var isDrawingNow = false
    var isDraggingPoint = false
    
    
    var shapeLayere:CAShapeLayer? = nil
    var highlightLayer: CAShapeLayer? = nil
    var selectedSegmentIndex: Int? = nil
    var tempshapeLayere:CAShapeLayer? = nil
    var isClosed = false
    var isConfirmed = false
    var startTouch : CGPoint?
    var secondTouch : CGPoint?
    var delegate:LineViewDelegate?
    var subSquareView:[SubSqureView] = []
    var currentContext : CGContext? = nil
    var prevImage : UIImage?
    var buzierpath:UIBezierPath = UIBezierPath()
    var tempbuzierpath:UIBezierPath = UIBezierPath()
    
    var pointPath:[customPointObjcet] = []
    var tempLabel = UILabel()
    var touchmoved = false
    var starttouchBegan:CGPoint?
    var stoptouchBegan:CGPoint?
    
    var angleLabels: [UILabel] = []
    var angleLayer: CAShapeLayer? = nil
    var curveHandlesLayer: CAShapeLayer? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let vc = self.delegate as? CustomShapeLineViewController, vc.activeCustomPopup != nil {
            return
        }
        
        self.deselectSegment()
        if let touch = touches.first {
            self.endEditing(true)
            redoStack.removeAll()
            touchmoved = false
            let position = touch.location(in: self)

            if isClosed {
                if let clickedSegment = self.findClickedSegment(at: position) {
                    self.selectSegment(at: clickedSegment)
                }
                return
            }

            // Check if touching any drag handle or label
            for point in pointPath {
                if point.subView.superview != nil && point.subView.frame.contains(position) {
                    return
                }
                if point.label.superview != nil && point.label.frame.contains(position) {
                    return
                }
            }

            isDrawingNow = true
            self.delegate?.LineDrawingStarted()
            
            if pointPath.isEmpty {
                let limitedPoint = self.getLimitedPoint(at: position)  // No need for optional binding
                startTouch = limitedPoint
                starttouchBegan = limitedPoint
                print("starttouchBegan:", starttouchBegan)
            } else {
                if let lastPoint = pointPath.last {
                    if pointPath.count >= 2 {
                        let secondLastPoint = pointPath[pointPath.count - 2].point
                        if currentDrawingMode == .vertical && abs(lastPoint.point.x - secondLastPoint.x) < 0.1 {
                            if let vc = self.delegate as? CustomShapeLineViewController {
                                vc.alert("You cannot draw consecutive vertical lines. Please select horizontal line mode to continue.", nil)
                            }
                            isDrawingNow = false
                            return
                        } else if currentDrawingMode == .horizontal && abs(lastPoint.point.y - secondLastPoint.y) < 0.1 {
                            if let vc = self.delegate as? CustomShapeLineViewController {
                                vc.alert("You cannot draw consecutive horizontal lines. Please select vertical line mode to continue.", nil)
                            }
                            isDrawingNow = false
                            return
                        }
                    }
                    
                    let dx = position.x - lastPoint.point.x
                    let dy = position.y - lastPoint.point.y
                    
                    if currentDrawingMode != .line && currentDrawingMode != .curve {
                        if abs(dx) > abs(dy) {
                            currentDrawingMode = .horizontal
                        } else {
                            currentDrawingMode = .vertical
                        }
                    }
                    
                    let limitedPoint = self.getLimitedPoint(at: position, referencePoint: lastPoint.point)
                    startTouch = lastPoint.point
                    
                    var snappedPoint = limitedPoint
                    if currentDrawingMode == .vertical {
                        snappedPoint.x = lastPoint.point.x
                    } else if currentDrawingMode == .horizontal {
                        snappedPoint.y = lastPoint.point.y
                    }
                    
                    secondTouch = snappedPoint
                    starttouchBegan = lastPoint.point
                    stoptouchBegan = snappedPoint

                    print("starttouchBegan:", starttouchBegan)
                    print("stoptouchBegan:", stoptouchBegan)
                } else {
                    print("Error: pointPath.last returned nil")
                    isDrawingNow = false
                    return
                }
            }

            drowTempLine()
        }
    }


//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            touchmoved=false
//            let position = touch.location(in: self)
//            if(isClosed)
//            {
//                return
//            }
//            if(pointPath.count == 0)
//            {
//                startTouch = self.getLimitedPoint(at: position)
//                starttouchBegan = self.getLimitedPoint(at: position)
//                print("starttouchBegan",starttouchBegan)
//            }
//            else
//            {
//                startTouch = pointPath[pointPath.count - 1].point
//                secondTouch = self.getLimitedPoint(at: position)
//                starttouchBegan = pointPath[pointPath.count - 1].point
//                stoptouchBegan = self.getLimitedPoint(at: position)
//                print("starttouchBegan",starttouchBegan)
//                print("stoptouchBegan",stoptouchBegan)
//            }
//            drowTempLine()
//            
//        }
//    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isClosed || !isDrawingNow {
            return
        }
        touchmoved=true
        if let touch = touches.first {
            let position = touch.location(in: self)
            let limitedPoint = self.getLimitedPoint(at: position, referencePoint: startTouch)
            
            var snappedPoint = limitedPoint
            if let start = startTouch {
                if currentDrawingMode == .vertical {
                    snappedPoint.x = start.x
                } else if currentDrawingMode == .horizontal {
                    snappedPoint.y = start.y
                }
            }
            secondTouch = snappedPoint
            drowTempLine()
        }
    }
    //     func getCurrentContext()
    //     {
    //         let context = UIGraphicsGetCurrentContext()
    //        context.
    //     }
    func insertCurveControlPoint(p0: CGPoint, p2: CGPoint) {
        let mid = CGPoint(x: (p0.x + p2.x) / 2, y: (p0.y + p2.y) / 2)
        let offset: CGFloat = -50.0
        let dx = p2.x - p0.x
        let dy = p2.y - p0.y
        let length = hypot(dx, dy)
        let nx = length > 0 ? -dy / length : 0
        let ny = length > 0 ? dx / length : 0
        let cPoint = CGPoint(x: mid.x + nx * offset, y: mid.y + ny * offset)
        
        let controlLabel = LineSegmentControlView()
        controlLabel.lineView = self
        self.addSubview(controlLabel)
        let controlNode = customPointObjcet(label: controlLabel, point: cPoint, lineValue: 0)
        controlLabel.pointObject = controlNode
        controlNode.isCorved = true
        self.pointPath.append(controlNode)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isClosed || !isDrawingNow {
            return
        }
        isDrawingNow = false
        touchmoved=false
        clearTempLine()
        
        saveState()
        
        if pointPath.count == 0
        {
            let label1 = LineSegmentControlView()
            label1.lineView = self
            label1.isHidden = true
            let pt1 = customPointObjcet(label: label1, point: startTouch!, lineValue: 0)
            label1.pointObject = pt1
            self.addSubview(label1)
            self.pointPath.append(pt1)
            if(secondTouch != nil)
            {
                if currentDrawingMode == .curve {
                    insertCurveControlPoint(p0: startTouch!, p2: secondTouch!)
                }
                let label2 = LineSegmentControlView()
                label2.lineView = self
                let pt2 = customPointObjcet(label: label2, point: secondTouch!, lineValue: 0)
                label2.pointObject = pt2
                self.addSubview(label2)
                self.pointPath.append(pt2)
                self.drowShape(false)
            }
            else
            {
                self.drowShape(false)
            }
        }
        else
        {
            if(pointPath.count < 3)
            {
                if currentDrawingMode == .curve && pointPath.count > 0 {
                    insertCurveControlPoint(p0: pointPath.last!.point, p2: secondTouch!)
                }
                let label = LineSegmentControlView()
                label.lineView = self
                let pt = customPointObjcet(label: label, point: secondTouch!, lineValue: 0)
                label.pointObject = pt
                self.addSubview(label)
                self.pointPath.append(pt)
                self.drowShape(false)
            }
            else
            {
                if getdistanceofpoint(self.pointPath[0].point, secondTouch!) < 60
                {
                    if currentDrawingMode == .curve && pointPath.count > 0 {
                        insertCurveControlPoint(p0: pointPath.last!.point, p2: self.pointPath[0].point)
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.drowShape(true)
                        self.isClosed = true
                        self.layoutIfNeeded()
                    }
                }
                else
                {
                    if currentDrawingMode == .curve && pointPath.count > 0 {
                        insertCurveControlPoint(p0: pointPath.last!.point, p2: secondTouch!)
                    }
                    let label = LineSegmentControlView()
                    label.lineView = self
                    let pt = customPointObjcet(label: label, point: secondTouch!, lineValue: 0)
                    label.pointObject = pt
                    self.addSubview(label)
                    self.pointPath.append(pt)
                    UIView.animate(withDuration: 0.3) {
                        self.drowShape(false)
                        self.layoutIfNeeded()
                    }
                }
            }
        }
        
        if secondTouch != nil && !isClosed {
            // Automatic switching removed as per user request
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isClosed { return }
        isDrawingNow = false
        clearTempLine()
        self.delegate?.LineViewTempAreaResult(area: 0, isClosed: false, Perimeter: self.getPerimeter())
    }
    func roundTheValue(_ value:CGFloat) -> CGFloat
    {
        
        return CGFloat(Float(value * 100).rounded()/100)
    }
    
    
    func clearAllLine()
    {
        deselectSegment()
        if shapeLayere != nil
        {
            self.isClosed = false
            shapeLayere?.removeFromSuperlayer()
            for point in pointPath
            {
                point.label.removeFromSuperview()
                point.subView.removeFromSuperview()
            }
            pointPath = []
            undoStack.removeAll()
            redoStack.removeAll()
            shapeLayere = nil
            self.startTouch = nil
            self.secondTouch = nil
            clearAngles()
        }
    }
    
    func clearAngles() {
        angleLayer?.removeFromSuperlayer()
        angleLayer = nil
        curveHandlesLayer?.removeFromSuperlayer()
        curveHandlesLayer = nil
        for label in angleLabels {
            label.removeFromSuperview()
        }
        angleLabels.removeAll()
    }
    
    func removeLastLine()
    {
        guard !undoStack.isEmpty else { return }
        
        if isConfirmed { return }
        
        let currentPoints = pointPath.map { DrawingState.PointState(point: $0.point, isCorved: $0.isCorved, lineValue: $0.lineValue) }
        let currentOpenings = subSquareView.map { subview in
            DrawingState.OpeningState(
                center: subview.center,
                transform: subview.transform,
                customWidth: subview.custom_width,
                customHeight: subview.custom_hight,
                isVertical: subview.isVertical,
                color: subview.color,
                object: subview.object ?? OpeningCustomObject(name: "No Transition", color: .white),
                addViewHeight: subview.addViewHeight,
                transitionHeightId: subview.transitionHeightId
            )
        }
        let currentState = DrawingState(points: currentPoints, openings: currentOpenings, isClosed: self.isClosed)
        redoStack.append(currentState)
        
        let previousState = undoStack.removeLast()
        restoreState(previousState)
    }
    
    func redoLastLine()
    {
        guard !redoStack.isEmpty else { return }
        
        let currentPoints = pointPath.map { DrawingState.PointState(point: $0.point, isCorved: $0.isCorved, lineValue: $0.lineValue) }
        let currentOpenings = subSquareView.map { subview in
            DrawingState.OpeningState(
                center: subview.center,
                transform: subview.transform,
                customWidth: subview.custom_width,
                customHeight: subview.custom_hight,
                isVertical: subview.isVertical,
                color: subview.color,
                object: subview.object ?? OpeningCustomObject(name: "No Transition", color: .white),
                addViewHeight: subview.addViewHeight,
                transitionHeightId: subview.transitionHeightId
            )
        }
        let currentState = DrawingState(points: currentPoints, openings: currentOpenings, isClosed: self.isClosed)
        undoStack.append(currentState)
        
        let nextState = redoStack.removeLast()
        restoreState(nextState)
    }
    
    func saveState() {
        let points = pointPath.map { DrawingState.PointState(point: $0.point, isCorved: $0.isCorved, lineValue: $0.lineValue) }
        let openings = subSquareView.map { subview in
            DrawingState.OpeningState(
                center: subview.center,
                transform: subview.transform,
                customWidth: subview.custom_width,
                customHeight: subview.custom_hight,
                isVertical: subview.isVertical,
                color: subview.color,
                object: subview.object ?? OpeningCustomObject(name: "No Transition", color: .white),
                addViewHeight: subview.addViewHeight,
                transitionHeightId: subview.transitionHeightId
            )
        }
        let state = DrawingState(points: points, openings: openings, isClosed: self.isClosed)
        
        if let last = undoStack.last {
            if isStateEqual(last, state) { return }
        }
        
        undoStack.append(state)
        redoStack.removeAll()
        
        DispatchQueue.main.async {
            if let vc = self.delegate as? CustomShapeLineViewController {
                vc.updateUndoRedoButtonsState()
            }
        }
    }
    
    private func isStateEqual(_ lhs: DrawingState, _ rhs: DrawingState) -> Bool {
        guard lhs.isClosed == rhs.isClosed else { return false }
        guard lhs.points.count == rhs.points.count else { return false }
        guard lhs.openings.count == rhs.openings.count else { return false }
        
        for (i, pL) in lhs.points.enumerated() {
            let pR = rhs.points[i]
            if pL.point != pR.point || pL.isCorved != pR.isCorved || pL.lineValue != pR.lineValue {
                return false
            }
        }
        
        for (i, oL) in lhs.openings.enumerated() {
            let oR = rhs.openings[i]
            if oL.center != oR.center ||
               oL.transform != oR.transform ||
               oL.customWidth != oR.customWidth ||
               oL.customHeight != oR.customHeight ||
               oL.isVertical != oR.isVertical ||
               oL.color != oR.color ||
               oL.object.name != oR.object.name ||
               oL.object.color != oR.object.color ||
               oL.addViewHeight != oR.addViewHeight ||
               oL.transitionHeightId != oR.transitionHeightId {
                return false
            }
        }
        return true
    }
    
    private func restoreState(_ state: DrawingState) {
        deselectSegment()
        for point in pointPath {
            point.label.removeFromSuperview()
            point.subView.removeFromSuperview()
        }
        pointPath.removeAll()
        
        for subview in subSquareView {
            subview.removeFromSuperview()
        }
        subSquareView.removeAll()
        
        for pointState in state.points {
            let label = LineSegmentControlView()
            label.lineView = self
            let pt = customPointObjcet(label: label, point: pointState.point, lineValue: pointState.lineValue)
            pt.isCorved = pointState.isCorved
            label.pointObject = pt
            
            self.addSubview(label)
            pointPath.append(pt)
        }
        
        for openingState in state.openings {
            let subView = SubSqureView(
                frame: CGRect(x: openingState.center.x, y: openingState.center.y, width: openingState.customWidth * minimumValue, height: openingState.customHeight * minimumValue),
                isVertical: openingState.isVertical,
                color: openingState.color
            )
            subView.custom_width = openingState.customWidth
            subView.custom_hight = openingState.customHeight
            subView.change_color_of_path(openingState.color)
            subView.object = openingState.object
            subView.customDelegate = self.delegate as? CustomViewDelegate
            subView.tag = self.subSquareView.count
            subView.isUserInteractionEnabled = true
            subView.addViewHeight = openingState.addViewHeight
            subView.transitionHeightId = openingState.transitionHeightId
            subView.center = openingState.center
            subView.transform = openingState.transform
            
            self.subSquareView.append(subView)
            self.addSubview(subView)
        }
        
        self.isClosed = state.isClosed
        
        drowShape(self.isClosed)
        
        DispatchQueue.main.async {
            let area = self.getarea()
            self.delegate?.LineViewTempAreaResult(area: self.roundTheValue(area), isClosed: self.isClosed, Perimeter: self.getPerimeter())
            if let vc = self.delegate as? CustomShapeLineViewController {
                vc.updateUndoRedoButtonsState()
                vc.no_Squre_View_In_Tool()
            }
        }
    }
    
    
    func getCurvePoints(startPoint: CGPoint, endPoint:CGPoint, midilePoint:CGPoint) -> [CGPoint] {
        func halfPoint1D(p0: CGFloat, p2: CGFloat, control: CGFloat) -> CGFloat {
            return 2 * control - p0 / 2 - p2 / 2
        }
        
        let p0 = startPoint
        let p2 = endPoint
        
        let p1 = CGPoint(x: halfPoint1D(p0: p0.x, p2: p2.x, control: midilePoint.x),
                         y: halfPoint1D(p0: p0.y, p2: p2.y, control: midilePoint.y))
        return [p2,p1]
    }
    
    
    func getOffsetMidpoint(from p1: CGPoint, to p2: CGPoint) -> CGPoint {
        let mid = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let len = hypot(dx, dy)
        
        guard len > 0.1 else { return mid }
        
        var ux = -dy / len
        var uy = dx / len
        
        // Calculate centroid
        var totalX: CGFloat = 0
        var totalY: CGFloat = 0
        var count = 0
        for pt in pointPath {
            if !pt.isCorved {
                totalX += pt.point.x
                totalY += pt.point.y
                count += 1
            }
        }
        
        if count >= 3 {
            let centroid = CGPoint(x: totalX / CGFloat(count), y: totalY / CGFloat(count))
            let cx = centroid.x - mid.x
            let cy = centroid.y - mid.y
            let dot = cx * ux + cy * uy
            if dot > 0 {
                // Normal points TOWARDS centroid (inside). Flip it so it points OUTSIDE.
                ux = -ux
                uy = -uy
            }
        } else {
            // Fallback for lines before a shape is formed
            if abs(dx) > abs(dy) {
                if uy > 0 {
                    ux = -ux
                    uy = -uy
                }
            } else {
                if ux > 0 {
                    ux = -ux
                    uy = -uy
                }
            }
        }
        
        let d = abs(ux) * 110 + abs(uy) * 45 + 15
        return CGPoint(x: mid.x + ux * d, y: mid.y + uy * d)
    }

    func calculateAngle(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        var angle = atan2(dy, dx)
        // Normalize angle to range [-pi/2, pi/2] to keep label upright
        if angle > CGFloat.pi / 2 {
            angle -= CGFloat.pi
        } else if angle < -CGFloat.pi / 2 {
            angle += CGFloat.pi
        }
        return angle
    }

    func getCurvedLabelPosition(start: CGPoint, control: CGPoint, end: CGPoint, path: UIBezierPath? = nil) -> CGPoint {
        // Base point on the curve is control (since the curve passes through control)
        let curveMid = control
        
        // Calculate chord direction and unit normal
        let dx = end.x - start.x
        let dy = end.y - start.y
        let len = hypot(dx, dy)
        
        let nx: CGFloat
        let ny: CGFloat
        if len > 0.1 {
            nx = -dy / len
            ny = dx / len
        } else {
            nx = 0
            ny = 1
        }
        
        // Calculate centroid of the shape vertices (non-control points)
        var totalX: CGFloat = 0
        var totalY: CGFloat = 0
        var count = 0
        for pt in pointPath {
            if !pt.isCorved {
                totalX += pt.point.x
                totalY += pt.point.y
                count += 1
            }
        }
        
        let centroid: CGPoint
        if count > 0 {
            centroid = CGPoint(x: totalX / CGFloat(count), y: totalY / CGFloat(count))
        } else {
            centroid = curveMid
        }
        
        // Vector from curve midpoint to centroid
        let cx = centroid.x - curveMid.x
        let cy = centroid.y - curveMid.y
        
        // Determine which normal direction points inside (towards centroid)
        let projection = cx * nx + cy * ny
        let insideNormalX: CGFloat
        let insideNormalY: CGFloat
        if projection >= 0 {
            insideNormalX = nx
            insideNormalY = ny
        } else {
            insideNormalX = -nx
            insideNormalY = -ny
        }
        
        let outsideNormalX = -insideNormalX
        let outsideNormalY = -insideNormalY
        
        // Calculate the required offset distance to prevent overlap
        // Label size: W = 220, H = 90
        let wHalf: CGFloat = 110
        let hHalf: CGFloat = 45
        let margin: CGFloat = 5
        
        // Offset for inside candidate
        let insideOffset = wHalf * abs(insideNormalX) + hHalf * abs(insideNormalY) + margin
        let insidePoint = CGPoint(
            x: curveMid.x + insideNormalX * insideOffset,
            y: curveMid.y + insideNormalY * insideOffset
        )
        
        // Offset for outside candidate
        let outsideOffset = wHalf * abs(outsideNormalX) + hHalf * abs(outsideNormalY) + margin
        let outsidePoint = CGPoint(
            x: curveMid.x + outsideNormalX * outsideOffset,
            y: curveMid.y + outsideNormalY * outsideOffset
        )
        
        return outsidePoint
    }

    func getPath (_ isClose:Bool) -> UIBezierPath
    {
        let path = UIBezierPath()
        
        // 1. Build the path geometry first so contains() tests can run against a completed path
        var i = 0
        for point in pointPath
        {
            if(i == 0)
            {
                path.move(to: point.point)
            }
            else if(point.isCorved)
            {
                let nextPoint = pointPath[(i + 1) % pointPath.count]
                let curvpoints = getCurvePoints(startPoint: pointPath[i - 1].point, endPoint: nextPoint.point, midilePoint: point.point)
                path.addQuadCurve(to: curvpoints[0], controlPoint: curvpoints[1])
            }
            else if !(pointPath[i - 1].isCorved)
            {
                path.addLine(to: point.point)
            }
            else
            {
                // Curve endpoint (added by addQuadCurve)
            }
            i += 1
        }
        if(isClose)
        {
            path.close()
        }
        
        // 2. Position and configure labels using the completed path geometry
        i = 0
        for point in pointPath
        {
            if(i == 0)
            {
                point.label.isHidden = !isClose
            }
            else if(point.isCorved)
            {
                point.label.isHidden = false
                let nextPoint = pointPath[(i + 1) % pointPath.count]
                
                let labelPos = getCurvedLabelPosition(start: pointPath[i - 1].point, control: point.point, end: nextPoint.point, path: path)
                point.lineValue = labelConfigration(point.label, labelPos, distance: getdistanceofpoint(pointPath[i - 1].point, nextPoint.point), angle: 0, isCurved: true)
            }
            else if !(pointPath[i - 1].isCorved)
            {
                point.label.isHidden = false
                let angle = calculateAngle(from: pointPath[i - 1].point, to: point.point)
                point.lineValue = labelConfigration(point.label, getOffsetMidpoint(from: pointPath[i - 1].point, to: point.point), distance: getdistanceofpoint(pointPath[i - 1].point, point.point), angle: angle, isCurved: false)
            }
            else
            {
                // This is the curve endpoint: hide its label to avoid duplicates, but compute lineValue
                let startPointForEnd = (i - 2 >= 0) ? pointPath[i - 2].point : pointPath[pointPath.count - 1].point
                point.lineValue = labelConfigration(point.label, getOffsetMidpoint(from: pointPath[i - 1].point, to: point.point), distance: getdistanceofpoint(startPointForEnd, point.point), angle: 0, isCurved: true)
                point.label.isHidden = true
            }
            i += 1
        }
        
        if(isClose)
        {
            let label = pointPath[0].label
            let p1 = pointPath[pointPath.count - 1].point
            let p2 = pointPath[0].point
            let isClosingSegmentCurved = pointPath[pointPath.count - 1].isCorved
            
            if isClosingSegmentCurved {
                let startPt = pointPath[pointPath.count - 2].point
                let labelPos = getCurvedLabelPosition(start: startPt, control: p1, end: p2, path: path)
                pointPath[0].lineValue = labelConfigration(label, labelPos, distance: getdistanceofpoint(startPt, p2), angle: 0, isCurved: true)
                label.isHidden = true
            } else {
                let angle = calculateAngle(from: p1, to: p2)
                pointPath[0].lineValue = labelConfigration(label, getOffsetMidpoint(from: p1, to: p2), distance: getdistanceofpoint(p1, p2), angle: angle, isCurved: false)
                label.isHidden = false
            }
            self.addSubview(label)
        } else {
            if pointPath.count > 0 {
                pointPath[0].lineValue = 0
            }
        }
        
        buzierpath = path
        return buzierpath
    }
    
    func clearTempLine()
    {
        if tempshapeLayere != nil
        {
            tempshapeLayere?.removeFromSuperlayer()
            tempshapeLayere = nil
            self.tempLabel.removeFromSuperview()
        }
    }
    
    func drowTempLine()
    {
        if tempshapeLayere == nil
        {
            tempbuzierpath.removeAllPoints()
            tempbuzierpath.move(to: startTouch!)
            self.tempLabel.frame.origin.x = startTouch!.x
            self.tempLabel.frame.origin.y = startTouch!.y
            self.addSubview(self.tempLabel)
            if(secondTouch != nil)
            {
                let angle = calculateAngle(from: startTouch!, to: secondTouch!)
                if touchmoved==false{
                    _ = self.labelConfigration(self.tempLabel, self.getOffsetMidpoint(from: secondTouch!, to: startTouch!), distance: self.getdistanceofpoint(secondTouch!, startTouch!), angle: angle)
                    tempbuzierpath.addLine(to: secondTouch!)
                }
                else
                {
                    _ =  self.labelConfigration(self.tempLabel, self.getOffsetMidpoint(from: stoptouchBegan!, to: starttouchBegan!), distance: self.getdistanceofpoint(secondTouch!, startTouch!), angle: angle)
                }
                tempbuzierpath.addLine(to: secondTouch!)
            }
            tempshapeLayere = CAShapeLayer()
            tempshapeLayere!.path = tempbuzierpath.cgPath
            tempshapeLayere!.fillColor = UIColor.clear.cgColor
            tempshapeLayere!.strokeColor = UIColor.lightGray.cgColor
            tempshapeLayere!.lineWidth = 5.0
            self.layer.addSublayer(tempshapeLayere!)
        }
        else
        {
            if(secondTouch != nil)
            {
                let angle = calculateAngle(from: startTouch!, to: secondTouch!)
                if touchmoved==false{
                    _ =  self.labelConfigration(self.tempLabel, self.getOffsetMidpoint(from: secondTouch!, to: startTouch!), distance: self.getdistanceofpoint(secondTouch!, startTouch!), angle: angle)
                    
                }
                else
                {
                    _ =  self.labelConfigration(self.tempLabel, self.getOffsetMidpoint(from: secondTouch!, to: startTouch!), distance: self.getdistanceofpoint(secondTouch!, startTouch!), angle: angle)
                }
            }
            tempbuzierpath.removeAllPoints()
            tempbuzierpath.move(to: startTouch!)
            if(secondTouch != nil) {
                tempbuzierpath.addLine(to: secondTouch!)
            }
            tempshapeLayere!.path = tempbuzierpath.cgPath
        }
    }
    func labelConfigration(_ label: UILabel, _ cgPoint: CGPoint, distance: CGFloat, angle: CGFloat = 0) -> Float {
        let value = round(Float(distance/minimumValue) * 12) / 12.0
        let ftValue = Float(Int(value))
        let inchVal = (value - ftValue) * 12
        let roundeInch = Int(inchVal)
        
        label.transform = .identity
        if roundeInch == 0 {
            label.text = "\(Int(value)) ft"
            label.bounds = CGRect(x: 0, y: 0, width: 80, height: 25)
        } else {
            label.text = "\(Int(value)) ft \(roundeInch) in"
            label.bounds = CGRect(x: 0, y: 0, width: 110, height: 25)
        }
        label.numberOfLines = 1
        label.center = cgPoint
        label.transform = CGAffineTransform(rotationAngle: angle)
        
        label.font = UIFont(name: "Avenir-Black", size: 15)
        label.backgroundColor = UIColor.white
        label.textColor = .black
        label.borderColor = .darkGray
        label.borderWidth = 1
        label.textAlignment = .center
        return value
    }
    
    func labelConfigration(_ label: LineSegmentControlView, _ cgPoint: CGPoint, distance: CGFloat, angle: CGFloat = 0, isCurved: Bool = false) -> Float {
        let value = round(Float(distance/minimumValue) * 12) / 12.0
        
        label.lineView = self
        if label.pointObject == nil {
            label.pointObject = self.pointPath.first(where: { $0.label === label })
        }
        
        if let idx = self.pointPath.firstIndex(where: { $0.label === label }) {
            let wallNum = (idx == 0) ? self.pointPath.count : idx
            label.wallBadgeLabel.text = "Wall \(wallNum)"
            label.wallBadgeLabel.isHidden = true
        } else {
            label.wallBadgeLabel.isHidden = true
        }
        
        label.updateText(label.formatFeetValue(value))
        
        label.transform = .identity
        label.center = cgPoint
        
        let targetWidth: CGFloat = 130.0
        var scale: CGFloat = 1.0
        if value <= 3.0 {
            scale = 0.65
        } else if distance < targetWidth {
            scale = max(0.6, distance / targetWidth)
        }
        
        label.transform = CGAffineTransform(scaleX: scale, y: scale)
        // Removed rotation so the control view always stays horizontal
        
        
        if let idx = self.pointPath.firstIndex(where: { $0.label === label }) {
            label.setSelected(selectedSegmentIndex == nil ? nil : (selectedSegmentIndex == idx))
        }
        
        return value
    }
    
    func labelConfigration(_ label: UIView, _ cgPoint: CGPoint, distance: CGFloat, angle: CGFloat = 0, isCurved: Bool = false) -> Float {
        if let controlView = label as? LineSegmentControlView {
            return labelConfigration(controlView, cgPoint, distance: distance, angle: angle, isCurved: isCurved)
        } else if let labelView = label as? UILabel {
            return labelConfigration(labelView, cgPoint, distance: distance, angle: angle)
        }
        return 0
    }
    
    func updateSegmentLength(for pointObject: customPointObjcet, newLength: CGFloat) {
        guard let index = pointPath.firstIndex(where: { $0 === pointObject }) else { return }
        
        let startPoint: CGPoint
        if index > 0 {
            startPoint = pointPath[index - 1].point
        } else if index == 0 && isClosed {
            startPoint = pointPath[pointPath.count - 1].point
        } else {
            return
        }
        
        if pointObject.isCorved {
            let nextIndex = (index + 1) % pointPath.count
            let endPointNode = pointPath[nextIndex]
            let endPoint = endPointNode.point
            
            let dx = endPoint.x - startPoint.x
            let dy = endPoint.y - startPoint.y
            let currentDistance = hypot(dx, dy)
            guard currentDistance > 0.1 else { return }
            
            let ux = dx / currentDistance
            let uy = dy / currentDistance
            let newDistance = newLength * minimumValue
            
            let newEndPoint = CGPoint(x: startPoint.x + ux * newDistance, y: startPoint.y + uy * newDistance)
            let limitedEndPoint = getLimitedPoint(at: newEndPoint, snapToHalfFoot: false)
            endPointNode.point = limitedEndPoint
            endPointNode.subView.center = limitedEndPoint
            
            let scaleRatio = newDistance / currentDistance
            let cdx = pointObject.point.x - startPoint.x
            let cdy = pointObject.point.y - startPoint.y
            let newControlPoint = CGPoint(x: startPoint.x + cdx * scaleRatio, y: startPoint.y + cdy * scaleRatio)
            let limitedControlPoint = getLimitedPoint(at: newControlPoint, snapToHalfFoot: false)
            pointObject.point = limitedControlPoint
            pointObject.subView.center = limitedControlPoint
            
        } else {
            let endPoint = pointObject.point
            let dx = endPoint.x - startPoint.x
            let dy = endPoint.y - startPoint.y
            let currentDistance = hypot(dx, dy)
            
            guard currentDistance > 0.1 else { return }
            
            let ux = dx / currentDistance
            let uy = dy / currentDistance
            
            let newDistance = newLength * minimumValue
            let proposedPoint = CGPoint(x: startPoint.x + ux * newDistance, y: startPoint.y + uy * newDistance)
            let limitedPoint = getLimitedPoint(at: proposedPoint, snapToHalfFoot: false)
            
            pointObject.point = limitedPoint
            pointObject.subView.center = limitedPoint
        }
        
        moveShape()
    }
    
    
    
    func getLimitedPoint(at point:CGPoint, referencePoint: CGPoint? = nil, snapToHalfFoot: Bool = true) -> CGPoint
    {
        var xVal = point.x
        var yVal = point.y
        
        let snapUnit = snapToHalfFoot ? (minimumValue / 2.0) : (minimumValue / 12.0)
        
        if let ref = referencePoint {
            let dx = xVal - ref.x
            let dy = yVal - ref.y
            
            if currentDrawingMode == .line || currentDrawingMode == .curve {
                // Snap the actual distance (hypotenuse) to snapUnit so slanting and curved lines also adhere to 6-inch increments
                let distance = hypot(dx, dy)
                let snappedDistance = round(distance / snapUnit) * snapUnit
                
                if distance > 0 {
                    xVal = ref.x + (dx / distance) * snappedDistance
                    yVal = ref.y + (dy / distance) * snappedDistance
                } else {
                    xVal = ref.x
                    yVal = ref.y
                }
            } else {
                xVal = ref.x + round(dx / snapUnit) * snapUnit
                yVal = ref.y + round(dy / snapUnit) * snapUnit
            }
        } else {
            xVal = round(xVal / snapUnit) * snapUnit
            yVal = round(yVal / snapUnit) * snapUnit
        }
        
        return CGPoint(x: xVal, y: yVal)
    }
    
    func moveShape()
    {
        shapeLayere!.path = getPath(self.isClosed).cgPath
        if self.isClosed {
            shapeLayere!.fillColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 0.15).cgColor
            shapeLayere!.strokeColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
        } else {
            shapeLayere!.fillColor = UIColor.clear.cgColor
            shapeLayere!.strokeColor = UIColor.white.cgColor
        }
        
        for point in pointPath {
            point.subView.center = point.point
            self.bringSubviewToFront(point.subView)
        }
        
        for subSquare in subSquareView {
            subSquare.alignAndSnap(toProposedCenter: subSquare.center)
        }
        
        drawHighlight()
        
        drawAngles(isClose: self.isClosed)
        DispatchQueue.main.async {
            let area = self.getarea()
            self.delegate?.LineViewTempAreaResult(area: self.roundTheValue(area), isClosed: true, Perimeter: self.getPerimeter())
        }
        
    }
    func drowShape(_ isClose:Bool)
    {
        self.delegate?.LineDrawingStarted()
        if shapeLayere == nil
        {
            shapeLayere = CAShapeLayer()
            shapeLayere!.path = getPath(isClose).cgPath
            shapeLayere!.fillColor = UIColor.clear.cgColor
            shapeLayere!.strokeColor = UIColor.white.cgColor
            shapeLayere!.lineWidth = 5.0
            self.layer.addSublayer(shapeLayere!)
            self.setPoints()
        }
        else
        {
            
            
            shapeLayere!.path = getPath(isClose).cgPath
            if(isClose)
            {
                shapeLayere!.fillColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 0.15).cgColor
                shapeLayere!.strokeColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
                if(isConfirmed)
                {
                    self.removeAllPoints()
                    self.delegate?.LineViewArea_PerimeterResult(area: self.getarea(), Perimeter: self.getPerimeter())
                }
                else
                {
                    self.delegate?.LineViewTempAreaResult(area: self.getarea(), isClosed: true, Perimeter: self.getPerimeter())
                    self.setPoints()
                }
                
            }
            
            else
            {
                self.delegate?.LineViewTempAreaResult(area: 0, isClosed: false, Perimeter:  self.getPerimeter())
                
                shapeLayere!.fillColor = UIColor.clear.cgColor
                shapeLayere!.strokeColor = UIColor.white.cgColor
                self.setPoints()
            }
        }
        drawAngles(isClose: isClose)
        
        for subSquare in subSquareView {
            subSquare.alignAndSnap(toProposedCenter: subSquare.center)
        }
    }
    
    func drawAngles(isClose: Bool) {
        angleLayer?.removeFromSuperlayer()
        angleLayer = CAShapeLayer()
        angleLayer!.fillColor = UIColor.clear.cgColor
        angleLayer!.strokeColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
        angleLayer!.lineWidth = 1.5
        self.layer.addSublayer(angleLayer!)
        
        curveHandlesLayer?.removeFromSuperlayer()
        curveHandlesLayer = CAShapeLayer()
        curveHandlesLayer!.fillColor = UIColor.clear.cgColor
        curveHandlesLayer!.strokeColor = UIColor(red: 120/255.0, green: 125/255.0, blue: 135/255.0, alpha: 1.0).cgColor
        curveHandlesLayer!.lineWidth = 1.5
        self.layer.addSublayer(curveHandlesLayer!)
        
        let path = UIBezierPath()
        let handlesPath = UIBezierPath()
        let shapePath = getPath(isClose).cgPath
        
        for label in angleLabels {
            label.isHidden = true
        }
        
        var labelIndex = 0
        let count = pointPath.count
        
        let showTangents = self.isDraggingPoint
        
        for i in 0..<count {
            if pointPath[i].isCorved {
                let isLastPoint = (i == count - 1)
                if showTangents && i > 0 && (i < count - 1 || (isLastPoint && isClose)) {
                    let p0 = pointPath[i-1].point
                    let p2 = isLastPoint ? pointPath[0].point : pointPath[i+1].point
                    let mid = pointPath[i].point
                    let p1 = CGPoint(x: 2 * mid.x - p0.x / 2 - p2.x / 2,
                                     y: 2 * mid.y - p0.y / 2 - p2.y / 2)
                    
                    let m0 = CGPoint(x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2)
                    let m1 = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
                    
                    handlesPath.move(to: m0)
                    handlesPath.addLine(to: m1)
                    
                    handlesPath.move(to: CGPoint(x: m0.x + 5, y: m0.y))
                    handlesPath.addArc(withCenter: m0, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                    
                    handlesPath.move(to: CGPoint(x: m1.x + 5, y: m1.y))
                    handlesPath.addArc(withCenter: m1, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                }
                continue
            }
            
            if !isClose && (i == 0 || i == count - 1) { continue }
            
            let prevIndex = (i - 1 + count) % count
            let nextIndex = (i + 1) % count
            
            let p = pointPath[i].point
            let prevP = pointPath[prevIndex].point
            let nextP = pointPath[nextIndex].point
            
            var v1: CGPoint
            if pointPath[prevIndex].isCorved {
                let p0 = pointPath[(prevIndex - 1 + count) % count].point
                let p2 = p
                let mid = pointPath[prevIndex].point
                let p1 = CGPoint(x: 2 * mid.x - p0.x / 2 - p2.x / 2, y: 2 * mid.y - p0.y / 2 - p2.y / 2)
                v1 = CGPoint(x: p1.x - p.x, y: p1.y - p.y)
            } else {
                v1 = CGPoint(x: prevP.x - p.x, y: prevP.y - p.y)
            }
            
            var v2: CGPoint
            if pointPath[nextIndex].isCorved {
                let p0 = p
                let p2 = pointPath[(nextIndex + 1) % count].point
                let mid = pointPath[nextIndex].point
                let p1 = CGPoint(x: 2 * mid.x - p0.x / 2 - p2.x / 2, y: 2 * mid.y - p0.y / 2 - p2.y / 2)
                v2 = CGPoint(x: p1.x - p.x, y: p1.y - p.y)
            } else {
                v2 = CGPoint(x: nextP.x - p.x, y: nextP.y - p.y)
            }
            
            let len1 = hypot(v1.x, v1.y)
            let len2 = hypot(v2.x, v2.y)
            
            if len1 < 1 || len2 < 1 { continue }
            
            var startAngle = atan2(v1.y, v1.x)
            let endAngle = atan2(v2.y, v2.x)
            
            var diff = endAngle - startAngle
            if diff > .pi { diff -= 2 * .pi }
            else if diff < -.pi { diff += 2 * .pi }
            
            let angleDeg = abs(Int(round(diff * 180 / .pi)))
            if angleDeg == 0 || angleDeg == 180 { continue }
            
            var clockwise = diff > 0
            var bisectorAngle = startAngle + diff / 2
            
            // Check if the small angle points inside the shape
            let testPoint = CGPoint(x: p.x + cos(bisectorAngle) * 3, y: p.y + sin(bisectorAngle) * 3)
            let isInside = shapePath.contains(testPoint, using: .winding, transform: .identity)
            
            let displayAngleDeg: Int
            if isInside {
                displayAngleDeg = angleDeg
            } else {
                displayAngleDeg = 360 - angleDeg
                clockwise = !clockwise
                bisectorAngle += .pi
            }
            
            // Determine the base radius of the arc based on the size of the angle.
            // Pushing the arc further away for smaller angles makes them wider and significantly more visible.
            let baseArcRadius: CGFloat
            if angleDeg < 15 {
                baseArcRadius = 70
            } else if angleDeg < 30 {
                baseArcRadius = 55
            } else if angleDeg < 45 {
                baseArcRadius = 40
            } else if angleDeg < 60 {
                baseArcRadius = 30
            } else {
                baseArcRadius = 25
            }
            
            // Limit the arc radius to at most half of the shortest adjacent segment length to prevent overshooting.
            let minLen = min(len1, len2)
            let arcRadius = min(baseArcRadius, max(15, minLen * 0.5))
            
            path.move(to: CGPoint(x: p.x + v1.x/len1 * arcRadius, y: p.y + v1.y/len1 * arcRadius))
            path.addArc(withCenter: p, radius: arcRadius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            
            
            // to avoid overlapping with the closely converging lines.
            let labelOffset: CGFloat = displayAngleDeg < 30 ? 30 : (displayAngleDeg < 45 ? 25 : 15)
            let labelRadius = arcRadius + labelOffset
            let labelCenter = CGPoint(x: p.x + cos(bisectorAngle) * labelRadius, y: p.y + sin(bisectorAngle) * labelRadius)
            
            let label: UILabel
            if labelIndex < angleLabels.count {
                label = angleLabels[labelIndex]
            } else {
                label = UILabel()
                label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
                label.textColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0)
                label.textAlignment = .center
                label.backgroundColor = .clear
                label.shadowColor = UIColor.black
                label.shadowOffset = CGSize(width: 1, height: 1)
                self.addSubview(label)
                angleLabels.append(label)
            }
            labelIndex += 1
            
            label.text = "\(displayAngleDeg)°"
            label.sizeToFit()
            label.center = labelCenter
            label.isHidden = false
        }
        
        angleLayer!.path = path.cgPath
        curveHandlesLayer!.path = handlesPath.cgPath
    }
    func getCenterPoint(_ to: CGPoint, _ from: CGPoint) -> CGPoint
    {
        
        let x = (to.x + from.x)/2
        let y = (to.y + from.y)/2
        return CGPoint(x: x , y: y)
    }
    func getdistanceofpoint(_ to: CGPoint, _ from: CGPoint) -> CGFloat
    {
        let xDist = to.x - from.x
        let yDist = to.y - from.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func alphaFromPoint(point: CGPoint) -> CGFloat {
        
        
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let alphaInfo : CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: alphaInfo.rawValue) //need add .rawValue to alphaInfo
        
        context!.translateBy(x: -point.x, y: -point.y);
        
        self.shapeLayere!.render(in: context!)
        
        let floatAlpha = CGFloat(pixel[3])
        return floatAlpha
        
        
        
    }
    func removeAllPoints()
    {
        self.deselectSegment()
        for point in pointPath
        {
            point.subView.removeFromSuperview()
        }
    }
    func setPoints()
    {
        if pointPath.count < 2 {
            for point in pointPath {
                point.subView.removeFromSuperview()
            }
            return
        }
        var i = 0
        for point in pointPath
        {
            
            point.subView.tag = i
            point.subView.backgroundColor = .clear
            point.subView.layer.borderWidth = 0
            point.subView.center = point.point
            
            // Style the outer ring (diameter 18)
            point.dotView.backgroundColor = UIColor(red: 0.9, green: 0.88, blue: 0.78, alpha: 0.4)
            point.dotView.layer.borderColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
            point.dotView.layer.borderWidth = 1.5
            
            // Style the inner core dot (diameter 8)
            point.coreView.backgroundColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0)
            
            self.bringSubviewToFront(point.label)
            if point.subView.superview == nil {
                addGestureToPints(point.subView)
                self.addSubview(point.subView)
            }
            self.bringSubviewToFront(point.subView)
            i += 1
        }
        
    }
    
    
    
    
    var longPressStartLocations = [UIView: CGPoint]()
    
    func addGestureToPints(_ subView:UIView){
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        subView.addGestureRecognizer(gesture)
        subView.isUserInteractionEnabled = true
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(wasDoubleTaped(gestureRecognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        subView.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(wasSingleTaped(gestureRecognizer:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.require(toFail: doubleTapGesture)
        subView.addGestureRecognizer(singleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(wasLongPressed(gestureRecognizer:)))
        subView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func wasDoubleTaped(gestureRecognizer: UITapGestureRecognizer) {
        if let subview = gestureRecognizer.view {
            if(pointPath.count - 1 > subview.tag && subview.tag > 0)
            {
                saveState()
                pointPath[subview.tag].isCorved = !pointPath[subview.tag].isCorved
                moveShape()
                setPoints()
            }
        }
    }
    
    @objc func wasSingleTaped(gestureRecognizer: UITapGestureRecognizer) {
        if let subview = gestureRecognizer.view {
            let tagIndex = subview.tag
            if tagIndex == 0 && !isClosed && pointPath.count >= 3 {
                saveState()
                
                UIView.animate(withDuration: 0.3) {
                    self.isClosed = true
                    self.drowShape(true)
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func wasLongPressed(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let draggedView = gestureRecognizer.view else { return }
        
        if gestureRecognizer.state == .began {
            saveState()
            isDraggingPoint = true
            longPressStartLocations[draggedView] = gestureRecognizer.location(in: self)
        }
        
        if gestureRecognizer.state == .changed {
            self.endEditing(true)
            let currentLocation = gestureRecognizer.location(in: self)
            guard let startLocation = longPressStartLocations[draggedView] else { return }
            
            let translation = CGPoint(x: currentLocation.x - startLocation.x, y: currentLocation.y - startLocation.y)
            
            let tagIndex = draggedView.tag
            let currentCenter = draggedView.center
            
            let xConnected = getXConnectedIndices(from: tagIndex, pointPath: pointPath)
            let yConnected = getYConnectedIndices(from: tagIndex, pointPath: pointPath)
            let snapUnit = minimumValue / 2.0
            var actualDx: CGFloat = 0
            var actualDy: CGFloat = 0
            
            if xConnected.count > 1 || yConnected.count > 1 {
                var xAnchor: CGPoint? = nil
                var yAnchor: CGPoint? = nil
                
                for idx in xConnected {
                    let idxNeighbors = isClosed ? [(idx - 1 + pointPath.count) % pointPath.count, (idx + 1) % pointPath.count] : [idx - 1, idx + 1].filter { $0 >= 0 && $0 < pointPath.count }
                    for n in idxNeighbors {
                        if !xConnected.contains(n) { xAnchor = pointPath[n].point; break }
                    }
                    if xAnchor != nil { break }
                }
                
                for idx in yConnected {
                    let idxNeighbors = isClosed ? [(idx - 1 + pointPath.count) % pointPath.count, (idx + 1) % pointPath.count] : [idx - 1, idx + 1].filter { $0 >= 0 && $0 < pointPath.count }
                    for n in idxNeighbors {
                        if !yConnected.contains(n) { yAnchor = pointPath[n].point; break }
                    }
                    if yAnchor != nil { break }
                }
                
                let targetX = currentCenter.x + translation.x
                let targetY = currentCenter.y + translation.y
                
                let snappedX = xAnchor != nil ? xAnchor!.x + round((targetX - xAnchor!.x) / snapUnit) * snapUnit : round(targetX / snapUnit) * snapUnit
                let snappedY = yAnchor != nil ? yAnchor!.y + round((targetY - yAnchor!.y) / snapUnit) * snapUnit : round(targetY / snapUnit) * snapUnit
                
                actualDx = snappedX - currentCenter.x
                actualDy = snappedY - currentCenter.y
            } else {
                let prevPt = isClosed ? pointPath[(tagIndex - 1 + pointPath.count) % pointPath.count].point : (tagIndex > 0 ? pointPath[tagIndex - 1].point : nil)
                let nextPt = isClosed ? pointPath[(tagIndex + 1) % pointPath.count].point : (tagIndex < pointPath.count - 1 ? pointPath[tagIndex + 1].point : nil)
                
                let rawTargetX = currentCenter.x + translation.x
                let rawTargetY = currentCenter.y + translation.y
                
                var finalTargetX = rawTargetX
                var finalTargetY = rawTargetY
                
                if let p1 = prevPt, let p2 = nextPt {
                    let d1 = hypot(rawTargetX - p1.x, rawTargetY - p1.y)
                    let d2 = hypot(rawTargetX - p2.x, rawTargetY - p2.y)
                    let l1 = round(d1 / snapUnit) * snapUnit
                    let l2 = round(d2 / snapUnit) * snapUnit
                    
                    var bestIntersection: CGPoint? = nil
                    var minD: CGFloat = .infinity
                    for dl1 in [-snapUnit, 0.0, snapUnit] {
                        for dl2 in [-snapUnit, 0.0, snapUnit] {
                            let r1 = max(snapUnit, l1 + dl1)
                            let r2 = max(snapUnit, l2 + dl2)
                            let inters = self.getCircleIntersections(center1: p1, radius1: r1, center2: p2, radius2: r2)
                            for inter in inters {
                                let dist = hypot(inter.x - rawTargetX, inter.y - rawTargetY)
                                if dist < minD {
                                    minD = dist
                                    bestIntersection = inter
                                }
                            }
                        }
                    }
                    
                    if let best = bestIntersection {
                        finalTargetX = best.x
                        finalTargetY = best.y
                    } else {
                        let refPoint = p1
                        let targetPoint = self.getLimitedPoint(at: CGPoint(x: rawTargetX, y: rawTargetY), referencePoint: refPoint)
                        finalTargetX = targetPoint.x
                        finalTargetY = targetPoint.y
                    }
                } else {
                    let refPoint = prevPt ?? nextPt
                    let targetPoint = self.getLimitedPoint(at: CGPoint(x: rawTargetX, y: rawTargetY), referencePoint: refPoint)
                    finalTargetX = targetPoint.x
                    finalTargetY = targetPoint.y
                }
                
                actualDx = finalTargetX - currentCenter.x
                actualDy = finalTargetY - currentCenter.y
            }
            
            if actualDx != 0 || actualDy != 0 {
                let xConnected = getXConnectedIndices(from: tagIndex, pointPath: pointPath)
                let yConnected = getYConnectedIndices(from: tagIndex, pointPath: pointPath)
                
                for idx in xConnected {
                    var p = pointPath[idx].point
                    p.x += actualDx
                    pointPath[idx].point = p
                    pointPath[idx].subView.center = p
                }
                
                for idx in yConnected {
                    var p = pointPath[idx].point
                    p.y += actualDy
                    pointPath[idx].point = p
                    pointPath[idx].subView.center = p
                }
                
                longPressStartLocations[draggedView] = CGPoint(x: currentLocation.x - (translation.x - actualDx), y: currentLocation.y - (translation.y - actualDy))
                moveShape()
            }
        }
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled || gestureRecognizer.state == .failed {
            isDraggingPoint = false
            longPressStartLocations.removeValue(forKey: draggedView)
            
            if !isClosed && gestureRecognizer.state == .ended {
                let tagIndex = draggedView.tag
                if tagIndex == pointPath.count - 1 && pointPath.count >= 3 {
                    let distance = getdistanceofpoint(pointPath[0].point, pointPath.last!.point)
                    if distance < 60 {
                        let removedPt = pointPath.removeLast()
                        removedPt.subView.removeFromSuperview()
                        removedPt.label.removeFromSuperview()
                        
                        UIView.animate(withDuration: 0.3) {
                            self.isClosed = true
                            self.drowShape(true)
                            self.layoutIfNeeded()
                        }
                        return
                    }
                }
            }
            
            moveShape()
        }
    }
    private func getXConnectedIndices(from startIndex: Int, pointPath: [customPointObjcet]) -> Set<Int> {
        var visited = Set<Int>([startIndex])
        
        // If the dragged point is a curve control point, it should act independently.
        if pointPath[startIndex].isCorved {
            return visited
        }
        
        var queue = [startIndex]
        let count = pointPath.count
        guard count > 0 else { return visited }
        
        while !queue.isEmpty {
            let curr = queue.removeFirst()
            var neighbors: [Int] = []
            if isClosed {
                neighbors.append((curr - 1 + count) % count)
                neighbors.append((curr + 1) % count)
            } else {
                if curr > 0 {
                    neighbors.append(curr - 1)
                }
                if curr < count - 1 {
                    neighbors.append(curr + 1)
                }
            }
            
            for neighbor in neighbors {
                if !visited.contains(neighbor) {
                    if pointPath[neighbor].isCorved { continue }
                    
                    let p1 = pointPath[curr].point
                    let p2 = pointPath[neighbor].point
                    if abs(p1.x - p2.x) < 1.0 {
                        visited.insert(neighbor)
                        queue.append(neighbor)
                    }
                }
            }
        }
        return visited
    }

    private func getYConnectedIndices(from startIndex: Int, pointPath: [customPointObjcet]) -> Set<Int> {
        var visited = Set<Int>([startIndex])
        
        // If the dragged point is a curve control point, it should act independently.
        if pointPath[startIndex].isCorved {
            return visited
        }
        
        var queue = [startIndex]
        let count = pointPath.count
        guard count > 0 else { return visited }
        
        while !queue.isEmpty {
            let curr = queue.removeFirst()
            var neighbors: [Int] = []
            if isClosed {
                neighbors.append((curr - 1 + count) % count)
                neighbors.append((curr + 1) % count)
            } else {
                if curr > 0 {
                    neighbors.append(curr - 1)
                }
                if curr < count - 1 {
                    neighbors.append(curr + 1)
                }
            }
            
            for neighbor in neighbors {
                if !visited.contains(neighbor) {
                    if pointPath[neighbor].isCorved { continue }
                    
                    let p1 = pointPath[curr].point
                    let p2 = pointPath[neighbor].point
                    if abs(p1.y - p2.y) < 1.0 {
                        visited.insert(neighbor)
                        queue.append(neighbor)
                    }
                }
            }
        }
        return visited
    }

    func distanceFromPoint(p: CGPoint, toSegmentFrom a: CGPoint, to b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        
        if lengthSquared == 0 {
            return hypot(p.x - a.x, p.y - a.y)
        }
        
        var t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSquared
        t = max(0, min(1, t))
        
        let closestPoint = CGPoint(x: a.x + t * dx, y: a.y + t * dy)
        return hypot(p.x - closestPoint.x, p.y - closestPoint.y)
    }
    
    func distanceFromPoint(p: CGPoint, toCurveFrom p1: CGPoint, control: CGPoint, to p2: CGPoint) -> CGFloat {
        var minDistance: CGFloat = .infinity
        let steps = 10
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let mt = 1.0 - t
            let x = mt * mt * p1.x + 2 * mt * t * control.x + t * t * p2.x
            let y = mt * mt * p1.y + 2 * mt * t * control.y + t * t * p2.y
            let dist = hypot(p.x - x, p.y - y)
            if dist < minDistance {
                minDistance = dist
            }
        }
        return minDistance
    }
    func getCircleIntersections(center1: CGPoint, radius1: CGFloat, center2: CGPoint, radius2: CGFloat) -> [CGPoint] {
        let dx = center2.x - center1.x
        let dy = center2.y - center1.y
        let d = hypot(dx, dy)
        if d > radius1 + radius2 || d < abs(radius1 - radius2) || d == 0 { return [] }
        let a = (radius1 * radius1 - radius2 * radius2 + d * d) / (2 * d)
        let h = sqrt(max(0, radius1 * radius1 - a * a))
        let p2x = center1.x + a * (center2.x - center1.x) / d
        let p2y = center1.y + a * (center2.y - center1.y) / d
        let p3x1 = p2x + h * (center2.y - center1.y) / d
        let p3y1 = p2y - h * (center2.x - center1.x) / d
        let p3x2 = p2x - h * (center2.y - center1.y) / d
        let p3y2 = p2y + h * (center2.x - center1.x) / d
        return [CGPoint(x: p3x1, y: p3y1), CGPoint(x: p3x2, y: p3y2)]
    }
    
    func findClickedSegment(at position: CGPoint) -> Int? {
        let count = pointPath.count
        guard count >= 2 else { return nil }
        
        var minDistance: CGFloat = .infinity
        var bestIndex: Int? = nil
        
        let limit = isClosed ? count : count - 1
        for i in 0..<limit {
            let currIdx = (i + 1) % count
            let prevIdx = i
            
            if pointPath[prevIdx].isCorved {
                continue
            }
            
            if pointPath[currIdx].isCorved {
                let startPt = pointPath[prevIdx].point
                let midPt = pointPath[currIdx].point
                let endPt = pointPath[(currIdx + 1) % count].point
                let curvpoints = getCurvePoints(startPoint: startPt, endPoint: endPt, midilePoint: midPt)
                let ctrlPt = curvpoints[1]
                let dist = distanceFromPoint(p: position, toCurveFrom: startPt, control: ctrlPt, to: endPt)
                if dist < minDistance {
                    minDistance = dist
                    bestIndex = currIdx
                }
            } else {
                let startPt = pointPath[prevIdx].point
                let endPt = pointPath[currIdx].point
                let dist = distanceFromPoint(p: position, toSegmentFrom: startPt, to: endPt)
                if dist < minDistance {
                    minDistance = dist
                    bestIndex = currIdx
                }
            }
        }
        
        let threshold: CGFloat = 20.0
        if minDistance <= threshold {
            return bestIndex
        }
        return nil
    }

    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            saveState()
            isDraggingPoint = true
        }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            self.endEditing(true)
            let translation = gestureRecognizer.translation(in: self)
            
            if let draggedView = gestureRecognizer.view {
                let tagIndex = draggedView.tag
                let currentCenter = draggedView.center
                
                let xConnected = getXConnectedIndices(from: tagIndex, pointPath: pointPath)
                let yConnected = getYConnectedIndices(from: tagIndex, pointPath: pointPath)
                let snapUnit = minimumValue / 2.0
                var actualDx: CGFloat = 0
                var actualDy: CGFloat = 0
                
                if xConnected.count > 1 || yConnected.count > 1 {
                    var xAnchor: CGPoint? = nil
                    var yAnchor: CGPoint? = nil
                    
                    for idx in xConnected {
                        let idxNeighbors = isClosed ? [(idx - 1 + pointPath.count) % pointPath.count, (idx + 1) % pointPath.count] : [idx - 1, idx + 1].filter { $0 >= 0 && $0 < pointPath.count }
                        for n in idxNeighbors {
                            if !xConnected.contains(n) { xAnchor = pointPath[n].point; break }
                        }
                        if xAnchor != nil { break }
                    }
                    
                    for idx in yConnected {
                        let idxNeighbors = isClosed ? [(idx - 1 + pointPath.count) % pointPath.count, (idx + 1) % pointPath.count] : [idx - 1, idx + 1].filter { $0 >= 0 && $0 < pointPath.count }
                        for n in idxNeighbors {
                            if !yConnected.contains(n) { yAnchor = pointPath[n].point; break }
                        }
                        if yAnchor != nil { break }
                    }
                    
                    let targetX = currentCenter.x + translation.x
                    let targetY = currentCenter.y + translation.y
                    
                    let snappedX = xAnchor != nil ? xAnchor!.x + round((targetX - xAnchor!.x) / snapUnit) * snapUnit : round(targetX / snapUnit) * snapUnit
                    let snappedY = yAnchor != nil ? yAnchor!.y + round((targetY - yAnchor!.y) / snapUnit) * snapUnit : round(targetY / snapUnit) * snapUnit
                    
                    actualDx = snappedX - currentCenter.x
                    actualDy = snappedY - currentCenter.y
                } else {
                    let prevPt = isClosed ? pointPath[(tagIndex - 1 + pointPath.count) % pointPath.count].point : (tagIndex > 0 ? pointPath[tagIndex - 1].point : nil)
                    let nextPt = isClosed ? pointPath[(tagIndex + 1) % pointPath.count].point : (tagIndex < pointPath.count - 1 ? pointPath[tagIndex + 1].point : nil)
                    
                    let rawTargetX = currentCenter.x + translation.x
                    let rawTargetY = currentCenter.y + translation.y
                    
                    var finalTargetX = rawTargetX
                    var finalTargetY = rawTargetY
                    
                    if let p1 = prevPt, let p2 = nextPt {
                        let d1 = hypot(rawTargetX - p1.x, rawTargetY - p1.y)
                        let d2 = hypot(rawTargetX - p2.x, rawTargetY - p2.y)
                        let l1 = round(d1 / snapUnit) * snapUnit
                        let l2 = round(d2 / snapUnit) * snapUnit
                        
                        var bestIntersection: CGPoint? = nil
                        var minD: CGFloat = .infinity
                        for dl1 in [-snapUnit, 0.0, snapUnit] {
                            for dl2 in [-snapUnit, 0.0, snapUnit] {
                                let r1 = max(snapUnit, l1 + dl1)
                                let r2 = max(snapUnit, l2 + dl2)
                                let inters = self.getCircleIntersections(center1: p1, radius1: r1, center2: p2, radius2: r2)
                                for inter in inters {
                                    let dist = hypot(inter.x - rawTargetX, inter.y - rawTargetY)
                                    if dist < minD {
                                        minD = dist
                                        bestIntersection = inter
                                    }
                                }
                            }
                        }
                        
                        if let best = bestIntersection {
                            finalTargetX = best.x
                            finalTargetY = best.y
                        } else {
                            let refPoint = p1
                            let targetPoint = self.getLimitedPoint(at: CGPoint(x: rawTargetX, y: rawTargetY), referencePoint: refPoint)
                            finalTargetX = targetPoint.x
                            finalTargetY = targetPoint.y
                        }
                    } else {
                        let refPoint = prevPt ?? nextPt
                        let targetPoint = self.getLimitedPoint(at: CGPoint(x: rawTargetX, y: rawTargetY), referencePoint: refPoint)
                        finalTargetX = targetPoint.x
                        finalTargetY = targetPoint.y
                    }
                    
                    actualDx = finalTargetX - currentCenter.x
                    actualDy = finalTargetY - currentCenter.y
                }
                
                if actualDx != 0 || actualDy != 0 {
                    let xConnected = getXConnectedIndices(from: tagIndex, pointPath: pointPath)
                    let yConnected = getYConnectedIndices(from: tagIndex, pointPath: pointPath)
                    
                    for idx in xConnected {
                        var p = pointPath[idx].point
                        p.x += actualDx
                        pointPath[idx].point = p
                        pointPath[idx].subView.center = p
                    }
                    
                    for idx in yConnected {
                        var p = pointPath[idx].point
                        p.y += actualDy
                        pointPath[idx].point = p
                        pointPath[idx].subView.center = p
                    }
                    
                    gestureRecognizer.setTranslation(CGPoint(x: translation.x - actualDx, y: translation.y - actualDy), in: self)
                    moveShape()
                }
            }
        }
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled || gestureRecognizer.state == .failed {
            isDraggingPoint = false
            
            if !isClosed && gestureRecognizer.state == .ended {
                if let draggedView = gestureRecognizer.view {
                    let tagIndex = draggedView.tag
                    // Check if it's the last point being dragged near the first point
                    if tagIndex == pointPath.count - 1 && pointPath.count >= 3 {
                        let distance = getdistanceofpoint(pointPath[0].point, pointPath.last!.point)
                        if distance < 60 {
                            let removedPt = pointPath.removeLast()
                            removedPt.subView.removeFromSuperview()
                            removedPt.label.removeFromSuperview()
                            
                            UIView.animate(withDuration: 0.3) {
                                self.isClosed = true
                                self.drowShape(true)
                                self.layoutIfNeeded()
                            }
                            return
                        }
                    }
                }
            }
            
            moveShape()
        }
    }
    
    
    
    //       override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //           self.currentContext = nil
    //           self.prevImage = self.drawingCanvas.image
    //       }
    //
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension LineView{
    func createClosedPathWithPoints(points:CGPoint,count:size_t) -> CGPath {
        let path = CGMutablePath()
        
        return path;
    }
    
    func integralFrameForPath(path:CGPath) -> CGRect{
        let tmpframe = path.boundingBox;
        return tmpframe.integral;
    }
    
    func bytesPerRowForWidth(width:CGFloat) -> size_t {
        let kFactor:size_t = 64;
        // Round up to a multiple of kFactor, which must be a power of 2.
        return (size_t(width) + (kFactor - 1)) & ~(kFactor - 1);
    }
    
    func getarea() -> CGFloat
    {
        let xMax = buzierpath.cgPath.boundingBox.maxX
        let yMax = buzierpath.cgPath.boundingBox.maxY
        let xMin = buzierpath.cgPath.boundingBox.minX
        let yMin = buzierpath.cgPath.boundingBox.minY
        var area:CGFloat = 0.0
        
        let width = max(1.0, xMax - xMin)
        let height = max(1.0, yMax - yMin)
        
        let stepX = min(10.0, max(0.01, width / 50.0))
        let stepY = min(10.0, max(0.01, height / 50.0))
        
        // Midpoint sampling to avoid edge cases
        for x in stride(from: xMin + stepX/2, to: xMax, by: stepX) {
            for y in stride(from: yMin + stepY/2, to: yMax, by: stepY) {
                let point = CGPoint(x: x, y: y)
                if(buzierpath.cgPath.contains(point, using: .winding, transform:.identity))
                {
                    area += (stepX * stepY)
                }
            }
        }
        
        let value = (area/(minimumValue * minimumValue) * 100).rounded(.down)/100
        return value
    }
    func getPerimeter() -> Float
    {
        
        var value:Float = 0
        for path in self.pointPath
        {
            value += path.lineValue
        }
        return value
        
        
    }
    
    //    func createBitmapContextWithFrame(frame:CGRect ,bytesPerRow: size_t ) -> CGContext {
    //        let grayscale = CGColorSpaceCreateDeviceGray();
    //
    //        let gc:CGContext = CGContext(data: nil, width: Int(Float(frame.size.width ?? 0)), height:  Int(Float(frame.size.width ?? 0)), bitsPerComponent: 64, bytesPerRow: 64, space: grayscale, bitmapInfo: .max)
    //       // CGContextRef gc = CGBitmapContextCreate(NULL, frame.size.width, frame.size.height, 8, bytesPerRow, grayscale, kCGImageAlphaNone);
    //       // CGColorSpaceRelease(grayscale);
    //       // CGContextTranslateCTM(gc, -frame.origin.x, -frame.origin.x);
    //        return gc;
    //    }
    
    
    //    func areaFilledInBitmapContext(gc:CGContext) -> Double {
    //        let width:size_t = gc.width
    //        let height:size_t  = gc.height
    //        let stride:size_t  = gc.bytesPerRow
    //        let pixels:UInt8 = UInt8(gc.bitmapInfo.rawValue)
    //        var coverage:UInt8 = 0;
    //        for y in 0...height
    //        {
    //            for x in 0...width
    //            {
    //
    //               coverage += pixels[y * stride + x]
    //            }
    //        }
    //
    //        for (size_t y = 0; y < height; ++y) {
    //            for (size_t x = 0; x < width; ++x) {
    //                coverage += pixels[y * stride + x];
    //            }
    //        }
    //        return (double)coverage / UINT8_MAX;
    //    }
    
    
    //    static double areaOfCurveWithPoints(const CGPoint *points, size_t count) {
    //        CGPathRef path = createClosedPathWithPoints(points, count);
    //        CGRect frame = integralFrameForPath(path);
    //        size_t bytesPerRow = bytesPerRowForWidth(frame.size.width);
    //        CGContextRef gc = createBitmapContextWithFrame(frame, bytesPerRow);
    //
    //        CGContextSetFillColorWithColor(gc, [UIColor whiteColor].CGColor);
    //        CGContextAddPath(gc, path);
    //        CGContextFillPath(gc);
    //        CGPathRelease(path);
    //
    //        double area = areaFilledInBitmapContext(gc);
    //        CGContextRelease(gc);
    //
    //        return area;
    //    }
    
    
    
    func add_Sub_Square_View(xAsis:CGFloat,yAxis:CGFloat,width:CGFloat,hight:CGFloat,delegate:CustomViewDelegate,isVertical:Bool,objc:OpeningCustomObject,addViewHeight: String,transitionheightId:Int)
          {
              self.saveState()
              let subView = SubSqureView(frame: CGRect(x: xAsis, y: yAxis, width: width * minimumValue, height: hight * minimumValue),isVertical:isVertical, color: objc.color)
                  
              subView.custom_width = width
              subView.custom_hight = hight
              subView.change_color_of_path(objc.color)
              subView.object = objc
              subView.customDelegate = delegate
              subView.tag = self.subSquareView.count
              subView.isUserInteractionEnabled = true
              subView.addViewHeight = addViewHeight
              subView.transitionHeightId = transitionheightId
              self.subSquareView.append(subView)
              self.addSubview(subView)
              UIView.animate(withDuration: 0.3) {
                     subView.customDelegate?.customViewDelegateResult(subView.tag)
              }
          }
    
    
    func remove_Sub_Square_View(at Index:Int)
    {
        self.saveState()
        self.subSquareView[Index].removeFromSuperview()
        self.subSquareView.remove(at: Index)
        if(self.subSquareView.count > 0)
        {
        for i in 0...(self.subSquareView.count - 1)
                {
                    self.subSquareView[i].tag = i
                }
        }
    }
    func clear_All_Sub_Square_View()
    {
        if !subSquareView.isEmpty {
            self.saveState()
        }
        for view in subSquareView
        {
            view.removeFromSuperview()
        }
        self.subSquareView.removeAll()
    }
    func setSubSelectedView(at position:Int)
    {
        for subviewTemp in subSquareView
        {
            if(subviewTemp.tag == position)
            {
                subviewTemp.change_color_of_path(subviewTemp.color)
            }
            else
            {
                subviewTemp.change_color_of_path(subviewTemp.color)
            }
        }
    }
    
    func selectSegment(at index: Int) {
        selectedSegmentIndex = index
        drawHighlight()
        updateLabelsSelectionState()
    }
    
    func deselectSegment() {
        selectedSegmentIndex = nil
        highlightLayer?.removeFromSuperlayer()
        highlightLayer = nil
        updateLabelsSelectionState()
    }
    
    func drawHighlight() {
        highlightLayer?.removeFromSuperlayer()
        highlightLayer = nil
        
        guard let index = selectedSegmentIndex, index < pointPath.count else { return }
        let count = pointPath.count
        guard count >= 2 else { return }
        
        let p2 = pointPath[index].point
        let p1 = pointPath[(index - 1 + count) % count].point
        
        let path = UIBezierPath()
        path.move(to: p1)
        
        if pointPath[index].isCorved {
            let nextPoint = pointPath[(index + 1) % count].point
            let curvpoints = getCurvePoints(startPoint: p1, endPoint: nextPoint, midilePoint: p2)
            path.addQuadCurve(to: curvpoints[0], controlPoint: curvpoints[1])
        } else {
            path.addLine(to: p2)
        }
        
        let hlLayer = CAShapeLayer()
        hlLayer.path = path.cgPath
        hlLayer.fillColor = UIColor.clear.cgColor
        hlLayer.strokeColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
        hlLayer.lineWidth = 8.0
        hlLayer.lineCap = .round
        
        if let shape = shapeLayere {
            self.layer.insertSublayer(hlLayer, above: shape)
        } else {
            self.layer.addSublayer(hlLayer)
        }
        highlightLayer = hlLayer
    }
    
    func updateLabelsSelectionState() {
        for (i, point) in pointPath.enumerated() {
            if let controlView = point.label as? LineSegmentControlView {
                controlView.setSelected(selectedSegmentIndex == nil ? nil : (selectedSegmentIndex == i))
            }
        }
    }
    func configureForPreview(_ isPreview: Bool) {
        let goldColor = UIColor().colorFromHexString("#958E3E")
        let normalLineColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0)
        
        self.backgroundColor = isPreview ? .clear : .clear
        self.shapeLayere?.strokeColor = isPreview ? goldColor.cgColor : normalLineColor.cgColor
        
        for angleLabel in angleLabels {
            angleLabel.textColor = isPreview ? goldColor : normalLineColor
        }
        
        for point in pointPath {
            point.dotView.isHidden = isPreview
            if let controlView = point.label as? LineSegmentControlView {
                controlView.minusButton.isHidden = isPreview
                controlView.plusButton.isHidden = isPreview
                if isPreview {
                    controlView.containerPill.backgroundColor = goldColor
                    controlView.feetTextField.backgroundColor = .clear
                    controlView.feetTextField.textColor = .white
                    controlView.inchesTextField.backgroundColor = .clear
                    controlView.inchesTextField.textColor = .white
                    
                    controlView.containerPill.frame = CGRect(x: 15, y: 22, width: 100, height: 30)
                    controlView.feetTextField.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    controlView.feetLabel.frame = CGRect(x: 30, y: 0, width: 20, height: 30)
                    controlView.inchesTextField.frame = CGRect(x: 50, y: 0, width: 28, height: 30)
                    controlView.inchesLabel.frame = CGRect(x: 78, y: 0, width: 22, height: 30)
                    
                    controlView.feetLabel.textColor = .white
                    controlView.wallBadgeLabel.isHidden = true
                    controlView.wallBadgeLabel.frame = CGRect(x: 30, y: 0, width: 70, height: 20)
                    controlView.wallBadgeLabel.backgroundColor = .clear
                    controlView.wallBadgeLabel.textColor = .white
                    controlView.wallBadgeLabel.layer.cornerRadius = 10
                    controlView.wallBadgeLabel.clipsToBounds = true
                    
                    controlView.moldingDropdownButton.isHidden = true
                    controlView.moldingDropdownButton.frame = CGRect(x: 0, y: 54, width: 130, height: 24)
                    controlView.moldingDropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                    controlView.moldingDropdownButton.isUserInteractionEnabled = false
                    controlView.moldingDropdownButton.backgroundColor = .clear
                    controlView.moldingDropdownButton.setTitleColor(.white, for: .normal)
                    controlView.moldingDropdownButton.layer.borderWidth = 0
                    controlView.moldingDropdownButton.setImage(nil, for: .normal)
                } else {
                    controlView.containerPill.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
                    controlView.feetTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
                    controlView.feetTextField.textColor = .white
                    controlView.feetLabel.textColor = .white
                    controlView.inchesTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
                    controlView.inchesTextField.textColor = .white
                    controlView.inchesLabel.textColor = .white
                    
                    controlView.wallBadgeLabel.isHidden = true
                    controlView.wallBadgeLabel.backgroundColor = .clear
                    controlView.wallBadgeLabel.textColor = UIColor(red: 167/255, green: 176/255, blue: 186/255, alpha: 1.0)
                    
                    controlView.moldingDropdownButton.isHidden = true
                    controlView.moldingDropdownButton.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
                    controlView.moldingDropdownButton.setTitleColor(UIColor(red: 167/255, green: 176/255, blue: 186/255, alpha: 1.0), for: .normal)
                    controlView.moldingDropdownButton.layer.borderWidth = 1
                    if #available(iOS 13.0, *) {
                        controlView.moldingDropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                    }
                    
                    controlView.containerPill.frame = CGRect(x: 12, y: 24, width: 196, height: 34)
                    controlView.wallBadgeLabel.frame = CGRect(x: 75, y: 0, width: 70, height: 20)
                    controlView.moldingDropdownButton.frame = CGRect(x: 52, y: 62, width: 135, height: 38)
                    controlView.moldingDropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                    controlView.moldingDropdownButton.isUserInteractionEnabled = true
                    
                    controlView.minusButton.frame = CGRect(x: 6, y: 6, width: 22, height: 22)
                    controlView.feetTextField.frame = CGRect(x: 34, y: 4, width: 40, height: 26)
                    controlView.feetLabel.frame = CGRect(x: 76, y: 4, width: 18, height: 26)
                    controlView.inchesTextField.frame = CGRect(x: 98, y: 4, width: 36, height: 26)
                    controlView.inchesLabel.frame = CGRect(x: 136, y: 4, width: 22, height: 26)
                    controlView.plusButton.frame = CGRect(x: 168, y: 6, width: 22, height: 22)
                }
            }
        }
        

        
        for subSquare in subSquareView {
            subSquare.configureForPreview(isPreview)
        }
    }
}
class customPointObjcet:NSObject
{
    var label:UIView
    var point:CGPoint
    var lineValue:Float
    var isCorved:Bool
    var subView:UIView
    var dotView:UIView
    var coreView:UIView
    init(label:UIView, point:CGPoint,lineValue:Float) {
        self.label = label
        self.point = point
        self.lineValue = lineValue
        self.isCorved = false
        self.subView = UIView(frame: CGRect(origin: point, size: CGSize(width: 44, height: 44)))
        self.subView.backgroundColor = .clear
        
        // Outer dot view (diameter 18) centered in the 44x44 container
        self.dotView = UIView(frame: CGRect(x: 13, y: 13, width: 18, height: 18))
        self.dotView.layer.cornerRadius = 9
        self.dotView.clipsToBounds = true
        self.subView.addSubview(self.dotView)
        
        // Inner core dot view (diameter 12) centered in the 18x18 container
        self.coreView = UIView(frame: CGRect(x: 3, y: 3, width: 12, height: 12))
        self.coreView.layer.cornerRadius = 6
        self.coreView.clipsToBounds = true
        self.dotView.addSubview(self.coreView)
    }
}

class LineSegmentControlView: UIView, UITextFieldDelegate {
    weak var lineView: LineView?
    weak var pointObject: customPointObjcet?
    let wallBadgeLabel = UILabel()
    let moldingDropdownButton = UIButton(type: .custom)
    let containerPill = UIView()
    let minusButton = UIButton(type: .custom)
    let feetTextField = UITextField()
    let feetLabel = UILabel()
    let inchesTextField = UITextField()
    let inchesLabel = UILabel()
    let plusButton = UIButton(type: .custom)
    
    private var isUpdatingValue = false
    private var originalValueBeforeEditing: Float?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 220, height: 90))
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        
        // Wall Badge Setup
        wallBadgeLabel.frame = CGRect(x: 75, y: 0, width: 70, height: 20)
        wallBadgeLabel.isHidden = true
        wallBadgeLabel.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 0.9)
        wallBadgeLabel.textColor = .white
        wallBadgeLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        wallBadgeLabel.textAlignment = .center
        wallBadgeLabel.layer.cornerRadius = 10
        wallBadgeLabel.clipsToBounds = true
        self.addSubview(wallBadgeLabel)
        
        // Container Pill Setup
        containerPill.frame = CGRect(x: 12, y: 24, width: 196, height: 34)
        containerPill.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        containerPill.layer.cornerRadius = 17
        containerPill.clipsToBounds = true
        self.addSubview(containerPill)
        
        // Molding Dropdown Button Setup
        moldingDropdownButton.frame = CGRect(x: 52, y: 62, width: 135, height: 38)
        moldingDropdownButton.isHidden = true
        moldingDropdownButton.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        moldingDropdownButton.layer.cornerRadius = 19
        moldingDropdownButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        moldingDropdownButton.layer.borderWidth = 1
        moldingDropdownButton.setTitle("Select Molding", for: .normal)
        moldingDropdownButton.setTitleColor(UIColor(red: 167/255, green: 176/255, blue: 186/255, alpha: 1.0), for: .normal)
        moldingDropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        moldingDropdownButton.titleLabel?.lineBreakMode = .byTruncatingTail
        moldingDropdownButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        if #available(iOS 13.0, *) {
            moldingDropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            moldingDropdownButton.tintColor = UIColor(red: 167/255, green: 176/255, blue: 186/255, alpha: 1.0)
            moldingDropdownButton.semanticContentAttribute = .forceRightToLeft
            moldingDropdownButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        moldingDropdownButton.addTarget(self, action: #selector(moldingDropdownTapped), for: .touchUpInside)
        self.addSubview(moldingDropdownButton)
        
        // Minus Button Setup
        minusButton.frame = CGRect(x: 6, y: 6, width: 22, height: 22)
        minusButton.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        minusButton.layer.cornerRadius = 11
        minusButton.setTitle("−", for: .normal)
        minusButton.setTitleColor(.white, for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        containerPill.addSubview(minusButton)
        
        // Feet Text Field Setup
        feetTextField.frame = CGRect(x: 34, y: 4, width: 40, height: 26)
        feetTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
        feetTextField.textColor = .white
        feetTextField.textAlignment = .center
        feetTextField.font = UIFont(name: "Avenir-Black", size: 13)
        feetTextField.layer.cornerRadius = 6
        feetTextField.keyboardType = .numberPad
        feetTextField.delegate = self
        feetTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        containerPill.addSubview(feetTextField)
        
        feetLabel.frame = CGRect(x: 76, y: 4, width: 18, height: 26)
        feetLabel.text = "Ft."
        feetLabel.textColor = .white
        feetLabel.font = UIFont(name: "Avenir-Black", size: 12)
        feetLabel.textAlignment = .left
        containerPill.addSubview(feetLabel)
        
        // Inches Text Field Setup
        inchesTextField.frame = CGRect(x: 98, y: 4, width: 36, height: 26)
        inchesTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
        inchesTextField.textColor = .white
        inchesTextField.textAlignment = .center
        inchesTextField.font = UIFont(name: "Avenir-Black", size: 13)
        inchesTextField.layer.cornerRadius = 6
        inchesTextField.keyboardType = .numberPad
        inchesTextField.delegate = self
        inchesTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        containerPill.addSubview(inchesTextField)
        
        inchesLabel.frame = CGRect(x: 136, y: 4, width: 22, height: 26)
        inchesLabel.text = "In."
        inchesLabel.textColor = .white
        inchesLabel.font = UIFont(name: "Avenir-Black", size: 12)
        inchesLabel.textAlignment = .left
        containerPill.addSubview(inchesLabel)
        
        // Plus Button Setup
        plusButton.frame = CGRect(x: 168, y: 6, width: 22, height: 22)
        plusButton.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        plusButton.layer.cornerRadius = 11
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        containerPill.addSubview(plusButton)
    }
    
    func updateText(_ text: String) {
        guard !feetTextField.isFirstResponder && !inchesTextField.isFirstResponder else { return }
        let feetVal = parseFeetValue(text) ?? 0
        let totalInches = Int(round(feetVal * 12.0))
        let feet = totalInches / 12
        let inches = totalInches % 12
        
        feetTextField.text = "\(feet)"
        inchesTextField.text = "\(inches)"
    }
    
    @objc private func moldingDropdownTapped() {
        lineView?.showMoldingPopup(for: self)
    }
    
    @objc private func minusTapped() {
        guard let currentVal = pointObject?.lineValue else { return }
        if currentVal - 0.5 <= 0 {
            if let vc = lineView?.delegate as? UIViewController {
                let alert = UIAlertController(title: "Alert", message: "We cannot enter 0 as a measurement", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                vc.present(alert, animated: true, completion: nil)
            }
            return
        }
        let newVal = currentVal - 0.5
        lineView?.saveState()
        if let lineView = lineView, let pointObject = pointObject {
            if let index = lineView.pointPath.firstIndex(where: { $0 === pointObject }) {
                lineView.selectSegment(at: index)
            }
        }
        updateValue(newVal)
    }
    
    @objc private func plusTapped() {
        guard let currentVal = pointObject?.lineValue else { return }
        let newVal = currentVal + 0.5
        lineView?.saveState()
        if let lineView = lineView, let pointObject = pointObject {
            if let index = lineView.pointPath.firstIndex(where: { $0 === pointObject }) {
                lineView.selectSegment(at: index)
            }
        }
        updateValue(newVal)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard !isUpdatingValue else { return }
        
        let feet = Float(feetTextField.text ?? "0") ?? 0
        let inches = Float(inchesTextField.text ?? "0") ?? 0
        let val = feet + (inches / 12.0)
        
        if val > 0 {
            guard let pointObject = pointObject, let lineView = lineView else { return }
            pointObject.lineValue = val
            lineView.updateSegmentLength(for: pointObject, newLength: CGFloat(val))
        }
    }
    
    private func updateValue(_ newVal: Float) {
        guard let pointObject = pointObject, let lineView = lineView else { return }
        isUpdatingValue = true
        pointObject.lineValue = newVal
        
        let totalInches = Int(round(newVal * 12.0))
        let feet = totalInches / 12
        let inches = totalInches % 12
        feetTextField.text = "\(feet)"
        inchesTextField.text = "\(inches)"
        
        isUpdatingValue = false
        
        lineView.updateSegmentLength(for: pointObject, newLength: CGFloat(newVal))
    }
    
    func parseFeetValue(_ text: String) -> Float? {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let val = Float(cleanText) { return val }
        
        let lower = cleanText.lowercased()
        
        var feet: Float = 0
        var inches: Float = 0
        
        let numbers = lower.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        
        if lower.contains("ft") || lower.contains("'") {
            if numbers.count > 0, let f = Float(numbers[0]) {
                feet = f
            }
            if numbers.count > 1, let i = Float(numbers[1]) {
                inches = i
            }
        } else if lower.contains("in") || lower.contains("\"") || lower.contains("inc") {
            if numbers.count > 0, let i = Float(numbers[0]) {
                inches = i
            }
        }
        
        return feet + (inches / 12.0)
    }
    
    func formatFeetValue(_ val: Float) -> String {
        let ftValue = Int(val)
        let inchVal = Int(round((val - Float(ftValue)) * 12))
        
        if inchVal == 0 {
            return "\(ftValue) Ft."
        } else if inchVal == 12 {
            return "\(ftValue + 1) Ft."
        } else {
            return "\(ftValue) Ft. \(inchVal) In."
        }
    }
    
    // UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == inchesTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty {
                return true
            }
            
            if let intValue = Int(updatedText) {
                return intValue >= 0 && intValue <= 12
            }
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        originalValueBeforeEditing = pointObject?.lineValue
        lineView?.saveState()
        if let lineView = lineView, let pointObject = pointObject {
            if let index = lineView.pointPath.firstIndex(where: { $0 === pointObject }) {
                lineView.selectSegment(at: index)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let feet = Float(feetTextField.text ?? "0") ?? 0
        let inches = Float(inchesTextField.text ?? "0") ?? 0
        let val = feet + (inches / 12.0)
        
        if val > 0 {
            updateValue(val)
        } else {
            if val <= 0 {
                if let vc = lineView?.delegate as? UIViewController {
                    let alert = UIAlertController(title: "Alert", message: "We cannot enter 0 as a measurement", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    vc.present(alert, animated: true, completion: nil)
                }
            }
            if let originalVal = originalValueBeforeEditing {
                updateValue(originalVal)
            } else if let pointObject = pointObject {
                updateValue(pointObject.lineValue)
            }
        }
        originalValueBeforeEditing = nil
        lineView?.deselectSegment()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setSelected(_ isSelected: Bool?) {
        if let selected = isSelected {
            if selected {
                self.alpha = 1.0
                feetTextField.backgroundColor = .white
                feetTextField.textColor = .black
                feetTextField.layer.borderColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
                feetTextField.layer.borderWidth = 1.5
                inchesTextField.backgroundColor = .white
                inchesTextField.textColor = .black
                inchesTextField.layer.borderColor = UIColor(red: 0.75, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
                inchesTextField.layer.borderWidth = 1.5
                minusButton.alpha = 1.0
                plusButton.alpha = 1.0
            } else {
                self.alpha = 0.4
                feetTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
                feetTextField.textColor = .white
                feetTextField.layer.borderColor = UIColor.clear.cgColor
                feetTextField.layer.borderWidth = 0
                inchesTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
                inchesTextField.textColor = .white
                inchesTextField.layer.borderColor = UIColor.clear.cgColor
                inchesTextField.layer.borderWidth = 0
                minusButton.alpha = 0.6
                plusButton.alpha = 0.6
            }
        } else {
            self.alpha = 1.0
            feetTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
            feetTextField.textColor = .white
            feetTextField.layer.borderColor = UIColor.clear.cgColor
            feetTextField.layer.borderWidth = 0
            inchesTextField.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 20/255, alpha: 1.0)
            inchesTextField.textColor = .white
            inchesTextField.layer.borderColor = UIColor.clear.cgColor
            inchesTextField.layer.borderWidth = 0
            minusButton.alpha = 1.0
            plusButton.alpha = 1.0
        }
    }
}

protocol MoldingSelectionDelegate: AnyObject {
    func didSelectMolding(name: String, applyToAll: Bool, popup: MoldingSelectionPopupView)
}

class MoldingSelectionPopupView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: MoldingSelectionDelegate?
    weak var targetControl: LineSegmentControlView?
    var moldingList: [String] = []
    var selectedMolding: String?
    
    private let tableView = UITableView()
    private let applyToAllButton = UIButton(type: .custom)
    private let applyButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor(red: 42/255, green: 42/255, blue: 46/255, alpha: 0.95)
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(MoldingSelectionCell.self, forCellReuseIdentifier: "MoldingSelectionCell")
        
        applyToAllButton.setTitle("Apply to All", for: .normal)
        applyToAllButton.backgroundColor = UIColor(red: 0x58/255.0, green: 0x64/255.0, blue: 0x71/255.0, alpha: 1.0) // #586471
        applyToAllButton.layer.cornerRadius = 8
        applyToAllButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 15)
        applyToAllButton.addTarget(self, action: #selector(applyToAllTapped), for: .touchUpInside)
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.backgroundColor = UIColor(red: 0x29/255.0, green: 0x25/255.0, blue: 0x62/255.0, alpha: 1.0) // #292562
        applyButton.layer.cornerRadius = 8
        applyButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 15)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        
        self.addSubview(tableView)
        self.addSubview(applyToAllButton)
        self.addSubview(applyButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 12
        let buttonHeight: CGFloat = 40
        let buttonWidth = (self.bounds.width - (padding * 3)) / 2
        
        applyToAllButton.frame = CGRect(x: padding, y: self.bounds.height - buttonHeight - padding, width: buttonWidth, height: buttonHeight)
        applyButton.frame = CGRect(x: padding * 2 + buttonWidth, y: self.bounds.height - buttonHeight - padding, width: buttonWidth, height: buttonHeight)
        
        tableView.frame = CGRect(x: 0, y: padding, width: self.bounds.width, height: self.bounds.height - buttonHeight - padding * 3)
    }
    
    private func loadData() {
        moldingList = ["Not Applicable"]
        let molds = UIViewController().getMoldList()
        for mold in molds {
            if let name = mold.name {
                moldingList.append(name)
            }
        }
        tableView.reloadData()
    }
    
    @objc private func applyToAllTapped() {
        if let selected = selectedMolding {
            delegate?.didSelectMolding(name: selected, applyToAll: true, popup: self)
        }
    }
    
    @objc private func applyTapped() {
        if let selected = selectedMolding {
            delegate?.didSelectMolding(name: selected, applyToAll: false, popup: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moldingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoldingSelectionCell", for: indexPath) as! MoldingSelectionCell
        let name = moldingList[indexPath.row]
        cell.titleLabel.text = name
        cell.isMoldingSelected = (name == selectedMolding)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMolding = moldingList[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

class MoldingSelectionCell: UITableViewCell {
    let titleLabel = UILabel()
    let radioImageView = UIImageView()
    
    var isMoldingSelected: Bool = false {
        didSet {
            if isMoldingSelected {
                if #available(iOS 13.0, *) {
                    radioImageView.image = UIImage(systemName: "checkmark.circle.fill")
                }
                radioImageView.tintColor = .green
                self.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
            } else {
                if #available(iOS 13.0, *) {
                    radioImageView.image = UIImage(systemName: "circle")
                }
                radioImageView.tintColor = .gray
                self.backgroundColor = .clear
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(radioImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 16
        radioImageView.frame = CGRect(x: self.bounds.width - padding - 20, y: (self.bounds.height - 20) / 2, width: 20, height: 20)
        titleLabel.frame = CGRect(x: padding, y: 0, width: self.bounds.width - padding * 3 - 20, height: self.bounds.height)
    }
}

extension LineView: MoldingSelectionDelegate {
    func showMoldingPopup(for control: LineSegmentControlView) {
        // Remove existing if any
        dismissMoldingPopup()
        
        let dimmer = UIView()
        dimmer.tag = 999999
        dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dimmer)
        
        NSLayoutConstraint.activate([
            dimmer.topAnchor.constraint(equalTo: self.topAnchor),
            dimmer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimmer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dimmer.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        let popup = MoldingSelectionPopupView()
        popup.delegate = self
        popup.targetControl = control
        let currentTitle = control.moldingDropdownButton.title(for: .normal)
        if currentTitle != "Select Molding" {
            popup.selectedMolding = currentTitle
        }
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(popup)
        
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 300),
            popup.heightAnchor.constraint(equalToConstant: 350)
        ])
        
        self.bringSubviewToFront(popup)
        
        popup.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        popup.alpha = 0.0
        dimmer.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            popup.transform = .identity
            popup.alpha = 1.0
            dimmer.alpha = 1.0
        }, completion: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMoldingPopup))
        dimmer.addGestureRecognizer(tap)
    }
    
    @objc func dismissMoldingPopup() {
        for subview in self.subviews where subview is MoldingSelectionPopupView || subview.tag == 999999 {
            subview.removeFromSuperview()
        }
    }
    
    func didSelectMolding(name: String, applyToAll: Bool, popup: MoldingSelectionPopupView) {
        if applyToAll {
            for point in pointPath {
                if let control = point.label as? LineSegmentControlView {
                    control.moldingDropdownButton.setTitle(name, for: .normal)
                }
            }
        } else {
            popup.targetControl?.moldingDropdownButton.setTitle(name, for: .normal)
        }
        dismissMoldingPopup()
    }
}
