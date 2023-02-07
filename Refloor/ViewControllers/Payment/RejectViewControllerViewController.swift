//
//  RejectViewControllerViewController.swift
//  Refloor
//
//  Created by apple on 07/07/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
class RejectViewControllerViewController: UIViewController {
    static func initialization() -> RejectViewControllerViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "RejectViewControllerViewController") as? RejectViewControllerViewController
    }
    //   var downPayment:Double = 0
    @IBOutlet weak var paymentlabel: UILabel!
    var successString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setClearNavigationBar()
        paymentlabel.text = self.successString
        // Do any additional setup after loading the view.
    }
    @IBAction func thankYouButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
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


