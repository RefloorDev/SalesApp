//
//  ApplicantFormViewController.swift
//  Refloor
//
//  Created by sbek on 20/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import RealmSwift
class ApplicantFormViewControllerForm: UIViewController,DropDownDelegate,AddressSelectPlaceEntryDelegate,UITextFieldDelegate,GMSMapViewDelegate{
    
    static public func initialization() -> ApplicantFormViewControllerForm? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ApplicantFormViewControllerForm") as? ApplicantFormViewControllerForm
    }
    
    @IBOutlet weak var raceOtherTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var receOtherHightConstrain: NSLayoutConstraint!
    @IBOutlet weak var homePhone: UITextField!
    @IBOutlet weak var cellPhone: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var stateZipCode: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var howLong: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var socialSecurityNo: UITextField!
    @IBOutlet weak var lisenceExpDate: UITextField!
    @IBOutlet weak var lisenceissueDate: UITextField!
    @IBOutlet weak var drivingLisenceID: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var dateofbirth: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var middlename: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var exAddress: UITextField!
    @IBOutlet weak var exHowLong: UITextField!
    @IBOutlet weak var exState: UITextField!
    @IBOutlet weak var exCity: UITextField!
    @IBOutlet weak var exZipCode: UITextField!
    @IBOutlet weak var presentEmployer: UITextField!
    @IBOutlet weak var yearonJob: UITextField!
    @IBOutlet weak var occupation: UITextField!
    @IBOutlet weak var empAddress: UITextField!
    @IBOutlet weak var earnings: UITextField!
    @IBOutlet weak var earningType: UITextField!
    @IBOutlet weak var department: UITextField!
    @IBOutlet weak var employementPhone: UITextField!
    //    @IBOutlet weak var exEmployeeAddress: UITextField!
    //    @IBOutlet weak var exYearsOnJob: UITextField!
    var GMSTag = 0
    //    @IBOutlet weak var exEmployeementPhone: UITextField!
    //    @IBOutlet weak var exDepartment: UITextField!
    //    @IBOutlet weak var exEarnings: UITextField!
    @IBOutlet weak var donotwishLabel: UILabel!
    @IBOutlet weak var hispanicImage: UIImageView!
    @IBOutlet weak var sexSegment: UISegmentedControl!
    @IBOutlet weak var race: UITextField!
    @IBOutlet weak var martialStatus: UITextField!
    @IBOutlet weak var hispanic: UILabel!
    @IBOutlet weak var nothispanic: UILabel!
    @IBOutlet weak var nothispanicImage: UIImageView!
    @IBOutlet weak var donotwishImage: UIImageView!
    @IBOutlet weak var raceOherView: UIView!
    @IBOutlet weak var raceOther: UITextField!
    var isPasswordVisble = true
    
    @IBOutlet weak var creditRequestCollectionView: UICollectionView!
    var ethencity = ""
    var experyDate:Date?
    var isDateOFBirth = 0
    var dateOFbirth:Date?
    var raceTag = 1
    var exmonthlyTag = 2
    var monthlyTag = 3
    var marriedTag = 4
    var datePicker = UIDatePicker()
    var wishShareStatus:HispanicStatus = .Share
    var hispanicstatus:HispanicStatus = .None
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
    var downpayment = DownPaymentViewController.initialization()!
    let datePickerMYOnly = MonthYearPickerView()
    var monthlyEarnings:String = String()
    var co_Applicant_Skipped:Bool = Bool()
    var totalPrice:Double = Double()
    var finalPayment:Double = Double()
    var financeAmount:Double = Double()
    var packagePlanName = ""
    var adjustmentValue:Double = 0
    var roomName = ""
    var coapplicantSkiip:Int = 0
    var installationDate = ""
    var adminFeeStatus = false
    var minSalePrice:Double = 0.0
    var savings:Double = 0
    var promotionCodeId:Int = Int()
    
    var creditRequest = ["Individual Credit - relying on my income or assets as well as income or assets from other sources","Joint Credit - We intend to apply for joint credit"]
    var selectedReq = 0
    var imagePicker: CaptureImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "Applicant Information".uppercased())
        if AppDelegate.appoinmentslData.co_applicant_skipped == 1
        {
            co_Applicant_Skipped = true
        }
        else
        {
            co_Applicant_Skipped = false
        }
        drivingLisenceID.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // cellPhone.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        firstName.setPlaceHolderWithColor(placeholder: "First Name", colour: UIColor.placeHolderColor)
        homePhone.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        zipCode.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        middlename.setPlaceHolderWithColor(placeholder: "Middle Name", colour: UIColor.placeHolderColor)
        lastName.setPlaceHolderWithColor(placeholder: "Last Name", colour: UIColor.placeHolderColor)
        stateZipCode.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        presentEmployer.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        yearonJob.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        occupation.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        city.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        howLong.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //exYearsOnJob.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        address.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        socialSecurityNo.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        lisenceExpDate.setPlaceHolderWithColor(placeholder: "MM/DD/YYYY", colour: UIColor.placeHolderColor)
        lisenceissueDate.setPlaceHolderWithColor(placeholder: "MM/DD/YYYY", colour: UIColor.placeHolderColor)
        
        emailAddress.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        dateofbirth.setPlaceHolderWithColor(placeholder: "MM/DD/YYYY", colour: UIColor.placeHolderColor)
        //exAddress.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // exHowLong.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // exState.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // exCity.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // exZipCode.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // empAddress.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        earnings.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //  department.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //  employementPhone.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        raceOther.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        howLong.delegate = self
        socialSecurityNo.delegate = self
        // exHowLong.delegate = self
        yearonJob.delegate = self
        earnings.delegate = self
        //  exEmployeeAddress.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        // exEmployeementPhone.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        //  exDepartment.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        //  exEarnings.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(clickOnDonotwish))
        let tap11 = UITapGestureRecognizer(target: self, action: #selector(clickOnDonotwish))
        
        tap1.numberOfTapsRequired = 1
        tap11.numberOfTapsRequired = 1
        
        self.donotwishLabel.isUserInteractionEnabled = true
        self.donotwishImage.isUserInteractionEnabled = true
        self.donotwishImage.addGestureRecognizer(tap1)
        self.donotwishLabel.addGestureRecognizer(tap11)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(clickOnNotHispanic))
        let tap22 = UITapGestureRecognizer(target: self, action: #selector(clickOnNotHispanic))
        tap2.numberOfTapsRequired = 1
        tap22.numberOfTapsRequired = 1
        // self.nothispanicImage.isUserInteractionEnabled = true//
        //  self.nothispanic.isUserInteractionEnabled = true
        // self.nothispanicImage.addGestureRecognizer(tap2)
        //  self.nothispanic.addGestureRecognizer(tap22)
        
        //   let tap3 = UITapGestureRecognizer(target: self, action: #selector(clickOnHispanic))
        //   let tap33 = UITapGestureRecognizer(target: self, action: #selector(clickOnHispanic))
        //     tap3.numberOfTapsRequired = 1
        //     tap33.numberOfTapsRequired = 1
        //     self.hispanicImage.isUserInteractionEnabled = true
        //      self.hispanic.isUserInteractionEnabled = true
        //     self.hispanicImage.addGestureRecognizer(tap3)
        //     self.hispanic.addGestureRecognizer(tap33)
        
        self.race.text = "Select"
        self.martialStatus.text = "Married"
        
        self.monthlyEarnings = "Monthly"
        if let customer = AppDelegate.appoinmentslData
        {
            self.firstName.text = customer.applicant_first_name ?? ""
            self.middlename.text = customer.applicant_middle_name ?? ""
            self.lastName.text = customer.applicant_last_name ?? ""
            self.address.text = ((customer.street2 ?? "") == "") ? (customer.street ?? ""): ((customer.street ?? "") + " " + (customer.street2 ?? ""))
            self.city.text = customer.city ?? ""
            self.stateZipCode.text =  (customer.state_code ?? "")
            self.zipCode.text =  (customer.zip ?? "")
            self.homePhone.text = customer.phone
            self.emailAddress.text = customer.email
        }
        setPhoneNumberDelegate()
        let font = UIFont(name: "Avenir-Medium", size: 22)!
        sexSegment.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        self.zipCode.keyboardType = .asciiCapableNumberPad
        self.zipCode.delegate = self
        
        
        
        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    
    func setPhoneNumberDelegate()
    {
        self.homePhone.delegate = self
        //  self.cellPhone.delegate = self
        // self.employementPhone.delegate = self
        self.socialSecurityNo.delegate = self
        
        // self.exEmployeementPhone.delegate = self
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.textInputMode?.primaryLanguage == "emoji") {
            return false
        }
        //let specialCharString = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢")
        if string.rangeOfCharacter(from: Validation.specialCharString) != nil && textField != self.emailAddress {
            return false
        }
        
        if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil
        {
            if(textField == self.homePhone || textField == self.cellPhone || textField == self.employementPhone )
            {
                guard let text = textField.text else { return false }
                let newString = (text as NSString).replacingCharacters(in: range, with: string)
                textField.text = self.format(with: "(XXX) XXX-XXXX", phone: newString)
                return false
            }
            else if(textField == self.socialSecurityNo)
            {
                
                guard let text = textField.text else { return false }
                let newString = (text as NSString).replacingCharacters(in: range, with: string)
                textField.text = self.format(with: "XXX-XX-XXXX", phone: newString)
                //  self.socialSecurityNo.isSecureTextEntry = true
                return false
            }
            else if(textField == self.zipCode) {
                guard var text = textField.text else { return false }
                text = text + string
                if text.count > 5 {
                    return false
                }
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        if socialSecurityNo == textField {
//            textField.isSecureTextEntry = true
//        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if socialSecurityNo == textField {
//            textField.isSecureTextEntry = false
//        }
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
    
    @IBAction func addressDidBigen(_ sender: UITextField) {
        self.GMSTag = 0
        googleMapPlaceSearchPopUp()
    }
    
    func googleMapPlaceSearchPopUp()
    {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func addressDidChange(_ sender: UITextField) {
        //getMapPlaces(words: sender.text ?? "", sender: sender, tag: 11)
    }
    
    /*  @IBAction func currentAddress(_ sender: UIButton) {
     let getaddress = AddressEntryViewController.initialization()!
     getaddress.delegate = self
     getaddress.delegateTag = 11
     getaddress.address = self.address.text ?? ""
     self.present(getaddress, animated: true, completion: nil)
     
     }*/
    
    @IBAction func currentAddress(_ sender: UIButton) {
        //        let getaddress = AddressEntryViewController.initialization()!
        //        getaddress.delegate = self
        //        getaddress.delegateTag = 11
        //        getaddress.address = self.address.text ?? ""
        //        self.present(getaddress, animated: true, completion: nil)
        self.GMSTag = 0
        googleMapPlaceSearchPopUp()
    }
    
    
    @IBAction func skipButtonAction(_ sender: UIButton)
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "ApplicantInformation"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //        let signature = SignatureSubmitViewController.initialization()!
        //        if co_Applicant_Skipped == true{
        //            signature.isCoAppSkiped = 1
        //        }
        //        else{
        //            signature.isCoAppSkiped = 0
        //        }
        //        signature.downOrFinal = self.downOrFinal
        //        signature.totalAmount = self.totalAmount
        //        signature.paymentPlan = self.paymentPlan
        //        signature.paymentPlanValue = self.paymentPlanValue
        //        signature.paymentOptionDataValue = self.paymentOptionDataValue
        //        signature.drowingImageID = self.drowingImageID
        //        signature.area = self.area
        //        signature.downPaymentValue = self.downPaymentValue
        //        signature.finalpayment = self.finalpayment
        //        signature.financePayment = self.financePayment
        //        signature.selectedPaymentMethord = self.selectedPaymentMethord
        //        signature.downpayment = self.downpayment
        //        if let customer = AppDelegate.appoinmentslData
        //        {
        //            signature.isCoAppSkiped = customer.co_applicant_skipped ?? 0
        //        }
        //        self.navigationController?.pushViewController(signature, animated: true)
        
//                let details = UpdateCustomerDetailsOneViewController.initialization()!
//                details.floorLevelData = AppDelegate.floorLevelData
//                details.floorShapeData = []
//                details.roomData = AppDelegate.roomData
//                details.appoinmentslData = AppDelegate.appoinmentslData
//                details.downOrFinal = self.downOrFinal
//                details.totalAmount = self.totalAmount
//                details.paymentPlan = self.paymentPlan
//                details.paymentPlanValue = self.paymentPlanValue
//                details.paymentOptionDataValue = self.paymentOptionDataValue
//                details.drowingImageID = self.drowingImageID
//                details.area = self.area
//                details.downPaymentValue = self.downPaymentValue
//                details.finalpayment = self.finalpayment
//                details.financePayment = self.financePayment
//                details.selectedPaymentMethord = self.selectedPaymentMethord
//                details.downpayment = self.downpayment
//                self.navigationController?.pushViewController(details, animated: true)
        
        print("financePayment : ", financePayment, " finalpayment : ", finalpayment, " downPaymentValue : ", downPaymentValue, " totalAmount : ", totalAmount)
        let details = UpdateDownFinalPaymentViewController.initialization()!
        details.floorLevelData = AppDelegate.floorLevelData
        details.floorShapeData = []
        details.roomData = AppDelegate.roomData
        details.appoinmentslData = AppDelegate.appoinmentslData
        details.packagePlanName = packagePlanName
        details.downOrFinal = self.downPaymentValue
        details.totalAmount = self.totalAmount
        details.paymentPlan = self.paymentPlan
        details.roomName = self.roomName
        details.adjustmentValue = self.adjustmentValue
        details.paymentPlanValue = self.paymentPlanValue
        details.paymentOptionDataValue = self.paymentOptionDataValue
        details.drowingImageID = self.drowingImageID
        details.area = self.area
        details.downpayment = self.downpayment
        details.downPaymentValue = self.downPaymentValue
        details.finalpayment = self.finalpayment
        details.financePayment = self.financePayment
        details.selectedPaymentMethord1 = self.selectedPaymentMethord
        details.installationDate = self.installationDate
        details.adminFeeStatus = self.adminFeeStatus
        details.coapplicantSkiip = self.coapplicantSkiip
        details.minSalePrice = self.minSalePrice
        details.savings = self.savings
        details.promotionCodeId = self.promotionCodeId
        self.navigationController?.pushViewController(details, animated: true)
    }
    
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        // let applicant = CoApplicantFormViewControllerForm.initialization()!
        // self.navigationController?.pushViewController(applicant, animated: true)
        
        //sathesh
        if(self.selectedReq == 0)
        {
            AppDelegate.appoinmentslData.co_applicant_skipped = 1
        }
        else
        {
            AppDelegate.appoinmentslData.co_applicant_skipped = 0
        }
        
        
        if(validation() != "")
        {
            self.alert(validation(), nil)
            return
        }
        
        
        ethencity = "I do not wish to furnish this information"
        if(self.wishShareStatus != .DoNotShare)
        {
            
            ethencity = ""
            
        }
        let sex = self.sexSegment.titleForSegment(at: self.sexSegment.selectedSegmentIndex) ?? ""
        
        var dateOfBirth = self.dateofbirth.text ?? ""
        var licenseIssueDate = self.lisenceissueDate.text ?? ""
        var licenseExpdate = self.lisenceExpDate.text ?? ""
        //dateOfBirth = dateOfBirth.replacingOccurrences(of: "/", with: "-")
        dateOfBirth = dateOfBirth.dateconverterEncoding(dateOfBirth)
        if licenseIssueDate != ""
        {
            licenseIssueDate = licenseIssueDate.dateconverterEncoding(licenseIssueDate)
           
        }
        if  licenseExpdate != ""
        {
            licenseExpdate = licenseExpdate.dateconverterEncoding(licenseExpdate)
        }
        
        let data = ApplicationData.init(applicantFirstName: self.firstName.text ?? "", applicantMiddleName: self.middlename.text ?? "", applicantLastName: self.lastName.text ?? "", driversLicense: self.drivingLisenceID.text ?? "", driversLicenseExpDate: licenseExpdate,driversLicenseIssueDate: licenseIssueDate, dateOfBirth: dateOfBirth, socialSecurityNumber: self.socialSecurityNo.text ?? "", addressOfApplicant: self.address.text ?? "", addressOfApplicantStreet: "", addressOfApplicantStreet2: "", addressOfApplicantCity: self.city.text ?? "", addressOfApplicantState: self.stateZipCode.text ?? "", addressOfApplicantZip: self.zipCode.text ?? "", previousAddressOfApplicant:"", previousAddressOfApplicantStreet: "", previousAddressOfApplicantStreet2: "", previousAddressOfApplicantCity: "", previousAddressOfApplicantState:"", previousAddressOfApplicantZip: "", cellPhone:"", homePhone: self.homePhone.text ?? "", howLong: self.howLong.text ?? "", previousAddressHowLong: "", presentEmployer: self.presentEmployer.text ?? "", yearsOnJob: self.yearonJob.text ?? "", occupation: self.occupation.text ?? "", presentEmployersAddress: "", presentEmployersAddressStreet: "", presentEmployersAddressStreet2: "", presentEmployersAddressCity: "", presentEmployersAddressState: "", presentEmployersAddressZip: "", earningsFromEmployment: self.earnings.text ?? "", supervisorOrDepartment:"", employersPhoneNumber:"", previousEmployersAddress: "", previousEmployersAddressStreet: "", previousEmployersAddressStreet2: "", previousEmployersAddressCity: "", previousEmployersAddressState: "", previousEmployersAddressZip: "", earningsPerMonth: "", yearsOnJobPreviousEmployer: "", occupationPreviousEmployer: "", previousEmployersPhoneNumber: "", ethnicity: ethencity, race: (wishShareStatus == .Share) ? (self.race.text ?? ""): ethencity, sex: sex,  maritalStatus: self.martialStatus.text ?? "",applicantEmail: self.emailAddress.text ?? "", type_of_credit_requested: creditRequest[selectedReq], otherRace: self.raceOther.text ?? "")
        
        //arb
        let rf_ApplicantInfo = rf_ApplicantData(applicantOneData:data)
        self.saveApplicantOneDataToAppointmentDetail(applicantInfo: rf_ApplicantInfo)
        //update appdlegate value
        
        let appointmetslData = AppDelegate.appoinmentslData
        appointmetslData?.applicant_first_name = self.firstName.text
        appointmetslData?.applicant_middle_name = self.middlename.text
        appointmetslData?.applicant_last_name = self.lastName.text
        appointmetslData?.phone = self.homePhone.text
        appointmetslData?.street = self.address.text
        appointmetslData?.zip = self.zipCode.text
        appointmetslData?.city = self.city.text
        appointmetslData?.state = self.stateZipCode.text
        appointmetslData?.email = self.emailAddress.text

        
   
        
        if(AppDelegate.appoinmentslData.co_applicant_skipped == 1)
        {
            
            let coData = CoApplicationData.init(applicantFirstName: "", applicantMiddleName: "", applicantLastName: "", driversLicense: "", driversLicenseExpDate: "",driversLicenseIssueDate: self.lisenceExpDate.text ?? "", dateOfBirth:  "", socialSecurityNumber:  "", addressOfApplicant: "", addressOfApplicantStreet: "", addressOfApplicantStreet2: "", addressOfApplicantCity: "", addressOfApplicantState:"", addressOfApplicantZip: "", previousAddressOfApplicant: "", previousAddressOfApplicantStreet: "", previousAddressOfApplicantStreet2: "", previousAddressOfApplicantCity:  "", previousAddressOfApplicantState: "", previousAddressOfApplicantZip:  "", cellPhone: "", homePhone:  "",howLong:  "", previousAddressHowLong:  "", presentEmployer: "", yearsOnJob: "", occupation: "", presentEmployersAddress: "", presentEmployersAddressStreet: "", presentEmployersAddressStreet2: "", presentEmployersAddressCity: "", presentEmployersAddressState: "", presentEmployersAddressZip: "", earningsFromEmployment:  "", supervisorOrDepartment: "", employersPhoneNumber:  "", previousEmployersAddress:"", previousEmployersAddressStreet: "", previousEmployersAddressStreet2: "", previousEmployersAddressCity: "", previousEmployersAddressState: "", previousEmployersAddressZip: "", earningsPerMonth: "", yearsOnJobPreviousEmployer: "", occupationPreviousEmployer:"", previousEmployersPhoneNumber:  "", ethnicity: "", race: "", sex: "", maritalStatus: "",CoapplicantEmail:  "",otherRace: "")
            //arb
            let rf_CoApplicantInfo = rf_CoApplicationData(coApplicantData: coData)
            self.saveCoApplicantDataToAppointmentDetail(coApplicantInfo: rf_CoApplicantInfo)
            //
           
            let appointment = AppDelegate.appoinmentslData
            appointment?.co_applicant_first_name =  ""
            appointment?.co_applicant_last_name =  ""
            appointment?.co_applicant_middle_name =  ""
            appointment?.co_applicant_zip =  ""
            appointment?.co_applicant_email =  ""
            appointment?.co_applicant_city =  ""
            appointment?.co_applicant_state = ""
            appointment?.co_applicant_address = ""
            appointment?.co_applicant_skipped = 1
            let applicant = OtherIncomeViewControllerForm.initialization()!
            applicant.downOrFinal = self.downOrFinal
            applicant.totalAmount = self.totalAmount
            applicant.paymentPlan = self.paymentPlan
            applicant.paymentPlanValue = self.paymentPlanValue
            applicant.paymentOptionDataValue = self.paymentOptionDataValue
            applicant.drowingImageID = self.drowingImageID
            applicant.area = self.area
            applicant.applicantData = data
            applicant.coApplicantData = coData
            applicant.downPaymentValue = self.downPaymentValue
            applicant.finalpayment = self.finalpayment
            applicant.financePayment = self.financePayment
            applicant.selectedPaymentMethord = self.selectedPaymentMethord
            applicant.downpayment = downpayment
            applicant.isCoAppSkiped = 1
            //arb
            let appointmentId = AppointmentData().appointment_id ?? 0
            let currentClassName = String(describing: type(of: self))
            let classDisplayName = "ApplicantInformation"
            self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
            //
            self.navigationController?.pushViewController(applicant, animated: true)
            
            
        }
        
        else{
            
            let applicant = CoApplicantFormViewControllerForm.initialization()!
            applicant.downOrFinal = self.downOrFinal
            applicant.totalAmount = self.totalAmount
            applicant.paymentPlan = self.paymentPlan
            applicant.paymentPlanValue = self.paymentPlanValue
            applicant.paymentOptionDataValue = self.paymentOptionDataValue
            applicant.drowingImageID = self.drowingImageID
            applicant.area = self.area
            applicant.applicantData = data
            applicant.downPaymentValue = self.downPaymentValue
            applicant.finalpayment = self.finalpayment
            applicant.financePayment = self.financePayment
            applicant.selectedPaymentMethord = self.selectedPaymentMethord
            applicant.downpayment = downpayment
            //arb
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment = AppDelegate.appoinmentslData
            appointment?.zip = self.zipCode.text ?? ""
            appointment?.email = self.emailAddress.text ?? ""
            appointment?.phone = self.homePhone.text ?? ""
            appointment?.city = self.city.text ?? ""
            appointment?.state = self.stateZipCode.text ?? ""
            let currentClassName = String(describing: type(of: self))
            let classDisplayName = "ApplicantInformation"
            self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
            //
            self.navigationController?.pushViewController(applicant, animated: true)
        }
        
        ///skipp
        
        
        
    }
    
    func validation() -> String
    {
        if(firstName.text!.removeUnvantedcharactoes() == "")
        {
            firstName.becomeFirstResponder()
            return "Please enter First Name"
        }
        
        
        //        else if(middlename.text!.removeUnvantedcharactoes() == "")
        //        {
        //            return "Please enter middle name"
        //        }
        if(lastName.text!.removeUnvantedcharactoes() == "")
        {
            lastName.becomeFirstResponder()
            return "Please enter Last Name"
        }
        if(dateofbirth.text!.removeUnvantedcharactoes() == "")
        {
            dateofbirth.becomeFirstResponder()
            return "Please select Date of Birth"
        }
        
        //        if !(emailAddress.text!.validateEmail())
        //        {
        //            emailAddress.becomeFirstResponder()
        //            return "Please enter a valid Email Address"
        //        }
        //        if(drivingLisenceID.text!.removeUnvantedcharactoes() == "")
        //        {
        //            drivingLisenceID.becomeFirstResponder()
        //            return "Please enter your Drivers License Number"
        //        }
        //        if(lisenceExpDate.text!.removeUnvantedcharactoes() == "")
        //        {
        //            lisenceExpDate.becomeFirstResponder()
        //            return "Please enter your Drivers License Expiration Date"
        //        }
        
        if(address.text!.removeUnvantedcharactoes() == "")
        {
            address.becomeFirstResponder()
            return "Please enter Applicant Address"
        }
        
        if(socialSecurityNo.text!.removeUnvantedcharactoesUnerScore() == "")
        {
            socialSecurityNo.becomeFirstResponder()
            return "Please enter the Applicant SSN"
        }
        
        if(!isValidSsn(ssn:socialSecurityNo.text ?? ""))
        {
            socialSecurityNo.becomeFirstResponder()
            return "Please enter valid SSN"
        }
        
        if(city.text!.removeUnvantedcharactoes() == "")
        {
            city.becomeFirstResponder()
            return "Please enter your City"
        }
        if(stateZipCode.text!.removeUnvantedcharactoes() == "")
        {
            stateZipCode.becomeFirstResponder()
            return "Please enter Present State"
        }
        if(zipCode.text!.removeUnvantedcharactoes() == "")
        {
            zipCode.becomeFirstResponder()
            return "Please enter your ZIP Code"
        }
        if(howLong.text!.removeUnvantedcharactoes() == "")
        {
            howLong.becomeFirstResponder()
            //return "Please enter How Long at Current Address"
            return "Please enter Years In Home"
        }
        
        //        if !(cellPhone.text!.validatePhone())
        //        {
        //            cellPhone.becomeFirstResponder()
        //            return "Please enter a valid Cell Phone"
        //        }
        
        //         if(empAddress.text!.removeUnvantedcharactoes() == "")
        //         {
        //            empAddress.becomeFirstResponder()
        //         return "Please enter present Employer Address"
        //         }
        //        if !(employementPhone.text!.validatePhone())
        //         {
        //            employementPhone.becomeFirstResponder()
        //           return "Please enter a valid Present Employer Phone Number"
        //         }
        //        if (department.text!.removeUnvantedcharactoes() == "")
        //         {
        //            department.becomeFirstResponder()
        //           return "Please enter Supervisor Name"
        //         }
        //  if !(homePhone.text == "")
        // {
        if !(homePhone.text!.validatePhone())
        {
            homePhone.becomeFirstResponder()
            return "Please enter a valid home Phone Number"
        }
        if(presentEmployer.text!.removeUnvantedcharactoes() == "")
        {
            presentEmployer.becomeFirstResponder()
            return "Please enter Employer/Source Of Income"
        }
        if(earnings.text!.removeUnvantedcharactoes() == "")
        {
            earnings.becomeFirstResponder()
            return "Please enter monthly earnings"
        }
        //   }
        if (self.wishShareStatus == .Share)
        {
            if(self.race.text == "Select")
            {
                //race.becomeFirstResponder()
                return "Please specify your Race/National Origin"
            }
            else if(self.race.text == "Other")
            {
                if(self.raceOther.text == "")
                {
                    raceOther.becomeFirstResponder()
                    return "Please specify your Other Race/National Origin details"
                }
            }
            
            //            if(hispanicstatus == .None)
            //            {
            //                return "Please specify your Ethnicity/Race"
            //            }
        }
        
        
        
        return ""
        /*  else if(empAddress.text!.removeUnvantedcharactoes() == "")
         {
         return "Please enter present employer address"
         }
         
         else if(earnings.text!.removeUnvantedcharactoes() == "")
         {
         return "Please enter present earnings"
         }
         else if(occupation.text!.removeUnvantedcharactoes() == "")
         {
         return "Please enter occupation/department"
         }
         else if !(employementPhone.text!.validatePhone())
         {
         return "Please enter a valid present employer phone number"
         }
         else if(wishShareStatus == .Share)
         {
         if(hispanicstatus == .None)
         {
         return "Please select any ethnicity"
         }
         }*/
        
    }
    
    func isValidSsn(ssn: String) -> Bool
    {
        let ssnRegext = "^(?!(000|666|9))\\d{3}-(?!00)\\d{2}-(?!0000)\\d{4}$"
        return ssn.range(of: ssnRegext, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    
    @objc func clickOnDonotwish()
    {
        if(wishShareStatus == .Share)
        {
            wishShareStatus = .DoNotShare
            self.hispanicStatusChange(status: .DoNotShare)
        }
        else
        {
            wishShareStatus = .Share
            self.hispanicStatusChange(status: .Share)
        }
    }
    @objc func clickOnNotHispanic()
    {
        if(wishShareStatus == .Share)
        {
            hispanicstatus = .NotHispanic
            self.hispanicStatusChange(status: .NotHispanic)
        }
    }
    @objc func clickOnHispanic()
    {
        if(wishShareStatus == .Share)
        {
            hispanicstatus = .Hispanic
            self.hispanicStatusChange(status: .Hispanic)
        }
    }
    func hispanicStatusChange(status:HispanicStatus)
    {
        switch status {
        case .DoNotShare:
            self.donotwishImage.image = UIImage(named: "BigTick")
            //self.hispanicImage.image = UIImage(named: "deselectedRound")
            //self.nothispanicImage.image = UIImage(named: "deselectedRound")
            break;
        case .Hispanic:
            
            // self.hispanicImage.image = UIImage(named: "BigTick")
            // self.nothispanicImage.image = UIImage(named: "deselectedRound")
            break;
        case .NotHispanic:
            
            // self.hispanicImage.image = UIImage(named: "deselectedRound")
            //self.nothispanicImage.image = UIImage(named: "BigTick")
            break;
        case .Share:
            self.donotwishImage.image = UIImage(named: "deselectedRound")
            //  self.hispanicImage.image = UIImage(named: "deselectedRound")
            //  self.nothispanicImage.image = UIImage(named: "deselectedRound")
            break;
        case .None:
            //   self.hispanicImage.image = UIImage(named: "deselectedRound")
            //   self.nothispanicImage.image = UIImage(named: "deselectedRound")
            break;
        }
    }
    
    @IBAction func presentEmployeeEarningTypeButtonAction(_ sender: UIButton) {
        //   self.DropDownDefaultfunction(sender, sender.bounds.width, ["Monthly","Weekly","Daily","Yearly"], 0, delegate: self, tag: monthlyTag)
        self.DropDownDefaultfunction(sender, sender.bounds.width, ["Monthly"], 0, delegate: self, tag: monthlyTag)
    }
    @IBAction func dateofbirthpickingAction(_ sender: UITextField) {
        isDateOFBirth = 1
        datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        //       datePicker.backgroundColor =  UIColor.init(red: 40/255, green: 59/255, blue: 79/255, alpha: 1)
        //       datePicker.tintColor = UIColor.white
        //        datePicker.setSelected(UIColor.white)
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
        if(isDateOFBirth == 1)
        {
            self.dateofbirth.text = dateString
        }
        else if(isDateOFBirth == 2)
        {
            
            self.lisenceExpDate.text = dateString
        }
        else if(isDateOFBirth == 3)
        {
            self.lisenceissueDate.text = dateString
        }
        self.view.endEditing(true)
        
    }
    @IBAction func passwordVisbleBatton(_ sender: UIButton) {
        isPasswordVisble = !isPasswordVisble
        self.socialSecurityNo.isSecureTextEntry = !isPasswordVisble
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    @IBAction func lisenceExpDatePickAction(_ sender: UITextField) {
        isDateOFBirth = 2
        
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.minimumDate = Date()
        
        //                      datePicker.backgroundColor =  UIColor.init(red: 40/255, green: 59/255, blue: 79/255, alpha: 1)
        //                      datePicker.tintColor = UIColor.white
        //                      datePicker.setSelected(UIColor.white)
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
    
    @IBAction func lisenceIssueDatePickAction(_ sender: UITextField) {
        isDateOFBirth = 3
        
        
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.maximumDate = Date()
        
        //                      datePicker.backgroundColor =  UIColor.init(red: 40/255, green: 59/255, blue: 79/255, alpha: 1)
        //                      datePicker.tintColor = UIColor.white
        //                      datePicker.setSelected(UIColor.white)
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
    
    
    @IBAction func exEmployeeEarningTypeButtonAction(_ sender: UIButton) {
        self.DropDownDefaultfunction(sender, sender.bounds.width, ["Monthly"], 0, delegate: self, tag: exmonthlyTag)
    }
    
    @IBAction func martialStatusButtonAction(_ sender: UIButton) {
        self.DropDownDefaultfunction(sender, sender.bounds.width, [ "Married","Unmarried","Separated"], 0, delegate: self, tag: marriedTag)
    }
    @IBAction func raceButtonAction(_ sender: UIButton) {
        if(wishShareStatus == .Share)
        {
            let names = ["American Indian or Alaskan Native",
                         "White/Caucasian (non Hispanic)",
                         "Hispanic",
                         "Asian or Pacific Islander",
                         "Black (non Hispanic)","Other"]
            self.DropDownDefaultfunction(sender, sender.bounds.width, names, 0, delegate: self, tag: raceTag)
        }
        
    }
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        if(tag == raceTag)
        {
            if(item == "Other")
            {
                raceOherView.isHidden = false
                receOtherHightConstrain.constant = 105
                raceOtherTopConstrain.constant = 25
            }
            else
            {
                raceOherView.isHidden = true
                receOtherHightConstrain.constant = 0
                raceOtherTopConstrain.constant = 0
            }
            race.text = item
        }
        else if(tag == marriedTag)
        {
            self.martialStatus.text = item
        }
        else if(tag == exmonthlyTag)
        {
            //self.exEarningType.text = item
        }
        else if(tag == monthlyTag)
        {
            self.monthlyEarnings = item
        }
    }
    func DidAddressSelectPlaceEntryDelegate(title: String, mapItem: MKMapItem?, tag: Int) {
        if let mapPlace = mapItem
        {
            
            // Location name
            if let locationName = mapPlace.placemark.location {
                print(locationName)
            }
            // Street address
            if let street = mapPlace.placemark.thoroughfare {
                print(street)
            }
            // state
            if let state = mapPlace.placemark.administrativeArea {
                self.stateZipCode.text = state
            }
            // City
            if let city = mapPlace.placemark.subAdministrativeArea {
                self.city.text = city
            }
            // Zip code
            if let zip = mapPlace.placemark.postalCode {
                self.zipCode.text = zip
            }
            // Country
            if let country = mapPlace.placemark.country {
                print(country)
            }
        }
        self.address.text = title
        
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
                        if(co.lowercased() == "locality")
                        {
                            self.city.text = component.name
                        }
                        else if(co.lowercased() == "postal_code")
                        {
                            self.zipCode.text = component.name
                        }
                        else if(co.lowercased() == "administrative_area_level_1")
                        {
                            self.stateZipCode.text = component.shortName
                        }
                        else if(co.lowercased() == "street_number")
                        {
                            self.address.text = ""
                            self.address.text = component.name
                        }
                        else if(co.lowercased() == "route")
                        {
                            self.address.text = (self.address.text ?? "") + " " + component.name
                        }
                    }
                }
                
                self.address.text = title
                
            }
        }
        else if (tag == 1)
        {
            if let mapPlace = mapItem
            {
                for component in mapPlace.addressComponents ?? []
                {
                    for co in component.types
                    {
                        if(co.lowercased() == "administrative_area_level_2")
                        {
                            self.exCity.text = component.name
                        }
                        else if(co.lowercased() == "postal_code")
                        {
                            self.exZipCode.text = component.name
                        }
                        else if(co.lowercased() == "administrative_area_level_1")
                        {
                            self.exState.text = component.name
                        }
                        
                    }
                }
                
                self.exAddress.text = title
                
            }
        }
        else if (tag == 2)
        {
            self.empAddress.text = mapItem?.formattedAddress
        }
        else if (tag == 3)
        {
            
            //              self.exEmployeeAddress.text =  (mapItem?.name ?? "") + "," + (mapItem?.formattedAddress ?? "")
            // self.exEmployeeAddress.text = mapItem?.formattedAddress
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
extension ApplicantFormViewControllerForm: ImagePickerDelegate {
    
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
extension ApplicantFormViewControllerForm:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return creditRequest.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentMethorInDownPaymentCollectionViewCell", for: indexPath) as! PaymentMethorInDownPaymentCollectionViewCell
        
        cell.nameLabel.text = creditRequest[indexPath.row]
        if(selectedReq == indexPath.row)
        {
            cell.selectImageView.image = UIImage(named: "selectedRound")
        }
        else
        {
            cell.selectImageView.image = UIImage(named: "deselectedRound")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedReq = indexPath.row
        self.creditRequestCollectionView.reloadData()
    }
}
extension ApplicantFormViewControllerForm: GMSAutocompleteViewControllerDelegate {
    
    
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
enum HispanicStatus
{
    case Hispanic
    case NotHispanic
    case DoNotShare
    case Share
    case None
}
