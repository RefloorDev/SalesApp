//
//  InstallerSuccessViewController.swift
//  Refloor
//
//  Created by Bincy C A on 22/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit

class InstallerSuccessViewController: UIViewController {
    
    @IBOutlet weak var installationDateLbl: UILabel!
    @IBOutlet weak var appointmentIdLbl: UILabel!
    @IBOutlet weak var customerNameLbl: UILabel!
    var appointmentdate:String = String()
    var customerName:String = String()
    var installationDate:String = String()
    
    static func initialization() -> InstallerSuccessViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "InstallerSuccessViewController") as? InstallerSuccessViewController

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        schedulerSuccessNavBar()
        let appointmentId = AppointmentData().appointment_id ?? 0
        appointmentIdLbl.text = String(appointmentId)
        customerNameLbl.text = customerName
        installationDateLbl.text = installationDate
        
    }
    

    @IBAction func goToAptBtn(_ sender: UIButton)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

}
