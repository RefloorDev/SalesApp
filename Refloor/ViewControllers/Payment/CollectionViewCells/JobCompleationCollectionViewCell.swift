//
//  JobCompleationCollectionViewCell.swift
//  Refloor
//
//  Created by sbek on 29/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class JobCompleationCollectionViewCell: UICollectionViewCell,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var loanButton: UIButton!
    @IBOutlet weak var onjobButton: UIButton!
    @IBOutlet weak var tableViewHightConstrain: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var payButton: UIButton!
    var items:[String] = ["Credit Card","Debit Card","Check","Cash"]
    var selectedItem = 0
    var isOnjobCompletion = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.isHidden = true
        tableViewHightConstrain.constant = 0
        payButton.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PaymentTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentTypeTableViewCell")
    }
    func reload()
    {
        self.selectedItem = 0
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTypeTableViewCell") as! PaymentTypeTableViewCell
        cell.nameLabel.text = items[indexPath.row]
        if(selectedItem == indexPath.row)
        {
            cell.selectionImageView.image =  UIImage(named: "selectedRound")
        }
        else
        {
            cell.selectionImageView.image =  UIImage(named: "deselectedRound")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedItem = indexPath.row
        self.tableView.reloadData()
    }
    
    
    
    @IBAction func onJobCompleation(_ sender: UIButton) {
        isOnjobCompletion = true
        tableView.isHidden = false
        payButton.isHidden = false
        onjobButton.borderColor = .redColor
        onjobButton.borderWidth = 3
        loanButton.borderColor = .clear
        loanButton.borderWidth = 0
        tableViewHightConstrain.constant = CGFloat(items.count * 44)
    }
    @IBAction func onApplyLoan(_ sender: UIButton) {
        isOnjobCompletion = false
        tableView.isHidden = true
        payButton.isHidden = false
        loanButton.borderColor = .redColor
        loanButton.borderWidth = 3
        onjobButton.borderColor = .clear
        onjobButton.borderWidth = 0
        tableViewHightConstrain.constant = 0
    }
    @IBAction func PayButtonAction(_ sender: UIButton) {
    }
    
    
}
