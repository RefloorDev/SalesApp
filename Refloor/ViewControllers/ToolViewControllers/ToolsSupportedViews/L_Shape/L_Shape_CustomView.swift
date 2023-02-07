//
//  L_Shape_CustomView.swift
//  RefloorEx
//
//  Created by sbek on 10/04/20.
//  Copyright © 2020 Arun Rajendrababu. All rights reserved.
//

import UIKit
var minimumValue:CGFloat = 40
protocol L_Shape_Label_Delegate {
    func L_Shape_Label_Tap_Result(label:UILabel,value:String,tag:Int)
}
protocol CustomViewDelegate {
    func customViewDelegateResult(_ tag:Int)
}
protocol L_Shape_CustomeView_Delegate {
    func areaChnaged(_ area:CGFloat)
}
class L_Shape_CustomView: CustomView {
    
    var l_shape_side_width_1:CGFloat = 5
    var l_shape_side_height_1:CGFloat = 10
    var l_shape_side_width_2:CGFloat = 10
    var l_shape_side_height_2:CGFloat = 5
    var l_shape_side_width_1_temp:CGFloat = 5  * minimumValue
    var l_shape_side_height_1_temp:CGFloat = 10 * minimumValue
    var l_shape_side_width_2_temp:CGFloat = 10 * minimumValue
    var l_shape_side_height_2_temp:CGFloat = 5  * minimumValue
    var l_1_width_label = UILabel()
    var l_1_hight_label = UILabel()
    var l_2_width_label = UILabel()
    var l_2_hight_label = UILabel()
    var l_1_2_width_label = UILabel()
    var l_1_2_hight_label = UILabel()
    var l_1_width_label_tag = 101
    var l_1_hight_label_tag = 102
    var l_2_width_label_tag = 103
    var l_2_hight_label_tag = 104
    var l_1_2_width_label_tag = 105
    var l_1_2_hight_label_tag = 106
    var center_Label_Color:UIColor = .gray
    var center_Label_Text = ""
    var center_Label = UILabel()
    var label_Delegate:L_Shape_Label_Delegate?
    var delegete:L_Shape_CustomeView_Delegate?
    var isFlip = false
    var selectedPostion = 0
    var responderLabel:[UILabel] = []
    var subSquareView:[SubSqureView] = []
    var layerSharae:CAShapeLayer!
    var linecolor:UIColor = .white
    
    func setSides(_ side1_width:CGFloat,_ side1_height:CGFloat,_ side2_width:CGFloat,_ side2_height:CGFloat,_ name:String,_ isFlip:Bool)
    {
        self.l_shape_side_width_1 = side1_width
        self.l_shape_side_height_1 = side1_height
        self.l_shape_side_width_2 = side2_width
        self.l_shape_side_height_2 = side2_height
        self.center_Label_Text = name
        self.isFlip = isFlip
        self.l_Shape_Configartion()
    }
    
    func set_side1_width(_ value:CGFloat)
    {
        self.l_shape_side_width_1 = value
        
        self.l_Shape_Configartion()
        
    }
    func set_side1_height(_ value:CGFloat)
    {
        self.l_shape_side_height_1 = value
        
        self.l_Shape_Configartion()
    }
    func set_side2_width(_ value:CGFloat)
    {
        self.l_shape_side_width_2 = value
        
        self.l_Shape_Configartion()
    }
    func set_side2_height(_ value:CGFloat)
    {
        self.l_shape_side_height_2 = value
        
        self.l_Shape_Configartion()
    }
    
    
    func setMinimumValue()
    {
        var value = l_shape_side_width_1
        if(l_shape_side_height_1 > value)
        {
            value = l_shape_side_height_1
        }
        if(l_shape_side_width_2 > value)
        {
            value = l_shape_side_width_2
        }
        if(l_shape_side_height_2 > value)
        {
            value = l_shape_side_height_2
        }
        if(value < 7)
        {
            minimumValue = 40
        }
        else if(value < 15)
        {
            minimumValue = 30
        }
        else if(value < 20)
        {
            minimumValue = 20
        }
        else if(value < 50)
        {
            minimumValue = 10
        }
        else if(value < 100)
        {
            minimumValue = 5
        }
        else if (value < 400)
        {
            minimumValue = 1
        }
        else if(value < 1000)
        {
            minimumValue = 0.5
        }
        else if(value < 2000)
        {
            minimumValue = 0.4
        }
        
        
        
    }
    func l_Shape_Configartion()
    {
        setMinimumValue()
        self.l_shape_side_width_1_temp = self.l_shape_side_width_1 * minimumValue
        self.l_shape_side_height_1_temp = self.l_shape_side_height_1 * minimumValue
        self.l_shape_side_width_2_temp = self.l_shape_side_width_2 * minimumValue
        self.l_shape_side_height_2_temp = self.l_shape_side_height_2 * minimumValue
        var object = getposition1path()
        if isFlip
        {
            object = getposition2path()
        }
        let  path = object.path
        setLabelFromTempLabel(object.label_1_hight_size, l_1_hight_label)
        setLabelFromTempLabel(object.label_2_hight_size, l_2_hight_label)
        setLabelFromTempLabel(object.label_1_width_size, l_1_width_label)
        setLabelFromTempLabel(object.label_2_width_size, l_2_width_label)
        setLabelFromTempLabel(object.label_1_label2_hight_size, l_1_2_hight_label)
        setLabelFromTempLabel(object.label_1_label2_width_size, l_1_2_width_label)
        setCenterLabel(path!.cgPath)
        self.frame = CGRect(x: 40, y: 40, width: (path!.bounds.width + (minimumValue * 2)), height: (path!.bounds.height + (minimumValue * 2)))
        if(layerSharae == nil)
        {
            layerSharae = CAShapeLayer()
            layerSharae.path = path!.cgPath
            layerSharae.fillColor = UIColor.clear.cgColor
            layerSharae.strokeColor = UIColor.white.cgColor
            layerSharae.lineWidth = 3.0
            self.layer.addSublayer(layerSharae)
            let tap_1_hight = UITapGestureRecognizer(target: self, action: #selector(self.l_1_hight_label_tap_action))
            tap_1_hight.numberOfTapsRequired = 1
            let tap_2_hight = UITapGestureRecognizer(target: self, action: #selector(self.l_2_hight_label_tap_action))
            tap_2_hight.numberOfTapsRequired = 1
            let tap_1_width = UITapGestureRecognizer(target: self, action: #selector(self.l_1_width_label_tap_action))
            tap_1_width.numberOfTapsRequired = 1
            let tap_2_width = UITapGestureRecognizer(target: self, action: #selector(self.l_2_width_label_tap_action))
            tap_2_width.numberOfTapsRequired = 1
            let tap_2_1_width = UITapGestureRecognizer(target: self, action: #selector(self.l_1_2_width_label_tap_action))
            tap_2_1_width.numberOfTapsRequired = 1
            let tap_2_1_hight = UITapGestureRecognizer(target: self, action: #selector(self.l_1_2_hight_label_tap_action))
            tap_2_1_hight.numberOfTapsRequired = 1
            l_1_hight_label.addGestureRecognizer(tap_1_hight)
            l_1_hight_label.tag = 2
            responderLabel.append(l_1_hight_label)
            l_1_hight_label.isUserInteractionEnabled = true
            l_2_hight_label.addGestureRecognizer(tap_2_hight)
            l_2_hight_label.tag = 4
            responderLabel.append(l_2_hight_label)
            l_2_hight_label.isUserInteractionEnabled = true
            l_1_width_label.addGestureRecognizer(tap_1_width)
            l_1_width_label.tag = 1
            responderLabel.append(l_1_width_label)
            l_1_width_label.isUserInteractionEnabled = true
            l_2_width_label.addGestureRecognizer(tap_2_width)
            l_2_width_label.tag = 3
            responderLabel.append(l_2_width_label)
            l_2_width_label.isUserInteractionEnabled = true
            l_1_2_hight_label.addGestureRecognizer(tap_2_1_hight)
            l_1_2_hight_label.tag = 6
            responderLabel.append(l_1_2_hight_label)
            l_1_2_hight_label.isUserInteractionEnabled = true
            l_1_2_width_label.addGestureRecognizer(tap_2_1_width)
            l_1_2_width_label.tag = 5
            responderLabel.append(l_1_2_width_label)
            l_1_2_width_label.isUserInteractionEnabled = true
            self.addSubview(l_1_hight_label)
            self.addSubview(l_2_hight_label)
            self.addSubview(l_1_width_label)
            self.addSubview(l_2_width_label)
            self.addSubview(l_1_2_hight_label)
            self.addSubview(l_1_2_width_label)
            self.addSubview(center_Label)
        }
        else
        {
            layerSharae.path = path!.cgPath
        }
        delegete?.areaChnaged(getArea())
        
    }
    
    func setresponderfor(tag:Int)
    {
        for responder in responderLabel
        {
            if(responder.tag == tag)
            {
                responder.textColor = UIColor.red
            }
            else
            {
                responder.textColor = UIColor.white
            }
        }
    }
    
    func setLabelFromTempLabel(_ fromLabel:UILabel,_ toLabel:UILabel)
    {
        toLabel.text = fromLabel.text
        toLabel.textColor = linecolor
        toLabel.frame = fromLabel.frame
        toLabel.font = fromLabel.font
        toLabel.lineBreakMode = fromLabel.lineBreakMode
        toLabel.numberOfLines = fromLabel.numberOfLines
    }
    @objc func l_1_hight_label_tap_action()
    {
        label_Delegate?.L_Shape_Label_Tap_Result(label: self.l_1_hight_label, value:  self.l_1_hight_label.text ?? "", tag: l_1_hight_label_tag)
        setresponderfor(tag: l_1_hight_label.tag)
    }
    @objc func l_2_hight_label_tap_action()
    {
        label_Delegate?.L_Shape_Label_Tap_Result(label: self.l_2_hight_label, value:  self.l_2_hight_label.text ?? "", tag: l_2_hight_label_tag)
        setresponderfor(tag: l_2_hight_label.tag)
    }
    @objc func l_1_width_label_tap_action()
    {
        label_Delegate?.L_Shape_Label_Tap_Result(label: self.l_1_width_label, value:  self.l_1_width_label.text ?? "", tag: l_1_width_label_tag)
        setresponderfor(tag: l_1_width_label.tag)
    }
    @objc func l_2_width_label_tap_action()
    {
        label_Delegate?.L_Shape_Label_Tap_Result(label: self.l_2_width_label, value:  self.l_2_width_label.text ?? "", tag: l_2_width_label_tag)
        setresponderfor(tag: l_2_width_label.tag)
    }
    @objc func l_1_2_width_label_tap_action()
    {
        label_Delegate?.L_Shape_Label_Tap_Result(label: self.l_1_2_width_label, value:  self.l_1_2_width_label.text ?? "", tag: l_1_2_width_label_tag)
        setresponderfor(tag: l_1_2_width_label.tag)
    }
    @objc func l_1_2_hight_label_tap_action()
    {
        label_Delegate?.L_Shape_Label_Tap_Result(label: self.l_1_2_hight_label, value:  self.l_1_2_hight_label.text ?? "", tag: l_1_2_hight_label_tag)
        setresponderfor(tag: l_1_2_hight_label.tag)
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
        
        UIView.animate(withDuration: 0.3) {
            self.addSubview(subView)
            subView.customDelegate?.customViewDelegateResult(subView.tag)
        }
    }
    
    
    //   |
    //    |
    //    |
    //    |_____
    
    func getposition1path() -> pathandlabelvaluesOBj
    {
        let path = UIBezierPath()
        var label_1_width_label = UILabel()
        var label_1_hight_label = UILabel()
        var label_2_width_label = UILabel()
        var label_2_hight_label = UILabel()
        var label_1_label2_width_label = UILabel()
        var label_1_label2_hight_label = UILabel()
        let startXaxis = minimumValue
        let startYaxis = minimumValue
        var xAxis = startXaxis
        var yAxis = startYaxis
        
        path.move(to: CGPoint(x: xAxis, y: yAxis))
        
        // line
        //get center point
        let mid_point_for_label_1_width_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis + l_shape_side_width_1_temp, y: yAxis))
        //get size of label
        let size_of_label_1_width = getLabelSize(l_shape_side_width_1_temp, false)
        //get point of lable
        let point_for_label_1_width_size = CGPoint(x: (mid_point_for_label_1_width_size.x - (size_of_label_1_width.width/2)), y: mid_point_for_label_1_width_size.y + 10)
        //set label
        label_1_width_label = getLabel(l_shape_side_width_1_temp, point_for_label_1_width_size, true, labelValue: l_shape_side_width_1)
        // set Axis for adding line
        xAxis = xAxis + l_shape_side_width_1_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        
        // line
        //get center point
        let mid_point_for_label_1_height_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis, y: yAxis + l_shape_side_height_1_temp))
        //get size of label
        let size_of_label_1_hight = getLabelSize(l_shape_side_height_1_temp, false)
        //get point of lable
        let point_for_label_1_height_size = CGPoint(x: mid_point_for_label_1_height_size.x - (size_of_label_1_hight.width + 10) , y: (mid_point_for_label_1_height_size.y - (size_of_label_1_hight.height / 2)))
        //set label
        label_1_hight_label = getLabel(l_shape_side_height_1_temp, point_for_label_1_height_size, false, labelValue: l_shape_side_height_1)
        // set Axis for adding line
        yAxis = yAxis + l_shape_side_height_1_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        // line
        //get center point
        let mid_point_for_label_2_width_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis + l_shape_side_width_2_temp, y: yAxis))
        //get size of label
        let size_of_label_2_width = getLabelSize(l_shape_side_width_2_temp, true)
        //get point of lable
        let point_for_label_2_width_size = CGPoint(x: (mid_point_for_label_2_width_size.x - (size_of_label_2_width.width/2)), y: mid_point_for_label_2_width_size.y + 10)
        
        //get point of lable
        label_2_width_label = getLabel(l_shape_side_width_2_temp, point_for_label_2_width_size, true, labelValue: l_shape_side_width_2)
        // set Axis for adding line
        xAxis = xAxis + l_shape_side_width_2_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        // line
        //get center point
        let mid_point_for_label_2_height_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis, y: yAxis + l_shape_side_height_2_temp))
        //get size of label
        let size_of_label_2_hight = getLabelSize(l_shape_side_height_2_temp, false)
        //get point of lable
        let point_for_label_2_height_size = CGPoint(x: mid_point_for_label_2_height_size.x - (size_of_label_2_hight.width + 10) , y: (mid_point_for_label_2_height_size.y - (size_of_label_2_hight.height / 2)))
        //set label
        label_2_hight_label = getLabel(l_shape_side_height_2_temp, point_for_label_2_height_size, false, labelValue: l_shape_side_height_2)
        // set Axis for adding line
        yAxis = yAxis + l_shape_side_height_2_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        // line
        
        // get line width
        let width_1_2_lines = l_shape_side_width_1_temp + l_shape_side_width_2_temp
        //get center point
        let mid_point_for_label_2_1_width_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis - width_1_2_lines , y: yAxis))
        //get size of label
        let size_of_label_2_1_width = getLabelSize(width_1_2_lines, true)
        //get point of lable
        let point_for_label_2_1_width_size = CGPoint(x: (mid_point_for_label_2_1_width_size.x - (size_of_label_2_1_width.width/2)), y: (mid_point_for_label_2_1_width_size.y - (size_of_label_2_1_width.height + 10)))
        
        //set Label
        label_1_label2_width_label = getLabel(width_1_2_lines, point_for_label_2_1_width_size, true, labelValue: (l_shape_side_width_2 + l_shape_side_width_1))
        // set Axis for adding line
        xAxis = xAxis - width_1_2_lines
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        
        // line
        // get line hight
        let hight_1_2_lines = l_shape_side_height_1_temp + l_shape_side_height_2_temp
        //get center point
        let mid_point_for_label_2_1_height_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: startXaxis, y: startYaxis))
        //get size of label
        let size_of_label_2_1_hight = getLabelSize(hight_1_2_lines, false)
        //get point of lable
        let point_for_label_2_1_height_size = CGPoint(x: mid_point_for_label_2_1_height_size.x + 10 , y: (mid_point_for_label_2_1_height_size.y - (size_of_label_2_1_hight.height / 2)))
        //set label
        label_1_label2_hight_label = getLabel(hight_1_2_lines, point_for_label_2_1_height_size, false, labelValue: l_shape_side_height_1 + l_shape_side_height_2)
        
        // addine
        path.close()
        
        return pathandlabelvaluesOBj(path, label_1_width_label, label_1_hight_label, label_2_width_label, label_2_hight_label, label_1_label2_width_label, label_1_label2_hight_label)
    }
    
    
    //    |
    //     |
    //     |
    // ____|
    
    func getposition2path() -> pathandlabelvaluesOBj
    {
        let path = UIBezierPath()
        var label_1_width_label = UILabel()
        var label_1_hight_label = UILabel()
        var label_2_width_label = UILabel()
        var label_2_hight_label = UILabel()
        var label_1_label2_width_label = UILabel()
        var label_1_label2_hight_label = UILabel()
        let startXaxis = (minimumValue + l_shape_side_width_2_temp + l_shape_side_width_1_temp)
        let startYaxis = minimumValue
        var xAxis = startXaxis
        var yAxis = startYaxis
        
        path.move(to: CGPoint(x: xAxis, y: yAxis))
        
        // line
        //get center point
        let mid_point_for_label_1_width_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis - l_shape_side_width_1_temp, y: yAxis))
        //get size of label
        let size_of_label_1_width = getLabelSize(l_shape_side_width_1_temp, false)
        //get point of lable
        let point_for_label_1_width_size = CGPoint(x: (mid_point_for_label_1_width_size.x - (size_of_label_1_width.width/2)), y: mid_point_for_label_1_width_size.y + 10)
        //set label
        label_1_width_label = getLabel(l_shape_side_width_1_temp, point_for_label_1_width_size, true, labelValue: l_shape_side_width_1)
        // set Axis for adding line
        xAxis = xAxis - l_shape_side_width_1_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        
        // line
        //get center point
        let mid_point_for_label_1_height_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis, y: yAxis + l_shape_side_height_1_temp))
        //get size of label
        let size_of_label_1_hight = getLabelSize(l_shape_side_height_1_temp, false)
        //get point of lable
        let point_for_label_1_height_size = CGPoint(x: mid_point_for_label_1_height_size.x  + 10 , y: (mid_point_for_label_1_height_size.y - (size_of_label_1_hight.height / 2)))
        //set label
        label_1_hight_label = getLabel(l_shape_side_height_1_temp, point_for_label_1_height_size, false, labelValue: l_shape_side_height_1)
        // set Axis for adding line
        yAxis = yAxis + l_shape_side_height_1_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        // line
        //get center point
        let mid_point_for_label_2_width_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis - l_shape_side_width_2_temp, y: yAxis))
        //get size of label
        let size_of_label_2_width = getLabelSize(l_shape_side_width_2_temp, true)
        //get point of lable
        let point_for_label_2_width_size = CGPoint(x: (mid_point_for_label_2_width_size.x - (size_of_label_2_width.width/2)), y: mid_point_for_label_2_width_size.y + 10)
        
        //get point of lable
        label_2_width_label = getLabel(l_shape_side_width_2_temp, point_for_label_2_width_size, true, labelValue: l_shape_side_width_2)
        // set Axis for adding line
        xAxis = xAxis - l_shape_side_width_2_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        // line
        //get center point
        let mid_point_for_label_2_height_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis, y: yAxis + l_shape_side_height_2_temp))
        //get size of label
        let size_of_label_2_hight = getLabelSize(l_shape_side_height_2_temp, false)
        //get point of lable
        let point_for_label_2_height_size = CGPoint(x: mid_point_for_label_2_height_size.x + 10 , y: (mid_point_for_label_2_height_size.y - (size_of_label_2_hight.height / 2)))
        //set label
        label_2_hight_label = getLabel(l_shape_side_height_2_temp, point_for_label_2_height_size, false, labelValue: l_shape_side_height_2)
        // set Axis for adding line
        yAxis = yAxis + l_shape_side_height_2_temp
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        // line
        
        // get line width
        let width_1_2_lines = l_shape_side_width_1_temp + l_shape_side_width_2_temp
        //get center point
        let mid_point_for_label_2_1_width_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: xAxis + width_1_2_lines , y: yAxis))
        //get size of label
        let size_of_label_2_1_width = getLabelSize(width_1_2_lines, true)
        //get point of lable
        let point_for_label_2_1_width_size = CGPoint(x: (mid_point_for_label_2_1_width_size.x - (size_of_label_2_1_width.width/2)), y: (mid_point_for_label_2_1_width_size.y - (size_of_label_2_1_width.height + 10)))
        
        //set Label
        label_1_label2_width_label = getLabel(width_1_2_lines, point_for_label_2_1_width_size, true, labelValue: (l_shape_side_width_2 + l_shape_side_width_1))
        // set Axis for adding line
        xAxis = xAxis + width_1_2_lines
        // addine
        path.addLine(to: CGPoint(x: xAxis, y: yAxis))
        
        
        
        // line
        // get line hight
        let hight_1_2_lines = l_shape_side_height_1_temp + l_shape_side_height_2_temp
        //get center point
        let mid_point_for_label_2_1_height_size = getCenterPoint(CGPoint(x: xAxis, y: yAxis), CGPoint(x: startXaxis, y: startYaxis))
        //get size of label
        let size_of_label_2_1_hight = getLabelSize(hight_1_2_lines, false)
        //get point of lable
        let point_for_label_2_1_height_size = CGPoint(x: mid_point_for_label_2_1_height_size.x - (size_of_label_2_1_hight.width + 10) , y: (mid_point_for_label_2_1_height_size.y - (size_of_label_2_1_hight.height / 2)))
        //set label
        label_1_label2_hight_label = getLabel(hight_1_2_lines, point_for_label_2_1_height_size, false, labelValue: l_shape_side_height_1 + l_shape_side_height_2)
        
        // addine
        path.close()
        
        return pathandlabelvaluesOBj(path, label_1_width_label, label_1_hight_label, label_2_width_label, label_2_hight_label, label_1_label2_width_label, label_1_label2_hight_label)
    }
    func setCenterLabel(_ path:CGPath)
    {
        let value = path.boundingBox.width
        center_Label.text = center_Label_Text
        center_Label.textColor = center_Label_Color
        if(value < 51)
        {
            let size = CGSize(width: 10, height: 5)
            let point = CGPoint(x: (path.boundingBox.width/2) - (size.width/2), y: (path.boundingBox.height/2) - (size.height/2))
            center_Label.frame = CGRect(origin: point, size: size)
            center_Label.font = center_Label.font.withSize(6)
        }
        else if(value < 101)
        {
            let size = CGSize(width: 20, height: 10)
            let point = CGPoint(x: (path.boundingBox.width/2) - (size.width/2), y: (path.boundingBox.height/2) - (size.height/2))
            center_Label.frame = CGRect(origin: point, size: size)
            center_Label.font = center_Label.font.withSize(8)
        }
        else if(value < 151)
        {
            let size = CGSize(width: 30, height: 10)
            let point = CGPoint(x: (path.boundingBox.width/2) - (size.width/2), y: (path.boundingBox.height/2) - (size.height/2))
            center_Label.frame = CGRect(origin: point, size: size)
            center_Label.font = center_Label.font.withSize(10)
        }
        else if(value < 200)
        {
            let size = CGSize(width: 40, height: 15)
            let point = CGPoint(x: (path.boundingBox.width/2) - (size.width/2), y: (path.boundingBox.height/2) - (size.height/2))
            center_Label.frame = CGRect(origin: point, size: size)
            center_Label.font = center_Label.font.withSize(12)
        }
        else if(value < 250)
        {
            let size = CGSize(width: 60, height: 20)
            let point = CGPoint(x: (path.boundingBox.width/2) - (size.width/2), y: (path.boundingBox.height/2) - (size.height/2))
            center_Label.frame = CGRect(origin: point, size: size)
            center_Label.font = center_Label.font.withSize(14)
        }
        else if(value < 300)
        {
            let size = CGSize(width: 80, height: 30)
            let point = CGPoint(x: (path.boundingBox.width/2) - (size.width/2), y: (path.boundingBox.height/2) - (size.height/2))
            center_Label.frame = CGRect(origin: point, size: size)
            center_Label.font = center_Label.font.withSize(15)
        }
        else
        {
            let size = CGSize(width: 150, height: 40)
            let point = CGPoint(x: (path.boundingBox.width/2) - (size.width/2), y: (path.boundingBox.height/2) - (size.height/2))
            center_Label.frame = CGRect(origin: point, size: size)
            center_Label.font = center_Label.font.withSize(18)
        }
    }
    func getLabelSize(_ value:CGFloat,_ isWidth:Bool) -> CGSize
    {
        if(value < 11)
        {
            var label =  CGSize(width: value, height: value/2)
            
            if !isWidth
            {
                label = CGSize(width: value, height: value)
                
            }
            return label
            
        }
        else if(value < 21)
        {
            var label = CGSize(width: 10, height: 5)
            
            if !isWidth
            {
                label = CGSize(width: 10, height: 10)
            }
            return label
            
        }
        else if(value < 51)
        {
            var label = CGSize(width: 20, height: 10)
            
            if !isWidth
            {
                label =  CGSize(width: 12, height: 20)
            }
            return label
        }
        else if(value < 101)
        {
            var label = CGSize(width: 40, height: 15)
            
            if !isWidth
            {
                label =  CGSize(width: 30, height: 40)
                
            }
            return label
        }
        else if(value < 151)
        {
            var label = CGSize(width: 80, height: 30)
            
            if !isWidth
            {
                label =  CGSize(width: 50, height: 80)
            }
            
            return label
            
        }
        else
        {
            var label = CGSize(width: 100, height: 40)
            
            if !isWidth
            {
                label =  CGSize(width: 60, height: 100)
                
            }
            return label
        }
    }
    func getLabel(_ value:CGFloat,_ point:CGPoint, _ isWidth:Bool,labelValue:CGFloat) -> UILabel
    {
        if(value < 11)
        {
            let label = UILabel(frame: CGRect(origin: point, size: CGSize(width: value, height: value/2)))
            if isWidth
            {
                label.text = "⇠ \(labelValue) ft ⇢"
            }
            else
            {
                label.frame.size = CGSize(width: value, height: value)
                label.text = "⇡\n \(labelValue) ft \n⇣"
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
            }
            label.font = label.font.withSize(value/2)
            return label
            
        }
        else if(value < 21)
        {
            let label = UILabel(frame: CGRect(origin: point, size: CGSize(width: 10, height: 5)))
            if isWidth
            {
                label.text = "⇠ \(labelValue) ft ⇢"
            }
            else
            {
                label.frame.size = CGSize(width: 10, height: 10)
                label.text = "⇡\n \(labelValue) ft \n⇣"
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
            }
            label.font = label.font.withSize(4)
            return label
            
        }
        else if(value < 51)
        {
            let label = UILabel(frame: CGRect(origin: point, size: CGSize(width: 20, height: 10)))
            if isWidth
            {
                label.text = "⇠ \(labelValue) ft ⇢"
            }
            else
            {
                label.frame.size =  CGSize(width: 12, height: 20)
                label.text = "⇡\n \(labelValue) ft \n⇣"
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
            }
            label.font = label.font.withSize(8)
            return label
        }
        else if(value < 101)
        {
            let label = UILabel(frame: CGRect(origin: point, size: CGSize(width: 40, height: 15)))
            if isWidth
            {
                label.text = "⇠ \(labelValue) ft ⇢"
            }
            else
            {
                label.frame.size =  CGSize(width: 30, height: 40)
                label.text = "⇡\n \(labelValue) ft \n⇣"
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
            }
            label.font = label.font.withSize(12)
            return label
        }
        else if(value < 151)
        {
            let label = UILabel(frame: CGRect(origin: point, size: CGSize(width: 80, height: 30)))
            if isWidth
            {
                label.text = "⇠ \(labelValue) ft ⇢"
            }
            else
            {
                label.frame.size =  CGSize(width: 50, height: 80)
                label.text = "⇡\n \(labelValue) ft \n⇣"
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
            }
            
            label.font = label.font.withSize(15)
            return label
            
        }
        else
        {
            let label = UILabel(frame: CGRect(origin: point, size: CGSize(width: 100, height: 40)))
            if isWidth
            {
                label.text = "⇠ \(labelValue) ft ⇢"
            }
            else
            {
                label.frame.size =  CGSize(width: 60, height: 100)
                label.text = "⇡\n \(labelValue) ft \n⇣"
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
            }
            label.font = label.font.withSize(17)
            return label
        }
    }
    func getCenterPoint(_ to: CGPoint, _ from: CGPoint) -> CGPoint
    {
        
        let x = (to.x + from.x)/2
        let y = (to.y + from.y)/2
        return CGPoint(x: x , y: y)
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
    func getArea() -> CGFloat
    {
        let area1 = l_shape_side_width_1 * l_shape_side_height_1
        let area2 = l_shape_side_width_2 * l_shape_side_height_2
        let area3 = l_shape_side_width_1 * l_shape_side_height_2
        return area1 + area2 + area3
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
    
    
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
class pathandlabelvaluesOBj:NSObject
{
    var path:UIBezierPath!
    var label_1_width_size:UILabel!
    var label_1_hight_size:UILabel!
    var label_2_width_size:UILabel!
    var label_2_hight_size:UILabel!
    var label_1_label2_width_size:UILabel!
    var label_1_label2_hight_size:UILabel!
    override init() {
        super.init()
    }
    
    init(_ path:UIBezierPath,_ label_1_width_size:UILabel,_ label_1_hight_size:UILabel,_ label_2_width_size:UILabel,_ label_2_hight_size:UILabel,_ label_1_label2_width_size:UILabel,_ label_1_label2_hight_size:UILabel) {
        self.path = path
        self.label_1_width_size = label_1_width_size
        self.label_1_hight_size = label_1_hight_size
        self.label_2_width_size = label_2_width_size
        self.label_2_hight_size = label_2_hight_size
        self.label_1_label2_width_size = label_1_label2_width_size
        self.label_1_label2_hight_size = label_1_label2_hight_size
    }
    
    
}
