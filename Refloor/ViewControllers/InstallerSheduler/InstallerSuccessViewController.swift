//
//  InstallerSuccessViewController.swift
//  Refloor
//
//  Created by Bincy C A on 22/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit

protocol CreditApplicationProtocol
{
    func creditApplicationCall(isVersatile:Bool)
}

class InstallerSuccessViewController: UIViewController {
    
    @IBOutlet weak var installerSubheadingBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var installerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var hunterLoanProviderOutlet: UILabel!
    @IBOutlet weak var hunterLoanProvidert: UILabel!
    @IBOutlet weak var approvedAmountOutlet: UILabel!
    @IBOutlet weak var refrenceNumberOutlet: UILabel!
    @IBOutlet weak var loanProviderOutlet: UILabel!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var gotToCreditAplBtn: UIButton!
    @IBOutlet weak var gotToHunterAplBtn: UIButton!
    @IBOutlet weak var versatileViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var installerSuccess: UIImageView!
    @IBOutlet weak var approvedAmountLbl: UILabel!
    @IBOutlet weak var referenceNumberLbl: UILabel!
    @IBOutlet weak var loanProviderLbl: UILabel!
    @IBOutlet weak var subHeading: UILabel!
    @IBOutlet weak var confirmLbl: UILabel!
    @IBOutlet weak var versatileView: UIView!
    @IBOutlet weak var gotoCreditBtnHeightConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var tryAgainTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var installerSuccessview: UIView!
    @IBOutlet weak var installationDateLbl: UILabel!
    @IBOutlet weak var appointmentIdLbl: UILabel!
    @IBOutlet weak var thankYouBtn: UIButton!
    @IBOutlet weak var goToAptBtn: UIButton!
    @IBOutlet weak var customerNameLbl: UILabel!
    var creditApplication: CreditApplicationProtocol?
    
    var appointmentdate:String = String()
    var customerName:String = String()
    var installationDate:String = String()
    var isVersatile:Bool = Bool()
    var isHunter:Bool = Bool()
    
    var downOrFinal:Double = 0
    var totalAmount:Double = 0
    var paymentPlan:PaymentPlanValue?
    var paymentPlanValue:PaymentPlanValue?
    var paymentOptionDataValue:PaymentOptionDataValue?
    var drowingImageID = 0
    var area:Double = 0
    var downPaymentValue:Double = 0
    var finalpayment:Double = 0
    var financePayment:Double = 0
    var selectedPaymentMethord:PaymentType?
    var downpayment = DownPaymentViewController.initialization()!
    
    var status:String = String()
    var loanProvider:String = String()
    var refernceNumber:String = String()
    var approvedAmount:String = String()
    var successMsg:String = String()
    var isCoAppSkiped = 0
    var timer: Timer?
    var time = 0
    
    static func initialization() -> InstallerSuccessViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "InstallerSuccessViewController") as? InstallerSuccessViewController

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        schedulerSuccessNavBar()
        if isHunter
        {
            installerViewHeightConstraint.constant = 0
            installerSubheadingBottomConstraint.constant = 15
            installerSuccessview.isHidden = true
            versatileView.isHidden = false
            if successMsg == "Success"
            {
                if status == "Pending"
                {
                    versatileViewHeightConstraints.constant = 128
                    installerSubheadingBottomConstraint.constant = 46
                    installerViewHeightConstraint.constant = 128
                    //status = "approved"
                    confirmLbl.text = "Submitted"
                    subHeading.text = "Your loan application has been submitted successfully to hunter financial."
                    installerSuccess.image = UIImage(named: "installerSuccess")
                    hunterLoanProvidert.text = "Hunter Financial"
                    hunterLoanProvidert.isHidden = false
                    hunterLoanProviderOutlet.isHidden = false
                    loanProviderLbl.isHidden = true
                    loanProviderOutlet.isHidden = true
                    thankYouBtn.isHidden = false
                    referenceNumberLbl.isHidden = true
                    approvedAmountLbl.isHidden = true
                    goToAptBtn.isHidden = true
                    refrenceNumberOutlet.isHidden = true
                    approvedAmountOutlet.isHidden = true
                    
                }
            }
        }
       else if isVersatile
        {
            installerViewHeightConstraint.constant = 0
            installerSubheadingBottomConstraint.constant = 15
            installerSuccessview.isHidden = true
            versatileView.isHidden = false
            if successMsg == "Success" //approved, preapproved, prequalified
            {
                if status.lowercased() == "approved" || status.lowercased() == "preapproved" || status.lowercased() == "prequalified"
                {
                    versatileViewHeightConstraints.constant = 128
                    installerSubheadingBottomConstraint.constant = 46
                    installerViewHeightConstraint.constant = 128
                    //status = "approved"
                    subHeading.text = "Your application has been approved."
                    installerSuccess.image = UIImage(named: "installerSuccess")
                    
                    thankYouBtn.isHidden = false
                }
                else if status.lowercased() == "canceled" || status.lowercased() == "declined" || status.lowercased() == "expired" || status.lowercased() == "nooffer" || status.lowercased() == "pending"
                {

                    versatileView.isHidden = true
                    //status = "declined"
                    confirmLbl.textColor = UIColor().colorFromHexString("#C93F48")
                    if status.lowercased() == "nooffer"
                    {
                        self.status = "no offer"
                        subHeading.text = "Sorry, there are no available offers at this time."
                    }
                    else if status.lowercased() == "pending"
                    {
                        subHeading.text = "Your application is pending. Please contact the lender and provide additional information where required."
                    }
                    else
                    {
                        subHeading.text = "Your application has been declined."
                    }
                    installerSuccess.image = UIImage(named: "versatileDeclined")
                    versatileViewHeightConstraints.constant = 0
                    gotoCreditBtnHeightConstraint.constant = 70
                    gotToCreditAplBtn.isHidden = false
                    gotToHunterAplBtn.isHidden = false
                    thankYouBtn.isHidden = true
                    
                    
                    
                }
                else
                {
                    if status.lowercased() == "error"
                    {
                        subHeading.text = "Processing error - please resubmit your application."
                    }
                    else if status.lowercased() == "awaiting"
                    {
                        subHeading.text = "Loan processing is pending as we are await data from lending platform."
                    }
                    
                    //status = "awaiting" //
                    versatileView.isHidden = true
                    confirmLbl.textColor = UIColor().colorFromHexString("#D37A52")
                    //subHeading.text = "Awaiting data from lending platform"
                    installerSuccess.image = UIImage(named: "versatileAwaiting")
                    versatileViewHeightConstraints.constant = 0
                    gotoCreditBtnHeightConstraint.constant = 0
                    tryAgainTopConstraints.constant = 0
                    
                    //gotToCreditAplBtn.isHidden = false
                    thankYouBtn.isHidden = true
                    tryAgainBtn.isHidden = false
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(versatileTimerActivated), userInfo: nil, repeats: true)
                }
            }
            else
           {
                if loanProvider == "" && approvedAmount == "0.0"
                {
                    self.status = "DECLINED"
                    self.confirmLbl.text = self.status
                    self.confirmLbl.textColor = UIColor().colorFromHexString("#C93F48")
                    self.subHeading.text = "Your loan application through lending platform is declined."
                    self.installerSuccess.image = UIImage(named: "versatileDeclined")
                    self.versatileViewHeightConstraints.constant = 0
                    self.gotToCreditAplBtn.isHidden = false
                    self.gotToHunterAplBtn.isHidden = false
                    gotoCreditBtnHeightConstraint.constant = 70
                    self.tryAgainBtn.isHidden = true
                    loanProviderOutlet.isHidden = true
                    refrenceNumberOutlet.isHidden = true
                    approvedAmountOutlet.isHidden = true
                    approvedAmountLbl.isHidden = true
                    
                }
                else
                {
                    status = "awaiting"
                    if status.lowercased() == "error"
                    {
                        subHeading.text = "Processing error - please resubmit your application."
                    }
                    else if status.lowercased() == "awaiting"
                    {
                        subHeading.text = "Loan processing is pending as we are await data from lending platform."
                    }
                    
                    //status = "awaiting" //
                    versatileView.isHidden = true
                    confirmLbl.textColor = UIColor().colorFromHexString("#D37A52")
                    //subHeading.text = "Awaiting data from lending platform"
                    installerSuccess.image = UIImage(named: "versatileAwaiting")
                    versatileViewHeightConstraints.constant = 0
                    gotoCreditBtnHeightConstraint.constant = 0
                    tryAgainTopConstraints.constant = 0
                    
                    //gotToCreditAplBtn.isHidden = false
                    thankYouBtn.isHidden = true
                    tryAgainBtn.isHidden = false
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(versatileTimerActivated), userInfo: nil, repeats: true)
                }
                confirmLbl.text = status.uppercased()
                
                
                
                loanProviderLbl.text = loanProvider
                referenceNumberLbl.text = refernceNumber
                let approvedAmountDouble = Double(approvedAmount)
                approvedAmountLbl.text = "$" + String.localizedStringWithFormat("%.2f",approvedAmountDouble ?? 0.0)
                goToAptBtn.isHidden = true
            }
           confirmLbl.text = status.uppercased()
           loanProviderLbl.text = loanProvider
           referenceNumberLbl.text = refernceNumber
           let approvedAmountDouble = Double(approvedAmount)
           approvedAmountLbl.text = "$" + String.localizedStringWithFormat("%.2f",approvedAmountDouble ?? 0.0)
           goToAptBtn.isHidden = true
        }
        else
        {
            //installerSuccess
            installerViewHeightConstraint.constant = 128
            installerSubheadingBottomConstraint.constant = 46
            installerSuccess.image = UIImage(named: "installerSuccess")
            confirmLbl.text = "CONFIRMED"
            subHeading.text = "Your installation request has been submitted successfully"
            installerSuccessview.isHidden = false
            versatileView.isHidden = true
            thankYouBtn.isHidden = true
            goToAptBtn.isHidden = false
            tryAgainBtn.isHidden = true
            gotToCreditAplBtn.isHidden = true
            gotToHunterAplBtn.isHidden = true
            let appointmentId = AppointmentData().appointment_id ?? 0
            appointmentIdLbl.text = String(appointmentId)
            customerNameLbl.text = customerName
            installationDateLbl.text = installationDate
        }
        
    }
    
    
    @objc func versatileTimerActivated()
    {
        time = time + 1
        if time == 60
        {
            timer?.invalidate()
            versatileStatusApiCall()
        }
    }
    @IBAction func goToHunterBtnPressed(_ sender: UIButton)
    {
        if isVersatile
        {
            creditApplication?.creditApplicationCall(isVersatile: isVersatile)
        }
       // self.creditApplication = self
        
    }
    @IBAction func goToCreditAplBtnPressed(_ sender: UIButton)
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
        self.navigationController?.pushViewController(applicant, animated: true)
    }
    @IBAction func goToAptBtn(_ sender: UIButton)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func tryAgainBtnPressed(_ sender: UIButton)
    {
       
            versatileStatusApiCall()
        
    }
    
    func versatileStatusApiCall()
    {
        let parameter : [String:Any] = ["appointment_id":AppDelegate.appoinmentslData.id ?? 0,"loan_type":"versatile"]
        HttpClientManager.SharedHM.versatileStatusAPi(parameter: parameter) { [self]
            success, message ,data in
            
            if success == "Success"
            {
                if data!.status == "approved" || data!.status == "preapproved" || data!.status == "prequalified"
                {
                    self.status = data?.status?.uppercased() ?? ""
                    self.subHeading.text = "Your loan has been approved"
                    self.installerSuccess.image = UIImage(named: "installerSuccess")
                    self.versatileViewHeightConstraints.constant = 128
                }
                else //if data!.status == "canceled" || data!.status == "declined" || data!.status == "expired" || data!.status == "nooffer" || data!.status == "pending"
                {
                    if time < 60
                    {
                        return
                    }
                    else
                    {
                        self.status = "DECLINED"
                        self.confirmLbl.text = self.status
                        self.confirmLbl.textColor = UIColor().colorFromHexString("#C93F48")
                        self.subHeading.text = "Your loan application through lending platform is declined."
                        self.installerSuccess.image = UIImage(named: "versatileDeclined")
                        self.versatileViewHeightConstraints.constant = 0
                        self.gotToCreditAplBtn.isHidden = false
                        self.gotToHunterAplBtn.isHidden = false
                        gotoCreditBtnHeightConstraint.constant = 70
                        self.tryAgainBtn.isHidden = true
                    }
                    
                }
            }
            else
            {
                if time < 60
                {
                    return
                }
                else
                {
                    self.status = "DECLINED"
                    self.confirmLbl.text = self.status
                    self.confirmLbl.textColor = UIColor().colorFromHexString("#C93F48")
                    self.subHeading.text = "Your loan application through lending platform is declined."
                    self.installerSuccess.image = UIImage(named: "versatileDeclined")
                    self.versatileViewHeightConstraints.constant = 0
                    self.tryAgainBtn.isHidden = true
                    self.gotToCreditAplBtn.isHidden = false
                    self.gotToHunterAplBtn.isHidden = false
                    gotoCreditBtnHeightConstraint.constant = 70
                }
            }
        }
    }
    
    @IBAction func thankYouBtnPressed(_ sender: UIButton)
    {
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
        if let customer = AppDelegate.appoinmentslData
        {
            signature.isCoAppSkiped = customer.co_applicant_skipped ?? 0
        }
        self.navigationController?.pushViewController(signature, animated: true)
    }
        
    
    
}

//extension InstallerSuccessViewController: CreditApplicationProtocol
//{
//    if isVersatile
//    {
//        creditApplication?.creditApplicationCall(isVersatile: isVersatile)
//    }
//}
