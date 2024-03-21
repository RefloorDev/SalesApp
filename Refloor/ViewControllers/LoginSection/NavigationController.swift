//
//  NavigationController.swift
//  Refloor
//
//  Created by sbek on 17/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bounds = self.navigationBar.bounds
        self.navigationBar.frame = CGRect(x: bounds.minX, y: bounds.minX, width:bounds.width, height: 120)
        // Do any additional setup after loading the view.
    }
    override func viewWillLayoutSubviews() {
        
        if #available(iOS 11.0, *) {
            for subview in self.navigationBar.subviews {
                let stringFromClass = NSStringFromClass(subview.classForCoder)
                if stringFromClass.contains("BarBackground") {
                    let bounds = self.navigationBar.bounds
                    subview.frame =  CGRect(x: bounds.minX, y: bounds.minX, width:bounds.width, height: 120)
                } else if stringFromClass.contains("BarContentView") {
                    
                    subview.frame.origin.y = 20
                    subview.frame.size.height = 52
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
