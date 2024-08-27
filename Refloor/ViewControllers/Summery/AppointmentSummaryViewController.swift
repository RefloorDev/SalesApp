//
//  AppointmentSummaryViewController.swift
//  Refloor
//
//  Created by Bincy C A on 08/08/24.
//  Copyright © 2024 oneteamus. All rights reserved.
//

import UIKit

class AppointmentSummaryViewController: UIViewController, ImagePickerDelegate 
{
    
    var imagePicker: CaptureImage!
    var paymentType = ""
    var orderID = 0
    var downPayment:Double = 0
    var balance:Double = 0
    var total:Double = 0
    var payment_TrasnsactionDict:[String:String] = [:]
    var isCardVerified:Bool = Bool()
    var document = ""
    var includedRooms:[SummeryListData] = []
    var excludedRooms:[SummeryListData] = []
    var area:Double = Double()
    var totalPrice:Double = Double()
    var finalPayment:Double = Double()
    var financeAmount:Double = Double()
    var adjustedArea = 0.0
    @IBOutlet weak var summaryTableView: UITableView!
    func didSelect(image: UIImage?, imageName: String?)
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
    
    
    static func initialization() -> AppointmentSummaryViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "AppointmentSummaryViewController") as? AppointmentSummaryViewController
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarbackAndlogo(with: "Summary".uppercased())
        summaryTableView.register(UINib(nibName: "AppointmentSummaryFirstRowTableViewCell", bundle: nil), forCellReuseIdentifier: "AppointmentSummaryFirstRowTableViewCell")
        //RoomsTableViewCell
        summaryTableView.register(UINib(nibName: "RoomsTableViewCell", bundle: nil), forCellReuseIdentifier: "RoomsTableViewCell")
        //TitleSummaryTableViewCell
        summaryTableView.register(UINib(nibName: "TitleSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleSummaryTableViewCell")
        
        
        let tableValues = self.getRoomsSummary(appointmentId: AppointmentData().appointment_id ?? 0)
         for tableRooms in tableValues
        {
             if tableRooms.striked == "false"
             {
                 includedRooms.append(tableRooms)
                 //self.adjustedArea += tableRooms.adjusted_area ?? 0.0
             }
             else
             {
                 excludedRooms.append(tableRooms)
             }
         }
        
    }
    
    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePicker = CaptureImage(presentationController: self, delegate: self)
            self.imagePicker.present(from: sender)
            
        }
}

extension AppointmentSummaryViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return includedRooms.count
        case 3:
            if excludedRooms.count == 0
            {
                return 0
            }
            else
            {
                return 1
            }
        case 4:
            return excludedRooms.count
        default:
            return 1
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int 
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section
        {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentSummaryFirstRowTableViewCell", for: indexPath) as! AppointmentSummaryFirstRowTableViewCell
            cell.NextBtn.addTarget(self, action: #selector(nextBtnAction(sender: )), for: .touchUpInside)
            cell.paymentSummaryBtn.addTarget(self, action: #selector(paymentSummaryBtnClicked(sender:)), for: .touchUpInside)
            //cell.areaLbl.text = "\(adjustedArea) SQ.FT"
            cell.totalPriceLbl.text = "$\(total.toDoubleString)"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleSummaryTableViewCell", for: indexPath) as! TitleSummaryTableViewCell
            cell.roomTitle.text = "Included Rooms"
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsTableViewCell", for: indexPath) as! RoomsTableViewCell
            cell.includedTick.isHidden = false
            cell.areaMeasured.text = "\(String(describing: includedRooms[indexPath.row].adjusted_area!)) Sq.Ft"
            cell.roomImage.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: includedRooms[indexPath.row].room_image_url ?? "")
            cell.roomName.text = includedRooms[indexPath.row].room_name
            cell.colorLbl.text = includedRooms[indexPath.row].color
            cell.moldingLbl.text = includedRooms[indexPath.row].moulding
            cell.colorImageView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: includedRooms[indexPath.row].material_image_url ?? "")
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:AppointmentData().appointment_id ?? 0)
            appointment.first?.rooms.forEach({ room in
               if room.room_id == includedRooms[indexPath.row].room_id
                {
                let questionAnswers = room.questionnaires
                   questionAnswers.forEach { question in
                       if question.question_name == "Current Surface"
                       {
                           cell.currentSurface.text =  question.rf_AnswerOFQustion[0].answer[0]
                       }
                       else if question.question_name == "Remove Existing Surface"
                       {
                           cell.removeExistingLbl.text = question.rf_AnswerOFQustion[0].answer[0]
                       }
                       print(question)
                   }
                }
            })
            
            if includedRooms[indexPath.row].adjusted_area == 0.0 || includedRooms[indexPath.row].room_area == 0.0
            {
                cell.moldingLbl.isHidden = true
                cell.moldingTxtLbl.isHidden = true
                cell.areaMeasuredTextLbl.text = "Stair Count: "
                cell.areaMeasured.text = "\(String(describing: includedRooms[indexPath.row].stair_count!))"
            }
            else
            {
                cell.moldingLbl.isHidden = false
                cell.moldingTxtLbl.isHidden = false
                cell.areaMeasuredTextLbl.text = "Area Measured: "
                
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleSummaryTableViewCell", for: indexPath) as! TitleSummaryTableViewCell
            cell.roomTitle.text = "Excluded Rooms"
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsTableViewCell", for: indexPath) as! RoomsTableViewCell
            cell.colorLbl.textColor = UIColor().colorFromHexString("#A7B0BA")
            cell.moldingLbl.textColor = UIColor().colorFromHexString("#A7B0BA")
            cell.areaMeasured.textColor = UIColor().colorFromHexString("#A7B0BA")
            cell.roomName.textColor = UIColor().colorFromHexString("#A7B0BA")
            cell.includedTick.isHidden = true
            cell.areaMeasured.text = "\(String(describing: excludedRooms[indexPath.row].adjusted_area!)) Sq.Ft"
            cell.roomImage.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: excludedRooms[indexPath.row].room_image_url ?? "")
            cell.roomName.text = excludedRooms[indexPath.row].room_name
            cell.colorLbl.text = excludedRooms[indexPath.row].color
            cell.moldingLbl.text = excludedRooms[indexPath.row].moulding
            cell.colorImageView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: excludedRooms[indexPath.row].material_image_url ?? "")
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:AppointmentData().appointment_id ?? 0)
            appointment.first?.rooms.forEach({ room in
               if room.room_id == excludedRooms[indexPath.row].room_id
                {
                let questionAnswers = room.questionnaires
                   questionAnswers.forEach { question in
                       if question.question_name == "Current Surface"
                       {
                           cell.currentSurface.text =  question.rf_AnswerOFQustion[0].answer[0]
                       }
                       else if question.question_name == "Remove Existing Surface"
                       {
                           cell.removeExistingLbl.text = question.rf_AnswerOFQustion[0].answer[0]
                       }
                       print(question)
                   }
                }
            })
            if excludedRooms[indexPath.row].adjusted_area == 0.0 || excludedRooms[indexPath.row].room_area == 0.0
            {
                cell.moldingLbl.isHidden = true
                cell.moldingTxtLbl.isHidden = true
                cell.areaMeasuredTextLbl.text = "Stair Count: "
                cell.areaMeasured.text = "\(String(describing: excludedRooms[indexPath.row].stair_count!))"
            }
            else
            {
                cell.moldingLbl.isHidden = false
                cell.moldingTxtLbl.isHidden = false
                cell.areaMeasuredTextLbl.text = "Area Measured: "
                
            }
            return cell
       
            
        //case 1:
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentSummaryFirstRowTableViewCell", for: indexPath) as! AppointmentSummaryFirstRowTableViewCell
            return cell
            
        }
        
        
        
        //cell.bgView.applyGradient(colors: [UIColor().colorFromHexString("#72C36F").cgColor, UIColor().colorFromHexString("#252C35").cgColor])
//        let gradientLayer = CAGradientLayer()
//
//                // Set the frame of the gradient layer to be the same as the view's frame
//                gradientLayer.frame = self.view.bounds
//
//                // Define the colors for the gradient (start and end colors)
//                gradientLayer.colors = [UIColor().colorFromHexString("#72C36F").cgColor, UIColor().colorFromHexString("#252C35").cgColor]
//
//                // Set the startPoint and endPoint for the gradient direction
//                // (0, 0) is the top-left, (1, 1) is the bottom-right
//                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//                gradientLayer.endPoint = CGPoint(x: 0, y: 1)
//
//                // Add the gradient layer to the view's layer
//        cell.bgView.layer.insertSublayer(gradientLayer, at: 0)
        
       
    }
    @objc func paymentSummaryBtnClicked(sender:UIButton)
    {
        let installer = AppointmentPaymentSummaryViewController.initialization()!
        installer.totalPrice = total
        installer.downPayment = downPayment
        installer.finalPayment = finalPayment
        installer.financeAmount = financeAmount
        self.present(installer, animated: true, completion: nil)
    }
    @objc func nextBtnAction(sender:UIButton)
    {
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "ScopeOfWork"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        if paymentType == "cash"
        {
            let web = CancellationPolicyViewController.initialization()!
            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //web.balance  = self.DownPaymentcalucaltion().balance
            web.downPayment = downPayment //self.downpayment.DownPaymentcalucaltion().downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "cash"
            web.isCardVerified = false
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            self.navigationController?.pushViewController(web, animated: true)
        }
        else if self.paymentType == "check"
        {
            let web = DynamicContractViewController.initialization()!
            //web.downPayment = self.DownPaymentcalucaltion().downPayment
            //web.balance  = self.DownPaymentcalucaltion().balance
            web.downPayment = downPayment //self.downpayment.DownPaymentcalucaltion().downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "check"
            web.isCardVerified = false
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            self.navigationController?.pushViewController(web, animated: true)
            
        }
        else if paymentType == "card"
        {
            let web = DynamicContractViewController.initialization()!
            web.downPayment = downPayment //self.downpayment.DownPaymentcalucaltion().downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "card"
            web.isCardVerified = isCardVerified
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            self.navigationController?.pushViewController(web, animated: true)
        }
        else
        {
            let web = DynamicContractViewController.initialization()!
            web.document=document
            web.orderID=orderID
            web.downPayment = downPayment
            web.total = total
            web.balance = balance
            web.paymentType = "finance"
            web.payment_TrasnsactionDict = self.payment_TrasnsactionDict
            self.navigationController?.pushViewController(web, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.section
        {
        case 0:
            return 115
        case 1:
            return 70
        case 2:
            return 183
        case 3:
            return 70
        case 4:
            return 183
        default:
            return 115
        }
        
    }
    
    
}
