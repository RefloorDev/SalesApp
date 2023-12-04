//
//  VersatileViewController.swift
//  Refloor
//
//  Created by Bincy C A on 04/12/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit

class VersatileViewController: UIViewController {
    static public func initialization() -> VersatileViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "VersatileViewController") as? VersatileViewController
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "LENDING PLATFORM")
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        // Do any additional setup after loading the view.
    }
    

    

}
