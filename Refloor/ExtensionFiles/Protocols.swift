//
//  Protocals.swift
//  MajourApp
//
//  Created by sbek on 14/01/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol ExternalCollectionViewDelegateForTableView {
    func externalCollectionViewDidSelectbutton(index:Int,tag:Int)
}
protocol ExternalCollectionViewDelegate {
    func externalCollectionViewDidSelectbutton(index:Int)
}
protocol ExternalCollectionViewDelegate2 {
    func externalCollectionViewDidSelectbutton2(index:Int,tag:Int)
}
protocol DropDownDelegate {
    func DropDownDidSelectedAction(_ index:Int,_ item:String,_ tag:Int)
}
protocol DropDownForTableViewCellDelegate {
    func DropDownDidSelectedAction(index:Int,item:String,tag:Int,cell:Int)
}
protocol MultySelectionDelegate {
    func MultySelectionSelectedAction(_ items:[QuoteLabelData],_ tag:Int)
}

protocol PermissionAccessDelegate {
    func didconfirmationfromPermissionAccess(isRegisterd:Bool)
}

protocol PromoPopUpViewDelegate {
    func didApplyPromoCode(code:String)
    func didApplyDiscountAtCash(cash:Double)
    func didApplyDiscountAtPersentage(persentage:Double)
}
