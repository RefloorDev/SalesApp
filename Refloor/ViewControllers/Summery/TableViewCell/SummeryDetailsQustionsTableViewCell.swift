//
//  SummeryDetailsQustionsTableViewCell.swift
//  Refloor
//
//  Created by sbek on 26/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SummeryDetailsQustionsTableViewCell: UITableViewCell {
    @IBOutlet weak var qustionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
