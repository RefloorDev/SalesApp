//
//  LoginViewController.swift
//  Refloor
//
//  Created by sbek on 16/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift


class LoginViewController: UIViewController {
    
    static func initialization() -> LoginViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
    }
    
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var hiddenStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var hiddenStackView: UIStackView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var versionNumber: UIButton!
    @IBOutlet weak var trainingCheckboxButton: UIButton!
    @IBOutlet weak var stagingCheckboxButton:UIButton!
    @IBOutlet weak var tapGesatureView: UIView!
    var isPasswordVisble = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenStackHeightConstraint.constant = 0
        stackViewBottomConstraint.constant = 0
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                     longPressGestureRecognizer.minimumPressDuration = 6.0 // Duration for the long press
        tapGesatureView.addGestureRecognizer(longPressGestureRecognizer)
        BASE_URL = AppURL().LIVE_BASE_URL
        self.setClearNavigationBar()
       
        //this will be triggered when all images from the master data is successfully downloaded and saved to DB
        NotificationCenter.default.addObserver(self, selector: #selector(self.masterDataInsertedSuccessfullyToDatabase(notification:)), name: Notification.Name("MasterDataComplete"), object: nil)
        self.navigationController?.viewControllers = [self]
        emailTF.setPlaceHolderWithColor(placeholder: "Email Address", colour: UIColor.placeHolderColor)
        passwordTF.setPlaceHolderWithColor(placeholder: "Password", colour: UIColor.placeHolderColor)
//        self.emailTF.textContentType = .emailAddress
//        self.emailTF.keyboardType = .emailAddress
//        passwordTF.textContentType = .password
            //  self.emailTF.text = "john@refloor.com"
        //  self.passwordTF.text = "api"
        //  self.emailTF.text = "mhigley@refloor.com"
        //  self.passwordTF.text = "SALESapp"
//        
//     self.emailTF.text = "bincy.aliyar@oneteamus.com" //vrenaud@refloor.com"
//     self.passwordTF.text = "Apps@021"
//        self.emailTF.text = "satheesh.nambiar@oneteamus.com"
//        self.passwordTF.text = "SALESapp"

        //just remove this.
//        self.emailTF.text = "vrenaud@refloor.com" //vrenaud@refloor.com"
//        self.passwordTF.text = "TESTAPP" //testAPP"
        
        if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        
            if BASE_URL == "https://odoostage.myx.ac/api/"
            {
                versionNumber.setTitle("Version: \(text) (1.0) - STAGE", for: .normal)
            }else{
                versionNumber.setTitle("Version: \(text)", for: .normal)
            }
            print(text)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                // Get the location of the long press
                let location = gesture.location(in: self.view)
                
                // Define the top left corner area (e.g., 100x100 points)
                //let topLeftCornerRect = CGRect(x: 0, y: 0, width: 100, height: 100)
                
                // Check if the long press is within the top left corner area
//                if topLeftCornerRect.contains(location) {
                    // Enable the button if the long press is within the specified area
                if hiddenStackView.isHidden
                {
                    hiddenStackView.isHidden = false
                    hiddenStackHeightConstraint.constant = 30
                    stackViewBottomConstraint.constant = 30
                }
                else
                {
                    hiddenStackView.isHidden = true
                    hiddenStackHeightConstraint.constant = 0
                    stackViewBottomConstraint.constant = 0
                }
                //}
            }
        }
    
    func showhideHUD(viewtype: SHOWHIDEHUD,title: String)
    {
        
        switch viewtype {
        case .SHOW:
            CAXSVProgressHUD.sharedInstance.titleLbl.text = title
            CAXSVProgressHUD.sharedInstance.titleLbl.textColor = .black
            
            CAXSVProgressHUD.show()
        case .HIDE:
            CAXSVProgressHUD.sharedInstance.titleLbl.text = ""
            CAXSVProgressHUD.dismiss()
        }
    }
    
    @objc func masterDataInsertedSuccessfullyToDatabase(notification: Notification) {
        
        if let percentage = notification.userInfo?["percentage"] as? Int {
            // do something with your image
            if(percentage == 1008)
            {
                DispatchQueue.main.async
                {
                    self.showhideHUD(viewtype: .HIDE, title: "")
                }
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.getMasterData()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                DispatchQueue.main.async
                {
                    self.alert(AppAlertMsg.serverNotReached, [yes,no])
                }
            }
            
            else if(percentage>0)
            {
                DispatchQueue.main.async
                {
                    // self.showhideHUD(viewtype: .HIDE, title: "")
                    
                    self.showhideHUD(viewtype: .SHOW, title:"Downloading Floor Images. Please wait. Downloading: \(percentage)%")
                }
            }
            
            else
            {
                print("Master data saved completely")
                DispatchQueue.main.async
                {   UserData.setLogedInVal(true)
                    self.showhideHUD(viewtype: .HIDE, title: "")
                    let masterdataSyncCompletedDateTime = Date().getMasterDataSyncDateAsString()
                    UserDefaults.standard.set(masterdataSyncCompletedDateTime, forKey: "MasterDataSyncDate")
                    self.navigationController?.pushViewController(CustomerListViewController.initialization()!, animated: true)
                }
            }
        }
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setClearNavigationBar()
//        if UserDefaults.standard.value(forKey: "username") != nil
//        {
//            emailTF.text = UserDefaults.standard.value(forKey: "username") as? String
//        }
//        if UserDefaults.standard.value(forKey: "password") != nil
//        {
//            passwordTF.text = UserDefaults.standard.value(forKey: "password") as? String
//        }
    }
    
    
    
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
        
        self.alert("Please contact refloor admin for changing the password" , nil)
        
        //self.navigationController?.pushViewController(ForgotPasswordViewController.initialization()!, animated: true)
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if(validation() == "")
        {
            login_Api_Call()
        }
        else
        {
            self.alert(validation(), nil)
        }
    }
    
    @IBAction func passwordVisbleBatton(_ sender: UIButton) {
        isPasswordVisble = !isPasswordVisble
        self.passwordTF.isSecureTextEntry = !isPasswordVisble
    }
    
    func validation() -> String
    {
        if (emailTF.text ?? "").count == 0
        {
            return "Please Enter Email Address"
        }
        if (passwordTF.text ?? "").count == 0
        {
            return "Please Enter password"
        }
        return ""
    }
    
    func login_Api_Call()
    {
        HttpClientManager.SharedHM.Authentication(usernae: emailTF.text ?? "", password: passwordTF.text ?? "") { (result, message, value) in
            if (result ?? "") == "Success"
            {
                
                //salesPersonEmail
                UserDefaults.standard.set(self.emailTF.text, forKey: "salesPersonEmail")
                let user = UserData.init(userID: value?[0].user_id ?? 0, userName: value?[0].user_name ?? "", token: value?[0].token ?? "",restrict_geolocation: value?[0].restrict_geolocation ?? 0)
                print("Token: \(value?[0].token ?? "")")
                //UserData.setLogedInDate(loginDate: Date() as NSDate)
                //                if  UserDefaults.standard.bool(forKey: "isMasterDataSaved") == false{
                //                    self.getMasterData()
                //
//          }
                if let can_view_phone_number = value?[0].can_view_phone_number{
                    UserDefaults.standard.set(can_view_phone_number, forKey: "can_view_phone_number")
                }
                
                if let company_logo_url = value?[0].company_logo_url{
                    if let url = URL(string: company_logo_url){
                        self.downloadImage(from: url, companylogoString : company_logo_url)
                    }
                }
                
                if  ((self.determineIfAnyPendingAppointmentsToSink() == false) || (UserData.isLogedIn() != true)){
                    self.emailTF.text = self.emailTF.text
                    self.passwordTF.text = self.passwordTF.text
                    self.getMasterData()
                }
                //self.navigationController?.pushViewController(ApplicantFormViewControllerForm.initialization()!, animated: true)
            }
            else if ((result ?? "") == "Failed" || ((result ?? "") == "afailed"))
            {
                self.alert(message ?? AppAlertMsg.INVALID_BOTH, nil)
            }
            else if (result ?? "") == "TokenExist"{
                self.alert(message ?? AppAlertMsg.INVALID_TOKEN, nil)
            }
            else
            {
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.login_Api_Call()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
            }
        }
    }
    
//    @IBAction func trainingAction(_ sender: UIButton) {
//        if sender.isSelected{
//            sender.isSelected = false
//            trainingCheckboxButton.isSelected = false
//            BASE_URL = AppURL().LIVE_BASE_URL
//        }else{
//            sender.isSelected = true
//            trainingCheckboxButton.isSelected = true
//            BASE_URL = AppURL().TRAINING_BASE_URL
//        }
//        UserDefaults.standard.set(BASE_URL, forKey: "BASE_URL")
//    }
    
    @IBAction func stagingAction(_ sender: UIButton) {
        let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
           if sender.isSelected{
               sender.isSelected = false
               stagingCheckboxButton.isSelected = false
               BASE_URL = AppURL().LIVE_BASE_URL
               versionNumber.setTitle("Version: \(String(describing: text!))", for: .normal)
           }else{
               sender.isSelected = true
               stagingCheckboxButton.isSelected = true
               BASE_URL = AppURL().STAGE_BASE_URL
               versionNumber.setTitle("Version: \(String(describing: text!)) (1.0) - STAGE", for: .normal)
               if trainingCheckboxButton.isSelected
               {
                   trainingCheckboxButton.isSelected = false
               }
           }
           UserDefaults.standard.set(BASE_URL, forKey: "BASE_URL")
       }
       
       @IBAction func trainingAction(_ sender: UIButton) {
           if sender.isSelected{
               sender.isSelected = false
               trainingCheckboxButton.isSelected = false
               BASE_URL = AppURL().LIVE_BASE_URL
           }else{
               sender.isSelected = true
               trainingCheckboxButton.isSelected = true
               BASE_URL = AppURL().TRAINING_BASE_URL
               if stagingCheckboxButton.isSelected
               {
                   stagingCheckboxButton.isSelected = false
               }
           }
           UserDefaults.standard.set(BASE_URL, forKey: "BASE_URL")
       }

    
    //arb for testing
    func getMasterData(){
        HttpClientManager.SharedHM.getMasterDataApi { success in
            print(Realm.Configuration.defaultConfiguration.fileURL)
            if (success ?? "") == "Success"{
                do {
                    let realm = try Realm()
                    //UserDefaults.standard.set(true, forKey: "isMasterDataSaved")
                    let results =  realm.objects(MasterData.self)
                    //var flooringColorImageArray:[String] = []
                    var flooringColorImageArray:[[String:String]] = []
                    //var stairColourImageArray:[String] = []
                    if let masterData = results.first{
                        //dynamic contract
                       
                        let discountDataArray = masterData.discount_coupons
                        for discountObj in discountDataArray{
                            let discountSuccessPopupImageUrlStr = discountObj.promoUrlImage ?? ""
                            if let discountSuccessPopupImageUrl = URL(string: discountSuccessPopupImageUrlStr){
                                let discountCode = discountObj.code ?? ""
                                self.downloadDiscountSuccessPopupImage(from: discountSuccessPopupImageUrl, code: discountCode)
                            }
                        }
                        
//                        let floorColors = masterData.flooring_colors
//                                                for floorColor in floorColors{
//                                                    if let img = floorColor.material_image_url{
//                                                        flooringColorImageArray.append(img)
//                                                    }
//                                                }
                        let floorColors = masterData.floorColourList
                        let stairColors = masterData.stairColourList
                        var dict:[String:String] = [:]
                        flooringColorImageArray.removeAll()
                        for stairColor in stairColors
                        {
                            if let img = stairColor.material_image_url
                            {
                                dict = [img:"StairColor"]
                                flooringColorImageArray.append(dict)
                            }
                        }
                        for floorColor in floorColors{
                            if let img = floorColor.material_image_url{
                                dict = [img:"FloorColor"]
                                flooringColorImageArray.append(dict)
                            }
                        }
                        UserDefaults.standard.set(self.emailTF.text, forKey: "username")
                        UserDefaults.standard.set(self.passwordTF.text, forKey: "password")
                        let loggedIndateAndTime =  Date().dateToString().autoLogoutDate()
                        

                        UserDefaults.standard.set(loggedIndateAndTime, forKey: "LoggedInTime")
                        
                        DispatchQueue.global(qos: .background).async{
                            DispatchQueue.main.async
                            {
                                self.showhideHUD(viewtype: .SHOW, title:"Master Data Fetching Completed.")
                    
                            }
                            
                            
                            self.downloadPhoto(imageUrlArray: flooringColorImageArray,type: .floorColor)
                        }
                       
                        
                        //                        let questionnaires = masterData.questionnaires
                        //                        let quote_label = masterData.questionnaires.first?.quote_label
                        //                        let flooring_colors = masterData.flooring_colors
                        //                        let molding_types = masterData.molding_types
                        //                        let discount_coupons = masterData.discount_coupons
                        //                        let product_plans = masterData.product_plans
                        
                    }
                }catch{
                    print(RealmError.initialisationFailed.rawValue)
                }
            }else{
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.getMasterData()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert(AppAlertMsg.serverNotReached, [yes,no])
                
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
