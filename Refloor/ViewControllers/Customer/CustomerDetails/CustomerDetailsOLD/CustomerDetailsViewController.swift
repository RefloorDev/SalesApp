//
//  CustomerDetailsViewController.swift
//  Refloor
//
//  Created by sbek on 17/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class CustomerDetailsViewController: UIViewController,UITextFieldDelegate {
    
    
    static func initialization() -> CustomerDetailsViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerDetailsViewController") as? CustomerDetailsViewController
    }
    
    
    @IBOutlet weak var customerFirstName: UITextField!
    @IBOutlet weak var customerLastName: UITextField!
    @IBOutlet weak var coApplicantFirstName: UITextField!
    @IBOutlet weak var coApplicantMiddleName: UITextField!
    @IBOutlet weak var coApplicantLastName: UITextField!
    @IBOutlet weak var customerMiddleName: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var state_TF: UITextField!
    @IBOutlet weak var city_TF: UITextField!
    @IBOutlet weak var Street_Address_TF: UITextField!
    @IBOutlet weak var coApplicantEmail: UITextField!
    @IBOutlet weak var coApplicantPhone: UITextField!
    @IBOutlet weak var customerContactNumberTF: UITextField!
    @IBOutlet weak var customerAddressTF: UITextField!
    var roomData:[RoomDataValue]?
    var floorShapeData:[FloorShapeDataValue]?
    var floorLevelData:[FloorLevelDataValue]?
    var appoinmentslData:AppoinmentDataValue!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "Customer Details")
        self.customerFirstName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.customerLastName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.customerMiddleName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        self.customerContactNumberTF.setPlaceHolderWithColor(placeholder: "Contact Number", colour: UIColor.placeHolderColor)
        
        
        
        self.coApplicantFirstName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.coApplicantMiddleName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.coApplicantLastName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.coApplicantPhone.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.coApplicantEmail.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        self.customerAddressTF.setPlaceHolderWithColor(placeholder: "Apartment", colour: UIColor.placeHolderColor)
        self.Street_Address_TF.setPlaceHolderWithColor(placeholder: "Street", colour: UIColor.placeHolderColor)
        self.state_TF.setPlaceHolderWithColor(placeholder: "State Code", colour: UIColor.placeHolderColor)
        self.city_TF.setPlaceHolderWithColor(placeholder: "City", colour: UIColor.placeHolderColor)
        self.zipTF.setPlaceHolderWithColor(placeholder: "Zip", colour: UIColor.placeHolderColor)
        
        self.customerFirstName.text = ((self.appoinmentslData?.applicant_first_name ?? "") == "") ? (self.appoinmentslData.customer_name ?? "") : (self.appoinmentslData?.applicant_first_name ?? "")
        self.customerMiddleName.text = self.appoinmentslData.applicant_middle_name ?? ""
        self.customerLastName.text = self.appoinmentslData.applicant_last_name
        self.coApplicantMiddleName.text = self.appoinmentslData.co_applicant_middle_name ?? ""
        self.coApplicantLastName.text = self.appoinmentslData.co_applicant_last_name ?? ""
        self.coApplicantEmail.text = self.appoinmentslData.co_applicant_email ?? ""
        self.coApplicantPhone.text = self.appoinmentslData.co_applicant_phone ?? ""
        
        
        self.coApplicantFirstName.text = ((self.appoinmentslData?.co_applicant_first_name ?? "") == "") ? (self.appoinmentslData.co_applicant ?? "") : (self.appoinmentslData?.co_applicant_first_name ?? "")
        self.customerContactNumberTF.text = self.appoinmentslData.phone
        
        if let street = appoinmentslData.street2
        {
            self.customerAddressTF.text = street
        }
        if let street2 = appoinmentslData.street
        {
            self.Street_Address_TF.text = street2
        }
        if let city = appoinmentslData.city
        {
            self.city_TF.text = city
        }
        if let state = appoinmentslData.state_code
        {
            self.state_TF.text = state
        }
        
        
        self.zipTF.text = appoinmentslData.zip ?? "48083"
        setPhoneNumberDelegate()
        //         self.customerAddressTF.isUserInteractionEnabled = false
        //         self.customerContactNumberTF.isUserInteractionEnabled = false
        //         self.customerSpouseNameTF.isUserInteractionEnabled = false
        //         self.customerNameTF.isUserInteractionEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAndTransforButtonAction(_ sender: Any) {
        
        let data:[String:Any] =
            [
                "mobile": (self.customerContactNumberTF.text ?? ""),
                "street2" : (self.customerAddressTF.text ?? ""),
                "street":(self.Street_Address_TF.text ?? "") ,
                "state_code": (self.state_TF.text ?? ""),
                "city" : (self.city_TF.text ?? ""),
                "zip" :(self.zipTF.text ?? ""),
                "appointment_id": (appoinmentslData.id ?? 0),
                "customer_id":(appoinmentslData.id ?? 0),"appointment_date":(appoinmentslData.appointment_date ?? ""),"state_id":(appoinmentslData.state_id ?? 0),"state":(appoinmentslData.state ?? ""),"country_id":(appoinmentslData.country_id ?? 0),"country":(appoinmentslData.country ??
                                                                                                                                                                                                                                                                        ""),"country_code":(appoinmentslData.country_code ?? ""),"phone":(appoinmentslData.phone ?? ""),"email":(appoinmentslData.email ?? ""),"sales_person":(appoinmentslData.sales_person ?? ""),"salesperson_id":(appoinmentslData.salesperson_id ?? 0),"partner_latitude":(appoinmentslData.partner_latitude ?? 0),"partner_longitude":(appoinmentslData.partner_longitude ?? 0),"applicant_first_name":self.customerFirstName.text ?? "" ,"applicant_middle_name":self.customerMiddleName.text ?? "","applicant_last_name":self.customerLastName.text ?? "","co_applicant_first_name":self.coApplicantFirstName.text ?? "","co_applicant_middle_name":self.coApplicantMiddleName.text ?? "","co_applicant_last_name":self.coApplicantLastName.text ?? "","co_applicant_email":self.coApplicantEmail.text ?? "","co_applicant_phone":self.coApplicantPhone.text ?? ""]
        let parameter:[String:Any] = ["token":UserData.init().token ?? "","data":data]
        self.submitApi(parameter)
        
        
        
    }
    func setPhoneNumberDelegate()
    {
        self.coApplicantPhone.delegate = self
        self.customerContactNumberTF.delegate = self
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil
        {
            if(textField == self.coApplicantPhone || textField == self.customerContactNumberTF)
            {
                guard let text = textField.text else { return false }
                let newString = (text as NSString).replacingCharacters(in: range, with: string)
                textField.text = self.format(with: "(XXX) XXX-XXXX", phone: newString)
                return false
            }
            
            return true
        }
        else
        {
            
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            
            if (isBackSpace == -92) {
                return true
            }
            
            return false
        }
    }
    
    
    
    func validation() -> String
    {
        
        
        if !(coApplicantEmail.text!.validateEmail()||coApplicantEmail.text == "")
        {
            return "Please enter a valid email address"
        }
        
        
        return ""
        
        
        
    }
    
    func submitApi(_ parameter:[String:Any])
    {
        if(validation() != "")
        {
            self.alert(validation(), nil)
            return
        }
        
        HttpClientManager.SharedHM.SubmitAppointmentsApi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                self.appoinmentslData.customer_name = (self.coApplicantFirstName.text ?? "")
                self.appoinmentslData.mobile = (self.customerContactNumberTF.text ?? "")
                self.appoinmentslData.co_applicant = (self.coApplicantFirstName.text ?? "")
                self.appoinmentslData.street2 = (self.customerAddressTF.text ?? "")
                self.appoinmentslData.street =  (self.Street_Address_TF.text ?? "")
                self.appoinmentslData.state_code = (self.state_TF.text ?? "")
                self.appoinmentslData.city =  (self.city_TF.text ?? "")
                self.appoinmentslData.zip = (self.zipTF.text ?? "")
                self.appoinmentslData.applicant_first_name = self.customerFirstName.text ?? ""
                self.appoinmentslData.applicant_middle_name = self.customerMiddleName.text ?? ""
                self.appoinmentslData.applicant_last_name = self.customerLastName.text ?? ""
                self.appoinmentslData.co_applicant_first_name = self.coApplicantFirstName.text ?? ""
                self.appoinmentslData.co_applicant_middle_name = self.coApplicantMiddleName.text ?? ""
                self.appoinmentslData.co_applicant_email = self.coApplicantEmail.text ?? ""
                self.appoinmentslData.co_applicant_phone = self.coApplicantPhone.text ?? ""
                self.appoinmentslData.co_applicant_last_name = self.coApplicantLastName.text ?? ""
                AppDelegate.floorLevelData = self.floorLevelData ?? []
                AppDelegate.roomData = self.roomData ?? []
                AppDelegate.appoinmentslData = self.appoinmentslData
                
                if !(self.appoinmentslData.is_room_measurement_exist ?? false)
                {
                    let room = SelectARoomViewController.initialization()!
                    
                    room.appoinmentsData = self.appoinmentslData
                    self.navigationController?.pushViewController(room, animated: true)
                }
                else
                {
                    let summeryList = SummeryListViewController.initialization()!
                    summeryList.appoinmentID = self.appoinmentslData.id ?? 0
                    self.navigationController?.pushViewController(summeryList, animated: true)
                }
            }
            else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                        {
                         
                            let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                                
                                self.fourceLogOutbuttonAction()
                            }
                          
                            self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
                            
                        }
            else
            {
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
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
