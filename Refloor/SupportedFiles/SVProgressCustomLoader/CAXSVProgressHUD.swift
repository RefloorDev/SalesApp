//
//  CAXSVProgressHUD.swift
//  Fuuf
//
//  Created by Arun P S on 24/05/17.
//  Copyright © 2017 Caxita. All rights reserved.
//

import UIKit
import SVProgressHUD.SVIndefiniteAnimatedView

class CAXSVProgressHUD: UIView {
   @IBOutlet var animatedView: SVIndefiniteAnimatedView?
   @IBOutlet var containerView: UIView?
   @IBOutlet var imgView: UIImageView?
    @IBOutlet var titleLbl: UILabel!
 //   let myView = NSBundle.mainBundle().loadNibNamed("MyView", owner: nil, options: nil)[0] as UIView

    
    static let sharedInstance = Bundle.main.loadNibNamed("CAXSVProgressHUD", owner: nil)?[0] as! CAXSVProgressHUD
    
    
    override init(frame:CGRect) {
        super.init(frame: frame)
       
    }
    
    override func updateConstraints() {
        
        self.frame = (self.window?.bounds)!
        animatedView?.radius = 34
        animatedView?.strokeThickness = 4
        animatedView?.strokeColor = UIColor.blue
        animatedView?.backgroundColor = UIColor.clear
        imgView?.layer.cornerRadius = 30
        containerView?.layer.cornerRadius = 37
       
        super.updateConstraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func show() {
        let hud: CAXSVProgressHUD? = self.sharedInstance
        
        self.showView(hud!)
    }
    class func dismiss() {
        self.removeIfPresented()
        //self.setShowPlaneSlider(false)
    }
    
    
    class func showView(_ view: CAXSVProgressHUD) {
        let mainWindow: UIWindow? = UIApplication.shared.windows.first
         mainWindow?.addSubview(view)
      
    }
    
    
    
    class func removeIfPresented() {
        let hud: CAXSVProgressHUD? = self.sharedInstance
        if ((hud?.superview) != nil) {
            hud?.removeFromSuperview()
        }
    }
}
