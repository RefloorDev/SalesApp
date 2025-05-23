//
//  PaymentDetailsViewController.swift
//  Refloor
//
//  Created by sbek on 12/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit


class PaymentDetailsViewController: UIViewController, versatileProtocol{
    func whetherToProceed(isConfirmBtnPressed: Bool) {
        print(isConfirmBtnPressed)
        if isConfirmBtnPressed
        {
           // versatileCall()
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
    
    static public func initialization() -> PaymentDetailsViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentDetailsViewController
    }
    
    @IBOutlet weak var totalFinanceAmount: UILabel!
    @IBOutlet weak var financeTypeHeading: UILabel!
    @IBOutlet weak var financeAmount: UILabel!
    @IBOutlet weak var financeTitleLabel: UILabel!
    @IBOutlet weak var finalPayment: UILabel!
    @IBOutlet weak var downPayment: UILabel!
    @IBOutlet weak var totelPrice: UILabel!
    @IBOutlet weak var pakageName: UILabel!
    @IBOutlet weak var adminFeeLabel: UILabel!
    @IBOutlet weak var adminFeeLabelTitle: UILabel!
    @IBOutlet weak var financeTitleHightConstrain: NSLayoutConstraint!
    @IBOutlet weak var financeTopConstrain: NSLayoutConstraint!
    var selectedPaymentMethord:PaymentType?
    var downOrFinal:Double = 0
    var totalAmount:Double = 0
    var adminFee:Double = 0
    // var adminFeeStatus:Int = 0
    var adminFeeStatus = false
    var isPaymentByCash = false
    var installationDate = ""
    var coapplicantSkiip:Int = 0
    var fullLoan = ""
    var loanPayment:Double = 0
    var paymentPlan:PaymentPlanValue?
    var downPaymentValue:Double = 0
    var finalpayment:Double = 0
    var adjustmentValue:Double = 0
    var financePayment:Double = 0
    var paymentPlanValue:PaymentPlanValue?
    var paymentOptionDataValue:PaymentOptionDataValue?
    var drowingImageID = 0
    var area:Double = 0
    var excluded_amount_promotion:Double = 0.0
    var downpayment = DownPaymentViewController.initialization()!
    var imagePicker: CaptureImage!
    var savings:Double = 0
    var specialPriceId:Int = Int()
    var stairSpecialPriceId:Int = Int()
    var promotionCodeId:Int = Int()
    var stairPrice:Double = Double()
    var minSalePrice:Double = 0.0
    var packagePlanName = ""
    var roomName = ""
    
    override func viewWillAppear(_ animated: Bool ){
        
        self.setNavigationBarbackAndlogo(with: "Payment Summary".uppercased())
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        // adminFeeLabelTitle.isHidden = true
        // adminFeeLabel.isHidden = true
        
        downPayment.text = "$\(downPaymentValue.clean)"
        
        totelPrice.text = "$\((totalAmount + adminFee ).clean)"
        pakageName.text = paymentPlanValue?.plan_title ?? "Unknown"
        
        if(paymentOptionDataValue?.Name == "Cash")
        {
            // self.amountLabel.isHidden = true
            //            self.financeTitleLabel.isHidden = true
            // self.financeTitleLabel.isHidden = true
            // self.financeTitleLabel.textColor = UIColor(white: 1, alpha: 0.3)
            // financeTitleHightConstrain.constant = 100
            //self.financeAmount.textColor = UIColor(white: 1, alpha: 0.3)
            
        }
        
        if(paymentOptionDataValue == nil)
        {
            self.financeTypeHeading.isHidden = true
            self.totalFinanceAmount.isHidden = true
            // adminFeeLabel.text = "$\(adminFee.toDoubleString)"
            if (adminFee>0)
            {
                //  adminFeeLabel.text = "$\(adminFee.clean)"
                totelPrice.text = "$\((totalAmount + adminFee ).toDoubleString)"
                finalpayment = finalpayment + adminFee
                finalPayment.text =  "$\((finalpayment).clean)"
                
            }
            else
            {
                // adminFeeLabel.text = "Waived"
                totelPrice.text = "$\((totalAmount - adminFee ).clean)"
                finalpayment = finalpayment - adminFee
                finalPayment.text =  "$\((finalpayment).clean)"
            }
            
            
            financeAmount.text = "$\((financePayment).toDoubleString)"
            
            
            
        }
        else
        {
            self.financeTypeHeading.text = "Payment Method (\(paymentOptionDataValue?.Name ?? ""))"
            loanPayment =  self.financePayment
            //            if (adminFee>0)
            //            {
            // adminFeeLabel.text = "$\(adminFee.clean)"
            loanPayment = loanPayment + adminFee
            //
            financeAmount.text = "$\((financePayment).toDoubleString)"
            finalPayment.text = "$\(finalpayment.clean)"
            if(financePayment == 0)
            {    finalpayment = finalpayment + adminFee
                finalPayment.text =  "$\((finalpayment).clean)"
                totalFinanceAmount.isHidden = true
                
            }
            else
            {
                financePayment = financePayment + adminFee
                financeAmount.text = "$\((financePayment).clean)"
            }
            let Balance_DueDt = Double(self.paymentOptionDataValue?.Balance_Due__c ?? "0") ?? 0
            
            if(Balance_DueDt > 0)
            {
                self.financeTypeHeading.text = "Payment Amount (\(paymentOptionDataValue?.Name?.withoutHtml ?? ""))"
                let stringFormmatting = self.financeTypeHeading.text
                let usingreplacingOccurrences = stringFormmatting!.replacingOccurrences(of: "\n",with: " ")
                self.financeTypeHeading.text = usingreplacingOccurrences
                let today = Date()
                let Balance_DueDt = Double(self.paymentOptionDataValue?.Balance_Due__c ?? "0") ?? 0
                let modifiedDate = Calendar.current.date(byAdding: .day, value: Int(Balance_DueDt), to: today)!
                self.totalFinanceAmount.text =  "Balance Due On: " + modifiedDate.DateFromStringMonthDate()
                
            }
            else
            {
                //self.totalFinanceAmount.text = "$\((self.financePayment * (Double(self.paymentOptionDataValue?.Payment_Factor__c ?? "0") ?? 0)).toDoubleString)"
                if self.paymentOptionDataValue?.Secondary_Payment_Factor__c != "0"
                {
                    self.totalFinanceAmount.text = "$\((self.financePayment * (Double(self.paymentOptionDataValue?.Payment_Factor__c ?? "0") ?? 0)).rounded().clean) - $\((self.financePayment * (Double(self.paymentOptionDataValue?.Secondary_Payment_Factor__c ?? "0") ?? 0)).rounded().clean)"
                }
                else
                {
                    self.totalFinanceAmount.text = "$\((self.financePayment * (Double(self.paymentOptionDataValue?.Payment_Factor__c ?? "0") ?? 0)).rounded().clean)"
                }
            }
            
            
            
            totalAmount = totalAmount + adminFee
            
            totelPrice.text = "$\((totalAmount).clean)"
            
            
            
            //   }
            /* else
             {
             // adminFeeLabel.text = "Waived"
             loanPayment = loanPayment - adminFee
             financeAmount.text = "$\((financePayment).clean)"
             self.totalFinanceAmount.text = "$\(loanPayment.toDoubleString)"
             totalAmount = totalAmount - adminFee
             totelPrice.text = "$\((totalAmount).clean)"
             finalPayment.text = "$\(finalpayment.clean)"
             }*/
            
        }
        // Do any additional setup after loading the view.
    }
    
    
    
    func getloanPayment(tag:Int)
    {
        if(tag == 0)
        {
            self.loanPayment = (self.financePayment * 0.04)
        }
        else if(tag == 1)
        {
            self.loanPayment = (self.financePayment * 0.0132)
        }
        else
        {
            self.loanPayment = (self.financePayment * 0)
        }
    }
    func getPaymentmethordString(payment:PaymentType) -> String
    {
        switch payment {
        case .Cash:
            return "cash"
        case .DebitCard:
            return "debit_card"
        case .CreditCard:
            return "credit_card"
        case .Check:
            return "check"
        }
    }
    func createSalesQuotation()
    {
        
        let costpersqft = (self.paymentPlanValue?.cost_per_sqft ?? 0)
        let mrp = costpersqft * area
        var paymentmethord = ""
        var adminStatusValue:Int = 0
        if self.adminFeeStatus
        {
            adminStatusValue=1
        }
        else
        {
            adminStatusValue=0
        }
        
        if let pay = selectedPaymentMethord
        {
            paymentmethord = self.getPaymentmethordString(payment: pay)
        }
        
        if(totalAmount == financePayment)
        {
            paymentmethord = "finance"
        }
        //arb
        if self.financePayment > 0{
            paymentmethord = "finance"
        }
        //
        if let customer = AppDelegate.appoinmentslData
        {
            coapplicantSkiip = customer.co_applicant_skipped ?? 0
        }
        let data = ["selected_package_id":paymentPlanValue?.id ?? 0,"appointment_id":AppDelegate.appoinmentslData.id ?? 0,"discount":self.paymentPlanValue?.discount ?? 0,"payment_method":paymentmethord,"finance_option_id":paymentOptionDataValue?.id ?? 0,"additional_cost":self.paymentPlanValue?.additional_cost ?? 0,"msrp":mrp + self.stairPrice,"installation_date":self.installationDate,"photo_permission":adminStatusValue,"adjustment":adjustmentValue,"price":totalAmount,"down_payment_amount":downPaymentValue,"final_payment":finalpayment,"finance_amount":financePayment,"coapplicant_skip":coapplicantSkiip,"savings": savings,"special_price_id":specialPriceId,"stair_special_price_id":stairSpecialPriceId,"calc_based_on":"msrp","stair_calc_based_on":"msrp","promotion_code_id":promotionCodeId, "excluded_amount_promotion":self.excluded_amount_promotion,"min_sale_price": self.minSalePrice] as [String : Any]
        //arb
        print("savePaymentDetailsToAppointmentDetail data : ", data)
        self.savePaymentDetailsToAppointmentDetail(data: data as NSDictionary)
        //
        //test
        // let dict = self.getPaymentDetailsDataFromAppointmentDetail()
        //print(dict)
        //
        
        //let parameter = ["token":UserData.init().token ?? "","data":data,"loan_payment":self.loanPayment] as [String : Any]
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "PaymentSummary"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
      
        
//        let financeCheckList = FinanceOrderCheckListViewController.initialization()!
//        self.navigationController?.pushViewController(financeCheckList, animated: true)
        
            if(self.financePayment != 0)
            {
                
                let applicant = FinanceViewController.initialization()!
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
                applicant.adminFee = self.adminFee
                applicant.downPaymentValue = self.downPaymentValue
                applicant.finalpayment = self.finalpayment
                applicant.financePayment = self.financePayment
                applicant.selectedPaymentMethord = self.selectedPaymentMethord
                applicant.downpayment = self.downpayment
                applicant.packagePlanName = self.packagePlanName
                applicant.installationDate = self.installationDate
                applicant.adminFeeStatus = self.adminFeeStatus
                applicant.coapplicantSkiip = self.coapplicantSkiip
                applicant.minSalePrice = self.minSalePrice
                applicant.savings = self.savings
                applicant.promotionCodeId = self.promotionCodeId
                
                self.navigationController?.pushViewController(applicant, animated: true)
  
//                }
            }
            else
            {

                
                //Q4 Cahnges
                print("inside UpdateCustomerDetailsOneViewController")
                
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
                details.isPaymentByCash = self.isPaymentByCash
                details.selectedPaymentMethord1 = self.selectedPaymentMethord
                details.installationDate = self.installationDate
                details.adminFeeStatus = self.adminFeeStatus
                details.coapplicantSkiip = self.coapplicantSkiip
                details.minSalePrice = self.minSalePrice
                details.savings = self.savings
                details.promotionCodeId = self.promotionCodeId
                details.stairPrice = self.stairPrice
                details.excluded_amount_promotion = self.excluded_amount_promotion
            
                self.navigationController?.pushViewController(details, animated: true)
                

            }
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        createSalesQuotation()
        
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension PaymentDetailsViewController: ImagePickerDelegate {

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
