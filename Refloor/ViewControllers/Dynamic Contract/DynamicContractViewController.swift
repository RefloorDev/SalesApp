//
//  DynamicContractViewController.swift
//  Refloor
//
//  Created by Anju on 01.09.2023.
//  Copyright © 2023 oneteamus. All rights reserved.
//  Created by Anju on 13.06.2023.

import UIKit
import PDFKit
import RealmSwift
import JWTCodable


class DynamicContractViewController: UIViewController,PDFDocumentDelegate,UITextFieldDelegate, ContractCommentProtocol{
    
    
    static func initialization() -> DynamicContractViewController?
    {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "DynamicContractViewController") as? DynamicContractViewController
    }
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var entryTxtFld: UITextField!
    
    var document = ""
    var paymentType = ""
    var orderID = 0
    var downPayment:Double = 0
    var balance:Double = 0
    var total:Double = 0
    var isTapped = true
    var isloadCompleted = false
    var comments = ""
    var sendPhysicalDocument: Bool = false
    var FlexInstall : Bool = false
    var isCardVerified:Bool = Bool()
    let header = JWTHeader(typ: "JWT", alg: .hs256)
    let signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"//"password"
    var recisionDate:String = String()
    var payment_TrasnsactionDict:[String:String] = [:]
    let group = DispatchGroup()
    // var activity= PaymentOptionsViewController
    let activity = HttpClientManager.init()
    
    
    var myNewView = PDFView()
    var CurrentDate=String()
    var propertyAddress=String()
    var owner1Name=String()
    var owner1Mobile=String()
    var owner1Alternative=String()
    var owner1Email=String()
    var owner2Name=String()
    var owner2Mobile=String()
    var owner2Alternative=String()
    var owner2Email=String()
    
    
    
    var applicantSignatureImage: UIImage?
    var applicantInitialsImage: UIImage?
    var coApplicantSignatureImage: UIImage?
    var coApplicantInitialsImage: UIImage?
    var applicantData:AppoinmentDataValue!
    
    
    
    var contractUpdateDocArray:List<rf_contract_document_templates_results>!
    var fieldArray:List<rf_fields>!
    var page:PDFPage!
    var pageRect:CGRect!
    var pageheight:CGFloat!
    var pagewidth:CGFloat!
    var Bounds:CGRect!
    var Annotation:PDFAnnotation!
    var selectedIndex = -2
    var url:URL!
    var contractdata:Data!
    var checkboxArray=[Int]()
    var optionalArray=[Int]()
    var initialArray=[Int]()
    var filteredArray=[Int]()
    var imageAnnotation:ImageStampAnnotation!
    var contractDataStatus:ContractData?
    var CheckoximageAnnotation:ImageStampAnnotation!
    var imagePicker: CaptureImage!
    var networkMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            let speedTest = HttpClientManager.NetworkSpeedTest()
            speedTest.testUploadSpeed { speed in
                print("Upload speed: \(speed) Mbps")
                self.networkMessage = String(speed)
            }
        }
        self.setNavigationBarbacklogoAndDone()
        getCurrentShortDate()
        self.getSignatureAndInitials()
        contractUpdateDocArray=self.getContractUpdateDocument()
        addAnnotations()
        
        self.contractDataStatus = ContractData.init(contract_owner_reviewed_status: 0, contract_transition: 0, contract_molding_status: 0, contract_molding_none_status: 0, contract_molding_waterproof_status: 0, contract_molding_unfinished_status: 0, contract_molding_CovedBaseboard_status: 0,contract_risk_free_status: 0, contract_lifetime_guarantee_status: 0, contract_lead_safe_status: 0, contract_deposit_status: 0, contract_final_payment_status: 0, contract_time_of_performance_status: 0, contract_notices_to_owners_status: 0, contract_notices_of_cancellation: 0, contract_scheduling_status: 0, contract_motion_status: 0, contract_floor_protection_status: 0, contract_plumbing_status: 0, contract_plumbing_option_status: -1, contract_additional_other_cost_status: 0, contract_additional_other_subfloor_status: 0, contract_additional_other_leveling_status: 0, contract_additional_other_screwdown_status: 0, contract_additional_other_hardwood_removal_status: 0, contract_additional_other_door_removal_status: 0, contract_additional_other_bifold_removal_status: 0, contract_floor_protection: 0, contract_right_to_cure_status: 0, contract_owner_responsibility_status: 0, electronicsAuthorization1Status: 0, electronicsAuthorization2Status: 0,electronicsAuthorization3Status: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(annotationHit(_:)), name: NSNotification.Name.PDFViewAnnotationHit, object: pdfView)
    }
    @objc override func doregenerateBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    func setInitialData(){
        var moldingTypesSelected = identifyMoldingTypesSelectedForRooms()
        
        if moldingTypesSelected.contains(where: {$0.localizedStandardContains("NO MOLDING")}) {
            setcheckBoxAnnotation(type:"molding_none")
            contractDataStatus!.contract_molding_none_status = 1
            
        }
        
        if moldingTypesSelected.contains(where: {$0.localizedStandardContains("Vinyl White")}) {
            setcheckBoxAnnotation(type:"molding_vinyl")
            contractDataStatus!.contract_molding_waterproof_status = 1
        }
        if moldingTypesSelected.contains(where: {$0.localizedStandardContains("Unfinished")}) {
            setcheckBoxAnnotation(type:"molding_unfinished")
            contractDataStatus!.contract_molding_unfinished_status = 1
        }
        if moldingTypesSelected.contains(where: {$0.localizedStandardContains("Cove Baseboard")}) {
            setcheckBoxAnnotation(type:"molding_coved_baseboard")
            contractDataStatus!.contract_molding_CovedBaseboard_status = 1
        }
        let paymentDetails = self.getPaymentDetailsDataFromAppointmentDetail()
        if let financeAmount = paymentDetails["finance_amount"] as? Double{
            if financeAmount > 0{
                setcheckBoxAnnotation(type:"contract Balance Finance")
            }else{
                if paymentType == "cash"{
                    setcheckBoxAnnotation(type:"contract Cash Payment")
                }else if paymentType == "check"{
                    setcheckBoxAnnotation(type:"contract Check payment")
                }else if paymentType == "card"{
                    setcheckBoxAnnotation(type:"card_visa")
                }
            }
        }
        
    }
    
    func setcheckBoxAnnotation(type:String){
        for i in 0...fieldArray.count-1{
            if fieldArray[i].field_type=="checkbox"{
                if fieldArray[i].type==type{
                    self.page = self.pdfView.document?.page(at: self.fieldArray[i].page-1)
                    self.pageRect=self.page.bounds(for: .trimBox)
                    self.pageheight=self.pageRect.size.height
                    self.pagewidth=self.pageRect.size.width
                    //            print(fieldArray[i].height)
                    //            print(fieldArray[i].posX)
                    let fieldheight=CGFloat(self.fieldArray[i].height*1000)+10
                    let fieldwidth=CGFloat(self.fieldArray[i].width*1000)
                    var  posX:CGFloat!
                    var posY:CGFloat!
                    posX=CGFloat(self.fieldArray[i].posX*620-10)
                    posY=CGFloat(self.fieldArray[i].posY*1000+23)

                    let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: 25, height: 20)
                    
                    self.CheckoximageAnnotation=ImageStampAnnotation(with: UIImage(named:"singleTick"),  forBounds: Bounds, withProperties: nil)
                    page.addAnnotation( self.CheckoximageAnnotation)
                }
            }
        }
        
    }
    
    func addAnnotations(){
        
//        if activity.connectedToNetwork(){
//                   DispatchQueue.main.async
//                   {
//                       self.showhideHUD(viewtype: .SHOW, title: "Loading Contract Document. Please wait")
//                   }
//               }
//        else{
//                   let yes = UIAlertAction(title: "Ok", style:.default) { (_) in
//                                      // self.addAnnotations()
//                       }
//                   alert(AppAlertMsg.NetWorkAlertMessage, [yes])
//                   //completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
//               }
        
        let applicantData = self.getApplicantsData()
        let applicant = applicantData["data"] as? [String:Any] ?? [:]
        if let mainApplicant = self.getApplicantData(){
            let street = mainApplicant.street2 == "" ? mainApplicant.street : (mainApplicant.street ?? "") + "," + (mainApplicant.street2 ?? "")
            let city = mainApplicant.city ?? ""
            let state = mainApplicant.state ?? ""
            let zip = mainApplicant.zip ?? ""
            let streetPlusCity = (street ?? "") + ", " + city
            propertyAddress = streetPlusCity + ", " + state + " " + zip
            
            
            
            let applicantFirstName = mainApplicant.applicant_first_name ?? ""
            let applicantMiddleName = mainApplicant.applicant_middle_name ?? ""
            let applicantLastName = mainApplicant.applicant_last_name ?? ""
            
            owner1Name = (applicantMiddleName == "") ? (applicantFirstName + " " + applicantLastName) : (applicantFirstName  + " " + applicantMiddleName  + " " + applicantLastName)
            owner1Mobile = mainApplicant.phone ?? ""
            owner1Alternative = mainApplicant.mobile ?? ""
            owner1Email = mainApplicant.email ?? ""
            let coApplicantFirstName = mainApplicant.co_applicant_first_name ?? ""
            let coApplicantMiddleName = mainApplicant.co_applicant_middle_name ?? ""
            let coApplicantLastName = mainApplicant.co_applicant_last_name ?? ""
            
            owner2Name = (coApplicantMiddleName == "") ? (coApplicantFirstName + " " + coApplicantLastName) : (coApplicantFirstName + " " + coApplicantMiddleName + " " + coApplicantLastName)
            owner2Mobile = mainApplicant.co_applicant_phone ?? ""
            owner2Alternative = mainApplicant.co_applicant_secondary_phone ?? ""
            owner2Email = mainApplicant.co_applicant_email ?? ""
        }
        
        if (UserDefaults.standard.value(forKey: "Recision_Date") as! String) != ""
        {
            let recison = UserDefaults.standard.value(forKey: "Recision_Date") as! String
            //self.recisionDate = masterData.resitionDate?.recisionDate().DateFromStringForServer() ?? ""
            self.recisionDate = recison.recisionDate().DateFromStringForServer()
        }
        if coApplicantSignatureImage != nil{
//            url = URL(string: contractUpdateDocArray[0].document_url ?? "")
            self.fieldArray=contractUpdateDocArray[0].fields
            contractdata = contractUpdateDocArray[0].data
            addAnnotationsWithoutCoApplicant()
            
        }else{
            self.fieldArray=contractUpdateDocArray[1].fields
            let feildType = self.fieldArray.filter({$0.field_type == "initial"})
            //url = URL(string: contractUpdateDocArray[1].document_url ?? "")
            contractdata = contractUpdateDocArray[1].data
            addAnnotationsWithoutCoApplicant()
            
        }
        
    }
    func addAnnotationsWithoutCoApplicant(){
        
        //        let url = URL(string: "https://refloor-dev.odooapps.oneteam.us/web/image/11928?access_token=5fc33a7f-fe39-4507-8f1d-82206352fdbd")
        initialArray.removeAll()
        checkboxArray.removeAll()
        //DispatchQueue.global(qos: .userInitiated).async {
            //if let data = try? Data(contentsOf: self.url!),
               let document = PDFDocument(data: contractdata)
        //{
                DispatchQueue.main.async {
                    self.pdfView.displayMode = .singlePageContinuous
                    self.pdfView.autoScales = true
                    self.pdfView.displayDirection = .vertical
                    self.pdfView.document = document
                    document?.delegate=self
                    
                    // self.pdfView.document = document
                    
                    //        guard let path = Bundle.main.path(forResource: "Refloor Contract v05.24.2023", ofType: "pdf") else { return }
                    //        let url = URL(string: "https://refloor-dev.odooapps.oneteam.us/web/image/11928?access_token=5fc33a7f-fe39-4507-8f1d-82206352fdbd")!
                    //        let document = PDFDocument(url: url)
                    //        pdfView.displayMode = .singlePageContinuous
                    //        pdfView.autoScales = true
                    //        pdfView.displayDirection = .vertical
                    //        pdfView.document = document
                    // document?.delegate=self
                    
                    // self.fieldArray=self.contractUpdateDocArray[0].fields
                    print("fieldArray",self.fieldArray)
                    self.checkboxArray.removeAll()
                    for i in 0...self.fieldArray.count-1{
                        self.page = self.pdfView.document?.page(at: self.fieldArray[i].page-1)
                        self.pageRect=self.page.bounds(for: .trimBox)
                        self.pageheight=self.pageRect.size.height
                        self.pagewidth=self.pageRect.size.width
                        let fieldheight=CGFloat(self.fieldArray[i].height*1000)+10
                        let fieldwidth=CGFloat(self.fieldArray[i].width*1000)
                        let posX=CGFloat(self.fieldArray[i].posX*620)
                        let posY=CGFloat(self.fieldArray[i].posY*1000+23)
                        let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                        var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                        Annotation.font=UIFont.systemFont(ofSize: 10)
                        let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 20, height: 20)
                        let checkboxBounds = CGRect(x: posX, y: self.pageheight-posY, width: 26, height: 20)
                        self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                        self.CheckoximageAnnotation=ImageStampAnnotation(with: UIImage(named:""),  forBounds: checkboxBounds, withProperties: nil)
                        
                        if self.fieldArray[i].type=="property_address"{
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "property_address"
                            
                            Annotation.widgetStringValue=self.propertyAddress
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="Customer Name"{
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Customer Name"
                            Annotation.widgetStringValue=self.owner1Name
                            self.page.addAnnotation(Annotation)
                        }
                        
                        if self.fieldArray[i].type=="Salesperson"{
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Salesperson"
                            Annotation.widgetStringValue=self.getSalesPersonName()
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="CoApp Name"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "CoApp Name"
                            Annotation.widgetStringValue=self.owner2Name
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract_applicant_Phone"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract_applicant_Phone"
                            Annotation.widgetStringValue=self.owner1Mobile
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="sec phone"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "sec phone"
                            Annotation.widgetStringValue=self.owner1Alternative
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract co_applicant_phone"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract co_applicant_phone"
                            Annotation.widgetStringValue=self.owner2Mobile
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="co_applicant_sec_phone"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "co_applicant_sec_phone"
                            Annotation.widgetStringValue=self.owner2Alternative
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract co_applicant_email"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract co_applicant_email"
                            Annotation.widgetStringValue=self.owner2Email
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract_applicant_Email"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract_applicant_Email"
                            Annotation.widgetStringValue=self.owner1Email
                            self.page.addAnnotation(Annotation)
                        }
//                        if self.fieldArray[i].type=="App Signature"{
//
//                            Annotation.widgetFieldType = .text
//                            Annotation.isReadOnly = true
//                            Annotation.font=UIFont.systemFont(ofSize: 13)
//                            Annotation.backgroundColor = .clear
//                            Annotation.fieldName = "App Signature"
//                            //Annotation.widgetStringValue=self.owner1Email
//                            self.page.addAnnotation(Annotation)
//                        }
                        if self.fieldArray[i].field_type=="checkbox"{
                            self.CheckoximageAnnotation=ImageStampAnnotation(with: UIImage(named:""),  forBounds: checkboxBounds, withProperties: nil)
                            self.page.addAnnotation(self.CheckoximageAnnotation)
                        }
                        let Datecharacter: String = "Date"
                        let recesion: String = "recision_date"
                        let type=self.fieldArray[i].type
                        if type?.contains(Datecharacter)==true {
                            var posY:CGFloat!
                            //                            if self.coApplicantSignatureImage != nil{
                            //                                 posY=CGFloat(self.fieldArray[i].posY*1000+27)
                            //                            }else{
                            posY=CGFloat(self.fieldArray[i].posY*1000+26)
                            //                            }
                            let Bounds = CGRect(x: posX-5, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Date"
                            Annotation.widgetStringValue=Date().DateFromStringForServer()
                            self.page.addAnnotation(Annotation)
                        }
                        
                        
                        if type?.contains(recesion)==true {
                            let posY=CGFloat(self.fieldArray[i].posY*1000+27)
                            //                            }
                            let Bounds = CGRect(x: posX-5, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "recision_date"
                            Annotation.widgetStringValue=self.recisionDate
                            self.page.addAnnotation(Annotation)
                        }
                        
                        
                        
                        let totalAmount = (self.total.rounded())
                        let depositAmount = (self.downPayment.rounded())
                        let balanceDueAmount = (self.balance.rounded())
                        
                        if self.fieldArray[i].type=="Grand Total Amount"{
                            var posY:CGFloat!
                            //
                            posY=CGFloat(self.fieldArray[i].posY*1000+27)
                            //
                            let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Grand Total Amount"
                            Annotation.widgetStringValue="$" + String(format: "%.2f", totalAmount)
                            self.page.addAnnotation(Annotation)
                            
                        }
                        if self.fieldArray[i].type=="Deposit Amount"{
                            var posY:CGFloat!
                            posY=CGFloat(self.fieldArray[i].posY*1000+25)
                            let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Deposit Amount"
                            Annotation.widgetStringValue="$" + String(format: "%.2f", depositAmount)
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="Balance Amount"{
                            var posY:CGFloat!
                            posY=CGFloat(self.fieldArray[i].posY*1000+27)
                            let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.isReadOnly = true
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Balance Amount"
                            Annotation.widgetStringValue="$" + String(format: "%.2f", balanceDueAmount)
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="App Signature"{

                            let posY=CGFloat(self.fieldArray[i].posY*1000+38)
                            let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 60, height: 26)
                            //self.imageAnnotation=ImageStampAnnotation(with: self.applicantSignatureImage,  forBounds: ImageBounds, withProperties: nil)
                            self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                            self.imageAnnotation.setValue(self.fieldArray[i].type, forAnnotationKey: .name)
                            self.page.addAnnotation(self.imageAnnotation)
                        }
                        if self.fieldArray[i].type=="CoApp Sign"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000+38)
                            let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 60, height: 26)

                            //self.imageAnnotation=ImageStampAnnotation(with: self.coApplicantSignatureImage,  forBounds: ImageBounds, withProperties: nil)
                            self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                            self.imageAnnotation.setValue(self.fieldArray[i].type, forAnnotationKey: .name)
                            self.page.addAnnotation(self.imageAnnotation)
                        }
                        
                        if self.fieldArray[i].field_type=="initial"{
                            
                            if self.fieldArray[i].option=="" || self.fieldArray[i].option == nil{
                                let posY=CGFloat(self.fieldArray[i].posY*1000+17)
                                let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 12, height: 12)
                                self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                                
                            }else{
                                let posX=CGFloat(self.fieldArray[i].posX*620)
                                let posY=CGFloat(self.fieldArray[i].posY*1000+13)
                                let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: 13, height: 13)
                                self.optionalArray.append(i)
                                self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: Bounds, withProperties: nil)
                                
                            }
                            if (self.fieldArray[i].field_type=="initial" && self.fieldArray[i].requiredField == 1) || (self.fieldArray[i].field_type == "initial" && self.fieldArray[i].option == "option")
                            {
                                self.checkboxArray.append(i)
                            }
                            self.imageAnnotation.setValue(self.fieldArray[i].type, forAnnotationKey: .name)
                            self.page.addAnnotation(self.imageAnnotation)
                            
                        }
                        
                        if self.fieldArray[i].field_type == "signature" && self.fieldArray[i].requiredField == 1
                        {
                                self.checkboxArray.append(i)
                        }
                        
                        
                    }
                    DispatchQueue.main.async
                    {
                        self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                    self.setInitialData()
                }
            //}
       // }
        
    }
    
    func addAnnotationsWithCoApplicant(){
        initialArray.removeAll()
        checkboxArray.removeAll()
        //        let url = URL(string: "https://refloor-dev.odooapps.oneteam.us/web/image/11928?access_token=5fc33a7f-fe39-4507-8f1d-82206352fdbd")
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: self.url!),
               let document = PDFDocument(data: data) {
                DispatchQueue.main.async {
                    self.pdfView.displayMode = .singlePageContinuous
                    self.pdfView.autoScales = true
                    self.pdfView.displayDirection = .vertical
                    self.pdfView.document = document
                    document.delegate=self
                    
                    // self.pdfView.document = document
                    
                    //        guard let path = Bundle.main.path(forResource: "Refloor Contract v05.24.2023", ofType: "pdf") else { return }
                    //        let url = URL(string: "https://refloor-dev.odooapps.oneteam.us/web/image/11928?access_token=5fc33a7f-fe39-4507-8f1d-82206352fdbd")!
                    //        let document = PDFDocument(url: url)
                    //        pdfView.displayMode = .singlePageContinuous
                    //        pdfView.autoScales = true
                    //        pdfView.displayDirection = .vertical
                    //        pdfView.document = document
                    // document?.delegate=self
                    
                    // self.fieldArray=self.contractUpdateDocArray[0].fields
                    print("fieldArray",self.fieldArray)
                    self.checkboxArray.removeAll()
                    for i in 0...self.fieldArray.count-1{
                        //fieldArray[i].index=i
                        self.page = self.pdfView.document?.page(at: self.fieldArray[i].page-1)
                        self.pageRect=self.page.bounds(for: .trimBox)
                        self.pageheight=self.pageRect.size.height
                        self.pagewidth=self.pageRect.size.width
                        //            print(fieldArray[i].height)
                        //            print(fieldArray[i].posX)
                        let fieldheight=CGFloat(self.fieldArray[i].height*1000)+10
                        let fieldwidth=CGFloat(self.fieldArray[i].width*1000)
                        let posX=CGFloat(self.fieldArray[i].posX*620)
                        let posY=CGFloat(self.fieldArray[i].posY*1000+23)
                        let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                        var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                        Annotation.font=UIFont.systemFont(ofSize: 10)
                        let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 20, height: 20)
                        let checkboxBounds = CGRect(x: posX, y: self.pageheight-posY, width: 26, height: 20)
                        self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                        self.CheckoximageAnnotation=ImageStampAnnotation(with: UIImage(named:""),  forBounds: checkboxBounds, withProperties: nil)
                        
                        if self.fieldArray[i].type=="property_address"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "property_address"
                            
                            Annotation.widgetStringValue=self.propertyAddress
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="Customer Name"{
                            //
                            //                let CustomerNamebounds = CGRect(x: posX, y: pageheight-posY, width: fieldwidth, height: fieldheight)
                            //                let CustomerNameAnnotation = PDFAnnotation(bounds: CustomerNamebounds, forType: .widget, withProperties: nil)
                            let posY=CGFloat(self.fieldArray[i].posY*1000+8)
                            let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Customer Name"
                            Annotation.widgetStringValue=self.owner1Name
                            self.page.addAnnotation(Annotation)
                        }
                        
                        if self.fieldArray[i].type=="Salesperson"{
                            
                            
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Salesperson"
                            Annotation.widgetStringValue=self.getSalesPersonName()
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="CoApp Name"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000+8)
                            let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "CoApp Name"
                            Annotation.widgetStringValue=self.owner2Name
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract_applicant_Phone"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000+4)
                            let Bounds = CGRect(x: posX-5, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract_applicant_Phone"
                            Annotation.widgetStringValue=self.owner1Mobile
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="sec phone"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000-10)
                            let Bounds = CGRect(x: posX-5, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "sec phone"
                            Annotation.widgetStringValue=self.owner1Alternative
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract co_applicant_phone"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000+4)
                            let Bounds = CGRect(x: posX-5, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract co_applicant_phone"
                            Annotation.widgetStringValue=self.owner2Mobile
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="co_applicant_sec_phone"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "co_applicant_sec_phone"
                            Annotation.widgetStringValue=self.owner2Alternative
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract co_applicant_email"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000-6)
                            let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract co_applicant_email"
                            Annotation.widgetStringValue=self.owner2Email
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="contract_applicant_Email"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000-6)
                            let Bounds = CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "contract_applicant_Email"
                            Annotation.widgetStringValue=self.owner1Email
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].field_type=="checkbox"{
                            //                            let checkBox = PDFAnnotation(bounds: CGRect(x: posX, y: self.pageheight-posY, width: fieldwidth, height: fieldheight), forType: .widget, withProperties: nil)
                            //                            checkBox.widgetFieldType = .button
                            //                            checkBox.border?.style=
                            //                            checkBox.border?.borderKeyValues
                            //                            checkBox.widgetControlType = .checkBoxControl
                            //                            checkBox.backgroundColor = .clear
                            
                            self.CheckoximageAnnotation=ImageStampAnnotation(with: UIImage(named:""),  forBounds: checkboxBounds, withProperties: nil)
                            
                            
                            //
                            self.page.addAnnotation(self.CheckoximageAnnotation)
                        }
                        
                        
                        let Datecharacter: String = "Date"
                        let recesion: String = "recision_date"
                        let type=self.fieldArray[i].type
                        if type?.contains(Datecharacter)==true {
                            let posY=CGFloat(self.fieldArray[i].posY*1000+27)
                            let Bounds = CGRect(x: posX-5, y: self.pageheight-posY, width: fieldwidth, height: fieldheight)
                            var Annotation = PDFAnnotation(bounds: Bounds, forType: .widget, withProperties: nil)
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Date"
                            Annotation.widgetStringValue=Date().DateFromStringForServer()
                            self.page.addAnnotation(Annotation)
                        }
                        
                        
                        if type?.contains(recesion)==true {
                            
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "recision_date"
                            Annotation.widgetStringValue=self.recisionDate
                            self.page.addAnnotation(Annotation)
                        }
                        
                        
                        
                        let totalAmount = (self.total.rounded())
                        let depositAmount = (self.downPayment.rounded())
                        let balanceDueAmount = (self.balance.rounded())
                        
                        if self.fieldArray[i].type=="Grand Total Amount"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Grand Total Amount"
                            Annotation.widgetStringValue="$" + String(format: "%.2f", totalAmount)
                            self.page.addAnnotation(Annotation)
                            
                        }
                        if self.fieldArray[i].type=="Deposit Amount"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Deposit Amount"
                            Annotation.widgetStringValue="$" + String(format: "%.2f", depositAmount)
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="Balance Amount"{
                            
                            Annotation.widgetFieldType = .text
                            Annotation.font=UIFont.systemFont(ofSize: 13)
                            Annotation.backgroundColor = .clear
                            Annotation.fieldName = "Balance Amount"
                            Annotation.widgetStringValue="$" + String(format: "%.2f", balanceDueAmount)
                            self.page.addAnnotation(Annotation)
                        }
                        if self.fieldArray[i].type=="App Signature"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000+40)
                            let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 60, height: 26)
                            //self.imageAnnotation=ImageStampAnnotation(with: self.applicantSignatureImage,  forBounds: ImageBounds, withProperties: nil)
                            self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                            self.page.addAnnotation(self.imageAnnotation)
                        }
                        if self.fieldArray[i].type=="CoApp Sign"{
                            let posY=CGFloat(self.fieldArray[i].posY*1000+40)
                            let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 60, height: 26)

                            //self.imageAnnotation=ImageStampAnnotation(with: self.coApplicantSignatureImage,  forBounds: ImageBounds, withProperties: nil)
                            self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                            self.page.addAnnotation(self.imageAnnotation)
                        }
                       
                        
                        if self.fieldArray[i].field_type=="initial"{
                            let posX=CGFloat(self.fieldArray[i].posX*620)
                            let posY=CGFloat(self.fieldArray[i].posY*1000-25)
                            let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 18, height: 18)
                            
                            self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: ImageBounds, withProperties: nil)
                            if self.fieldArray[i].requiredField == 1
                            {
                                self.checkboxArray.append(i)
                            }
                            self.imageAnnotation.setValue(self.fieldArray[i].type, forAnnotationKey: .name)
                            self.page.addAnnotation(self.imageAnnotation)
                        }
                        
                        
                    }
                    DispatchQueue.main.async
                    {
                        self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                    self.setInitialData()
                }
            }
        }
        
    }
    
    
    override func nextAction()
    {
    self.validateFieldsAnnotation()
    }
    
    
    func validateFieldsAnnotation(){
        filteredArray.removeAll()
        for i in 0...fieldArray.count-1{
            if (fieldArray[i].field_type=="initial" || fieldArray[i].field_type == "signature") && fieldArray[i].requiredField == 1
            {
                filteredArray = checkboxArray.filter { !initialArray.contains($0) }
                
            }
        }
        if filteredArray.count > 0
        {
        if filteredArray.count>0||self.contractDataStatus?.contract_plumbing_option_status == -1  {
            self.alert("Please check all initials", nil)
            for i in 0...fieldArray.count-1{
                if fieldArray[i].field_type=="initial" || fieldArray[i].field_type == "signature"{
                    if filteredArray.count>0
                    {
                        for j in 0...filteredArray.count-1{
                            
                            if i==filteredArray[j]{
                                self.page = self.pdfView.document?.page(at: self.fieldArray[i].page-1)
                                self.pageRect=self.page.bounds(for: .trimBox)
                                self.pageheight=self.pageRect.size.height
                                self.pagewidth=self.pageRect.size.width
                                
                                let fieldheight=CGFloat(self.fieldArray[i].height*1000)+10
                                let fieldwidth=CGFloat(self.fieldArray[i].width*1000)
                                let posX=CGFloat(self.fieldArray[i].posX*620)
                                let posY=CGFloat(self.fieldArray[i].posY*1000+18)
                                //
                                var Bounds:CGRect!
                                if fieldArray[i].option=="" || fieldArray[i].option == nil{
                                    Bounds = CGRect(x: posX, y: self.pageheight-posY, width: 13, height: 13)
                                    self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheckRed"),  forBounds: Bounds, withProperties: nil)
                                    if fieldArray[i].field_type == "signature"
                                    {
                                        let posX=CGFloat(self.fieldArray[i].posX*620)
                                        let posY=CGFloat(self.fieldArray[i].posY*1000+38)
                                        let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 60, height: 26)
                                        self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"signatureUncheckRed"),  forBounds: ImageBounds, withProperties: nil)
                                    }
                                    page.addAnnotation(imageAnnotation)
                                }else{
                                    let posX=CGFloat(self.fieldArray[i].posX*620)
                                    let posY=CGFloat(self.fieldArray[i].posY*1000+13)
                                    Bounds = CGRect(x: posX, y: self.pageheight-posY, width: 13, height: 13)
                                    self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheckRed"),  forBounds: Bounds, withProperties: nil)
                                    if fieldArray[i].field_type == "signature"
                                    {
                                        let posX=CGFloat(self.fieldArray[i].posX*620)
                                        let posY=CGFloat(self.fieldArray[i].posY*1000+38)
                                        let ImageBounds = CGRect(x: posX, y: self.pageheight-posY, width: 60, height: 26)
                                        self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"signatureUncheckRed"),  forBounds: ImageBounds, withProperties: nil)
                                    }
                                    page.addAnnotation(imageAnnotation)
                                }
                                
                                self.imageAnnotation.setValue(self.fieldArray[i].type, forAnnotationKey: .name)
                                //self.imageAnnotation.backgroundColor = .red
                                page.addAnnotation(self.imageAnnotation)
                            }
                        }
                    }
                }
            }
        }
    }else{
            let comment = ContactCommentPopUpViewController.initialization()!
            comment.delegate = self
            self.present(comment, animated: true, completion: nil)
        }
        
    }
    
    
    
    
    @objc func annotationHit(_ notification: Notification) {
        let annotation = notification.userInfo!["PDFAnnotationHit"] as? ImageStampAnnotation
        
        let typeName = annotation?.value(forAnnotationKey: .name) as? String
        
        
        for i in 0...fieldArray.count-1{
            if typeName==fieldArray[i].type{
                
                if fieldArray[i].field_type=="initial" || fieldArray[i].field_type == "signature"{
                    
                    if initialArray.contains(i){
                        
                    }else{
                        initialArray.append(i)
                    }
                    
                    self.page = self.pdfView.document?.page(at: self.fieldArray[i].page-1)
                    self.pageRect=self.page.bounds(for: .trimBox)
                    self.pageheight=self.pageRect.size.height
                    self.pagewidth=self.pageRect.size.width
                    //            print(fieldArray[i].height)
                    //            print(fieldArray[i].posX)
                    let fieldheight=CGFloat(self.fieldArray[i].height*1000)+10
                    let fieldwidth=CGFloat(self.fieldArray[i].width*1000)
                    let posX=CGFloat(self.fieldArray[i].posX*620)
                    let posY=CGFloat(self.fieldArray[i].posY*1000+18)
                    var Bounds:CGRect!
                    
                    if fieldArray[i].option=="" || fieldArray[i].option==nil{
                        Bounds = CGRect(x: posX-5, y: self.pageheight-posY, width: 23, height: 25)
                        if fieldArray[i].field_type == "signature" && typeName == "CoApp Sign"
                        {
                            let posY=CGFloat(self.fieldArray[i].posY*1000+40)
                            let ImageBounds = CGRect(x: posX, y: self.pageheight-posY+5, width: 60, height: 26)
                            self.imageAnnotation=ImageStampAnnotation(with: self.coApplicantSignatureImage,  forBounds: ImageBounds, withProperties: nil)
                        }
                        else if fieldArray[i].field_type == "signature" && typeName == "App Signature"
                        {
                            let posY=CGFloat(self.fieldArray[i].posY*1000+40)
                            let ImageBounds = CGRect(x: posX, y: self.pageheight-posY+5, width: 60, height: 26)
                            self.imageAnnotation=ImageStampAnnotation(with: self.applicantSignatureImage,  forBounds: ImageBounds, withProperties: nil)
                        }
                        else
                        {
                            self.imageAnnotation=ImageStampAnnotation(with: self.applicantInitialsImage,  forBounds: Bounds, withProperties: nil)
                        }
                        page.addAnnotation(imageAnnotation)
                    }else{
                        
                        if optionalArray.count>0{
                            for j in 0...optionalArray.count-1{
                                if optionalArray[j]==i{
                                    if j==0{
                                        self.contractDataStatus!.contract_plumbing_option_status=0
                                    }else{
                                        self.contractDataStatus!.contract_plumbing_option_status=1
                                    }
                                    let posX=CGFloat(self.fieldArray[i].posX*620)
                                    let posY=CGFloat(self.fieldArray[i].posY*1000+13)
                                    Bounds = CGRect(x: posX, y: self.pageheight-posY, width: 16, height: 16)
                                    self.imageAnnotation=ImageStampAnnotation(with: self.applicantInitialsImage,  forBounds: Bounds, withProperties: nil)
                                    page.addAnnotation(imageAnnotation)
                                }else{
                                    
                                    let posX=CGFloat(self.fieldArray[optionalArray[j]].posX*620)
                                    let posY=CGFloat(self.fieldArray[optionalArray[j]].posY*1000+13)
                                    Bounds = CGRect(x: posX, y: self.pageheight-posY, width: 13, height: 13)
                                    self.imageAnnotation=ImageStampAnnotation(with: UIImage(named:"contactUncheck"),  forBounds: Bounds, withProperties: nil)
                                    self.imageAnnotation.setValue(self.fieldArray[optionalArray[j]].type, forAnnotationKey: .name)
                                    
                                        if checkboxArray.contains(optionalArray[j])
                                        {
                                            let index = checkboxArray.firstIndex(of: optionalArray[j])!
                                            self.checkboxArray.remove(at: index)
                                        }
                                    
                                    page.addAnnotation(imageAnnotation)
                                }
                            }
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func Action(_ sender: UIButton) {
        let firstName = "newString"
        //       // let  pageIndex=1
        for pageIndex in 0..<(myNewView.document?.pageCount ?? 0) {
            if let page = myNewView.document?.page(at: pageIndex) {
                for annotation in page.annotations {
                    
                    if annotation.widgetFieldType == .text{
                        if let textField = annotation as? PDFAnnotation{
                            if textField.fieldName == "File_Name" {
                                if let page = myNewView.document?.page(at: 0) {
                                    let bounds = CGRect(x: 0, y: 0, width: 70, height: 80)
                                    let widgetAnnotation = PDFAnnotation(bounds: bounds, forType: .widget, withProperties: nil)
                                    widgetAnnotation.widgetFieldType = .text
                                    widgetAnnotation.backgroundColor = .red
                                    widgetAnnotation.fieldName = textField.fieldName
                                    page.addAnnotation(widgetAnnotation)
                                }
                                
                                
                                
                                //                                 textField.widgetStringValue = firstName
                                let fieldName = textField.fieldName
                                let fieldValue =  textField.widgetStringValue
                                // Perform any required operations with the text field
                                print("Field Name: \(fieldName)")
                                print("Field Value: \(fieldValue)")
                                
                            }
                        }
                    }
                }
            }
        }
        
        // addTextAnnotation(pageIndex: 2, text: "HHHHHHHHHHH", rect: CGRect(x: 0, y: 100, width: 700, height: 200))
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == entryTxtFld{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            let firstName = newString
            let  pageIndex=1
            //            for pageIndex in 0..<(myNewView.document?.pageCount ?? 0) {
            if let page = myNewView.document?.page(at: pageIndex) {
                for annotation in page.annotations {
                    if annotation.widgetFieldType == .text{
                        if let textField = annotation as? PDFAnnotation {
                            if textField.fieldName == "WASTE:" {
                                textField.widgetStringValue = firstName
                            }
                        }
                    }
                }
            }
            //            }
        }
        return true
    }
    func getCurrentShortDate() -> String {
        var todaysDate = NSDate()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        var DateInFormat = dateFormatter.string(from: todaysDate as Date)
        
        return DateInFormat
    }
    
    func getSignatureAndInitials(){
        let (applicantSignature,applicantInitials) = self.getApplicantSignatureAndInitials()
        let (coApplicantSignature,coApplicantInitials) = self.getCoApplicantSignatureAndInitials()
        
        applicantSignatureImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: applicantSignature)
        applicantInitialsImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: applicantInitials)
        
        coApplicantSignatureImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: coApplicantSignature)
        coApplicantInitialsImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: coApplicantInitials)
    }
    
    
    func getApplicantsData() -> [String: Any]{
        return self.getApplicantAndIncomeDataFromAppointmentDetail()
    }
    func getApplicantData() -> AppoinmentDataValue?{
        var applicant:AppoinmentDataValue? = nil
        if let customer = AppDelegate.appoinmentslData
        {
            applicant = customer
            
        }
        return applicant
    }
    
    
    func addTextAnnotation(pageIndex: Int, text: String, rect: CGRect) {
        guard let pdfDocument = myNewView.document else { return }
        guard let page = pdfDocument.page(at: pageIndex) else { return }
        
        let annotation = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
        annotation.contents = text
        page.addAnnotation(annotation)
    }
    
    
    func sendAddedComments(comment: String, sendHardCopy: Bool,sendFlexInstall:Bool){
        print("COMMENT : \(comment)")
        self.comments = comment
        self.sendPhysicalDocument = sendHardCopy
        self.FlexInstall = sendFlexInstall
        validationOkayProceedWithContract()
    }
    func saveContractDataToDatabase(){
        let appointmentId = AppointmentData().appointment_id ?? 0
        self.contractDataStatus = ContractData.init(contract_owner_reviewed_status: 1, contract_transition: 1, contract_molding_status: 1, contract_molding_none_status:  self.contractDataStatus?.contract_molding_none_status ?? 0, contract_molding_waterproof_status: self.contractDataStatus?.contract_molding_waterproof_status ?? 0, contract_molding_unfinished_status: self.contractDataStatus?.contract_molding_unfinished_status ?? 0, contract_molding_CovedBaseboard_status:  self.contractDataStatus?.contract_molding_CovedBaseboard_status ?? 0,contract_risk_free_status: 1, contract_lifetime_guarantee_status: 1, contract_lead_safe_status: 1, contract_deposit_status: 1, contract_final_payment_status: 1, contract_time_of_performance_status: 1, contract_notices_to_owners_status: 1, contract_notices_of_cancellation: 1, contract_scheduling_status: 1, contract_motion_status: 1, contract_floor_protection_status: 1, contract_plumbing_status: 1, contract_plumbing_option_status:  self.contractDataStatus?.contract_plumbing_option_status ?? 0, contract_additional_other_cost_status: 1, contract_additional_other_subfloor_status: 1, contract_additional_other_leveling_status: 1, contract_additional_other_screwdown_status: 1, contract_additional_other_hardwood_removal_status: 1, contract_additional_other_door_removal_status: 1, contract_additional_other_bifold_removal_status: 1, contract_floor_protection: 1, contract_right_to_cure_status: 1, contract_owner_responsibility_status: 1, electronicsAuthorization1Status: 1, electronicsAuthorization2Status: 1,electronicsAuthorization3Status: 1)
        if let contractDataDict = self.contractDataStatus?.nsDictionary{
            self.saveContractDataOfAppointment(appointmentId: appointmentId, contractData: contractDataDict)
        }
    }
    func validationOkayProceedWithContract(){

        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "ContractDocument"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        self.saveContractDataToDatabase()

        //self.deleteAllAppointmentRequestForThisAppointmentId(appointmentId: appointmentId)
        // change customer data if applicant data is added
        let contactApiData = self.createContractParameters()
        if let applicantDataDict = contactApiData as? [String:Any]
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
    //            if  let applicant = applicantDataDict["applicationInfo"] as? [String:Any]
    //            {
    //                self.saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId: appointmentId, customerDetailsDict: applicant)
    //            }
        }
        //1.
        
        var customerAndRoomData = self.createFinalParameterForCustomerApiCall()
        for (key,value) in contactApiData{
            customerAndRoomData[key] = value
        }
            if payment_TrasnsactionDict != [:]
            {
                customerAndRoomData["payment_transaction_info"] = self.payment_TrasnsactionDict
            }
        
        checkForInstallerOrNot(customerAndRoomData: customerAndRoomData, appointmentId: appointmentId)
        
        print(contactApiData)
    
        
    }

    func checkForInstallerOrNot(customerAndRoomData:[String:Any],appointmentId:Int)
    {
        print("----checkForInstallerOrNot------", customerAndRoomData)
        var iscustomerAndRoomSuccess:Bool = Bool()
        var isNetwork:Bool = Bool()
        
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            
            isNetwork = true
            if isCardVerified == true
            {
                iscustomerAndRoomSuccess = true
                //whetheToProceedToInstaller(customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork, appointmentId: appointmentId)
                self.additionalComments(message: "Order details updated successfully", customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork)
            }
            else
            {
                HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW , title: "Creating Sale Order")
                let appointment = self.getAppointmentData(appointmentId: AppointmentData().appointment_id ?? 0)
                let firstName = appointment?.applicant_first_name ?? ""
                let lastName = appointment?.applicant_last_name ?? ""
                let name = lastName == ""  ? firstName : firstName + " " + lastName
                let date = appointment?.appointment_datetime ?? ""
                var parameterToPass:[String:Any] = [:]
                let decodeOption:[String:Bool] = ["verify_signature":false]
                
                
                parameterToPass = ["token": UserData.init().token ?? "" ,"decode_options":decodeOption,"data":customerAndRoomData,"network_strength":networkMessage]
                HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(parameter: parameterToPass, isOnlineCollectBtnPressed: false) { success, message,payment_status,payment_message,transactionId,cardType  in
                    if(success ?? "") == "Success"
                    {
                        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                        self.deleteAnyAppointmentLogsTable(appointmentId: appointmentId)
                        
                        self.createDBAppointmentRequest(requestTitle: RequestTitle.CustomerAndRoom, requestUrl: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParameter: customerAndRoomData as NSDictionary, imageName: "")
                        
                        self.additionalComments(message: message!, customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: true, isNetwork: isNetwork)

                        
                    }
                    else if success == "Failed"
                    {
                        let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                            
                            self.checkForInstallerOrNot(customerAndRoomData: customerAndRoomData, appointmentId: appointmentId)
                            
                        }
                        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    }
                    else if success == "false"
                    {
                        let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                            
                            self.checkForInstallerOrNot(customerAndRoomData: customerAndRoomData, appointmentId: appointmentId)
                            
                        }
                        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
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
                        let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                            
                            self.checkForInstallerOrNot(customerAndRoomData: customerAndRoomData, appointmentId: appointmentId)
                            
                        }
                        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        self.alert( AppAlertMsg.NetWorkAlertMessage, [yes,no])
                    }
                }
                
                
                
            }
            
        }
        else
        {
            
            isNetwork = false
            if isCardVerified == true
            {
                iscustomerAndRoomSuccess = true
                whetheToProceedToInstaller(customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork, appointmentId: appointmentId)
            }
            else
            {
                iscustomerAndRoomSuccess = false
                whetheToProceedToInstaller(customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork, appointmentId: appointmentId)
            }
        }
    }
    
    func additionalComments(message:String,customerAndRoomData:[String:Any],iscustomerAndRoomSuccess:Bool,isNetwork:Bool)
    {
        var iscustomerAndRoomSuccess = iscustomerAndRoomSuccess
        var parametersAdditionalComments:[String:Any] = [:]
        let appoint_id = AppointmentData().appointment_id ?? 0
        let recison = UserDefaults.standard.value(forKey: "Recision_Date") as! String
        parametersAdditionalComments = ["token": UserData.init().token ?? "" ,"appointment_id":appoint_id,"flexible_installation":self.FlexInstall ? 1: 0,"send_physical_document":self.sendPhysicalDocument ? 1 : 0,"additional_comments":self.comments,"recision_date":recison,"network_strength":networkMessage]
        
        HttpClientManager.SharedHM.additionalCommentsAPi(parameter: parametersAdditionalComments) { success, usermessage in
            if(success ?? "") == "Success"
            {
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    self.isCardVerified = true
                    iscustomerAndRoomSuccess = true
                    self.whetheToProceedToInstaller(customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork, appointmentId: appoint_id)
                }
                
                
                self.alert(message ?? "", [yes])
            }
            
            else if success == "Failed"
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.additionalComments(message: message, customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork)
                    
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
            }
            else if success == "false"
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.additionalComments(message: message, customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork)
                    
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
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
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.additionalComments(message: message, customerAndRoomData: customerAndRoomData, iscustomerAndRoomSuccess: iscustomerAndRoomSuccess, isNetwork: isNetwork)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert( AppAlertMsg.NetWorkAlertMessage, [yes,no])
            }
        }
            
        
    }
    
    
    
    func whetheToProceedToInstaller(customerAndRoomData:[String:Any],iscustomerAndRoomSuccess:Bool,isNetwork:Bool,appointmentId:Int)
    {
        
        if self.isCardVerified == false && iscustomerAndRoomSuccess == false && isNetwork == false
        {
            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.CustomerAndRoom, url: AppURL().syncCustomerAndRoomInfo, requestType: RequestType.post, requestParams: customerAndRoomData as NSDictionary, imageName: "")
        }
        
        let imagesArray = self.allImagesUnderAppointment().filter({$0["image_name"] as! String != ""})
        //            var lastImageDict = imagesArray[imagesArray.count-1]
        //            lastImageDict["data_completed"] = 1
        //            imagesArray[imagesArray.count-1] = lastImageDict
        //            print(imagesArray)
        for imageDict in imagesArray{
            self.createAppointmentsRequestDataToDatabase(title: RequestTitle.ImageUpload, url: AppURL().syncImageInfo, requestType: RequestType.formData, requestParams: imageDict as NSDictionary, imageName: imageDict["image_name"] as! String)
        }
        //4.
        let appoint_id = String(AppointmentData().appointment_id ?? 0)
        var contract_plumbing_option_1 = 0
        var contract_plumbing_option_2 = 0
        if self.contractDataStatus!.contract_plumbing_option_status == 0{
            contract_plumbing_option_1 = 1
        }else if self.contractDataStatus!.contract_plumbing_option_status == 1{
            contract_plumbing_option_2 = 1
        }
        let recison = UserDefaults.standard.value(forKey: "Recision_Date") as! String
        let requestPara:[String:Any] = ["appointment_id":appoint_id,"contract_plumbing_option_1":contract_plumbing_option_1, "contract_plumbing_option_2" : contract_plumbing_option_2,"recision_date" : recison,"send_physical_document": self.sendPhysicalDocument ? 1 : 0,"additional_comments":self.comments, "flexible_installation": self.FlexInstall ? 1: 0]
        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.GenerateContract, url: AppURL().syncGenerateContractDocumentInServer, requestType: RequestType.post, requestParams: requestPara as NSDictionary, imageName: "")
        
        let requestParaInitiateSync:[String:Any] = ["appointment_id":appoint_id,"screen_logs":self.getScreenCompletionArrayToSend()]
        let requestParaInitiateSyncFinal = ["data":requestParaInitiateSync]
        self.createAppointmentsRequestDataToDatabase(title: RequestTitle.InitiateSync, url: AppURL().syncInitiate_i360, requestType: RequestType.post, requestParams: requestParaInitiateSyncFinal as NSDictionary, imageName: "")
        
        //log entry
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.appointmentLogStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        if isNetwork
        {
            HttpClientManager.SharedHM.showhideHUD(viewtype: .HIDE)
            let installer = InstallerShedulerViewController.initialization()!
            installer.name = name
            self.navigationController?.pushViewController(installer, animated: true)
        }
        else
        {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    func createAppointmentsRequestDataToDatabase(title:RequestTitle,url:String,requestType:RequestType,requestParams:NSDictionary,imageName:String){
        
        self.createAppointmentRequest(requestTitle: title, requestUrl: url, requestType: requestType, requestParameter: requestParams, imageName: imageName)
    }
    // MARK: - ROOM PARAMETERS
    //rooms
    func createRoomParameters() -> [[String:Any]]{
        return self.getRoomArrayForApiCall()
    }
    
    func createQuestionAnswerForAllRoomsParameter() -> [[String:Any]]{
        return self.getQuestionAnswerArrayForApiCall()
    }
    
    func createCustomerParameter() -> [String:Any]{
        return self.getCustomerDetailsForApiCall()
    }
    
    func createFinalParameterForCustomerApiCall() -> [String:Any]{
        var customerDict: [String:Any] = [:]
        customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        customerDict["data_completed"] = 0
        var customerData = createCustomerParameter()
        //        customerData["additional_comments"] = self.comments
        //        customerData["send_physical_document"] = self.sendPhysicalDocument ? 1 : 0
        customerDict["customer"] = customerData
        customerDict["rooms"] = createRoomParameters()
        customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
        customerDict["operation_mode"] = "offline"
        customerDict["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return customerDict
    }
    
    // MARK: - CONTRACT PARAMETERS
    //contract
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
        contractDict["application_info_secret"] = applicantInfoSecret//applicantDta["data"]//
        //contractDict["contractInfo"] = contactInfo
        //        contractDict["data_completed"] = 0
        //        contractDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        //        let contractDataDict: [String:Any] = ["data":contractDict]
        //        print(contractDataDict)
        return contractDict //contractDataDict
    }
    
    // MARK: - IMAGE PARAMETERS
    //images
    func createRoomDrawImageParameter() -> [[String:Any]]{
        return self.getRoomDrawingForApiCall()
    }
    
    func createRoomImagesParameter() -> [[String:Any]]{
        return self.getRoomImagesForApiCall()
    }
    
    func createApplicantSignatureParameter() -> [[String:Any]]{
        return self.getApplicantSignatureForApiCall()
    }
    
    func createCoApplicantSignatureParameter() -> [[String:Any]]{
        return getCoApplicantSignatureForApiCall()
    }
    
    func createSnapshotImageParameter() -> [[String:Any]]{
        return self.getSnapShotImagesForApiCall()
    }
    
    func allImagesUnderAppointment() -> [[String:Any]] {
        let drawImageArray = createRoomDrawImageParameter()
        print(drawImageArray)
        let roomImageArray = createRoomImagesParameter()
        print(roomImageArray)
        let applicantSignatureAndInitialsArray = createApplicantSignatureParameter()
        print(applicantSignatureAndInitialsArray)
        let coApplicantSignatureAndInitialsArray = createCoApplicantSignatureParameter()
        print(coApplicantSignatureAndInitialsArray)
        let snapshotArray = createSnapshotImageParameter()
        let totalImagesUnderAppointment:[[String:Any]] =  applicantSignatureAndInitialsArray + coApplicantSignatureAndInitialsArray + drawImageArray + roomImageArray + snapshotArray
        print(totalImagesUnderAppointment)
        return totalImagesUnderAppointment
    }
    //
    
    
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
    
    func showhideHUD(viewtype: SHOWHIDEHUD,title: String = "")
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
}

extension DynamicContractViewController: ImagePickerDelegate {
    
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




extension Array where Element: Equatable {
    func contains(array: [Element]) -> Bool {
        for item in array {
            if !self.contains(item) { return false }
        }
        return true
    }
}

