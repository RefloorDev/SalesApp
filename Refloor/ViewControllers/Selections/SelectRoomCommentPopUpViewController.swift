//
//  SelectRoomCommentPopUpViewController.swift
//  Refloor
//
//  Created by Bincy C A on 16/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit

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

class SelectRoomCommentPopUpViewController: UIViewController,UITextFieldDelegate {
    
    static func initialization() -> SelectRoomCommentPopUpViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SelectRoomCommentPopUpViewController") as? SelectRoomCommentPopUpViewController
    }
    
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var addEditView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var roomNameTxtFld: UITextField!
    var delegate: AddCustomRoomProtocol?
    var editDelegate:EditCustomRoomProtocol?
    var deleteDelegate:deleteCustomRoomProtocol?
    var isEdit:Bool = Bool()
    var roomId:Int = Int()
    var roomname:String = String()
    var isdelete:Bool = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.roomNameTxtFld.autocapitalizationType = UITextAutocapitalizationType.allCharacters;
        roomNameTxtFld.delegate = self
        roomNameTxtFld.setLeftPaddingPoints(15)
        roomNameTxtFld.setRightPaddingPoints(15)
        if isdelete
        {
            deleteView.isHidden = false
            addEditView.isHidden = true
        }
        else
        {
            deleteView.isHidden = true
            addEditView.isHidden = false
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
            subTitleLbl.text = "Edit your room name"
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
        do
        {
            let allowedCharacter = CharacterSet.letters
            let allowedCharacter1 = CharacterSet.whitespaces
            let allowedCharacter3 = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            if allowedCharacter.isSuperset(of: characterSet) || allowedCharacter1.isSuperset(of: characterSet) || allowedCharacter3.isSuperset(of: characterSet)
            {
                guard range.location == 0 else {
                        return true
                    }

                    let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
                    return (newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0) && (allowedCharacter.isSuperset(of: characterSet) || allowedCharacter1.isSuperset(of: characterSet) || allowedCharacter3.isSuperset(of: characterSet))
            }
        }
        return true
                 
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
                if self.isEdit == false
                {
                    self.delegate?.sendRoomName(roomName: self.roomNameTxtFld.text!)
                }
                else
                {
                    self.editDelegate?.editRoomName(roomName: self.roomNameTxtFld.text!, roomId: self.roomId)
                }
            }
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
}
