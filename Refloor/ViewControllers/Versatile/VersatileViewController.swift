//
//  VersatileViewController.swift
//  Refloor
//
//  Created by Bincy C A on 04/12/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit
import WebKit

protocol backToCreditApplicationProtocol
{
    func backToCreditApplication(isVersatile:Bool)
}

class VersatileViewController: UIViewController, ImagePickerDelegate, versatileBackprotocol,CreditApplicationProtocol
{
   
    
    func creditApplicationCall(isVersatile: Bool)
    {
        creditApplicationDelegate?.creditApplicationCall(isVersatile: isVersatile)
    }
    
    func whetherToProceedBack()
    {
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.isVersatile {
//    self.alert("Unsuccessful due to incomplete compliance training", nil)
                //Q3 changes
                print("inside whetherToProceedBack")
                // Create the alert
                let alert = UIAlertController(
                    title: "Error!",
                    message: "Application was unsuccessful due to incomplete compliance training.",
                    preferredStyle: .alert
                )
                // Add the "OK" action button
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                // Present the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
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
//self.imageUploadScreenShot(image,imageName ?? name)
    }
    
    static public func initialization() -> VersatileViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "VersatileViewController") as? VersatileViewController
    }

    @IBOutlet weak var versatileWebView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var url:String = String()
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
    var isCoAppSkiped = 0
    var appointmentId:Int = Int()
    var imagePicker: CaptureImage!
    var isVersatile = false
    var isHunter = false
    var creditApplicationDelegate:CreditApplicationProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        if isVersatile
        {
            self.setNavigationBarbackAndlogo(with: "Versatile Credit")
        }
        else
        {
            self.setNavigationBarbackAndlogo(with: "Credit Card Rate Lending")
        }
        
        sendRequest(urlString: url)
        versatileWebView.navigationDelegate = self
        
//        let parameter : [String:Any] = ["appointment_id":appointmentId,"loan_type":"versatile"]
//        HttpClientManager.SharedHM.versatileStatusAPi(parameter: parameter) {
//            success, data in
//        }
        // Do any additional setup after loading the view.
    }
    
    override func performSegueToReturnBack()
    {
        let selectRoomPopUp = SelectRoomCommentPopUpViewController.initialization()!
        selectRoomPopUp.versatileBack = self
        selectRoomPopUp.isVersatile = false
        selectRoomPopUp.isVersaileBack = isVersatile
        selectRoomPopUp.isHunterBack = isHunter
        selectRoomPopUp.isdelete = false
        self.present(selectRoomPopUp, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    private func sendRequest(urlString: String)
    {
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        versatileWebView.load(myRequest)
    }
    fileprivate func showActivityIndicator(show: Bool) {
          if show {
              //activityIndicator.addSubview(self.view)
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
          } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            //activityIndicator.removeFromSuperview()
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

    

}

extension VersatileViewController:WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.showActivityIndicator(show: false)
      }
      func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
   
            self.showActivityIndicator(show: true)
    
      }
      func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showActivityIndicator(show: false)
          self.alert(error.localizedDescription, nil)
        
        
      }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        self.showActivityIndicator(show: false)
        self.alert(error.localizedDescription, nil)
        if let urlError = error as? URLError {
               webView.loadHTMLString(urlError.localizedDescription, baseURL: urlError.failingURL)
           } else {
               webView.loadHTMLString(error.localizedDescription, baseURL: URL(string: "data:text/html"))
           }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        let redirectURL:URL = URL(string: "https://versatilecredit.com/landingpage")!
        let hunterRedirectURL:URL = URL(string: "https://www.hunterfinancial.com/")!
            if(navigationAction.navigationType == .other) {
                if navigationAction.request.url == redirectURL || navigationAction.request.url == hunterRedirectURL {
                    if isVersatile
                    {
                        let parameter : [String:Any] = ["appointment_id":appointmentId,"loan_type":"versatile","improveit_appointment_id":AppDelegate.appoinmentslData.improveit_appointment_id ?? ""]
                        HttpClientManager.SharedHM.versatileStatusAPi(parameter: parameter) {
                        success, message, data in
                        
                        if success == "Success" || success == "Failed"
                        {
                            let versatileSuccess = InstallerSuccessViewController.initialization()!
                            versatileSuccess.creditApplication = self
                            versatileSuccess.isVersatile = true
                            versatileSuccess.downOrFinal = self.downOrFinal
                            versatileSuccess.totalAmount = self.totalAmount
                            versatileSuccess.paymentPlan = self.paymentPlan
                            versatileSuccess.paymentPlanValue = self.paymentPlanValue
                            versatileSuccess.paymentOptionDataValue = self.paymentOptionDataValue
                            versatileSuccess.drowingImageID = self.drowingImageID
                            versatileSuccess.area = self.area
                            versatileSuccess.downPaymentValue = self.downPaymentValue
                            versatileSuccess.finalpayment = self.finalpayment
                            versatileSuccess.financePayment = self.financePayment
                            versatileSuccess.selectedPaymentMethord = self.selectedPaymentMethord
                            versatileSuccess.downpayment = self.downpayment
                            versatileSuccess.loanProvider = data?.provider ?? ""
                            versatileSuccess.refernceNumber = data?.providerRefrence ?? ""
                            versatileSuccess.approvedAmount = String(data?.approvedAmount ?? 0.0 )
                            versatileSuccess.status = data?.status ?? ""
                            versatileSuccess.successMsg = success!
                            if let customer = AppDelegate.appoinmentslData
                            {
                                versatileSuccess.isCoAppSkiped = customer.co_applicant_skipped ?? 0
                            }
                            self.navigationController?.pushViewController(versatileSuccess, animated: true)
                        }
                        
                        
                    }
                }
                    else if isHunter
                    {
                        let parameter : [String:Any] = ["appointment_id":appointmentId,"loan_type":"hunter","improveit_appointment_id":AppDelegate.appoinmentslData.improveit_appointment_id ?? ""]
                        HttpClientManager.SharedHM.versatileStatusAPi(parameter: parameter) {
                        success, message, data in
                        
                        if success == "Success" || success == "Failed"
                            {
                            if success == "Failed" && message == "Credit application is not existing"
                            {
                                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                                    self.navigationController?.popViewController(animated: true)
                                }
                                self.alert(message ?? "", [yes])
                                
                                //self.alert(message!, nil)
                            }
                            else
                            {
                                let versatileSuccess = InstallerSuccessViewController.initialization()!
                                versatileSuccess.isHunter = true
                                versatileSuccess.creditApplication = self
                                versatileSuccess.downOrFinal = self.downOrFinal
                                versatileSuccess.totalAmount = self.totalAmount
                                versatileSuccess.paymentPlan = self.paymentPlan
                                versatileSuccess.paymentPlanValue = self.paymentPlanValue
                                versatileSuccess.paymentOptionDataValue = self.paymentOptionDataValue
                                versatileSuccess.drowingImageID = self.drowingImageID
                                versatileSuccess.area = self.area
                                versatileSuccess.downPaymentValue = self.downPaymentValue
                                versatileSuccess.finalpayment = self.finalpayment
                                versatileSuccess.financePayment = self.financePayment
                                versatileSuccess.selectedPaymentMethord = self.selectedPaymentMethord
                                versatileSuccess.downpayment = self.downpayment
                                versatileSuccess.loanProvider = data?.provider ?? ""
                                versatileSuccess.refernceNumber = data?.providerRefrence ?? ""
                                versatileSuccess.approvedAmount = String(data?.approvedAmount ?? 0.0 )
                                
                                versatileSuccess.status = data?.status ?? ""
                                versatileSuccess.successMsg = success!
                                if let customer = AppDelegate.appoinmentslData
                                {
                                    versatileSuccess.isCoAppSkiped = customer.co_applicant_skipped ?? 0
                                }
                                self.navigationController?.pushViewController(versatileSuccess, animated: true)
                            }
                        }
                        
                        
                    }
                    }
                   
                }
                decisionHandler(.allow)
                return
            }
            decisionHandler(.allow)
        }
}
