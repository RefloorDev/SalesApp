//
//  InstallerSuccessViewController.swift
//  Refloor
//
//  Created by Bincy C A on 22/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit

class InstallerSuccessViewController: UIViewController {
    
    static func initialization() -> InstallerSuccessViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "InstallerSuccessViewController") as? InstallerSuccessViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        schedulerSuccessNavBar()
        
    }
    

    

}
