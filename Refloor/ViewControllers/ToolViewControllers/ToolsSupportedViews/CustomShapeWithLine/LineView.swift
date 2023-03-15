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
}
class LineView: UIView {
    
    var shapeLayere:CAShapeLayer? = nil
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchmoved=false
            let position = touch.location(in: self)
            if(isClosed)
            {
                return
            }
            if(pointPath.count == 0)
            {
                startTouch = self.getLimitedPoint(at: position)
                starttouchBegan = self.getLimitedPoint(at: position)
                print("starttouchBegan",starttouchBegan)
            }
            else
            {
                startTouch = pointPath[pointPath.count - 1].point
                secondTouch = self.getLimitedPoint(at: position)
                starttouchBegan = pointPath[pointPath.count - 1].point
                stoptouchBegan = self.getLimitedPoint(at: position)
                print("starttouchBegan",starttouchBegan)
                print("stoptouchBegan",stoptouchBegan)
            }
            drowTempLine()
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isClosed)
        {
            return
        }
        touchmoved=true
        for touch in touches{
            let position = touch.location(in: self)
            secondTouch = self.getLimitedPoint(at: position)
            drowTempLine()
            
        }
        
    }
    //     func getCurrentContext()
    //     {
    //         let context = UIGraphicsGetCurrentContext()
    //        context.
    //     }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchmoved=false
        if(isClosed)
        {
            return
        }
        clearTempLine()
        if pointPath.count == 0
        {
            let label1 = UILabel()
            self.addSubview(label1)
            self.pointPath.append(customPointObjcet(label: label1, point: startTouch!, lineValue: 0))
            if(secondTouch != nil)
            {
                let label2 = UILabel()
                self.addSubview(label2)
                self.pointPath.append(customPointObjcet(label: label2, point: secondTouch!, lineValue: 0))
                self.drowShape(false)
            }
        }
        else
        {
            if(pointPath.count < 3)
            {
                
                let label = UILabel()
                self.addSubview(label)
                self.pointPath.append(customPointObjcet(label: label, point: secondTouch!, lineValue: 0))
                self.drowShape(false)
            }
            else
            {
                
                
                if getdistanceofpoint(self.pointPath[0 ].point, secondTouch!) < 30
                {
                    UIView.animate(withDuration: 0.3) {
                        self.drowShape(true)
                        self.isClosed = true
                        self.layoutIfNeeded()
                    }
                    
                }
                else
                {
                    let label = UILabel()
                    self.addSubview(label)
                    self.pointPath.append(customPointObjcet(label: label, point: secondTouch!, lineValue: 0))
                    UIView.animate(withDuration: 0.3) {
                        self.drowShape(false)
                        self.layoutIfNeeded()
                    }
                }
            }
            
        }
        
    }
    func roundTheValue(_ value:CGFloat) -> CGFloat
    {
        
        return CGFloat(Float(value * 100).rounded()/100)
    }
    
    
    func clearAllLine()
    {
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
            shapeLayere = nil
            self.startTouch = nil
            self.secondTouch = nil
        }
    }
    
    func removeLastLine()
    {
        if(pointPath.count > 1)
        {
            if isClosed
            {
                isClosed = false
                for point in pointPath
                {
                    point.subView.removeFromSuperview()
                }
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
            else if(point.isCorved)
            {
                let curvpoints = getCurvePoints(startPoint: pointPath[i - 1].point, endPoint: pointPath[i + 1].point, midilePoint: point.point)
                path.addQuadCurve(to: curvpoints[0], controlPoint: curvpoints[1])
                
                point.lineValue = labelConfigration(point.label, getCenterPoint(pointPath[i - 1].point,point.point), distance:getdistanceofpoint(pointPath[i - 1].point,point.point))
            }
            else if !(pointPath[i - 1].isCorved)
            {
                point.lineValue = labelConfigration(point.label, getCenterPoint(pointPath[i - 1].point,point.point), distance:getdistanceofpoint(pointPath[i - 1].point,point.point))
                
                path.addLine(to: point.point)
            }
            else
            {
                point.lineValue =  labelConfigration(point.label, getCenterPoint(pointPath[i - 1].point,point.point), distance:getdistanceofpoint(pointPath[i - 1].point,point.point))
            }
            i += 1
        }
        if(isClose)
        {
            let label = pointPath[0].label
            pointPath[0].lineValue =  labelConfigration(label, getCenterPoint(pointPath[pointPath.count - 1].point,pointPath[0].point), distance:getdistanceofpoint(pointPath[pointPath.count - 1].point,pointPath[0].point))
            self.addSubview(label)
            path.close()
            buzierpath = path
            return buzierpath
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
                if touchmoved==false{
                    _ = self.labelConfigration(self.tempLabel, self.getCenterPoint(secondTouch!, startTouch!), distance: self.getdistanceofpoint(secondTouch!, startTouch!))
                    tempbuzierpath.addLine(to: secondTouch!)
                }
                else
                {
                    _ =  self.labelConfigration(self.tempLabel, self.getCenterPoint(stoptouchBegan! ,starttouchBegan!), distance: self.getdistanceofpoint(secondTouch!, startTouch!))
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
            if touchmoved==false{
                _ =  self.labelConfigration(self.tempLabel, self.getCenterPoint(secondTouch!, startTouch!), distance: self.getdistanceofpoint(secondTouch!, startTouch!))
                
            }
            else
            {
                _ =  self.labelConfigration(self.tempLabel, startTouch!, distance: self.getdistanceofpoint(secondTouch!, startTouch!))
            }
            tempbuzierpath.removeAllPoints()
            tempbuzierpath.move(to: startTouch!)
            tempbuzierpath.addLine(to: secondTouch!)
            tempshapeLayere!.path = tempbuzierpath.cgPath
        }
    }
    func labelConfigration(_ label:UILabel,_ cgPoint:CGPoint,distance:CGFloat) -> Float
    {
        
        let value = Float((distance/minimumValue) * 100).rounded()/100
        let ftValue = Float(Int(value))
        let inchVal = (value - ftValue) * 12
        let roundeInch = Int(inchVal)
        if roundeInch == 0
        {
            label.text = "\(Int(value)) ft"
            label.frame = CGRect(origin: cgPoint, size: CGSize(width: 80, height: 30))
        }
        else
        {
            label.text = "\(Int(value)) ft \(roundeInch) in"
            label.frame = CGRect(origin: cgPoint, size: CGSize(width: 110, height: 30))
        }
        label.font = UIFont(name: "Avenir-Black", size: 17)
        label.backgroundColor = UIColor.white
        label.textColor = .black
        label.borderColor = .darkGray
        label.borderWidth = 1
        label.textAlignment = .center
        return value
        
    }
    
    
    
    func getLimitedPoint(at point:CGPoint) -> CGPoint
    {
        var xVal = point.x
        var yVal = point.y
        
        if(xVal > self.bounds.width)
        {
            xVal = self.bounds.width
        }
        else if(xVal < 40)
        {
            xVal = 40
        }
        
        if(yVal > self.bounds.height - 20)
        {
            yVal = self.bounds.height - 20
        }
        else if(yVal < 40)
        {
            yVal = 40
        }
        return CGPoint(x: xVal, y: yVal)
    }
    
    func moveShape()
    {
        shapeLayere!.path = getPath(self.isClosed).cgPath
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
        }
        else
        {
            
            
            shapeLayere!.path = getPath(isClose).cgPath
            if(isClose)
            {
                shapeLayere!.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
                if(isConfirmed)
                {
                    shapeLayere!.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
                    shapeLayere!.strokeColor = UIColor.white.cgColor
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
            }
        }
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
        for point in pointPath
        {
            point.subView.removeFromSuperview()
        }
    }
    func setPoints()
    {
        var i = 0
        for point in pointPath
        {
            
            point.subView.tag = i
            point.subView.cornerRadius = 15
            point.subView.borderColor = UIColor.white
            point.subView.borderWidth = 5
            point.subView.center = point.point
            point.subView.backgroundColor =  UIColor.white.withAlphaComponent(0.3)
            self.bringSubviewToFront(point.label)
            addGestureToPints(point.subView)
            self.addSubview(point.subView)
            i += 1
        }
        
    }
    
    
    
    
    func addGestureToPints(_ subView:UIView){
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        subView.addGestureRecognizer(gesture)
        subView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wasTaped(gestureRecognizer:)))
        tapGesture.numberOfTapsRequired = 2
        subView.addGestureRecognizer(tapGesture)
        // subView.delegate = self
    }
    @objc func wasTaped(gestureRecognizer: UITapGestureRecognizer) {
        if let subview = gestureRecognizer.view {
            if(pointPath.count - 1 > subview.tag && subview.tag > 0)
            {
                pointPath[subview.tag].isCorved = !pointPath[subview.tag].isCorved
                moveShape()
            }
        }
        
    }
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {
            let translation = gestureRecognizer.translation(in: self)
            //            print(gestureRecognizer.view!.center.y)
            //            if(gestureRecognizer.view!.center.y < 555) {
            
            let point = self.getLimitedPoint(at:  CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y))
            
            gestureRecognizer.view!.center = point
            pointPath[ gestureRecognizer.view!.tag].point = point
            //            }else {
            //                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: 554)
            //            }
            
            gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self)
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
        for x in stride(from: xMin, to: xMax, by: +10 as CGFloat) {
            for y in stride(from: yMin, to: yMax, by: +10 as CGFloat) {
                let point = CGPoint(x: x, y: y)
                if(buzierpath.cgPath.contains(point, using: .winding, transform:.identity))
                {
                    if(self.alphaFromPoint(point: point) != 0)
                    {
                        //let view = UIView(frame: CGRect(origin: point, size: CGSize(width: 1, height: 1)))
                        //  view.backgroundColor = .green
                        // self.addSubview(view)
                        area += 10
                    }
                }
            }
        }
        area = area * 10
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
        let subView = SubSqureView(frame: CGRect(x: xAsis, y: yAxis, width: width * (40), height: hight * (40)),isVertical:isVertical, color: objc.color)
                  
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
    
    
}
class customPointObjcet:NSObject
{
    var label:UILabel
    var point:CGPoint
    var lineValue:Float
    var isCorved:Bool
    var subView:UIView
    init(label:UILabel, point:CGPoint,lineValue:Float) {
        self.label = label
        self.point = point
        self.lineValue = lineValue
        self.isCorved = false
        self.subView = UIView(frame: CGRect(origin: point, size: CGSize(width: 30, height: 30)))
        self.subView.backgroundColor = .clear
    }
}
