//
//  ContactCommentPopUpViewController.swift
//  Refloor
//
//  Created by Arun Rajendrababu on 30/05/22.
//  Copyright © 2022 oneteamus. All rights reserved.
//

import UIKit
protocol ContractCommentProtocol{
    func sendAddedComments(comment: String, sendHardCopy: Bool, sendFlexInstall : Bool)
}

class ContactCommentPopUpViewController: UIViewController,UITextViewDelegate {
    static func initialization() -> ContactCommentPopUpViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ContactCommentPopUpViewController") as? ContactCommentPopUpViewController
    }
    @IBOutlet weak var sendPhysicalBtn: UIButton!
    @IBOutlet weak var sendPhysicalStackView: UIStackView!
    var delegate: ContractCommentProtocol?
    let placeholderColor = UIColor.lightGray
    let placeholderText = "Enter Here"
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var sendPhysicalDocumentCheckboxButton: UIButton!
    @IBOutlet weak var sendPhysicalStackViewHeightCnstr: NSLayoutConstraint!
    @IBOutlet weak var flexibleInstallCheckBoxBtn: UIButton!
    var isSendHardCopy = false
    var isFlexibleInstall = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTextView.text = placeholderText
        commentsTextView.textColor = placeholderColor
        commentsTextView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        sendPhysicalBtn.isHidden = true
        sendPhysicalStackView.isHidden = true
        sendPhysicalStackViewHeightCnstr.constant = 0
    }
    
    @IBAction func dismissOnBackgroundTap(_ sender: UIControl) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendPhysicalContractAction(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            sendPhysicalDocumentCheckboxButton.isSelected = false
            isSendHardCopy = false
        }else{
            sender.isSelected = true
            sendPhysicalDocumentCheckboxButton.isSelected = true
            isSendHardCopy = true
        }
    }
    
    @IBAction func FlexibleInstallContractAction(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            flexibleInstallCheckBoxBtn.isSelected = false
            isFlexibleInstall = false
        }else{
            sender.isSelected = true
            flexibleInstallCheckBoxBtn.isSelected = true
            isFlexibleInstall = true
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        delegate?.sendAddedComments(comment: "", sendHardCopy: isSendHardCopy, sendFlexInstall: isFlexibleInstall)
        self.dismiss(animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if let comment = commentsTextView.text{
            if comment.trimmingCharacters(in: .whitespaces).count > 0 && comment != placeholderText{
                self.dismiss(animated: true) {
                    self.delegate?.sendAddedComments(comment: comment, sendHardCopy: self.isSendHardCopy, sendFlexInstall: self.isFlexibleInstall)
                }
                
            } else{
                self.dismiss(animated: true){
                    self.delegate?.sendAddedComments(comment: "",sendHardCopy: self.isSendHardCopy, sendFlexInstall: self.isFlexibleInstall)
                }
//                let okBtn = UIAlertAction(title: "OK", style: .cancel)
//                self.alert("Please enter comment", [okBtn])
            }
            
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderColor {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = placeholderColor
        }
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
