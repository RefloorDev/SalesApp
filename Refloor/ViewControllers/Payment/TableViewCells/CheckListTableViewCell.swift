//
//  CheckListTableViewCell.swift
//  Refloor
//
//  Created by Bincy C A on 14/02/25.
//  Copyright © 2025 oneteamus. All rights reserved.
//

import UIKit

class CheckListTableViewCell: UITableViewCell {

    @IBOutlet weak var checkListBgBtn: UIButton!
    @IBOutlet weak var checkListBtn: UIButton!
    @IBOutlet weak var checkListLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
