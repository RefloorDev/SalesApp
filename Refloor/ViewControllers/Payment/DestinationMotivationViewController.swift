//
//  DestinationMotivationViewController.swift
//  Refloor
//
//  Created by Bincy C A on 10/06/25.
//  Copyright © 2025 oneteamus. All rights reserved.
//

import UIKit

class DestinationMotivationViewController: UIViewController, DropDownDelegate {
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int)
    {
        selectDestinationCenterView.isHidden = true
        scrollViewHeightConstraint.constant = 1300
        radioSumitLablViewHeightConstraint.constant = 145
        termsViewHeightConstraint.constant = 676
        selectDestinationLbl.isHidden = false
        dropDownView.isHidden = false
        termsAndConditionView.isHidden = false
        radioSumitView.isHidden = false
        dropDownLbl.text = destinationDropDownValues[index]
        radioLabl.text = masterData.destinationSelectionConsentMesage
        terms_conditionLbl.text = destinationTermsCondition[index]
        destinationSelectionId = destinationSelectionIdArray[index]
        termsndConditionHeadingLbl.text = "TERMS & CONDITIONS"
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
    
    var masterData = MasterData()
    override func viewDidLoad() {
        super.viewDidLoad()
        masterData = getMasterDataFromDB()
        dropDownLbl.text = "Select"
        terms_conditionLbl.text = ""
        radioLabl.text = ""
        termsndConditionHeadingLbl.text = ""
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
    @IBAction func nextBtnAction(_ sender: UIButton)
    {
        
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            //HttpClientManager.SharedHM.showhideHUD(viewtype: .HIDE)
            
            DispatchQueue.main.async
            {
                HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Submitting additional data..")
                
                
                
                var networkMessage = ""
                let speedTest = NetworkSpeedTest()
                speedTest.testUploadSpeed { speed in
                    print("Upload speed: \(speed) Mbps")
                    networkMessage = String(format: "%.2f", speed)
                    networkMessage += "Mbps"
                    self.parametersAdditionalComments["network_strength"] = networkMessage
                    self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
                    self.additionalCommentsApiCall(networkMessage: networkMessage)
                }
                
            }
            
        }
        else
        {
            let appoint_id = String(AppointmentData().appointment_id ?? 0)
            self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.GenerateContract, url: AppURL().syncGenerateContractDocumentInServer, requestType: RequestType.post, requestParams: parametersAdditionalComments as NSDictionary, imageName: "")
            
            let requestParaInitiateSync:[String:Any] = ["appointment_id":appoint_id,"screen_logs":self.getScreenCompletionArrayToSend()]
            let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func createAppointmentsRequestDataToDatabase(title:RequestTitle,url:String,requestType:RequestType,requestParams:NSDictionary,imageName:String){
        
        self.createAppointmentRequest(requestTitle: title, requestUrl: url, requestType: requestType, requestParameter: requestParams, imageName: imageName)
    }
    
    override func insallerSkipBtnAction(sender: UIButton)
    {
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            DispatchQueue.main.async
            {
                HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Submitting additional data..")
                
                
                
                var networkMessage = ""
                let speedTest = NetworkSpeedTest()
                speedTest.testUploadSpeed { speed in
                    print("Upload speed: \(speed) Mbps")
                    networkMessage = String(format: "%.2f", speed)
                    networkMessage += "Mbps"
                    self.parametersAdditionalComments["network_strength"] = networkMessage
                    self.parametersAdditionalComments["destination_selection_id"] = self.destinationSelectionId
                    self.additionalCommentsApiCall(networkMessage: networkMessage)
                }
                
            }
        }
        else
        {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func additionalCommentsApiCall(networkMessage:String)
    {
        HttpClientManager.SharedHM.additionalCommentsAPi(parameter: parametersAdditionalComments) { success, usermessage in
            if(success ?? "") == "Success"
            {
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    let appointmentId = AppointmentData().appointment_id ?? 0
                    let currentClassName = String(describing: type(of: self))
                    let classDisplayName = "DestinationMotivation"
                    self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
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
