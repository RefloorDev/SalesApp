//
//  PamentOptionsTopCollectionViewCell.swift
//  Refloor
//
//  Created by sbek on 17/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class PamentOptionsTopCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var HeadingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var warrentyLabel: UILabel!
    @IBOutlet weak var mrpLabel: UILabel!
    @IBOutlet weak var monthlyPayment: UILabel!
    @IBOutlet weak var adjustmentValue: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var adjustmentHeadingLabel: UILabel!
    @IBOutlet weak var priceTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var makeVisibleButton: UIButton!
    @IBOutlet weak var savingsValueHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var savingsLblHeightConstraint: NSLayoutConstraint!
    var viewC:PaymentOptionsNewViewController?
    @IBAction func makeVisibleButtonAction(_ sender: UIButton) {
        if viewC != nil
        {
            if viewC!.paymentPlanValueDetails[sender.tag].isNotAvailable
            {
                self.makeVisibleButton.setImage(UIImage(named: "redcancel"), for: .normal)
                self.closeImage.image = nil
                viewC?.paymentPlanValueDetails[sender.tag].isNotAvailable = false
            }
            else
            {
                self.makeVisibleButton.setImage(UIImage(named: "graycancel"), for: .normal)
                self.closeImage.image = UIImage(named: "closeBG")
                if(viewC?.selectedPlan == sender.tag)
                {
                    viewC?.selectedPlan = -1
                    viewC?.monthlyValue = 0
                    viewC?.adjestmentValue = 0
                    viewC?.adjustmentLabel.text = "YOU SAVED $\(0) !"
                    viewC?.planCollectionView.reloadData()
                }
                viewC?.paymentPlanValueDetails[sender.tag].isNotAvailable = true
            }
        }
    }
    
}
