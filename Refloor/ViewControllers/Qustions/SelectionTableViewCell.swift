//
//  SelectionTableViewCell.swift
//  Refloor
//
//  Created by sbek on 05/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectionBGView: UIView!
    @IBOutlet weak var tickImageView: UIImageView!
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
