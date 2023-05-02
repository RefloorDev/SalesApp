//
//  CustomerDetailsOneViewController.swift
//  Refloor
//
//  Created by sbek on 21/10/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import PhotosUI
import MobileCoreServices

class CustomerDetailsOneViewController:  UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
   
    
    static func initialization() -> CustomerDetailsOneViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerDetailsOneViewController") as? CustomerDetailsOneViewController
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
    @IBOutlet weak var customerContactNumberTF: UITextField!
    @IBOutlet weak var customerPhoneStackView: UIStackView!
    @IBOutlet weak var customerContactNumberStackView: UIStackView!
    
    @IBOutlet weak var customerContactNumberHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerContactNumbertopConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerContactNumberbottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customerPhoneHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerPhoneNumbertopConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerPhoneNumberbottomConstraint: NSLayoutConstraint!
    
    var roomData:[RoomDataValue]?
    var floorShapeData:[FloorShapeDataValue]?
    var floorLevelData:[FloorLevelDataValue]?
    var appoinmentslData:AppoinmentDataValue!
    var isEditedtextField = false
    var GMSTag = 0
  
    
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
        }
        else{
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
        NetworkMonitor.shared.startMonitoring()
        NetworkMonitor.shared.getConnectionType()
        AppDelegate.appoinmentslData = self.appoinmentslData
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setNavigationBarbackAndlogo(with: "Customer 1 Details")
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
        
        self.customerFirstName.text = ((self.appoinmentslData?.applicant_first_name ?? "") == "") ? (self.appoinmentslData.customer_name ?? "") : (self.appoinmentslData?.applicant_first_name ?? "")
        self.customerMiddleName.text = self.appoinmentslData.applicant_middle_name ?? ""
        self.customerLastName.text = self.appoinmentslData.applicant_last_name
        
        self.customerContactNumberTF.text = self.appoinmentslData.phone
        
        
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
        self.customerEmail.text = appoinmentslData.email ?? ""
        self.customerPhone.text = self.appoinmentslData.mobile ?? ""
        self.customerContactNumberTF.text =  self.appoinmentslData.phone ?? ""
        
        self.checkTextFieldEdited()
        
        
        setPhoneNumberDelegate()
        //         self.customerAddressTF.isUserInteractionEnabled = false
        //         self.customerContactNumberTF.isUserInteractionEnabled = false
        //         self.customerSpouseNameTF.isUserInteractionEnabled = false
        //         self.customerNameTF.isUserInteractionEnabled = false
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
//     @objc override func OrderstatusBarButtonAction()
//    {
//        //        if AppDelegate.appoinmentslData.id != nil
//        //        {
//        let order  = OrderStatusViewController.initialization()!
//        order.delegate = self
//        let masterData = self.getMasterDataFromDB()
//        let appointmentResults = masterData.appointmentResults
//
//        order.appointmentResults =
//        self.present(order, animated: true, completion: nil)
//        //}
//        //        else
//        //        {
//        //            self.alert("No record available", nil)
//        //        }
//    }
    @IBAction func submitAndTransforButtonAction(_ sender: Any) {
        
        if(validation() != "")
        {
            self.alert(validation(), nil)
            return
        }
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "Customer1"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        
        self.appoinmentslData.mobile = (self.customerPhone.text ?? "")
        self.appoinmentslData.customer_name = (self.customerFirstName.text ?? "")
        self.appoinmentslData.street =  (self.Street_Address_TF.text ?? "")
        self.appoinmentslData.state_code = (self.state_TF.text ?? "")
        self.appoinmentslData.city =  (self.city_TF.text ?? "")
        self.appoinmentslData.zip = (self.zipTF.text ?? "")
        self.appoinmentslData.applicant_first_name = self.customerFirstName.text ?? ""
        self.appoinmentslData.applicant_middle_name = self.customerMiddleName.text ?? ""
        self.appoinmentslData.email = self.customerEmail.text ?? ""
        self.appoinmentslData.phone = self.customerContactNumberTF.text ?? ""
        self.appoinmentslData.applicant_last_name = self.customerLastName.text ?? ""
        //arb
        let applicantOneDetails:[String:Any] = ["id":appointmentId,"mobile":self.appoinmentslData.mobile!,"customer_name":self.appoinmentslData.customer_name!,"street":self.appoinmentslData.street!,"state_code":self.appoinmentslData.state_code!,"city":self.appoinmentslData.city!,"zip":self.appoinmentslData.zip!,"applicant_first_name":self.appoinmentslData.applicant_first_name!,"applicant_middle_name":self.appoinmentslData.applicant_middle_name!,"email":self.appoinmentslData.email!,"phone":self.appoinmentslData.phone!,"applicant_last_name":self.appoinmentslData.applicant_last_name!]

        self.updateAppointmentData(appointmentChangesDict: applicantOneDetails)
        let details = CustomerDetailsTowViewController.initialization()!
        details.floorLevelData = self.floorLevelData
        details.floorShapeData = self.floorShapeData
        details.roomData = self.roomData
        details.appoinmentslData = self.appoinmentslData
        details.isEditedtextField = isEditedtextField
        self.navigationController?.pushViewController(details, animated: true)
        
        
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
    
    func setPhoneNumberDelegate()
    {
        self.customerPhone.delegate = self
        self.customerContactNumberTF.delegate = self
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.textInputMode?.primaryLanguage == "emoji") {
            return false
        }
        //let specialCharString = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢")
        if string.rangeOfCharacter(from: Validation.specialCharString) != nil && textField != self.customerEmail {
            return false
        }
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
        }
        return true
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        isEditedtextField=true
        
    }
    
    func submitApi(_ parameter:[String:Any])
    {
        //        if(validation() != "")
        //           {
        //               self.alert(validation(), nil)
        //               return
        //           }
        
        HttpClientManager.SharedHM.SubmitAppointmentsApi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                
                self.appoinmentslData.co_applicant_first_name = self.customerFirstName.text ?? ""
                self.appoinmentslData.co_applicant_middle_name = self.customerMiddleName.text ?? ""
                self.appoinmentslData.co_applicant_email = self.customerEmail.text ?? ""
                self.appoinmentslData.co_applicant_phone = self.customerContactNumberTF.text ?? ""
                self.appoinmentslData.co_applicant_last_name = self.customerLastName.text ?? ""
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

extension CustomerDetailsOneViewController: GMSAutocompleteViewControllerDelegate
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

extension CustomerDetailsOneViewController: ImagePickerDelegate {

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


