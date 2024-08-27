//
//  AppointmentSummaryFirstRowTableViewCell.swift
//  Refloor
//
//  Created by Bincy C A on 08/08/24.
//  Copyright © 2024 oneteamus. All rights reserved.
//

import UIKit

class AppointmentSummaryFirstRowTableViewCell: UITableViewCell {

    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var paymentSummaryBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) 
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
