//
//  CustomerListTableViewCell.swift
//  Refloor
//
//  Created by sbek on 17/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class CustomerListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var customerLocationLabel: UILabel!
    @IBOutlet weak var cutomerphoneNumberLabel: UILabel!
    @IBOutlet weak var cutomerphoneNumberLogoImageView: UIImageView!
    @IBOutlet weak var customerPhoneStackView: UIStackView!
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
