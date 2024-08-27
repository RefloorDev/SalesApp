//
//  AppointmentPaymentSummaryViewController.swift
//  Refloor
//
//  Created by Bincy C A on 12/08/24.
//  Copyright © 2024 oneteamus. All rights reserved.
//

import UIKit

class AppointmentPaymentSummaryViewController: UIViewController {
    
    static func initialization() -> AppointmentPaymentSummaryViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "AppointmentPaymentSummaryViewController") as? AppointmentPaymentSummaryViewController
    }
    
    
    var totalPrice:Double = Double()
    var finalPayment:Double = Double()
    var financeAmount:Double = Double()
    var downPayment:Double = 0

    @IBOutlet weak var downPaymentLbl: UILabel!
    @IBOutlet weak var financeAmountLbl: UILabel!
    @IBOutlet weak var finalPaymentLbl: UILabel!
    @IBOutlet weak var totalPriceLblSummary: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        downPaymentLbl.text = "$\(downPayment.toDoubleString)"
        finalPaymentLbl.text = "$\(finalPayment.toDoubleString)"
        financeAmountLbl.text = "$\(financeAmount.toDoubleString)"
        totalPriceLbl.text = "$\(totalPrice.toDoubleString)"
        totalPriceLblSummary.text = "$\(totalPrice.toDoubleString)"

       
    }
    

    @IBAction func okBtnClicked(_ sender: UIButton) 
    {
        
        self.dismiss(animated: true)
    }

}
