//
//  DownFinalPaymentViewController.swift
//  Refloor
//
//  Created by sbek on 12/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class DownFinalPaymentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    static public func initialization() -> DownFinalPaymentViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "DownFinalPaymentViewController") as? DownFinalPaymentViewController
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
    var stairsSpecialPriceId:Int = Int()
    var imagePicker: CaptureImage!
    var promotionCodeId:Int = Int()
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
        downPaymentTitleLabel.text = (self.paymentPlanValue?.plan_title ?? "") + " " + "(\(str ?? ""))"
        
        finalPaymentTF.delegate = self
        downPaymentTF.delegate = self
        
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
        return paymentMethords.count
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
    @IBAction func nextButtonAction(_ sender: Any) {
        
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
            
            if(financePayment > 1)
            {
                self.alert("Down and final payment amount lower than sales price. Please update the price and tap on Next button.", nil)
                return
            }
            
        }
        
        UIUpdateForValueChange(isUpdateDownPayment:true)
        summery.specialPriceId = specialPriceId
        summery.stairSpecialPriceId = stairsSpecialPriceId
        summery.promotionCodeId = promotionCodeId
        summery.downOrFinal = self.downOrFinal
        summery.totalAmount = self.totalAmount
        summery.paymentPlan = self.paymentPlan
        summery.paymentPlanValue = self.paymentPlanValue
        summery.paymentOptionDataValue = self.paymentOptionDataValue
        summery.drowingImageID = self.drowingImageID
        summery.savings = self.savings
        summery.area = self.area
        // summery.adminFeeStatus = self.isAdmiFee
        //summery.installationDate=self.installationDate.text ?? ""
        summery.downPaymentValue = self.downPayment
        summery.finalpayment = self.finalpayment
        summery.financePayment = self.financePayment
        summery.downpayment = downpayment
        
        // let adminFee = Double(self.adminFee)
        //   summery.adminFee = ((self.isAdmiFee) ? adminFee : 0) ?? 0
        
        summery.adminFee = Double(self.adminFee)
        summery.selectedPaymentMethord = (self.selectedPaymentMethord != -1) ? self.paymentMethords[self.selectedPaymentMethord] : nil
        summery.adjustmentValue = self.adjustmentValue
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "DownFinalPayment"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        self.navigationController?.pushViewController(summery, animated: true)
    }
    func validation() -> String
    {
        let finalvalue = Double(finalPaymentTF.text ?? "0")
        let downvalue = Double(downPaymentTF.text ?? "0")
        // {
        finalpayment = finalvalue ?? 0
        downPayment = downvalue ?? 0
        
        if (finalpayment>0 && self.selectedPaymentMethord == -1)
        {
            self.UIUpdateForValueChange(isUpdateDownPayment: true)
            return "Please select final payment method"
            
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
class PaymentMethorInDownPaymentCollectionViewCell:UICollectionViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectImageView: UIImageView!
    
}

extension DownFinalPaymentViewController: ImagePickerDelegate {

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
