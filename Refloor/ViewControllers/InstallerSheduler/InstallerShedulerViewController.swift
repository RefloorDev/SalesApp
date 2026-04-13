//
//  InstallerShedulerViewController.swift
//  Refloor
//
//  Created by Bincy C A on 22/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit
import JWTCodable
@MainActor
class InstallerShedulerViewController: UIViewController,installerConfirmProtocol,UICollectionViewDelegateFlowLayout {
    func installerConfirm()
    {
        installerSubmitBtnApiCall()
    }
    
    
    static func initialization() -> InstallerShedulerViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "InstallerShedulerViewController") as? InstallerShedulerViewController
    }

    @IBOutlet weak var installerRightBtn: UIButton!
    @IBOutlet weak var installerLeftBtn: UIButton!
    @IBOutlet weak var installerCollectionView: UICollectionView!
    var selectedIndex = 0
    var availableDatesdata = [AvailableDatesValues]()
    var saleOrderId:Int = Int()
    var installationId:Int = Int()
    var installationDate:String = String()
    var name:String = String()
    var isDestination = false
    //let count = 7
    var currentIndex = 0
    let itemsPerPage = 5
    var parametersAdditionalComments:[String:Any] = [:]
    var isCardVerified:Bool = Bool()
    var payment_TrasnsactionDict:[String:String] = [:]
    
    //var dates = ["00","01","02","03","04","05","06"]//,"07","08","09","10","11","12","13","14","15","16","17","18","19"]
    override func viewDidLoad()
    {
        super.viewDidLoad()
        installerLeftBtn.layer.cornerRadius = installerLeftBtn.frame.height / 2
        installerRightBtn.layer.cornerRadius = installerRightBtn.frame.height / 2
        //installerLeftBtn.borderWidth = 0
       
        installerRightBtn.isHidden = true
        installerLeftBtn.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Submit")
         if isDestination
        {
             installerDatesApiCall()
         }
        else
        {
            callingCustomerApi()
        }
        //
        
        
    }
    override func viewDidAppear(_ animated: Bool)
    {
        logScreenEvent(screen: ScreenNames.installationScheduler) {
            var networkMessage = ""
            let speedTest = NetworkSpeedTest()
            speedTest.testUploadSpeed { speed in
                print("Upload speed: \(speed) Mbps")
                networkMessage = String(format: "%.2f", speed)
                networkMessage += "Mbps"
                //DispatchQueue.main.async {
                
                let (_,timeZone) = Date().getCompletedDateStringAndTimeZone()
                let parameters:[String:Any] = ["appointment_id": AppointmentData().appointment_id ?? 0,"screen_name":ScreenNames.installationScheduler,"screen_entry_date":Date().getSyncDateAsString(),"network_strength":networkMessage,"timezone":timeZone,"CreatedDate": Date().getSyncDateAsString()]
                HttpClientManager.SharedHM.liveScreenLogsAPi(parameter: parameters)
            }
        }
            
        }
    
    
    func installerSubmitBtnApiCall()
    {
 
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW, title: "Submitting Installation Request. Please wait.")
            DispatchQueue.main.async {
                
                var networkMessage = ""
                let speedTest = NetworkSpeedTest()
                speedTest.testUploadSpeed { speed in
                    print("Upload speed: \(speed) Mbps")
                    networkMessage = String(format: "%.2f", speed)
                    networkMessage += "Mbps"
                    self.installerSubmitNetworkMessage(networkMessage: networkMessage)
                }
            }
            
            
      
        }
            else{
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    self.installerSubmitBtnApiCall()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
                    
                  
                
                self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
            }
        }
    
    func installerSubmitNetworkMessage(networkMessage:String)
    {
        DispatchQueue.main.async {
            
            let parameter : [String:Any] = ["token": UserData.init().token!, "sale_order_id": self.saleOrderId ,"installation_id": self.installationId,"network_strength":networkMessage,"CreatedDate": Date().getSyncDateAsString()]
            
            HttpClientManager.SharedHM.installerDatesSubmitAPi(parameter: parameter) { success, message in
                if success == "Success"
                {
                    // self.installerConfirm?.installerConfirm()
                    
                    
                    let installer = InstallerSuccessViewController.initialization()!
                    installer.installationDate = self.installationDate
                    installer.customerName = self.name
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(installer, animated: true)
                    }
                    
                    
                    
                }
                else if success == "Failed" && message == "Selected Date is not available now. Please select different date"
                {
                    let installerPopUp = InstallerPopUpViewController.initialization()!
                    installerPopUp.installationId = self.installationId
                    installerPopUp.saleOrderId = self.saleOrderId
                    //installerPopUp.installerConfirm = self
                    DispatchQueue.main.async {
                        self.present(installerPopUp, animated: true, completion: nil)
                    }
                }
                else if success == "false"
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        self.installerSubmitBtnApiCall()
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
                }
                else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                {
                    
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        self.fourceLogOutbuttonAction()
                    }
                    
                    self.alert((message) ?? AppAlertMsg.serverNotReached, [yes])
                    
                }
                else{
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        self.installerSubmitBtnApiCall()
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert(message ?? AppAlertMsg.NetWorkAlertMessage, [yes,no])
                }
            }
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
    
    func callingCustomerApi()
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
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
                                self.parametersAdditionalComments["CreatedDate"] = Date().getSyncDateAsString()
                                self.additionalCommentsApiCall(networkMessage: networkMessage)
                            }
                        }
                        
                    }
                
                }
                
            }
        else
        {
            offlineParameterCreation()
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
                        self.installerDatesApiCall()
//                        let installer = InstallerShedulerViewController.initialization()!
//                        installer.name = self.name
//                        self.navigationController?.pushViewController(installer, animated: true)
                        
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
        parameterToPass = ["token": UserData.init().token ?? "" ,"decode_options":decodeOption,"data":customerAndRoomData,"network_strength":networkMessage,"CreatedDate": Date().getSyncDateAsString()]
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
    
    
    
    func installerDatesApiCall()
    {
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW, title: "Fetching available installer schedule dates. Please wait…")
            DispatchQueue.main.async {
                
                var networkMessage = ""
                let speedTest = NetworkSpeedTest()
                speedTest.testUploadSpeed { speed in
                    print("Upload speed: \(speed) Mbps")
                    networkMessage = String(format: "%.2f", speed)
                    networkMessage += "Mbps"
                    self.installerNetrworkProceed(networkMessage: networkMessage)
                }
            }
        }
        else{
            let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                self.installerDatesApiCall()
            }
            let no = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Retry")
            }
            
            self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
        }
    }
    
    func installerNetrworkProceed(networkMessage:String)
    {
        DispatchQueue.main.async {
            
            let parameter : [String:Any] = ["token": UserData.init().token!, "appointment_id": AppDelegate.appoinmentslData.id!,"network_strength":networkMessage,"CreatedDate": Date().getSyncDateAsString()]
            
            HttpClientManager.SharedHM.installerDatesAPi(parameter: parameter) { success, message, availableDates, saleOrderId in
                if success == "Success"
                {
                    self.saleOrderId = saleOrderId ?? 0
                    self.availableDatesdata = availableDates!
                    DispatchQueue.main.async
                    {
                        if self.availableDatesdata.count > 0
                        {
                            self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Submit")
                        }
                        self.installerCollectionView.reloadData()
                    }
                }
                else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                {
                    
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        self.fourceLogOutbuttonAction()
                    }
                    
                    self.alert((message) ?? AppAlertMsg.serverNotReached, [yes])
                    
                }
                else if success == "Failed"
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.installerDatesApiCall()
                        
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Retry")
                    }
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                }
                
                else
                {
                    //self.alert(message ?? "", nil)
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.installerDatesApiCall()
                        
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Retry")
                    }
                    
                    self.alert( message ?? AppAlertMsg.serverNotReached, [yes,no])
                }
            }
        }

    }
    
    @IBAction func installerLeftBtnAction(_ sender: UIButton)
    {
        currentIndex -= 5
        if currentIndex <= 0
        {
            currentIndex = 0
        }
        DispatchQueue.main.async
        {
            self.installerCollectionView.reloadData()
        }
    }
    @IBAction func installerRightBtnAction(_ sender: UIButton)
    {
        var lastIndex = currentIndex
        lastIndex += 5
        if availableDatesdata.count <= lastIndex
        {
            
            return
        }
        else
        {
            currentIndex += 5
            DispatchQueue.main.async
            {
                self.installerCollectionView.reloadData()
            }
            //installerCollectionView.reloadData()
        }
    }
    
    override func insallerSkipBtnAction(sender: UIButton)
    {
        DispatchQueue.main.async
        {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "InstallerScheduler"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        let requestParaInitiateSync:[String:Any] = ["appointment_id":appointmentId,"screen_logs":self.getScreenCompletionArrayToSend()]
        let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
        
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    override func insallerSubmitBtnAction(sender: UIButton)
    {
         if sender.titleLabel?.text == "Retry"
        {
            installerDatesApiCall()
        }
        else
        {
             if installationId == 0
            {
                self.alert("Please select a date and proceed", nil)
            }
            
            else
            {
                let appointmentId = AppointmentData().appointment_id ?? 0
                let currentClassName = String(describing: type(of: self))
                let classDisplayName = "InstallerScheduler"
                self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
                let requestParaInitiateSync:[String:Any] = ["appointment_id":appointmentId,"screen_logs":self.getScreenCompletionArrayToSend()]
                let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
                self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
                DispatchQueue.main.async
                {
                    let installerPopUp = InstallerPopUpViewController.initialization()!
                    installerPopUp.installationId = self.installationId
                    installerPopUp.saleOrderId = self.saleOrderId
                    installerPopUp.installerConfirm = self
                    self.present(installerPopUp, animated: true, completion: nil)
                }
            }
        }

    }
    
    func createAppointmentsRequestDataToDatabase(title:RequestTitle,url:String,requestType:RequestType,requestParams:NSDictionary,imageName:String){
        
        self.createAppointmentRequest(requestTitle: title, requestUrl: url, requestType: requestType, requestParameter: requestParams, imageName: imageName)
    }
    
}

extension InstallerShedulerViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if availableDatesdata.count > 5
        {
            installerRightBtn.isHidden = false
            installerLeftBtn.isHidden = false
        }
        else
        {
            installerRightBtn.isHidden = true
            installerLeftBtn.isHidden = true
        }
        let remainingItems = availableDatesdata.count - currentIndex
        return min(itemsPerPage, remainingItems)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InstallerSchedulerCollectionViewCell", for: indexPath) as! InstallerSchedulerCollectionViewCell
        //cell.dateLbl.text = dates[indexPath.row + currentIndex]
                cell.dateLbl.text = availableDatesdata[indexPath.row + currentIndex].startDate?.installerDate(installationDate: availableDatesdata[indexPath.row + currentIndex].startDate!)
                var installerWeekDayDate = availableDatesdata[indexPath.row + currentIndex].startDate?.logDate()
                cell.weekNameLbl.text = availableDatesdata[indexPath.row + currentIndex].startDate?.getInstallerWeekDay(installerDate: installerWeekDayDate!)
        
        
        if indexPath.row == selectedIndex
        {
            cell.borderColor = UIColor().colorFromHexString("#D29B3C")
            cell.borderWidth = 2
            cell.backgroundColor = UIColor().colorFromHexString("#292562")
            cell.tickImgView.isHidden = false
                            installationId = availableDatesdata[indexPath.row + currentIndex].installationId ?? 0
                            installationDate = cell.dateLbl.text!
        }
        else
        {
            cell.borderColor = UIColor().colorFromHexString("#586471")
            cell.borderWidth = 1
            cell.backgroundColor = UIColor().colorFromHexString("#2D343D")
            cell.tickImgView.isHidden = true
        }
        
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedIndex = indexPath.row
                installationId = availableDatesdata[indexPath.row + currentIndex].installationId ?? 0
                installationDate = availableDatesdata[indexPath.row + currentIndex].startDate?.installerDate(installationDate: availableDatesdata[indexPath.row].startDate!) ?? ""
        DispatchQueue.main.async {
            self.installerCollectionView.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let yourWidth = ((collectionView.bounds.width) - (17 * 4)) / 5
        return CGSize(width: yourWidth, height: 110)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))

        if cellCount < 5 {
            let yourWidth = ((collectionView.bounds.width) - (17 * 4)) / 5
            let cellWidth = yourWidth + 17.0//flowLayout.minimumInteritemSpacing
            //let cellWidth = 163.0//flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            print("cellWidth : ",cellWidth)
            print("cellCount : ",cellCount)
            let totalCellWidth = cellWidth * cellCount
            print("totalCellWidth : ",totalCellWidth)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right - flowLayout.headerReferenceSize.width - flowLayout.footerReferenceSize.width
            print("contentWidth : ",contentWidth)
            if (totalCellWidth < contentWidth)
            {
                //let padding = (contentWidth - totalCellWidth + flowLayout.minimumInteritemSpacing) / 2.0
                let padding = (collectionView.frame.size.width - totalCellWidth + flowLayout.minimumInteritemSpacing) / 2.0 //+ flowLayout.minimumInteritemSpacing - 17
                print("Padding : ",padding)
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            }
            
            
        
        }

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 17)
    }
    
    
    
    

        

    


}





