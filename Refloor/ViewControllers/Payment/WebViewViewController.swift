//
//  WebViewViewController.swift
//  Refloor
//
//  Created by sbek on 02/07/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import WebKit
import JWTCodable
import CryptoKit
import CommonCrypto

class WebViewViewController: UIViewController,WKNavigationDelegate,WKUIDelegate,ContractCommentProtocol {
    var document = ""
    var paymentType = ""
    var orderID = 0
    var downPayment:Double = 0
    var balance:Double = 0
    var total:Double = 0
    var isTapped = true
    var isloadCompleted = false
    var comments = ""
    var sendPhysicalDocument: Bool = false
    var FlexInstall : Bool = false
    var isCardVerified:Bool = Bool()
    let header = JWTHeader(typ: "JWT", alg: .hs256)
    let signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"//"password"
    var recisionDate:String = String()
    // var activity= PaymentOptionsViewController
    let activity = HttpClientManager.init()
    static func initialization() -> WebViewViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController
    }
    @IBOutlet weak var wkWebView: WKWebView!
    var imagePicker: CaptureImage!
    var contractDataStatus:ContractData?
    var applicantSignatureImage: UIImage?
    var applicantInitialsImage: UIImage?
    var coApplicantSignatureImage: UIImage?
    var coApplicantInitialsImage: UIImage?
    var applicantData:AppoinmentDataValue!
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    @IBOutlet weak var cancellationLabel2: UILabel!
    @IBOutlet weak var dateOfTransaction2: UILabel!
    @IBOutlet weak var dateOfTransaction1: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var refloorRepresentativeLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!
    
    @IBOutlet weak var nameOwner1Label: UILabel!
    @IBOutlet weak var mobileOwner1Label: UILabel!
    @IBOutlet weak var alternatePhoneOwner1Label: UILabel!
    @IBOutlet weak var emailOwner1Label: UILabel!
    
    @IBOutlet weak var nameOwner2Label: UILabel!
    @IBOutlet weak var mobileOwner2Label: UILabel!
    @IBOutlet weak var alternatePhoneOwner2Label: UILabel!
    @IBOutlet weak var emailOwner2Label: UILabel!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var balanceDueLabel: UILabel!
    
    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var financingButton: UIButton!
    @IBOutlet weak var visaCardButton: UIButton!
    @IBOutlet weak var masterCardButton: UIButton!
    @IBOutlet weak var AmericanExpressButton: UIButton!
    
    @IBOutlet weak var signatureOwner1Button: UIButton!
    @IBOutlet weak var dateOwner1Label: UILabel!
    @IBOutlet weak var signatureOwner2Button: UIButton!
    @IBOutlet weak var dateOwner2Label: UILabel!
    
    @IBOutlet weak var contractPlumbingOptionButton1: UIButton!
    @IBOutlet weak var contractPlumbingOptionButton2: UIButton!
    
    @IBOutlet weak var moldingNone: UIButton!
    @IBOutlet weak var moldingVinyl: UIButton!
    @IBOutlet weak var moldingUnfinish: UIButton!
    
    @IBOutlet weak var contract_owner_reviewed_Btn, contract_transition_Btn, contract_molding_Btn,contract_molding_none_Btn, contract_molding_waterproof_Btn, contract_molding_unfinished_Btn,  contract_risk_free_Btn, contract_lifetime_guarantee_Btn, contract_lead_safe_btn,contract_deposit_Btn, contract_final_payment_Btn, contract_time_of_performance_btn,contract_notices_to_owners_btn,notices_to_cancellation_btn,contract_scheduling_Btn, contract_motion_btn, contract_floor_protection_Btn, contract_plumbing_Btn, contract_plumbing_option_Btn,contract_plumbing_option_Btn2, contract_additional_other_cost_Btn, contract_additional_other_subfloor_Btn, contract_additional_other_leveling_Btn, contract_additional_other_screwdown_Btn, contract_additional_other_hardwood_removal_Btn, contract_additional_other_door_removal_Btn, contract_additional_other_bifold_removal_Btn,contract_floor_protection, contract_right_to_cure_Btn, contract_owner_responsibility_Btn,electronicsAuthorizationBtn,electronicsAuthorizationBtn2: UIButton!
    
    @IBOutlet weak var cancellationLabelTopPart: UILabel!
    func getSignatureAndInitials(){
        let (applicantSignature,applicantInitials) = self.getApplicantSignatureAndInitials()
        let (coApplicantSignature,coApplicantInitials) = self.getCoApplicantSignatureAndInitials()
        
         applicantSignatureImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: applicantSignature)
         applicantInitialsImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: applicantInitials)
        
         coApplicantSignatureImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: coApplicantSignature)
         coApplicantInitialsImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: coApplicantInitials)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //self.setNavigationBarbacklogoAndSubmit()
        self.setNavigationBarbacklogoAndDone()
        if (UserDefaults.standard.value(forKey: "Recision_Date") as! String) != ""
        {
            let recison = UserDefaults.standard.value(forKey: "Recision_Date") as! String
            //self.recisionDate = masterData.resitionDate?.recisionDate().DateFromStringForServer() ?? ""
            self.recisionDate = recison.recisionDate().DateFromStringForServer()
        }
//        let cancellationDate:NSMutableAttributedString = NSMutableAttributedString(string: " 10/12/2022", attributes:[NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
//        let defaultString:NSMutableAttributedString = NSMutableAttributedString(string: cancellationLabelTopPart.text!)
//        defaultString.append(cancellationDate)
//        cancellationLabelTopPart.attributedText = defaultString
        //cancellationLabelTopPart.attributedText = cancellationLabelTopPart.attributedText + " 10/12/2022"
        
        //arb
        self.getSignatureAndInitials()
        setInitialData()
        //contract_owner_reviewed_Btn, contract_transition_Btn, contract_molding_Btn,contract_molding_none_Btn, contract_molding_waterproof_Btn, contract_molding_unfinished_Btn,  contract_risk_free_Btn, contract_lifetime_guarantee_Btn, contract_lead_safe_btn,contract_deposit_Btn, contract_final_payment_Btn, contract_time_of_performance_btn,contract_notices_to_owners_btn,notices_to_cancellation_btn,
        self.contractDataStatus = ContractData.init(contract_owner_reviewed_status: 0, contract_transition: 0, contract_molding_status: 0, contract_molding_none_status: 0, contract_molding_waterproof_status: 0, contract_molding_unfinished_status: 0, contract_risk_free_status: 0, contract_lifetime_guarantee_status: 0, contract_lead_safe_status: 0, contract_deposit_status: 0, contract_final_payment_status: 0, contract_time_of_performance_status: 0, contract_notices_to_owners_status: 0, contract_notices_of_cancellation: 0, contract_scheduling_status: 0, contract_motion_status: 0, contract_floor_protection_status: 0, contract_plumbing_status: 0, contract_plumbing_option_status: -1, contract_additional_other_cost_status: 0, contract_additional_other_subfloor_status: 0, contract_additional_other_leveling_status: 0, contract_additional_other_screwdown_status: 0, contract_additional_other_hardwood_removal_status: 0, contract_additional_other_door_removal_status: 0, contract_additional_other_bifold_removal_status: 0, contract_floor_protection: 0, contract_right_to_cure_status: 0, contract_owner_responsibility_status: 0, electronicsAuthorization1Status: 0, electronicsAuthorization2Status: 0) //ContractData.init(contract_owner_reviewed_status: 0, contract_transition: 0, contract_molding_status: 0,contract_molding_none_status: 0, contract_molding_waterproof_status: 0, contract_molding_unfinished_status: 0, contract_financing_status: 0, contract_risk_free_status: 0, contract_lifetime_guarantee_status: 0, contract_deposit_status: 0, contract_final_payment_status: 0, contract_additional_cost_status: 0, contract_lead_safe_status: 0, contract_scheduling_status: 0, contract_time_of_performance_status: 0, contract_floor_protection_status: 0, contract_door_frame_and_other_status: 0, contract_plumbing_status: 0, contract_plumbing_option_status: -1, contract_additional_other_cost_status: 0, contract_additional_other_subfloor_status: 0, contract_additional_other_leveling_status: 0, contract_additional_other_screwdown_status: 0, contract_additional_other_tile_removal_status: 0, contract_additional_other_hardwood_removal_status: 0, contract_additional_other_door_removal_status: 0, contract_additional_other_bifold_removal_status: 0, contract_right_to_cure_status: 0, contract_owner_responsibility_status: 0,electronicsAuthorization1Status:0,electronicsAuthorization2Status: 0)
        
    }
//    override func performSegueToReturnBack() {
//
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        logoImageView.contentMode = .scaleAspectFit
        if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
            logoImageView.image = savedLogoImage
        }else{
            logoImageView.image = UIImage(named: "contractRefloorIcon")
        }
        logoImageView.backgroundColor = .clear
    }
    
    
    func getApplicantsData() -> [String: Any]{
        return self.getApplicantAndIncomeDataFromAppointmentDetail()
    }
    
    func getApplicantData() -> AppoinmentDataValue?{
        var applicant:AppoinmentDataValue? = nil
        if let customer = AppDelegate.appoinmentslData
        {
            applicant = customer
            
        }
        return applicant
    }
    
    // MARK: - SET INITIAL DATA
    func setInitialData(){
        let moldingTypesSelected = identifyMoldingTypesSelectedForRooms()
        if moldingTypesSelected.contains(where: {$0.localizedStandardContains("NO MOLDING")}) {
            self.moldingNone.setBackgroundImage(UIImage(named: "contactTick"), for: .normal)
        }
        if moldingTypesSelected.contains(where: {$0.localizedStandardContains("Vinyl White")}) {
            self.moldingVinyl.setBackgroundImage(UIImage(named: "contactTick"), for: .normal)
        }
        if moldingTypesSelected.contains(where: {$0.localizedStandardContains("Unfinished")}) {
            self.moldingUnfinish.setBackgroundImage(UIImage(named: "contactTick"), for: .normal)
        }
        contract_plumbing_option_Btn.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
        contract_plumbing_option_Btn2.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
        self.dateLabel.text = Date().DateFromStringForServer()
        self.dateOfTransaction1.text = dateOfTransaction1.text! + " \(Date().DateFromStringForServer())"
        self.dateOfTransaction2.text = dateOfTransaction2.text! + " \(Date().DateFromStringForServer())"
        self.cancellationLabelTopPart.text = cancellationLabelTopPart.text! + self.recisionDate
        self.cancellationLabel2.text = cancellationLabel2.text! + self.recisionDate
        self.refloorRepresentativeLabel.text = self.getSalesPersonName()
        let applicantData = self.getApplicantsData()
        let applicant = applicantData["data"] as? [String:Any] ?? [:]
        if let mainApplicant = getApplicantData(){
            let street = mainApplicant.street2 == "" ? mainApplicant.street : (mainApplicant.street ?? "") + "," + (mainApplicant.street2 ?? "")
            let city = mainApplicant.city ?? ""
            let state = mainApplicant.state ?? ""
            let zip = mainApplicant.zip ?? ""
            let streetPlusCity = (street ?? "") + ", " + city
            self.propertyLabel.text = streetPlusCity + ", " + state + " " + zip
            
            let applicantFirstName = mainApplicant.applicant_first_name ?? ""
            let applicantMiddleName = mainApplicant.applicant_middle_name ?? ""
            let applicantLastName = mainApplicant.applicant_last_name ?? ""
            
            self.nameOwner1Label.text = (applicantMiddleName == "") ? (applicantFirstName + " " + applicantLastName) : (applicantFirstName  + " " + applicantMiddleName  + " " + applicantLastName)
            self.mobileOwner1Label.text = mainApplicant.phone ?? ""
            self.alternatePhoneOwner1Label.text = mainApplicant.mobile ?? ""
            self.emailOwner1Label.text = mainApplicant.email ?? ""
            let coApplicantFirstName = mainApplicant.co_applicant_first_name ?? ""
            let coApplicantMiddleName = mainApplicant.co_applicant_middle_name ?? ""
            let coApplicantLastName = mainApplicant.co_applicant_last_name ?? ""
//            if coApplicantMiddleName == ""
//            {
//                self.nameOwner2Label.text = coApplicantFirstName ?? "" + " " + (coApplicantLastName ?? "")
//            }
//            else
//            {
//                self.nameOwner2Label.text = coApplicantFirstName ?? "" + " " + coApplicantMiddleName ?? "" + " " + coApplicantLastName ?? ""
//            }
            self.nameOwner2Label.text = (coApplicantMiddleName == "") ? (coApplicantFirstName + " " + coApplicantLastName) : (coApplicantFirstName + " " + coApplicantMiddleName + " " + coApplicantLastName)
            self.mobileOwner2Label.text = mainApplicant.co_applicant_phone ?? ""
            self.alternatePhoneOwner2Label.text = mainApplicant.co_applicant_secondary_phone ?? ""
            self.emailOwner2Label.text = mainApplicant.co_applicant_email ?? ""
        }
        
        
        
      
        
        
        let totalAmount = (self.total.rounded())
        let depositAmount = (self.downPayment.rounded())
        let balanceDueAmount = (self.balance.rounded())
        self.totalLabel.text = "$" + String(format: "%.2f", totalAmount)
        self.depositLabel.text = "$" + String(format: "%.2f", depositAmount)
        self.balanceDueLabel.text = "$" + String(format: "%.2f", balanceDueAmount)
        
        self.signatureOwner1Button.setBackgroundImage(applicantSignatureImage ?? UIImage(), for: .normal)
        self.dateOwner1Label.text = Date().DateFromStringForServer()
        if coApplicantSignatureImage != nil{
            self.signatureOwner2Button.setBackgroundImage(coApplicantSignatureImage ?? UIImage(), for: .normal)
            self.dateOwner2Label.text = Date().DateFromStringForServer()
        }
        
        let paymentDetails = self.getPaymentDetailsDataFromAppointmentDetail()
        if let financeAmount = paymentDetails["finance_amount"] as? Double{
            if financeAmount > 0{
                self.financingButton.setBackgroundImage(UIImage(named: "contactTick"), for: .normal)
            }else{
                if paymentType == "cash"{
                    self.cashButton.setBackgroundImage(UIImage(named: "contactTick"), for: .normal)
                }else if paymentType == "check"{
                    self.checkButton.setBackgroundImage(UIImage(named: "contactTick"), for: .normal)
                }else if paymentType == "card"{
                    self.visaCardButton.setBackgroundImage(UIImage(named: "contactTick"), for: .normal)
                }
            }
        }
           
    }
    // MARK: - SAVE CONTRACT DETAILS TO DB
    func saveContractDataToDatabase(){
        let appointmentId = AppointmentData().appointment_id ?? 0
        if let contractDataDict = self.contractDataStatus?.nsDictionary{
            self.saveContractDataOfAppointment(appointmentId: appointmentId, contractData: contractDataDict)
        }
    }
    
    // MARK: - CHECKBOX ACTIONS
    @IBAction func ownerReviewed(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus?.contract_owner_reviewed_status = 0
        }else{
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
            contractDataStatus?.contract_owner_reviewed_status = 1
        }
    }
    
    @IBAction func contract_owner_reviewed_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            self.contractDataStatus?.contract_owner_reviewed_status = 0
        }else{
            
            self.contractDataStatus?.contract_owner_reviewed_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_transition(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_transition = 0
        }else{
            
            contractDataStatus!.contract_transition = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_molding_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_molding_status = 0
        }else{
            
            contractDataStatus!.contract_molding_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    @IBAction func contract_molding_none_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_molding_none_status = 0
        }else{
            
            contractDataStatus!.contract_molding_none_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    @IBAction func contract_molding_waterproof_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_molding_waterproof_status = 0
        }else{
            
            contractDataStatus!.contract_molding_waterproof_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    
    @IBAction func contract_molding_unfinished_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_molding_unfinished_status = 0
        }else{
            
            contractDataStatus!.contract_molding_unfinished_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    
    
    @IBAction func contract_risk_free_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_risk_free_status = 0
        }else{
            
            contractDataStatus!.contract_risk_free_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    @IBAction func noticesToOwnerBtnAction(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_notices_to_owners_status = 0
        }else{
            
            contractDataStatus!.contract_notices_to_owners_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    @IBAction func noticesToCancellation(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_notices_of_cancellation = 0
        }else{
            
            contractDataStatus!.contract_notices_of_cancellation = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func otherPerformanceBtnAction(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_time_of_performance_status = 0
        }else{
            
            contractDataStatus!.contract_time_of_performance_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    @IBAction func contract_LeadSafeBtnAction(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_lead_safe_status = 0
        }else{
            
            contractDataStatus!.contract_lead_safe_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
        
    }
    
    
    @IBAction func contract_lifetime_guarantee_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_lifetime_guarantee_status = 0
        }else{
            
            contractDataStatus!.contract_lifetime_guarantee_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    @IBAction func contract_deposit_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_deposit_status = 0
        }else{
            
            contractDataStatus!.contract_deposit_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    @IBAction func contract_final_payment_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_final_payment_status = 0
        }else{
            
            contractDataStatus!.contract_final_payment_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    
    @IBAction func contract_lead_safe_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_lead_safe_status = 0
        }else{
            
            contractDataStatus!.contract_lead_safe_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_scheduling_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_scheduling_status = 0
        }else{
            
            contractDataStatus!.contract_scheduling_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_time_of_performance_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_motion_status = 0
        }else{
            
            contractDataStatus!.contract_motion_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_floor_protection_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_floor_protection_status = 0
        }else{
            
            contractDataStatus!.contract_floor_protection_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    
    @IBAction func contract_plumbing_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_plumbing_status = 0
        }else{
            
            contractDataStatus!.contract_plumbing_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_plumbing_option_status(_ sender: UIButton)
    {
        if sender.isSelected{
            if sender.tag == 1{
                contract_plumbing_option_Btn2.isSelected = true
                contractDataStatus!.contract_plumbing_option_status = 1
                contract_plumbing_option_Btn.setBackgroundImage(UIImage(named: "contactUncheck"), for: .normal)
            }else{
                contractPlumbingOptionButton1.isSelected = true
                contractDataStatus!.contract_plumbing_option_status = 0
                contract_plumbing_option_Btn2.setBackgroundImage(UIImage(named: "contactUncheck"), for: .normal)
            }
            sender.isSelected = false
            
        }else{
            if sender.tag == 1{
                contract_plumbing_option_Btn2.isSelected = false
                contractDataStatus!.contract_plumbing_option_status = 0
                sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
                contract_plumbing_option_Btn2.setBackgroundImage(UIImage(named: "contactUncheck"), for: .normal)
            }else{
                contract_plumbing_option_Btn.isSelected = false
                contract_plumbing_option_Btn.setBackgroundImage(UIImage(named: "contactUncheck"), for: .normal)
                contractDataStatus!.contract_plumbing_option_status = 1
                sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            }
            
            sender.isSelected = true
            
        }
    }
    
    @IBAction func contract_additional_other_cost_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_additional_other_cost_status = 0
        }else{
            
            contractDataStatus!.contract_additional_other_cost_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_additional_other_subfloor_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_additional_other_subfloor_status = 0
        }else{
            
            contractDataStatus!.contract_additional_other_subfloor_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_additional_other_leveling_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_additional_other_leveling_status = 0
        }else{
            
            contractDataStatus!.contract_additional_other_leveling_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_additional_other_screwdown_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_additional_other_screwdown_status = 0
        }else{
            
            contractDataStatus!.contract_additional_other_screwdown_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
   
    
    @IBAction func contract_additional_other_hardwood_removal_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_additional_other_hardwood_removal_status = 0
        }else{
            
            contractDataStatus!.contract_additional_other_hardwood_removal_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_additional_other_door_removal_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_additional_other_door_removal_status = 0
        }else{
            
            contractDataStatus!.contract_additional_other_door_removal_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    
    @IBAction func contract_additional_other_bifold_removal_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_additional_other_bifold_removal_status = 0
        }else{
            
            contractDataStatus!.contract_additional_other_bifold_removal_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    @IBAction func electronicsAuthorizationBtn1Action(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.electronicsAuthorization1Status = 0
        }else{
            
            contractDataStatus!.electronicsAuthorization1Status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    @IBAction func electronicsAuthorization2Action(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.electronicsAuthorization2Status = 0
        }else{
            
            contractDataStatus!.electronicsAuthorization2Status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    @objc override func doregenerateBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func floorProtectionBtnStatus(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_floor_protection = 0
        }else{
            
            contractDataStatus!.contract_floor_protection = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_right_to_cure_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_right_to_cure_status = 0
        }else{
            
            contractDataStatus!.contract_right_to_cure_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    
    @IBAction func contract_owner_responsibility_status(_ sender: UIButton)
    {
        if sender.isSelected{
            sender.isSelected = false
            contractDataStatus!.contract_owner_responsibility_status = 0
        }else{
            
            contractDataStatus!.contract_owner_responsibility_status = 1
            sender.setBackgroundImage(applicantInitialsImage ?? UIImage(), for: .selected)
            sender.isSelected = true
        }
    }
    // MARK: - VALIDATE FIELDS
    func validateFields() -> (String,CGPoint){
        var alertMessage = ""
        guard contractDataStatus!.contract_owner_reviewed_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_owner_reviewed_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_owner_reviewed_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_transition == 1 else{
            alertMessage = "alertMessage"
            self.contract_transition_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_transition_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_molding_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_molding_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_molding_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        
        guard contractDataStatus!.contract_risk_free_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_risk_free_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_risk_free_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_lifetime_guarantee_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_lifetime_guarantee_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_lifetime_guarantee_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_lead_safe_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_lead_safe_btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_lead_safe_btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_deposit_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_deposit_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_deposit_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_final_payment_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_final_payment_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_final_payment_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        
        guard contractDataStatus!.contract_time_of_performance_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_time_of_performance_btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_time_of_performance_btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_notices_to_owners_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_notices_to_owners_btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_notices_to_owners_btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_notices_of_cancellation == 1 else{
            alertMessage = "alertMessage"
            self.notices_to_cancellation_btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.notices_to_cancellation_btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_scheduling_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_scheduling_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_scheduling_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_motion_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_motion_btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_motion_btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_floor_protection_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_floor_protection_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_floor_protection_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_plumbing_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_plumbing_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_plumbing_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard  contractDataStatus!.contract_plumbing_option_status != -1 else{
            alertMessage = "alertMessage"
            self.contract_plumbing_option_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            self.contract_plumbing_option_Btn2.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_plumbing_option_Btn.frame.origin.y)
            return (alertMessage,postion)
        }

        guard contractDataStatus!.contract_additional_other_cost_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_additional_other_cost_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_additional_other_cost_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_additional_other_subfloor_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_additional_other_subfloor_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_additional_other_subfloor_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_additional_other_leveling_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_additional_other_leveling_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_additional_other_leveling_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_additional_other_screwdown_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_additional_other_screwdown_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_additional_other_screwdown_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_additional_other_hardwood_removal_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_additional_other_hardwood_removal_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_additional_other_hardwood_removal_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_additional_other_bifold_removal_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_additional_other_bifold_removal_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_additional_other_bifold_removal_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_additional_other_door_removal_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_additional_other_door_removal_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_additional_other_door_removal_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        
        guard contractDataStatus!.contract_floor_protection == 1 else{
            alertMessage = "alertMessage"
            self.contract_floor_protection.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_floor_protection.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.contract_right_to_cure_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_right_to_cure_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_right_to_cure_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
       
        guard contractDataStatus!.contract_owner_responsibility_status == 1 else{
            alertMessage = "alertMessage"
            self.contract_owner_responsibility_Btn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.contract_owner_responsibility_Btn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.electronicsAuthorization1Status == 1 else
        {
            alertMessage = "alertMessage"
            self.electronicsAuthorizationBtn.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.electronicsAuthorizationBtn.frame.origin.y)
            return (alertMessage,postion)
        }
        guard contractDataStatus!.electronicsAuthorization2Status == 1 else
        {
            alertMessage = "alertMessage"
            self.electronicsAuthorizationBtn2.setBackgroundImage(UIImage(named: "contactUncheckRed"), for: .normal)
            let postion = CGPoint(x: 0, y: self.electronicsAuthorizationBtn2.frame.origin.y)
            return (alertMessage,postion)
        }
        return (alertMessage,CGPoint.zero)
    }

    override func nextAction()
    { //rooms
//        func createRoomParameters() -> [[String:Any]]{
//            return self.getRoomArrayForApiCall()
//        }
//
//        func createQuestionAnswerForAllRoomsParameter() -> [[String:Any]]{
//            return self.getQuestionAnswerArrayForApiCall()
//        }
//
//        func createCustomerParameter() -> [String:Any]{
//            return self.getCustomerDetailsForApiCall()
//        }
//
//        func createFinalParameterForCustomerApiCall() -> [String:Any]{
//            var customerDict: [String:Any] = [:]
//            customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
//            customerDict["data_completed"] = 0
//            customerDict["customer"] = createCustomerParameter()
//            customerDict["rooms"] = createRoomParameters()
//            customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
//            return ["data":customerDict]
//        }
        
        let (validationMessage,scroolPosition) = self.validateFields()
        if validationMessage.isEmpty
        {
            let comment = ContactCommentPopUpViewController.initialization()!
            comment.delegate = self
            self.present(comment, animated: true, completion: nil)
        }
        else{
            let position = CGPoint(x: scroolPosition.x, y: scroolPosition.y-30)
            scrollView.setContentOffset(position, animated: true)
        }
    }
    
    func sendAddedComments(comment: String, sendHardCopy: Bool,sendFlexInstall:Bool){
        print("COMMENT : \(comment)")
        self.comments = comment
        self.sendPhysicalDocument = sendHardCopy
        self.FlexInstall = sendFlexInstall
        validationOkayProceedWithContract()
    }
    
    func validationOkayProceedWithContract(){

        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "ContractDocument"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        self.saveContractDataToDatabase()
    
        //self.deleteAllAppointmentRequestForThisAppointmentId(appointmentId: appointmentId)
        // change customer data if applicant data is added
        let contactApiData = self.createContractParameters()
        if let applicantDataDict = contactApiData as? [String:Any]
        {
//            if  let applicant = applicantDataDict["application_info_secret"] as? String{
//                if applicant == ""
//                {
//
//                }
//                else
//                {
//                    var applicantData:[String:Any] = [:]
//                    let customerFullDict = JWTDecoder.shared.decodeDict(jwtToken: applicant)
//                    applicantData = (customerFullDict["payload"] as? [String:Any] ?? [:])
//                    self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicantData)
//                }
//            }
            if  let applicant = applicantDataDict["applicationInfo"] as? [String:Any]{
                self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicant)
            }
        }
        //1.
        if isCardVerified == false
        {
        var customerAndRoomData = self.createFinalParameterForCustomerApiCall()
        for (key,value) in contactApiData{
            customerAndRoomData[key] = value
        }
//            let json = (customerAndRoomData as NSDictionary).JsonString()
//            let data = json.data(using: .utf8)
////            let decoder = JSONDecoder()
////            let model = try? decoder.decode(CustomerEncodingDecodingDetails.self, from: data!)
//            var jwtToken:String = String()
//
//            let decoder = JSONDecoder()
//
//            if let data = data, let model = try? decoder.decode(CustomerEncodingDecodingDetails.self, from: data) {
//                print(model)
//                let jwt = JWT<CustomerEncodingDecodingDetails>(header: header, payload: model, signature: signature)
//                jwtToken = JWTEncoder.shared.encode(jwt: jwt) ?? ""
//                print(jwtToken)
//            }
        //customerAndRoomData = ["data":customerAndRoomData]
            
        print(customerAndRoomData)
            createAppointmentsRequestDataToDatabase(title: RequestTitle.CustomerAndRoom, url: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParams: customerAndRoomData as NSDictionary, imageName: "")
        }
        //2.
        
        print(contactApiData)
//        createAppointmentsRequestDataToDatabase(title: RequestTitle.ContactDetails, url: AppURL().syncContactInfo, requestType: RequestType.post, requestParams: contactApiData as NSDictionary, imageName: "")
        //3.
        //arb arb
        let imagesArray = self.allImagesUnderAppointment().filter({$0["image_name"] as! String != ""})
        //            var lastImageDict = imagesArray[imagesArray.count-1]
        //            lastImageDict["data_completed"] = 1
        //            imagesArray[imagesArray.count-1] = lastImageDict
        //            print(imagesArray)
        for imageDict in imagesArray{
            createAppointmentsRequestDataToDatabase(title: RequestTitle.ImageUpload, url: AppURL().syncImageInfo, requestType: RequestType.formData, requestParams: imageDict as NSDictionary, imageName: imageDict["image_name"] as! String)
        }
        //4.
        let appoint_id = String(AppointmentData().appointment_id ?? 0)
        var contract_plumbing_option_1 = 0
        var contract_plumbing_option_2 = 0
        if self.contractDataStatus!.contract_plumbing_option_status == 0{
            contract_plumbing_option_1 = 1
        }else if self.contractDataStatus!.contract_plumbing_option_status == 1{
            contract_plumbing_option_2 = 1
        }
        let recison = UserDefaults.standard.value(forKey: "Recision_Date") as! String
        let requestPara:[String:Any] = ["appointment_id":appoint_id,"contract_plumbing_option_1":contract_plumbing_option_1, "contract_plumbing_option_2" : contract_plumbing_option_2,"recision_date" : recison,"send_physical_document": self.sendPhysicalDocument ? 1 : 0,"additional_comments":self.comments, "flexible_installation": self.FlexInstall ? 1: 0]
        createAppointmentsRequestDataToDatabase(title: RequestTitle.GenerateContract, url: AppURL().syncGenerateContractDocumentInServer, requestType: RequestType.post, requestParams: requestPara as NSDictionary, imageName: "")
        
        let requestParaInitiateSync:[String:Any] = ["appointment_id":appoint_id,"screen_logs":self.getScreenCompletionArrayToSend()]
        let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
        createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
        
        //log entry
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.appointmentLogStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        //arb
        
        //
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func createAppointmentsRequestDataToDatabase(title:RequestTitle,url:String,requestType:RequestType,requestParams:NSDictionary,imageName:String){
        
            self.createAppointmentRequest(requestTitle: title, requestUrl: url, requestType: requestType, requestParameter: requestParams, imageName: imageName)
    }
    // MARK: - ROOM PARAMETERS
    //rooms
    func createRoomParameters() -> [[String:Any]]{
        return self.getRoomArrayForApiCall()
    }
    
    func createQuestionAnswerForAllRoomsParameter() -> [[String:Any]]{
        return self.getQuestionAnswerArrayForApiCall()
    }
    
    func createCustomerParameter() -> [String:Any]{
        return self.getCustomerDetailsForApiCall()
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
        contractDict["payment_method_secret"] = paymentTypeSecret
        contractDict["application_info_secret"] = applicantInfoSecret
        //contractDict["contractInfo"] = contactInfo
//        contractDict["data_completed"] = 0
//        contractDict["appointment_id"] = AppointmentData().appointment_id ?? 0
//        let contractDataDict: [String:Any] = ["data":contractDict]
//        print(contractDataDict)
        return contractDict //contractDataDict
    }
    
    // MARK: - IMAGE PARAMETERS
    //images
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
    //

    
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

extension WebViewViewController: ImagePickerDelegate {

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
