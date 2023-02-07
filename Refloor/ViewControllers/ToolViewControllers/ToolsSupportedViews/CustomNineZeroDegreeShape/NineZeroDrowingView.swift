//
//  NineZeroDrowingView.swift
//  Refloor
//
//  Created by sbek on 11/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
protocol NineZeroDrowingViewDelegate{
    func customeLabelDelegateResult(label:UILabel)
    func changesDoneinDrowingView(area:CGFloat,isClosed:Bool,labels:[UILabel])
}
class NineZeroDrowingView: UIView {
    var shapeLayere:CAShapeLayer? = nil
    var tempshapeLayere:CAShapeLayer? = nil
    var isClosed = false
    var isConfirmed = false
    var startTouch : XYpoint?
    var secondTouch : XYpoint?
    var delegate:NineZeroDrowingViewDelegate?
    var currentContext : CGContext? = nil
    var prevImage : UIImage?
    var buzierpath:UIBezierPath = UIBezierPath()
    var subSquareView:[SubSqureView] = []
    var tempbuzierpath:UIBezierPath = UIBezierPath()
    var pointPath:[CustomPointObjcetForNineZero] = []
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            if(isClosed)
            {
                return
            }
            if(pointPath.count == 0)
            {
                let point = CGPoint(x: roundTheValue(position.x), y: roundTheValue(position.y))
                startTouch = XYpoint(point: point, isXvalue: true, position: .down)
                
            }
            else
            {
                startTouch = XYpoint(point: pointPath[pointPath.count - 1].point, isXvalue: pointPath[pointPath.count - 1].isXvalue, position: pointPath[pointPath.count - 1].position)
                
                secondTouch = self.getPoint(startPoint: startTouch!.point, endPoint: position)
            }
            drowTempLine()
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isClosed)
        {
            return
        }
        for touch in touches{
            let position = touch.location(in: self)
            secondTouch = self.getPoint(startPoint: startTouch!.point, endPoint: position)
            drowTempLine()
            
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isClosed)
        {
            return
        }
        clearTempLine()
        if pointPath.count == 0
        {
            let label1 = UILabel()
            label1.isUserInteractionEnabled = true
            
            
            label1.tag = 0
            label1.addGestureRecognizer(getTapGetsureRecoganizer())
            self.addSubview(label1)
            self.pointPath.append(CustomPointObjcetForNineZero(id: self.pointPath.count, label: label1, point: startTouch!.point, isXvalue: startTouch!.isXvalue, position: startTouch!.position))
            if(secondTouch != nil)
            {
                let label2 = UILabel()
                label2.tag = 1
                label2.isUserInteractionEnabled = true
                label2.addGestureRecognizer(getTapGetsureRecoganizer())
                self.addSubview(label2)
                self.pointPath.append(CustomPointObjcetForNineZero(id: self.pointPath.count, label: label2, point: secondTouch!.point, isXvalue: secondTouch!.isXvalue, position: secondTouch!.position))
                self.drowShape(false)
            }
        }
        else
        {
            if(pointPath.count < 3)
            {
                
                let label = UILabel()
                label.tag =  self.pointPath.count
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(getTapGetsureRecoganizer())
                self.addSubview(label)
                self.pointPath.append(CustomPointObjcetForNineZero(id: self.pointPath.count, label: label, point: secondTouch!.point, isXvalue: secondTouch!.isXvalue, position: secondTouch!.position))
                self.drowShape(false)
            }
            else
            {
                
                
                if getdistanceofpoint(self.pointPath[0 ].point, secondTouch!.point) < 30
                {
                    let lastPoint = self.pointPath[self.pointPath.count - 1].point
                    if (self.pointPath[self.pointPath.count - 1].isXvalue)
                    {
                        
                        self.pointPath[self.pointPath.count - 1].point = CGPoint(x: self.pointPath[0].point.x, y: lastPoint.y)
                    }
                    else
                    {
                        self.pointPath[self.pointPath.count - 1].point = CGPoint(x: lastPoint.x, y: self.pointPath[0].point.y)
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.drowShape(true)
                        self.pointPath[0].label.tag = self.pointPath.count
                        self.isClosed = true
                        self.layoutIfNeeded()
                    }
                    
                }
                else
                {
                    let label = UILabel()
                    label.tag =  self.pointPath.count
                    label.isUserInteractionEnabled = true
                    label.addGestureRecognizer(getTapGetsureRecoganizer())
                    self.addSubview(label)
                    self.pointPath.append(CustomPointObjcetForNineZero(id: self.pointPath.count, label: label, point: secondTouch!.point, isXvalue: secondTouch!.isXvalue, position: secondTouch!.position))
                    UIView.animate(withDuration: 0.3) {
                        self.drowShape(false)
                        self.layoutIfNeeded()
                    }
                }
            }
            
        }
        
    }
    
    // Label Tap Gesture Functioning
    func getTapGetsureRecoganizer() -> UITapGestureRecognizer
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        tap.numberOfTapsRequired = 1
        return tap
    }
    @objc func tapFunction(sender:UITapGestureRecognizer){
        if !isClosed || !isConfirmed
        {
            return
        }
        guard let view = sender.view else {
            return
        }
        if let label = view as? UILabel
        {
            setresponderfor(label:label)
            delegate?.customeLabelDelegateResult(label: label)
        }
    }
    
    func setresponderfor(label:UILabel)
    {
        for responder in pointPath
        {
            if(responder.label == label)
            {
                responder.label.textColor = UIColor.red
                responder.label.borderColor = .red
                
            }
            else
            {
                responder.label.textColor = UIColor.white
                responder.label.borderColor = .white
            }
        }
    }
    
    
    func roundTheValue(_ value:CGFloat) -> CGFloat
    {
        return CGFloat(roundf(Float(value) * 100) / 100)
    }
    // get line position and changing value(x or y) and the 90 degree line maker
    func getPoint(startPoint:CGPoint, endPoint:CGPoint) -> XYpoint
    {
        let defX = (startPoint.x > endPoint.x) ? (startPoint.x - endPoint.x) : (endPoint.x - startPoint.x)
        let defY = (startPoint.y > endPoint.y) ? (startPoint.y - endPoint.y) : (endPoint.y - startPoint.y)
        if (defX > defY)
        {
            if(startPoint.x > endPoint.x)
            {
                
                
                return  XYpoint(point: CGPoint(x: startPoint.x - roundTheValue(defX), y: startPoint.y), isXvalue: true, position: .left)
            }
            else
            {
                return XYpoint(point: CGPoint(x: startPoint.x + roundTheValue(defX), y: startPoint.y), isXvalue: true, position: .right)
            }
        }
        else
        {
            if (startPoint.y > endPoint.y)
            {
                return XYpoint(point: CGPoint(x: startPoint.x, y: startPoint.y - roundTheValue(defY)), isXvalue: false, position: .up)
            }
            else
            {
                return XYpoint(point: CGPoint(x: startPoint.x, y: startPoint.y + roundTheValue(defY)), isXvalue: false, position: .down)
            }
        }
    }
    // get UIBazerOrginalPath
    func getPath (_ isClose:Bool) -> UIBezierPath
    {
        let path = UIBezierPath()
        var i = 0
        for point in pointPath
        {
            if(i == 0)
            {
                path.move(to: point.point)
            }
            else
            {
                labelConfigration(point.label, getCenterPoint(pointPath[i - 1].point,point.point), distance:getdistanceofpoint(pointPath[i - 1].point,point.point))
                
                path.addLine(to: point.point)
            }
            i += 1
        }
        if(isClose)
        {
            let xValue = getPoint(startPoint: pointPath[0].point, endPoint: pointPath[pointPath.count - 1].point)
            let label = pointPath[0].label
            pointPath[0].position = xValue.position
            label.tag =  self.pointPath.count
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(getTapGetsureRecoganizer())
            labelConfigration(label, getCenterPoint(pointPath[pointPath.count - 1].point,pointPath[0].point), distance:getdistanceofpoint(pointPath[pointPath.count - 1].point,pointPath[0].point))
            self.addSubview(label)
            for path in pointPath
            {
                self.bringSubviewToFront(path.label)
            }
            
            path.close()
            buzierpath = path
            return buzierpath
        }
        buzierpath = path
        return buzierpath
    }
    
    // Label Configruation
    func labelConfigration(_ label:UILabel,_ cgPoint:CGPoint,distance:CGFloat)
    {
        label.frame = CGRect(origin: cgPoint, size: CGSize(width: 60, height: 20))
        let value = roundf(Float(distance/minimumValue) * 100) / 100
        label.text = "\(value)"
        label.font = label.font.withSize(12)
        label.backgroundColor = .darkGray
        label.textColor = .white
        label.borderColor = .white
        label.borderWidth = 1
        label.textAlignment = .center
        
    }
    // Get Label Point or Get Center Point of side
    func getCenterPoint(_ to: CGPoint, _ from: CGPoint) -> CGPoint
    {
        
        let x = (to.x + from.x)/2
        let y = (to.y + from.y)/2
        return CGPoint(x: x , y: y)
    }
    // get width of a side
    func getdistanceofpoint(_ to: CGPoint, _ from: CGPoint) -> CGFloat {
        let xDist = to.x - from.x
        let yDist = to.y - from.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    
    
    // drowing temprary Red Line
    func drowTempLine()
    {
        if tempshapeLayere == nil
        {
            tempbuzierpath.removeAllPoints()
            tempbuzierpath.move(to: startTouch!.point)
            if(secondTouch != nil)
            {
                tempbuzierpath.addLine(to: secondTouch!.point)
            }
            tempshapeLayere = CAShapeLayer()
            tempshapeLayere!.path = tempbuzierpath.cgPath
            tempshapeLayere!.fillColor = UIColor.clear.cgColor
            tempshapeLayere!.strokeColor = UIColor.red.cgColor
            tempshapeLayere!.lineWidth = 3.0
            self.layer.addSublayer(tempshapeLayere!)
        }
        else
        {
            tempbuzierpath.removeAllPoints()
            tempbuzierpath.move(to: startTouch!.point)
            tempbuzierpath.addLine(to: secondTouch!.point)
            tempshapeLayere!.path = tempbuzierpath.cgPath
        }
    }
    func clearTempLine()
    {
        if tempshapeLayere != nil
        {
            tempshapeLayere?.removeFromSuperlayer()
            tempshapeLayere = nil
        }
    }
    // Remove Last Line or points
    
    func clearAllLine()
    {
        if shapeLayere != nil
        {
            shapeLayere?.removeFromSuperlayer()
            for point in pointPath
            {
                point.label.removeFromSuperview()
            }
            pointPath = []
            shapeLayere = nil
        }
    }
    
    func removeLastLine()
    {
        if(pointPath.count > 1)
        {
            if isClosed
            {
                isClosed = false
                pointPath[0].label.removeFromSuperview()
                drowShape(false)
            }
            else
            {
                pointPath[pointPath.count - 1].label.removeFromSuperview()
                pointPath.remove(at: pointPath.count - 1)
                drowShape(false)
            }
        }
    }
    
    // Drow Orginal Shape
    func drowShape(_ isClose:Bool)
    {
        if shapeLayere == nil
        {
            shapeLayere = CAShapeLayer()
            shapeLayere!.path = getPath(isClose).cgPath
            shapeLayere!.fillColor = UIColor.clear.cgColor
            shapeLayere!.strokeColor = UIColor.white.cgColor
            shapeLayere!.lineWidth = 3.0
            self.layer.addSublayer(shapeLayere!)
        }
        else
        {
            
            
            shapeLayere!.path = getPath(isClose).cgPath
            var area:CGFloat = 0
            var lables:[UILabel] = []
            
            for points in pointPath
            {
                lables.append(points.label)
                self.bringSubviewToFront(points.label)
            }
            if(isClose)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let size = self.getPath(isClose).cgPath.boundingBox
                    let width = size.width / 40
                    let hight = size.height / 40
                    //let area = self.GetExactArea()
                    self.delegate?.changesDoneinDrowingView(area: self.GetExactArea(), isClosed: (self.isConfirmed) ? isClose:false, labels: lables)
                    
                }
            }
            else
            {
                self.delegate?.changesDoneinDrowingView(area: area, isClosed: (isConfirmed) ? isClose:false, labels: lables)
            }
        }
    }
    
    // Check the points inside border Line of the shapelayer
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
    
    func GetExactArea()  -> CGFloat
    {
        let xMax = buzierpath.cgPath.boundingBox.maxX
        let yMax = buzierpath.cgPath.boundingBox.maxY
        let xMin = buzierpath.cgPath.boundingBox.minX
        let yMin = buzierpath.cgPath.boundingBox.minY
        var area:CGFloat = 0.0
        for x in stride(from: xMin, to: xMax, by: +1 as CGFloat) {
            for y in stride(from: yMin, to: yMax, by: +1 as CGFloat)
            {
                let point = CGPoint(x: x, y: y)
                if(self.alphaFromPoint(point: point) == 0)
                {
                    area += 1
                }
                
            }
        }
        area = area * 1
        let value = (area/(minimumValue * minimumValue) * 100).rounded()/100
        return value
    }
    
    
    
    //Get the area of the shape
    func getarea() -> CGFloat
    {
        let xMax = buzierpath.cgPath.boundingBox.maxX
        let yMax = buzierpath.cgPath.boundingBox.maxY
        let xMin = buzierpath.cgPath.boundingBox.minX
        let yMin = buzierpath.cgPath.boundingBox.minY
        var area:CGFloat = 0.0
        for x in stride(from: xMin, to: xMax, by: +10 as CGFloat) {
            for y in stride(from: yMin, to: yMax, by: +10 as CGFloat) {
                let point = CGPoint(x: x, y: y)
                if(buzierpath.cgPath.contains(point, using: .winding, transform:.identity))
                {
                    //                      if(self.alphaFromPoint(point: point) != 0)
                    //                      {
                    //let view = UIView(frame: CGRect(origin: point, size: CGSize(width: 1, height: 1)))
                    //  view.backgroundColor = .green
                    // self.addSubview(view)
                    area += 10
                    //                      }
                }
            }
        }
        area = area * 10
        let value = (area/(minimumValue * minimumValue) * 100).rounded()/100
        return value
    }
    
    // Edit The Closed Shape
    func editValue(_ tag:Int,value:CGFloat,oldValue:CGFloat)
    {
        var temp1Points:[CustomPointObjcetForNineZero] = []
        var temp2Points:[CustomPointObjcetForNineZero] = []
        var intVal = 0
        var numTag = tag
        if(tag == pointPath.count)
        {
            numTag -= 1
        }
        for point in pointPath
        {
            if (tag <= intVal)
            {
                temp1Points.append(point)
            }
            else
            {
                temp2Points.append(point)
            }
            intVal += 1
        }
        for points in temp2Points
        {
            temp1Points.append(points)
        }
        if(tag < temp1Points.count)
        {
            if(temp1Points[0].isXvalue)
            {
                var xValue = temp1Points[0].point.x
                if(temp1Points[0].position == .right)
                {
                    if(value > oldValue)
                    {
                        xValue = temp1Points[0].point.x + (value - oldValue)
                    }
                    else
                    {
                        xValue = temp1Points[0].point.x - (oldValue - value)
                    }
                }
                else
                {
                    if(value > oldValue)
                    {
                        xValue = temp1Points[0].point.x - (value - oldValue)
                    }
                    else
                    {
                        xValue = temp1Points[0].point.x + (oldValue - value)
                    }
                }
                temp1Points[0].point = CGPoint(x: xValue, y: temp1Points[0].point.y)
            }
            else
            {
                var yValue = temp1Points[0].point.y
                
                if(temp1Points[0].position == .down)
                {
                    if(value > oldValue)
                    {
                        yValue = temp1Points[0].point.y + (value - oldValue)
                    }
                    else
                    {
                        yValue = temp1Points[0].point.y - (oldValue - value)
                    }
                }
                else
                {
                    if(value > oldValue)
                    {
                        yValue = temp1Points[0].point.y - (value - oldValue)
                    }
                    else
                    {
                        yValue = temp1Points[0].point.y + (oldValue - value)
                    }
                }
                temp1Points[0].point = CGPoint(x: temp1Points[0].point.x, y: yValue)
            }
            
            for i in 1...(temp1Points.count - 1)
            {
                let startPoint = temp1Points[i - 1]
                let endPoint = temp1Points[i]
                
                if(endPoint.isXvalue)
                {
                    temp1Points[i].point = CGPoint(x: temp1Points[i].point.x, y: startPoint.point.y)
                }
                else
                {
                    temp1Points[i].point = CGPoint(x: startPoint.point.x, y: temp1Points[i].point.y)
                }
                
            }
        }
        else
        {
            temp1Points = pointPath
            let point = getPoint(startPoint: temp1Points[temp1Points.count - 1].point, endPoint: temp1Points[0].point)
            if(point.isXvalue)
            {
                var xValue = temp1Points[0].point.x
                if(point.position == .right)
                {
                    if(value > oldValue)
                    {
                        xValue = temp1Points[0].point.x + (value - oldValue)
                    }
                    else
                    {
                        xValue = temp1Points[0].point.x - (oldValue - value)
                    }
                }
                else
                {
                    if(value > oldValue)
                    {
                        xValue = temp1Points[0].point.x - (value - oldValue)
                    }
                    else
                    {
                        xValue = temp1Points[0].point.x + (oldValue - value)
                    }
                }
                temp1Points[0].point = CGPoint(x: xValue, y: temp1Points[0].point.y)
            }
            else
            {
                var yValue = temp1Points[0].point.y
                
                if(point.position == .down)
                {
                    if(value > oldValue)
                    {
                        yValue = temp1Points[0].point.y + (value - oldValue)
                    }
                    else
                    {
                        yValue = temp1Points[0].point.y - (oldValue - value)
                    }
                }
                else
                {
                    if(value > oldValue)
                    {
                        yValue = temp1Points[0].point.y - (value - oldValue)
                    }
                    else
                    {
                        yValue = temp1Points[0].point.y + (oldValue - value)
                    }
                }
                temp1Points[0].point = CGPoint(x: temp1Points[0].point.x, y: yValue)
            }
            
            for i in 1...(temp1Points.count - 1)
            {
                let startPoint = temp1Points[i - 1]
                let endPoint = temp1Points[i]
                
                if(endPoint.isXvalue)
                {
                    temp1Points[i].point = CGPoint(x: temp1Points[i].point.x, y: startPoint.point.y)
                }
                else
                {
                    temp1Points[i].point = CGPoint(x: startPoint.point.x, y: temp1Points[i].point.y)
                }
                
            }
            
        }
        for tem in temp1Points
        {
            var i = 0
            for point in pointPath
            {
                if(tem.id == point.id)
                {
                    i = point.id
                }
            }
            pointPath[i] = tem
        }
        drowShape(isClosed)
        
    }
    
    func add_Sub_Square_View(xAsis:CGFloat,yAxis:CGFloat,width:CGFloat,hight:CGFloat,delegate:CustomViewDelegate,isVertical:Bool)
    {
        let subView = SubSqureView(frame: CGRect(x: xAsis, y: yAxis, width: width * (minimumValue), height: hight * (minimumValue)),isVertical:isVertical, color: .red)
        
        subView.custom_width = width
        subView.custom_hight = hight
        subView.customDelegate = delegate
        subView.tag = self.subSquareView.count
        subView.isUserInteractionEnabled = true
        
        self.subSquareView.append(subView)
        self.addSubview(subView)
        UIView.animate(withDuration: 0.3) {
            subView.customDelegate?.customViewDelegateResult(subView.tag)
        }
    }
    
    
    func remove_Sub_Square_View(at Index:Int)
    {
        self.subSquareView[Index].removeFromSuperview()
    }
    func clear_All_Sub_Square_View()
    {
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
                subviewTemp.change_color_of_path(.red)
            }
            else
            {
                subviewTemp.change_color_of_path(.white)
            }
        }
    }
    
    
}
class XYpoint:NSObject
{
    var point:CGPoint
    var position:XYPostion
    var isXvalue = false
    init(point:CGPoint, isXvalue:Bool,position:XYPostion) {
        self.point = point
        self.isXvalue = isXvalue
        self.position = position
    }
}
class CustomPointObjcetForNineZero:NSObject
{
    var id:Int
    var label:UILabel
    var point:CGPoint
    var isXvalue = false
    var position:XYPostion
    init(id:Int,label:UILabel, point:CGPoint, isXvalue:Bool,position:XYPostion) {
        self.id = id
        self.label = label
        self.point = point
        self.position = position
        self.isXvalue = isXvalue
    }
}
enum XYPostion {
    case up
    case down
    case left
    case right
}
