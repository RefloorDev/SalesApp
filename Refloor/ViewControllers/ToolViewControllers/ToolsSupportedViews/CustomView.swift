//
//  File.swift
//  RefloorEx
//
//  Created by sbek on 20/03/20.
//  Copyright © 2020 Arun Rajendrababu. All rights reserved.
//

import Foundation
import UIKit

class CustomView: UIView {
    var lastLocation = CGPoint(x: 0, y: 0)
    var custom_width: CGFloat = 0
    var custom_hight: CGFloat  = 0
    var customDelegate:CustomViewDelegate?
    var isMoved = true
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        self.gestureRecognizers = [panRecognizer]
        
        //randomize view color
        //        let blueValue = CGFloat.random(in: 0 ..< 1)
        //        let greenValue = CGFloat.random(in: 0 ..< 1)
        //        let redValue = CGFloat.random(in: 0 ..< 1)
        
        self.backgroundColor = .clear
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
    
    func custom_size_reload()
    {
        self.bounds.size.width = self.custom_width * minimumValue
        self.bounds.size.height = self.custom_hight * minimumValue
    }
    
}
