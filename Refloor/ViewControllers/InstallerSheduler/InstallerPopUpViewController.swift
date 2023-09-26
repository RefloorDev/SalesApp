//
//  InstallerPopUpViewController.swift
//  Refloor
//
//  Created by Bincy C A on 08/09/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit


protocol installerConfirmProtocol
{
    func installerConfirm()
}
protocol alreadySelectedProtocol
{
    func alreadySelected()
}

class InstallerPopUpViewController: UIViewController {
    
    static func initialization() -> InstallerPopUpViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "InstallerPopUpViewController") as? InstallerPopUpViewController
    }

    @IBOutlet weak var alreadySelectedDateView: UIView!
    @IBOutlet weak var installationView: UIView!
    
    var saleOrderId:Int = Int()
    var installationId:Int = Int()
    var installerConfirm: installerConfirmProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectDateBtn(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func installationConfirmBtn(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        installationView.isHidden = true
        installerConfirm?.installerConfirm()
        //alreadySelectedDateView.isHidden = false
    }
    @IBAction func installationCancelBtn(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    

}
