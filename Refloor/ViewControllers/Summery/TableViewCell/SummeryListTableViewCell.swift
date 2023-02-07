//
//  SummeryListTableViewCell.swift
//  Refloor
//
//  Created by sbek on 27/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SummeryListTableViewCell: UITableViewCell {
    @IBOutlet weak var floorNameLabel: UILabel!
    @IBOutlet weak var strickView: UIView!
    @IBOutlet weak var areaLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
class SummeryListNewTableViewCell: UITableViewCell {
    @IBOutlet weak var summeryAttachmentView: UIImageView!
    @IBOutlet weak var moldingBgView: UIView!
    @IBOutlet weak var colorView: UIImageView!
    @IBOutlet weak var colorLabel: UITextField!
    @IBOutlet weak var selectColor: UIButton!
    @IBOutlet weak var floorNameLabel: UILabel!
    @IBOutlet weak var strickView: UIView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var selectColorNewBgView: UIView!
    @IBOutlet weak var molding: UITextField!
      @IBOutlet weak var moldingHeader: UILabel!
    @IBOutlet weak var selectMolding: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
