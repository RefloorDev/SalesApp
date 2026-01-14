//
//  FinanceProviderTableViewCell.swift
//  Refloor
//
//  Created by macbook on 1/13/26.
//  Copyright © 2026 oneteamus. All rights reserved.
//

import UIKit

class FinanceProviderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var versatileBtnImage: UIImageView!
    @IBOutlet weak var versatileStackView: UIStackView!
    @IBOutlet weak var versatileLogo:UIImageView!
    @IBOutlet weak var versatileTitle:UILabel!
    @IBOutlet weak var bGButton:UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
