//
//  SummeryDetailsFooterTableViewCell.swift
//  Refloor
//
//  Created by sbek on 31/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SummeryDetailsFooterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
