//
//  FinanceViewController.swift
//  Refloor
//
//  Created by Bincy C A on 08/02/24.
//  Copyright © 2024 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

class FinanceViewController: UIViewController, versatileProtocol, CreditApplicationProtocol, ImagePickerDelegate{
    func didSelect(image: UIImage?, imageName: String?) {
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
    }
    func creditApplicationCall(isVersatile: Bool)
    {
        if isVersatile
        {
            self.isVersatile = false
            self.isHunter = true
            
        }
        else
        {
            self.isHunter = false
            self.isVersatile = true
        }
        financeProvider()
    }
    
    func whetherToProceed(isConfirmBtnPressed: Bool) {
        print("")
        if isConfirmBtnPressed
        {
            if HttpClientManager.SharedHM.connectedToNetwork()
            {
                financeProvider()
            }
            else
            {
                self.internetAlert("Please check your internet connection and try again", nil) {
                    self.dismiss(animated: true, completion: nil)
                    
                    let applicant = ApplicantFormViewControllerForm.initialization()!
                    applicant.downOrFinal = self.downOrFinal
                    applicant.totalAmount = self.totalAmount
                    applicant.paymentPlan = self.paymentPlan
                    applicant.paymentPlanValue = self.paymentPlanValue
                    applicant.paymentOptionDataValue = self.paymentOptionDataValue
                    applicant.drowingImageID = self.drowingImageID
                    applicant.area = self.area
                    applicant.downPaymentValue = self.downPaymentValue
                    applicant.finalpayment = self.finalpayment
                    applicant.financePayment = self.financePayment
                    applicant.selectedPaymentMethord = self.selectedPaymentMethord
                    applicant.downpayment = self.downpayment
                    applicant.packagePlanName = self.packagePlanName
                    self.navigationController?.pushViewController(applicant, animated: true)
                }
            }
        }
        else
        {
            let applicant = ApplicantFormViewControllerForm.initialization()!
            applicant.downOrFinal = self.downOrFinal
            applicant.totalAmount = self.totalAmount
            applicant.paymentPlan = self.paymentPlan
            applicant.paymentPlanValue = self.paymentPlanValue
            applicant.paymentOptionDataValue = self.paymentOptionDataValue
            applicant.drowingImageID = self.drowingImageID
            applicant.area = self.area
            applicant.downPaymentValue = self.downPaymentValue
            applicant.finalpayment = self.finalpayment
            applicant.financePayment = self.financePayment
            applicant.selectedPaymentMethord = self.selectedPaymentMethord
            applicant.downpayment = self.downpayment
            applicant.packagePlanName = self.packagePlanName
            self.navigationController?.pushViewController(applicant, animated: true)
        }
        
            
        
    }
    
    
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var versatileBtnImage: UIImageView!
    @IBOutlet weak var versatileStackView: UIStackView!
    @IBOutlet weak var hunterBtnImage: UIImageView!
    @IBOutlet weak var hunterStackView: UIStackView!
    @IBOutlet weak var skipBtnLeadingConstraint: NSLayoutConstraint!
    var imagePicker: CaptureImage!
    var isHunter = false
    var isVersatile = false
    var downOrFinal:Double = 0
    var totalAmount:Double = 0
    var paymentPlan:PaymentPlanValue?
    var downPaymentValue:Double = 0
    var finalpayment:Double = 0
    var financePayment:Double = 0
    var paymentPlanValue:PaymentPlanValue?
    var paymentOptionDataValue:PaymentOptionDataValue?
    var drowingImageID = 0
    var area:Double = 0
    var adminFee:Double = 0
    var selectedPaymentMethord:PaymentType?
    var downpayment = DownPaymentViewController.initialization()!
    var externalCredentialsArray:List<rf_extrenal_credential_results>!
    var totalPrice:Double = Double()
    var finalPayment:Double = Double()
    var financeAmount:Double = Double()
    var packagePlanName = ""
    static func initialization() -> FinanceViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "FinanceViewController") as? FinanceViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarbackAndlogo(with: "FINANCE PROVIDER".uppercased())
        externalCredentialsArray = externalCredentialsValue()
    }
    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePicker = CaptureImage(presentationController: self, delegate: self)
            self.imagePicker.present(from: sender)
            
        }
    @IBAction func hunterBtnAction(_ sender: UIButton)
    {
        print("hunter")
        isHunter = !isHunter
        isVersatile = false
        proceedBtn.isHidden = false
        if isHunter
        {
            hunterStackView.backgroundColor = UIColor().colorFromHexString("#292562")
            hunterStackView.borderWidth = 2
            hunterStackView.borderColor = UIColor().colorFromHexString("#D29B3C")
            hunterBtnImage.image = UIImage(named: "selectedRound")
            
            versatileStackView.backgroundColor = UIColor().colorFromHexString("#2D343D")
            versatileStackView.borderWidth = 1
            versatileStackView.borderColor = UIColor().colorFromHexString("#586471")
            //notSelected
            versatileBtnImage.image = UIImage(named: "notSelected")
            skipBtnLeadingConstraint.constant = 346
        }
        else
        {
            hunterStackView.backgroundColor = UIColor().colorFromHexString("#2D343D")
            hunterStackView.borderWidth = 1
            hunterStackView.borderColor = UIColor().colorFromHexString("#586471")
            hunterBtnImage.image = UIImage(named: "notSelected")
            proceedBtn.isHidden = true
            skipBtnLeadingConstraint.constant = 70
        }
    }
    
    @IBAction func versatileBtnAction(_ sender: UIButton)
    {
        print("versatile")
        isVersatile = !isVersatile
        isHunter = false
        proceedBtn.isHidden = false
        if isVersatile
        {
            
                versatileStackView.backgroundColor = UIColor().colorFromHexString("#292562")
            versatileStackView.borderWidth = 2
            versatileStackView.borderColor = UIColor().colorFromHexString("#D29B3C")
            versatileBtnImage.image = UIImage(named: "selectedRound")
            
            hunterStackView.backgroundColor = UIColor().colorFromHexString("#2D343D")
            hunterStackView.borderWidth = 1
            hunterStackView.borderColor = UIColor().colorFromHexString("#586471")
            hunterBtnImage.image = UIImage(named: "notSelected")
            skipBtnLeadingConstraint.constant = 346
            }
            else
            {
                versatileStackView.backgroundColor = UIColor().colorFromHexString("#2D343D")
                versatileStackView.borderWidth = 1
                versatileStackView.borderColor = UIColor().colorFromHexString("#586471")
                //notSelected
                versatileBtnImage.image = UIImage(named: "notSelected")
                proceedBtn.isHidden = true
                skipBtnLeadingConstraint.constant = 70            }
    }
    
    @IBAction func skipBtnAction(_ sender: UIButton)
    {
        let applicant = ApplicantFormViewControllerForm.initialization()!
        applicant.downOrFinal = self.downOrFinal
        applicant.totalAmount = self.totalAmount
        applicant.paymentPlan = self.paymentPlan
        applicant.paymentPlanValue = self.paymentPlanValue
        applicant.paymentOptionDataValue = self.paymentOptionDataValue
        applicant.drowingImageID = self.drowingImageID
        applicant.area = self.area
        applicant.downPaymentValue = self.downPaymentValue
        applicant.finalpayment = self.finalpayment
        applicant.financePayment = self.financePayment
        applicant.selectedPaymentMethord = self.selectedPaymentMethord
        applicant.downpayment = self.downpayment
        applicant.packagePlanName = self.packagePlanName
        self.navigationController?.pushViewController(applicant, animated: true)
    }
    @IBAction func proceedBtnAction(_ sender: UIButton)
    {
        if HttpClientManager.SharedHM.connectedToNetwork() && externalCredentialsArray.count > 0
        {
            let selectRoomPopUp = SelectRoomCommentPopUpViewController.initialization()!
            selectRoomPopUp.versatile = self
            selectRoomPopUp.isVersatile = self.isVersatile
            selectRoomPopUp.isHunter = self.isHunter
            selectRoomPopUp.isdelete = false
            self.present(selectRoomPopUp, animated: true, completion: nil)
        }
        else
        {
            self.internetAlert("Please check your internet connection and try again", nil) {
                self.dismiss(animated: true, completion: nil)
                
                let applicant = ApplicantFormViewControllerForm.initialization()!
                applicant.downOrFinal = self.downOrFinal
                applicant.totalAmount = self.totalAmount
                applicant.paymentPlan = self.paymentPlan
                applicant.paymentPlanValue = self.paymentPlanValue
                applicant.paymentOptionDataValue = self.paymentOptionDataValue
                applicant.drowingImageID = self.drowingImageID
                applicant.area = self.area
                applicant.downPaymentValue = self.downPaymentValue
                applicant.finalpayment = self.finalpayment
                applicant.financePayment = self.financePayment
                applicant.selectedPaymentMethord = self.selectedPaymentMethord
                applicant.downpayment = self.downpayment
                applicant.packagePlanName = self.packagePlanName
                self.navigationController?.pushViewController(applicant, animated: true)
            }
        }
    }
    
    func financeProvider()
    {
        let customer = AppDelegate.appoinmentslData!
        let primaryApplicantAddress:[String:Any] = ["addressLine1":customer.street!,"addressLine2":customer.street2!,"city":customer.city!,"state":customer.state!,"postalCode":customer.zip!]
        let jointApplicantAddress:[String:Any] = ["addressLine1":customer.co_applicant_address ?? "","addressLine2":customer.co_applicant_city ?? "","city":customer.co_applicant_city ?? "","state":customer.co_applicant_state  ?? "","postalCode":customer.co_applicant_zip ?? ""]
        let primaryApplicant:[String:Any] = ["firstName":customer.applicant_first_name ?? "","middleInitial":customer.applicant_middle_name ?? "","lastName":customer.applicant_last_name ?? "","dateOfBirth":(isHunter ? nil : ""),"email":customer.email ?? "","homePhone":customer.phone ?? "","mobilePhone":((isHunter && customer.mobile == "") ? customer.phone: customer.mobile ?? ""),"workPhone":"","address":primaryApplicantAddress]
        let jointApplicant:[String:Any] = ["firstName":customer.co_applicant_first_name ?? "","middleInitial":customer.co_applicant_middle_name ?? "","lastName":customer.co_applicant_last_name ?? "","dateOfBirth": (isHunter ? nil : ""),"email":customer.co_applicant_email ?? "","homePhone":customer.co_applicant_phone ?? "","mobilePhone":((isHunter && customer.co_applicant_phone == "") ? customer.co_applicant_secondary_phone: customer.co_applicant_phone ?? ""),"workPhone":"","address":jointApplicantAddress]
        let salesPerson = customer.sales_person?.split(separator: " ")
        let salesPersonFirstName = salesPerson?[0]
        let salesPersonLastName = salesPerson?[1]
        let salesPersonEmail = UserDefaults.standard.value(forKey: "salesPersonEmail") as! String
        var versatileTotalPrice:Double = 0.0
        if isVersatile
        {
            if totalAmount + adminFee < 3500
            {
                versatileTotalPrice = 3500
            }
            else
            {
                versatileTotalPrice = totalAmount + adminFee
            }
        }
        
        let prefillDictionary:[String:Any] = ["expectedPurchaseAmount": isHunter ?  (totalAmount + adminFee) : (versatileTotalPrice) * 100,"downPaymentAmount" :isHunter ? downPaymentValue : (downPaymentValue * 100),"primaryApplicant":primaryApplicant,"jointApplicant":jointApplicant,"salesAssociate":"RCB","salesAssociateFirstName":salesPersonFirstName ?? "","salesAssociateLastName":salesPersonLastName ?? "","salesAssociateEmail":salesPersonEmail]
        let parameter:[String:Any] = ["prefill":prefillDictionary,"mode":"full","prequalificationId":"d0a88bb7-4fbd-43c6-9839-340e8c5308ff","applicationId":"861625fa-b505-4924-a933-e5dbf91efa20","returnUrl":"https://versatilecredit.com/landingpage", "externalCustomerId": customer.improveit_appointment_id ?? ""]
        
        if isHunter //https://hunterfinancedev.oneteamus.com/refloor-request
        {
            let hunterArray = externalCredentialsArray.filter({$0.provider == "hunter"})
            if hunterArray.count > 0
            {
                hunterCall(parameter: parameter, customer: customer, url: (hunterArray.first?.url)!, apiKey: (hunterArray.first?.apiKey)!, entityKey: (hunterArray.first?.entityKey)!)
            }
            
        }
        else
        {
            let versatileArray = externalCredentialsArray.filter({$0.provider == "versatile"})
            if customer.externalEntityKey.count > 0
            {
                versatileCall(parameter: parameter, customer: customer,url:(versatileArray.first?.url)!,apiKey: (versatileArray.first?.apiKey)!,entityKey: customer.externalEntityKey[0].entityKey ?? "")
            }
            else
            {
                self.alert("Versatile credit application feature is not available for your location", nil)
            }
        }
    }
    
    func hunterCall(parameter:[String:Any], customer:AppoinmentDataValue,url:String,apiKey:String,entityKey:String)
    {
        HttpClientManager.SharedHM.hunterAPi(url: url, apiKey: apiKey, entityKey: entityKey,parameter: parameter) { success,url in
            if success == "redirect"
            {
                let versatile = VersatileViewController.initialization()!
                versatile.creditApplicationDelegate = self
                versatile.url = url ?? ""
                versatile.downOrFinal = self.downOrFinal
                versatile.totalAmount = self.totalAmount
                versatile.paymentPlan = self.paymentPlan
                versatile.paymentPlanValue = self.paymentPlanValue
                versatile.paymentOptionDataValue = self.paymentOptionDataValue
                versatile.drowingImageID = self.drowingImageID
                versatile.area = self.area
                versatile.downPaymentValue = self.downPaymentValue
                versatile.finalpayment = self.finalpayment
                versatile.financePayment = self.financePayment
                versatile.selectedPaymentMethord = self.selectedPaymentMethord
                versatile.downpayment = self.downpayment
                versatile.appointmentId = customer.id!
                versatile.isHunter = true
                versatile.finalpayment = self.finalpayment
                versatile.financePayment = self.financePayment
                versatile.selectedPaymentMethord = self.selectedPaymentMethord
                versatile.downpayment = self.downpayment
                if let customer = AppDelegate.appoinmentslData
                {
                    versatile.isCoAppSkiped = customer.co_applicant_skipped ?? 0
                }
                self.navigationController?.pushViewController(versatile, animated: true)
            }
        }
    }
    
    func versatileCall(parameter:[String:Any], customer:AppoinmentDataValue,url:String,apiKey:String,entityKey:String)
    {
        print("entityKey",entityKey)
        print("apikey",apiKey)
        HttpClientManager.SharedHM.versatileAPi(url: url, apiKey: apiKey, entityKey: entityKey,parameter: parameter) { success,url in
            if success == "redirect"
            {
                let versatile = VersatileViewController.initialization()!
                versatile.creditApplicationDelegate = self
                versatile.url = url ?? ""
                versatile.downOrFinal = self.downOrFinal
                versatile.totalAmount = self.totalAmount
                versatile.paymentPlan = self.paymentPlan
                versatile.paymentPlanValue = self.paymentPlanValue
                versatile.paymentOptionDataValue = self.paymentOptionDataValue
                versatile.drowingImageID = self.drowingImageID
                versatile.area = self.area
                versatile.downPaymentValue = self.downPaymentValue
                versatile.finalpayment = self.finalpayment
                versatile.financePayment = self.financePayment
                versatile.selectedPaymentMethord = self.selectedPaymentMethord
                versatile.downpayment = self.downpayment
                versatile.appointmentId = customer.id!
                versatile.isVersatile = true
                if let customer = AppDelegate.appoinmentslData
                {
                    versatile.isCoAppSkiped = customer.co_applicant_skipped ?? 0
                }
                self.navigationController?.pushViewController(versatile, animated: true)
            }
        }
    }
}
