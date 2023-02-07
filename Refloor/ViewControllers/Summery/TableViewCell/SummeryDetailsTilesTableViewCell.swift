//
//  SunneryDetailsTilesTableViewCell.swift
//  Refloor
//
//  Created by sbek on 12/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SummeryDetailsTilesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tileImageView: UIImageView!
    @IBOutlet weak var aboutLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
