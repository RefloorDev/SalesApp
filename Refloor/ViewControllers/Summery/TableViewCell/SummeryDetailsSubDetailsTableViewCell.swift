//
//  SummeryDetailsSubDetailsTableViewCell.swift
//  Refloor
//
//  Created by sbek on 26/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SummeryDetailsSubDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var shapeMessurementImage: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var messurementTF: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
