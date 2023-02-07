//
//  TotalPriceTableViewCell.swift
//  Refloor
//
//  Created by Arun Rajendrababu on 03/06/22.
//  Copyright © 2022 oneteamus. All rights reserved.
//

import UIKit

class TotalPriceTableViewCell: UITableViewCell {

    @IBOutlet weak var newPriceStackView: UIStackView!
    @IBOutlet weak var newPriceInitialStackView: UIStackView!
    @IBOutlet weak var newPriceLabel: UILabel!
    @IBOutlet weak var newInitialPriceLabel: UILabel!
    @IBOutlet weak var totalSavingsStackView: UIStackView!
    @IBOutlet weak var totalSavingsLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
