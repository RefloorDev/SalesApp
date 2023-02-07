//
//  SelectionViewController.swift
//  Refloor
//
//  Created by sbek on 05/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    static func initialization() -> SelectionViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SelectionViewController") as? SelectionViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionName: UILabel!
    var quote_label :[QuoteLabelData] = []
    var selectedQuote_Label:[QuoteLabelData] = []
    var delegate:MultySelectionDelegate?
    var  question = ""
    var tag = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "")
        questionName.text = question
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quote_label.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var isSelected = false
        for select in selectedQuote_Label
        {
            if select.value == quote_label[indexPath.row].value
            {
                isSelected = true
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionTableViewCell") as! SelectionTableViewCell
        
        cell.nameLabel.text = quote_label[indexPath.row].value
        
        if(isSelected)
        {
            cell.selectionBGView.layer.borderColor = UIColor(displayP3Red: 201/255, green: 63/255, blue: 72/255, alpha: 1).cgColor//#rgba(201, 63, 72, 1)
            cell.selectionBGView.layer.borderWidth = 3
            cell.tickImageView.image = UIImage(named: "tick")
            
        }
        else
        {
            cell.selectionBGView.layer.borderColor = UIColor.clear.cgColor
            cell.selectionBGView.layer.borderWidth = 0
            cell.tickImageView.image = UIImage()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var isSelected = false
        var i = 0
        for select in selectedQuote_Label
        {
            if select.value == quote_label[indexPath.row].value
            {
                isSelected = true
            }
            if(!isSelected)
            {
                i += 1
            }
        }
        if isSelected
        {
            selectedQuote_Label.remove(at: i)
        }
        else
        {
            selectedQuote_Label.append(quote_label[indexPath.row])
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func performSegueToReturnBack() {
        delegate?.MultySelectionSelectedAction(selectedQuote_Label, tag)
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
