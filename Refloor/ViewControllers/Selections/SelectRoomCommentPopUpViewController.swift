//
//  SelectRoomCommentPopUpViewController.swift
//  Refloor
//
//  Created by Bincy C A on 16/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol AddCustomRoomProtocol{
    func sendRoomName(roomName:String)
}
protocol EditCustomRoomProtocol
{
    func editRoomName(roomName:String,roomId:Int)
}
protocol deleteCustomRoomProtocol
{
    func deleteRoomName(roomId:Int)
}

protocol versatileProtocol
{
    func whetherToProceed(isConfirmBtnPressed:Bool)
}
protocol versatileBackprotocol
{
    func whetherToProceedBack()
}

class SelectRoomCommentPopUpViewController: UIViewController,UITextFieldDelegate {
    
    static func initialization() -> SelectRoomCommentPopUpViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SelectRoomCommentPopUpViewController") as? SelectRoomCommentPopUpViewController
    }
    
    @IBOutlet weak var successSubMsgLbl: UILabel!
    @IBOutlet weak var stopSyncView: UIView!
    @IBOutlet weak var lendingBackTitle: UILabel!
    @IBOutlet weak var lendingSubTitle: UILabel!
    @IBOutlet weak var lendingPlatformTitle: UILabel!
    @IBOutlet weak var versatileView: UIView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var addEditView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var successfullView: UIView!
    @IBOutlet weak var roomNameTxtFld: UITextField!
    @IBOutlet weak var versatileBackView: UIView!
    @IBOutlet weak var successMainHeading: UILabel!
    var delegate: AddCustomRoomProtocol?
    var versatile: versatileProtocol?
    var editDelegate:EditCustomRoomProtocol?
    var deleteDelegate:deleteCustomRoomProtocol?
    var versatileBack: versatileBackprotocol?
    var isEdit:Bool = Bool()
    var roomId:Int = Int()
    var roomname:String = String()
    var isdelete:Bool = Bool()
    var isVersatile:Bool = Bool()
    var isVersaileBack:Bool = Bool()
    var isHunterBack:Bool = Bool()
    var isHunter:Bool = Bool()
    var isStopSync:Bool = Bool()
    var isSuccess:Bool = Bool()
    var isSendReview = false
    var isSuccessMsg = true
    var isAppointmentStatus = false
    var sendReviewFailedMsg:String = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
        self.roomNameTxtFld.autocapitalizationType = UITextAutocapitalizationType.allCharacters;
        roomNameTxtFld.delegate = self
        roomNameTxtFld.setLeftPaddingPoints(15)
        roomNameTxtFld.setRightPaddingPoints(15)
        if isdelete
        {
            deleteView.isHidden = false
            addEditView.isHidden = true
            versatileView.isHidden = true
            versatileBackView.isHidden = true
            stopSyncView.isHidden = true
            successfullView.isHidden = true
        }
        else if isVersatile
        {
            versatileView.isHidden = false
            deleteView.isHidden = true
            addEditView.isHidden = true
            versatileBackView.isHidden = true
            lendingPlatformTitle.text = "Versatile Credit"
            lendingSubTitle.text = lendingSubTitle.text! + "Versatile Credit?"
            stopSyncView.isHidden = true
            successfullView.isHidden = true
        }
        else if isHunter
        {
            versatileView.isHidden = false
            deleteView.isHidden = true
            addEditView.isHidden = true
            versatileBackView.isHidden = true
            lendingPlatformTitle.text = "Credit Card Rate Lending"
            lendingSubTitle.text = lendingSubTitle.text! + "Credit Card Rate Lending?"
            stopSyncView.isHidden = true
            successfullView.isHidden = true
        }
        else if isVersaileBack
        {
            versatileView.isHidden = true
            deleteView.isHidden = true
            addEditView.isHidden = true
            versatileBackView.isHidden = false
            lendingBackTitle.text = "Versatile Credit"
            stopSyncView.isHidden = true
            successfullView.isHidden = true
        }
        else if isStopSync
        {
            deleteView.isHidden = true
            addEditView.isHidden = true
            versatileView.isHidden = true
            versatileBackView.isHidden = true
            stopSyncView.isHidden = false
            successfullView.isHidden = true
        }
        else if isHunterBack
        {
            versatileView.isHidden = true
            deleteView.isHidden = true
            addEditView.isHidden = true
            versatileBackView.isHidden = false
            lendingBackTitle.text = "Credit Card Rate Lending"
            stopSyncView.isHidden = true
            successfullView.isHidden = true
        }
        else if isSuccess
        {
            deleteView.isHidden = true
            addEditView.isHidden = true
            versatileView.isHidden = true
            versatileBackView.isHidden = true
            stopSyncView.isHidden = true
            successfullView.isHidden = false
            if isSendReview
            {
                successSubMsgLbl.text = "The review link has been successfully sent."
            }
            else
            {
                successSubMsgLbl.text = "Your arrival time has been successfully logged."
            }
            if isSuccessMsg
            {
                successMainHeading.text = "Refloor"
            }
             if isAppointmentStatus
            {
                successMainHeading.text = "Appointment Verification"
                successSubMsgLbl.text = sendReviewFailedMsg//"You are not the assigned salesperson for this appointment."
            }
            if !isSuccessMsg && !isAppointmentStatus
            {
                successMainHeading.text = "Refloor"
                successSubMsgLbl.text = sendReviewFailedMsg
            }
        }
        else
        {
            deleteView.isHidden = true
            addEditView.isHidden = false
            versatileView.isHidden = true
            versatileBackView.isHidden = true
            stopSyncView.isHidden = true
            successfullView.isHidden = true
        }
        
        if isEdit == true
        {
            TitleLbl.text = "Edit Room"
            subTitleLbl.text = "Edit your room name here"
            addBtn.setTitle("Update", for: .normal)
            roomNameTxtFld.text = roomname
        }
        else
        {
            TitleLbl.text = "Add Custom Room"
            subTitleLbl.text = "Enter your room name"
            addBtn.setTitle("Add", for: .normal)
        }

        // Do any additional setup after loading the view.
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField)
//    {
//
//
//    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
//        do
//        {
//
//            let allowedCharacter1 = CharacterSet.whitespaces
//            let allowedCharacter3 = CharacterSet.decimalDigits
//            let allowedCharacter = CharacterSet.letters
//            let characterSet = CharacterSet(charactersIn: string)
//            if allowedCharacter.isSuperset(of: characterSet) || allowedCharacter1.isSuperset(of: characterSet) || allowedCharacter3.isSuperset(of: characterSet)
//            {
//                guard range.location == 0 else {
//                        return true
//                    }
//
//                    let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
//                    return (newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0) && (allowedCharacter.isSuperset(of: characterSet) || allowedCharacter1.isSuperset(of: characterSet) || allowedCharacter3.isSuperset(of: characterSet))
//            }
//        }
//        return true
        
        //Q3 changes
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ "
        if range.location == 0 && string == " "
        {
            return false
        }
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")

//            return (string == filtered)
        if string != filtered {
               return false
           }
           
           // Calculate the new length of the text
           let currentText = textField.text ?? ""
           let newLength = currentText.count + string.count - range.length
           
           // Restrict the total length to 40 characters
           return newLength <= 40
                 
    }
    @IBAction func successfullOkBtnPressed(_ sender: UIButton) 
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func stopSynBtnAction(_ sender: UIButton) 
    {
        self.dismiss(animated: true) {
            self.versatileBack?.whetherToProceedBack()
        }
    }
    @IBAction func stopSyncCancelBtnAction(_ sender: UIButton) 
    {
        self.dismiss(animated: true)
            

    }
    @IBAction func addRoomConfirmBtnAction(_ sender: UIButton)
    {
        
        if roomNameTxtFld.text == ""
        {
            self.alert("Please enter a custom room name", nil)
        }
        else
        {
            self.dismiss(animated: true)
            {
                let roomName = self.roomNameTxtFld.text!.trimmingCharacters(in: .whitespaces)
            
                if self.isEdit == false
                {
                    self.delegate?.sendRoomName(roomName: roomName)
                }
                else
                {
                    self.editDelegate?.editRoomName(roomName: roomName, roomId: self.roomId)
                }
            }
        }
    }
    @IBAction func versatileConfirmAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        {
            self.versatile?.whetherToProceed(isConfirmBtnPressed: true)
        }
    }
    @IBAction func versatileSkipAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        {
            self.versatile?.whetherToProceed(isConfirmBtnPressed: false)
        }
    }
    @IBAction func addRoomCancelBtn(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    @IBAction func deleteBtnAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        {
            self.deleteDelegate?.deleteRoomName(roomId: self.roomId)
        }
    }
    @IBAction func versatileBackCancelAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    @IBAction func versatileBackLeaveAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        {
            self.versatileBack?.whetherToProceedBack()
        }
    }
}
