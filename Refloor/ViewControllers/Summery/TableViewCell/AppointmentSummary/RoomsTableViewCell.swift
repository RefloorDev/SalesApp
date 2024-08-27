//
//  RoomsTableViewCell.swift
//  Refloor
//
//  Created by Bincy C A on 12/08/24.
//  Copyright © 2024 oneteamus. All rights reserved.
//

import UIKit

class RoomsTableViewCell: UITableViewCell {

    @IBOutlet weak var moldingLbl: UILabel!
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var areaMeasuredTextLbl: UILabel!
    @IBOutlet weak var areaMeasured: UILabel!
    @IBOutlet weak var removeExistingLbl: UILabel!
    @IBOutlet weak var currentSurface: UILabel!
    @IBOutlet weak var includedTick: UIImageView!
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var roomImage: UIImageView!
    @IBOutlet weak var moldingTxtLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
