//
//  SubSqureView.swift
//  Refloor
//
//  Created by sbek on 23/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SubSqureView: UIView {
    
    var lastLocation = CGPoint(x: 0, y: 0)
    var custom_width: CGFloat = 0
    var custom_hight: CGFloat  = 0
    var object:OpeningCustomObject?
    var getSize:CGFloat{
        return self.isVertical ?  custom_hight : custom_width
    }
    var customDelegate:CustomViewDelegate?
    var isMoved = true
    var color:UIColor = .red
    let layerSharae:CAShapeLayer = CAShapeLayer()
    var isVertical = false
    init(frame: CGRect, isVertical:Bool,color:UIColor) {
        super.init(frame: frame)
        
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        self.gestureRecognizers = [panRecognizer]
        
        //randomize view color
        //        let blueValue = CGFloat.random(in: 0 ..< 1)
        //        let greenValue = CGFloat.random(in: 0 ..< 1)
        //        let redValue = CGFloat.random(in: 0 ..< 1)
        self.color = color
        self.isVertical = isVertical
        layerSharae.path = getPath().cgPath
        layerSharae.fillColor = UIColor.clear.cgColor
        layerSharae.strokeColor = color.cgColor
        layerSharae.lineWidth = 5.0
        self.layer.addSublayer(layerSharae)
        self.backgroundColor = .clear
    }
    func changeOriantation(_ isVertical:Bool)
    {
        if self.isVertical != isVertical
        {
            let temp = custom_width
            custom_width = custom_hight
            custom_hight = temp
            let hight = self.bounds.height
            let width = self.bounds.width
            self.bounds.size = CGSize(width: hight , height: width)
            self.isVertical = isVertical
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.layerSharae.path = self.getPath().cgPath
            })
            
        }
    }
    
    func getPath() -> UIBezierPath
    {
        let path = UIBezierPath()
        if(isVertical)
        {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: self.bounds.width, y: 0))
            path.move(to: CGPoint(x: 0, y: self.bounds.height))
            path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        }
        else
        {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: self.bounds.height))
            path.move(to: CGPoint(x: self.bounds.width, y: 0))
            path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        }
        return path
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        if !isMoved
        {
            return
        }
        let translation  = recognizer.translation(in: self.superview)
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Promote the touched view
        if !isMoved
        {
            return
        }
        self.superview?.bringSubviewToFront(self)
        customDelegate?.customViewDelegateResult(self.tag)
        // Remember original location
        lastLocation = self.center
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoved
        {
            return
        }
        for touch in touches
        {
            lastLocation = touch.location(in: self.superview)
        }
    }
    
    func change_color_of_path(_ color:UIColor)
    {
        layerSharae.strokeColor = color.cgColor
    }
    func custom_size_reload()
    {
        self.bounds.size.width = self.custom_width * 40
        self.bounds.size.height = self.custom_hight * 40
        self.layerSharae.path = getPath().cgPath
    }
    
}
