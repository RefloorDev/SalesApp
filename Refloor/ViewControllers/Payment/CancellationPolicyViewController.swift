//
//  CancellationPolicyViewController.swift
//  Refloor
//
//  Created by Bincy C A on 26/10/22.
//  Copyright © 2022 oneteamus. All rights reserved.
//

import UIKit

class CancellationPolicyViewController: UIViewController, ImagePickerDelegate {
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
    
    
    
    static func initialization() -> CancellationPolicyViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CancellationPolicyViewController") as? CancellationPolicyViewController
    }

    @IBOutlet weak var noticeOfCancellationLbl: UILabel!
    @IBOutlet weak var cancellationPolicyTerms: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelRadioBtn: UIButton!
    
    var downPayment:Double = 0
    var balance:Double = 0
    var total:Double = 0
    var paymentType = ""
    var isCardVerified:Bool = Bool()
    var cancelRadioBtnBool:Bool = false
    var orderID = 0
    var document = ""
    var recisionDate:String = String()
    var imagePicker: CaptureImage!
    var payment_TrasnsactionDict:[String:String] = [:]
    var area:Double = Double()
    var totalPrice:Double = Double()
    var finalPayment:Double = Double()
    var financeAmount:Double = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "CANCELLATION POLICY".uppercased())
        nextBtn.isUserInteractionEnabled = false
        //let masterData = self.getMasterDataFromDB()
        let today = Date().toString().recisionDate().DateFromStringForServer()
        if (UserDefaults.standard.value(forKey: "Recision_Date") as! String) != ""
        {
            let recison = UserDefaults.standard.value(forKey: "Recision_Date") as! String
            //self.recisionDate = masterData.resitionDate?.recisionDate().DateFromStringForServer() ?? ""
            self.recisionDate = recison.recisionDate().DateFromStringForServer() 
        }
        cancellationPolicyTerms.text = cancellationPolicyTerms.text! + self.recisionDate
        noticeOfCancellationLbl.text = noticeOfCancellationLbl.text! + " " + today
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    override func performSegueToReturnBack()
    {
        if isCardVerified == true || payment_TrasnsactionDict != [:]
        {
            self.alert("You can’t navigate back and change the payment option. ", nil)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePicker = CaptureImage(presentationController: self, delegate: self)
            self.imagePicker.present(from: sender)
            
        }
    

    @IBAction func cancelRadioBtnAction(_ sender: UIButton) {
        if !cancelRadioBtnBool
        {
            cancelRadioBtnBool = !cancelRadioBtnBool
            cancelRadioBtn.setImage(UIImage(named: "selectedRound"), for: .normal)
            nextBtn.isUserInteractionEnabled = true
            nextBtn.backgroundColor = UIColor().colorFromHexString("#292562")
            nextBtn.borderColor = UIColor().colorFromHexString("#A7B0BA")
            nextBtn.borderWidth = 1
            nextBtn.setTitleColor(.white, for: .normal)
        }
        else
            
        {
            //#586471
            cancelRadioBtnBool = !cancelRadioBtnBool
            nextBtn.backgroundColor = UIColor().colorFromHexString("#586471")
            nextBtn.borderColor = .clear
            nextBtn.borderWidth = 0
            nextBtn.isUserInteractionEnabled = false
            cancelRadioBtn.setImage(UIImage(named: ""), for: .normal)
            
            nextBtn.setTitleColor(UIColor().colorFromHexString("#252C35"), for: .normal)
        }
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) 
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "CancellationPolicy"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        if paymentType == "cash"
        {
            let web = DynamicContractViewController.initialization()!
            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //web.balance  = self.DownPaymentcalucaltion().balance
            web.downPayment = downPayment //self.downpayment.DownPaymentcalucaltion().downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "cash"
            web.isCardVerified = false
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
//            web.area = getTotalAdjustedAreaForAllRooms()
//            web.totalPrice = total
//            web.finalPayment = self.finalPayment
//            web.financeAmount = self.financeAmount
            self.navigationController?.pushViewController(web, animated: true)
        }
        else if self.paymentType == "check"
        {
            let web = AppointmentSummaryViewController.initialization()!
            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //web.balance  = self.DownPaymentcalucaltion().balance
            web.downPayment = downPayment //self.downpayment.DownPaymentcalucaltion().downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "check"
            web.isCardVerified = false
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            web.area = getTotalAdjustedAreaForAllRooms()
            web.totalPrice = totalPrice
            web.finalPayment = self.finalPayment
            web.financeAmount = self.financeAmount
            self.navigationController?.pushViewController(web, animated: true)
            
        }
        else if paymentType == "card"
        {
            let web = AppointmentSummaryViewController.initialization()!
            web.downPayment = downPayment //self.downpayment.DownPaymentcalucaltion().downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "card"
            web.isCardVerified = isCardVerified
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            web.area = getTotalAdjustedAreaForAllRooms()
            web.totalPrice = totalPrice
            web.finalPayment = self.finalPayment
            web.financeAmount = self.financeAmount
            self.navigationController?.pushViewController(web, animated: true)
        }
        else 
        {
            let web = AppointmentSummaryViewController.initialization()!
            web.document=document
            web.orderID=orderID
            web.downPayment = downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "finance"
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            web.area = getTotalAdjustedAreaForAllRooms()
            web.totalPrice = totalPrice
            web.finalPayment = self.finalPayment
            web.financeAmount = self.financeAmount
            self.navigationController?.pushViewController(web, animated: true)
        }
        
    }
    
}
