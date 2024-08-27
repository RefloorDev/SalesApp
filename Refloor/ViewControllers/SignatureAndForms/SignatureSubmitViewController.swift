//
//  SignatureSubmitViewController.swift
//  Refloor
//
//  Created by sbek on 14/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SignatureSubmitViewController: UIViewController,SignSignatureDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    
    static public func initialization() -> SignatureSubmitViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SignatureSubmitViewController") as? SignatureSubmitViewController
    }
    @IBOutlet weak var collectionView: UICollectionView!
    var image:UIImage?
    var initailImage:UIImage?
    var coImage:UIImage?
    var coinitailImage:UIImage?
    var isApplicantImage = true
    var isInitial = false
    
    var names = ["Contract","Finance Application","Credit Card"]
    @IBOutlet weak var applicantBGView: UIView!
    @IBOutlet weak var applicantInitialBGView: UIView!
    @IBOutlet weak var co_ApplicantView: UIImageView!
    @IBOutlet weak var applicantView: UIImageView!
    @IBOutlet weak var applicantInitial: UIImageView!
    @IBOutlet weak var coApplicantInitial: UIImageView!
    @IBOutlet weak var coApplicanView: UIView!
    @IBOutlet weak var coApplicanInitialView: UIView!
    
    
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
    var isCoAppSkiped = 0
    var imagePicker: CaptureImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "Signature".uppercased())
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(applicantImageViewAction))
        tap1.numberOfTapsRequired = 1
        applicantView.addGestureRecognizer(tap1)
        applicantView.isUserInteractionEnabled = true
        let tap11 = UITapGestureRecognizer(target: self, action: #selector(applicantInitialImageViewAction))
        tap11.numberOfTapsRequired = 1
        applicantInitial.addGestureRecognizer(tap11)
        applicantInitial.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(coapplicantImageViewAction))
        tap2.numberOfTapsRequired = 1
        co_ApplicantView.addGestureRecognizer(tap2)
        
        
        let tap21 = UITapGestureRecognizer(target: self, action: #selector(coapplicantInitialImageViewAction))
        tap21.numberOfTapsRequired = 1
        coApplicantInitial.addGestureRecognizer(tap21)
        coApplicantInitial.isUserInteractionEnabled = true
        co_ApplicantView.isUserInteractionEnabled = true
        if(isCoAppSkiped == 1)
        {
            
            coApplicanView.isHidden = true
            coApplicanInitialView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.deleteCoApplicantSignatureAndInitialsFromAppointmentDetail()
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if(validation() != "")
        {
            self.alert(validation(), nil)
            return
        }
        
        else
        {
            if(isCoAppSkiped == 1)
            {
                let imageNameStr = Date().toString()
                var image_name =  "ApplicantSignature" +  String(imageNameStr) + ".JPG"
                let applicantSignature = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: self.image!, saveImgName: image_name)
                self.saveApplicantOrCoApplicantSignatureAndInitials(isApplicant: true, isSignature: true, fileName: applicantSignature)
                image_name =  "ApplicantInitial" +  String(imageNameStr) + ".JPG"
                let applicantInitials = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: self.initailImage!, saveImgName: image_name)
                self.saveApplicantOrCoApplicantSignatureAndInitials(isApplicant: true, isSignature: false, fileName: applicantInitials)
            
            }
            else
            {
                let imageNameStr = Date().toString()
                var image_name =  "ApplicantSignature" +  String(imageNameStr) + ".JPG"
                let applicantSignature = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: self.image!, saveImgName: image_name)
                self.saveApplicantOrCoApplicantSignatureAndInitials(isApplicant: true, isSignature: true, fileName: applicantSignature)
                image_name =  "ApplicantInitial" +  String(imageNameStr) + ".JPG"
                let applicantInitials = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: self.initailImage!, saveImgName: image_name)
                self.saveApplicantOrCoApplicantSignatureAndInitials(isApplicant: true, isSignature: false, fileName: applicantInitials)
                
                
                image_name =  "CoApplicantSignature" +  String(imageNameStr) + ".JPG"
                let coApplicantSignature = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: self.coImage!, saveImgName: image_name)
                self.saveApplicantOrCoApplicantSignatureAndInitials(isApplicant: false, isSignature: true, fileName: coApplicantSignature)
                image_name =  "CoApplicantInitial" +  String(imageNameStr) + ".JPG"
                let coApplicantInitials = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: self.coinitailImage!, saveImgName: image_name)
                self.saveApplicantOrCoApplicantSignatureAndInitials(isApplicant: false, isSignature: false, fileName: coApplicantInitials)
            }
            self.downpayment.downOrFinal = self.downOrFinal
            self.downpayment.totalAmount =  self.totalAmount
            self.downpayment.downPaymentValue =  self.downPaymentValue
            self.downpayment.finalpayment =  self.finalpayment
            self.downpayment.financePayment =  self.financePayment
            //arb
            let appointmentId = AppointmentData().appointment_id ?? 0
            let currentClassName = String(describing: type(of: self))
            let classDisplayName = "Signature"
            self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
            //
            if(self.downpayment.financePayment != 0)
            {
//                self.getCreditFormPdf()
                if(self.downPaymentValue != 0)
                {
                    self.navigationController?.pushViewController(self.downpayment, animated: true)
                }
                else
                {
                    let cancel = AppointmentSummaryViewController.initialization()!
                   // web.document=value ?? ""
                    cancel.orderID=self.downpayment.orderID
                    cancel.downPayment = self.downPaymentValue //self.downpayment.DownPaymentcalucaltion().downPayment
                    cancel.total = self.totalAmount
                    cancel.balance = self.totalAmount - self.downPaymentValue
                    cancel.finalPayment =  self.finalpayment
                    cancel.financeAmount =  self.financePayment
                    if self.totalAmount == self.financePayment{
                        cancel.paymentType = "finance"
                    }
                    //arb
                    if self.financePayment > 0{
                        cancel.paymentType = "finance"
                    }
                    //
                    self.navigationController?.pushViewController(cancel, animated: true)
                }
            }
            else
            {
                self.navigationController?.pushViewController(self.downpayment, animated: true)
            }
            //signatureSubmitApi()
        }
    }
    
    
    func validation() -> String
    {
        
        
        if(isCoAppSkiped == 1)
        {
            if(self.image == nil || self.initailImage == nil)
            {
                return "Please capture applicant signature and Initials"
            }
        }
        else
        {
            if(self.image == nil || self.initailImage == nil)
            {
                return "Please capture applicant signature and Initials"
            }
            
            if(self.coImage == nil || self.coinitailImage == nil)
            {
                return "Please capture Co-applicant signature and Co-applicant Initials"
            }
            
        }
        
        
        return ""
        
    }
    
    @objc func applicantInitialImageViewAction()
    {
        isApplicantImage = true
        self.isInitial = true
        let sign = SignViewController.initialization()!
        sign.delegate = self
        sign.signatureName = "Applicant Initials  "
        sign.signatureNotetxt = "(Please make your initials as large as possible)"
        self.present(sign, animated: true, completion: nil)
    }
    @objc func coapplicantInitialImageViewAction()
    {
        isApplicantImage = false
        self.isInitial = true
        let sign = SignViewController.initialization()!
        sign.delegate = self
        sign.signatureName = "Co-Applicant Initials  "
        sign.signatureNotetxt = "(Please make your initials as large as possible)"
        self.present(sign, animated: true, completion: nil)
    }
    
    @objc func applicantImageViewAction()
    {
        isApplicantImage = true
        self.isInitial = false
        let sign = SignViewController.initialization()!
        sign.delegate = self
        sign.signatureName = "Applicant Signature  "
        sign.signatureNotetxt = "(Please make your signature as large as possible)"
        self.present(sign, animated: true, completion: nil)
    }
    @objc func coapplicantImageViewAction()
    {
        isApplicantImage = false
        self.isInitial = false
        let sign = SignViewController.initialization()!
        sign.delegate = self
        sign.signatureName = "Co-Applicant Signature  "
        sign.signatureNotetxt = "(Please make your signature as large as possible)"
        self.present(sign, animated: true, completion: nil)
    }
    
    func signatureSubmitApi()
    {
        HttpClientManager.SharedHM.SignatureMapingpFn(self.image ?? UIImage(), self.coImage, credit_card: "True", finance_application: "True", contract: "True", appointment_id:"\(AppDelegate.appoinmentslData.id ?? 0)", applicant_initial: self.initailImage, coapplicant_initial: self.coinitailImage) { (result, message, data) in
            if(result ?? "false").uppercased() == "TRUE" || (result ?? "false").uppercased() == "SUCCESS"
            {
                self.downpayment.downOrFinal = self.downOrFinal
                self.downpayment.totalAmount =  self.totalAmount
                self.downpayment.downPaymentValue =  self.downPaymentValue
                self.downpayment.finalpayment =  self.finalpayment
                self.downpayment.financePayment =  self.financePayment
                
                if(self.downpayment.financePayment != 0)
                {
                    self.getCreditFormPdf()
                }
                else
                {
                    self.navigationController?.pushViewController(self.downpayment, animated: true)
                }
                
            }
            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.signatureSubmitApi()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func SignSignatureDidGetImage(with image: UIImage) {
        if isApplicantImage
        {
            if(!isInitial)
            {
                self.image = image
                applicantView.image = image
                applicantBGView.backgroundColor = UIColor.white
            }
            else
            {
                self.initailImage = image
                self.applicantInitial.image = image
                applicantInitialBGView.backgroundColor = UIColor.white
            }
            
            
        }
        else
        {
            if(!isInitial)
            {
                self.coImage = image
                self.co_ApplicantView.image = image
                coApplicanView.backgroundColor = UIColor.white
            }
            else
            {
                self.coinitailImage = image
                self.coApplicantInitial.image = image
                coApplicanInitialView.backgroundColor = UIColor.white
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 69)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return names.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentMethorInDownPaymentCollectionViewCell", for: indexPath) as! PaymentMethorInDownPaymentCollectionViewCell
        let name = names[indexPath.item]
        
        cell.nameLabel.text = name
        
        return cell
    }
    
    func getCreditFormPdf()
    {
        
        //  let data:[String:Any] = ["order_id":orderID ,"token":UserData.init().token ?? ""]
        let parameter = ["token":UserData.init().token ?? "","appointment_id":AppDelegate.appoinmentslData.id ?? 0] as [String : Any]
        
        HttpClientManager.SharedHM.CreateCreditApplicationPdf(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                if(self.downPaymentValue != 0)
                {
                    self.navigationController?.pushViewController(self.downpayment, animated: true)
                }
                else
                {
                    let cancel = AppointmentSummaryViewController.initialization()!
                    cancel.document=value ?? ""
                    cancel.orderID=self.downpayment.orderID
                    cancel.downPayment = self.downpayment.DownPaymentcalucaltion().downPayment
                    
                    self.navigationController?.pushViewController(cancel, animated: true)
                }
                //                 let web = WebViewViewController.initialization()!
                //                web.document=value ?? ""
                ////                web.orderID=self.orderID
                ////                 web.downPayment = self.DownPaymentcalucaltion().downPayment
                //                  self.navigationController?.pushViewController(web, animated: true)
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
                    
                    self.getCreditFormPdf()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func paymentTransactionCashApi()
    {
        
        let data:[String:Any] = ["order_id":self.downpayment.orderID ,"token":UserData.init().token ?? ""]
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        
        HttpClientManager.SharedHM.PaymentRequestAPi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                
                let web = DynamicContractViewController.initialization()!
                web.document=value ?? ""
                web.orderID=self.downpayment.orderID
                web.downPayment = self.downpayment.DownPaymentcalucaltion().downPayment
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
                    
                    self.paymentTransactionCashApi()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
                //  self.alert(message ?? AppAlertMsg.serverNotReached, nil)
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
    
}
extension SignatureSubmitViewController: ImagePickerDelegate {

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

