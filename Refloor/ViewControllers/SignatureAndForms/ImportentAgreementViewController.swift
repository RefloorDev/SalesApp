//
//  ImportentAgreementViewController.swift
//  Refloor
//
//  Created by sbek on 25/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class ImportentAgreementViewController: UIViewController {
    static public func initialization() -> ImportentAgreementViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ImportentAgreementViewController") as? ImportentAgreementViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func okButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
