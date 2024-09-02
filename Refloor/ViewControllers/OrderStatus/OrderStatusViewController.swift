//
//  OrderStatusViewController.swift
//  Refloor
//
//  Created by sbek on 10/12/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift
import JWTCodable
import CryptoKit
import CommonCrypto

protocol OrderStatusViewDelegate {
    func OrderStatusViewDelegateResult()
}

class OrderStatusViewController: UIViewController,DropDownDelegate,UITextViewDelegate
{
    
    static public func initialization() -> OrderStatusViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "OrderStatusViewController") as? OrderStatusViewController
    }
    let activity = HttpClientManager.init()
    var StatusArray = [String]()
    var theApiValue:OrderStatusDataMap?
    var tempstatusList:[OrderStatusData] = []
    var aptResultList:[AppointmentResultData] = []
    var appoinmentslData:AppoinmentDataValue!
    var delegate:OrderStatusViewDelegate?
    var isAPIcalled = true
    let placeholderColor = UIColor().colorFromHexString("#A7B0BA")
    let header = JWTHeader(typ: "JWT", alg: .hs256)
    let signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
    @IBOutlet weak var orderstatusLabel: UILabel!
    
    @IBOutlet weak var aptResultDetailsLbl: UILabel!
    @IBOutlet weak var aptResultScrollView: UIScrollView!
    @IBOutlet weak var whtnextButton: UIButton!
    @IBOutlet weak var whthpndButton: UIButton!
    @IBOutlet weak var priceQuoted: UIButton!
    @IBOutlet weak var whatsnxterrorLabel: UILabel!
    @IBOutlet weak var whathpnderrorLabel: UILabel!
    @IBOutlet weak var lastPricerrorLabel: UILabel!
    @IBOutlet weak var whatsnewTextView: UITextView!
    @IBOutlet weak var whthpndTextView: UITextView!
    @IBOutlet weak var priceQuotedTextView: UITextView!
    var imagesArray: [[String:Any]] = []
    var selectedAptResultReasonId:Int = Int()
    var appointmentResults = List<rf_master_appointments_results_demoedNotDemoed>()
    var appointDetailsResults:List<rf_appointment_result_reasons_results>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aptResultScrollView.isDirectionalLockEnabled = true
        priceQuotedTextView.delegate = self
        //  self.setNavigationBarbackAndlogo(with: "Customer 1 Details")
        whatsnewTextView.text = "Enter here"
        whatsnewTextView.textColor = placeholderColor
        whthpndTextView.text = "Enter here"
        whthpndTextView.textColor = placeholderColor 
        priceQuotedTextView.text = "Enter here"
        priceQuotedTextView.textColor = placeholderColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        if orderstatusLabel.text=="Select Result" || aptResultDetailsLbl.text == "Select Result Details"{
            whthpndTextView.isUserInteractionEnabled=false
            whatsnewTextView.isUserInteractionEnabled=false
            priceQuotedTextView.isUserInteractionEnabled=false
        }else{
            whthpndTextView.isUserInteractionEnabled=true
            whatsnewTextView.isUserInteractionEnabled=true
            priceQuotedTextView.isUserInteractionEnabled=true
        }
        
        whatsnewTextView.leftSpace()
        whthpndTextView.leftSpace()
        priceQuotedTextView.leftSpace()
        //self.activity.showhideHUD(viewtype: .SHOW, title: "")
//        let masterData = self.getMasterDataFromDB()
//        appointmentResults = masterData.appointmentResults
        for appointmentResult in appointmentResults{
            self.tempstatusList.append(OrderStatusData(appointmentResult: appointmentResult))
        }
        appointDetailsResults = self.getAptResultReason()
        for aptResultReason in appointDetailsResults
        {
            self.aptResultList.append(AppointmentResultData(appointmentResultData: aptResultReason))
        }
        //OrderStatustLisApiCall()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Check if the textView being edited is priceQuotedTextView
        if let priceTextView = priceQuotedTextView, textView == priceTextView {
            // Get the current text in the textView
            var currentText = textView.text ?? ""
            
            // Concatenate the new text with the current text
            currentText = (currentText as NSString).replacingCharacters(in: range, with: text)
            
            // Remove non-numeric characters, except for the decimal point, and the "$" symbol
            var digits = currentText.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
            
            // Ensure that the text does not exceed 12 characters
            if digits.count > 12 {
                return false
            }
            
            // Split the text into integer and fractional parts
            let parts = digits.components(separatedBy: ".")
            var formattedText = ""
            
            // Format the integer part with commas
            if let integerPart = parts.first {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                if let number = formatter.number(from: integerPart) {
                    formattedText += formatter.string(from: number) ?? ""
                }
            }
            
            // Add the decimal point if it exists
            if parts.count > 1 {
                formattedText += "."
                // Ensure that only digits are displayed after the decimal point
                if parts.count > 1 {
                    let fractionalPart = parts[1].filter({ $0.isNumber })
                    formattedText += fractionalPart
                }
            }
            
            // Prepend "$" to the formatted text if it's not empty
            if !formattedText.isEmpty {
                formattedText = "$" + formattedText
            }
            
            // Set the formatted text to the textView
            textView.text = formattedText
            
            // Return false to prevent the default behavior of the text view
            return false
        } else {
            // Check for other text views and restrict characters
            let restrictedCharacters = CharacterSet(charactersIn: "&$+/,:;=?@#<>")
            
            // Iterate over the Unicode.Scalar values in the replacement text
            for scalar in text.unicodeScalars {
                if restrictedCharacters.contains(scalar) {
                    return false // Block the character
                }
            }
            return true // Allow the character
        }
    }

//    // Q4_Change Textfield_Validation
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//           let restrictedCharacters = CharacterSet(charactersIn: "&$+/,:;=?@#")
//           
//           // Iterate over the Unicode.Scalar values in the replacement text
//           for scalar in text.unicodeScalars {
//               if restrictedCharacters.contains(scalar) {
//                   return false // Block the character
//               }
//           }
//           return true // Allow the character
//       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    
    func imageUploadScreenShotOrderStatus(_ image:UIImage,_ name:String )
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
                    
                    self.imageUploadScreenShotOrderStatus(image,name)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    @IBAction func screenShotBarButtonActionOrderStatus()
    {
        // open func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let tempimage = screenshotImage {
                let imageName = Date().toString()
                
                // self.imageUploadScreenShotOrderStatus(tempimage,"Screenshot_\(imageName)")
                //  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
            textView.text = "Enter here"
            textView.textColor = placeholderColor
        }
    }
    
    @IBAction func whthpndButtonAction(_ sender: Any) {
        if orderstatusLabel.text=="Select Result"{
            whthpndTextView.isUserInteractionEnabled=false
            whthpndButton.isHidden=false
            whthpndTextView.borderColor = UIColor().colorFromHexString("#A7B0BA")
            whthpndTextView.borderWidth = 1
            self.alert("Please select appointment result", nil)
            
        }else{
            whthpndTextView.borderColor = UIColor().colorFromHexString("#A7B0BA")
            whthpndTextView.borderWidth = 1
            whthpndTextView.isUserInteractionEnabled=true
            whthpndButton.isHidden=true
            whthpndTextView.text=""
            whthpndTextView.becomeFirstResponder()
            whathpnderrorLabel.isHidden=true
        }
        
    }
    
    @IBAction func whatnextButtonAction(_ sender: Any) {
        if orderstatusLabel.text=="Select Result"{
            
            whatsnewTextView.isUserInteractionEnabled=false
            whtnextButton.isHidden=false
            self.alert("Please select appointment result", nil)
            whatsnewTextView.borderColor = UIColor().colorFromHexString("#A7B0BA")
            whatsnewTextView.borderWidth = 1
        }
        else{
            whatsnewTextView.borderColor = UIColor().colorFromHexString("#A7B0BA")
            whatsnewTextView.borderWidth = 1
            whatsnewTextView.isUserInteractionEnabled=true
            whtnextButton.isHidden=true
            whatsnewTextView.text=""
            whatsnewTextView.becomeFirstResponder()
            whatsnxterrorLabel.isHidden=true
        }
    }
    
    
    @IBAction func priceQuotedButton(_ sender: Any) {

        if orderstatusLabel.text=="Select Result"{
            priceQuotedTextView.isUserInteractionEnabled=false
            priceQuoted.isHidden=false
            self.alert("Please select appointment result", nil)
            priceQuotedTextView.borderColor = UIColor().colorFromHexString("#A7B0BA")
            priceQuotedTextView.borderWidth = 1
        } else{
            priceQuotedTextView.borderColor = UIColor().colorFromHexString("#A7B0BA")
            priceQuotedTextView.borderWidth = 1
            priceQuotedTextView.isUserInteractionEnabled=true
            priceQuoted.isHidden=true
            priceQuotedTextView.text=""
            priceQuotedTextView.becomeFirstResponder()
            lastPricerrorLabel.isHidden=true
        }
    }
    
    @IBAction func dropDownButtonAction(_ sender: UIButton) {
        
        if sender.tag == 0
        {
            var value:[String] = []
            for val in tempstatusList
            {
                value.append(val.statusresult ?? "Unknown")
            }
            
            if(value.count != 0)
            {
                // self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 1, cell: sender.tag)
                self.DropDownDefaultfunction(sender, sender.bounds.width, value, -1, delegate: self, tag: 0)
                //  self.DropDownDefaultfunction(sender, sender.bounds.width, value, -1, delegate: self, tag: 0)
                
                
            }
            else
            {
                self.alert("Appointment Results not available", nil)
            }
        }
        else
        {
            var value:[String] = []
            for val in aptResultList
            {
                value.append(val.reason ?? "Unknown")
            }
            
            if(value.count != 0)
            {
                // self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 1, cell: sender.tag)
                self.DropDownDefaultfunction(sender, sender.bounds.width, value, -1, delegate: self, tag: 1)
                //  self.DropDownDefaultfunction(sender, sender.bounds.width, value, -1, delegate: self, tag: 0)
                
                
            }
            else
            {
                self.alert("Appointment Result Details not available", nil)
            }
        }
        
        
        
        
        // self.DropDownDefaultfunction(sender, sender.bounds.width, ["true","false"], -1, delegate: self, tag: 0)
    }
    @IBAction func cancelbuttonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonACtion(_ sender: Any)
    {
        if  self.orderstatusLabel.text == "Select Result"
        {
            self.alert("Please select appointment result", nil)
            
        }
        else if aptResultDetailsLbl.text == "Select Result Details"
        {
            self.alert("Please select appointment result details", nil)
        }
        else if whthpndTextView.text=="Enter here" && whatsnewTextView.text=="Enter here" && priceQuotedTextView.text=="Enter here"{
            whathpnderrorLabel.isHidden=false
            whatsnxterrorLabel.isHidden=false
            lastPricerrorLabel.isHidden=false
        }
        else if whthpndTextView.text=="" || whthpndTextView.text=="Enter here"{
            whathpnderrorLabel.isHidden=false
            
        }else if whatsnewTextView.text=="" || whatsnewTextView.text=="Enter here"{
            whatsnxterrorLabel.isHidden=false
        }
        else if priceQuotedTextView.text=="" || priceQuotedTextView.text=="Enter here"{
            lastPricerrorLabel.isHidden=false
        }
        else
        {
            whathpnderrorLabel.isHidden = true
            whatsnxterrorLabel.isHidden = true
            lastPricerrorLabel.isHidden = true
            //  self.activity.showhideHUDDark(viewtype: .SHOW, title: "The appointment results are being submitting. Please wait...")
            if(isAPIcalled)
            {
                isAPIcalled = false
//                self.updateOrderStatustLisApiCall(status:self.orderstatusLabel.text ?? "",whatHappendSTring: self.whthpndTextView.text ?? "",whatNextString: self.whatsnewTextView.text ?? "", priceQuotedString: Double(self.priceQuotedTextView.text) ?? 0.0)
                print("The appointment results are being submitting")
            }
            
            //create parameters for api call & save in DB
            let appointmentId = AppointmentData().appointment_id ?? 0
            self.deleteAllAppointmentRequestForThisAppointmentId(appointmentId: appointmentId)
            // change customer data if applicant data is added
            
            //1.
            imagesArray = []
            if checkIfRoomDrawImageExist(appointmentId: appointmentId){ // room image exist
                if self.checkIfPaymentDetailsExistForAppointment(appointmentId: appointmentId){
                    let contactApiData = self.createContractParameters()
                    if let applicantDataDict = contactApiData as? [String:Any]
                    {
                        if  let applicant = applicantDataDict["application_info_secret"] as? String {
                            if applicant == ""
                            {

                            }
                            else
                            {
                                var applicantData:[String:Any] = [:]
                                let customerFullDict = JWTDecoder.shared.decodeDict(jwtToken: applicant)
                                applicantData = (customerFullDict["payload"] as? [String:Any] ?? [:])
                                self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicantData)
                            }
                           // self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicant)
                        }
//                        if  let applicant = applicantDataDict["applicationInfo"] as? [String:Any]{
//                            self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicant)
//                        }
                    }
                    print("TEST-1",contactApiData)
                    var customerAndRoomData =  self.createFinalParameterForCustomerApiCall(data_completed: 0)
                    for (key,value) in contactApiData{
                        customerAndRoomData[key] = value
                    }
//                    let json = (customerAndRoomData as NSDictionary).JsonString()
//                    let data = json.data(using: .utf8)
//                    var jwtToken:String = String()
//
//                    let decoder = JSONDecoder()
//
//                    if let data = data, let model = try? decoder.decode(CustomerEncodingDecodingDetails.self, from: data) {
//                        print(model)
//                        let jwt = JWT<CustomerEncodingDecodingDetails>(header: header, payload: model, signature: signature)
//                        jwtToken = JWTEncoder.shared.encode(jwt: jwt) ?? ""
//                        print(jwtToken)
//                    }
                    //customerAndRoomData = ["data":customerAndRoomData]
                    print("customerAndRoomData2 : ", customerAndRoomData)
                    createAppointmentsRequestDataToDatabase(title: RequestTitle.CustomerAndRoom, url: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParams:customerAndRoomData as NSDictionary, imageName: "")
                    
                    //self.createAppointmentsRequestDataToDatabase(title: RequestTitle.ContactDetails, url: AppURL().syncContactInfo, requestType: RequestType.post, requestParams: contactApiData as NSDictionary, imageName: "")
                    imagesArray = self.allImagesUnderAppointment().filter({$0["image_name"] as! String != ""})
                    var lastImageDict = imagesArray[imagesArray.count-1]
                    lastImageDict["data_completed"] = 1
                    imagesArray[imagesArray.count-1] = lastImageDict
                    for imageDict in imagesArray{
                        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.ImageUpload, url: AppURL().syncImageInfo, requestType: RequestType.formData, requestParams: imageDict as NSDictionary, imageName: imageDict["image_name"] as! String)
                    }
                    
                    let requestParaInitiateSync:[String:Any] = ["appointment_id":appointmentId,"screen_logs":self.getScreenCompletionArrayToSend()]
                    let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
                    self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
                        self.dismiss(animated: true) {
                            self.addStartLog()
                            self.delegate?.OrderStatusViewDelegateResult()
                        }
                }else{ // no room image exist only customer details
                    var customerAndRoomData = self.createFinalParameterForCustomerApiCall(data_completed: 0)
//                    let json = (customerAndRoomData as NSDictionary).JsonString()
//                    let data = json.data(using: .utf8)
//                    var jwtToken:String = String()
//
//                    let decoder = JSONDecoder()
//
//                    if let data = data, let model = try? decoder.decode(CustomerEncodingDecodingDetails.self, from: data) {
//                        print(model)
//                        let jwt = JWT<CustomerEncodingDecodingDetails>(header: header, payload: model, signature: signature)
//                        jwtToken = JWTEncoder.shared.encode(jwt: jwt) ?? ""
//                        print(jwtToken)
//                    }
                    //customerAndRoomData = ["data":customerAndRoomData]
                    print("customerAndRoomData1 : ", customerAndRoomData)
                    createAppointmentsRequestDataToDatabase(title: RequestTitle.CustomerAndRoom, url: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParams: customerAndRoomData as NSDictionary, imageName: "")
                    
                    imagesArray = self.allImagesUnderAppointment().filter({$0["image_name"] as! String != ""})
                    var lastImageDict = imagesArray[imagesArray.count-1]
                    lastImageDict["data_completed"] = 1
                    imagesArray[imagesArray.count-1] = lastImageDict
                    for imageDict in imagesArray{
                        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.ImageUpload, url: AppURL().syncImageInfo, requestType: RequestType.formData, requestParams: imageDict as NSDictionary, imageName: imageDict["image_name"] as! String)
                    }
                    
                    let requestParaInitiateSync:[String:Any] = ["appointment_id":appointmentId,"screen_logs":self.getScreenCompletionArrayToSend()]
                    let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
                    self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")

                        self.dismiss(animated: true)
                    {
                            self.addStartLog()
                            self.delegate?.OrderStatusViewDelegateResult()
                    }
                }
                
                
            }
            else{
                //ie appointment started but no room added
                var customerAndRoomData = self.createFinalParameterForCustomerApiCall(data_completed: 1)
//                let json = (customerAndRoomData as NSDictionary).JsonString()
//                let data = json.data(using: .utf8)
//                var jwtToken:String = String()
//
//                let decoder = JSONDecoder()
//
//                if let data = data, let model = try? decoder.decode(CustomerEncodingDecodingDetails.self, from: data) {
//                    print(model)
//                    let jwt = JWT<CustomerEncodingDecodingDetails>(header: header, payload: model, signature: signature)
//                    jwtToken = JWTEncoder.shared.encode(jwt: jwt) ?? ""
//                    print(jwtToken)
//                }
                //customerAndRoomData = ["data":customerAndRoomData]
                print("customerAndRoomData : ", customerAndRoomData)
                createAppointmentsRequestDataToDatabase(title: RequestTitle.CustomerAndRoom, url: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParams: customerAndRoomData as NSDictionary, imageName: "")
                
                let requestParaInitiateSync:[String:Any] = ["appointment_id":appointmentId,"screen_logs":self.getScreenCompletionArrayToSend()]
                let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
                self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
                /*   if HttpClientManager.SharedHM.connectedToNetwork()
                 {
                 var requestParams = customerAndRoomData
                 requestParams["token"] = UserData.init().token ?? ""
                 self.syncCustomerAndRoomData(parameter: requestParams, appointmentStatus: .startedAppointment)
                 }
                 else
                 {
                 self.showhideHUD(viewtype: .HIDE)*/
                self.dismiss(animated: true)
                {
                    self.addStartLog()
                    self.delegate?.OrderStatusViewDelegateResult()
                    
                }
                
                //  }
                
            }
            
            
        }
        
    }
    
    func addStartLog(){
        let appointmentId = AppointmentData().appointment_id ?? 0
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.appointmentLogStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
    }
    
    
    func syncCustomerAndRoomData(parameter:[String:Any], appointmentStatus: AppointmentStatusEnum){
        let appointmentId = AppointmentData().appointment_id ?? 0
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        //Writing Logs
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.appointmentStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        //
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        var networkMessage = ""
        let speedTest = NetworkSpeedTest()
        speedTest.testUploadSpeed { speed in
            print("Upload speed: \(speed) Mbps")
            networkMessage = String(speed)
            var params = parameter
            params["network_strength"] = networkMessage
        HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(parameter: params, isOnlineCollectBtnPressed: false) { success, message,payment_status,payment_message,transactionId,cardType  in
            if(success ?? "") == "Success"{
                print(message ?? "No msg")
                //Writing Logs
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.CustomerAndRoom)
                switch appointmentStatus {
                case .startedAppointment:
                    //call i360
                    var networkMessage = ""
                    let speedTest = NetworkSpeedTest()
                    speedTest.testUploadSpeed { speed in
                        print("Upload speed: \(speed) Mbps")
                        networkMessage = String(speed)
                        if HttpClientManager.SharedHM.connectedToNetwork(){
                            let requestParams:[String:Any] = ["token" :UserData.init().token ?? "","appointment_id":appointmentId,"network_strength": networkMessage]
                            HttpClientManager.SharedHM.initiateSync_i360_APi(parameter: requestParams) { success, message in
                                if(success ?? "") == "Success"{
                                    self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync)
                                }
                            }
                            
                        }
                    }
                   
                    DispatchQueue.main.async{
                        self.showhideHUD(viewtype: .HIDE)
                        self.dismiss(animated: true) {
                            self.delegate?.OrderStatusViewDelegateResult()
                        }
                    }
                    break
                case .addedRooms:
                    // call image upload
                    if HttpClientManager.SharedHM.connectedToNetwork(){
                        self.syncImages(imageArray: self.imagesArray,appointmentStatus:.addedRooms)
                    }else{
                        self.dismiss(animated: true) {
                            self.delegate?.OrderStatusViewDelegateResult()
                        }
                    }
                    break
                    //                case .paymentAdded:
                    //
                    //                    if HttpClientManager.SharedHM.connectedToNetwork(){
                    //                        var contactApiData = self.createContractParameters()
                    //                        contactApiData["token"] = UserData.init().token ?? ""
                    //                        self.syncContractData(parameter: contactApiData)
                    //                    }else{
                    //                        self.dismiss(animated: true) {
                    //                            self.delegate?.OrderStatusViewDelegateResult()
                    //                        }
                    //                    }
                    //                    break
                }
                
                //
            }else{
                //Writing Logs
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                //Logs
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
                //
                DispatchQueue.main.async{
                    self.showhideHUD(viewtype: .HIDE)
                    let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    self.alert(message ?? "An Error occured", [ok])
                }
            }
        }
    }
    }
    
    func syncImages(imageArray:[[String:Any]], appointmentStatus: AppointmentStatusEnum){
        let group = DispatchGroup()
        for roomImageObj in imageArray{
            let room = roomImageObj
            let appoint_id = String(AppointmentData().appointment_id ?? 0)
            let image_name = room["image_name"] as? String ?? ""
            let image_type = room["image_type"] as? String ?? ""
            let dataCompleted = room["data_completed"] as? Int ?? 0
            //log
            let appoint_Id = (AppointmentData().appointment_id ?? 0)
            self.addImageStatLogs(appointmentId: appoint_Id, imageType: image_type)
            //
            let file = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: image_name) ?? UIImage()
            let room_id = (room["room_id"] as? Int ?? 0)
            let room_name = room["room_name"] as? String ?? ""
            let room_id_str = String(room_id)
            group.enter()
            var networkMessage = ""
            let speedTest = NetworkSpeedTest()
            speedTest.testUploadSpeed { speed in
                print("Upload speed: \(speed) Mbps")
                networkMessage = String(speed)
                HttpClientManager.SharedHM.syncImagesOfAppointment(appointmentId: appoint_id, roomId: room_id_str, attachments: file, imagename: image_name, imageType: image_type, dataCompleted: String(dataCompleted),roomName: room_name, networkMessage: networkMessage) { success, message, imageName in
                    if(success ?? "") == "Success"{
                        group.leave()
                        print(message ?? "No msg")
                        if let imageNam = imageName{
                            let appoint_id = (AppointmentData().appointment_id ?? 0)
                            self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appoint_id, requestTitle: RequestTitle.ImageUpload,imageName: imageNam)
                        }
                    }else{
                        print(message ?? "No msg")
                        group.leave()
                    }
                }
            }

        }
        group.notify(queue: .main) {
            switch appointmentStatus {
            case .addedRooms:
                //call i360
                let appoint_id = (AppointmentData().appointment_id ?? 0)
                var networkMessage = ""
                let speedTest = NetworkSpeedTest()
                speedTest.testUploadSpeed { speed in
                    print("Upload speed: \(speed) Mbps")
                    networkMessage = String(speed)
                    let requestParams:[String:Any] = ["token" :UserData.init().token ?? "","appointment_id":appoint_id,"network_strength": networkMessage]
                    HttpClientManager.SharedHM.initiateSync_i360_APi(parameter: requestParams) { success, message in
                    }
                }
               
                
                DispatchQueue.main.async{
                    self.showhideHUD(viewtype: .HIDE)
                    self.dismiss(animated: true) {
                        self.delegate?.OrderStatusViewDelegateResult()
                    }
                }
                break
//            case .paymentAdded:
//                if HttpClientManager.SharedHM.connectedToNetwork(){
//                    let appointmentId = (AppointmentData().appointment_id ?? 0)
//                    let requestParams:[String:Any] = ["token" :UserData.init().token ?? "","appointment_id":appointmentId]
//                    HttpClientManager.SharedHM.initiateSync_i360_APi(parameter: requestParams) { success, message in
//                        if(success ?? "") == "Success"{
//                            self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync)
//                        }
//                    }
//
//                }
//                DispatchQueue.main.async{
//                    self.showhideHUD(viewtype: .HIDE)
//                    self.dismiss(animated: true) {
//                        self.delegate?.OrderStatusViewDelegateResult()
//                    }
//                }
            default:
                break
            }
        }
    }
    
//    func syncContractData(parameter:[String:Any]){
//        let appointmentId = AppointmentData().appointment_id ?? 0
//        let appointment = self.getAppointmentData(appointmentId: appointmentId)
//        let firstName = appointment?.applicant_first_name ?? ""
//        let lastName = appointment?.applicant_last_name ?? ""
//        let name = lastName == ""  ? firstName : firstName + " " + lastName
//        let date = appointment?.appointment_datetime ?? ""
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        //
//        HttpClientManager.SharedHM.updateContractInfoAPi(parameter: parameter) { success, message in
//            if(success ?? "") == "Success"{
//                print(message ?? "No msg")
//                //Logs
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                //
//                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.ContactDetails)
//
//                ///
//                if HttpClientManager.SharedHM.connectedToNetwork(){
//                    self.syncImages(imageArray: self.imagesArray,appointmentStatus:.paymentAdded)
//                }else{
//                    self.dismiss(animated: true) {
//                        self.delegate?.OrderStatusViewDelegateResult()
//                    }
//                }
//
//
//            }else{
//                //Logs
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                DispatchQueue.main.async{
//                    self.showhideHUD(viewtype: .HIDE)
//                    let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
//                    self.alert(message ?? "An Error occured", [ok])
//                }
//            }
//        }
//    }
    
    //contract
    func createContractParameters() -> [String:Any] {
        let paymentDetails = self.getPaymentDetailsDataFromAppointmentDetail()
        print(paymentDetails)
        let paymentType = self.getPaymentMethodTypeFromAppointmentDetail()
        print(paymentType)
        let paymentTypeSecret = createJWTToken(parameter: paymentType)
        
        let applicantDta = self.getApplicantAndIncomeDataFromAppointmentDetail()
        print(applicantDta)
        var applicantInfoSecret:String = String()
        if applicantDta.count > 0
        {
            applicantInfoSecret = createJWTTokenApplicantInfo(parameter: applicantDta["data"] as! [String : Any])
        }
        //let contactInfo = self.getContractDataOfAppointment()
        //print(contactInfo)
        var contractDict: [String:Any] = [:]
        contractDict["paymentdetails"] = paymentDetails
        contractDict["payment_method_secret"] = paymentTypeSecret//paymentType//
        contractDict["application_info_secret"] = applicantInfoSecret//applicantDta["data"]//applicantInfoSecret
        //contractDict["contractInfo"] = contactInfo
        //contractDict["data_completed"] = 0
        //contractDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        //let contractDataDict: [String:Any] = ["data":contractDict]
        //print(contractDataDict)
        return contractDict //contractDataDict
    }
    
    func createAppointmentsRequestDataToDatabase(title:RequestTitle,url:String,requestType:RequestType,requestParams:NSDictionary,imageName:String){
       
            self.createAppointmentRequest(requestTitle: title, requestUrl: url, requestType: requestType, requestParameter: requestParams, imageName: imageName)
        print("createAppointmentsRequestDataToDatabase_requestParameter : ", requestParams)
    }
    
    func createRoomParameters() -> [[String:Any]]{
        return self.getRoomArrayForApiCall()
    }
    
    func createQuestionAnswerForAllRoomsParameter() -> [[String:Any]]{
        return self.getQuestionAnswerArrayForApiCall()
    }
    
    func createCustomerParameter() -> [String:Any]{
        let priceTextWithoutCommas = self.priceQuotedTextView.text?.replacingOccurrences(of: ",", with: "")
        // print("Price Text Without Commas:", priceTextWithoutCommas)
          // Remove the "$" symbol if present
          let priceTextWithoutSymbol = priceTextWithoutCommas?.replacingOccurrences(of: "$", with: "")
//        let priceTextWithoutSymbol = self.priceQuotedTextView.text?.replacingOccurrences(of: "$", with: "")
        print("Price Text Without Symbol:", priceTextWithoutSymbol)
        var customerDict = self.getCustomerDetailsForApiCall()
        customerDict["appointment_result"] = self.orderstatusLabel.text ?? ""
        let (date,timeZone) = Date().getCompletedDateStringAndTimeZone()
        customerDict["completed_date"] = date
        customerDict["timezone"] = timeZone
        customerDict["what_happened_notes"] = self.whthpndTextView.text ?? ""
        customerDict["whats_next_notes"] = self.whatsnewTextView.text ?? ""
        customerDict["last_price_quoted_value"] = Double(priceTextWithoutSymbol ?? "")
        customerDict["resulting_reason_id"] = self.selectedAptResultReasonId
        return customerDict
    }
    
    func createFinalParameterForCustomerApiCall(data_completed:Int) -> [String:Any]{
        var customerDict: [String:Any] = [:]
        customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        customerDict["data_completed"] = data_completed
        customerDict["customer"] = createCustomerParameter()
        customerDict["rooms"] = createRoomParameters()
        customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
        customerDict["operation_mode"] = "offline"
        customerDict["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return customerDict
    }
    
    
    func getAllRoomsFromAppointment() -> [[String:Any]] {
        let drawImageArray = createRoomDrawImageParameter()
        print(drawImageArray)
        let roomImageArray = createRoomImagesParameter()
        print(roomImageArray)
        let applicantSignatureAndInitialsArray = createApplicantSignatureParameter()
        print(applicantSignatureAndInitialsArray)
        let coApplicantSignatureAndInitialsArray = createCoApplicantSignatureParameter()
        print(coApplicantSignatureAndInitialsArray)
        let snapshotArray = createSnapshotImageParameter()
        let totalImagesUnderAppointment:[[String:Any]] =  applicantSignatureAndInitialsArray + coApplicantSignatureAndInitialsArray + drawImageArray + roomImageArray + snapshotArray
        print(totalImagesUnderAppointment)
        return totalImagesUnderAppointment
    }
    
    func allImagesUnderAppointment() -> [[String:Any]] {
        let drawImageArray = createRoomDrawImageParameter()
        print(drawImageArray)
        let roomImageArray = createRoomImagesParameter()
        print(roomImageArray)
        let applicantSignatureAndInitialsArray = createApplicantSignatureParameter()
        print(applicantSignatureAndInitialsArray)
        let coApplicantSignatureAndInitialsArray = createCoApplicantSignatureParameter()
        print(coApplicantSignatureAndInitialsArray)
        let snapshotArray = createSnapshotImageParameter()
        let totalImagesUnderAppointment:[[String:Any]] =  applicantSignatureAndInitialsArray + coApplicantSignatureAndInitialsArray + drawImageArray + roomImageArray + snapshotArray
        print(totalImagesUnderAppointment)
        return totalImagesUnderAppointment
    }
    
    func createRoomDrawImageParameter() -> [[String:Any]]{
        return self.getRoomDrawingForApiCall()
    }
    
    func createRoomImagesParameter() -> [[String:Any]]{
        return self.getRoomImagesForApiCall()
    }
    
    func createApplicantSignatureParameter() -> [[String:Any]]{
        return self.getApplicantSignatureForApiCall()
    }
    
    func createCoApplicantSignatureParameter() -> [[String:Any]]{
        return getCoApplicantSignatureForApiCall()
    }
    func createSnapshotImageParameter() -> [[String:Any]]{
        return self.getSnapShotImagesForApiCall()
    }
    
    
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        if tag == 0
        {
            self.orderstatusLabel.text = item
            self.orderstatusLabel.textColor = .white
        }
        else
        {
            let selectedAptResultReasonArray = appointDetailsResults.filter({$0.reason == item})
            selectedAptResultReasonId = selectedAptResultReasonArray.first?.reasonId ?? 0
            self.aptResultDetailsLbl.text = item
            self.aptResultDetailsLbl.textColor = .white
        }
    }
    
    func addImageStatLogs(appointmentId: Int, imageType:String){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        switch imageType {
        case "measurement_image":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "room_photo":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "protrusion_image":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "applicant_signature":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.signatureSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "applicant_initial":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.initialsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "snapshot":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.snapshotDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        default:
            break
        }
    }
    
    func addImageCompleteLogs(appointmentId: Int){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.signatureSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.initialsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.snapshotDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
    }
    
    func addImageFailLogs(appointmentId: Int,errorMessage:String){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.signatureSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.initialsSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.snapshotDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func OrderStatustLisApiCall()
    {
        HttpClientManager.SharedHM.OrderStatustListApi { (result, message, value) in
            if (result ?? "") == "Success"
            {
                self.theApiValue = value
                if( self.theApiValue != nil)
                {
                    self.tempstatusList = (self.theApiValue?.orderStatus_list_data)!
                    
                    self.activity.showhideHUD(viewtype: .HIDE, title: "")
                }
                
                
            }
            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message ?? value?.message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.OrderStatustLisApiCall()
                }
                //   let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                    self.activity.showhideHUD(viewtype: .HIDE, title: "")
                })
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached , nil)
            }
            
            
        }
    }
    
    func updateOrderStatustLisApiCall(status:String,whatHappendSTring:String,whatNextString:String,priceQuotedString:Double)
    {
        
        // let parameter = ["token":UserData.init().token ?? "","appointment_id":AppDelegate.appoinmentslData.id ?? 0] as [String : Any]
        var networkMessage = ""
        let speedTest = NetworkSpeedTest()
        speedTest.testUploadSpeed { speed in
            print("Upload speed: \(speed) Mbps")
            networkMessage = String(speed)
            let parameter =  ["token":UserData.init().token ?? "","result":status ,"appointment_id":AppDelegate.appoinmentslData.id ?? 0,"what_happened_notes":whatHappendSTring,"whats_next_notes":whatNextString, "last_price_quoted_value": Double(priceQuotedString) ?? 0.0,"network_strength":networkMessage] as [String : Any]
            print("parameter_what_happened_notes1 : ", parameter)
            HttpClientManager.SharedHM.submitOrderStatustListApi(parameter: parameter) { (success, message) in
                if(success ?? "").lowercased() == "success" || (success ?? "").lowercased() == "true"
                {
                    self.isAPIcalled = true
                    HttpClientManager.SharedHM.submitOrderStatustUploadData(parameter: parameter) {_,_ in
                        print("parameter_what_happened_notes : ", parameter)
                    }
                    
                    self.activity.showhideHUD(viewtype: .HIDE, title: "")
                    self.dismiss(animated: true) {
                        self.delegate?.OrderStatusViewDelegateResult()
                    }
                    
                }
                
                else
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        self.isAPIcalled = true
                        self.updateOrderStatustLisApiCall(status: self.orderstatusLabel.text ?? "",whatHappendSTring: self.whthpndTextView.text ?? "",whatNextString: self.whatsnewTextView.text ?? "", priceQuotedString: Double(self.priceQuotedTextView.text) ?? 0.0)
                        print("")
                    }
                    //let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        
                        self.activity.showhideHUD(viewtype: .HIDE, title: "")
                    })
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
                }
            }
        }
  
    }
    func showhideHUD(viewtype: SHOWHIDEHUD,title: String = "")
    {
        
        switch viewtype {
        case .SHOW:
            CAXSVProgressHUD.sharedInstance.titleLbl.text = title
            CAXSVProgressHUD.sharedInstance.titleLbl.textColor = .black
            
            CAXSVProgressHUD.show()
        case .HIDE:
            CAXSVProgressHUD.sharedInstance.titleLbl.text = ""
            CAXSVProgressHUD.dismiss()
        }
    }
    
}
extension UITextView {
    func leftSpace() {
        self.textContainerInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 20)
    }
}

enum AppointmentStatusEnum{
    case startedAppointment
    case addedRooms
    //case paymentAdded
}
