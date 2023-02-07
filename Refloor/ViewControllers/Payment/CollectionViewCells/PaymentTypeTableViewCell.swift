//
//  PaymentTypeTableViewCell.swift
//  Refloor
//
//  Created by sbek on 29/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class PaymentTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
