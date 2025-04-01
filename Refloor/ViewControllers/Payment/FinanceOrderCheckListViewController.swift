//
//  FinanceOrderCheckListViewController.swift
//  Refloor
//
//  Created by Bincy C A on 14/02/25.
//  Copyright © 2025 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

class FinanceOrderCheckListViewController: UIViewController,ImagePickerDelegate {
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
    
    
    
    static func initialization() -> FinanceOrderCheckListViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "FinanceOrderCheckListViewController") as? FinanceOrderCheckListViewController
    }

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var financeOrderTableView: UITableView!
    var checkListArray:List<FinanceOrderCheckList>!
    var checkListArrayBool:[Bool] = [Bool]()
    var imagePicker: CaptureImage!
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
    var adminFee:Double = 0
    var selectedPaymentMethord:PaymentType?
    var downpayment = DownPaymentViewController.initialization()!
    var externalCredentialsArray:List<rf_extrenal_credential_results>!
    var totalPrice:Double = Double()
    var finalPayment:Double = Double()
    var financeAmount:Double = Double()
    var roomData:[RoomDataValue]?
    var floorShapeData:[FloorShapeDataValue]?
    var floorLevelData:[FloorLevelDataValue]?
    var appoinmentslData:AppoinmentDataValue!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        checkListArray = financeOderCheckListArray()
        self.setNavigationBarbackAndlogo(with: "Closing Checklist".uppercased())
        financeOrderTableView.register(UINib(nibName: "CheckListTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckListTableViewCell")
        checkListArrayBool = Array(repeating: false, count: checkListArray.count)
        nextBtn.borderWidth = 0
        nextBtn.borderColor = .clear
    }
    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePicker = CaptureImage(presentationController: self, delegate: self)
            self.imagePicker.present(from: sender)
            
        }
    @IBAction func NextBtnAction(_ sender: Any) 
    {
//        let allFalse = checkListArrayBool.allSatisfy { $0 == true }
//        if allFalse
//        {
            
            let applicant = UpdateCustomerDetailsOneViewController.initialization()!
            applicant.downOrFinal = self.downOrFinal
            applicant.totalAmount = self.totalAmount
            applicant.paymentPlan = self.paymentPlan
            applicant.paymentPlanValue = self.paymentPlanValue
            applicant.paymentOptionDataValue = self.paymentOptionDataValue
            applicant.drowingImageID = self.drowingImageID
            applicant.area = self.area
            applicant.downPaymentValue = self.downPaymentValue
            applicant.finalpayment = self.finalpayment
            applicant.financePayment = self.financePayment
            applicant.selectedPaymentMethord = self.selectedPaymentMethord
            applicant.downpayment = self.downpayment
            applicant.adminFee = self.adminFee
            applicant.downPaymentValue = self.downPaymentValue
            applicant.finalpayment = self.finalpayment
            applicant.financePayment = self.financePayment
            applicant.selectedPaymentMethord = self.selectedPaymentMethord
            applicant.downpayment = self.downpayment
            applicant.floorLevelData = AppDelegate.floorLevelData
            applicant.floorShapeData = []
            applicant.roomData = AppDelegate.roomData
            applicant.appoinmentslData = AppDelegate.appoinmentslData
            self.navigationController?.pushViewController(applicant, animated: true)
        }
   // }
}

extension FinanceOrderCheckListViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return checkListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListTableViewCell", for: indexPath) as! CheckListTableViewCell
        cell.checkListLbl.text = checkListArray[indexPath.row].checkListName
        cell.checkListBgBtn.tag = indexPath.row
        cell.checkListBgBtn.addTarget(self, action: #selector(checkListBtnTapped(sender:)), for: .touchUpInside)
        
        if checkListArrayBool[indexPath.row]
        {
            cell.checkListBtn.setImage(UIImage(named: "selectedRound"), for: .normal)
        }
        else
        {
            cell.checkListBtn.setImage(UIImage(named: "notSelected"), for: .normal)
        }
        return cell
    }
    
    @objc func checkListBtnTapped(sender:UIButton)
    {
        checkListArrayBool[sender.tag] = !checkListArrayBool[sender.tag]
        financeOrderTableView.reloadData()
        let allFalse = checkListArrayBool.allSatisfy { $0 == true }
        if allFalse
        {
            nextBtn.backgroundColor = UIColor().colorFromHexString("#292562")
            nextBtn.setTitleColor(UIColor().colorFromHexString("#FFFFFF"), for: .normal)
            nextBtn.isUserInteractionEnabled = true
            nextBtn.borderColor = UIColor().colorFromHexString("#A7B0BA")
            nextBtn.borderWidth = 1
        }
        else
        {
            nextBtn.backgroundColor = UIColor().colorFromHexString("#586471")
            nextBtn.setTitleColor(UIColor().colorFromHexString("#252C35"), for: .normal)
            nextBtn.isUserInteractionEnabled = false
            nextBtn.borderWidth = 0
            nextBtn.borderColor = .clear
        }
    }
    
    
}
