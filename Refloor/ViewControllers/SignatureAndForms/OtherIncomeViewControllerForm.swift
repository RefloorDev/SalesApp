//
//  OtherIncomeViewController.swift
//  Refloor
//
//  Created by sbek on 21/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class OtherIncomeViewControllerForm: UIViewController,DropDownDelegate,UITextFieldDelegate {
    static public func initialization() -> OtherIncomeViewControllerForm? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "OtherIncomeViewControllerForm") as? OtherIncomeViewControllerForm
    }
    
    
    @IBOutlet weak var typeOfProperperty: UITextField!
    @IBOutlet weak var workDone: UITextField!
    @IBOutlet weak var sourceOfIncome: UITextField!
    @IBOutlet weak var earningFromEmployment: UITextField!
    @IBOutlet weak var additionalIncomeSource: UITextField!
    @IBOutlet weak var periodofEarnings: UITextField!
    
    @IBOutlet weak var nearestReletive: UITextField!
    @IBOutlet weak var relationship: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var mortgage: UITextField!
    @IBOutlet weak var lenderFirstName: UITextField!
    @IBOutlet weak var lenderMiddleName: UITextField!
    @IBOutlet weak var landerLastName: UITextField!
    @IBOutlet weak var landerPhoneNumber: UITextField!
    @IBOutlet weak var monthlyMortgageAmount: UITextField!
    @IBOutlet weak var presentBalance: UITextField!
    @IBOutlet weak var presentValueOfHome: UITextField!
    @IBOutlet weak var otherPhoneNumber: UITextField!
    @IBOutlet weak var InsuranceCompany: UITextField!
    @IBOutlet weak var agent: UITextField!
    @IBOutlet weak var insurenceCompanyNumber: UITextField!
    @IBOutlet weak var coverage: UITextField!
    @IBOutlet weak var owners: UITextField!
    @IBOutlet weak var ownersType: UITextField!
    @IBOutlet weak var addressToBeImporove: UITextField!
    @IBOutlet weak var addressToBeImprov: UIButton!
    @IBOutlet weak var sourceOfIncomeSelectBtn: UIButton!
    
    @IBOutlet weak var addressToBeImproveType: UITextField!
    var GMSTag = 0
    @IBOutlet weak var typeofloan: UITextField!
    
    @IBOutlet weak var lenderDetails: UITextField!
    @IBOutlet weak var orginalAmount: UITextField!
    @IBOutlet weak var presentBalanceAmount: UITextField!
    @IBOutlet weak var monthlypaymentAmount: UITextField!
    @IBOutlet weak var otherObligations: UITextField!
    @IBOutlet weak var totalMonthlyPayments: UITextField!
    @IBOutlet weak var checkingAccountNumber: UITextField!
    @IBOutlet weak var nameOfBank: UITextField!
    @IBOutlet weak var checkingRoutingNumber: UITextField!
    
    @IBOutlet weak var dateAcquired: UITextField!
    @IBOutlet weak var secondMortgage: UISegmentedControl!
    @IBOutlet weak var otherIncomeSegment: UISegmentedControl!
    
    
    @IBOutlet weak var landerAddress: UITextField!
    
    
    
    
    @IBOutlet weak var orginalPurchasePrice: UITextField!
    @IBOutlet weak var orginalMortagageAmount: UITextField!
    
    @IBOutlet weak var termsCondition: UIImageView!
    @IBOutlet weak var termsConditionLabel: UILabel!
    @IBOutlet weak var termsHunterLabel: UILabel!
    
    @IBOutlet weak var HuntertermsCondition: UIImageView!
    
    var typeOfPropertyChangeTag = 1
    var workDoneChangeTag = 2
    var sourceOfIncomeChangeTag = 3
    var periodofEarningChangeTag = 4
    var relationshipChangeTag = 5
    var mortgageChangeTag = 6
    var typeofloanTag = 7
    var ownersTag = 8
    var addressTobeTag = 9
    var selectedPaymentMethord:PaymentType?
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
    
    let datePicker = UIDatePicker()
    var applicantData:ApplicationData!
    var coApplicantData:CoApplicationData?
    var downpayment = DownPaymentViewController.initialization()!
    var isCoAppSkiped = 0
    var istearmAndCondition = false
    var ishuntertearmAndCondition = false
    var huntertearmStatus = "No"
    var imagePicker: CaptureImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.otherIncomeSegment.selectedSegmentIndex = 1
        self.otherIncomeSegment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .touchUpInside)
        self.otherIncomeSegment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        self.sourceOfIncome.isUserInteractionEnabled = false
        self.additionalIncomeSource.isUserInteractionEnabled = false
        self.sourceOfIncomeSelectBtn.isUserInteractionEnabled = false
        
        self.setNavigationBarbackAndlogo(with: "Other Income & Obligations".uppercased())
        typeOfProperperty.setPlaceHolderWithColor(placeholder: "First Name", colour: UIColor.placeHolderColor)
        workDone.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        sourceOfIncome.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //earningFromEmployment.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        additionalIncomeSource.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        
        periodofEarnings.setPlaceHolderWithColor(placeholder: "Last Name", colour: UIColor.placeHolderColor)
        nearestReletive.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        relationship.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        phoneNumber.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //   address.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        mortgage.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        lenderFirstName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //  owners.isUserInteractionEnabled = false
        addressToBeImporove.isUserInteractionEnabled = false
        //   address.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //  lenderMiddleName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //  dateAcquired.setPlaceHolderWithColor(placeholder: "MM/DD/YYYY", colour: UIColor.placeHolderColor)
        // landerLastName.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // landerPhoneNumber.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        monthlyMortgageAmount.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        monthlyMortgageAmount.delegate = self
        presentBalance.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        presentBalance.delegate = self
        presentValueOfHome.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        presentValueOfHome.delegate = self
        //  otherPhoneNumber.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // InsuranceCompany.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // agent.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // insurenceCompanyNumber.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // coverage.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        lenderDetails.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        orginalAmount.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        orginalAmount.delegate = self
        additionalIncomeSource.delegate = self
        presentBalanceAmount.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        presentBalanceAmount.delegate = self
        monthlypaymentAmount.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        monthlypaymentAmount.delegate = self
        //    otherObligations.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //   otherObligations.delegate = self
        //  totalMonthlyPayments.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //totalMonthlyPayments.delegate = self
        checkingAccountNumber.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        checkingAccountNumber.delegate = self
        checkingRoutingNumber.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        checkingRoutingNumber.delegate = self
        nameOfBank.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //   landerAddress.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        orginalPurchasePrice.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        orginalPurchasePrice.delegate = self
        orginalMortagageAmount.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        orginalPurchasePrice.delegate = self
        
        typeofloan.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        monthlypaymentAmount.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        monthlypaymentAmount.delegate = self
        addressToBeImporove.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //  owners.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        orginalMortagageAmount.delegate = self
        
        let font = UIFont(name: "Avenir-Medium", size: 22)!
        secondMortgage.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        otherIncomeSegment.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        
        var paymentPlanDropdownString = ""
        
        if(self.paymentOptionDataValue?.sequenceid == 1)
        
        {
            paymentPlanDropdownString = "One Year no Payments"
            
        }
        else if(self.paymentOptionDataValue?.sequenceid == 2 || self.paymentOptionDataValue?.sequenceid == 3)
        
        {
            paymentPlanDropdownString = "No Interest"
            
        }
        else
        {
            paymentPlanDropdownString = "Low Payment"
        }
        
        
        self.DropDownDidSelectedAction(0, paymentPlanDropdownString, typeofloanTag)
        self.DropDownDidSelectedAction(0, "SAME AS APPLICANT", ownersTag)
        self.DropDownDidSelectedAction(0, "SAME AS APPLICANT", addressTobeTag)
        self.DropDownDidSelectedAction(0, "Single Family", typeOfPropertyChangeTag)
        self.DropDownDidSelectedAction(0, "FLOORING", workDoneChangeTag)
        self.DropDownDidSelectedAction(0, "MORTGAGE", mortgageChangeTag)
        // self.DropDownDidSelectedAction(0, "Single", relationshipChangeTag)
        self.DropDownDidSelectedAction(0, "Monthly", periodofEarningChangeTag)
        self.DropDownDidSelectedAction(0, "Select", sourceOfIncomeChangeTag)
        
        let tap100 = UITapGestureRecognizer(target: self, action: #selector(termsandconditions))
        tap100.numberOfTapsRequired = 1
        
        let tap101 = UITapGestureRecognizer(target: self, action: #selector(termsandconditionsAction))
        tap101.numberOfTapsRequired = 1
        self.termsCondition.isUserInteractionEnabled = true
        self.termsCondition.addGestureRecognizer(tap101)
        
        self.termsConditionLabel.addGestureRecognizer(tap100)
        self.termsConditionLabel.isUserInteractionEnabled = true
        self.termsCondition.image = UIImage(named: "deselectedRound")
        
        
        let tap102 = UITapGestureRecognizer(target: self, action: #selector(HuntertermsandconditionsAction))
        tap102.numberOfTapsRequired = 1
        self.HuntertermsCondition.isUserInteractionEnabled = true
        self.HuntertermsCondition.addGestureRecognizer(tap102)
        let tap103 = UITapGestureRecognizer(target: self, action: #selector(HuntertermsandconditionsAction))
        tap103.numberOfTapsRequired = 1
        self.termsHunterLabel.isUserInteractionEnabled = true
        self.termsHunterLabel.addGestureRecognizer(tap103)
        // self.termsConditionLabel.addGestureRecognizer(tap100)
        // self.termsConditionLabel.isUserInteractionEnabled = true
        self.HuntertermsCondition.image = UIImage(named: "deselectedRound")
        self.addressToBeImprov.isHidden = true
        
        setPhoneNumberDelegate()
    }
    
    @objc func termsandconditionsAction()
    {
        if !istearmAndCondition
        {
            istearmAndCondition = true
            self.termsCondition.image = UIImage(named: "BigTick")
        }
        else
        {
            istearmAndCondition = false
            self.termsCondition.image = UIImage(named: "deselectedRound")
        }
        
    }
    @objc func HuntertermsandconditionsAction()
    {
        if !ishuntertearmAndCondition
        {
            ishuntertearmAndCondition = true
            huntertearmStatus = "Yes"
            self.HuntertermsCondition.image = UIImage(named: "BigTick")
        }
        else
        {
            ishuntertearmAndCondition = false
            huntertearmStatus = "No"
            self.HuntertermsCondition.image = UIImage(named: "deselectedRound")
        }
        
    }
    @objc func termsandconditions()
    {
        
        self.present(ImportentAgreementViewController.initialization()!, animated: true, completion: nil)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl)  {
        if sender.selectedSegmentIndex == 0
        {
            
            self.sourceOfIncome.isUserInteractionEnabled = true
            self.additionalIncomeSource.isUserInteractionEnabled = true
            self.sourceOfIncomeSelectBtn.isUserInteractionEnabled = true
            
        }
        else
        {
            // self.DropDownDidSelectedAction(0, "Select", sourceOfIncomeChangeTag)
            self.sourceOfIncome.isUserInteractionEnabled = false
            self.additionalIncomeSource.isUserInteractionEnabled = false
            self.sourceOfIncomeSelectBtn.isUserInteractionEnabled = false
            self.additionalIncomeSource.text = ""
            self.sourceOfIncome.text = "Select"
            
            //  _ = self.sourceOfIncome.text == "Select" ? "" : self.sourceOfIncome.text
            
        }
        
    }
    @IBAction func exEmployeraddressDidBigen(_ sender: UITextField) {
        self.GMSTag = 3
        googleMapPlaceSearchPopUp()
        //getMapPlaces(words: sender.text ?? "", sender: sender, tag: 11)
    }
    @IBAction func presentEmployeraddressDidBigen(_ sender: UITextField) {
        self.GMSTag = 2
        googleMapPlaceSearchPopUp()
        //getMapPlaces(words: sender.text ?? "", sender: sender, tag: 11)
    }
    @IBAction func exaddressDidBigen(_ sender: UITextField) {
        self.GMSTag = 1
        googleMapPlaceSearchPopUp()
    }
    
    @IBAction func laanderaddressDidBigen(_ sender: UITextField) {
        self.GMSTag = 0
        googleMapPlaceSearchPopUp()
    }
    @IBAction func ownersTypeaddressDidBigen(_ sender: UITextField) {
        self.GMSTag = 4
        googleMapPlaceSearchPopUp()
    }
    @IBAction func addressTobeDidBigen(_ sender: UITextField) {
        self.GMSTag = 5
        googleMapPlaceSearchPopUp()
    }
    @IBAction func addressTobeForGoogleButttonAction(_ sender: UIButton) {
        //        let getaddress = AddressEntryViewController.initialization()!
        //        getaddress.delegate = self
        //        getaddress.delegateTag = 11
        //        getaddress.address = self.address.text ?? ""
        //        self.present(getaddress, animated: true, completion: nil)
        self.GMSTag = 5
        googleMapPlaceSearchPopUp()
    }
    func googleMapPlaceSearchPopUp()
    {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    func setPhoneNumberDelegate()
    {
        // self.landerPhoneNumber.delegate = self
        self.phoneNumber.delegate = self
        // self.otherPhoneNumber.delegate = self
        // self.insurenceCompanyNumber.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil
        {
            
            if(textField == self.phoneNumber || textField == self.landerPhoneNumber || textField == self.otherPhoneNumber || textField == self.insurenceCompanyNumber )
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
    @IBAction func typeOfLoanChange(_ sender: UIButton) {
        //        let array = ["NO LOAN APPLIED","LOW PAYMENT","NO INTEREST"]
        //        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.typeofloanTag)
    }
    @IBAction func ownersChange(_ sender: UIButton) {
        let array = ["SAME AS APPLICANT","DIFFERENT"]
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.ownersTag)
    }
    @IBAction func addressToBeImporvedChange(_ sender: UIButton) {
        let array = ["SAME AS APPLICANT","DIFFERENT"]
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.addressTobeTag)
    }
    
    
    
    
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        if(validation() != "")
        {
            self.alert(validation(), nil)
            return
        }
        //arb
        //
        var dateOfSignature = Date().SignatureDate()
        dateOfSignature = dateOfSignature.replacingOccurrences(of: "/", with: "-")
        let otherIncome = OtherIncomeData(sourceOfOtherIncome: self.sourceOfIncome.text == "Select" ? "" : self.sourceOfIncome.text ?? "", amountMonthly: Int(Double(self.monthlypaymentAmount.text ?? "") ?? 0), nearestRelative: self.nearestReletive.text ?? "", relationship: self.relationship.text ?? "", addressRelationship: "", addressRelationshipStreet: "", addressRelationshipStreet2: "", addressRelationshipCity: "", addressRelationshipState: "", addressRelationshipZip: "", phoneNumberRelationhip:  self.phoneNumber.text ?? "", propertyDetails: self.mortgage.text ?? "", applicant_mortgage_company: self.lenderFirstName.text ?? "", additional_monthly_income: (Double(self.additionalIncomeSource.text ?? "0.0") ?? 0.0) , lenderAddressStreet: "", lenderAddressStreet2: "", lenderAddressCity: "", lenderAddressState: "", lenderAddressZip: "", lenderPhone: "", originalPurchasePrice: Double(self.orginalPurchasePrice.text ?? "0.0") ?? 0.0, originalMortageAmount:(Double(self.orginalMortagageAmount.text ?? "0.0") ?? 0.0) , monthlyMortagePayment: (Double(self.monthlyMortgageAmount.text ?? "0.0") ?? 0.0), dateAquired: "", presentBalance: (Double(self.presentBalance.text ?? "0.0") ?? 0.0), presentValueOfHome: (Double(self.presentValueOfHome.text ?? "0.0") ?? 0.0), secondMortage: self.secondMortgage.titleForSegment(at:                                 self.secondMortgage.selectedSegmentIndex) ?? "", lenderNameOrPhone: self.lenderDetails.text ?? "", originalAmount:(Double(self.orginalAmount.text ?? "0.0") ?? 0.0), presentBalanceSecondMortage: (Double(self.presentBalanceAmount.text ?? "0.0") ?? 0.0), monthlyPayment: (Double(self.monthlypaymentAmount.text ?? "0.0") ?? 0.0), otherObligations: "0", totalMonthlyPayments: 0, checkingAccountNo: self.checkingAccountNumber.text ?? "", nameOfBank: self.nameOfBank.text ?? "", bankPhoneNumber: "", insuranceCompany: "", agent: "", insurancePhoneNo: "", coverage: "", typeOfCreditRequested: self.applicantData.type_of_credit_requested ?? "", additional_income: self.otherIncomeSegment.titleForSegment(at: self.otherIncomeSegment.selectedSegmentIndex) ?? "", second_mortage:  self.secondMortgage.titleForSegment(at: self.secondMortgage.selectedSegmentIndex) ?? "", lender_name_or_phone: self.lenderDetails.text ?? "", checking_account_no: self.checkingAccountNumber.text ?? "", checking_routing_no: self.checkingRoutingNumber.text ?? "", name_of_bank: self.nameOfBank.text ?? "", applicant_signature_date: dateOfSignature, co_applicant_signature_date: dateOfSignature, hunterMessageStatus: huntertearmStatus, present_balance: (Double(self.presentBalance.text ?? "0.0") ?? 0.0), present_value_of_home: (Double(self.presentValueOfHome.text ?? "0.0") ?? 0.0), original_amount: (Double(self.orginalAmount.text ?? "0.0") ?? 0.0), present_balance_second_mortage: self.secondMortgage.titleForSegment(at: self.secondMortgage.selectedSegmentIndex) ?? "", monthly_payment: (Double(self.monthlypaymentAmount.text ?? "0.0") ?? 0.0), lenderName: self.lenderDetails.text ?? "")
        let rf_OtherIncomeInfo = rf_OtherIncomeData(otherIncomeData: otherIncome)
        self.saveOtherIncomeDetailsToAppointmentDetail(otherIncomeInfo:rf_OtherIncomeInfo)
        
        //let parameter:[String:Any] = ["token": UserData.init().token ?? "","data":self.getParameterForRefloorLocalAppsteamOdooServer()]
        let parameter:[String:Any] = ["data":self.getParameterForRefloorLocalAppsteamOdooServer()]
        self.saveApplicantAndIncomeDataToAppointmentDetail(data: (parameter as NSDictionary))
        let signature = SignatureSubmitViewController.initialization()!
        signature.downOrFinal = self.downOrFinal
        signature.totalAmount = self.totalAmount
        signature.paymentPlan = self.paymentPlan
        signature.paymentPlanValue = self.paymentPlanValue
        signature.paymentOptionDataValue = self.paymentOptionDataValue
        signature.drowingImageID = self.drowingImageID
        signature.area = self.area
        signature.downPaymentValue = self.downPaymentValue
        signature.finalpayment = self.finalpayment
        signature.financePayment = self.financePayment
        signature.selectedPaymentMethord = self.selectedPaymentMethord
        signature.downpayment = self.downpayment
        signature.isCoAppSkiped = self.isCoAppSkiped
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "OtherIncomeObligation"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        self.navigationController?.pushViewController(signature, animated: true)
        
        //test
        let dict = self.getApplicantAndIncomeDataFromAppointmentDetail()
        print(dict)
        //
        
//        HttpClientManager.SharedHM.createcreditapplication(parameter: parameter) { (result, message) in
//            if (result ?? "").lowercased() == "success" ||  (result ?? "").lowercased() == "true"
//            {
//                let signature = SignatureSubmitViewController.initialization()!
//                signature.downOrFinal = self.downOrFinal
//                signature.totalAmount = self.totalAmount
//                signature.paymentPlan = self.paymentPlan
//                signature.paymentPlanValue = self.paymentPlanValue
//                signature.paymentOptionDataValue = self.paymentOptionDataValue
//                signature.drowingImageID = self.drowingImageID
//                signature.area = self.area
//                signature.downPaymentValue = self.downPaymentValue
//                signature.finalpayment = self.finalpayment
//                signature.financePayment = self.financePayment
//                signature.selectedPaymentMethord = self.selectedPaymentMethord
//                signature.downpayment = self.downpayment
//                signature.isCoAppSkiped = self.isCoAppSkiped
//                self.navigationController?.pushViewController(signature, animated: true)
//            }
//            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
//            {
//
//                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
//
//                    self.fourceLogOutbuttonAction()
//                }
//
//                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
//
//            }
//            else
//            {
//                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//
//                    self.nextButtonAction(UIButton())
//                }
//                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
//                //  self.alert(message ?? "", nil)
//
//            }
//        }
        
        
        //        HttpClientManager.SharedHM.FormUpdateApi(parameter: parameter) { (status, value) in
        //            if(status ?? "").lowercased() == "success"
        //            {
        //                let signature = SignatureSubmitViewController.initialization()!
        //                    signature.downOrFinal = self.downOrFinal
        //                    signature.totalAmount = self.totalAmount
        //                    signature.paymentPlan = self.paymentPlan
        //                    signature.paymentPlanValue = self.paymentPlanValue
        //                    signature.paymentOptionDataValue = self.paymentOptionDataValue
        //                    signature.drowingImageID = self.drowingImageID
        //                    signature.area = self.area
        //                    signature.downPaymentValue = self.downPaymentValue
        //                    signature.finalpayment = self.finalpayment
        //                    signature.financePayment = self.financePayment
        //                    signature.selectedPaymentMethord = self.selectedPaymentMethord
        //                    signature.downpayment = self.downpayment
        //                self.navigationController?.pushViewController(signature, animated: true)
        //            }
        //            else
        //            {
        //                self.alert("The from updation is failed", nil)
        //            }
        //        }
        
    }
    /*  func getParameterForRefloorOfficialServer() -> [String:Any]
     {
     return  [
     "Applicant_Amount_Financed" : self.financePayment,
     "Applicant_Cell_Phone" : self.applicantData.cellPhone ?? "",
     "Applicant_Checking_Account" :self.checkingAccountNumber.text ?? "",
     "Applicant_Checking_Account_Bank" : self.nameOfBank.text ?? "",
     "Applicant_Checking_Account_Bank_Phone" : self.otherPhoneNumber.text ?? "",
     "Applicant_City" : self.applicantData.addressOfApplicantCity ?? "",
     "Applicant_Current_Lender_Address" : self.landerAddress.text ?? "",
     "Applicant_Current_Lender_Phone" : self.landerPhoneNumber.text ?? "",
     "Applicant_Current_Mortgage_Balance" : self.orginalMortagageAmount.text ?? "",
     "Applicant_Date_of_Birth" : self.applicantData.dateOfBirth ?? "",
     "Applicant_Down_Payment" : self.downPaymentValue,
     "Applicant_Drivers_License/State_ID" :self.applicantData.driversLicense ?? "",
     "Applicant_Drivers_License_Expiration_Dat" : self.applicantData.driversLicenseExpDate ?? "",
     "Applicant_Earning_Period" : "Monthly",
     "Applicant_Earnings_per_Month" : Double(self.applicantData.earningsPerMonth ?? "0") ?? 0,
     "Applicant_Employer_Phone_Number" : self.applicantData.employersPhoneNumber ?? " ",
     "Applicant_Ethnicity" : "",
     "Applicant_Home_Phone" : self.applicantData.homePhone ?? "",
     "Applicant_Home_Value" : Double(self.presentValueOfHome.text ?? "0") ?? 0,
     "Applicant_Insurance_Agent" :self.agent.text ?? "",
     "Applicant_Insurance_Agent_Phone" : self.insurenceCompanyNumber.text ?? "",
     "Applicant_Insurance_Company" : self.InsuranceCompany.text ?? "",
     "Applicant_Insurance_Coverage" : self.coverage.text ?? "",
     "Applicant_Lender_Name" : "\(self.lenderFirstName.text ?? "") \(self.lenderMiddleName.text ?? "") \(self.landerLastName.text ?? "")",
     "Applicant_Length_of_Time_at_Current_Job" : 1,
     "Applicant_Marital_Status" : self.applicantData.maritalStatus ?? "",
     "Applicant_Monthly_Mortgage_Payment" : Double(self.monthlyMortgageAmount.text ?? "") ?? 0,
     "Applicant_Name" : "\(self.applicantData.applicantFirstName ?? "") \(self.applicantData.applicantMiddleName ?? "") \(self.applicantData.applicantLastName ?? "")",
     "Applicant_Nearest_Relative" : self.nearestReletive.text ?? "",
     "Applicant_Nearest_Relative_Phone" : self.phoneNumber.text ?? "",
     "Applicant_Nearest_Relative_Relationship" : self.relationship.text ?? "",
     "Applicant_Near_Relative_Address" : self.address.text ?? "",
     "Applicant_Occupation" : self.applicantData.occupation ?? "",
     "Applicant_Original_Mortgage_Amount" : Double(self.orginalMortagageAmount.text ?? "") ?? 0,
     "Applicant_Original_Purchase_Price" : Double(self.orginalPurchasePrice.text ?? "") ?? 0,
     "Applicant_Other_Income_Monthly_Amount" : Double(self.monthlypaymentAmount.text ?? "") ?? 0,
     "Applicant_Other_Obligations" : Double(self.otherObligations.text ?? "") ?? 0,
     "Applicant_Present_Employer" : self.applicantData.presentEmployer ?? "",
     "Applicant_Present_Employer_Address" : self.applicantData.presentEmployersAddress ?? " ",
     "Applicant_Previous_City" : self.applicantData.presentEmployersAddressCity ?? "",
     "Applicant_Previous_Employer_Address" : self.applicantData.previousEmployersAddress ?? "",
     "Applicant_Previous_Employer_Occupation" : self.applicantData.occupationPreviousEmployer ?? "",
     "Applicant_Previous_Employer_Phone" :  self.applicantData.previousEmployersPhoneNumber ?? "",
     "Applicant_Previous_State" :  self.applicantData.previousAddressOfApplicantState ?? "",
     "Applicant_Previous_Street_Address" :  self.applicantData.previousAddressOfApplicant ?? "",
     "Applicant_Previous_Years_on_the_Job" : self.applicantData.yearsOnJobPreviousEmployer ?? "",
     "Applicant_Previous_ZIP_Code" : self.applicantData.previousEmployersAddressZip ?? "",
     "Applicant_Property_Acquisition_Date" : self.dateAcquired.text ?? "",
     "Applicant_Property_Address" : self.address.text ?? "",
     "Applicant_Property_Details" : self.mortgage.text ?? "",
     "Applicant_Property_Owners" : self.owners.text ?? "",
     "Applicant_Race" : self.applicantData.race ?? "",
     "Applicant_Second_Mortgage" : (self.secondMortgage.selectedSegmentIndex == 0),
     "Applicant_Second_Mortgage_Amount" : Double(self.orginalAmount.text ?? "") ?? 0,
     "Applicant_Second_Mortgage_Balance" : Double(self.presentBalance.text ?? "") ?? 0,
     "Applicant_Second_Mortgage_Lender" :self.lenderDetails.text ?? "",
     "Applicant_Second_Mortgage_Payment" : Double(self.monthlypaymentAmount.text ?? "") ?? 0,
     "Applicant_Second_Mortgage_Phone" : "",
     "Applicant_Sex" : self.applicantData.sex ?? "",
     "Applicant_Signature_Date" : Date().DateFromStringForServer(),
     "Applicant_Source_of_Other_Income" : self.sourceOfIncome.text ?? "",
     "Applicant_SSN" : self.applicantData.socialSecurityNumber ?? "",
     "Applicant_State" : self.applicantData.addressOfApplicantState ?? "",
     "Applicant_Street_Address" : self.applicantData.addressOfApplicant ?? "",
     "Applicant_Supervisor_or_Department" : self.applicantData.supervisorOrDepartment ?? " ",
     "Applicant_Total_Monthly_Payments" : Double(self.totalMonthlyPayments.text ?? "") ?? 0,
     "Applicant_Total_Price" : self.totalAmount,
     "Applicant_Type_of_Loan" : self.typeofloan.text ?? "",
     "Applicant_Type_of_Property" : self.typeOfProperperty.text ?? "",
     "Applicant_Work_to_be_Done" : self.workDone.text ?? "",
     "Applicant_Years_At_Current_Address" : self.applicantData.howLong ?? "",
     "Applicant_ZIP_Code" : self.applicantData.addressOfApplicantZip ?? "",
     "Coapp_Date_of_Birth" : self.coApplicantData?.dateOfBirth ?? "",
     "Coapp_Drivers_License_Expiration" : self.coApplicantData?.driversLicenseExpDate ?? "",
     "Coapp_Drivers_License_or_State_ID" : self.coApplicantData?.driversLicense ?? "",
     "Coapplicant_Ethnicity" : "",
     "Coapplicant_Marital_Status" : self.coApplicantData?.maritalStatus ?? "",
     "Coapplicant_Race" : self.coApplicantData?.race ?? "",
     "Coapplicant_Sex" : self.coApplicantData?.sex ?? "",
     "Coapplicant_Signature_Date" : Date().DateFromStringForServer(),
     "Coapp_Monthly_Earnings" : Double(self.coApplicantData?.earningsPerMonth ?? "") ?? 0,
     "Coapp_Name" : "\(self.coApplicantData?.applicantFirstName ?? "") \(self.coApplicantData?.applicantMiddleName ?? "") \(self.coApplicantData?.applicantLastName ?? "")",
     "Coapp_Present_Employer_Address" : self.coApplicantData?.presentEmployersAddress ?? "",
     "Coapp_Present_Employer_Phone" : self.coApplicantData?.employersPhoneNumber ?? "",
     "Coapp_Present_Occupation" : self.coApplicantData?.occupation ?? "",
     "Coapp_Previous_Employer_Address" : self.coApplicantData?.previousEmployersAddress ?? "",
     "Coapp_Previous_Employer_Monthly_Earnings" : Double(self.coApplicantData?.earningsFromEmployment ?? "0") ?? 0,
     "Coapp_Previous_Employer_Occupation" : self.coApplicantData?.occupationPreviousEmployer ?? "",
     "Coapp_Previous_Employer_Phone" : self.coApplicantData?.previousEmployersPhoneNumber ?? "",
     "Coapp_Previous_Employer_Years_on_Job" : Double(self.coApplicantData?.yearsOnJobPreviousEmployer ?? "0") ?? 0,
     "Coapp_SSN" : self.coApplicantData?.socialSecurityNumber ?? "",
     "Coapp_Years_on_Job" : Double(self.coApplicantData?.yearsOnJob ?? "0") ?? 0
     ]
     }*/
    func getParameterForRefloorLocalAppsteamOdooServer() -> [String:Any]
    {
        var signatureDate = Date().SignatureDate()
        signatureDate = signatureDate.replacingOccurrences(of: "/", with: "-")
        return  [
            "appointment_id": AppDelegate.appoinmentslData.id ?? 0,
            "total_price": self.totalAmount.noDecimal,
            "downpayment": self.downPaymentValue.noDecimal,
            "amount_financed": self.financePayment.noDecimal,
            "type_of_loan": self.typeofloan.text ?? "",
            "type_of_property": self.typeOfProperperty.text ?? "",
            "work_to_be_done": self.workDone.text ?? "",
            "owners": "",
            "owners_if_different": "",
            "address_of_property": self.addressToBeImporove.text ?? "",
            "street": "",
            "street2": "",
            "city": "",
            "state": "",
            "zip": "",
            "same_property_address": self.addressToBeImproveType.text ?? "",
            "applicant_first_name": self.applicantData.applicantFirstName ?? "",
            "applicant_middle_name": self.applicantData.applicantMiddleName ?? "",
            "applicant_last_name": self.applicantData.applicantLastName ?? "",
            "drivers_license": self.applicantData.driversLicense ?? "",
            "drivers_license_exp_date": self.applicantData.driversLicenseExpDate ?? "",
            "drivers_license_issue_date": self.applicantData.driversLicenseIssueDate ?? "",
            "date_of_birth": self.applicantData.dateOfBirth ?? "",
            "social_security_number": self.applicantData.socialSecurityNumber ?? "",
            "address_of_applicant": self.applicantData.addressOfApplicant ?? "",
            "address_of_applicant_street": "",
            "address_of_applicant_street2": "",
            "address_of_applicant_city": self.applicantData.addressOfApplicantCity ?? "",
            "address_of_applicant_state": self.applicantData.addressOfApplicantState ?? "",
            "address_of_applicant_zip": self.applicantData.addressOfApplicantZip ?? "",
            "previous_address_of_applicant": self.applicantData.previousAddressOfApplicant ?? "",
            "previous_address_of_applicant_street": "",
            "previous_address_of_applicant_street2": "",
            "previous_address_of_applicant_city": self.applicantData.previousAddressOfApplicantCity ?? "",
            "previous_address_of_applicant_state": self.applicantData.previousAddressOfApplicantState ?? "",
            "previous_address_of_applicant_zip": self.applicantData.previousAddressOfApplicantZip ?? "",
            "cell_phone": self.applicantData.cellPhone ?? "",
            "home_phone": self.applicantData.homePhone ?? "",
            "how_long": self.applicantData.howLong ?? "",
            "previous_address_how_long": self.applicantData.previousAddressHowLong ?? "",
            "present_employer": self.applicantData.presentEmployer ?? "",
            "years_on_job": self.applicantData.yearsOnJob ?? "",
            "occupation": self.applicantData.occupation ?? "",
            "present_employers_address": self.applicantData.presentEmployersAddress ?? "",
            "present_employers_address_street":  "",
            "present_employers_address_street2": "",
            "present_employers_address_city": self.applicantData.presentEmployersAddressCity ?? "",
            "present_employers_address_state":self.applicantData.presentEmployersAddressState ?? "",
            "present_employers_address_zip": self.applicantData.presentEmployersAddressZip ?? "",
            "earnings_from_employment": Double(self.applicantData.earningsFromEmployment ?? "") ?? 0,
            "supervisor_or_department": self.applicantData.supervisorOrDepartment ?? "",
            "employers_phone_number": self.applicantData.employersPhoneNumber ?? "",
            "previous_employers_address": self.applicantData.presentEmployersAddress ?? "",
            "previous_employers_address_street": "",
            "previous_employers_address_street2": "",
            "previous_employers_address_city": self.applicantData.previousEmployersAddressCity ?? "",
            "previous_employers_address_state": self.applicantData.previousEmployersAddressState ?? "",
            "previous_employers_address_zip": self.applicantData.previousEmployersAddressState ?? "",
            "earnings_per_month": self.applicantData.earningsPerMonth ?? "",
            "years_on_job_previous_employer": self.applicantData.yearsOnJobPreviousEmployer ?? "",
            "occupation_previous_employer": self.applicantData.occupationPreviousEmployer ?? "",
            "previous_employers_phone_number": self.applicantData.previousEmployersPhoneNumber ?? "",
            "co_applicant_first_name": self.coApplicantData?.applicantFirstName ?? "",
            "co_applicant_middle_name": self.coApplicantData?.applicantMiddleName ?? "",
            "co_applicant_last_name": self.coApplicantData?.applicantLastName ?? "",
            "co_applicant_drivers_license": self.coApplicantData?.driversLicense ?? "",
            "co_applicant_drivers_license_exp_date":self.coApplicantData?.driversLicenseExpDate ?? "",
            "co_applicant_drivers_license_issue_date": self.coApplicantData?.driversLicenseIssueDate ?? "",
            "co_applicant_date_of_birth": self.coApplicantData?.dateOfBirth ?? "",
            "co_applicant_social_security_number": self.coApplicantData?.socialSecurityNumber ?? "",
            "co_applicant_address_of_applicant": self.coApplicantData?.addressOfApplicant ?? "",
            "co_applicant_street": "",
            "co_applicant_street2": "",
            "co_applicant_city": self.coApplicantData?.addressOfApplicantCity ?? "",
            "co_applicant_state": self.coApplicantData?.addressOfApplicantState ?? "",
            "co_applicant_zip": self.coApplicantData?.addressOfApplicantZip ?? "",
            "co_applicant_previous_address_of_applicant": self.coApplicantData?.previousAddressOfApplicant ?? "",
            "co_applicant_previous_street": "",
            "co_applicant_previous_street2": "",
            "co_applicant_previous_city": self.coApplicantData?.previousAddressOfApplicantCity ?? "",
            "co_applicant_previous_state": self.coApplicantData?.previousAddressOfApplicantState ?? "",
            "co_applicant_previous_zip": self.coApplicantData?.previousAddressOfApplicantZip ?? "",
            "co_applicant_how_long": self.coApplicantData?.howLong ?? "",
            "co_applicant_present_employer": self.coApplicantData?.presentEmployer ?? " ",
            "co_applicant_years_on_job": self.coApplicantData?.yearsOnJob ?? "",
            "co_applicant_occupation": self.coApplicantData?.occupation ?? "",
            "co_applicant_present_employers_address": self.coApplicantData?.presentEmployersAddress ?? "",
            "co_applicant_present_employers_street": "",
            "co_applicant_present_employers_street2": "",
            "co_applicant_present_employers_city": self.coApplicantData?.presentEmployersAddressCity ?? "",
            "co_applicant_present_employers_state": self.coApplicantData?.presentEmployersAddressState ?? "",
            "co_applicant_present_employers_zip": self.coApplicantData?.presentEmployersAddressZip ?? "",
            "co_applicant_earnings_from_employment": Double(self.coApplicantData?.earningsFromEmployment ?? "") ?? 0,
            "co_applicant_supervisor_or_department": self.coApplicantData?.supervisorOrDepartment ?? "",
            "co_applicant_employers_phone_number": self.coApplicantData?.employersPhoneNumber ?? "",
            "co_applicant_previous_employers_address": self.coApplicantData?.previousEmployersAddress ?? "",
            "co_applicant_previous_employers_street": "",
            "co_applicant_previous_employers_street2": "",
            "co_applicant_previous_employers_city": "",
            "co_applicant_previous_employers_state": "",
            "co_applicant_previoust_employers_zip": "",
            "co_applicant_earnings_per_month":  Double(self.coApplicantData?.earningsPerMonth ?? "") ?? 0,
            "co_applicant_years_on_job_previous_employer": self.coApplicantData?.yearsOnJobPreviousEmployer ?? "",
            "co_applicant_occupation_previous_employer":self.coApplicantData?.occupationPreviousEmployer ?? "",
            "co_applicant_previous_employers_phone_number": self.coApplicantData?.previousEmployersPhoneNumber ?? "",
            "source_of_other_income": self.sourceOfIncome.text == "Select" ? "" : self.sourceOfIncome.text ?? "",
            "amount_monthly": Double(self.monthlypaymentAmount.text ?? "") ?? 0,
            "nearest_relative": self.nearestReletive.text ?? "",
            "relationship": self.relationship.text ?? "",
            "address_relationship": "",
            "address_relationship_street": "",
            "address_relationship_street2": "",
            "address_relationship_city": "",
            "address_relationship_state": "",
            "address_relationship_zip": "",
            "phone_number_relationship": self.phoneNumber.text ?? "",
            "property_details": self.mortgage.text ?? "",
            "applicant_mortgage_company": self.lenderFirstName.text ?? "",
            "additional_monthly_income": Double(self.additionalIncomeSource.text ?? "") ?? 0,
            "lender_address": "",
            "lender_address_street": "",
            "lender_address_street2": "",
            "lender_address_city": "",
            "lender_address_state": "",
            "lender_address_zip": "",
            "lender_phone": "",
            "original_purchase_price": Double(self.orginalPurchasePrice.text ?? "") ?? 0,
            "original_mortage_amount": Double(self.orginalMortagageAmount.text ?? "") ?? 0,
            "monthly_mortage_payment": Double(self.monthlyMortgageAmount.text ?? "") ?? 0,
            "additional_income": self.otherIncomeSegment.titleForSegment(at: self.otherIncomeSegment.selectedSegmentIndex) ?? "",
            "date_aquired":  "",
            "present_balance": Double(self.presentBalance.text ?? "") ?? 0,
            "present_value_of_home": Double(self.presentValueOfHome.text ?? "") ?? 0,
            "second_mortage": self.secondMortgage.titleForSegment(at: self.secondMortgage.selectedSegmentIndex) ?? "",
            "lender_name_or_phone": self.lenderDetails.text ?? "",
            "original_amount": Double(self.orginalAmount.text ?? "") ?? 0,
            "present_balance_second_mortage": Double(self.presentBalanceAmount.text ?? "") ?? 0,
            "monthly_payment": Double(self.monthlypaymentAmount.text ?? "") ?? 0,
            "other_obligations": 0,
            "total_monthly_payments": 0,
            "checking_account_no": self.checkingAccountNumber.text ?? "", "checking_routing_no": self.checkingRoutingNumber.text ?? "",
            "name_of_bank": self.nameOfBank.text ?? "",
            "bank_phone_number": "",
            "insurance_company": "",
            "agent": "",
            "insurance_phone_no": "",
            "coverage": "",
            "applicant_not_furnish_info": (self.applicantData.ethnicity ?? "").lowercased().contains("hispanic") ? "1":"0",
            "ethnicity":"",
            "race": self.applicantData.race ?? "",
            "sex": self.applicantData.sex ?? "",
            "marital_status": self.applicantData.maritalStatus ?? "",
            "co_applicant_not_furnish_info": (self.coApplicantData?.ethnicity ?? "").lowercased().contains("hispanic") ? "1":"0",
            "co_applicant_ethnicity": "",
            "co_applicant_race": self.coApplicantData?.race ?? "",
            "co_applicant_sex":self.coApplicantData?.sex ?? "",
            "co_applicant_marital_status":self.coApplicantData?.maritalStatus ?? "",
            "type_of_credit_requested": self.applicantData.type_of_credit_requested ?? "",
            "applicant_signature_date": signatureDate,
            "co_applicant_signature_date": signatureDate,
            "joint_credit_initials":"",
            "applicant_email":self.applicantData.applicantEmail ?? "",
            "applicant_otherRace":self.applicantData.otherRace ?? "",
            "co_applicant_otherRace":self.coApplicantData?.otherRace ?? "",
            "hunterMessageStatus":huntertearmStatus,
            "co_applicant_email":self.coApplicantData?.CoapplicantEmail ?? "","co_applicant_skip":isCoAppSkiped,"co_applicant_phone":self.coApplicantData?.homePhone ?? "","co_applicant_secondary_phone":""
            
            
        ]
    }
    //self.coApplicantData?.homePhone
    func validation() -> String
    {
        /*     if(ownersType.text!.removeUnvantedcharactoes() == "DIFFERENT")
         {
         if(owners.text!.removeUnvantedcharactoes() == "")
         {
         owners.becomeFirstResponder()
         return "Please enter Owners Details"
         }
         }*/
        if(addressToBeImproveType.text!.removeUnvantedcharactoes() == "DIFFERENT")
        {
            if(addressToBeImporove.text!.removeUnvantedcharactoes() == "")
            {
                addressToBeImporove.becomeFirstResponder()
                return "Please enter Address of the Property to Improve the Details"
            }
            else
            {
            }
        }
        /*   else if(nearestReletive.text!.removeUnvantedcharactoes() == "")
         {
         nearestReletive.becomeFirstResponder()
         return "Please enter Nearest Relative"
         }
         else if(relationship.text!.removeUnvantedcharactoes() == "")
         {
         relationship.becomeFirstResponder()
         return "Please enter Relationship of Nearest Relative"
         }
         else if(address.text!.removeUnvantedcharactoes() == "")
         {
         address.becomeFirstResponder()
         return "Please enter Address"
         }
         else if !(phoneNumber.text!.validatePhone())
         {
         phoneNumber.becomeFirstResponder()
         return "Please enter Relative Phone Number"
         }
         */
        //    else if(lenderFirstName.text!.removeUnvantedcharactoes() == "")
        //    {
        //        lenderFirstName.becomeFirstResponder()
        //        return "Please enter Lender First Name"
        //    }
        //    else if(lenderMiddleName.text!.removeUnvantedcharactoes() == "")
        //    {
        //        lenderMiddleName.becomeFirstResponder()
        //        return "Please enter Lender Middle Name"
        //    }
        //    else if(landerLastName.text!.removeUnvantedcharactoes() == "")
        //    {
        //        landerLastName.becomeFirstResponder()
        //        return "Please enter Lender Last Name"
        //    }
        //    else if(lenderDetails.text!.removeUnvantedcharactoes() == "")
        //    {
        //        lenderDetails.becomeFirstResponder()
        //        return "Please enter Lender Phone"
        //    }
        /*  else if(presentValueOfHome.text!.removeUnvantedcharactoes() == "")
         {
         presentValueOfHome.becomeFirstResponder()
         return "Please enter Present Value of Home"
         }
         else if(totalMonthlyPayments.text!.removeUnvantedcharactoes() == "")
         {
         totalMonthlyPayments.becomeFirstResponder()
         return "Please enter  Monthly Payment"
         }
         else if(checkingAccountNumber.text!.removeUnvantedcharactoes() == "")
         {
         checkingAccountNumber.becomeFirstResponder()
         return "Please enter your Checking Account Number"
         }
         else if(nameOfBank.text!.removeUnvantedcharactoes() == "")
         {
         nameOfBank.becomeFirstResponder()
         return "Please enter the Name of Bank"
         }
         else if !(otherPhoneNumber.text!.validatePhone())
         {
         otherPhoneNumber.becomeFirstResponder()
         return "Please enter Bank Phone Number"
         }
         */
        if !istearmAndCondition
        {
            return "You must accept the Terms and Conditions"
        }
        
        return ""
    }
    
    
    @IBAction func typeOfPropertyChange(_ sender: UIButton) {
        let array = ["Single Family","Mobile Home","Condo"]
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.typeOfPropertyChangeTag)
    }
    @IBAction func workDoneChange(_ sender: UIButton) {
        let array = [ "FLOORING","WINDOWS","ROOF","SIDING","GUTTERS"
                      ,"GUTTER GRATE","INSULATION","WALK IN TUBS"]
        // let array = [ "FLOORING"]
        
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.workDoneChangeTag)
    }
    @IBAction func sourceOfIncomeChange(_ sender: UIButton) {
        
        let array = [ "Social Security","Pension","Child Support","Rental","Other"]
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.sourceOfIncomeChangeTag)
    }
    @IBAction func periodofEarningChange(_ sender: UIButton) {
        let array = [ "Monthly"]
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.periodofEarningChangeTag)
    }
    @IBAction func relationshipChange(_ sender: UIButton) {
        let array = [ "Single","Married","Unmarried","Separated"]
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.relationshipChangeTag)
    }
    
    @IBAction func mortgageChange(_ sender: UIButton) {
        //  let array = [ "MORTGAGE","LAND","CONTRACT","FREE AND CLEAR"]
        let array = ["MORTGAGE"]
        self.DropDownDefaultfunction(sender, sender.bounds.width, array, -1, delegate: self, tag: self.mortgageChangeTag)
    }
    @IBAction func dateAcquiredAction(_ sender: UITextField) {
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        //        datePicker.setSelected(UIColor.white)
        //            datePicker.backgroundColor =  UIColor.init(red: 40/255, green: 59/255, blue: 79/255, alpha: 1)
        //            datePicker.tintColor = UIColor.white
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.barStyle = .blackTranslucent
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        doneButton.tintColor = .white
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        cancelButton.tintColor = .white
        
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        sender.inputAccessoryView = toolbar
        sender.inputView?.backgroundColor = UIColor.init(red: 40/255, green: 59/255, blue: 79/255, alpha: 1)
        sender.inputView = datePicker
    }
    
    
    
    
    
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        let dateString = formatter.string(from: self.datePicker.date)
        
        self.dateAcquired.text = dateString
        
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        if(tag == self.mortgageChangeTag)
        {
            self.mortgage.text = item
        }
        if(tag == self.periodofEarningChangeTag)
        {
            self.periodofEarnings.text = item
        }
        if(tag == self.workDoneChangeTag)
        {
            self.workDone.text = item
        }
        if(tag == self.relationshipChangeTag)
        {
            self.relationship.text = item
        }
        if(tag == self.sourceOfIncomeChangeTag)
        {
            self.sourceOfIncome.text = item
        }
        if(tag == self.typeOfPropertyChangeTag)
        {
            self.typeOfProperperty.text = item
        }
        if(tag == self.typeofloanTag)
        {
            self.typeofloan.text = item
        }
        /* if(tag == self.ownersTag)
         {
         self.ownersType.text = item
         if(item == "SAME AS APPLICANT")
         {
         self.owners.isUserInteractionEnabled = false
         self.owners.text = ""
         }
         else
         {
         self.owners.isUserInteractionEnabled = true
         }
         }*/
        if(tag == self.addressTobeTag)
        {
            self.addressToBeImproveType.text = item
            if(item == "SAME AS APPLICANT")
            {
                self.addressToBeImporove.isUserInteractionEnabled = false
                self.addressToBeImprov.isHidden = true
                self.addressToBeImporove.text = ""
            }
            else
            {
                self.addressToBeImprov.isHidden = false
                self.addressToBeImporove.isUserInteractionEnabled = true
            }
        }
        
    }
    func DidAddressSelectPlaceEntryDelegate(title: String, mapItem: GMSPlace?, tag: Int) {
        if(tag == 0)
        {
            
            
            self.landerAddress.text = mapItem?.formattedAddress
            
            
        }
        if(tag == 1)
        {
            
            
            self.address.text = mapItem?.formattedAddress
            
            
        }
        if(tag == 4)
        {
            
            
            self.owners.text = mapItem?.formattedAddress
            
            
        }
        if(tag == 5)
        {
            
            
            self.addressToBeImporove.text = mapItem?.formattedAddress
            
            
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
}
extension OtherIncomeViewControllerForm: ImagePickerDelegate {

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
extension OtherIncomeViewControllerForm: GMSAutocompleteViewControllerDelegate {
    
    
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
