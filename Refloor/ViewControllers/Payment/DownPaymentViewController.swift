//
//  DownPaymentViewController.swift
//  Refloor
//
//  Created by sbek on 19/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

//import WeScan
import AVFoundation
import CommonCrypto
import CryptoKit
import JWTCodable
import SwiftUI
import UIKit
//import PayCardsRecognizer
import Vision
import VisionKit

var packageName = ""
@MainActor

/*
class DownPaymentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ExternalCollectionViewDelegateForTableView,PayCardsRecognizerDelegate, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,VNDocumentCameraViewControllerDelegate,ImageScannerControllerDelegate{

    */

class DownPaymentViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    ExternalCollectionViewDelegateForTableView,
    UITextFieldDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, VNDocumentCameraViewControllerDelegate
{

    /*
    func imageScannerControllerDidCancel(
        _ scanner: WeScan.ImageScannerController
    ) {
        scanner.dismiss(animated: true)
    }
    */

    /*
    func imageScannerController(
        _ scanner: WeScan.ImageScannerController,
        didFailWithError error: any Error
    ) {
        print(error)
    }
    */

    static func initialization() -> DownPaymentViewController? {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(
                withIdentifier: "DownPaymentViewController"
            ) as? DownPaymentViewController
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
    @IBOutlet weak var checkTabButton: UIButton!
    @IBOutlet weak var checkTabView: UIView!
    @IBOutlet weak var checkTabLabel: UILabel!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    var globalIsJobCompletion = true
    var globalPayBalanace = ""
    var orderID = 0
    var paymentType: PaymentType = .Cash
    var downOrFinal: Double = 0
    var totalAmount: Double = 0
    var paymentPlan: PaymentPlanValue?
    var downPaymentValue: Double = 0
    var finalpayment: Double = 0
    var financePayment: Double = 0
    var persentageValue: Float = 10
    var adminFee = ""
    var downpaymentSelectionObjcet: [DownPaymentSelectionObj] = []
    var persentage: [String] = [
        "10 %", "20 %", "30 %", "40 %", "50 %", "Other",
    ]
    var selectedPersecntage = 0
    var viewForJobCompleation = false
    let datePicker = MonthYearPickerView()
    var downPaymentInputObject: DownPaymentInputObject? = nil
    var QuotationPaymentPlanValueDetails: QuotationPaymentDetails!
    var QuotationPaymentOptionDataValueDetail: [DownPaymentDataValue] = []
    var QuotationPaymentMethodlDataValue: [PaymentMethodDataValue] = []
    var customerName = ""
    var isCardVerifiedSuccessfully = false
    // ACH / Check account type: "ECHK" = Checking, "ESAV" = Savings
    var selectedAcctType: String = ""
    var selectedAcctTypeLabel: String = "Select"
    var imagePicker: CaptureImage!
    var roomData: RoomDataValue!
    var area = 0.0
    var cameraImagePicker = UIImagePickerController()
    var popOver: UIPopoverController?
    var ocrCameraImage: UIImage?
    //let header = JWTHeader(alg: .hs256)
    let header = JWTHeader(typ: "JWT", alg: .hs256)
    var payment_TrasnsactionDict: [String: String] = [:]
    var isPayltr = false
    var isOCR = false
    var routingNumber: String = String()
    var accountNumber: String = String()
    var checkNumber: String = String()
    var accountHolderName: String = String()
    var cardNumber: String = String()
    var cardExpiry: String = String()
    var cardPin: String = String()
    let signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"  //"password"//UserData.init().token ?? ""//

    override func viewDidLoad() {
        super.viewDidLoad()

        print(
            "finalpayment : ",
            finalpayment,
            " financePayment : ",
            financePayment,
            " downPaymentValue : ",
            downPaymentValue,
            " totalAmount : ",
            totalAmount
        )
        //JWT<paymentOptionUser>(header)
        self.setNavigationBarbackAndlogo(with: "DOWN PAYMENT".uppercased())
        let payment1 = DownPaymentSelectionObj(
            paymentType: .Cash,
            lable: self.cashLabel,
            view: self.cashView,
            button: self.cashButton,
            tag: 10
        )
        downpaymentSelectionObjcet.append(payment1)
        let payment2 = DownPaymentSelectionObj(
            paymentType: .CreditCard,
            lable: self.creditcardLabel,
            view: self.creditcardView,
            button: self.creditcardButton,
            tag: 11
        )
        downpaymentSelectionObjcet.append(payment2)
        let payment3 = DownPaymentSelectionObj(
            paymentType: .DebitCard,
            lable: self.debitcardLabel,
            view: self.debitcardView,
            button: self.debitcardButton,
            tag: 12
        )
        downpaymentSelectionObjcet.append(payment3)
        // Tab 4 – ACH (always)
        self.checkLabel.text = "E-Check/ACH"
        let payment4 = DownPaymentSelectionObj(
            paymentType: .ACH,
            lable: self.checkLabel,
            view: self.checkView,
            button: self.checkButton,
            tag: 13
        )
        downpaymentSelectionObjcet.append(payment4)
        // Tab 5 – Check (always)
        let payment5 = DownPaymentSelectionObj(
            paymentType: .Check,
            lable: self.checkTabLabel,
            view: self.checkTabView,
            button: self.checkTabButton,
            tag: 14
        )
        downpaymentSelectionObjcet.append(payment5)
        paymentCollectionView.register(
            UINib(nibName: "JobCompleationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "JobCompleationCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(
                nibName: "DownPaymentFromCashCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "DownPaymentFromCashCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(
                nibName: "DownPaymentFromCardCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "DownPaymentFromCardCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(
                nibName: "DownPaymentFromCheckCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "DownPaymentFromCheckCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(nibName: "DownPaymentFromACHCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "DownPaymentFromACHCollectionViewCell"
        )
        self.sideTabSelectedWith(at: self.cashButton.tag)
        cameraImagePicker.delegate = self
        self.totalAreaLabel.text = "\(area) Sq.ft"
        self.packegeLabel.text = packageName  //"\(self.QuotationPaymentPlanValueDetails.package ?? "")"
        self.financeAmountLabel.text = "$\(self.financePayment.toDoubleString)"
        self.finalPaymentLabel.text = "$\(self.finalpayment.toDoubleString)"
        self.downPaymentLabel.text = "$\(self.downPaymentValue.toDoubleString)"
        self.totalAmountLabel.text = "$\(self.totalAmount.toDoubleString)"

        self.headingLabel.text =
            "Collect the down payment amount: $\(self.downPaymentValue.toDoubleString)"

        if let customer = AppDelegate.appoinmentslData {
            let customerNameFirstName = customer.applicant_first_name ?? ""
            let customerNameMiddleName = customer.applicant_middle_name ?? ""
            let customerNameLastName = customer.applicant_last_name ?? ""
            customerName =
                customerNameFirstName + " " + customerNameMiddleName + " "
                + customerNameLastName
            //

        }

    }

    override func viewDidAppear(_ animated: Bool) {
        logScreenEvent(screen: ScreenNames.collectDownPayment) {
            var networkMessage = ""
            let speedTest = NetworkSpeedTest()
            speedTest.testUploadSpeed { speed in
                print("Upload speed: \(speed) Mbps")
                networkMessage = String(format: "%.2f", speed)
                networkMessage += "Mbps"
                //DispatchQueue.main.async {

                let (_, timeZone) = Date().getCompletedDateStringAndTimeZone()
                let parameters: [String: Any] = [
                    "appointment_id": AppointmentData().appointment_id ?? 0,
                    "screen_name": ScreenNames.collectDownPayment,
                    "screen_entry_date": Date().getSyncDateAsString(),
                    "network_strength": networkMessage, "timezone": timeZone,
                    "create_date": Date().getSyncDateAsString(),
                ]
                HttpClientManager.SharedHM.liveScreenLogsAPi(
                    parameter: parameters
                )
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)

        print(
            "finalpayment : ",
            finalpayment,
            " financePayment : ",
            financePayment,
            " downPaymentValue : ",
            downPaymentValue,
            " totalAmount : ",
            totalAmount
        )
        //JWT<paymentOptionUser>(header)
        self.setNavigationBarbackAndlogo(with: "DOWN PAYMENT".uppercased())
        if isOCR {
            return
        }
        let payment1 = DownPaymentSelectionObj(
            paymentType: .Cash,
            lable: self.cashLabel,
            view: self.cashView,
            button: self.cashButton,
            tag: 10
        )
        downpaymentSelectionObjcet.append(payment1)
        let payment2 = DownPaymentSelectionObj(
            paymentType: .CreditCard,
            lable: self.creditcardLabel,
            view: self.creditcardView,
            button: self.creditcardButton,
            tag: 11
        )
        downpaymentSelectionObjcet.append(payment2)
        let payment3 = DownPaymentSelectionObj(
            paymentType: .DebitCard,
            lable: self.debitcardLabel,
            view: self.debitcardView,
            button: self.debitcardButton,
            tag: 12
        )
        downpaymentSelectionObjcet.append(payment3)
        // Tab 4 – ACH (always)
        self.checkLabel.text = "E-Check/ACH"
        let payment4 = DownPaymentSelectionObj(
            paymentType: .ACH,
            lable: self.checkLabel,
            view: self.checkView,
            button: self.checkButton,
            tag: 13
        )
        downpaymentSelectionObjcet.append(payment4)
        // Tab 5 – Check (always)
        let payment5 = DownPaymentSelectionObj(
            paymentType: .Check,
            lable: self.checkTabLabel,
            view: self.checkTabView,
            button: self.checkTabButton,
            tag: 14
        )
        downpaymentSelectionObjcet.append(payment5)
        paymentCollectionView.register(
            UINib(nibName: "JobCompleationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "JobCompleationCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(
                nibName: "DownPaymentFromCashCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "DownPaymentFromCashCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(
                nibName: "DownPaymentFromCardCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "DownPaymentFromCardCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(
                nibName: "DownPaymentFromCheckCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "DownPaymentFromCheckCollectionViewCell"
        )
        paymentCollectionView.register(
            UINib(nibName: "DownPaymentFromACHCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "DownPaymentFromACHCollectionViewCell"
        )
        self.sideTabSelectedWith(at: self.cashButton.tag)

        self.totalAreaLabel.text = "\(area) Sq.ft"
        self.packegeLabel.text = packageName  //"\(self.QuotationPaymentPlanValueDetails.package ?? "")"
        self.financeAmountLabel.text = "$\(self.financePayment.toDoubleString)"
        self.finalPaymentLabel.text = "$\(self.finalpayment.toDoubleString)"
        self.downPaymentLabel.text = "$\(self.downPaymentValue.toDoubleString)"
        self.totalAmountLabel.text = "$\(self.totalAmount.toDoubleString)"

        self.headingLabel.text =
            "Collect the down payment amount: $\(self.downPaymentValue.toDoubleString)"

        if let customer = AppDelegate.appoinmentslData {
            let customerNameFirstName = customer.applicant_first_name ?? ""
            let customerNameMiddleName = customer.applicant_middle_name ?? ""
            let customerNameLastName = customer.applicant_last_name ?? ""
            customerName =
                customerNameFirstName + " " + customerNameMiddleName + " "
                + customerNameLastName
            //

        }
    }

    @IBAction func sidetabButtonActions(_ sender: UIButton) {
        viewForJobCompleation = false
        self.headingLabel.text =
            "Collect the down payment amount: $\(self.downPaymentValue.toDoubleString)"
        persentageValue = 10
        downPaymentInputObject = nil
        selectedAcctType = ""
        selectedAcctTypeLabel = "Select"
        cardNumber = ""
        cardExpiry = ""
        cardPin = ""
        routingNumber = ""  // ← reset ACH / Check fields when switching tabs
        accountNumber = ""
        checkNumber = ""
        self.sideTabSelectedWith(at: sender.tag)
    }

    func sideTabSelectedWith(at tag: Int) {
        if tag == 14
        {
            let yes = UIAlertAction(title: "Continue", style: .default) { (action) in
                
                
                
                UIView.animate(withDuration: 0.2) {
                    for obj in self.downpaymentSelectionObjcet {
                        
                        if obj.tag == tag {
                            self.paymentType = obj.paymentType
                            obj.view.backgroundColor = UIColor(
                                displayP3Red: 174 / 255,
                                green: 179 / 255,
                                blue: 184 / 255,
                                alpha: 0.66
                            )
                            obj.lable.textColor = .white
                        } else {
                            obj.view.backgroundColor = .clear
                            obj.lable.textColor = UIColor(
                                displayP3Red: 167 / 255,
                                green: 176 / 255,
                                blue: 186 / 255,
                                alpha: 1
                            )
                            
                        }
                        
                        self.paymentCollectionView.reloadData()
                    }
                    self.view.layoutIfNeeded()
                    
                }
            }
                
            let no = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                return
            }
                self.alert("Are you sure that you want to collect the physical check and bring it back to the office for later processing?", [yes,no])
            }
        
        else
        {
            
            
            
            UIView.animate(withDuration: 0.2) {
                for obj in self.downpaymentSelectionObjcet {
                    
                    if obj.tag == tag {
                        self.paymentType = obj.paymentType
                        obj.view.backgroundColor = UIColor(
                            displayP3Red: 174 / 255,
                            green: 179 / 255,
                            blue: 184 / 255,
                            alpha: 0.66
                        )
                        obj.lable.textColor = .white
                    } else {
                        obj.view.backgroundColor = .clear
                        obj.lable.textColor = UIColor(
                            displayP3Red: 167 / 255,
                            green: 176 / 255,
                            blue: 186 / 255,
                            alpha: 1
                        )
                        
                    }
                    
                    self.paymentCollectionView.reloadData()
                }
                self.view.layoutIfNeeded()
                
            }
        }

    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 700)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if viewForJobCompleation {
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "JobCompleationCollectionViewCell",
                    for: indexPath
                ) as! JobCompleationCollectionViewCell
            cell.reload()
            cell.payButton.setTitle("Collect", for: .normal)
            cell.payButton.addTarget(
                self,
                action: #selector(goNextPageForPAyButtonAction),
                for: .touchUpInside
            )
            return cell
        }

        if paymentType == .Cash {
            routingNumber = ""
            accountNumber = ""
            checkNumber = ""

            print(
                "******   CASE ----  DownPaymentFromCashCollectionViewCell  ---- *****"
            )

            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        "DownPaymentFromCashCollectionViewCell",
                    for: indexPath
                ) as! DownPaymentFromCashCollectionViewCell
            //  cell.totalLabel.text = "Total Price: $\(self.totalAmount.toDoubleString)"
            //cell.totalLabel.text =  "Down Payment: $\(self.downPaymentValue.toDoubleString)"
            cell.selectedItem = self.selectedPersecntage
            cell.collectionViewConfigruation(
                collectionViewData: self.persentage,
                delegate: self
            )
            cell.payButton.setTitle("Collect", for: .normal)

            self.downPaymentLabel.text =
                "$\(self.downPaymentValue.toDoubleString)"

            cell.payButton.addTarget(
                self,
                action: #selector(GoForJobCompleationValidation),
                for: .touchUpInside
            )
            return cell
        } else if paymentType == .DebitCard || paymentType == .CreditCard {
            routingNumber = ""
            accountNumber = ""
            checkNumber = ""

            print(
                "******   CARDS ----  DownPaymentFrom--Card--CollectionViewCell  ---- *****"
            )

            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        "DownPaymentFromCardCollectionViewCell",
                    for: indexPath
                ) as! DownPaymentFromCardCollectionViewCell
            cell.cardNumber = ""
            cell.cardExpiry = ""
            cell.cardPin = ""
            cell.payltrBtn.addTarget(
                self,
                action: #selector(payLtrBtn(sender:)),
                for: .touchUpInside
            )
            if paymentType == .DebitCard {
                cell.totalLabel.text = "Add Debit Card Details"
                cell.payltrStackView.isHidden = true
                //cell.payBtnTopConstraint.constant = 0

            } else {
                cell.cardNumber = self.cardNumber
                cell.cardExpiry = self.cardExpiry
                cell.cardPin = self.cardPin
                cell.totalLabel.text = "Add Credit Card Details"
                cell.payltrStackView.isHidden = true
                //cell.payBtnTopConstraint.constant = 0
                if isPayltr {
                    cell.payRadioBtn.setImage(
                        UIImage(named: "selectedRound"),
                        for: .normal
                    )

                } else {
                    cell.payRadioBtn.setImage(UIImage(named: ""), for: .normal)
                }
            }
            //cell.totalLabel.text =  "Down Payment: $\(self.downPaymentValue.toDoubleString)"
            cell.selectedItem = self.selectedPersecntage
            cell.collectionViewConfigruation(
                collectionViewData: self.persentage,
                delegate: self
            )
            cell.payButton.addTarget(
                self,
                action: #selector(GoForJobCompleationValidation),
                for: .touchUpInside
            )
            cell.cardScanButton.addTarget(
                self,
                action: #selector(cardScanner),
                for: .touchUpInside
            )
            cell.accountHolderNameTF.setPlaceHolderWithColor(
                placeholder: "Name",
                colour: .placeHolderColor
            )

            cell.cardNumberTF.keyboardType = .numberPad
            cell.cardPinTF.keyboardType = .numberPad
            cell.cardPinTF.delegate = self

            cell.cardExperyDateTF.delegate = self
            cell.cardPinTF.isSecureTextEntry = true

            cell.cardPinTF.setPlaceHolderWithColor(
                placeholder: "0000",
                colour: .placeHolderColor
            )

            if paymentType == .CreditCard {

            }
            if cardNumber == "" || cardPin == "" || cardExpiry == "" {
                cell.cardNumberTF.setPlaceHolderWithColor(
                    placeholder: "0000 0000 0000 0000",
                    colour: .placeHolderColor
                )
                cell.cardExperyDateTF.setPlaceHolderWithColor(
                    placeholder: "01/30",
                    colour: .placeHolderColor
                )
                cell.cardPinTF.setPlaceHolderWithColor(
                    placeholder: "000",
                    colour: .placeHolderColor
                )

            }

            cell.cardExperyDateTF.addTarget(
                self,
                action: #selector(datepickerSalection(_:)),
                for: .editingDidBegin
            )

            if paymentType == .DebitCard {
                //                cell.cardScanButton.setTitle("DEBIT CARD SCAN", for: .normal)
                cell.cardNumberLabel.text = "Debit Card Number"
                cell.cardPinLabel.text = "PIN"
            } else {
                //                cell.cardScanButton.setTitle("CREDIT CARD SCAN", for: .normal)
                cell.cardNumberLabel.text = "Credit Card Number"
                cell.cardPinLabel.text = "CVV"
            }
            cell.accountHolderNameTF.text = customerName
            cell.payButton.setTitle("Collect", for: .normal)

            return cell
        } else if paymentType == .Check {

            print(
                "******   CHECKS ----  DownPaymentFrom-- Check --CollectionViewCell  ---- *****"
            )
            
            //Are you sure that you want to collect the physical check and bring it back to the office for later processing?"
            
            
                
                let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        "DownPaymentFromCheckCollectionViewCell",
                    for: indexPath
                ) as! DownPaymentFromCheckCollectionViewCell
                // cell.totalLabel.text = "Total Price: $\(self.totalAmount.toDoubleString)"
                cell.totalLabel.text = "Add Turn-In Check Details"
                //cell.totalLabel.text = "Down Payment: $\(self.downPaymentValue.toDoubleString)"
                cell.selectedItem = self.selectedPersecntage
                
                cell.accountNumberTF.delegate = self
                
                cell.routingNumberTF.delegate = self
                if routingNumber != "" || accountNumber != "" || checkNumber != "" {
                    cell.routingNumberTF.text = routingNumber
                    
                    cell.accountNumberTF.text = accountNumber
                    
                    cell.checkNumberTF.text = checkNumber
                    cell.routingNumber = routingNumber
                    cell.accountNumber = accountNumber
                    cell.checkNumber = checkNumber
                    //cell.collectionView.reloadData()
                } else {
                    cell.checkNumberTF.setPlaceHolderWithColor(
                        placeholder: "00000",
                        colour: .placeHolderColor
                    )
                    cell.accountNumberTF.setPlaceHolderWithColor(
                        placeholder: "0000 0000 0000 0000",
                        colour: .placeHolderColor
                    )
                    cell.routingNumberTF.setPlaceHolderWithColor(
                        placeholder: "0000 0000 0000 0000",
                        colour: .placeHolderColor
                    )
                    cell.routingNumber = routingNumber
                    cell.accountNumber = accountNumber
                    cell.checkNumber = checkNumber
                }
                //cell.collectionViewConfigruation(collectionViewData: self.persentage, delegate: self)
                //cell.collectionViewConfigruation(collectionViewData: self.persentage, delegate: self)
                cell.payButton.addTarget(
                    self,
                    action: #selector(GoForJobCompleationValidation),
                    for: .touchUpInside
                )
                cell.cameraButton.addTarget(
                    self,
                    action: #selector(autoReadOCRForCheck),
                    for: .touchUpInside
                )
                cell.payButton.setTitle("Collect", for: .normal)
                
                cell.checkNumberTF.delegate = self
                cell.collectionViewConfigruation(
                    collectionViewData: self.persentage,
                    delegate: self
                )
                
                return cell
            
        } else {
            // ACH cell

            print(
                "******   ACH ----  DownPaymentFrom-- ACH --CollectionViewCell  ---- *****"
            )

            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: "DownPaymentFromACHCollectionViewCell",
                    for: indexPath
                ) as! DownPaymentFromACHCollectionViewCell
            cell.totalLabel.text = "Add E-Check/ACH Details"
            cell.selectedItem = self.selectedPersecntage
            cell.collectionViewConfigruation(
                collectionViewData: self.persentage,
                delegate: self
            )
            cell.bankAccountNumberTF.setPlaceHolderWithColor(
                placeholder: "0000 0000 0000 0000",
                colour: .placeHolderColor
            )
            cell.bankAccountNumberTF.keyboardType = .numberPad
            cell.bankAccountNumberTF.delegate = self
            cell.bankRoutingNumberTF.setPlaceHolderWithColor(
                placeholder: "000000000",
                colour: .placeHolderColor
            )
            cell.bankRoutingNumberTF.keyboardType = .numberPad
            cell.bankRoutingNumberTF.delegate = self
            cell.acctTypeLabel.text = selectedAcctTypeLabel
            cell.acctTypeButton.addTarget(
                self,
                action: #selector(showAcctTypeDropdown),
                for: .touchUpInside
            )
            cell.payButton.addTarget(
                self,
                action: #selector(GoForJobCompleationValidation),
                for: .touchUpInside
            )
            cell.oCRCameraBtn.addTarget(
                self,
                action: #selector(autoReadOCRForCheck),
                for: .touchUpInside
            )
            cell.payButton.setTitle("Collect", for: .normal)
            if routingNumber != "" || accountNumber != "" {
                cell.bankRoutingNumberTF.text = routingNumber

                cell.bankAccountNumberTF.text = accountNumber

                //cell.checkNumberTF.text = checkNumber
                cell.routingNumber = routingNumber
                cell.accountNumber = accountNumber
                //cell.checkNumber = checkNumber
                //cell.collectionView.reloadData()
            }

            return cell
        }
    }

    @objc func payLtrBtn(sender: UIButton) {
        isPayltr = !isPayltr
        self.paymentCollectionView.reloadData()

    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        if textField.textInputMode?.primaryLanguage == "emoji" {
            return false
        }
        //let specialCharString = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢")
        if string.rangeOfCharacter(from: Validation.specialCharString) != nil {
            return false
        }

        // Restrict routing number to 9 digits
        if let cell = paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromACHCollectionViewCell,
            textField == cell.bankRoutingNumberTF
        {
            let current = textField.text ?? ""
            let newLength = current.count + string.count - range.length
            return newLength <= 9
        }

        return true
    }

    /*
    @objc func cardScanner() {
        let rec = RecognizerViewController.initialization()!
        rec.delegate = self
        self.navigationController?.pushViewController(rec, animated: true)
    }
    */
    /*
    @objc func autoReadOCRForCheck() {
    
        // self.openScanner()
        //            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        //                appDelegate.orientationLock = .landscape
        //            }
    
        // Force the device to rotate immediately
        UIDevice.current.setValue(
            UIInterfaceOrientation.landscapeRight.rawValue,
            forKey: "orientation"
        )
    
        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        present(scannerViewController, animated: true)
    
    }
    */

    //    @objc func autoReadOCRForCheck() {
    //        // Force landscape orientation
    //        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
    //            appDelegate.orientationLock = .landscape
    //        }
    //
    //        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    //
    //        // Use the custom landscape scanner
    //        let scannerViewController = imagesc()
    //        scannerViewController.imageScannerDelegate = self
    //        scannerViewController.modalPresentationStyle = .fullScreen
    //
    //        present(scannerViewController, animated: true)
    //    }

    //    private func configureCameraForLandscape(_ scanner: ImageScannerController)
    //    {// Find the camera view controller in the navigation stack
    //        if let cameraVC = scanner.viewControllers.first(where: { $0 is ScannerViewController }) {// Use reflection to access private properties
    //            let mirror = Mirror(reflecting: cameraVC)
    //            for child in mirror.children {if child.label == "previewLayer", let previewLayer = child.value as? AVCaptureVideoPreviewLayer {
    //                if let connection = previewLayer.connection, connection.isVideoOrientationSupported {                    connection.videoOrientation = .landscapeRight
    //                        print("Camera preview set to landscape right")}}}}}
    //

    /*
    func openScanner() {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true, completion: nil)
    }
    
    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        for pageIndex in 0..<scan.pageCount {
            let img = scan.imageOfPage(at: pageIndex)
            //let yes = UIAlertAction(title: "OK", style:.default) { (_) in
    
            controller.dismiss(animated: true)
            let selectRoomPopUp =
                SelectRoomCommentPopUpViewController.initialization()!
            selectRoomPopUp.isSuccess = true
            selectRoomPopUp.isOCR = true
            selectRoomPopUp.sendReviewFailedMsg =
                "We have filled in most of the details for you. Just take a moment to double-check with your check to make sure everything is accurate."  //message ?? ""
            self.present(selectRoomPopUp, animated: true, completion: nil)
    
            self.isOCR = true
            detectMICR(from: img)
    
        }
        //               let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //
        //               self.alert("We have filled in most of the details for you. Just take a moment to double-check with your check to make sure everything is accurate.", [yes,no])
        // 👉 Process this image to check if it's a check (OCR, MICR detection)
    
        //}
    
        //sideTabSelectedWith(at: self.checkButton.tag)
    }
    
     */

    func openCameraToPickImage() {
        cameraImagePicker.allowsEditing = false
        cameraImagePicker.sourceType = .camera
        cameraImagePicker.mediaTypes =
            UIImagePickerController.availableMediaTypes(for: .camera)!  // [kUTTypeImage as String]//
        //        if UIDevice.current.userInterfaceIdiom == .pad
        //        {
        //self.popOver = UIPopoverController(contentViewController: cameraImagePicker)
        // if isRoomImage{
        //self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY - 300, width: 300, height: 300), in: self.view, permittedArrowDirections: .any, animated: true)
        //            }else{
        //self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY , width: 400, height: 400), in: self.view, permittedArrowDirections: .any, animated: true)
        //            }
        //        }
        //        else
        //        {
        present(
            cameraImagePicker,
            animated: true,
            completion: {
                self.cameraImagePicker.navigationBar.topItem?
                    .rightBarButtonItem?.tintColor = .black
                self.cameraImagePicker.navigationBar.topItem?
                    .rightBarButtonItem?.isEnabled = true
            }
        )
        //}
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:
            Any]
    ) {
        if let originalImage = info[
            UIImagePickerController.InfoKey.originalImage
        ] as? UIImage {
            print("imageDone")
            ocrCameraImage = originalImage
        }
        dismiss(animated: true, completion: nil)
        // ocrReadingFromImage(pickedImage: ocrCameraImage!)
        //processImage(image: ocrCameraImage!)
        //        detectMICR(from: ocrCameraImage!)
    }

    func ocrReadingFromImage(pickedImage: UIImage) {
        //        // converting image into CGImage
        let sampleCheckImage = UIImage(named: "sampleCheck")
        guard let cgImage = sampleCheckImage?.cgImage else { return }
        // creating request with cgImage
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        // Vision provides its text-recognition capabilities through
        //VNRecognizeTextRequest, an image-based request type that finds and extracts text in images.
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else { return }

            guard
                let results = request.results as? [VNRecognizedTextObservation]
            else { return }

            let text = results.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: ", ")

            print(text)  // text we get from image

            let (routing_number, account_number, check_number) =
                self.extractCheckInfo(from: text)
            print("Routing Number :\(routing_number)")
            print("Account Number: \(account_number)")
            print("Check Number: \(check_number)")

        }
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]

        // let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("Vision request failed: \(error)")
        }

    }

    /*
    func imageScannerController(
        _ scanner: ImageScannerController,
        didFinishScanningWithResults results: ImageScannerResults
    ) {
        // The user successfully scanned an image, which is available in the ImageScannerResults
        // You are responsible for dismissing the ImageScannerController
    
        //        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        //            appDelegate.orientationLock = .all
        //        }
        //
        //        // Restore back to your default orientation (e.g., portrait)
        //        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    
        scanner.dismiss(animated: true)
        let selectRoomPopUp =
            SelectRoomCommentPopUpViewController.initialization()!
        selectRoomPopUp.isSuccess = true
        selectRoomPopUp.isOCR = true
        selectRoomPopUp.sendReviewFailedMsg =
            "We have filled in most of the details for you. Just take a moment to double-check with your check to make sure everything is accurate."  //message ?? ""
        self.present(selectRoomPopUp, animated: true, completion: nil)
    
        self.isOCR = true
        detectMICR(from: results.croppedScan.image)
    }
    */

    /*
    func detectMICR(from image: UIImage) {
        //let sampleCheckImage = UIImage(named: "sampleCheck")
        guard let cgImage = image.cgImage else { return }
    
        let request = VNRecognizeTextRequest { request, error in
            guard
                let observations = request.results
                    as? [VNRecognizedTextObservation]
            else { return }
    
            var allLines: [String] = []
            for observation in observations {
                if let candidate = observation.topCandidates(1).first {
                    allLines.append(candidate.string)
                }
            }
    
            print("All OCR Lines: \(allLines)")
    
            //if let micrLine = allLines.sorted(by: { $0.count > $1.count }).last {
            let micr = self.extractMICRLine(from: allLines)
            print("Routing: \(micr.routing ?? "N/A")")
            print("Account: \(micr.account ?? "N/A")")
            print("Check #: \(micr.checkNumber ?? "N/A")")
            self.routingNumber = micr.routing ?? ""
            self.accountNumber = micr.account ?? ""
            self.checkNumber = micr.checkNumber ?? ""
            //}
        }
    
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false  // MICR isn't real words
        request.recognitionLanguages = ["en-US"]
    
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
        self.sideTabSelectedWith(at: self.checkButton.tag)
        //        self.paymentType = .Check
        //        self.paymentCollectionView.reloadData()
    }
    */

    /*
    func extractMICRLine(from lines: [String]) -> (
        routing: String?, account: String?, checkNumber: String?
    ) {
        let micrCandidates = lines.filter {
            $0.rangeOfCharacter(from: .decimalDigits) != nil
        }
        let micrJoined = micrCandidates.joined(separator: " ")
        let normalized = normalizeMICRText(micrCandidates.last ?? micrJoined)
    
        // Find all groups of digits
        let regex = try! NSRegularExpression(pattern: #"\d+"#)
        let matches = regex.matches(
            in: normalized,
            range: NSRange(normalized.startIndex..., in: normalized)
        )
    
        var routing: String?
        var account: String?
        var check: String?
    
        for match in matches {
            let number = (normalized as NSString).substring(with: match.range)
    
            switch number.count
            {
            case 9...12:
                if routing == nil {
                    routing = number
                } else {
                    account = number
                }
            case 3...7:
                if check == nil {
                    check = number
                } else {
                    account = number
                }
            case 4...12:
                if account == nil  //&& number.count != 9
                {
                    account = number
                }
            default:
                continue
            }
        }
    
        return (routing, account, check)
    }
    */

    func normalizeMICRText(_ text: String) -> String {
        var cleaned = text
        // Replace common Vision misreads for MICR symbols
        //        cleaned = cleaned.replacingOccurrences(of: "P", with: "")
        cleaned = cleaned.replacingOccurrences(of: "1:", with: "")
        cleaned = cleaned.replacingOccurrences(of: "ar", with: "1")
        cleaned = cleaned.replacingOccurrences(of: "AR", with: "1")
        // Remove everything that's not a digit or space
        cleaned = cleaned.replacingOccurrences(
            of: "[^0-9 ]",
            with: "",
            options: .regularExpression
        )
        return cleaned
    }

    func preprocessImage(_ image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(1.0, forKey: kCIInputContrastKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)

        let context = CIContext()
        if let output = filter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent)
        {
            return UIImage(cgImage: cgImage)
        }
        return image
    }

    func processImage(image: UIImage) {
        let sampleCheckImage = UIImage(named: "sampleCheck")
        let processImage = preprocessImage(sampleCheckImage!)
        guard let cgImage = processImage.cgImage else { return }

        let request = VNRecognizeTextRequest { request, error in
            guard
                let observations = request.results
                    as? [VNRecognizedTextObservation], error == nil
            else {
                print(
                    "Text recognition error: \(error?.localizedDescription ?? "Unknown error")"
                )
                return
            }

            let recognizedText = observations.compactMap { observation in
                // Get the top candidate for recognition
                return observation.topCandidates(1).first?.string
            }.joined(separator: "\n")

            // Now, you can apply post-processing, including filtering and regex
            print("Raw recognized text:\n\(recognizedText)")

            // Filtering non-numeric characters (basic filtering, adjust as needed)
            //let filteredText = recognizedText.components(separatedBy: CharacterSet.decimalDigits.inverted)
            // .joined()

            let result = self.extractCheckInfo(from: recognizedText)

            let filteredText =
                recognizedText
                .components(
                    separatedBy: CharacterSet(charactersIn: "0123456789")
                        .inverted
                )
                .filter { !$0.isEmpty && $0.count >= 5 }.joined()

            // Regex for Account and Routing Numbers (Illustrative - requires refinement based on your checks)
            // **Important:** MICR is highly country-specific. The regex for routing and account numbers can vary significantly.
            // Consult banking regulations and MICR specifications for your region to create accurate regex patterns.

            // Example Regex (Illustrative - routing number pattern)
            let routingNumberPattern = "\\b\\d{9}\\b"  // 9 digits, surrounded by word boundaries
            if let routingRange = filteredText.range(
                of: routingNumberPattern,
                options: .regularExpression
            ) {
                let routingNumber = String(filteredText[routingRange])
                print("Detected Routing Number: \(routingNumber)")
            }

            // Example Regex (Illustrative - account number pattern)
            let accountNumberPattern = "\\b\\d{10,}\\b"  // 10 or more digits, surrounded by word boundaries
            if let accountRange = filteredText.range(
                of: accountNumberPattern,
                options: .regularExpression
            ) {
                let accountNumber = String(filteredText[accountRange])
                print("Detected Account Number: \(accountNumber)")
            }
        }

        // You can customize the request:
        request.recognitionLevel = .accurate  // Prioritize accuracy
        request.usesLanguageCorrection = false  // Disable language correction for MICR
        // request.recognitionLanguages = ["en-US"] //  Can provide some context

        let requestHandler = VNImageRequestHandler(
            cgImage: cgImage,
            options: [:]
        )
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
        }
    }

    func
        extractCheckInfo(from text: String) -> (
            routing: String?, account: String?, check: String?
        )
    {
        // 1. Extract all digit sequences, removing non-digit characters
        let digitGroups =
            text
            .components(
                separatedBy: CharacterSet(charactersIn: "0123456789").inverted
            )
            .filter { !$0.isEmpty && $0.count >= 5 }  // Likely to be routing/account/check

        // 2. Iterate through sequences to find a 9-digit number (routing number candidate)
        for i in 0..<digitGroups.count {
            let group = digitGroups[i]

            if group.count >= 9 {
                // Try to extract a routing number from the first 9 digits
                let routing = String(group.prefix(9))
                let remainder = String(group.dropFirst(9))

                var account: String? = nil
                var check: String? = nil

                // Try to use remainder as account number if it's long enough
                if remainder.count >= 4 {
                    account = remainder
                } else if i + 1 < digitGroups.count {
                    account = digitGroups[i + 1]
                }

                // Check number is likely the group after the account
                if i + 2 < digitGroups.count {
                    check = digitGroups[i + 2]
                }

                return (routing, account, check)
            }
        }  // 24234567890, 4678904, ~87417

        // Fallback if no 9+ digit group found
        return (nil, nil, nil)
    }

    @objc func GoForJobCompleationValidation() {
        if paymentType == .Cash {
            GoForJobCompleation()
        } else if paymentType == .DebitCard || paymentType == .CreditCard {
            validateForCard()
        } else if paymentType == .ACH {
            validateForACH()
        } else {
            validateForCheck()
        }
    }
    func GoForJobCompleation() {
        let offlinemsg =
            "Are you sure you want to continue with this downpayment?"
        let onlinemsg =
            "Are you sure you want to continue with this downpayment? Once you proceed, you can’t navigate back and change the payment option again."

        if paymentType == .Cash {
            DispatchQueue.main.async {
                self.goNextPageForPAyButtonAction()
            }
        } else if paymentType == .DebitCard || paymentType == .CreditCard {
            let yes = UIAlertAction(title: "Continue", style: .default) { (_) in

                DispatchQueue.main.async {
                    self.goNextPageForPAyButtonAction()
                }
            }
            let no = UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
            if HttpClientManager.SharedHM.connectedToNetwork() {
                DispatchQueue.main.async {
                    self.alert(onlinemsg, [yes, no])
                }

            } else {
                DispatchQueue.main.async {
                    self.alert(offlinemsg, [yes, no])
                }
            }
        } else if paymentType == .ACH {
            let yes = UIAlertAction(title: "Continue", style: .default) { (_) in
                self.goNextPageForPAyButtonAction()
            }
            let no = UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
            if HttpClientManager.SharedHM.connectedToNetwork() {
                self.alert(onlinemsg, [yes, no])
            } else {
                self.alert(offlinemsg, [yes, no])
            }
        } else {
            self.goNextPageForPAyButtonAction()
        }

        // goNextPageForPAyButtonAction()
        //        self.headingLabel.text = "How do you want to pay the balance amount?"
        //        self.viewForJobCompleation = true
        //        self.paymentCollectionView.reloadData()
    }

    func validateForCheck() {
        var checkNumber = ""
        var accountNumber = ""
        var routineNumber = ""
        if let cell = paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromCheckCollectionViewCell
        {
            if (cell.checkNumberTF.text ?? "") != "" {
                if Int((cell.checkNumberTF.text ?? "")) == nil {
                    self.alert("please enter correct check number", nil)
                    return
                }
                checkNumber = (cell.checkNumberTF.text ?? "")
//                if (cell.accountNumberTF.text ?? "") != "" {
//                    if Int((cell.accountNumberTF.text ?? "")) == nil {
//                        self.alert("Please enter correct account number", nil)
//                        return
//                    }

//                    accountNumber = (cell.accountNumberTF.text ?? "")
//                    if (cell.routingNumberTF.text ?? "") != "" {
//                        if Int((cell.routingNumberTF.text ?? "")) == nil {
//                            self.alert(
//                                "Please enter correct routing number",
//                                nil
//                            )
//                            return
//                        }
                        routineNumber = (cell.routingNumberTF.text ?? "")
                        downPaymentInputObject = DownPaymentInputObject(
                            paymentType: .Check,
                            cardPaymentValue: nil,
                            checkValue: CheckValue(
                                checkNumber: checkNumber,
                                accountNumber: accountNumber,
                                routingNumber: routineNumber
                            )
                        )
                        GoForJobCompleation()

//                    } else {
//                        self.alert("Please enter routine number", nil)
//                    }
//                } else {
//                    self.alert("Please enter account number", nil)
//                }

            } else {
                self.alert("Please enter check number", nil)
            }

        } else {
            self.alert("Something went wrong", nil)
        }
    }

    func validateForACH() {
        if selectedAcctType.isEmpty {
            self.alert("Please select an account type", nil)
            return
        }
        if let cell = paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromACHCollectionViewCell
        {
            let acct = cell.bankAccountNumberTF.text ?? ""
            let routing = cell.bankRoutingNumberTF.text ?? ""
            if acct.isEmpty {
                self.alert("Please enter bank account number", nil)
                return
            }
            if Int(acct) == nil {
                self.alert("Please enter a valid bank account number", nil)
                return
            }
            if routing.isEmpty {
                self.alert("Please enter routing number", nil)
                return
            }
            if Int(routing) == nil {
                self.alert("Please enter a valid routing number", nil)
                return
            }
            if routing.count != 9 {
                self.alert("Routing number must be exactly 9 digits", nil)
                return
            }
            downPaymentInputObject = DownPaymentInputObject(
                paymentType: .ACH,
                cardPaymentValue: nil,
                checkValue: CheckValue(
                    checkNumber: "",
                    accountNumber: acct,
                    routingNumber: routing
                )
            )
            GoForJobCompleation()
        } else {
            self.alert("Something went wrong", nil)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print("cntrl here")
        if paymentType == .CreditCard {
            if textField.placeholder == "0000 0000 0000 0000" {
                self.cardNumber = textField.text ?? ""
            }
            if textField.placeholder == "01/30" {
                self.cardExpiry = textField.text ?? ""
            }
            if textField.placeholder == "000" {
                self.cardPin = textField.text ?? ""
            }
        }
    }
    func validateForCard() {
        var name = ""
        var cardNumber = ""
        var experyDate = ""
        var pin = ""
        if let cell = paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromCardCollectionViewCell
        {
            var month = Int()
            var year = Int()
            let monthInt = Calendar.current.component(.month, from: Date() - 1)
            let currentyear = Calendar.current.component(.year, from: Date())
            if cell.cardExperyDateTF.text == "" {
                month = self.datePicker.month
                year = self.datePicker.year
            } else {
                let string = cell.cardExperyDateTF.text
                let ch = Character("/")
                let result = string?.components(separatedBy: "/")
                month = (result?[0] as? NSString)?.integerValue ?? 0
                year = (result?[1] as? NSString)?.integerValue ?? 0
                //                month=result?.startIndex ?? 0
                //                year=result?.firstIndex(of: result)
                //                print("month",month)
            }
            if (cell.accountHolderNameTF.text ?? "") != "" {
                name = (cell.accountHolderNameTF.text ?? "")
                if (cell.cardNumberTF.text ?? "") != "" {
                    if Int((cell.cardNumberTF.text ?? "")) == nil {
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
                    } else {

                        self.alert("Please enter valid card number", nil)
                        return
                    }
                    if let type = CreditCardValidator(cardNumber).type {
                        print(type)  // Visa, Mastercard, Amex etc.
                    } else {
                        // I Can't detect type of credit card
                    }

                    // if(cardNumber.)
                    if (cell.cardExperyDateTF.text ?? "") != "" {
                        if month < monthInt && currentyear % 100 == year {
                            self.alert("The card entered is expired", .none)
                        } else {
                            experyDate = (cell.cardExperyDateTF.text ?? "")
                            if (cell.cardPinTF.text ?? "") != "" {
                                if Int((cell.cardPinTF.text ?? "")) == nil {
                                    self.alert(
                                        "Please enter correct cvv/pin number",
                                        nil
                                    )
                                    return
                                }

                                pin = (cell.cardPinTF.text ?? "")
                                downPaymentInputObject = DownPaymentInputObject(
                                    paymentType: paymentType,
                                    cardPaymentValue: CardPaymentValue(
                                        accountName: name,
                                        cardNumber: cardNumber,
                                        experyDate: experyDate,
                                        pinNumber: pin,
                                        isPayLtr: isPayltr
                                    ),
                                    checkValue: nil
                                )
                                self.cardNumber = cardNumber
                                self.cardExpiry = experyDate
                                self.cardPin = pin

                                self.GoForJobCompleation()

                            } else {
                                self.alert("Please enter cvv/pin number", nil)
                            }
                        }

                    } else {
                        self.alert("Please enter expiry date", nil)
                    }
                } else {
                    self.alert("Please enter card number", nil)
                }
            } else {
                self.alert("Please enter account holder name", nil)
            }

        } else {
            self.alert("Something went wrong", nil)
        }
    }

    func externalCollectionViewDidSelectbutton(index: Int, tag: Int) {
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

    func createCustomerParameter() -> [String: Any] {
        return self.getCustomerDetailsForApiCall()
    }
    func createRoomParameters() -> [[String: Any]] {
        return self.getRoomArrayForApiCall()
    }
    func createQuestionAnswerForAllRoomsParameter() -> [[String: Any]] {
        return self.getQuestionAnswerArrayForApiCall()
    }

    func createFinalParameterForCustomerApiCall() -> [String: Any] {
        var customerDict: [String: Any] = [:]
        customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        customerDict["data_completed"] = 0
        var customerData = createCustomerParameter()
        customerDict["customer"] = customerData
        customerDict["rooms"] = createRoomParameters()
        customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
        customerDict["operation_mode"] = "online"
        customerDict["app_version"] =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return customerDict
    }

    func createContractParameters() -> [String: Any] {
        let paymentDetails = self.getPaymentDetailsDataFromAppointmentDetail()
        print(paymentDetails)
        let paymentType = self.getPaymentMethodTypeFromAppointmentDetail()

        print(paymentType)
        let paymentTypeSecret = createJWTToken(parameter: paymentType)

        let applicantDta = self.getApplicantAndIncomeDataFromAppointmentDetail()
        print(applicantDta)
        var applicantInfoSecret: String = String()
        if applicantDta.count > 0 {
            applicantInfoSecret = createJWTTokenApplicantInfo(
                parameter: applicantDta["data"] as! [String: Any]
            )

        }
        //let contactInfo = self.getContractDataOfAppointment()
        //print(contactInfo)
        var contractDict: [String: Any] = [:]
        contractDict["paymentdetails"] = paymentDetails
        contractDict["payment_method_secret"] = paymentTypeSecret  //paymentType//
        contractDict["application_info_secret"] = applicantInfoSecret  //applicantDta["data"] //
        //contractDict["contractInfo"] = contactInfo
        //        contractDict["data_completed"] = 0
        //        contractDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        //        let contractDataDict: [String:Any] = ["data":contractDict]
        //        print(contractDataDict)
        return contractDict  //contractDataDict
    }

    @objc func goNextPageForPAyButtonAction() {
        if paymentType == .CreditCard || paymentType == .DebitCard
            || paymentType == .ACH
        {
            //let room_id = roomData.id
            //deleteRoomFromAppointment(appointmentId:AppointmentData().appointment_id ?? 0, roomId: self.roomData.id ?? 0)
            if HttpClientManager.SharedHM.connectedToNetwork() {
                DispatchQueue.main.async {

                    HttpClientManager.SharedHM.showhideHUD(
                        viewtype: .SHOW,
                        title: "Processing Payment"
                    )
                    var networkMessage = ""
                    let speedTest = NetworkSpeedTest()
                    speedTest.testUploadSpeed { speed in
                        print("Upload speed: \(speed) Mbps")
                        networkMessage = String(format: "%.2f", speed)
                        networkMessage += "Mbps"
                        //DispatchQueue.main.async {

                        self.networkProceedToPayment(
                            networkMessage: networkMessage
                        )
                    }
                }

            } else {
                getCardDetails()
                cardDetailsAPiSuccess()
            }
        }
        //arb
        else {
            getCardDetails()
            cardDetailsAPiSuccess()
        }

    }
    func networkProceedToPayment(networkMessage: String) {
        DispatchQueue.main.async {

            self.getCardDetails()
            var parameter = self.createContractParameters()
            let appointmentId = AppointmentData().appointment_id ?? 0
            if let applicantDataDict = parameter as? [String: Any] {
                if let applicant = applicantDataDict["application_info_secret"]
                    as? String
                {
                    if applicant == "" {

                    } else {
                        var applicantData: [String: Any] = [:]
                        let customerFullDict = JWTDecoder.shared.decodeDict(
                            jwtToken: applicant
                        )
                        applicantData =
                            (customerFullDict["payload"] as? [String: Any]
                                ?? [:])
                        self.saveToCustomerDetailsOnceUpdatedInApplicantForm(
                            appointmentId: appointmentId,
                            customerDetailsDict: applicantData
                        )
                    }
                }
                //                    if  let applicant = applicantDataDict["applicationInfo"] as? [String:Any]{
                //                        self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicant)
                // }
            }  //createFinalParameterForCustomerApiCall()
            var parameterToPass: [String: Any] = [:]
            //var jwtToken:String = String()
            let contactApiData = self.createFinalParameterForCustomerApiCall()  //self.createContractParameters()
            for (key, value) in contactApiData {
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

            let decodeOption: [String: Bool] = ["verify_signature": false]

            // params["network_strength"] = networkMessage

            parameterToPass = [
                "token": UserData.init().token ?? "",
                "decode_options": decodeOption, "data": parameter,
                "network_strength": networkMessage,
                "create_date": Date().getSyncDateAsString(),
            ]
            // }
            // let paymentOptionUserDetails = paymentOptionUser(payment_Method: "cash", paymentDetails: userPaymentDetails)

            let dbParameter = parameter
            //

            //parameter["token"] = UserData.init().token ?? ""

            HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(
                parameter: parameterToPass,
                isOnlineCollectBtnPressed: true
            ) {
                success,
                message,
                payment_status,
                payment_message,
                transactionId,
                cardType in
                DispatchQueue.main.async {

                    if (success ?? "") == "Success"
                        || (success == "Failed" && transactionId != "Invalid")
                    {
                        print("success")
                        let appointment = self.getAppointmentData(
                            appointmentId: AppointmentData().appointment_id ?? 0
                        )
                        let firstName = appointment?.applicant_first_name ?? ""
                        let lastName = appointment?.applicant_last_name ?? ""
                        let name =
                            lastName == ""
                            ? firstName : firstName + " " + lastName
                        let date = appointment?.appointment_datetime ?? ""
                        let appointmentId =
                            AppointmentData().appointment_id ?? 0
                        // self.saveLogDetailsForAppointment(appointmentId: appoint, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                        self.saveLogDetailsForAppointment(
                            appointmentId: appointmentId,
                            logMessage: AppointmentLogMessages
                                .customerDetailsSyncCompleted.rawValue,
                            time: Date().getSyncDateAsString(),
                            name: name,
                            appointmentDate: date,
                            payment_status: payment_status ?? "",
                            payment_message: payment_message ?? ""
                        )
                        self.deleteAnyAppointmentLogsTable(
                            appointmentId: appointmentId
                        )
                        self.createDBAppointmentRequest(
                            requestTitle: RequestTitle.CustomerAndRoom,
                            requestUrl: AppURL().syncCustomerAndRoomInfo,
                            requestType: RequestType.post,
                            requestParameter: dbParameter as NSDictionary,
                            imageName: ""
                        )
                        //self.alert(message ?? "", nil)
                        if success == "Success" {
                            self.isCardVerifiedSuccessfully = true
                        } else {
                            self.payment_TrasnsactionDict = [
                                "authorize_transaction_id": transactionId ?? "",
                                "card_type": cardType ?? "",
                            ]
                            self.isCardVerifiedSuccessfully = false
                        }
                        let yes = UIAlertAction(title: "OK", style: .default) {
                            (_) in

                            self.cardDetailsAPiSuccess()
                        }

                        self.alert(payment_message ?? "", [yes])
                    } else if (success ?? "") == "AuthFailed"
                        || ((success ?? "") == "authfailed")
                    {

                        let yes = UIAlertAction(title: "OK", style: .default) {
                            (_) in

                            self.fourceLogOutbuttonAction()
                        }

                        self.alert(
                            (message) ?? AppAlertMsg.serverNotReached,
                            [yes]
                        )

                    } else {
                        let yes = UIAlertAction(title: "Retry", style: .default)
                        { (_) in
                            self.goNextPageForPAyButtonAction()
                        }
                        let no = UIAlertAction(
                            title: "Cancel",
                            style: .cancel,
                            handler: nil
                        )
                        let errorMsg: String
                        if let pm = payment_message, !pm.isEmpty {
                            errorMsg = pm
                        } else {
                            errorMsg = message ?? AppAlertMsg.serverNotReached
                        }
                        self.alert(errorMsg, [yes, no])
                    }
                }
            }
        }

    }

    @objc func cardDetailsAPiSuccess() {
        if self.paymentType == .Cash {
            DispatchQueue.main.async {
                let cancel = AppointmentSummaryViewController.initialization()!
                //web.downPayment = self.DownPaymentcalucaltion().downPayment
                //web.balance  = self.DownPaymentcalucaltion().balance
                cancel.downPayment = self.downPaymentValue  //self.downpayment.DownPaymentcalucaltion().downPayment
                cancel.total = self.totalAmount
                cancel.balance = self.totalAmount - self.downPaymentValue
                cancel.paymentType = "cash"
                cancel.isCardVerified = false
                cancel.payment_TrasnsactionDict = self.payment_TrasnsactionDict
                cancel.area = self.getTotalAdjustedAreaForAllRooms()
                cancel.totalPrice = self.totalAmount
                cancel.finalPayment = self.finalpayment
                cancel.financeAmount = self.financePayment
                self.navigationController?.pushViewController(
                    cancel,
                    animated: true
                )
            }
        } else if self.paymentType == .Check {
            DispatchQueue.main.async {
                let cancel = AppointmentSummaryViewController.initialization()!
                //web.downPayment = self.DownPaymentcalucaltion().downPayment
                //web.balance  = self.DownPaymentcalucaltion().balance
                cancel.downPayment = self.downPaymentValue  //self.downpayment.DownPaymentcalucaltion().downPayment
                cancel.total = self.totalAmount
                cancel.balance = self.totalAmount - self.downPaymentValue
                cancel.paymentType = "check"
                cancel.isCardVerified = false
                cancel.payment_TrasnsactionDict = self.payment_TrasnsactionDict
                cancel.area = self.getTotalAdjustedAreaForAllRooms()
                cancel.totalPrice = self.totalAmount
                cancel.finalPayment = self.finalpayment
                cancel.financeAmount = self.financePayment
                self.navigationController?.pushViewController(
                    cancel,
                    animated: true
                )
            }

        } else {
            DispatchQueue.main.async {
                let cancel = AppointmentSummaryViewController.initialization()!
                //web.downPayment = self.DownPaymentcalucaltion().downPayment
                //web.balance  = self.DownPaymentcalucaltion().balance
                cancel.downPayment = self.downPaymentValue  //self.downpayment.DownPaymentcalucaltion().downPayment
                cancel.total = self.totalAmount
                cancel.balance = self.totalAmount - self.downPaymentValue
                cancel.paymentType = "card"
                cancel.isCardVerified = self.isCardVerifiedSuccessfully
                cancel.payment_TrasnsactionDict = self.payment_TrasnsactionDict
                cancel.area = self.getTotalAdjustedAreaForAllRooms()
                cancel.totalPrice = self.totalAmount
                cancel.finalPayment = self.finalpayment
                cancel.financeAmount = self.financePayment
                self.navigationController?.pushViewController(
                    cancel,
                    animated: true
                )
            }
        }
    }
    func getCardDetails() {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "CollectDownPayment"
        self.saveScreenCompletionTimeToDb(
            appointmentId: appointmentId,
            className: currentClassName,
            displayName: classDisplayName,
            time: Date()
        )
        //
        let balancePay = ""
        if paymentType == .Cash {
            var expirydate = downPaymentInputObject?.cardPaymentValue?
                .experyDate
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")

            let dict = [
                "card_number": downPaymentInputObject?.cardPaymentValue?
                    .cardNumber ?? "", "card_expiry": expirydate ?? "",
                "card_holder_name": downPaymentInputObject?.cardPaymentValue?
                    .accountName ?? "",
                "cardpin": downPaymentInputObject?.cardPaymentValue?.pinNumber
                    ?? "",
                "check_number": downPaymentInputObject?.checkValue?.checkNumber
                    ?? "",
                "check_account_number": downPaymentInputObject?.checkValue?
                    .accountNumber ?? "",
                "check_routing_number": downPaymentInputObject?.checkValue?
                    .routingNumber ?? "",
            ]
            let paymentOption = self.getPaymentOptionAndValues(
                payment_method: "cash",
                paymentOptionDict: dict
            )
            self.savePaymentMethodTypeToAppointmentDetail(
                paymentType: paymentOption.nsDictionary
            )

        } else if paymentType == .CreditCard {

            var expirydate = downPaymentInputObject?.cardPaymentValue?
                .experyDate
            //expirydate = expirydate?.expiryDateToString(date: expirydate ?? "")
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")

            let data: [String: Any] = [
                "card_number": downPaymentInputObject?.cardPaymentValue?
                    .cardNumber ?? "", "card_expiry": expirydate ?? "",
                "card_holder_name": downPaymentInputObject?.cardPaymentValue?
                    .accountName ?? "",
                "cardpin": downPaymentInputObject?.cardPaymentValue?.pinNumber
                    ?? "",
                "check_number": downPaymentInputObject?.checkValue?.checkNumber
                    ?? "",
                "check_account_number": downPaymentInputObject?.checkValue?
                    .accountNumber ?? "",
                "check_routing_number": downPaymentInputObject?.checkValue?
                    .routingNumber ?? "",
//                "pay_later":
//                    (downPaymentInputObject?.cardPaymentValue!.isPayLtr)!
//                    ? 1 : 0
            ]
            let paymentOption = self.getPaymentOptionAndValues(
                payment_method: "credit_card",
                paymentOptionDict: data
            )

            print(paymentOption)
            self.savePaymentMethodTypeToAppointmentDetail(
                paymentType: paymentOption.nsDictionary
            )
            //            let web = WebViewViewController.initialization()!
            //            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //            //web.balance  = self.DownPaymentcalucaltion().balance
            //            web.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
            //            web.total = self.totalAmount
            //            web.balance = self.totalAmount - self.downPaymentValue
            //            web.paymentType = "card"
            //            self.navigationController?.pushViewController(web, animated: true)
        } else if paymentType == .DebitCard {
            //self.paymentTransactionDebitCardApi(isOnJobCompleation: true, balancePaymentMethord: balancePay)
            var expirydate = downPaymentInputObject?.cardPaymentValue?
                .experyDate
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")

            let data: [String: Any] = [
                "card_number": downPaymentInputObject?.cardPaymentValue?
                    .cardNumber ?? "", "card_expiry": expirydate ?? "",
                "card_holder_name": downPaymentInputObject?.cardPaymentValue?
                    .accountName ?? "",
                "cardpin": downPaymentInputObject?.cardPaymentValue?.pinNumber
                    ?? "",
                "check_number": downPaymentInputObject?.checkValue?.checkNumber
                    ?? "",
                "check_account_number": downPaymentInputObject?.checkValue?
                    .accountNumber ?? "",
                "check_routing_number": downPaymentInputObject?.checkValue?
                    .routingNumber ?? "",
            ]
            let paymentOption = self.getPaymentOptionAndValues(
                payment_method: "debit_card",
                paymentOptionDict: data
            )

            print(paymentOption)
            self.savePaymentMethodTypeToAppointmentDetail(
                paymentType: paymentOption.nsDictionary
            )
            //            let web = WebViewViewController.initialization()!
            //            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //            //web.balance  = self.DownPaymentcalucaltion().balance
            //            web.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
            //            web.total = self.totalAmount
            //            web.balance = self.totalAmount - self.downPaymentValue
            //            web.paymentType = "card"
            //            self.navigationController?.pushViewController(web, animated: true)
        } else if paymentType == .Check {
            //self.paymentTransactionCheckApi(isOnJobCompleation: true, balancePaymentMethord: balancePay)
            var expirydate = downPaymentInputObject?.cardPaymentValue?
                .experyDate
            expirydate = expirydate?.replacingOccurrences(of: "/", with: "-")
            let data: [String: Any] = [
                "card_number": downPaymentInputObject?.cardPaymentValue?
                    .cardNumber ?? "", "card_expiry": expirydate ?? "",
                "card_holder_name": downPaymentInputObject?.cardPaymentValue?
                    .accountName ?? "",
                "cardpin": downPaymentInputObject?.cardPaymentValue?.pinNumber
                    ?? "",
                "check_number": downPaymentInputObject?.checkValue?.checkNumber
                    ?? "",
                "check_account_number": downPaymentInputObject?.checkValue?
                    .accountNumber ?? "",
                "check_routing_number": downPaymentInputObject?.checkValue?
                    .routingNumber ?? "", "acct_type": selectedAcctType,
            ]
            let paymentOption = self.getPaymentOptionAndValues(
                payment_method: "check",
                paymentOptionDict: data
            )

            print(paymentOption)
            self.savePaymentMethodTypeToAppointmentDetail(
                paymentType: paymentOption.nsDictionary
            )

            //test
            // let paymentMethodData = self.getPaymentMethodTypeFromAppointmentDetail()
            //print(paymentMethodData)
            //
        } else if paymentType == .ACH {
            let data: [String: Any] = [
                "bank_account_number": downPaymentInputObject?.checkValue?
                    .accountNumber ?? "",
                "bank_routing_number": downPaymentInputObject?.checkValue?
                    .routingNumber ?? "",
                "acct_type": selectedAcctType,
            ]
            let paymentOption = self.getPaymentOptionAndValues(
                payment_method: "ach",
                paymentOptionDict: data
            )
            print(paymentOption)
            self.savePaymentMethodTypeToAppointmentDetail(
                paymentType: paymentOption.nsDictionary
            )
        }
    }

    func DownPaymentcalucaltion() -> DownPaymentCalculationValue {

        let downValue =
            (Double(persentageValue) / 100)
            * (QuotationPaymentPlanValueDetails.total_amount ?? 0)

        return DownPaymentCalculationValue(
            balance: (QuotationPaymentPlanValueDetails.total_amount ?? 0)
                - downValue,
            downPayment: downValue
        )
    }

    @objc func datepickerSalection(_ sender: UITextField) {

        datePicker.backgroundColor = UIColor.init(
            red: 40 / 255,
            green: 59 / 255,
            blue: 79 / 255,
            alpha: 1
        )
        datePicker.tintColor = UIColor.white
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")

        //ToolBar
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(donedateDatePicker)
        )
        doneButton.tintColor = .white
        let spaceButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
            target: nil,
            action: nil
        )
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelDatePicker)
        )
        cancelButton.tintColor = .white

        toolbar.setItems(
            [doneButton, spaceButton, cancelButton],
            animated: false
        )
        sender.inputAccessoryView = toolbar
        sender.inputView?.backgroundColor = UIColor.init(
            red: 40 / 255,
            green: 59 / 255,
            blue: 79 / 255,
            alpha: 1
        )
        sender.inputView = datePicker
        let monthInt = Calendar.current.component(.month, from: Date())
        let currentyear = Calendar.current.component(.year, from: Date())
        if let cell = self.paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromCardCollectionViewCell
        {
            self.datePicker.onDateSelected = { (month: Int, year: Int) in
                if month < monthInt && currentyear == year {
                    self.alert("The card entered is expired", .none)
                } else {
                    let string = String(format: "%02d/%d", month, year)
                    cell.cardExperyDateTF.text = string

                    NSLog(string)
                }  // should show something like 05/2015
            }

        }

    }
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    @objc func donedateDatePicker() {

        if let cell = self.paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromCardCollectionViewCell
        {
            let month = self.datePicker.month
            let year = self.datePicker.year
            let monthInt = Calendar.current.component(.month, from: Date())
            let currentyear = Calendar.current.component(.year, from: Date())
            if month < monthInt && currentyear == year {
                self.alert("The card entered is expired", .none)
            } else {

                let string = String(format: "%02d/%d", month, year)
                cell.cardExperyDateTF.text = string
            }
            self.view.endEditing(true)
        }
    }

    /*
    func PayCardsRecognizerDidRecive(the result: PayCardsRecognizerResult) {
        if let cell = self.paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromCardCollectionViewCell
        {
            cell.accountHolderNameTF.text = result.recognizedHolderName ?? ""
            cell.cardNumberTF.text = result.recognizedNumber ?? ""
            if let year = result.recognizedExpireDateYear {
                if let month = result.recognizedExpireDateMonth {
                    cell.cardExperyDateTF.text = month + "/" + year
                }
            }
        }
    }
    */

    override func screenShotBarButtonAction(sender: UIButton) {
        self.imagePicker = CaptureImage(
            presentationController: self,
            delegate: self
        )
        self.imagePicker.present(from: sender)

    }

    func imageUploadScreenShot(_ image: UIImage, _ name: String) {
        HttpClientManager.SharedHM.AttachmentScreenShotsFn(image, name) {
            (success, message, value) in
            if (success ?? "") == "Success" {

                self.alert(message ?? "", nil)
            } else if (success ?? "") == "AuthFailed"
                || ((success ?? "") == "authfailed")
            {

                let yes = UIAlertAction(title: "OK", style: .default) { (_) in

                    self.fourceLogOutbuttonAction()
                }

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes]
                )

            } else {
                let yes = UIAlertAction(title: "Retry", style: .default) {
                    (_) in

                    self.imageUploadScreenShot(image, name)
                }
                let no = UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes, no]
                )

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

    func paymentTransactionCashApi(
        isOnJobCompleation: Bool,
        balancePaymentMethord: String
    ) {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation
        let data: [String: Any] = [
            "order_id": orderID, "token": UserData.init().token ?? "",
        ]
        let parameter =
            ["token": UserData.init().token ?? "", "data": data]
            as [String: Any]

        HttpClientManager.SharedHM.PaymentRequestAPi(parameter: parameter) {
            (success, message, value) in
            if (success ?? "") == "Success" {

                let web = DynamicContractViewController.initialization()!
                web.document = value ?? ""
                web.orderID = self.orderID
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "cash"
                self.navigationController?.pushViewController(
                    web,
                    animated: true
                )
            } else if (success ?? "") == "AuthFailed"
                || ((success ?? "") == "authfailed")
            {

                let yes = UIAlertAction(title: "OK", style: .default) { (_) in

                    self.fourceLogOutbuttonAction()
                }

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes]
                )

            } else {
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style: .default) {
                    (_) in

                    self.paymentTransactionCashApi(
                        isOnJobCompleation: self.globalIsJobCompletion,
                        balancePaymentMethord: self.globalPayBalanace
                    )
                }
                let no = UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes, no]
                )

                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }

    func paymentTransactionCreditCardApi(
        isOnJobCompleation: Bool,
        balancePaymentMethord: String
    ) {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation

        let data: [String: Any] = [
            "order_id": orderID, "token": UserData.init().token ?? "",
            "payment_method": "credit_card",
            "card_number": downPaymentInputObject?.cardPaymentValue?.cardNumber
                ?? "",
            "card_expiry": downPaymentInputObject?.cardPaymentValue?.experyDate
                ?? "",
            "card_holder_name": downPaymentInputObject?.cardPaymentValue?
                .accountName ?? "",
            "cardpin": downPaymentInputObject?.cardPaymentValue?.pinNumber
                ?? "",
        ]

        let parameter =
            ["token": UserData.init().token ?? "", "data": data]
            as [String: Any]

        HttpClientManager.SharedHM.PaymentRequestCardAPi(parameter: parameter) {
            (success, message, value) in
            if (success ?? "") == "Success" {
                let web = DynamicContractViewController.initialization()!
                web.document = value ?? ""
                web.orderID = self.orderID
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "card"
                self.navigationController?.pushViewController(
                    web,
                    animated: true
                )
            } else if (success ?? "") == "AuthFailed"
                || ((success ?? "") == "authfailed")
            {

                let yes = UIAlertAction(title: "OK", style: .default) { (_) in

                    self.fourceLogOutbuttonAction()
                }

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes]
                )

            } else {
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style: .default) {
                    (_) in

                    self.paymentTransactionCashApi(
                        isOnJobCompleation: self.globalIsJobCompletion,
                        balancePaymentMethord: self.globalPayBalanace
                    )
                }
                let no = UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes, no]
                )

                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }

    func paymentTransactionDebitCardApi(
        isOnJobCompleation: Bool,
        balancePaymentMethord: String
    ) {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation

        let data: [String: Any] = [
            "order_id": orderID, "token": UserData.init().token ?? "",
            "payment_method": "credit_card",
            "card_number": downPaymentInputObject?.cardPaymentValue?.cardNumber
                ?? "",
            "card_expiry": downPaymentInputObject?.cardPaymentValue?.experyDate
                ?? "",
            "card_holder_name": downPaymentInputObject?.cardPaymentValue?
                .accountName ?? "",
            "cardpin": downPaymentInputObject?.cardPaymentValue?.pinNumber
                ?? "",
        ]

        let parameter =
            ["token": UserData.init().token ?? "", "data": data]
            as [String: Any]

        HttpClientManager.SharedHM.PaymentRequestCardAPi(parameter: parameter) {
            (success, message, value) in
            if (success ?? "") == "Success" {
                let web = DynamicContractViewController.initialization()!
                web.document = value ?? ""
                web.orderID = self.orderID
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "card"
                self.navigationController?.pushViewController(
                    web,
                    animated: true
                )
            } else if (success ?? "") == "AuthFailed"
                || ((success ?? "") == "authfailed")
            {

                let yes = UIAlertAction(title: "OK", style: .default) { (_) in

                    self.fourceLogOutbuttonAction()
                }

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes]
                )

            } else {
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style: .default) {
                    (_) in

                    self.paymentTransactionCashApi(
                        isOnJobCompleation: self.globalIsJobCompletion,
                        balancePaymentMethord: self.globalPayBalanace
                    )
                }
                let no = UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes, no]
                )
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }

    func paymentTransactionCheckApi(
        isOnJobCompleation: Bool,
        balancePaymentMethord: String
    ) {
        self.globalPayBalanace = balancePaymentMethord
        self.globalIsJobCompletion = isOnJobCompleation

        let data: [String: Any] = [
            "order_id": orderID, "token": UserData.init().token ?? "",
            "payment_method": "check",
            "check_number": downPaymentInputObject?.checkValue?.checkNumber
                ?? "",
            "check_account_number": downPaymentInputObject?.checkValue?
                .accountNumber ?? "",
            "check_routing_number": downPaymentInputObject?.checkValue?
                .routingNumber ?? "",
        ]

        let parameter =
            ["token": UserData.init().token ?? "", "data": data]
            as [String: Any]

        HttpClientManager.SharedHM.PaymentRequestCheckAPi(parameter: parameter)
        { (success, message, value) in
            if (success ?? "") == "Success" {
                let web = DynamicContractViewController.initialization()!
                web.document = value ?? ""
                web.orderID = self.orderID
                web.downPayment = self.DownPaymentcalucaltion().downPayment
                web.paymentType = "check"
                self.navigationController?.pushViewController(
                    web,
                    animated: true
                )
            } else if (success ?? "") == "AuthFailed"
                || ((success ?? "") == "authfailed")
            {

                let yes = UIAlertAction(title: "OK", style: .default) { (_) in

                    self.fourceLogOutbuttonAction()
                }

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes]
                )

            } else {
                // self.performSegueToReturnBack()
                let yes = UIAlertAction(title: "Retry", style: .default) {
                    (_) in

                    self.paymentTransactionCashApi(
                        isOnJobCompleation: self.globalIsJobCompletion,
                        balancePaymentMethord: self.globalPayBalanace
                    )
                }
                let no = UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )

                self.alert(
                    (message ?? message) ?? AppAlertMsg.serverNotReached,
                    [yes, no]
                )

                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }

}

class DownPaymentCalculationValue {
    var balance: Double
    var downPayment: Double
    init(balance: Double, downPayment: Double) {
        self.balance = balance

        self.downPayment = downPayment
    }
}
class DownPaymentInputObject: NSObject {
    var paymentType: PaymentType
    var cardPaymentValue: CardPaymentValue?
    var checkValue: CheckValue?
    init(
        paymentType: PaymentType,
        cardPaymentValue: CardPaymentValue?,
        checkValue: CheckValue?
    ) {
        self.paymentType = paymentType
        self.cardPaymentValue = cardPaymentValue
        self.checkValue = checkValue
    }

}
class CardPaymentValue: NSObject {
    var accountName: String
    var cardNumber: String
    var experyDate: String
    var pinNumber: String
    var isPayLtr: Bool = false
    init(
        accountName: String,
        cardNumber: String,
        experyDate: String,
        pinNumber: String,
        isPayLtr: Bool
    ) {
        self.accountName = accountName
        self.cardNumber = cardNumber
        self.experyDate = experyDate
        self.pinNumber = pinNumber
        self.isPayLtr = isPayLtr
    }
}
class CheckValue: NSObject {
    var checkNumber: String
    var accountNumber: String
    var routingNumber: String
    init(checkNumber: String, accountNumber: String, routingNumber: String) {
        self.checkNumber = checkNumber
        self.accountNumber = accountNumber
        self.routingNumber = routingNumber
    }
}

class DownPaymentSelectionObj: NSObject {
    var paymentType: PaymentType
    var lable: UILabel
    var view: UIView
    var button: UIButton
    var tag: Int
    init(
        paymentType: PaymentType,
        lable: UILabel,
        view: UIView,
        button: UIButton,
        tag: Int
    ) {
        self.paymentType = paymentType
        self.lable = lable
        self.view = view
        self.button = button
        self.button.tag = tag
        self.tag = tag
    }
}
// MARK: - Account Type Dropdown (shared by Check and ACH)
extension DownPaymentViewController: DropDownDelegate {

    @objc func showAcctTypeDropdown() {
        var anchorButton: UIButton?
        if paymentType == .Check,
            let cell = paymentCollectionView.cellForItem(at: [0, 0])
                as? DownPaymentFromCheckCollectionViewCell
        {
            anchorButton = cell.acctTypeButton
        } else if paymentType == .ACH,
            let cell = paymentCollectionView.cellForItem(at: [0, 0])
                as? DownPaymentFromACHCollectionViewCell
        {
            anchorButton = cell.acctTypeButton
        }
        guard let button = anchorButton else { return }
        self.DropDownDefaultfunction(
            button,
            button.bounds.width,
            ["Checking", "Savings"],
            -1,
            delegate: self,
            tag: 99
        )
    }

    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        if tag == 99 {
            selectedAcctType = index == 0 ? "ECHK" : "ESAV"
            selectedAcctTypeLabel = item
            // Update only the button title — do NOT call reloadData() as it would
            // re-run collectionViewConfigruation() and wipe the user's entered field values
            if paymentType == .Check,
                let cell = paymentCollectionView.cellForItem(at: [0, 0])
                    as? DownPaymentFromCheckCollectionViewCell
            {
                cell.acctTypeButton.setTitle(item + " ▼", for: .normal)
            } else if paymentType == .ACH,
                let cell = paymentCollectionView.cellForItem(at: [0, 0])
                    as? DownPaymentFromACHCollectionViewCell
            {
                cell.acctTypeLabel.text = item
            }
        }
    }
}

extension DownPaymentViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?, imageName: String?) {
        guard let image = image

        else {
            return
        }
        let imageNameStr = Date().toString()
        let name = "Snapshot" + String(imageNameStr) + ".JPG"
        let snapShotImageName = ImageSaveToDirectory.SharedImage
            .saveImageDocumentDirectory(rfImage: image, saveImgName: name)
        let appointmentId = AppointmentData().appointment_id ?? 0
        _ = self.saveSnapshotImage(
            savedImageName: snapShotImageName,
            appointmentId: appointmentId
        )
        //self.imageUploadScreenShot(image,imageName ?? name)

    }
}
enum PaymentType {
    case Cash
    case Check
    case DebitCard
    case CreditCard
    case ACH
}
struct PaymentDetails: Codable {
    var card_Number: String?
    var card_Expiry: String?
    var card_Holder_Name: String?
    var card_Pin: String?
    var chek_Number: String?
    var check_Account_Number: String?
    var check_Routing_Number: String?

}
struct Payload: Codable {
    var sub: String?
    var name: String?
    var iat: Int?
}
struct paymentOptionUser: Codable {
    var payment_Method: String?
    var paymentDetails: PaymentDetails?

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
        return
            (try? JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments
            )).flatMap { $0 as? [String: Any] }
    }

    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard
            let dictionary = try JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments
            ) as? [String: Any]
        else {
            throw NSError()
        }
        return dictionary
    }
}

extension String {

    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(
            CCHmacAlgorithm(kCCHmacAlgSHA256),
            key,
            key.count,
            self,
            self.count,
            &digest
        )
        let data = Data.init(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false)
        else { return nil }
        return try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
        )
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

    var nonConformingFloatDecodingStrategy:
        JSONDecoder.NonConformingFloatDecodingStrategy
    {
        set { decoder.nonConformingFloatDecodingStrategy = newValue }
        get { return decoder.nonConformingFloatDecodingStrategy }
    }

    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        set { decoder.keyDecodingStrategy = newValue }
        get { return decoder.keyDecodingStrategy }
    }

    func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T
    where T: Decodable {
        let data = try JSONSerialization.data(
            withJSONObject: dictionary,
            options: []
        )
        return try decoder.decode(type, from: data)
    }
}

extension DownPaymentViewController {

    // MARK: - Credit Card / Debit Card Scan
    // Wired in cellForItemAt via:
    //   cell.cardScanButton.addTarget(self, action: #selector(cardScanner), for: .touchUpInside)

    @objc func cardScanner() {

        isOCR = true

        // Force landscape
        if #available(iOS 16.0, *) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene
            else { return }

            let preferences = UIWindowScene.GeometryPreferences.iOS(
                interfaceOrientations: .landscape
            )

            windowScene.requestGeometryUpdate(preferences)
        } else {
            UIDevice.current.setValue(
                UIInterfaceOrientation.landscapeRight.rawValue,
                forKey: "orientation"
            )
            UIViewController.attemptRotationToDeviceOrientation()
        }

        let scannerView = CreditCardScannerView { [weak self] cardData in
            guard let self else { return }

            self.isOCR = false

            // Return back to portrait if needed
            self.rotateBackToPortrait()

            self.applyCardScanResult(cardData)
        }

        let hostVC = RotatableHostingController(rootView: scannerView)
        hostVC.modalPresentationStyle = .fullScreen

        present(hostVC, animated: true)
    }

    private func rotateBackToPortrait() {

        if #available(iOS 16.0, *) {

            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene
            else { return }

            let preferences = UIWindowScene.GeometryPreferences.iOS(
                interfaceOrientations: .portrait
            )

            windowScene.requestGeometryUpdate(preferences)

        } else {

            UIDevice.current.setValue(
                UIInterfaceOrientation.portrait.rawValue,
                forKey: "orientation"
            )

            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    private func applyCardScanResult(_ data: CardData) {
        guard !data.number.isEmpty || !data.name.isEmpty || !data.expiry.isEmpty
        else { return }

        // Store on VC so values survive any future reloadData
        if !data.number.isEmpty { self.cardNumber = data.number }
        if !data.name.isEmpty { self.accountHolderName = data.name }
        if !data.expiry.isEmpty { self.cardExpiry = data.expiry }

        // Paste directly into the live cell
        if let cell = paymentCollectionView.cellForItem(at: [0, 0])
            as? DownPaymentFromCardCollectionViewCell
        {
            if !data.number.isEmpty { cell.cardNumberTF.text = data.number }
            if !data.name.isEmpty { cell.accountHolderNameTF.text = data.name }
            if !data.expiry.isEmpty { cell.cardExperyDateTF.text = data.expiry }
        }
    }

    // MARK: - ACH / Check Scan
    // Wired in cellForItemAt via:
    //   ACH   cell → cell.oCRCameraBtn.addTarget(self, action: #selector(autoReadOCRForCheck), ...)
    //   Check cell → cell.cameraButton.addTarget(self, action: #selector(autoReadOCRForCheck), ...)

    @objc func autoReadOCRForCheck() {

        // Prevents viewWillAppear from resetting the selected tab when the scanner dismisses.
        isOCR = true

        // Force landscape before presenting scanner
        if #available(iOS 16.0, *) {

            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene
            else {
                return
            }

            let preferences = UIWindowScene.GeometryPreferences.iOS(
                interfaceOrientations: .landscape
            )

            windowScene.requestGeometryUpdate(preferences)

        } else {

            UIDevice.current.setValue(
                UIInterfaceOrientation.landscapeRight.rawValue,
                forKey: "orientation"
            )

            UIViewController.attemptRotationToDeviceOrientation()
        }

        let scannerView = ChequeScannerView { [weak self] chequeData in

            guard let self else { return }

            self.isOCR = false

            // Return back to portrait after dismiss
            self.rotateBackToPortrait()

            self.applyChequeOrACHScanResult(chequeData)
        }

        let hostVC = RotatableHostingController(rootView: scannerView)
        hostVC.modalPresentationStyle = .fullScreen

        present(hostVC, animated: true)
    }

    private func applyChequeOrACHScanResult(_ data: ChequeData) {
        guard
            !data.routing.isEmpty || !data.account.isEmpty
                || !data.checkNumber.isEmpty
        else { return }

        // Store on VC
        if !data.routing.isEmpty { self.routingNumber = data.routing }
        if !data.account.isEmpty { self.accountNumber = data.account }
        if !data.checkNumber.isEmpty { self.checkNumber = data.checkNumber }

        if paymentType == .ACH {
            // outlet name confirmed: oCRCameraBtn, bankAccountNumberTF, bankRoutingNumberTF
            if let cell = paymentCollectionView.cellForItem(at: [0, 0])
                as? DownPaymentFromACHCollectionViewCell
            {
                if !data.account.isEmpty {
                    cell.bankAccountNumberTF.text = data.account
                }
                if !data.routing.isEmpty {
                    cell.bankRoutingNumberTF.text = data.routing
                }
            }
        } else {
            // Check cell: outlet names confirmed: cameraButton, accountNumberTF, routingNumberTF, checkNumberTF
            if let cell = paymentCollectionView.cellForItem(at: [0, 0])
                as? DownPaymentFromCheckCollectionViewCell
            {
                if !data.account.isEmpty {
                    cell.accountNumberTF.text = data.account
                }
                if !data.routing.isEmpty {
                    cell.routingNumberTF.text = data.routing
                }
                if !data.checkNumber.isEmpty {
                    cell.checkNumberTF.text = data.checkNumber
                }
            }
        }
    }
}
