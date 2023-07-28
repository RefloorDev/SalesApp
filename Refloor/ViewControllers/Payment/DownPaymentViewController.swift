//
//  DownPaymentViewController.swift
//  Refloor
//
//  Created by sbek on 19/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import JWTCodable
import CryptoKit
import CommonCrypto
import PayCardsRecognizer
var packageName = ""
class DownPaymentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ExternalCollectionViewDelegateForTableView,PayCardsRecognizerDelegate, UITextFieldDelegate {
    
    
    
    static func initialization() -> DownPaymentViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "DownPaymentViewController") as? DownPaymentViewController
    }
    @IBOutlet weak var financeAmountLabel: UILabel!
    @IBOutlet weak var finalPaymentLabel: UILabel!
    @IBOutlet weak var downPaymentLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var totalAreaLabel: UILabel!
    @IBOutlet weak var packegeLabel: UILabel!
    
    @IBOutlet weak var taxHeadingLabel: UILabel!
    
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var cashView: UIView!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var creditcardButton: UIButton!
    @IBOutlet weak var creditcardView: UIView!
    @IBOutlet weak var creditcardLabel: UILabel!
    @IBOutlet weak var debitcardButton: UIButton!
    @IBOutlet weak var debitcardView: UIView!
    @IBOutlet weak var debitcardLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    var globalIsJobCompletion = true
    var globalPayBalanace = ""
    var orderID = 0
    var paymentType:PaymentType = .Cash
    var downOrFinal:Double = 0
    var totalAmount:Double = 0
    var paymentPlan:PaymentPlanValue?
    var downPaymentValue:Double = 0
    var finalpayment:Double = 0
    var financePayment:Double = 0
    var persentageValue:Float = 10
    var adminFee = ""
    var downpaymentSelectionObjcet:[DownPaymentSelectionObj] = []
    var persentage:[String] = ["10 %","20 %","30 %","40 %","50 %", "Other"]
    var selectedPersecntage = 0
    var viewForJobCompleation = false
    let datePicker = MonthYearPickerView()
    var downPaymentInputObject:DownPaymentInputObject? = nil
    var QuotationPaymentPlanValueDetails:QuotationPaymentDetails!
    var QuotationPaymentOptionDataValueDetail:[DownPaymentDataValue] = []
    var QuotationPaymentMethodlDataValue:[PaymentMethodDataValue] = []
    var customerName = ""
    var isCardVerifiedSuccessfully = false
    var imagePicker: CaptureImage!
    var roomData:RoomDataValue!
    //let header = JWTHeader(alg: .hs256)
    let header = JWTHeader(typ: "JWT", alg: .hs256)
    var payment_TrasnsactionDict:[String:String] = [:]
    let signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"//"password"//UserData.init().token ?? ""//
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //JWT<paymentOptionUser>(header)
        self.setNavigationBarbackAndlogo(with: "DOWN PAYMENT".uppercased())
        let payment1 = DownPaymentSelectionObj(paymentType: .Cash, lable: self.cashLabel, view: self.cashView, button: self.cashButton, tag: 10)
        downpaymentSelectionObjcet.append(payment1)
        let payment2 = DownPaymentSelectionObj(paymentType: .CreditCard, lable: self.creditcardLabel, view: self.creditcardView, button: self.creditcardButton, tag: 11)
        downpaymentSelectionObjcet.append(payment2)
        let payment3 = DownPaymentSelectionObj(paymentType: .DebitCard, lable: self.debitcardLabel, view: self.debitcardView, button: self.debitcardButton, tag: 12)
        downpaymentSelectionObjcet.append(payment3)
        let payment4 = DownPaymentSelectionObj(paymentType: .Check, lable: self.checkLabel, view: self.checkView, button: self.checkButton, tag: 13)
        downpaymentSelectionObjcet.append(payment4)
        paymentCollectionView.register(UINib(nibName: "JobCompleationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "JobCompleationCollectionViewCell")
        paymentCollectionView.register(UINib(nibName: "DownPaymentFromCashCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DownPaymentFromCashCollectionViewCell")
        paymentCollectionView.register(UINib(nibName: "DownPaymentFromCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DownPaymentFromCardCollectionViewCell")
        paymentCollectionView.register(UINib(nibName: "DownPaymentFromCheckCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DownPaymentFromCheckCollectionViewCell")
        self.sideTabSelectedWith(at: self.cashButton.tag)
        
        self.totalAreaLabel.text = "\(getTotalAdjustedAreaForAllRooms().toRoundeString) Sq.ft"
        self.packegeLabel.text = packageName //"\(self.QuotationPaymentPlanValueDetails.package ?? "")"
        self.financeAmountLabel.text = "$\(self.financePayment.toDoubleString)"
        self.finalPaymentLabel.text = "$\(self.finalpayment.toDoubleString)"
        self.downPaymentLabel.text = "$\(self.downPaymentValue.toDoubleString)"
        self.totalAmountLabel.text = "$\(self.totalAmount.toDoubleString)"
        
        self.headingLabel.text = "Collect the down payment amount: $\(self.downPaymentValue.toDoubleString)"
        
        if let customer = AppDelegate.appoinmentslData
        {
            let customerNameFirstName = customer.applicant_first_name ?? ""
            let customerNameMiddleName = customer.applicant_middle_name ?? ""
            let customerNameLastName = customer.applicant_last_name ?? ""
            customerName = customerNameFirstName + " " + customerNameMiddleName + " " + customerNameLastName
            //
            
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    @IBAction func sidetabButtonActions(_ sender: UIButton) {
        viewForJobCompleation = false
        self.headingLabel.text = "Collect the down payment amount: $\(self.downPaymentValue.toDoubleString)"
        persentageValue = 10
        downPaymentInputObject = nil
        self.sideTabSelectedWith(at: sender.tag)
    }
    
    
    
    func sideTabSelectedWith(at tag:Int)
    {
        UIView.animate(withDuration: 0.2) {
            for obj in self.downpaymentSelectionObjcet
            {
                if(obj.tag == tag)
                {
                    self.paymentType = obj.paymentType
                    obj.view.backgroundColor =  UIColor(displayP3Red: 174/255, green: 179/255, blue: 184/255, alpha: 0.66)
                    obj.lable.textColor = .white
                }
                else
                
                {
                    obj.view.backgroundColor =  .clear
                    obj.lable.textColor = UIColor(displayP3Red: 167/255, green: 176/255, blue: 186/255, alpha: 1)
                    
                }
                self.paymentCollectionView.reloadData()
            }
            self.view.layoutIfNeeded()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 700)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(viewForJobCompleation)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JobCompleationCollectionViewCell", for: indexPath) as! JobCompleationCollectionViewCell
            cell.reload()
            cell.payButton.setTitle("Collect", for: .normal)
            cell.payButton.addTarget(self, action: #selector(goNextPageForPAyButtonAction), for: .touchUpInside)
            return cell
        }
        
        if(paymentType == .Cash)
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownPaymentFromCashCollectionViewCell", for: indexPath) as! DownPaymentFromCashCollectionViewCell
            //  cell.totalLabel.text = "Total Price: $\(self.totalAmount.toDoubleString)"
            //cell.totalLabel.text =  "Down Payment: $\(self.downPaymentValue.toDoubleString)"
            cell.selectedItem = self.selectedPersecntage
            cell.collectionViewConfigruation(collectionViewData: self.persentage, delegate: self)
            cell.payButton.setTitle("Collect", for: .normal)
            
            
            self.downPaymentLabel.text =  "$\(self.downPaymentValue.toDoubleString)"
            
            
            
            
            
            cell.payButton.addTarget(self, action: #selector(GoForJobCompleationValidation), for: .touchUpInside)
            return cell
        }
        else if(paymentType == .DebitCard || paymentType == .CreditCard)
        {
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownPaymentFromCardCollectionViewCell", for: indexPath) as! DownPaymentFromCardCollectionViewCell
            if paymentType == .DebitCard
            {
                cell.totalLabel.text = "Add Debit Card Details"
            }
            else
            {
                cell.totalLabel.text = "Add Credit Card Details"
            }
            //cell.totalLabel.text =  "Down Payment: $\(self.downPaymentValue.toDoubleString)"
            cell.selectedItem = self.selectedPersecntage
            cell.collectionViewConfigruation(collectionViewData: self.persentage, delegate: self)
            cell.payButton.addTarget(self, action: #selector(GoForJobCompleationValidation), for: .touchUpInside)
            cell.cardScanButton.addTarget(self, action:  #selector(cardScanner), for: .touchUpInside)
            cell.accountHolderNameTF.setPlaceHolderWithColor(placeholder: "Name", colour: .placeHolderColor)
            cell.cardNumberTF.setPlaceHolderWithColor(placeholder: "0000 0000 0000 0000", colour: .placeHolderColor)
            cell.cardNumberTF.keyboardType = .numberPad
            //cell.cardNumberTF.delegate = self
            cell.cardPinTF.keyboardType = .numberPad
            //cell.cardPinTF.delegate = self
            cell.cardExperyDateTF.setPlaceHolderWithColor(placeholder: "01/30", colour: .placeHolderColor)
            //cell.cardExperyDateTF.delegate = self
            cell.cardPinTF.isSecureTextEntry = true
            
            cell.cardPinTF.setPlaceHolderWithColor(placeholder: "0000", colour: .placeHolderColor)
            
            
            if(paymentType == .CreditCard)
            {
                cell.cardPinTF.setPlaceHolderWithColor(placeholder: "000", colour: .placeHolderColor)
            }
            cell.cardExperyDateTF.addTarget(self, action: #selector(datepickerSalection(_:)), for: .editingDidBegin)
           
            if(paymentType == .DebitCard)
            {
                cell.cardScanButton.setTitle("DEBIT CARD SCAN", for: .normal)
                cell.cardNumberLabel.text = "Debit Card Number"
                cell.cardPinLabel.text = "PIN"
            }
            else
            {
                cell.cardScanButton.setTitle("CREDIT CARD SCAN", for: .normal)
                cell.cardNumberLabel.text = "Credit Card Number"
                cell.cardPinLabel.text = "CVV"
            }
            cell.accountHolderNameTF.text = customerName
            cell.payButton.setTitle("Collect", for: .normal)
            
            return cell
        }
        else
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DownPaymentFromCheckCollectionViewCell", for: indexPath) as! DownPaymentFromCheckCollectionViewCell
            // cell.totalLabel.text = "Total Price: $\(self.totalAmount.toDoubleString)"
            cell.totalLabel.text = "Add Check Details"
            //cell.totalLabel.text = "Down Payment: $\(self.downPaymentValue.toDoubleString)"
            cell.selectedItem = self.selectedPersecntage
            cell.checkNumberTF.setPlaceHolderWithColor(placeholder: "0000 0000 0000 0000", colour: .placeHolderColor)
            cell.checkNumberTF.delegate = self
            cell.collectionViewConfigruation(collectionViewData: self.persentage, delegate: self)
            cell.accountNumberTF.setPlaceHolderWithColor(placeholder: "0000 0000 0000 0000", colour: .placeHolderColor)
            cell.accountNumberTF.delegate = self
            cell.routingNumberTF.setPlaceHolderWithColor(placeholder: "0000 0000 0000 0000", colour: .placeHolderColor)
            cell.routingNumberTF.delegate = self
            cell.collectionViewConfigruation(collectionViewData: self.persentage, delegate: self)
            cell.collectionViewConfigruation(collectionViewData: self.persentage, delegate: self)
            cell.payButton.addTarget(self, action: #selector(GoForJobCompleationValidation), for: .touchUpInside)
            cell.payButton.setTitle("Collect", for: .normal)
            
            
            
            
            
            return cell
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.textInputMode?.primaryLanguage == "emoji") {
            return false
        }
        //let specialCharString = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢")
        if string.rangeOfCharacter(from: Validation.specialCharString) != nil {
            return false
        }
        
        return true
    }
    
    @objc func cardScanner()
    {
        let rec = RecognizerViewController.initialization()!
        rec.delegate = self
        self.navigationController?.pushViewController(rec, animated: true)
    }
    @objc func GoForJobCompleationValidation()
    {
        if paymentType == .Cash
        {
            GoForJobCompleation()
        }
        else if paymentType == .DebitCard || paymentType == .CreditCard
        {
            validateForCard()
        }
        else
        {
            validateForCheck()
        }
    }
    func GoForJobCompleation()
    {
        let offlinemsg = "Are you sure you want to continue with this downpayment?"
        let onlinemsg = "Are you sure you want to continue with this downpayment? Once you proceed, you can’t navigate back and change the payment option again."
        
        if paymentType == .Cash
        {
            self.goNextPageForPAyButtonAction()
        }
        else if paymentType == .DebitCard || paymentType == .CreditCard
        {
            let yes = UIAlertAction(title: "Continue", style:.default) { (_) in
                
                self.goNextPageForPAyButtonAction()
            }
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            if HttpClientManager.SharedHM.connectedToNetwork()
            {
                self.alert(onlinemsg, [yes,no])
            }
            else
            {
                self.alert(offlinemsg, [yes,no])
            }
        }
        else
        {
            self.goNextPageForPAyButtonAction()
        }
        
        
        
        
        
        // goNextPageForPAyButtonAction()
        //        self.headingLabel.text = "How do you want to pay the balance amount?"
        //        self.viewForJobCompleation = true
        //        self.paymentCollectionView.reloadData()
    }
    
    
    func validateForCheck()
    {
        var checkNumber = ""
        var accountNumber = ""
        var routineNumber = ""
        if let cell = paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCheckCollectionViewCell
        {
            if (cell.checkNumberTF.text ?? "") != ""
            {
                if Int((cell.checkNumberTF.text ?? "")) == nil
                {
                    self.alert("please enter correct check number", nil)
                    return
                }
                checkNumber = (cell.checkNumberTF.text ?? "")
                if (cell.accountNumberTF.text ?? "") != ""
                {
                    if Int((cell.accountNumberTF.text ?? "")) == nil
                    {
                        self.alert("Please enter correct account number", nil)
                        return
                    }
                    
                    accountNumber = (cell.accountNumberTF.text ?? "")
                    if (cell.routingNumberTF.text ?? "") != ""
                    {
                        if Int((cell.routingNumberTF.text ?? "")) == nil
                        {
                            self.alert("Please enter correct routing number", nil)
                            return
                        }
                        routineNumber = (cell.routingNumberTF.text ?? "")
                        downPaymentInputObject = DownPaymentInputObject(paymentType: .Check, cardPaymentValue: nil, checkValue: CheckValue(checkNumber: checkNumber, accountNumber: accountNumber, routingNumber: routineNumber))
                        GoForJobCompleation()
                        
                    }
                    else
                    {
                        self.alert("Please enter routine number", nil)
                    }
                }
                else
                {
                    self.alert("Please enter account number", nil)
                }
                
                
            }
            else
            {
                self.alert("Please enter check number", nil)
            }
            
        }
        else
        {
            self.alert("Something went wrong", nil)
        }
    }
    func validateForCard()
    {
        var name = ""
        var cardNumber = ""
        var experyDate = ""
        var pin = ""
        if let cell = paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCardCollectionViewCell
        {
            var month=Int()
            var year=Int()
            let monthInt = Calendar.current.component(.month, from: Date()-1)
            let currentyear = Calendar.current.component(.year, from: Date())
            if cell.cardExperyDateTF.text==""{
                month=self.datePicker.month
                year=self.datePicker.year
            }else{
                let string = cell.cardExperyDateTF.text
                let ch = Character("/")
                let result = string?.components(separatedBy: "/")
                month=(result?[0] as? NSString)?.integerValue ?? 0
                year=(result?[1] as? NSString)?.integerValue ?? 0
                //                month=result?.startIndex ?? 0
                //                year=result?.firstIndex(of: result)
                //                print("month",month)
            }
            if (cell.accountHolderNameTF.text ?? "") != ""
            {
                name = (cell.accountHolderNameTF.text ?? "")
                if (cell.cardNumberTF.text ?? "") != ""
                {
                    if Int((cell.cardNumberTF.text ?? "")) == nil
                    {
                        //  self.alert("Please enter a valid card number", nil)
                        // return
                    }
                    cardNumber = (cell.cardNumberTF.text ?? "")
                    //                    let result = (cardNumber.filter { !$0.isWhitespace }).count
                    //                    if(result < 16){
                    //
                    //                        self.alert("Please enter valid card number", nil)
                    //                        return
                    //                    }
                    if CreditCardValidator(cardNumber).isValid {
                        
                        // Card number is valid
                    }
                    else
                    {
                        
                        self.alert("Please enter valid card number", nil)
                        return
                    }
                    if let type = CreditCardValidator(cardNumber).type {
                        print(type) // Visa, Mastercard, Amex etc.
                    } else {
                        // I Can't detect type of credit card
                    }
                    
                    // if(cardNumber.)
                    if (cell.cardExperyDateTF.text ?? "") != ""
                    {
                        if month<monthInt && currentyear%100==year{
                            self.alert("The card entered is expired", .none)
                        }
                        else
                        {
                            experyDate = (cell.cardExperyDateTF.text ?? "")
                            if (cell.cardPinTF.text ?? "") != ""
                            {
                                if Int((cell.cardPinTF.text ?? "")) == nil
                                {
                                    self.alert("Please enter correct cvv/pin number", nil)
                                    return
                                }
                                
                                pin = (cell.cardPinTF.text ?? "")
                                downPaymentInputObject = DownPaymentInputObject(paymentType: paymentType, cardPaymentValue: CardPaymentValue(accountName: name, cardNumber: cardNumber, experyDate: experyDate, pinNumber: pin), checkValue: nil)
                                self.GoForJobCompleation()
                                
                            }
                            else
                            {
                                self.alert("Please enter cvv/pin number", nil)
                            }
                        }
                        
                    }
                    else
                    {
                        self.alert("Please enter expiry date", nil)
                    }
                }
                else
                {
                    self.alert("Please enter card number", nil)
                }
            }
            else
            {
                self.alert("Please enter account holder name", nil)
            }
            
        }
        else
        {
            self.alert("Something went wrong", nil)
        }
    }
    
    
    
    
    func externalCollectionViewDidSelectbutton(index: Int, tag: Int)
    {
        //    if let cell = self.paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCashCollectionViewCell
        //    {
        //    if(persentage.count > index)
        //    {
        //    var value = persentage[index]
        //    value = value.replacingOccurrences(of: "%", with: "")
        //    value = value.replacingOccurrences(of: " ", with: "")
        //
        //        if let prsntage = Float(value)
        //        {
        //            self.persentageValue = prsntage
        //
        //            cell.payButton.setTitle("Collect", for: .normal)
        //        }
        //        else
        //        {
        //            let alert = UIAlertController(title: AppDetails.APP_NAME, message: "Please enter a valid percentage of down payment", preferredStyle: .alert)
        //
        //
        //            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        //                        self.persentageValue = 10
        //                         cell.selectedItem = 0
        //
        //
        //                         cell.downPaymentLabel.text = "Down Payment: $\(downpayment.downPayment.toRoundCommaString)"
        //                         cell.payButton.setTitle("Collect", for: .normal)
        //                        cell.persentage[cell.persentage.count - 1] = "Other"
        //                        cell.collectionView.reloadData()
        //
        //
        //            }
        //
        //
        //            let ok = UIAlertAction(title: "OK", style: .default) { (_) in
        //                if let textField = alert.textFields?[0]
        //                {
        //
        //                    if let value = Float(textField.text ?? "0")
        //                    {
        //                        if value<100 && value>0
        //                        {
        //                        self.persentageValue = value
        //                        let downpayment = self.DownPaymentcalucaltion()
        //                        self.dwnPaymenHeadingLabel.text = "Down Payment:"
        //                        self.downPaymentLabel.text = "$\(downpayment.downPayment.toRoundCommaString)"
        //                        self.balanceLabel.text = "$\(downpayment.balance.toRoundCommaString)"
        //                         cell.downPaymentLabel.text = "Down Payment: $\(downpayment.downPayment.toRoundCommaString)"
        //                         cell.payButton.setTitle("Collect", for: .normal)
        //                        cell.persentage[cell.persentage.count - 1] = "Other(\(value)%)"
        //                        cell.collectionView.reloadData()
        //                        }
        //                        else
        //                        {
        //
        //                             self.present(alert, animated: true, completion: nil)
        //                        }
        //                    }
        //                    else
        //                    {
        //                        self.present(alert, animated: true, completion: nil)
        //                    }
        //                }
        //            }
        //
        //            alert.addTextField { (textFiled) in
        //                textFiled.keyboardType = .decimalPad
        //                textFiled.placeholder = "1 to 99"
        //            }
        //            alert.addAction(ok)
        //            alert.addAction(cancel)
        //            self.present(alert, animated: true, completion: nil)
        //        }
        //
        //    }
        //    }
        //    else if let cell = self.paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCardCollectionViewCell
        //    {
        //    if(persentage.count > index)
        //    {
        //    var value = persentage[index]
        //    value = value.replacingOccurrences(of: "%", with: "")
        //    value = value.replacingOccurrences(of: " ", with: "")
        //
        //        if let prsntage = Float(value)
        //        {
        //            self.persentageValue = prsntage
        //            let downpayment = self.DownPaymentcalucaltion()
        //             self.dwnPaymenHeadingLabel.text = "Down Payment:"
        //              self.downPaymentLabel.text = "$\(downpayment.downPayment.toRoundCommaString)"
        //            self.balanceLabel.text = "$\(downpayment.balance.toRoundCommaString)"
        //             cell.payButton.setTitle("Collect", for: .normal)
        //
        //        }
        //        else
        //        {
        //            let alert = UIAlertController(title: AppDetails.APP_NAME, message: "Please enter a valid percentage of down payment", preferredStyle: .alert)
        //            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        //                                  self.persentageValue = 10
        //                                   cell.selectedItem = 0
        //                          let downpayment = self.DownPaymentcalucaltion()
        //                          self.dwnPaymenHeadingLabel.text = "Down Payment:"
        //                           self.downPaymentLabel.text = "$\(downpayment.downPayment.toRoundCommaString)"
        //                          self.balanceLabel.text = "$\(downpayment.balance.toRoundCommaString)"
        //                          cell.payButton.setTitle("Collect", for: .normal)
        //                          cell.persentage[cell.persentage.count - 1] = "Other"
        //                          cell.payButton.setTitle("Collect", for: .normal)
        //                          cell.collectionView.reloadData()
        //
        //
        //                      }
        //
        //
        //
        //            let ok = UIAlertAction(title: "OK", style: .default) { (_) in
        //                if let textField = alert.textFields?[0]
        //                {
        //                    if let value = Float(textField.text ?? "0")
        //                    {
        //                         if value<100 && value>0
        //                        {
        //                        self.persentageValue = value
        //                        let downpayment = self.DownPaymentcalucaltion()
        //                        self.dwnPaymenHeadingLabel.text = "Down Payment:"
        //                         self.downPaymentLabel.text = "$\(downpayment.downPayment.toRoundCommaString)"
        //                        self.balanceLabel.text = "$\(downpayment.balance.toRoundCommaString)"
        //                        cell.payButton.setTitle("Collect", for: .normal)
        //                        cell.persentage[cell.persentage.count - 1] = "Other(\(value)%)"
        //                        cell.payButton.setTitle("Collect", for: .normal)
        //                            cell.collectionView.reloadData()}
        //                        else
        //                        {
        //
        //                             self.present(alert, animated: true, completion: nil)
        //                        }
        //                    }
        //                    else
        //                    {
        //                        self.present(alert, animated: true, completion: nil)
        //                    }
        //                }
        //            }
        //
        //            alert.addTextField { (textFiled) in
        //                textFiled.keyboardType = .decimalPad
        //                textFiled.placeholder = "1 to 99"
        //            }
        //            alert.addAction(ok)
        //            alert.addAction(cancel)
        //            self.present(alert, animated: true, completion: nil)
        //        }
        //
        //    }
        //    }
        //    else if let cell = self.paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCheckCollectionViewCell
        //            {
        //            if(persentage.count > index)
        //            {
        //            var value = persentage[index]
        //            value = value.replacingOccurrences(of: "%", with: "")
        //            value = value.replacingOccurrences(of: " ", with: "")
        //
        //                if let prsntage = Float(value)
        //                {
        //                    self.persentageValue = prsntage
        //                    let downpayment = self.DownPaymentcalucaltion()
        //                    self.dwnPaymenHeadingLabel.text = "Down Payment:"
        //                     self.downPaymentLabel.text = "$\(downpayment.downPayment.toRoundCommaString)"
        //                    self.balanceLabel.text = "$\(downpayment.balance.toRoundCommaString)"
        //                    cell.payButton.setTitle("Collect", for: .normal)
        //                }
        //                else
        //                {
        //                    let alert = UIAlertController(title: AppDetails.APP_NAME, message: "Please enter a valid percentage of down payment", preferredStyle: .alert)
        //                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        //                                                    self.persentageValue = 10
        //                                                     cell.selectedItem = 0
        //                                            let downpayment = self.DownPaymentcalucaltion()
        //                    self.dwnPaymenHeadingLabel.text = "Down Payment:"
        //                  self.downPaymentLabel.text = "$\(downpayment.downPayment.toRoundCommaString)"
        //                    self.balanceLabel.text = "$\(downpayment.balance.toRoundCommaString)"
        //                      cell.payButton.setTitle("Collect", for: .normal)
        //                      cell.persentage[cell.persentage.count - 1] = "Other"
        //                           cell.collectionView.reloadData()
        //
        //
        //                                        }
        //
        //                    let ok = UIAlertAction(title: "OK", style: .default) { (_) in
        //                        if let textField = alert.textFields?[0]
        //                        {
        //                            if let value = Float(textField.text ?? "0")
        //                            {
        //                                 if value<100 && value>0
        //                                {
        //                                self.persentageValue = value
        //                                let downpayment = self.DownPaymentcalucaltion()
        //                                self.dwnPaymenHeadingLabel.text = "Down Payment:"
        //                                self.downPaymentLabel.text = "$\(downpayment.downPayment.toRoundCommaString)"
        //                                   self.balanceLabel.text = "$\(downpayment.balance.toRoundCommaString)"
        //                                 cell.payButton.setTitle("Collect", for: .normal)
        //                                cell.persentage[cell.persentage.count - 1] = "Other(\(value)%)"
        //                                cell.collectionView.reloadData()
        //                                    }
        //                                    else
        //                                    {
        //
        //                                         self.present(alert, animated: true, completion: nil)
        //                                    }
        //                            }
        //                            else
        //                            {
        //                                self.present(alert, animated: true, completion: nil)
        //                            }
        //                        }
        //                    }
        //
        //                    alert.addTextField { (textFiled) in
        //                        textFiled.keyboardType = .decimalPad
        //                        textFiled.placeholder = "1 to 99"
        //                    }
        //                    alert.addAction(ok)
        //                    alert.addAction(cancel)
        //                    self.present(alert, animated: true, completion: nil)
        //                }
        //
        //            }
        //            }
        //
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
    
    func createFinalParameterForCustomerApiCall() -> [String:Any]{
        var customerDict: [String:Any] = [:]
        customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        customerDict["data_completed"] = 0
        var customerData = createCustomerParameter()
        customerDict["customer"] = customerData
        customerDict["rooms"] = createRoomParameters()
        customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
        customerDict["operation_mode"] = "online"
        customerDict["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return customerDict
    }
    
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
        contractDict["application_info_secret"] = applicantInfoSecret//applicantDta["data"] //
        //contractDict["contractInfo"] = contactInfo
//        contractDict["data_completed"] = 0
//        contractDict["appointment_id"] = AppointmentData().appointment_id ?? 0
//        let contractDataDict: [String:Any] = ["data":contractDict]
//        print(contractDataDict)
        return contractDict //contractDataDict
    }
    

    
    @objc func goNextPageForPAyButtonAction()
    {
        if paymentType == .CreditCard || paymentType == .DebitCard
        {
            //let room_id = roomData.id
            //deleteRoomFromAppointment(appointmentId:AppointmentData().appointment_id ?? 0, roomId: self.roomData.id ?? 0)
            if HttpClientManager.SharedHM.connectedToNetwork()
            {
                self.getCardDetails()
                var parameter = self.createContractParameters()
                let appointmentId = AppointmentData().appointment_id ?? 0
                if let applicantDataDict = parameter as? [String:Any]
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
//                    if  let applicant = applicantDataDict["applicationInfo"] as? [String:Any]{
//                        self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicant)
                   // }
                }//createFinalParameterForCustomerApiCall()
                var parameterToPass:[String:Any] = [:]
                //var jwtToken:String = String()
                let contactApiData = createFinalParameterForCustomerApiCall()//self.createContractParameters()
                for (key,value) in contactApiData{
                    parameter[key] = value
                }
                print(parameter)
                
//                let json = (parameter as NSDictionary).JsonString()
//                let data = json.data(using: .utf8)
//
//                let decoder = JSONDecoder()
//
//                if let data = data, let model = try? decoder.decode(CustomerEncodingDecodingDetails.self, from: data) {
//                    print(model)
//                    let jwt = JWT<CustomerEncodingDecodingDetails>(header: header, payload: model, signature: signature)
//                    jwtToken = JWTEncoder.shared.encode(jwt: jwt) ?? ""
//                    print(jwtToken)

                let decodeOption:[String:Bool] = ["verify_signature":false]
                    
                    
                  parameterToPass = ["token": UserData.init().token ?? "" ,"decode_options":decodeOption,"data":parameter]
               // }
                // let paymentOptionUserDetails = paymentOptionUser(payment_Method: "cash", paymentDetails: userPaymentDetails)
             
     
                
                let dbParameter = parameter
                //
               
                //parameter["token"] = UserData.init().token ?? ""
                
                HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(parameter: parameterToPass, isOnlineCollectBtnPressed: true) { success, message,payment_status,payment_message,transactionId,cardType  in
                    if(success ?? "") == "Success" || (success == "Failed" && transactionId != "Invalid"){
                        print("success")
                        let appointment = self.getAppointmentData(appointmentId: AppointmentData().appointment_id ?? 0)
                        let firstName = appointment?.applicant_first_name ?? ""
                        let lastName = appointment?.applicant_last_name ?? ""
                        let name = lastName == ""  ? firstName : firstName + " " + lastName
                        let date = appointment?.appointment_datetime ?? ""
                        let appointmentId = AppointmentData().appointment_id ?? 0
                       // self.saveLogDetailsForAppointment(appointmentId: appoint, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                        self.deleteAnyAppointmentLogsTable(appointmentId: appointmentId)
                        self.createDBAppointmentRequest(requestTitle: RequestTitle.CustomerAndRoom, requestUrl: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParameter: dbParameter as NSDictionary, imageName: "")
                        //self.alert(message ?? "", nil)
                        if success == "Success"
                        {
                            self.isCardVerifiedSuccessfully = true
                        }
                        else
                        {
                            self.payment_TrasnsactionDict = ["authorize_transaction_id":transactionId ?? "","card_type":cardType ?? ""]
                            self.isCardVerifiedSuccessfully = false
                        }
                        let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                            
                            self.cardDetailsAPiSuccess()
                        }

                            
                            self.alert(payment_message ?? "", [yes])
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
                        //self.alert(message ?? "", nil)
                        let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                            
                            self.goNextPageForPAyButtonAction()
                            
                        }
                        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    }
                }
            }
            else
            {
                getCardDetails()
                cardDetailsAPiSuccess()
            }
        }
        //arb
        else
        {
            getCardDetails()
            cardDetailsAPiSuccess()
        }
        
                
    }
    
    @objc func cardDetailsAPiSuccess()
    {
        if self.paymentType == .Cash
        {
            let cancel = CancellationPolicyViewController.initialization()!
            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //web.balance  = self.DownPaymentcalucaltion().balance
            cancel.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
            cancel.total = self.totalAmount
            cancel.balance = self.totalAmount - self.downPaymentValue
            cancel.paymentType = "cash"
            cancel.isCardVerified = false
            cancel.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            self.navigationController?.pushViewController(cancel, animated: true)
        }
        else if self.paymentType == .Check
        {
            let cancel = CancellationPolicyViewController.initialization()!
            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //web.balance  = self.DownPaymentcalucaltion().balance
            cancel.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
            cancel.total = self.totalAmount
            cancel.balance = self.totalAmount - self.downPaymentValue
            cancel.paymentType = "check"
            cancel.isCardVerified = false
            cancel.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            self.navigationController?.pushViewController(cancel, animated: true)
            
        }
        else
        {
            let cancel = CancellationPolicyViewController.initialization()!
            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //web.balance  = self.DownPaymentcalucaltion().balance
            cancel.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
            cancel.total = self.totalAmount
            cancel.balance = self.totalAmount - self.downPaymentValue
            cancel.paymentType = "card"
            cancel.isCardVerified = self.isCardVerifiedSuccessfully
            cancel.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            self.navigationController?.pushViewController(cancel, animated: true)
        }
    }
    func getCardDetails()
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "CollectDownPayment"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        let balancePay = ""
        if paymentType == .Cash
        {
            var expirydate = downPaymentInputObject?.cardPaymentValue?.experyDate
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")

           let dict = ["card_number":downPaymentInputObject?.cardPaymentValue?.cardNumber ?? "","card_expiry":expirydate ?? "","card_holder_name":downPaymentInputObject?.cardPaymentValue?.accountName ?? "","cardpin":downPaymentInputObject?.cardPaymentValue?.pinNumber ?? "","check_number":downPaymentInputObject?.checkValue?.checkNumber ?? "","check_account_number":downPaymentInputObject?.checkValue?.accountNumber ?? "","check_routing_number":downPaymentInputObject?.checkValue?.routingNumber ?? ""]
            let paymentOption =  self.getPaymentOptionAndValues(payment_method: "cash", paymentOptionDict:dict)
            self.savePaymentMethodTypeToAppointmentDetail(paymentType: paymentOption.nsDictionary)
           
            
        }
        else if paymentType == .CreditCard
        {
            
            var expirydate = downPaymentInputObject?.cardPaymentValue?.experyDate
            //expirydate = expirydate?.expiryDateToString(date: expirydate ?? "")
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")
          
            let data:[String:Any] = ["card_number":downPaymentInputObject?.cardPaymentValue?.cardNumber ?? "","card_expiry":expirydate ?? "","card_holder_name":downPaymentInputObject?.cardPaymentValue?.accountName ?? "","cardpin":downPaymentInputObject?.cardPaymentValue?.pinNumber ?? "","check_number":downPaymentInputObject?.checkValue?.checkNumber ?? "","check_account_number":downPaymentInputObject?.checkValue?.accountNumber ?? "","check_routing_number":downPaymentInputObject?.checkValue?.routingNumber ?? ""]
            let paymentOption =  self.getPaymentOptionAndValues(payment_method: "credit_card", paymentOptionDict:data)

            print(paymentOption)
            self.savePaymentMethodTypeToAppointmentDetail(paymentType: paymentOption.nsDictionary)
//            let web = WebViewViewController.initialization()!
//            //web.downPayment = self.DownPaymentcalucaltion().downPayment
//            //web.balance  = self.DownPaymentcalucaltion().balance
//            web.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
//            web.total = self.totalAmount
//            web.balance = self.totalAmount - self.downPaymentValue
//            web.paymentType = "card"
//            self.navigationController?.pushViewController(web, animated: true)
        }
        else if paymentType == .DebitCard
        {
            //self.paymentTransactionDebitCardApi(isOnJobCompleation: true, balancePaymentMethord: balancePay)
            var expirydate = downPaymentInputObject?.cardPaymentValue?.experyDate
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")
         
            let data:[String:Any] = ["card_number":downPaymentInputObject?.cardPaymentValue?.cardNumber ?? "","card_expiry":expirydate ?? "","card_holder_name":downPaymentInputObject?.cardPaymentValue?.accountName ?? "","cardpin":downPaymentInputObject?.cardPaymentValue?.pinNumber ?? "","check_number":downPaymentInputObject?.checkValue?.checkNumber ?? "","check_account_number":downPaymentInputObject?.checkValue?.accountNumber ?? "","check_routing_number":downPaymentInputObject?.checkValue?.routingNumber ?? ""]
            let paymentOption =  self.getPaymentOptionAndValues(payment_method: "debit_card", paymentOptionDict:data)

            print(paymentOption)
            self.savePaymentMethodTypeToAppointmentDetail(paymentType: paymentOption.nsDictionary)
//            let web = WebViewViewController.initialization()!
//            //web.downPayment = self.DownPaymentcalucaltion().downPayment
//            //web.balance  = self.DownPaymentcalucaltion().balance
//            web.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
//            web.total = self.totalAmount
//            web.balance = self.totalAmount - self.downPaymentValue
//            web.paymentType = "card"
//            self.navigationController?.pushViewController(web, animated: true)
        }
        else if paymentType == .Check
        {
            //self.paymentTransactionCheckApi(isOnJobCompleation: true, balancePaymentMethord: balancePay)
            var expirydate = downPaymentInputObject?.cardPaymentValue?.experyDate
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")
            let data:[String:Any] = ["card_number":downPaymentInputObject?.cardPaymentValue?.cardNumber ?? "","card_expiry":expirydate ?? "","card_holder_name":downPaymentInputObject?.cardPaymentValue?.accountName ?? "","cardpin":downPaymentInputObject?.cardPaymentValue?.pinNumber ?? "","check_number":downPaymentInputObject?.checkValue?.checkNumber ?? "","check_account_number":downPaymentInputObject?.checkValue?.accountNumber ?? "","check_routing_number":downPaymentInputObject?.checkValue?.routingNumber ?? ""]
            let paymentOption =  self.getPaymentOptionAndValues(payment_method: "check", paymentOptionDict:data)

            print(paymentOption)
            self.savePaymentMethodTypeToAppointmentDetail(paymentType: paymentOption.nsDictionary)
            
            //test
            // let paymentMethodData = self.getPaymentMethodTypeFromAppointmentDetail()
            //print(paymentMethodData)
            //
        }
    }
    
    func DownPaymentcalucaltion() -> DownPaymentCalculationValue
    {
        
        let downValue = (Double(persentageValue)/100) * (QuotationPaymentPlanValueDetails.total_amount ?? 0)
        
        return DownPaymentCalculationValue(balance: (QuotationPaymentPlanValueDetails.total_amount ?? 0) - downValue, downPayment: downValue)
    }
    
    @objc func datepickerSalection(_ sender: UITextField) {
        
        datePicker.backgroundColor =  UIColor.init(red: 40/255, green: 59/255, blue: 79/255, alpha: 1)
        datePicker.tintColor = UIColor.white
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.barStyle = .blackTranslucent
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedateDatePicker));
        doneButton.tintColor = .white
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        cancelButton.tintColor = .white
        
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        sender.inputAccessoryView = toolbar
        sender.inputView?.backgroundColor = UIColor.init(red: 40/255, green: 59/255, blue: 79/255, alpha: 1)
        sender.inputView = datePicker
        let monthInt = Calendar.current.component(.month, from: Date())
        let currentyear = Calendar.current.component(.year, from: Date())
        if let cell = self.paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCardCollectionViewCell
        {
            self.datePicker.onDateSelected = { (month: Int, year: Int) in
                if month<monthInt && currentyear==year{
                    self.alert("The card entered is expired", .none)
                }
                else
                {
                    let string = String(format: "%02d/%d", month, year)
                    cell.cardExperyDateTF.text = string
                    
                    NSLog(string)
                }// should show something like 05/2015
            }
            
            
        }
        
    }
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    @objc func donedateDatePicker(){
        
        if let cell = self.paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCardCollectionViewCell
        {
            let month = self.datePicker.month
            let year = self.datePicker.year
            let monthInt = Calendar.current.component(.month, from: Date())
            let currentyear = Calendar.current.component(.year, from: Date())
            if month<monthInt && currentyear==year{
                self.alert("The card entered is expired", .none)
            }
            else
            {
                
                let string = String(format: "%02d/%d", month, year)
                cell.cardExperyDateTF.text = string
            }
            self.view.endEditing(true)
        }
    }
    
    
    func PayCardsRecognizerDidRecive(the result: PayCardsRecognizerResult) {
        if let cell = self.paymentCollectionView.cellForItem(at: [0,0]) as? DownPaymentFromCardCollectionViewCell
        {
            cell.accountHolderNameTF.text = result.recognizedHolderName ?? ""
            cell.cardNumberTF.text = result.recognizedNumber ?? ""
            if let year = result.recognizedExpireDateYear
            {
                if let month = result.recognizedExpireDateMonth
                {
                    cell.cardExperyDateTF.text = month + "/" + year
                }
            }
        }
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
    
    
    ///Payment API
    
    
    func paymentTransactionCashApi(isOnJobCompleation:Bool,balancePaymentMethord:String)
    {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation
        let data:[String:Any] = ["order_id":orderID ,"token":UserData.init().token ?? ""]
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        
        HttpClientManager.SharedHM.PaymentRequestAPi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                
                let web = WebViewViewController.initialization()! 
                web.document=value ?? ""
                web.orderID=self.orderID
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "cash"
                self.navigationController?.pushViewController(web, animated: true)
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
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.paymentTransactionCashApi(isOnJobCompleation: self.globalIsJobCompletion, balancePaymentMethord: self.globalPayBalanace)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func paymentTransactionCreditCardApi(isOnJobCompleation:Bool,balancePaymentMethord:String)
    {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation
        
        let data:[String:Any] = ["order_id":orderID , "token":UserData.init().token ?? "","payment_method":"credit_card"
                                 ,"card_number":downPaymentInputObject?.cardPaymentValue?.cardNumber ?? "","card_expiry":downPaymentInputObject?.cardPaymentValue?.experyDate ?? "","card_holder_name":downPaymentInputObject?.cardPaymentValue?.accountName ?? "","cardpin":downPaymentInputObject?.cardPaymentValue?.pinNumber ?? ""]
        
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        
        HttpClientManager.SharedHM.PaymentRequestCardAPi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                let web = WebViewViewController.initialization()!
                web.document=value ?? ""
                web.orderID=self.orderID;
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "card"
                self.navigationController?.pushViewController(web, animated: true)
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
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.paymentTransactionCashApi(isOnJobCompleation: self.globalIsJobCompletion, balancePaymentMethord: self.globalPayBalanace)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func paymentTransactionDebitCardApi(isOnJobCompleation:Bool,balancePaymentMethord:String)
    {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation
        
        let data:[String:Any] = ["order_id":orderID , "token":UserData.init().token ?? "","payment_method":"credit_card"
                                 ,"card_number":downPaymentInputObject?.cardPaymentValue?.cardNumber ?? "","card_expiry":downPaymentInputObject?.cardPaymentValue?.experyDate ?? "","card_holder_name":downPaymentInputObject?.cardPaymentValue?.accountName ?? "","cardpin":downPaymentInputObject?.cardPaymentValue?.pinNumber ?? ""]
        
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        
        HttpClientManager.SharedHM.PaymentRequestCardAPi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                let web = WebViewViewController.initialization()!
                web.document=value ?? ""
                web.orderID=self.orderID;
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "card"
                self.navigationController?.pushViewController(web, animated: true)
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
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.paymentTransactionCashApi(isOnJobCompleation: self.globalIsJobCompletion, balancePaymentMethord: self.globalPayBalanace)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    
    func paymentTransactionCheckApi(isOnJobCompleation:Bool,balancePaymentMethord:String)
    {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation
        
        let data:[String:Any] = ["order_id":orderID , "token":UserData.init().token ?? "","payment_method":"check"
                                 ,"check_number":downPaymentInputObject?.checkValue?.checkNumber ?? "","check_account_number":downPaymentInputObject?.checkValue?.accountNumber ?? "","check_routing_number":downPaymentInputObject?.checkValue?.routingNumber ?? ""]
        
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        
        HttpClientManager.SharedHM.PaymentRequestCheckAPi(parameter: parameter){ (success, message, value) in
            if(success ?? "") == "Success"
            {
                let web = WebViewViewController.initialization()!
                web.document=value ?? ""
                web.orderID = self.orderID;
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "check"
                self.navigationController?.pushViewController(web, animated: true)
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
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.paymentTransactionCashApi(isOnJobCompleation: self.globalIsJobCompletion, balancePaymentMethord: self.globalPayBalanace)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    
    
    
}

class DownPaymentCalculationValue
{
    var balance:Double
    var downPayment:Double
    init(balance:Double,downPayment:Double)
    {
        self.balance = balance
        
        self.downPayment = downPayment
    }
}
class DownPaymentInputObject:NSObject
{
    var paymentType:PaymentType
    var cardPaymentValue:CardPaymentValue?
    var checkValue:CheckValue?
    init(paymentType:PaymentType,cardPaymentValue:CardPaymentValue?,checkValue:CheckValue?)
    {
        self.paymentType = paymentType
        self.cardPaymentValue = cardPaymentValue
        self.checkValue = checkValue
    }
    
}
class CardPaymentValue:NSObject
{
    var accountName:String
    var cardNumber:String
    var experyDate:String
    var pinNumber:String
    init(accountName:String,cardNumber:String,experyDate:String,pinNumber:String)
    {
        self.accountName = accountName
        self.cardNumber = cardNumber
        self.experyDate = experyDate
        self.pinNumber = pinNumber
    }
}
class CheckValue:NSObject
{
    var checkNumber:String
    var accountNumber:String
    var routingNumber:String
    init(checkNumber:String,accountNumber:String,routingNumber:String)
    {
        self.checkNumber = checkNumber
        self.accountNumber = accountNumber
        self.routingNumber = routingNumber
    }
}

class DownPaymentSelectionObj:NSObject
{
    var paymentType:PaymentType
    var lable:UILabel
    var view:UIView
    var button:UIButton
    var tag:Int
    init(paymentType:PaymentType,lable:UILabel,view:UIView,button:UIButton,tag:Int)
    {
        self.paymentType = paymentType
        self.lable = lable
        self.view = view
        self.button = button
        self.button.tag = tag
        self.tag = tag
    }
}
extension DownPaymentViewController: ImagePickerDelegate {

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
enum PaymentType {
    case Cash
    case Check
    case DebitCard
    case CreditCard
}
struct PaymentDetails: Codable
{
    var card_Number:String?
    var card_Expiry:String?
    var card_Holder_Name:String?
    var card_Pin:String?
    var chek_Number:String?
    var check_Account_Number:String?
    var check_Routing_Number:String?
    
}
struct Payload: Codable {
    var sub: String?
    var name: String?
    var iat: Int?
}
struct paymentOptionUser:Codable
{
    var payment_Method:String?
    var paymentDetails:PaymentDetails?
    
//    private enum CodingKeys: String, CodingKey {
//            case payment_Method
//            case paymentDetails
//        }
//
//    init(payment_Method: String?, paymentDetails: [String:Any]) {
//            self.payment_Method = payment_Method
//            self.paymentDetails = paymentDetails
//        }
//    required init(from decoder:Decoder) throws {
//           let values = try decoder.container(keyedBy: CodingKeys.self)
//           payment_Method = try values.decode(String.self, forKey: .payment_Method)
//        paymentDetails = try values.decode([String:Any].self, forKey: .paymentDetails)
//       }
}
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}


extension String {
    
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        let data = Data.init(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

class DictionaryDecoder {
    
    private let decoder = JSONDecoder()
    
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        set { decoder.dateDecodingStrategy = newValue }
        get { return decoder.dateDecodingStrategy }
    }
    
    var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy {
        set { decoder.dataDecodingStrategy = newValue }
        get { return decoder.dataDecodingStrategy }
    }
    
    var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy {
        set { decoder.nonConformingFloatDecodingStrategy = newValue }
        get { return decoder.nonConformingFloatDecodingStrategy }
    }
    
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        set { decoder.keyDecodingStrategy = newValue }
        get { return decoder.keyDecodingStrategy }
    }
    
    func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try decoder.decode(type, from: data)
    }
}


