//
//  SuccessFullPaymentViewController.swift
//  Refloor
//
//  Created by sbek on 03/07/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SuccessFullPaymentViewController: UIViewController {
    static func initialization() -> SuccessFullPaymentViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SuccessFullPaymentViewController") as? SuccessFullPaymentViewController
    }
    var downPayment:Double = 0
    @IBOutlet weak var paymentlabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setClearNavigationBar()
        paymentlabel.text = "Total Amount Paid : $\(downPayment.toRoundCommaString)"
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
