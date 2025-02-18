//
//  UpdateDownFinalPaymentViewController.swift
//  Refloor
//
//  Created by Apple on 07/02/25.
//  Copyright © 2025 oneteamus. All rights reserved.
//

import UIKit

class UpdateDownFinalPaymentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    static public func initialization() -> UpdateDownFinalPaymentViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateDownFinalPaymentViewController") as? UpdateDownFinalPaymentViewController
    }
    
    //@IBOutlet weak var installationDate: UITextField!
    //@IBOutlet weak var yesImageVIew: UIImageView!
    //@IBOutlet weak var noImageView: UIImageView!
    //@IBOutlet weak var yesButton: UIButton!
    // @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var downPaymentTitleLabel: UILabel!
    // @IBOutlet weak var adminFeeLabel: UILabel!
    @IBOutlet weak var finalPaymentTF: UITextField!
    @IBOutlet weak var downPaymentTF: UITextField!
    @IBOutlet weak var paymentMethordCollectionView: UICollectionView!
    var isPaymentByCash = false
    var paymentMethords:[PaymentType] = [.DebitCard,.CreditCard,.Cash,.Check]
    var selectedPaymentMethord = 0
    var selectedPaymentMethord1:PaymentType?
    var downOrFinal:Double = 0
    var totalAmount:Double = 0
    var paymentPlan:PaymentPlanValue?
    var downPayment:Double = 0
    var finalpayment:Double = 0
    var adjustmentValue:Double = 0
    var financePayment:Double = 0
    var roomName = ""
    var isAdmiFee = false
    var adminFee:Double = 0
    var adminFeeText = ""
    var datePicker = UIDatePicker()
    var paymentPlanValue:PaymentPlanValue?
    var paymentOptionDataValue:PaymentOptionDataValue?
    var drowingImageID = 0
    var area:Double = 0
    var savings:Double = 0
    var downpayment = DownPaymentViewController.initialization()!
    var summery = PaymentDetailsViewController.initialization()!
    var specialPriceId:Int = Int()
    var stairSpecialPriceId:Int = Int()
    var stairsSpecialPriceId:Int = Int()
    var imagePicker: CaptureImage!
    var promotionCodeId:Int = Int()
    var stairPrice:Double = Double()
    var excluded_amount_promotion:Double = 0.0
    var minSalePrice:Double = 0.0
    var downPaymentValue:Double = 0.0
    var packagePlanName = ""
    var roomData:[RoomDataValue]?
    var floorShapeData:[FloorShapeDataValue]?
    var floorLevelData:[FloorLevelDataValue]?
    var appoinmentslData:AppoinmentDataValue!
    var coapplicantSkiip:Int = 0
    var installationDate = ""
    var adminFeeStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "Down and Final Payment".uppercased())
        // adminFeeLabel.text="\("I/We will allow REFLOOR to use photos, video and/or job signage for marketing purposes to waive the $")\(self.adminFee) \("Admin Fee")"
        if(!isPaymentByCash)
        {
            isPaymentByCash = (paymentPlan == nil)
        }
        finalPaymentTF.setPlaceHolderWithColor(placeholder: "$", colour: UIColor.placeHolderColor)
        downPaymentTF.setPlaceHolderWithColor(placeholder: "$", colour: UIColor.placeHolderColor)
        paymentMethordCollectionView.delegate = self
        paymentMethordCollectionView.dataSource = self
        let htmlString = paymentOptionDataValue?.Name
        let str = htmlString?.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
//        downPaymentTitleLabel.text = (self.paymentPlanValue?.plan_title ?? "") + " " + "(\(str ?? ""))"
        downPaymentTitleLabel.text = packagePlanName
        
        finalPaymentTF.delegate = self
        downPaymentTF.delegate = self
        print("downPaymentValue : ", downPaymentValue, " finalpayment : ", finalpayment)
        downPaymentTF.text = "\(downPaymentValue)"
        finalPaymentTF.text = "\(finalpayment)"
        // downPayment = downOrFinal/2
        // finalpayment = downOrFinal/2
        downPayment = downOrFinal
        if(paymentOptionDataValue?.Name == "Cash")
        {
            
            
            downPayment = downOrFinal
            finalpayment = totalAmount-downOrFinal
            if(totalAmount < 2)
            {
                downPayment = totalAmount
                
            }
            
            // let temp = totalAmount % 2
            let temp = totalAmount.truncatingRemainder(dividingBy:2)
            if(temp>0)
            {
                finalpayment = finalpayment + temp
            }
            //  finalpayment = finalpayment + temp
            self.amountLabel.isHidden = true
            self.selectedPaymentMethord = -1
        }
        // finalpayment =
        finalPaymentTF.text = ""
        UIUpdateForValueChange(isUpdateDownPayment: true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        self.validationDownpayment()
        print(self.summery.downPaymentValue)
        print(self.summery.finalpayment)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    @IBAction func yesnoButtonAction(_ sender: UIButton) {
        
        //        if(sender == yesButton)
        //        {
        //            self.isAdmiFee = true
        //             self.yesImageVIew.image = UIImage(named: "BigTick")
        //             self.noImageView.image = UIImage(named: "deselectedRound")
        //        }
        //        else
        //        {
        //             self.isAdmiFee = false
        //            self.yesImageVIew.image = UIImage(named: "deselectedRound")
        //            self.noImageView.image = UIImage(named: "BigTick")
        //        }
    }
    @IBAction func installationDatePicker(_ sender: UITextField) {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        
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
        // self.installationDate.text = dateString
        self.view.endEditing(true)
        
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    
    func UIUpdateForValueChange(isUpdateDownPayment:Bool)
    {
        if(isUpdateDownPayment)
        {
            if(downPayment < 0)
            {
                downPayment = 0
            }
            //finalpayment = downOrFinal - downPayment
            if(finalpayment < 0)
            {
                if(totalAmount < downPayment)
                {
                    downPayment = totalAmount
                }
                
                finalpayment = 0
                downOrFinal = downPayment
            }
            else
            {
                if downPayment > totalAmount
                {
                    downPayment = totalAmount
                    finalpayment = 0
                }
                self.finalPaymentTF.text = "\(finalpayment.noDecimal)"
            }
            
        }
        else
        {
            if finalpayment < 0
            {
                finalpayment = 0
            }
            if (finalpayment + downPayment) != downOrFinal
            {
                if(finalpayment + downPayment) > totalAmount
                {
                    finalpayment = totalAmount - downPayment
                    downOrFinal = totalAmount
                }
                else
                {
                    downOrFinal = (finalpayment + downPayment)
                }
            }
            
        }
        
        financePayment = totalAmount - (downPayment + finalpayment)
        if (finalpayment <= 0)
        {
            self.selectedPaymentMethord = -1
            self.paymentMethordCollectionView.reloadData()
        }
        else
        {
            if(self.selectedPaymentMethord == -1)
            {
                //  self.selectedPaymentMethord = 0
                self.paymentMethordCollectionView.reloadData()
            }
        }
        if(finalpayment > 0)
        
        {
            self.finalPaymentTF.text = "\(finalpayment.noDecimal)"
            if(paymentOptionDataValue?.Name == "Cash")
            {
                let temp = finalpayment + financePayment
                //  self.finalPaymentTF.text = "\(finalpayment.noDecimal)"
                self.finalPaymentTF.text = "\(temp.noDecimal)"
            }
        }
        else
        {
            //sathself.downPaymentTF.text = ""
        }
        if(downPayment > 0)
        
        {
            self.downPaymentTF.text = "\(downPayment.noDecimal)"
        }
        else
        {
            self.downPaymentTF.text = ""
            
        }
        
        if(financePayment<1)
        {
            financePayment = 0
        }
        if(paymentOptionDataValue?.Name == "Cash")
        {
            // self.amountLabel.isHidden = true
            
            
        }
        else
        {
            self.amountLabel.isHidden = false
            self.amountLabel.text =  "FINANCE AMOUNT: $\(financePayment.clean)"
        }
    }
    @IBAction func downPaymentDidEnd(_ sender: UITextField) {
        let value = Double(sender.text ?? "0")
        // {
        downPayment = value ?? 0
        self.UIUpdateForValueChange(isUpdateDownPayment: true)
        //  }
        //  else
        //  {
        //  self.alert("Please enter a valid value", nil)
        // }
    }
    @IBAction func finalPaymentDidEnd(_ sender: UITextField) {
        let value = Double(sender.text ?? "0")
        //   {
        finalpayment = value ?? 0
        self.UIUpdateForValueChange(isUpdateDownPayment: false)
        //   }
        //   else
        //  {
        //self.alert("Please enter a valid value", nil)
        //  }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 220, height: 69)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return paymentMethords.count
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentMethorInDownPaymentCollectionViewCell", for: indexPath) as! PaymentMethorInDownPaymentCollectionViewCell
        var name = "Debit Card"
        switch paymentMethords[indexPath.item] {
        case .CreditCard:
            name = "Credit Card"
        case .DebitCard:
            name = "Debit Card"
        case .Check:
            name = "Check"
        default:
            name = "Cash"
        }
        cell.nameLabel.text = name
        if(selectedPaymentMethord == indexPath.row)
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
        validationDownpayment()
        if(finalpayment > 0)
        {
            
            self.selectedPaymentMethord = indexPath.item
            self.paymentMethordCollectionView.reloadData()
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
    
    @IBAction func nextButtonAction(_ sender: Any)
    {
        let masterData = getMasterDataFromDB()
        let minAmount = masterData.min_downpayment_amount
        if isPaymentByCash && Double(downPaymentTF.text ?? "") ?? 0.0 < minAmount
        {
            self.alert("Please enter at least $\(minAmount) as down payment to proceed.", nil)
            return
        }
        if(validation() != "")
        {
            self.alert(validation(), nil)
            return
        }
        //self.downPaymentDidEnd(downPaymentTF)
        // self.finalPaymentDidEnd(finalPaymentTF)
        UIUpdateForValueChange(isUpdateDownPayment: true)
        
        
        
        // self.validationDownpayment()
        if(self.paymentOptionDataValue ==  nil || isPaymentByCash)
        {
            
            //  self.alert("You cant continue with out selecting finace option", nil)
            // self.alert("Please go back and select any finance option to proceed", nil)
            print("financePayment : ", financePayment)
            if(financePayment > 1)
            {
                self.alert("Down and final payment amount lower than sales price. Please update the price and tap on Next button.", nil)
                return
            }
            
        }
        
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
        
        if let pay = selectedPaymentMethord1
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
        
        
        UIUpdateForValueChange(isUpdateDownPayment:true)
        self.validationDownpayment()
        let details = UpdateCustomerDetailsOneViewController.initialization()!
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "DownFinalPayment"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        details.floorLevelData = AppDelegate.floorLevelData
        details.floorShapeData = []
        details.roomData = AppDelegate.roomData
        details.appoinmentslData = AppDelegate.appoinmentslData
        details.downOrFinal = self.downOrFinal
        details.totalAmount = self.totalAmount
        details.paymentPlan = self.paymentPlan
        details.paymentPlanValue = self.paymentPlanValue
        details.paymentOptionDataValue = self.paymentOptionDataValue
        details.drowingImageID = self.drowingImageID
        details.area = self.area
        details.downPaymentValue = self.downPaymentValue
        details.finalpayment = self.finalpayment
        details.financePayment = self.financePayment
//        details.selectedPaymentMethord = self.selectedPaymentMethord
        details.downpayment = self.downpayment
        print("finalpayment : ", finalpayment)
        
        let data = ["selected_package_id":paymentPlanValue?.id ?? 0,"appointment_id":AppDelegate.appoinmentslData.id ?? 0,"discount":self.paymentPlanValue?.discount ?? 0,"payment_method":paymentmethord,"finance_option_id":paymentOptionDataValue?.id ?? 0,"additional_cost":self.paymentPlanValue?.additional_cost ?? 0,"msrp":mrp + self.stairPrice,"installation_date":self.installationDate,"photo_permission":adminStatusValue,"adjustment":adjustmentValue,"price":totalAmount,"down_payment_amount":downPaymentValue,"final_payment":finalpayment,"finance_amount":financePayment,"coapplicant_skip":coapplicantSkiip,"savings": savings,"special_price_id":specialPriceId,"stair_special_price_id":stairSpecialPriceId,"calc_based_on":"msrp","stair_calc_based_on":"msrp","promotion_code_id":promotionCodeId, "excluded_amount_promotion":self.excluded_amount_promotion,"min_sale_price": self.minSalePrice] as [String : Any]
        //arb
        print("savePaymentDetailsToAppointmentDetail data : ", data)
        self.savePaymentDetailsToAppointmentDetail(data: data as NSDictionary)
        
        self.navigationController?.pushViewController(details, animated: true)
    }
    func validation() -> String
    {
        let finalvalue = Double(finalPaymentTF.text ?? "0")
        let downvalue = Double(downPaymentTF.text ?? "0")
        // {
        finalpayment = finalvalue ?? 0
        downPayment = downvalue ?? 0
        downPaymentValue = downvalue ?? 0
        
        if (finalpayment>0 && self.selectedPaymentMethord == -1)
        {
            self.UIUpdateForValueChange(isUpdateDownPayment: true)
//            return "Please select final payment method"
            
        }
        if(finalpayment == 0 && self.selectedPaymentMethord != -1)
        {
            self.UIUpdateForValueChange(isUpdateDownPayment: true)
        }
        //                 else
        //                 {
        //                    self.UIUpdateForValueChange(isUpdateDownPayment: false)
        //                  }
        
        
        
        return ""
        
        
        
    }
    func validationDownpayment() -> String
    {
        let finalvalue = Double(finalPaymentTF.text ?? "0")
        let downvalue = Double(downPaymentTF.text ?? "0")
        // {
        finalpayment = finalvalue ?? 0
        downPayment = downvalue ?? 0
        downPaymentValue = downvalue ?? 0
        
        if (finalpayment>0 && self.selectedPaymentMethord == -1)
        {
            self.UIUpdateForValueChange(isUpdateDownPayment: true)
            //return "Please select final payment method"
            
        }
        if(finalpayment == 0 && self.selectedPaymentMethord != -1)
        {
            self.UIUpdateForValueChange(isUpdateDownPayment: true)
        }
        //                 else
        //                 {
        //                    self.UIUpdateForValueChange(isUpdateDownPayment: false)
        //                  }
        
        
        
        return ""
        
        
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


extension UpdateDownFinalPaymentViewController: ImagePickerDelegate {

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
