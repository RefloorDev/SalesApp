//
//  SpalashScreenNewViewController.swift
//  Refloor
//
//  Created by sbek on 16/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SpalashScreenNewViewController: UIViewController {
    static func initialization() -> SpalashScreenNewViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SpalashScreenNewViewController") as? SpalashScreenNewViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setClearNavigationBar()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !UserData.isLogedIn()
            {
                self.navigationController?.pushViewController(LoginViewController.initialization()!, animated: true)
            }
            else
            {
                self.navigationController?.pushViewController(CustomerListViewController.initialization()!, animated: true)
                //  self.navigationController?.pushViewController(ApplicantFormViewControllerForm.initialization()!, animated: true)
            }
            
        }
        // Do any additional setup after loading the view.
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
