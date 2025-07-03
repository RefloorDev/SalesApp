//
//  DestinationMotivationViewController.swift
//  Refloor
//
//  Created by Bincy C A on 10/06/25.
//  Copyright © 2025 oneteamus. All rights reserved.
//

import UIKit
import JWTCodable
@MainActor
class DestinationMotivationViewController: UIViewController, DropDownDelegate {
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        DispatchQueue.main.async {  // ✅ Guarantees main thread execution
            self.cancelRadioBtnBool = true
            self.setDefaultRadioBtn()
            self.selectDestinationCenterView.isHidden = true
            
            // AutoLayout constraint changes
            self.scrollViewHeightConstraint.constant = 1400
            self.radioSumitLablViewHeightConstraint.constant = 145
            
            let height = self.calculateLabelHeight(
                text: self.destinationTermsCondition[index],
                font: UIFont(name: "Avenir-Book", size: 21)!,
                width: self.termsAndConditionView.frame.width
            )
            self.termsViewHeightConstraint.constant = height + 200
            
            // UI updates
            self.selectDestinationLbl.isHidden = false
            self.dropDownView.isHidden = false
            self.termsAndConditionView.isHidden = false
            self.radioSumitView.isHidden = false
            self.dropDownLbl.text = self.destinationDropDownValues[index]
            self.radioLabl.text = self.masterData.destinationSelectionConsentMesage
            self.terms_conditionLbl.text = self.destinationTermsCondition[index]
            self.termsndConditionHeadingLbl.text = "TERMS & CONDITIONS"
            
            // Optional: If layout changes need immediate effect
            self.view.layoutIfNeeded()
        }
        
        // Non-UI operation can stay outside
        self.destinationSelectionId = self.destinationSelectionIdArray[index]
    }
    
    
    static func initialization() -> DestinationMotivationViewController?
    {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "DestinationMotivationViewController") as? DestinationMotivationViewController
    }
    
    
    
    
    @IBOutlet weak var selectDestinationCenterView: UIView!
    @IBOutlet weak var termsndConditionHeadingLbl: UILabel!
    @IBOutlet weak var selectDestinationLbl: UILabel!
    @IBOutlet weak var termsAndConditionView: UIView!
    @IBOutlet weak var radioSumitView: UIView!
    @IBOutlet weak var radioBtn: UIButton!
    @IBOutlet weak var radioLabl: UILabel!
    @IBOutlet weak var terms_conditionLbl: UILabel!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var termsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownLbl: UILabel!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var radioSumitLablViewHeightConstraint: NSLayoutConstraint!
    var destinationDropDownValues:[String] = []
    var destinationTermsCondition:[String] = []
    var destinationSelectionIdArray:[Int] = []
    var cancelRadioBtnBool:Bool = false
    var name:String = String()
    var parametersAdditionalComments:[String:Any] = [:]
    var destinationSelectionId:Int = Int()
    var isCardVerified:Bool = Bool()
    var payment_TrasnsactionDict:[String:String] = [:]
    
    var masterData = MasterData()
    override func viewDidLoad() {
        super.viewDidLoad()
        masterData = getMasterDataFromDB()
        dropDownLbl.text = "Select"
        //terms_conditionLbl.text = ""
        //radioLabl.text = ""
        //termsndConditionHeadingLbl.text = ""
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.destinationNavBar(with: "DESTINATION MOTIVATION")
        let destinationSelectionList = masterData.destination_selection_list
        
        if destinationSelectionList.count > 0
        {
            for destinationValues in destinationSelectionList
            {
                destinationDropDownValues.append(destinationValues.name!)
                destinationTermsCondition.append(destinationValues.terms_conditions!)
                destinationSelectionIdArray.append(destinationValues.destinationId)
                
            }
            //destinationSelectionId = destinationSelectionIdArray[0]
            dropDownLbl.text = destinationDropDownValues[0]
            radioLabl.text = masterData.destinationSelectionConsentMesage
            terms_conditionLbl.text = destinationTermsCondition[0]
            
        }
        
        scrollViewHeightConstraint.constant = 400
        radioSumitLablViewHeightConstraint.constant = 0
        termsViewHeightConstraint.constant = 320
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    func calculateLabelHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        let boundingBox = NSString(string: text).boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        return ceil(boundingBox.height)
    }
    
    
    @IBAction func ropDownBtnAction(_ sender: UIButton)
    {
        self.DropDownDefaultfunction(sender, sender.bounds.width, destinationDropDownValues, -1, delegate: self, tag: sender.tag)
    }
    
    @IBAction func radioBtnAction(_ sender: UIButton)
    {
        
        if !cancelRadioBtnBool
        {
            cancelRadioBtnBool = !cancelRadioBtnBool
            radioBtn.setImage(UIImage(named: "selectedRound"), for: .normal)
            nextBtn.isUserInteractionEnabled = true
            nextBtn.backgroundColor = UIColor().colorFromHexString("#292562")
            nextBtn.borderColor = UIColor().colorFromHexString("#A7B0BA")
            nextBtn.borderWidth = 1
            nextBtn.setTitleColor(.white, for: .normal)
        }
        else
        
        {
            //#586471
            cancelRadioBtnBool = !cancelRadioBtnBool
            nextBtn.backgroundColor = UIColor().colorFromHexString("#586471")
            nextBtn.borderColor = .clear
            nextBtn.borderWidth = 0
            nextBtn.isUserInteractionEnabled = false
            radioBtn.setImage(UIImage(named: ""), for: .normal)
            
            nextBtn.setTitleColor(UIColor().colorFromHexString("#252C35"), for: .normal)
        }
    }
    
    func setDefaultRadioBtn()
    {
        if !cancelRadioBtnBool
        {
            cancelRadioBtnBool = !cancelRadioBtnBool
            radioBtn.setImage(UIImage(named: "selectedRound"), for: .normal)
            nextBtn.isUserInteractionEnabled = true
            nextBtn.backgroundColor = UIColor().colorFromHexString("#292562")
            nextBtn.borderColor = UIColor().colorFromHexString("#A7B0BA")
            nextBtn.borderWidth = 1
            nextBtn.setTitleColor(.white, for: .normal)
        }
        else
        
        {
            //#586471
            cancelRadioBtnBool = !cancelRadioBtnBool
            nextBtn.backgroundColor = UIColor().colorFromHexString("#586471")
            nextBtn.borderColor = .clear
            nextBtn.borderWidth = 0
            nextBtn.isUserInteractionEnabled = false
            radioBtn.setImage(UIImage(named: ""), for: .normal)
            
            nextBtn.setTitleColor(UIColor().colorFromHexString("#252C35"), for: .normal)
        }
    }
    @IBAction func nextBtnAction(_ sender: UIButton)
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "DestinationMotivation"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            
            if !isCardVerified
            {
                HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Creating sale order...")
                var networkMessage = ""
                let speedTest = NetworkSpeedTest()
                speedTest.testUploadSpeed { speed in
                    print("Upload speed: \(speed) Mbps")
                    DispatchQueue.main.async {
                        networkMessage = String(format: "%.2f", speed)
                        networkMessage += "Mbps"
                        self.createCustomerAPiCall(networkMessage: networkMessage,appointmentId:appointmentId)
                    }
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    
                    HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Submitting additional data..")
                    
                    
                    var networkMessage = ""
                    let speedTest = NetworkSpeedTest()
                    speedTest.testUploadSpeed { speed in
                        print("Upload speed: \(speed) Mbps")
                        DispatchQueue.main.async {
                            networkMessage = String(format: "%.2f", speed)
                            networkMessage += "Mbps"
                            self.parametersAdditionalComments["network_strength"] = networkMessage
                            self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
                            self.additionalCommentsApiCall(networkMessage: networkMessage)
                        }
                    }
                    
                }
            }
        }
        
        
//        if HttpClientManager.SharedHM.connectedToNetwork()
//        {
//            
//            
//            DispatchQueue.main.async
//            {
//                
//                HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Submitting additional data..")
//                
//                
//                var networkMessage = ""
//                let speedTest = NetworkSpeedTest()
//                speedTest.testUploadSpeed { speed in
//                    print("Upload speed: \(speed) Mbps")
//                    DispatchQueue.main.async {
//                        networkMessage = String(format: "%.2f", speed)
//                        networkMessage += "Mbps"
//                        self.parametersAdditionalComments["network_strength"] = networkMessage
//                        self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
//                        self.additionalCommentsApiCall(networkMessage: networkMessage)
//                    }
//                }
//                
//            }
//            
//        }
        else
        {
            offlineParameterCreation()
//            let appoint_id = String(AppointmentData().appointment_id ?? 0)
//            self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
//            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.GenerateContract, url: AppURL().syncGenerateContractDocumentInServer, requestType: RequestType.post, requestParams: self.parametersAdditionalComments as NSDictionary, imageName: "")
//            
//            let requestParaInitiateSync:[String:Any] = ["appointment_id":appoint_id,"screen_logs":self.getScreenCompletionArrayToSend()]
//            let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
//            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
//            DispatchQueue.main.async
//            {
//                
//                self.navigationController?.popToRootViewController(animated: true)
//            }
        }
    }
    func offlineParameterCreation()
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
        if !isCardVerified
        {
            
            let contactApiData = self.createContractParameters()
            if let applicantDataDict = contactApiData as? [String:Any]
            {
                if  let applicant = applicantDataDict["application_info_secret"] as? String{
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
                }
                
            }
            
            
            var customerAndRoomData = self.createFinalParameterForCustomerOfflineApiCall()
            for (key,value) in contactApiData
            {
                customerAndRoomData[key] = value
            }
            if payment_TrasnsactionDict != [:]
            {
                customerAndRoomData["payment_transaction_info"] = self.payment_TrasnsactionDict
            }
            
            
            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.CustomerAndRoom, url: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParams: customerAndRoomData as NSDictionary, imageName: "")
        }
        
        
        let imagesArray = self.allImagesUnderAppointment().filter({$0["image_name"] as! String != ""})
        //            var lastImageDict = imagesArray[imagesArray.count-1]
        //            lastImageDict["data_completed"] = 1
        //            imagesArray[imagesArray.count-1] = lastImageDict
        //            print(imagesArray)
        for imageDict in imagesArray{
            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.ImageUpload, url: AppURL().syncImageInfo, requestType: RequestType.formData, requestParams: imageDict as NSDictionary, imageName: imageDict["image_name"] as! String)
        }
        //4.
//        let appoint_id = String(AppointmentData().appointment_id ?? 0)
//        var contract_plumbing_option_1 = 0
//        var contract_plumbing_option_2 = 0
//        if self.contractDataStatus!.contract_plumbing_option_status == 0{
//            contract_plumbing_option_1 = 1
//        }else if self.contractDataStatus!.contract_plumbing_option_status == 1{
//            contract_plumbing_option_2 = 1
//        }
//        let recison = UserDefaults.standard.value(forKey: "Recision_Date") as! String
//        let requestPara:[String:Any] = ["appointment_id":appoint_id,"contract_plumbing_option_1":contract_plumbing_option_1, "contract_plumbing_option_2" : contract_plumbing_option_2,"recision_date" : recison,"send_physical_document": self.sendPhysicalDocument ? 1 : 0,"additional_comments":self.comments, "flexible_installation": self.FlexInstall ? 1: 0]
        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.GenerateContract, url: AppURL().syncGenerateContractDocumentInServer, requestType: RequestType.post, requestParams: parametersAdditionalComments as NSDictionary, imageName: "")
        
        let requestParaInitiateSync:[String:Any] = ["appointment_id":appointmentId,"screen_logs":self.getScreenCompletionArrayToSend()]
        let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.appointmentLogStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)

        
        DispatchQueue.main.async
        {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func createCustomerAPiCall(networkMessage:String,appointmentId:Int)
    {
        let contactApiData = self.createContractParameters()
        if let applicantDataDict = contactApiData as? [String:Any]
        {
            if  let applicant = applicantDataDict["application_info_secret"] as? String{
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
            }
            
        }
        var customerAndRoomData = self.createFinalParameterForCustomerApiCall()
        for (key,value) in contactApiData
        {
            customerAndRoomData[key] = value
        }
        if payment_TrasnsactionDict != [:]
        {
            customerAndRoomData["payment_transaction_info"] = self.payment_TrasnsactionDict
        }
        
        let appointment = self.getAppointmentData(appointmentId: AppointmentData().appointment_id ?? 0)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        self.name = name
        let date = appointment?.appointment_datetime ?? ""
        var parameterToPass:[String:Any] = [:]
        let decodeOption:[String:Bool] = ["verify_signature":false]
        parameterToPass = ["token": UserData.init().token ?? "" ,"decode_options":decodeOption,"data":customerAndRoomData,"network_strength":networkMessage]
        HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(parameter: parameterToPass, isOnlineCollectBtnPressed: false) { success, message,payment_status,payment_message,transactionId,cardType  in
            if(success ?? "") == "Success"
            {
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                //self.deleteAnyAppointmentLogsTable(appointmentId: appointmentId)
                
                self.createDBAppointmentRequest(requestTitle: RequestTitle.CustomerAndRoom, requestUrl: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParameter: customerAndRoomData as NSDictionary, imageName: "")
                
                
                let appointment = self.getAppointmentData(appointmentId: appointmentId)
               
                    //let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Submitting additional data..")
                        self.isCardVerified = true
                        //var iscustomerAndRoomSuccess = true
                        let appoint_id = AppointmentData().appointment_id ?? 0
                        self.parametersAdditionalComments["network_strength"] = networkMessage
                        self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
                        self.additionalCommentsApiCall(networkMessage: networkMessage)
                        //self.additionalComments(message: message!, customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: true, isNetwork: isNetwork,networkMessage: networkMessage)
                        //self.whetheToProceedToInstaller(customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork, appointmentId: appoint_id)
                    //}
                    //self.alert(message ?? "", [yes])
                
                    
                    
                    
                //}
                
                
            }
            else if success == "Failed"
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.createCustomerAPiCall(networkMessage: networkMessage, appointmentId: appointmentId)
                    
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
            }
            else if success == "false"
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.createCustomerAPiCall(networkMessage: networkMessage, appointmentId: appointmentId)
                    
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
            }
            
            else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.createCustomerAPiCall(networkMessage: networkMessage, appointmentId: appointmentId)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert( AppAlertMsg.NetWorkAlertMessage, [yes,no])
            }
        }
    }
    func createFinalParameterForCustomerApiCall() -> [String:Any]{
        var customerDict: [String:Any] = [:]
        customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        customerDict["data_completed"] = 0
        var customerData = createCustomerParameter()
        //        customerData["additional_comments"] = self.comments
        //        customerData["send_physical_document"] = self.sendPhysicalDocument ? 1 : 0
        customerDict["customer"] = customerData
        customerDict["rooms"] = createRoomParameters()
        customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
        customerDict["operation_mode"] = "Online"
        customerDict["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return customerDict
    }
    func createCustomerParameter() -> [String:Any]{
        return self.getCustomerDetailsForApiCall()
    }
    func createRoomParameters() -> [[String:Any]]{
        return self.getRoomArrayForApiCall()
    }
    func createQuestionAnswerForAllRoomsParameter() -> [[String:Any]]{
        return self.getQuestionAnswerArrayForApiCall()
    }
    func createFinalParameterForCustomerOfflineApiCall() -> [String:Any]{
        var customerDict: [String:Any] = [:]
        customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        customerDict["data_completed"] = 0
        var customerData = createCustomerParameter()
        //        customerData["additional_comments"] = self.comments
        //        customerData["send_physical_document"] = self.sendPhysicalDocument ? 1 : 0
        customerDict["customer"] = customerData
        customerDict["rooms"] = createRoomParameters()
        customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
        customerDict["operation_mode"] = "offline"
        customerDict["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return customerDict
    }
    
    // MARK: - CONTRACT PARAMETERS
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
        contractDict["application_info_secret"] = applicantInfoSecret//applicantDta["data"]//
        //contractDict["contractInfo"] = contactInfo
        //        contractDict["data_completed"] = 0
        //        contractDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        //        let contractDataDict: [String:Any] = ["data":contractDict]
        //        print(contractDataDict)
        return contractDict //contractDataDict
    }
    
    
    func createAppointmentsRequestDataToDatabase(title:RequestTitle,url:String,requestType:RequestType,requestParams:NSDictionary,imageName:String){
        
        self.createAppointmentRequest(requestTitle: title, requestUrl: url, requestType: requestType, requestParameter: requestParams, imageName: imageName)
    }
    
    override func insallerSkipBtnAction(sender: UIButton)
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "DestinationMotivation"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //saveDataForApiCall()
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            DispatchQueue.main.async
            {
                if !self.isCardVerified
                {
                    HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Creating sale order...")
                    var networkMessage = ""
                    let speedTest = NetworkSpeedTest()
                    speedTest.testUploadSpeed { speed in
                        print("Upload speed: \(speed) Mbps")
                        DispatchQueue.main.async {
                            networkMessage = String(format: "%.2f", speed)
                            networkMessage += "Mbps"
                            self.createCustomerAPiCall(networkMessage: networkMessage,appointmentId:appointmentId)
                        }
                    }
                }
                else
                {
                    
                        
                        HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Submitting additional data..")
                        
                        
                        var networkMessage = ""
                        let speedTest = NetworkSpeedTest()
                        speedTest.testUploadSpeed { speed in
                            print("Upload speed: \(speed) Mbps")
                            DispatchQueue.main.async {
                                networkMessage = String(format: "%.2f", speed)
                                networkMessage += "Mbps"
                                self.parametersAdditionalComments["network_strength"] = networkMessage
                                self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
                                self.additionalCommentsApiCall(networkMessage: networkMessage)
                            }
                        }
                        
                    }
                
                }
                
            }
        
        else
        {
            offlineParameterCreation()
           // self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func additionalCommentsApiCall(networkMessage:String)
    {
        HttpClientManager.SharedHM.additionalCommentsAPi(parameter: parametersAdditionalComments) { success, usermessage in
            DispatchQueue.main.async { // Ensure UI updates happen on the main thread
                if(success ?? "") == "Success"
                {
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        let imagesArray = self.allImagesUnderAppointment().filter({$0["image_name"] as! String != ""})
                        //            var lastImageDict = imagesArray[imagesArray.count-1]
                        //            lastImageDict["data_completed"] = 1
                        //            imagesArray[imagesArray.count-1] = lastImageDict
                        //            print(imagesArray)
                        for imageDict in imagesArray{
                            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.ImageUpload, url: AppURL().syncImageInfo, requestType: RequestType.formData, requestParams: imageDict as NSDictionary, imageName: imageDict["image_name"] as! String)
                        }
                        
                        let appoint_id = String(AppointmentData().appointment_id ?? 0)
                        //self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
                        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.GenerateContract, url: AppURL().syncGenerateContractDocumentInServer, requestType: RequestType.post, requestParams: self.parametersAdditionalComments as NSDictionary, imageName: "")
                        
                        let requestParaInitiateSync:[String:Any] = ["appointment_id":appoint_id,"screen_logs":self.getScreenCompletionArrayToSend()]
                        let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
                        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
                        let installer = InstallerShedulerViewController.initialization()!
                        installer.name = self.name
                        self.navigationController?.pushViewController(installer, animated: true)
                        
                    }
                    
                    
                    self.alert(usermessage ?? "", [yes])
                }
                
                else if success == "Failed"
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.additionalCommentsApiCall(networkMessage: networkMessage)
                        
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert((usermessage ?? usermessage) ?? AppAlertMsg.serverNotReached, [yes,no])
                }
                else if success == "false"
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.additionalCommentsApiCall(networkMessage: networkMessage)
                        
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert((usermessage ?? usermessage) ?? AppAlertMsg.serverNotReached, [yes,no])
                }
                
                else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                {
                    
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        self.fourceLogOutbuttonAction()
                    }
                    
                    self.alert((usermessage) ?? AppAlertMsg.serverNotReached, [yes])
                    
                }
                else
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.additionalCommentsApiCall(networkMessage: networkMessage)
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert( AppAlertMsg.NetWorkAlertMessage, [yes,no])
                }
            }
        }
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
    //
    
    
    
    
}
