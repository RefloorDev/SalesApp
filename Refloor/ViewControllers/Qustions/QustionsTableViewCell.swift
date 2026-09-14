//
//  QustionsTableViewCell.swift
//  Refloor
//
//  Created by sbek on 04/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class QustionsTableViewCell: UITableViewCell {
    //@IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    weak var importRoomButton: UIButton?
    //@IBOutlet weak var subHeadingLabel: UILabel!
    
    @IBOutlet weak var numerical_Qustion_Label: UILabel!
    @IBOutlet weak var numerical_Answer_Label: UITextField!
    @IBOutlet weak var numerical_Pluse_Button: UIButton!
    @IBOutlet weak var numerilcal_Minus_Button: UIButton!
    
    @IBOutlet weak var selection_Qustion_Label: UILabel!
    @IBOutlet weak var selection_Answer_Label: UILabel!
    @IBOutlet weak var selection_DropDown_Button: UIButton!
    
    @IBOutlet weak var miscellaneousTxtView: UITextView!
    
    @IBOutlet weak var entry_Qustion_Label: UILabel!
    @IBOutlet weak var entry_Answer_TextView: UITextView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let nextBtn = nextButton, let parent = nextBtn.superview {
            let btn = UIButton(type: .custom)
            btn.setTitle("Import Room", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor(red: 88/255.0, green: 100/255.0, blue: 113/255.0, alpha: 1.0)
            btn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
            btn.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(btn)
            self.importRoomButton = btn
            
            NSLayoutConstraint.activate([
                btn.trailingAnchor.constraint(equalTo: nextBtn.leadingAnchor, constant: -20),
                btn.centerYAnchor.constraint(equalTo: nextBtn.centerYAnchor),
                btn.heightAnchor.constraint(equalToConstant: 70),
                btn.widthAnchor.constraint(equalToConstant: 207)
            ])
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

