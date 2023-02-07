//
//  CustomerDetailsTowViewController.swift
//  Refloor
//
//  Created by sbek on 21/10/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RealmSwift

class CustomerDetailsTowViewController: UIViewController,UITextFieldDelegate {
    
    
    static func initialization() -> CustomerDetailsTowViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerDetailsTowViewController") as? CustomerDetailsTowViewController
    }
    
    
    @IBOutlet weak var customerFirstName: UITextField!
    @IBOutlet weak var customerLastName: UITextField!
    @IBOutlet weak var customerMiddleName: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var state_TF: UITextField!
    @IBOutlet weak var city_TF: UITextField!
    @IBOutlet weak var Street_Address_TF: UITextField!
    @IBOutlet weak var customerEmail: UITextField!
    @IBOutlet weak var customerPhone: UITextField!
    @IBOutlet weak var customerPhoneStackView: UIStackView!
    @IBOutlet weak var customerContactNumberTF: UITextField!
    @IBOutlet weak var customerContactNumberStackView: UIStackView!
    
    @IBOutlet weak var customerContactNumberHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerContactNumbertopConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerContactNumberbottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customerPhoneHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerPhoneNumbertopConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerPhoneNumberbottomConstraint: NSLayoutConstraint!
    var isEditedtextField = false
    
    var roomData:[RoomDataValue]?
    var floorShapeData:[FloorShapeDataValue]?
    var floorLevelData:[FloorLevelDataValue]?
    var appoinmentslData:AppoinmentDataValue!
    var GMSTag = 0
    var isSkippbuttonCalled:Int = 0
    var imagePicker: CaptureImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //arb
        if UserDefaults.standard.integer(forKey: "can_view_phone_number") == 0{
            customerPhoneStackView.isHidden = true
            customerContactNumberStackView.isHidden = true
            customerContactNumberHeightConstraint.constant = 0
            customerPhoneHeightConstraint.constant = 0
            
            customerContactNumbertopConstraint.constant = 0
            customerContactNumberbottomConstraint.constant = 0
            
            customerPhoneNumbertopConstraint.constant = 0
            customerPhoneNumberbottomConstraint.constant = 0
        }else{
            customerPhoneStackView.isHidden = false
            customerContactNumberStackView.isHidden = false
            customerContactNumberHeightConstraint.constant = 111
            customerPhoneHeightConstraint.constant = 111
            
            customerContactNumbertopConstraint.constant = 10
            customerContactNumberbottomConstraint.constant = 30
            
            customerPhoneNumbertopConstraint.constant = 10
            customerPhoneNumberbottomConstraint.constant = 30
            
        }
        //

        // AppDelegate.appoinmentslData.id = appoinmentslData.id
        AppDelegate.appoinmentslData = self.appoinmentslData
        self.setNavigationBarbackAndlogo(with: "Customer 2 Details")
        self.customerFirstName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.customerLastName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.customerMiddleName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        self.customerContactNumberTF.setPlaceHolderWithColor(placeholder: "Contact Number", colour: UIColor.placeHolderColor)
        
        
        
        self.customerEmail.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.customerPhone.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        self.customerContactNumberTF.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        self.Street_Address_TF.setPlaceHolderWithColor(placeholder: "Street", colour: UIColor.placeHolderColor)
        self.state_TF.setPlaceHolderWithColor(placeholder: "State Code", colour: UIColor.placeHolderColor)
        self.city_TF.setPlaceHolderWithColor(placeholder: "City", colour: UIColor.placeHolderColor)
        self.zipTF.setPlaceHolderWithColor(placeholder: "Zip", colour: UIColor.placeHolderColor)
        
        self.customerFirstName.text = ((self.appoinmentslData?.co_applicant_first_name ?? "") == "") ? (self.appoinmentslData.co_applicant ?? "") : (self.appoinmentslData?.co_applicant_first_name ?? "")
        self.customerMiddleName.text = self.appoinmentslData.co_applicant_middle_name ?? ""
        self.customerLastName.text = self.appoinmentslData.co_applicant_last_name
        
        self.customerContactNumberTF.text = self.appoinmentslData.co_applicant_secondary_phone
        self.customerEmail.text = self.appoinmentslData.co_applicant_email
        
        self.Street_Address_TF.text = self.appoinmentslData.co_applicant_address
        self.city_TF.text = self.appoinmentslData.co_applicant_city
        self.state_TF.text = self.appoinmentslData.co_applicant_state
        self.zipTF.text = self.appoinmentslData.co_applicant_zip
        self.customerPhone.text = self.appoinmentslData.co_applicant_phone
        self.appoinmentslData.co_applicant_skipped = 0
        
        self.checkTextFieldEdited()
        setPhoneNumberDelegate()
        //         self.customerAddressTF.isUserInteractionEnabled = false
        //         self.customerContactNumberTF.isUserInteractionEnabled = false
        //         self.customerSpouseNameTF.isUserInteractionEnabled = false
        //         self.customerNameTF.isUserInteractionEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         isSkippbuttonCalled = 0
    }
    
    @IBAction func submitAndTransforButtonAction(sender: UIButton)
    {
        if(isSkippbuttonCalled != 0)
        {
            sender.tag = isSkippbuttonCalled
        }
        isSkippbuttonCalled = sender.tag
        if(sender.tag != 1)
        {
            //            if(!isSkippbuttonCalled)
            //            {
            if(validation() != "")
            {
                isSkippbuttonCalled = 0
                self.alert(validation(), nil)
                return
            }
            //}
        }
        else
        {
            self.appoinmentslData.co_applicant_skipped = 1
        }
        let string1 = self.appoinmentslData.applicant_first_name ?? ""
        let string2 = self.appoinmentslData.applicant_last_name ?? ""
        var name = string1 + " " + string2
        
        let data:[String:Any] =
        [
            "mobile": (self.appoinmentslData.mobile ?? ""),
            "street2" : "",
            "street":(self.appoinmentslData.street ?? "") ,
            "state_code": (self.appoinmentslData.state_code ?? ""),
            "city" : (self.appoinmentslData.city ?? ""),
            "zip" :(self.appoinmentslData.zip ?? ""),
            "appointment_id": (appoinmentslData.id ?? 0),
            "customer_id":(appoinmentslData.id ?? 0),"appointment_date":(appoinmentslData.appointment_date ?? ""),"state":(appoinmentslData.state ?? ""),"country_id":(appoinmentslData.country_id ?? 0),"country":(appoinmentslData.country ??
                                                                                                                                                                                                                    ""),"country_code":(appoinmentslData.country_code ?? ""),"phone":(appoinmentslData.phone ?? ""),"email":(appoinmentslData.email ?? ""),"sales_person":(appoinmentslData.sales_person ?? ""),"salesperson_id":(appoinmentslData.salesperson_id ?? 0),"partner_latitude":(appoinmentslData.partner_latitude ?? 0),"partner_longitude":(appoinmentslData.partner_longitude ?? 0),"applicant_first_name":self.appoinmentslData.applicant_first_name ?? "" ,"applicant_middle_name":self.appoinmentslData.applicant_middle_name ?? "","applicant_last_name":self.appoinmentslData.applicant_last_name ?? "","co_applicant_first_name":self.customerFirstName.text ?? "","co_applicant_middle_name":self.customerMiddleName.text ?? "","co_applicant_last_name":self.customerLastName.text ?? "","co_applicant_email":self.customerEmail.text ?? "","co_applicant_secondary_phone":self.customerContactNumberTF.text ?? "","co_applicant_address":self.Street_Address_TF.text ?? "","co_applicant_city":self.city_TF.text ?? "","co_applicant_state":self.state_TF.text ?? "","co_applicant_zip":self.zipTF.text ?? "","co_applicant_phone":self.customerPhone.text ?? "","id":appoinmentslData.id ?? 0,
            "co_applicant_skipped":appoinmentslData       .co_applicant_skipped ?? 0]
        let parameter:[String:Any] = ["token":UserData.init().token ?? "","data":data]
        
        self.updateAppointmentData(appointmentChangesDict: data)
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        if !(checkIfAtleastOneRoomAddedUnderAppointment(appointmentId: appointmentId)){
            let appointmentInProcess = rf_completed_appointment(appointmentObj: rf_master_appointment(appointmentData: self.appoinmentslData))
            do{
                let realm = try Realm()
                try realm.write{
                    let appointmentId = AppointmentData().appointment_id
                    let appointment =  realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)
                    //let masterData = realm.objects(MasterData.self)
                    appointment?.co_applicant_first_name = data["co_applicant_first_name"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_middle_name"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_last_name"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_address"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_email"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_phone"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_zip"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_state"] as? String ?? ""
                    appointment?.co_applicant_first_name = data["co_applicant_city"] as? String ?? ""
                    if let rooms = appointment?.rooms{
                        appointmentInProcess.rooms = rooms
                    }
                    realm.add(appointmentInProcess, update: .all)
                }
            }catch{
                print(RealmError.initialisationFailed)
            }
        }
        //
        
        /*  if(isEditedtextField)
         {
         //arb commented
         // self.submitApi(parameter)
         if !(checkIfAtleastOneRoomAddedUnderAppointment(appointmentId: appointmentId))
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
         else
         {*/
        
        self.appoinmentslData.co_applicant_address =  (self.Street_Address_TF.text ?? "")
        self.appoinmentslData.co_applicant_state = (self.state_TF.text ?? "")
        self.appoinmentslData.co_applicant_city =  (self.city_TF.text ?? "")
        self.appoinmentslData.co_applicant_zip = (self.zipTF.text ?? "")
        self.appoinmentslData.co_applicant_first_name = self.customerFirstName.text ?? ""
        self.appoinmentslData.co_applicant_middle_name = self.customerMiddleName.text ?? ""
        self.appoinmentslData.co_applicant_last_name = self.customerLastName.text ?? ""
        
        
        self.appoinmentslData.co_applicant_email = self.customerEmail.text ?? ""
        self.appoinmentslData.co_applicant_phone = self.customerPhone.text ?? ""
        self.appoinmentslData.co_applicant_secondary_phone = self.customerContactNumberTF.text ?? ""
        
        
        
        AppDelegate.floorLevelData = self.floorLevelData ?? []
        AppDelegate.roomData = self.roomData ?? []
        AppDelegate.appoinmentslData = self.appoinmentslData
        
        //arb
        // if !(self.appoinmentslData.is_room_measurement_exist ?? false)
        //arb
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "Customer2"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        if !(checkIfAtleastOneRoomAddedUnderAppointment(appointmentId: appointmentId))
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
        
        //  }
        
        //  isEditedtextField = false
    }
    
    @IBAction func skipButtonAction(sender: UIButton)
    {
       // isSkippbuttonCalled = true
        if(sender.tag != 1)
        {
            if(validation() != "")
            {
                self.alert(validation(), nil)
                return
            }
        }
        let string1 = self.customerFirstName.text ?? ""
        let string2 = self.customerLastName.text ?? ""
        var name = string1 + " " + string2
        
        let data:[String:Any] =
            [
                "mobile": (self.appoinmentslData.mobile ?? ""),
                "street2" : "",
                "street":(self.appoinmentslData.street ?? "") ,
                "state_code": (self.appoinmentslData.state_code ?? ""),
                "city" : (self.appoinmentslData.city ?? ""),
                "zip" :(self.appoinmentslData.zip ?? ""),
                "appointment_id": (appoinmentslData.id ?? 0),
                "customer_id":(appoinmentslData.id ?? 0),"appointment_date":(appoinmentslData.appointment_date ?? ""),"state":(appoinmentslData.state ?? ""),"country_id":(appoinmentslData.country_id ?? 0),"country":(appoinmentslData.country ??
                                                                                                                                                                                                                            ""),"country_code":(appoinmentslData.country_code ?? ""),"phone":(appoinmentslData.phone ?? ""),"email":(appoinmentslData.email ?? ""),"sales_person":(appoinmentslData.sales_person ?? ""),"salesperson_id":(appoinmentslData.salesperson_id ?? 0),"partner_latitude":(appoinmentslData.partner_latitude ?? 0),"partner_longitude":(appoinmentslData.partner_longitude ?? 0),"applicant_first_name":self.appoinmentslData.applicant_first_name ?? "" ,"applicant_middle_name":self.appoinmentslData.applicant_middle_name ?? "","applicant_last_name":self.appoinmentslData.applicant_last_name ?? "","co_applicant_first_name":self.customerFirstName.text ?? "","co_applicant_middle_name":self.customerMiddleName.text ?? "","co_applicant_last_name":self.customerLastName.text ?? "","co_applicant_email":self.customerEmail.text ?? "","co_applicant_secondary_phone":self.customerPhone.text ?? "","co_applicant_address":self.Street_Address_TF.text ?? "","co_applicant_city":self.city_TF.text ?? "","co_applicant_state":self.state_TF.text ?? "","co_applicant_zip":self.zipTF.text ?? "","co_applicant_phone":self.customerContactNumberTF.text ?? "","co_applicant_skipped":appoinmentslData       .co_applicant_skipped ?? 1]
        let parameter:[String:Any] = ["token":UserData.init().token ?? "","data":data]
        let appointmentId = AppointmentData().appointment_id ?? 0
        //arb
        let appointmentInProcess = rf_completed_appointment(appointmentObj: rf_master_appointment(appointmentData: self.appoinmentslData))
        do{
            let realm = try Realm()
            try realm.write{
                let appointment =  realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)
                let masterData = realm.objects(MasterData.self)
                
                if let rooms = appointment?.rooms{
                    appointmentInProcess.rooms = rooms
                }
                if let snapshotArray = appointment?.snanpshotImages{
                    appointmentInProcess.snanpshotImages = snapshotArray
                }
                realm.add(appointmentInProcess, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        //arb
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "Customer2"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        if(isEditedtextField)
        {
           // self.submitApi(parameter)
            if !(checkIfAtleastOneRoomAddedUnderAppointment(appointmentId: appointmentId))
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
        else
        {
            self.appoinmentslData.co_applicant_address =  (self.Street_Address_TF.text ?? "")
            self.appoinmentslData.co_applicant_state = (self.state_TF.text ?? "")
            self.appoinmentslData.co_applicant_city =  (self.city_TF.text ?? "")
            self.appoinmentslData.co_applicant_zip = (self.zipTF.text ?? "")
            self.appoinmentslData.co_applicant_first_name = self.customerFirstName.text ?? ""
            self.appoinmentslData.co_applicant_middle_name = self.customerMiddleName.text ?? ""
            self.appoinmentslData.co_applicant_last_name = self.customerLastName.text ?? ""
            
            
            self.appoinmentslData.co_applicant_email = self.customerEmail.text ?? ""
            self.appoinmentslData.co_applicant_phone = self.customerPhone.text ?? ""
            self.appoinmentslData.co_applicant_secondary_phone = self.customerContactNumberTF.text ?? ""
            
            
            
            AppDelegate.floorLevelData = self.floorLevelData ?? []
            AppDelegate.roomData = self.roomData ?? []
            AppDelegate.appoinmentslData = self.appoinmentslData
            
            //if !(self.appoinmentslData.is_room_measurement_exist ?? false)
            if !(checkIfAtleastOneRoomAddedUnderAppointment(appointmentId: appointmentId))
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
        
        isEditedtextField = false
    }
    
    
    func checkTextFieldEdited()
    {
        customerFirstName.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                    for: .editingChanged)
        customerLastName.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                   for: .editingChanged)
        customerMiddleName.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                     for: .editingChanged)
        zipTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                        for: .editingChanged)
        state_TF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                           for: .editingChanged)
        city_TF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                          for: .editingChanged)
        Street_Address_TF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                    for: .editingChanged)
        customerEmail.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                for: .editingChanged)
        customerPhone.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                for: .editingChanged)
        customerContactNumberTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                          for: .editingChanged)
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField)
    {
        
        isEditedtextField=true
        
    }
    
    @IBAction func addressDidBigen(_ sender: UITextField) {
        self.GMSTag = 0
        googleMapPlaceSearchPopUp()
    }
    
    @IBAction func currentAddress(_ sender: UIButton) {
//        let getaddress = AddressEntryViewController.initialization()!
//        getaddress.delegate = self
//        getaddress.delegateTag = 11
//        getaddress.address = self.address.text ?? ""
//        self.present(getaddress, animated: true, completion: nil)
        self.GMSTag = 0
        googleMapPlaceSearchPopUp()
    }
    func googleMapPlaceSearchPopUp()
    {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    func submitButtonAction()
    {
        
    }
    
    func setPhoneNumberDelegate()
    {
        self.customerPhone.delegate = self
        self.customerContactNumberTF.delegate = self
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil
        {
            if(textField == self.customerPhone || textField == self.customerContactNumberTF)
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
        if customerFirstName.text == ""
        {
            return "Please enter First Name"
        }
        if customerLastName.text == ""
        {
            return "Please enter Last Name"
        }
        if UserDefaults.standard.integer(forKey: "can_view_phone_number") != 0{
            if !(customerContactNumberTF.text?.validatePhone() ?? false)
            {
                return "Please enter a valid Phone Number"
            }
        }
        if !customerEmail.text!.validateEmail()
        {
            return "Please enter a valid Email Address"
        }
        
        
        return ""
        
    }
    
    func submitApi(_ parameter:[String:Any])
    {
        
        
        HttpClientManager.SharedHM.SubmitAppointmentsApi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                self.isSkippbuttonCalled = 0
                self.appoinmentslData.co_applicant_address =  (self.Street_Address_TF.text ?? "")
                self.appoinmentslData.co_applicant_state = (self.state_TF.text ?? "")
                self.appoinmentslData.co_applicant_city =  (self.city_TF.text ?? "")
                self.appoinmentslData.co_applicant_zip = (self.zipTF.text ?? "")
                self.appoinmentslData.co_applicant_first_name = self.customerFirstName.text ?? ""
                self.appoinmentslData.co_applicant_middle_name = self.customerMiddleName.text ?? ""
                self.appoinmentslData.co_applicant_last_name = self.customerLastName.text ?? ""
                
                
                self.appoinmentslData.co_applicant_email = self.customerEmail.text ?? ""
                self.appoinmentslData.co_applicant_phone = self.customerPhone.text ?? ""
                self.appoinmentslData.co_applicant_secondary_phone = self.customerContactNumberTF.text ?? ""
                
                
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
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                          
//                           if(self.isSkippbuttonCalled)
//                                    {
//                                        //self.skipButtonAction(sender: UIButton())
//                                  // self.isSkippbuttonCalled = false
//                                 //  self.submitAndTransforButtonAction(sender: UIButton())
//
//                                    }
//                                   else
//                                     {
//                                      //  self.isSkippbuttonCalled = true
//                                      //  self.submitAndTransforButtonAction(sender: UIButton())
//
                                    // }
                    self.isEditedtextField = true
                    self.submitAndTransforButtonAction(sender: UIButton())
                                   
                                }
                                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                
                                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
               // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePicker = CaptureImage(presentationController: self, delegate: self)
            self.imagePicker.present(from: sender)
            
        }
        
        func imageUploadScreenShot(_ image:UIImage,_ name:String )
        {
            HttpClientManager.SharedHM.AttachmentScreenShotsFn(image, name) { (success, message, value) in
                if(success ?? "") == "Success"
                {
                  
                    
                    self.alert(message ?? "", nil)
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
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.imageUploadScreenShot(image,name)
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    
                    // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
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
    
    func DidAddressSelectPlaceEntryDelegate(title: String, mapItem: GMSPlace?, tag: Int) {
        if(tag == 0)
        {
            if let mapPlace = mapItem
            {
                for component in mapPlace.addressComponents ?? []
                {
                    for co in component.types
                    {
                        isEditedtextField=true
                        if(co.lowercased() == "locality")
                        {
                            self.city_TF.text = component.name
                        }
                        else if(co.lowercased() == "postal_code")
                        {
                            self.zipTF.text = component.name
                        }
                        else if(co.lowercased() == "administrative_area_level_1")
                        {
                            self.state_TF.text = component.shortName
                        }
                        else if(co.lowercased() == "route")
                        {
                            self.Street_Address_TF.text = component.name
                        }
                    }
                }
                
                //self.Street_Address_TF.text = title
                
            }
        }
        
    }
    
}

extension CustomerDetailsTowViewController: GMSAutocompleteViewControllerDelegate
{
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        
        self.DidAddressSelectPlaceEntryDelegate(title: place.name ?? "", mapItem: place, tag: GMSTag)
        
        self.dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        //        print("Error: \(error.description)")
        self.dismiss(animated: true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
extension CustomerDetailsTowViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?,imageName:String?)
    {
        guard let image = image
                
        else
        {
            return
        }
        let imageNameStr = Date().toString()
        let name = "Snapshot" + String(imageNameStr) + ".JPG"
        let snapShotImageName = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: image, saveImgName: name)
        let appointmentId = AppointmentData().appointment_id ?? 0
        _ = self.saveSnapshotImage(savedImageName: snapShotImageName, appointmentId: appointmentId)
        //self.imageUploadScreenShot(image,imageName ?? name)
        
    }
}
