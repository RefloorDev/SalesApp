//
//  ViewLogListViewController.swift
//  Refloor
//
//  Created by Arun Rajendrababu on 07/01/22.
//  Copyright © 2022 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift
import Zip
var stop_syncAppointmentArray = [Int]()
class ViewLogListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, versatileBackprotocol {
    func whetherToProceedBack() {
        SceneDelegate.timer.invalidate()
        let appointment_Id = appointmentLogsArray[selectedIndex].appointment_id
//        let allAppointmentsAvailable = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d" , appointment_Id)
        stop_syncAppointmentArray.append(appointment_Id)
        let realm = try! Realm()

        try! realm.write{
            appointmentLogsArray[selectedIndex].stop_sync = true
        }
        setStopSyncValue(appointmentId: appointment_Id)
        viewLogTableView.reloadData()
       
//        BackgroundTaskService.shared.cancelAllTaskRequests()
//        BackgroundTaskService.shared.startSyncProcess()
        let appointmentRequestArray = BackgroundTaskService.shared.getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
        if(appointmentRequestArray.count != 0)
        {
            if(!SceneDelegate.timer.isValid)
            {
                SceneDelegate.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
                    
                    print("TIMER WAKEUP Appointment")
                    BackgroundTaskService.shared.startSyncProcess()
                })
            }
            
            BackgroundTaskService.shared.enterBackground()
        }
    }
    
    static func initialization() -> ViewLogListViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ViewLogListViewController") as? ViewLogListViewController
    }
    @IBOutlet weak var fetchDataBtn: UIButton!
    @IBOutlet weak var viewLogTableView: UITableView!
    @IBOutlet weak var syncAllButton: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    @IBOutlet weak var uploadLogButton: UIButton!
    @IBOutlet weak var noLogLabel: UILabel!
    @IBOutlet weak var swipeDeleteTextButton: UIButton!
    var appointmentLogsArray:Results<rf_Appointment_Logs>!
    var timer = Timer()
    var times:Int = 0;
    var appointmentId:String = String()
    var intAppointment:Int = Int()
    var message:String = String()
    var isFetchData:Bool = Bool()
    var appStatus:String = String()
    var selectedIndex:Int = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewLogTableView.estimatedRowHeight = 70
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAndRefresh), name: Notification.Name("UpdateLogView"), object: nil)
        viewLogTableView.dataSource = self
        viewLogTableView.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setNavigationBarbackAndlogo2(with: "LOGS")
        appointmentLogsArray = self.getAppointmentLogsFromDB().filter("appBaseUrl == %@", BASE_URL)
        if appointmentLogsArray.count > 0{
            viewLogTableView.reloadData()
        }
        if self.fetchAppointmentRequest().count > 0{
            syncAllButton.isHidden = false
        }else{
            syncAllButton.isHidden = true
        }
        if (self.getAppointmentLogsFromDB().filter("appBaseUrl == %@", BASE_URL)).count > 0{ //log present
            noLogLabel.isHidden = true
            viewLogTableView.isHidden = false
        }else{
            deleteAllButton.isHidden = true
            uploadLogButton.isHidden = true
            noLogLabel.isHidden = false
            viewLogTableView.isHidden = true
            swipeDeleteTextButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        intAppointment = Int(appointmentId) ?? 0
        viewLogTableView.reloadData()
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        
    }
    
//    @IBAction func uploadImages(_ sender: UIButton) 
//    {
//        let roomDrawingParams = getRoomDrawingForApiCallCustom(aptId: 45233)
//        let roomImagesParams = getRoomImagesForApiCallCustom(aptId: 45233)
//        let applicantSignatureParams = getApplicantSignatureForApiCallCustom(aptId: 45233)
//        let coApplicantSignatureParams = getCoApplicantSignatureForApiCallCustom(aptId: 45233)
//         
//        let group = DispatchGroup()
//        for drawing in roomDrawingParams
//        {
//            group.enter()
//            BackgroundTaskService.shared.syncImages(imageDict: drawing) { success in
//                group.leave()
//            }
//        }
//        for rooms in roomImagesParams
//        {
//            group.enter()
//            BackgroundTaskService.shared.syncImages(imageDict: rooms) { success in
//                group.leave()
//            }
//        }
//        
//        for applSignature in applicantSignatureParams
//        {
//            group.enter()
//            BackgroundTaskService.shared.syncImages(imageDict: applSignature) { success in
//                group.leave()
//            }
//        }
//        for coApplSignature in coApplicantSignatureParams
//        {
//            group.enter()
//            BackgroundTaskService.shared.syncImages(imageDict: coApplSignature) { success in
//                group.leave()
//            }
//        }
//        
//        group.notify(queue: DispatchQueue.main)
//        {
//            print("Success")
//        }
//        
//        
//        
//        
//    }
    override func performSegueToReturnBack()
    {
        let details = CustomerListViewController.initialization()!
        self.navigationController?.pushViewController(details, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentLogsArray.count == 0 ? 0 :  appointmentLogsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewLogTableViewCell", for: indexPath) as! ViewLogTableViewCell
        
        cell.sendReviewLinkBtn.tag = indexPath.row
        cell.sendReviewLinkBtn.addTarget(self, action: #selector(sendReviewAction(sender: )), for: .touchUpInside)
        let title = "Send Review Link"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 22 // Set line spacing

        let attributedString = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .paragraphStyle: paragraphStyle
            ]
        )
        cell.sendReviewLinkBtn.setAttributedTitle(attributedString, for: .normal)
        
        cell.transactionMsgLbl.isHidden = true
        //cell.transactionMsgLblHeightConstraint.constant = 0
        cell.selectionStyle = .none
        appStatus = "Sync Completed"
    
        if  self.fetchAppointmentRequest(for: appointmentLogsArray[indexPath.row].appointment_id).count > 0
        {
            appStatus = "Sync Pending"
        }
        if appStatus == "Sync Pending"
        {
//            if appointmentLogsArray[indexPath.row].stop_sync == false{
//                cell.stopSyncButton.isHidden = false
//                cell.syncNowButton.isHidden = true
//        }else{
//            cell.stopSyncButton.isHidden = true
//            cell.syncNowButton.isHidden = false
//        }
            
            let isStopSync = appointmentLogsArray[indexPath.row].stop_sync
            cell.stopSyncButton.isHidden = isStopSync
            cell.syncNowButton.isHidden = !isStopSync

            
            if isFetchData == true
            {
                fetchDataBtn.isHidden = false
            }
            cell.syncBtn.setBackgroundImage(UIImage(named: "syncPending"), for: .normal)
            cell.appointmentStatusLabel.textColor = UIColor.lightGray
            cell.appointmentStatusLabel.text = appStatus
            if message != "" && intAppointment == appointmentLogsArray[indexPath.row].appointment_id
            {
                cell.transactionMsgLbl.isHidden = false
                cell.transactionMsgLbl.text = message
            }
            if  appointmentLogsArray[indexPath.row].paymentStatus == "Failed"
            {
                cell.transactionMsgLbl.isHidden = false
                cell.transactionMsgLbl.text = appointmentLogsArray[indexPath.row].paymentMessage
            }
        }
        else
        {
            cell.stopSyncButton.isHidden = true
            cell.syncNowButton.isHidden = true
            
            if isFetchData == true
            {
                fetchDataBtn.isHidden = true
            }
            cell.appointmentStatusLabel.text = appStatus
           if appointmentLogsArray[indexPath.row].paymentStatus == "Success" || appointmentLogsArray[indexPath.row].paymentStatus == "Not Done" || appointmentLogsArray[indexPath.row].paymentStatus == "" 
            {
            cell.syncBtn.setBackgroundImage(UIImage(named: "syncSuccess"), for: .normal)
            cell.appointmentStatusLabel.textColor = UIColor().colorFromHexString("#72C36F")
            }
            
            else
            {
               // print((appointmentLogsArray[indexPath.row].paymentStatus))
                if self.message != "" || intAppointment == appointmentLogsArray[indexPath.row].appointment_id || appointmentLogsArray[indexPath.row].paymentStatus == "Failed"
                {
                    cell.appointmentStatusLabel.text = appStatus
                    cell.syncBtn.setBackgroundImage(UIImage(named: "syncSuccess"), for: .normal)
                    cell.appointmentStatusLabel.textColor = .white
                    cell.transactionMsgLbl.text = appointmentLogsArray[indexPath.row].paymentMessage
                    cell.transactionMsgLbl.isHidden = false
                    //cell.transactionMsgLblHeightConstraint.constant = 19
                }
            }
            
        }
        //cell.appointmentStatusLabel.text = appStatus
       // cell.appointmentStatusLabel.textColor = UIColor.lightGray
        let appointment_id = (appointmentLogsArray[indexPath.row].appointment_id)
        let appointment = self.getAppointmentData(appointmentId: appointment_id)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        var date = appointment?.appointment_datetime ?? ""
        if date == ""{
            if ((appointment?.appointment_date ?? "").VaildDateFromStringForServerLeave()){
                date = (appointment?.appointment_date ?? "")
            }else{
                date = (appointment?.appointment_date ?? "").DateFromStringForServerLeave().appointmentDateStr()
            }
        }
        let text = name + "\n" + "(" + date + ")"
        let range = (text as NSString).range(of: date)
        let mutableAttributedString = NSMutableAttributedString.init(string: text)
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Avenir-Medium", size: 18)!, range: range)
        cell.appointmentIdLabel.attributedText = mutableAttributedString
       
        cell.stopSyncButton.tag = indexPath.row
        cell.stopSyncButton.addTarget(self, action: #selector(stopsyncButtonAction(sender:)), for: .touchUpInside)
        cell.syncNowButton.tag = indexPath.row
        cell.syncNowButton.addTarget(self, action: #selector(syncNowButtonAction(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selAppointment = "\(appointmentLogsArray[indexPath.row].appointment_id)"
        let appointmentLogArr = (appointmentLogsArray[indexPath.row].sync_message)
        let details = ViewLodDetailsViewController.initialization()!
        details.selectedAppointmentId = selAppointment
        details.appointmentLogsArray = appointmentLogArr
        self.navigationController?.pushViewController(details, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "DELETE") {  (contextualAction, view, boolValue) in
            print(indexPath.row)
            if self.syncStatusForAppointment(appointmentId: self.appointmentLogsArray[indexPath.row].appointment_id)
            {
                
                if self.appointmentLogsArray[indexPath.row].stop_sync != true
                {
                    let appointmentId = self.appointmentLogsArray[indexPath.row].appointment_id
                    self.deleteAppointmentLog(appointmentId: appointmentId, deleteAll: false)
                    self.appointmentLogsArray = self.getAppointmentLogsFromDB()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    boolValue(true)
                    if self.appointmentLogsArray.count == 0{
                        DispatchQueue.main.async{
                            self.deleteAllButton.isHidden = true
                            self.uploadLogButton.isHidden = true
                            self.noLogLabel.isHidden = false
                            self.viewLogTableView.isHidden = true
                            self.swipeDeleteTextButton.isHidden = true
                        }
                    }
                }
                
                else
                {
                    self.alert("You cannot delete an appointment log which is in ‘Sync Stopped’ state.", nil)
                }
            }
            else
            {
                self.alert("You cannot delete an appointment log which is in ‘Sync Pending’ state.", nil)
            }
    }
        deleteAction.image = UIImage(systemName: "trash")
//        //deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: 36, height: 36)).image {
//            _ in UIImage(named: "trash")!.draw(in: CGRect(x: 0, y: 0, width: 150, height: 80))
//        }
//        deleteAction.accessibilityFrame = CGRect(x: 0, y: 0, width: 150, height: 80)
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    // MARK: - DELETE LOGS
    @IBAction func deleteAllLogsAction(_ sender: UIButton) {
        let yes = UIAlertAction(title: "Delete", style:.default) { (_) in
            for appointments in self.appointmentLogsArray
            {
                if self.syncStatusForAppointment(appointmentId: appointments.appointment_id) == true
                {
                    let realm = try! Realm()

                    try! realm.write{
                        //workIndex = workRequestIdArray.firstIndex(of: workRequestIdArray.filter({$0.work_Request_id == workId}).first ?? Work_request_list()) ?? 0
                        let logIndex = self.appointmentLogsArray.firstIndex(of: self.appointmentLogsArray.filter({$0.appointment_id == appointments.appointment_id}).first ?? rf_Appointment_Logs()) ?? 0
                        self.appointmentLogsArray[logIndex].stop_sync = false
                    }
                    self.deleteAppointmentLog(appointmentId: appointments.appointment_id, deleteAll: false)
                    self.appointmentLogsArray = self.getAppointmentLogsFromDB()
                    self.viewLogTableView.reloadData()
               }
                else
                {
                    let logArray = self.appointmentLogsArray.filter("stop_sync == %@", true)
                    if logArray.count > 0
                    {
                        self.alert("You cannot delete an appointment log which is in ‘Sync Stopped’ state.", nil)
                    }
                    else
                    {
                        self.alert("You cannot delete an appointment log which is in ‘Sync Pending’ state.", nil)
                    }
                }
            }
            
            //self.appointmentLogsArray = self.getAppointmentLogsFromDB()
            
            DispatchQueue.main.async{
                
                
                if self.appointmentLogsArray.count == 0
                {
                    self.noLogLabel.isHidden = false
                    self.viewLogTableView.isHidden = true
                    self.deleteAllButton.isHidden = true
                    self.uploadLogButton.isHidden = true
                    self.swipeDeleteTextButton.isHidden = false
                    //self.alert("Unable to delete logs for appointments with stopped syncing. Please resume syncing to proceed.", nil)
                }
                else
                {
                    self.noLogLabel.isHidden = true
                    self.viewLogTableView.isHidden = false
                    self.deleteAllButton.isHidden = false
                    self.uploadLogButton.isHidden = false                }
                    self.swipeDeleteTextButton.isHidden = false
                    
            }
        }
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.alert("Are you sure you want to delete all logs?", [yes,no])
    }
    @objc func sendReviewAction(sender:UIButton)
    {
        let aptResult = getCompletedAppointmentsFromDB(appointmentId: appointmentLogsArray[sender.tag].appointment_id)
        let aplPhone = aptResult.first?.applicant_phone ?? ""
        sendReviewBtnTapped(aptId: appointmentLogsArray[sender.tag].appointment_id,applicantPhone: aplPhone)
    }
    func sendReviewBtnTapped(aptId:Int,applicantPhone:String)
    {
        let parameter:[String:Any] = ["appointment_id": aptId,"phone":applicantPhone]
        HttpClientManager.SharedHM.sendReviewLinkAPi(parameter: parameter) { success, message in
            if (success ?? "") == "Success"
            {
                let selectRoomPopUp = SelectRoomCommentPopUpViewController.initialization()!
                selectRoomPopUp.isSuccess = true
                selectRoomPopUp.isSendReview = true
                selectRoomPopUp.isSuccessMsg = true
                
                self.present(selectRoomPopUp, animated: true, completion: nil)
            }
            else if success == "Failed"
            {
                let selectRoomPopUp = SelectRoomCommentPopUpViewController.initialization()!
                selectRoomPopUp.isSuccess = true
                selectRoomPopUp.sendReviewFailedMsg = message ?? ""
                selectRoomPopUp.isSuccessMsg = false
                self.present(selectRoomPopUp, animated: true, completion: nil)
            }
            
            else{
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.sendReviewBtnTapped(aptId: aptId,applicantPhone: applicantPhone)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert(AppAlertMsg.serverNotReached, [yes,no])
                
            }
        }
    }
    @objc func stopsyncButtonAction( sender: UIButton) {
        
        selectedIndex = sender.tag
        let selectRoomPopUp = SelectRoomCommentPopUpViewController.initialization()!
        selectRoomPopUp.versatileBack = self
        selectRoomPopUp.isEdit = false
        selectRoomPopUp.isVersatile = false
        selectRoomPopUp.isStopSync = true
        self.present(selectRoomPopUp, animated: true, completion: nil)
       
        
    }
    @objc func syncNowButtonAction( sender: UIButton) {
        selectedIndex = sender.tag
        SceneDelegate.timer.invalidate()
        let appointment_Id = appointmentLogsArray[sender.tag].appointment_id
        if stop_syncAppointmentArray.contains(appointment_Id){
            if let index = stop_syncAppointmentArray.firstIndex(of: appointment_Id) {
                stop_syncAppointmentArray.remove(at: index)
                print("Value not found in the array.")
            }
            
        }
        let realm = try! Realm()

        try! realm.write{
            appointmentLogsArray[selectedIndex].stop_sync = false
        }
        viewLogTableView.reloadData()
        setSyncNowValue(appointmentId: appointment_Id)
        let appointmentRequestArray = BackgroundTaskService.shared.getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
        if(appointmentRequestArray.count != 0)
        {
            if(!SceneDelegate.timer.isValid)
            {
                SceneDelegate.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
                    
                    print("TIMER WAKEUP Appointment")
                    BackgroundTaskService.shared.startSyncProcess()
                })
            }
            
            BackgroundTaskService.shared.enterBackground()
        }
       
//        BackgroundTaskService.shared.cancelAllTaskRequests()
//       let filteredappointmentRequestArray = BackgroundTaskService.shared.getAppointmentsToSyncNowFromDB(appointment_Id: appointment_Id)
//        BackgroundTaskService.shared.startSyncProcessForsyncNow(appointmentRequestArray: filteredappointmentRequestArray)
        
    }
    
    @IBAction func fetchDataBtnClicked(_ sender: UIButton)
    {
        retrieveData()
    }
    
    @objc func reloadAndRefresh(){
        DispatchQueue.main.async
        {
            self.showhideHUD(viewtype: .HIDE)
            
        }
        appointmentLogsArray = self.getAppointmentLogsFromDB()
        self.viewLogTableView.reloadData()
        if self.fetchAppointmentRequest().count > 0{
            syncAllButton.isHidden = false
        }else{
            syncAllButton.isHidden = true
        }
        if appointmentLogsArray.count > 0{ //log present
            noLogLabel.isHidden = true
            viewLogTableView.isHidden = false
        }else{
            deleteAllButton.isHidden = true
            uploadLogButton.isHidden = true
            noLogLabel.isHidden = false
            viewLogTableView.isHidden = true
            swipeDeleteTextButton.isHidden = true
        }
    }
    // MARK: - SYNC ALL APPOINTMENTS
    @IBAction func syncAllAction(_ sender: UIButton) {
        
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            let appointmentRequestArray = BackgroundTaskService.shared.getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
            if(appointmentRequestArray.count != 0)
            {
                SceneDelegate.timer.invalidate()
                DispatchQueue.main.async{
                    self.showhideHUD(viewtype: .SHOW, title: "Syncing pending appointments. Please wait...")
                }
                if(!SceneDelegate.timer.isValid)
                {
                    SceneDelegate.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
                        print("TIMER WAKEUP Appointment")
                        BackgroundTaskService.shared.startManualSyncProcess()
                    })
                }
                
               // BackgroundTaskService.shared.enterBackground()
            }else{
                //delete item
                self.deleteAllRoomImagesFromAppointmentRequest()
            }
        }
        
        else{
            // self.alert(message ?? AppAlertMsg.serverNotReached , nil)
            let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                self.syncAllAction(sender)
            }
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            self.alert(AppAlertMsg.serverNotReached, [yes,no])
        }
    }
    
    // MARK: - UPLOAD LOG
    @IBAction func uploadLogAction(_ sender: UIButton) {
        isFetchData = true
        self.fetchDataBtn.isHidden = false
        let yes = UIAlertAction(title: "Upload", style:.default) { (_) in
            
            self.uploadLog()
        }
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.alert("Are you sure you want to upload all log files?", [yes,no])
    }
    
    
    func uploadLog(){
        
        for appointments in self.appointmentLogsArray
        {
//            if self.syncStatusForAppointment(appointmentId: appointments.appointment_id)
//            {
                let appointmentLogs = self.getAppointmentLogDetailsFromDB().filter({$0.appointment_id == appointments.appointment_id})
                if appointmentLogs.count > 0
                {
                    
                
                var appointmentLogsArray:[[String:Any]] = []
                appointmentLogs.forEach { appointmentLog in
                    let appointmentId = appointmentLog.appointment_id
                    let message = appointmentLog.sync_message ?? ""
                    //let appointmentTime = appointmentLog.sync_time?.logDate().logDataAsString() ?? ""
                    let appointmentTime = appointmentLog.sync_time ?? ""
                    let dict:[String:Any] = ["appointment_id":appointmentId,"message":message,"sync_time":appointmentTime]
                    appointmentLogsArray.append(dict)
                }
                
                let paramsDict:[String:Any] = ["token":UserData.init().token ?? "", "data":appointmentLogsArray]
                HttpClientManager.SharedHM.uploadLogsToServer(parameter: paramsDict) { result, message in
                    if (result ?? "") == "Success"
                    {
                        let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                            //self.deleteAppointmentLog(appointmentId: appointments.appointment_id, deleteAll: false)
                            self.appointmentLogsArray = self.getAppointmentLogsFromDB()
                            self.viewLogTableView.reloadData()
                            DispatchQueue.main.async{
                                
                                
                                if appointmentLogsArray.count == 0
                                {
                                    self.viewLogTableView.isHidden = true
                                    self.noLogLabel.isHidden = false
                                    self.deleteAllButton.isHidden = true
                                    self.uploadLogButton.isHidden = true
                                    self.swipeDeleteTextButton.isHidden = true
                                    self.syncAllButton.isHidden = true
                                }
                                else
                                {
                                    self.viewLogTableView.isHidden = false
                                    self.viewLogTableView.reloadData()
                                    self.noLogLabel.isHidden = true
                                    self.deleteAllButton.isHidden = false
                                    self.uploadLogButton.isHidden = false
                                    self.swipeDeleteTextButton.isHidden = false
                                    self.syncAllButton.isHidden = false
                                }
                                
                                if self.appStatus == "Sync Completed" && self.viewLogTableView.isHidden == true
                                {
                                    self.fetchDataBtn.isHidden = true
                                }
                                else
                                {
                                    self.fetchDataBtn.isHidden = false
                                }
                                //self.viewLogTableView.reloadData()
                                
                            }
                        }
                        self.alert(message ?? AppAlertMsg.serverNotReached, [ok])
                    }
                    
                    else
                    {
                        let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                            
                            self.uploadLog()
                            
                        }
                        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    }
                }
            }
                else
                {
                    //self.deleteAppointmentLog(appointmentId: appointments.appointment_id, deleteAll: false)
                    self.appointmentLogsArray = self.getAppointmentLogsFromDB()
                    self.viewLogTableView.reloadData()
                }
          //  }
//            else
//            {
//                if appointments.stop_sync == true
//                {
//                    self.alert("Unable to upload logs for appointments with stopped syncing. Please resume syncing to proceed.", nil)
//                }
//            }
        }
       // }
//        else
//        {
//            self.alert("Unable to upload logs for appointments with stopped syncing. Please resume syncing to proceed.", nil)
//        }
    }
}


extension ViewLogListViewController{
    func getAppointmentsToSyncFromDB(requestTitle:RequestTitle) -> Results<rf_Completed_Appointment_Request> {
        var reqTitle:RequestTitle = requestTitle
        var appointmentRequestArray:Results<rf_Completed_Appointment_Request>!
        switch reqTitle {
        case .CustomerAndRoom:
            appointmentRequestArray = self.fetchCustomerAndRoomFromAppointmentRequest()
            if appointmentRequestArray.isEmpty{
                reqTitle = RequestTitle.ImageUpload
                return self.getAppointmentsToSyncFromDB(requestTitle: reqTitle)
            }else{
                return appointmentRequestArray
            }
//        case .ContactDetails:
//            appointmentRequestArray = self.fetchContractFromAppointmentRequest()
//            if appointmentRequestArray.isEmpty{
//                reqTitle = RequestTitle.ImageUpload
//                return self.getAppointmentsToSyncFromDB(requestTitle: reqTitle)
//            }else{
//                return appointmentRequestArray
//            }
        case .ImageUpload:
            appointmentRequestArray = self.fetchImageAppointmentRequest()
            if appointmentRequestArray.isEmpty{
                reqTitle = RequestTitle.GenerateContract
                return self.getAppointmentsToSyncFromDB(requestTitle: reqTitle)
            }else{
                return appointmentRequestArray
            }
        case .GenerateContract:
            appointmentRequestArray = self.fetchGenerateContractFromAppointmentRequest()
            if appointmentRequestArray.isEmpty{
                reqTitle = RequestTitle.InitiateSync
                return self.getAppointmentsToSyncFromDB(requestTitle: reqTitle)
            }else{
                return appointmentRequestArray
            }
        case .InitiateSync:
            appointmentRequestArray = self.fetchi360FromAppointmentRequest()
            return appointmentRequestArray
        }
        
        return appointmentRequestArray
    }
    
//    func startSyncProcess(){
//        var ifAnyApiFailed = false
//        var spinnerStatus:Int = 0
//        times += 1
//        if HttpClientManager.SharedHM.connectedToNetwork(){
//            DispatchQueue.main.async{
//                self.showhideHUD(viewtype: .SHOW, title: "Syncing pending appointments. Please wait...")
//
//            }
//            let appointmentRequestArray = getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
//            if(appointmentRequestArray.count == 0)
//            {
//                timer.invalidate()
//                DispatchQueue.main.async{
//                    self.showhideHUD(viewtype: .HIDE)
//                    self.refreshAction()
//                }
//
//            }
//            //            else  if(appointmentRequestArray.count == 0 && times)
//            //            {
//            //
//            //            }
//            //
//            for appointmentRequest in appointmentRequestArray{
//                spinnerStatus = appointmentRequestArray.count
//
//                switch appointmentRequest.reqest_title {
//                case RequestTitle.CustomerAndRoom.rawValue:
//                    let (appointmentId, requestParams, _) =  self.createCustomerAndRoomParametersForApiCall(completedAppointmentRequest: appointmentRequest)
//                    self.syncCustomerAndRoomData(appointmentId: appointmentId, parameter: requestParams){ ifSuccess in
//                        spinnerStatus = spinnerStatus - 1
//
//                        if !ifSuccess{
//                            print("Spinner Count:1")
//                            ifAnyApiFailed = true
//                            return
//                        }else{
//                            print("Spinner Count:2")
//                            ifAnyApiFailed = false
//                        }
//                    }
//                    break
//                case RequestTitle.ContactDetails.rawValue:
//                    let (appointmentId, requestParams, _) =  self.createContractDetailsParametersForApiCall(completedAppointmentRequest: appointmentRequest)
//                    self.syncContractData(appointmentId: appointmentId, parameter: requestParams){ ifSuccess in
//                        spinnerStatus = spinnerStatus - 1
//                        if !ifSuccess{
//                            print("Spinner Count:3")
//                            ifAnyApiFailed = true
//                            return
//                        }else{
//                            print("Spinner Count:4")
//                            ifAnyApiFailed = false
//                        }
//                    }
//                    break
//                case RequestTitle.ImageUpload.rawValue:
//                    let requestParams =  self.createImageUploadParametersForApiCall(completedAppointmentRequest: appointmentRequest)
//                    self.syncImages(imageDict: requestParams){ ifSuccess in
//                        spinnerStatus = spinnerStatus - 1
//                        if !ifSuccess{
//                            print("Spinner Count:5")
//                            ifAnyApiFailed = true
//                            return
//                        }else{
//                            print("Spinner Count:6")
//                            ifAnyApiFailed = false
//                        }
//                    }
//                    break
//                case RequestTitle.GenerateContract.rawValue:
//                    let (appointmentId, requestParams, _) =  self.createGenerateContractParametersForApiCall(completedAppointmentRequest: appointmentRequest)
//                    self.syncGenerateContract(appointmentId:appointmentId,parameter: requestParams){ ifSuccess in
//                        spinnerStatus = spinnerStatus - 1
//                        if !ifSuccess{
//                            print("Spinner Count:7")
//                            ifAnyApiFailed = true
//                            return
//                        }else{
//                            print("Spinner Count:8")
//                            ifAnyApiFailed = false
//                        }
//                    }
//                    break
//                case RequestTitle.InitiateSync.rawValue:
//                    let (appointmentId, requestParams, _) = createInitiate_i360_SyncParametersForApiCall(completedAppointmentRequest: appointmentRequest)
//
//                    spinnerStatus = spinnerStatus - 1
//                    if HttpClientManager.SharedHM.connectedToNetwork(){
//                        print("Spinner Count:9")
//                        self.sync_i360(appointmentId: appointmentId, parameter: requestParams)
//                        self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync)
//                    }
//                    break
//                case .none:
//                    break
//                case .some(_):
//                    break
//                }
//            }
//            print("Spinner Count final:\(spinnerStatus)")
//            //            if(spinnerStatus <= 0)
//            //            {
//            //                DispatchQueue.main.async{
//            //                    self.showhideHUD(viewtype: .HIDE)
//            //                    self.refreshAction()
//            //                }
//            //            }
//
//            if ifAnyApiFailed{
//                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//                    self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
//                        print("START ALL PENDING SYNC OPERATIONS")
//                        self.startSyncProcess()
//                        //                        DispatchQueue.main.async{
//                        //                            self.showhideHUD(viewtype: .SHOW, title: "Completed appointment sync in-progress. Please wait...")
//                        //
//                        //                        }
//                    })
//                }
//                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
//
//                    self.showhideHUD(viewtype: .HIDE)
//                    self.times = 0
//                    self.timer.invalidate()
//                })
//                self.alert("Something went wrong... Please try again.", [yes,no])
//            }
//            if times > 4
//            {
//                DispatchQueue.main.async
//                {
//                    self.times = 0
//                    self.timer.invalidate()
//                    self.showhideHUD(viewtype: .HIDE)
//                    self.refreshAction()
//                    self.viewLogTableView.reloadData()
//                }
//            }
//        }else{
//
//            DispatchQueue.main.async{
//                self.showhideHUD(viewtype: .HIDE)
//                self.times = 0
//                self.timer.invalidate()
//                //  self.refreshAction()
//            }
//
//            let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//
//                DispatchQueue.main.async{
//                    self.showhideHUD(viewtype: .SHOW, title: "Completed appointment sync in-progress. Please wait...")
//
//                }
//                self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
//                    print("START ALL PENDING SYNC OPERATIONS")
//                    self.startSyncProcess()
//
//                })
//            }
//
//            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
//
//                self.showhideHUD(viewtype: .HIDE)
//                self.times = 0
//                self.timer.invalidate()
//            })
//
//            self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
//        }
//    }
    
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
    
    func createCustomerAndRoomParametersForApiCall(completedAppointmentRequest:rf_Completed_Appointment_Request) -> (appointmentId: Int, requestParams: [String:Any], requestUrl: String){
        let appointment_id = completedAppointmentRequest.appointment_id
        let apiUrl = completedAppointmentRequest.request_url ?? ""
        var paramsDict:[String:Any] = completedAppointmentRequest.request_parameter?.dictionaryValue() ?? [:]
        paramsDict["token"] = UserData.init().token ?? ""
        return (appointmentId: appointment_id, requestParams:paramsDict, requestUrl: apiUrl)
    }
    
    func createContractDetailsParametersForApiCall(completedAppointmentRequest:rf_Completed_Appointment_Request) -> (appointmentId: Int, requestParams: [String:Any], requestUrl: String){
        let appointment_id = completedAppointmentRequest.appointment_id
        let apiUrl = completedAppointmentRequest.request_url ?? ""
        var paramsDict:[String:Any] = completedAppointmentRequest.request_parameter?.dictionaryValue() ?? [:]
        paramsDict["token"] = UserData.init().token ?? ""
        return (appointmentId: appointment_id, requestParams:paramsDict, requestUrl: apiUrl)
    }
    
    func createImageUploadParametersForApiCall(completedAppointmentRequest:rf_Completed_Appointment_Request) -> [String:Any]{
        let paramsDict:[String:Any] = completedAppointmentRequest.request_parameter?.dictionaryValue() ?? [:]
        return paramsDict
    }
    
    func createGenerateContractParametersForApiCall(completedAppointmentRequest:rf_Completed_Appointment_Request) -> (appointmentId: Int, requestParams: [String:Any], requestUrl: String){
        let appointment_id = completedAppointmentRequest.appointment_id
        let apiUrl = completedAppointmentRequest.request_url ?? ""
        var paramsDict:[String:Any] = completedAppointmentRequest.request_parameter?.dictionaryValue() ?? [:]
        paramsDict["token"] = UserData.init().token ?? ""
        return (appointmentId: appointment_id, requestParams:paramsDict, requestUrl: apiUrl)
    }
    
    func createInitiate_i360_SyncParametersForApiCall(completedAppointmentRequest:rf_Completed_Appointment_Request) -> (appointmentId: Int, requestParams: [String:Any], requestUrl: String){
        let appointment_id = completedAppointmentRequest.appointment_id
        let apiUrl = completedAppointmentRequest.request_url ?? ""
        var paramsDict:[String:Any] = completedAppointmentRequest.request_parameter?.dictionaryValue() ?? [:]
        paramsDict["token"] = UserData.init().token ?? ""
        
        return (appointmentId: appointment_id, requestParams:paramsDict, requestUrl: apiUrl)
    }
    
    func syncCustomerAndRoomData(appointmentId:Int, parameter:[String:Any], completion: @escaping (Bool) -> ()){
        //Writing Logs
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.appointmentStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        //
        HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(parameter: parameter, isOnlineCollectBtnPressed: false) { success, message,payment_status,payment_message,transactionId,cardType  in
            if(success ?? "") == "Success"{
                print(message ?? "No msg")
                //Writing Logs
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "" ,payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "" ,payment_message: payment_message ?? "")
                //
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.CustomerAndRoom)
                completion(true)
            }else{
                //Writing Logs
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "" ,payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "" ,payment_message: payment_message ?? "")
                //
                completion(false)
            }
        }
    }
    
//    func syncContractData(appointmentId:Int, parameter:[String:Any], completion: @escaping (Bool) -> ()){
//        let appointment = self.getAppointmentData(appointmentId: appointmentId)
//        let firstName = appointment?.applicant_first_name ?? ""
//        let lastName = appointment?.applicant_last_name ?? ""
//        let name = lastName == ""  ? firstName : firstName + " " + lastName
//        let date = appointment?.appointment_datetime ?? ""
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//        HttpClientManager.SharedHM.updateContractInfoAPi(parameter: parameter) { success, message in
//
//            if(success ?? "") == "Success"{
//                print(message ?? "No msg")
//                //Logs
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
//                //
//                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.ContactDetails)
//                completion(true)
//            }else{
//                //Logs
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
//                //
//                completion(false)
//            }
//        }
//    }
    
    func syncImages(imageDict:[String:Any], completion: @escaping (Bool) -> ()){
        let room = imageDict
        let appoint_id = room["appointment_id"]  as? Int ?? 0
        let image_name = room["image_name"] as? String ?? ""
        let image_type = room["image_type"] as? String ?? ""
        //log
        self.addImageStatLogs(appointmentId: appoint_id, imageType: image_type)
        //
        let file = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: image_name) ?? UIImage()
        let room_id = (room["room_id"] as? Int ?? 0)
        let room_name = room["room_name"] as? String ?? ""
        let room_id_str = String(room_id)
        var networkMessage = ""
        let speedTest = NetworkSpeedTest()
        speedTest.testUploadSpeed { speed in
            print("Upload speed: \(speed) Mbps")
            networkMessage = String(format: "%.2f", speed)
            networkMessage += "Mbps"
        }
        HttpClientManager.SharedHM.syncImagesOfAppointment(appointmentId: String(appoint_id ?? 0), roomId: room_id_str, attachments: file, imagename: image_name, imageType: image_type,roomName: room_name,networkMessage: networkMessage) { success, message, imageName in
            if(success ?? "") == "Success"{
                print(message ?? "No msg")
                if let imageNam = imageName{
                    self.addImageCompleteLogs(appointmentId: appoint_id)
                    self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appoint_id, requestTitle:  RequestTitle.ImageUpload, imageName: imageNam)
                    completion(true)
                }
                completion(false)
            }else{
                self.addImageFailLogs(appointmentId: appoint_id, errorMessage: "Error image upload not complete")
                completion(false)
            }
        }
        
    }
    
    func syncGenerateContract(appointmentId:Int, parameter:[String:Any], completion: @escaping (Bool) -> ()){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.generateContractSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        HttpClientManager.SharedHM.generateContactAPi(parameter: parameter) { success, message in
            
            if(success ?? "") == "Success"{
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.generateContractSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
                print(message ?? "No msg")
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.GenerateContract)
                self.deleteSyncCompletedAppointmentFromAppointmentDB(appointmentId: appointmentId)
                completion(true)
            }else{
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.generateContractSyncCompleted.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
                completion(false)
            }
        }
    }
    
    
    func sync_i360(appointmentId:Int, parameter:[String:Any]){
        HttpClientManager.SharedHM.initiateSync_i360_APi(parameter: parameter) { success, message in
            if(success ?? "") == "Success"{
                print(message ?? "No msg")
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync)
            }
        }
    }
    
    func addImageStatLogs(appointmentId: Int, imageType:String){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        switch imageType {
        case "measurement_image":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "room_photo":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "protrusion_image":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "applicant_signature":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.signatureSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "applicant_initial":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.initialsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        case "snapshot":
            self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.snapshotDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        default:
            break
        }
    }
    
    func addImageCompleteLogs(appointmentId: Int){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.signatureSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.initialsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.snapshotDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
    }
    
    func addImageFailLogs(appointmentId: Int,errorMessage:String){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomMeasurementSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.signatureSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.initialsSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.snapshotDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(), errorMessage: errorMessage,name:name ,appointmentDate:date)
    }
    
    func retrieveData()
    {
        HttpClientManager.SharedHM.showhideHUD(viewtype: .SHOW, title: "Submitting Data and making zip file...")
        let completedAppointments = getCompletedAppointmentData()
        let completedAppointmenturlParamaterData = getCompletedAppointmentUrlParameterData()
        //getAppointmentsToSyncFromDB(requestTitle: RequestTitle.GenerateContract)
        //fetchGenerateContractFromAppointmentRequest()
        //var completedAppointmentsArray:[[String:Any]] = [[:]]
//        if completedAppointmenturlParamaterData!.count > 0
//        {
//            for appointments in completedAppointmenturlParamaterData!
//            {
//                var completedAppointmentDictionary:[String:Any] = [:]
//                completedAppointmentDictionary["appointment_id"] = appointments.appointment_id
//                completedAppointmentDictionary["reqest_title"] = appointments.reqest_title
//                completedAppointmentDictionary["request_url"] = appointments.request_url
//                completedAppointmentDictionary["request_parameter"] = appointments.request_parameter
//                completedAppointmentDictionary["request_type"] = appointments.request_type
//                completedAppointmentDictionary["image_name"] = appointments.image_name
//                completedAppointmentDictionary["sync_status"] = appointments.sync_status
//                
//                let url = createAppointmentZip(appointmentID: String(appointments.appointment_id), data: completedAppointmentDictionary, imagePaths: [])
//                 HttpClientManager.SharedHM.CompressFileOfAppointment(appointmentId: String(appointmentId), fileURL: url) { success, message in
//                     if(success ?? "") == "Success"
//                     {
//                         
//                     }
//                     else
//                     {
//                         
//                     }
//                 }
//                //appointment_id: Int = 0
////                @objc dynamic var reqest_title: String?
////                @objc dynamic var request_url: String?
////                @objc dynamic var request_parameter: String?
////                @objc dynamic var request_type: String?
////                @objc dynamic var sync_status: Bool = false
////                @objc dynamic var image_name: String?
//            }
//        }
        
        if completedAppointments!.count > 0
        {
            for appointments in completedAppointments!
            {
                var completedAppointmentDictionary:[String:Any] = [:]
                completedAppointmentDictionary["appointment_id"] = appointments.appointment_id
                completedAppointmentDictionary["appointment_date"] = appointments.appointment_date
                completedAppointmentDictionary["appointment_datetime"] = appointments.appointment_datetime
                completedAppointmentDictionary["customer_id"] = appointments.customer_id
                completedAppointmentDictionary["applicant_first_name"] = appointments.applicant_first_name
                completedAppointmentDictionary["applicant_middle_name"] = appointments.applicant_middle_name
                completedAppointmentDictionary["applicant_last_name"] = appointments.applicant_last_name
                completedAppointmentDictionary["applicant_street"] = appointments.applicant_street
                completedAppointmentDictionary["applicant_street2"] = appointments.applicant_street2
                completedAppointmentDictionary["applicant_city"] = appointments.applicant_city
                completedAppointmentDictionary["applicant_state_code"] = appointments.applicant_state_code
                completedAppointmentDictionary["applicant_zip"] = appointments.applicant_zip
                completedAppointmentDictionary["applicant_phone"] = appointments.applicant_phone
                completedAppointmentDictionary["applicant_country_code"] = appointments.applicant_country_code
                completedAppointmentDictionary["applicant_country"] = appointments.applicant_country
                completedAppointmentDictionary["applicant_email"] = appointments.applicant_email
                completedAppointmentDictionary["sales_person"] = appointments.sales_person
                completedAppointmentDictionary["salesperson_id"] = appointments.salesperson_id
                completedAppointmentDictionary["partner_latitude"] = appointments.partner_latitude
                completedAppointmentDictionary["partner_longitude"] = appointments.partner_longitude
                completedAppointmentDictionary["applicant_country_id"] = appointments.applicant_country_id
                completedAppointmentDictionary["co_applicant_first_name"] = appointments.co_applicant_first_name
                completedAppointmentDictionary["co_applicant_middle_name"] = appointments.co_applicant_middle_name
                completedAppointmentDictionary["co_applicant_last_name"] = appointments.co_applicant_last_name
                completedAppointmentDictionary["co_applicant_address"] = appointments.co_applicant_address
                completedAppointmentDictionary["co_applicant_city"] = appointments.co_applicant_city
                completedAppointmentDictionary["co_applicant_state"] = appointments.co_applicant_state
                completedAppointmentDictionary["co_applicant_zip"] = appointments.co_applicant_zip
                completedAppointmentDictionary["co_applicant_secondary_phone"] = appointments.co_applicant_secondary_phone
                completedAppointmentDictionary["co_applicant_phone"] = appointments.co_applicant_phone
                completedAppointmentDictionary["co_applicant_email"] = appointments.co_applicant_email
                completedAppointmentDictionary["applicantAndIncomeData"] = appointments.applicantAndIncomeData
                completedAppointmentDictionary["paymentDetails"] = appointments.paymentDetails
                completedAppointmentDictionary["applicantSignatureImage"] = appointments.applicantSignatureImage
                completedAppointmentDictionary["applicantInitialsImage"] = appointments.applicantInitialsImage
                completedAppointmentDictionary["coApplicantSignatureImage"] = appointments.coApplicantSignatureImage
                completedAppointmentDictionary["coApplicantInitialsImage"] = appointments.coApplicantInitialsImage
                completedAppointmentDictionary["paymentType"] = appointments.paymentType
                completedAppointmentDictionary["contractData"] = appointments.contractData
                completedAppointmentDictionary["recisionDate"] = appointments.recisionDate
                var roomData = roomDetails(roomdata: appointments.rooms)
                completedAppointmentDictionary["rooms"] = roomData
                //completedAppointmentDictionary["questionnaires"] = appointments.questionnaires
                if appointments.applicantData != nil
                {
                    var applicantData = applicantData(applicantdata:appointments.applicantData)
                    completedAppointmentDictionary["applicantData"] = applicantData
                }
                if appointments.coApplicantData != nil
                {
                    var coApplicantData = coApplicantData(coApplicantdata:appointments.coApplicantData!)
                    completedAppointmentDictionary["coApplicantData"] = coApplicantData
                }
                if appointments.otherIncomeData != nil
                {
                    var otherIncomeData = otherIncome(otherIncomedata:appointments.otherIncomeData)
                    completedAppointmentDictionary["otherIncomeData"] = otherIncomeData
                }
                
                let json = (completedAppointmentDictionary as NSDictionary).JsonString()
                //let json = "{'result': 'Success', 'message': 'Data stored successfully', 'override_json_result': 1}"
                let token = UserData.init().token ?? ""
                let appointmentId:Int = (completedAppointmentDictionary["appointment_id"] ?? 0 ) as! Int
                
                var parameter : [String:Any] = [:]
                parameter = ["token":token,"appointment_id":appointmentId,"data":json]
                //let imageBaseUrl = ImageSaveToDirectory.SharedImage.getDirectoryPath()
                
                var imageString:[String] = []
                for roomImage in appointments.rooms
                {
                  for images in  roomImage.room_attachments
                    {
//                      let imagePath = imageBaseUrl.appendingPathComponent(images) // Here Image Saved With This Name ."MyImage.png"
//                      let urlString: String = imagePath!.absoluteString
//                      imageString.append(urlString)
                      let imagePath = getImagePath(imageName: images)
                      imageString.append(imagePath)
                  }
//                    let imagePath = imageBaseUrl.appendingPathComponent(roomImage.draw_image_name ?? "") // Here Image Saved With This Name ."MyImage.png"
//                    let urlString: String = imagePath!.absoluteString
                    imageString.append(getImagePath(imageName: roomImage.draw_image_name ?? ""))
                
                }
                imageString.append(getImagePath(imageName: appointments.applicantSignatureImage ?? "")) // Here Image Saved With This Name ."MyImage.png"
                imageString.append(getImagePath(imageName: appointments.applicantInitialsImage ?? "")) // Here Image Saved With This Name ."MyImage.png"
                imageString.append(getImagePath(imageName: appointments.coApplicantSignatureImage ?? "")) // Here Image Saved With This Name ."MyImage.png"
               
                imageString.append(getImagePath(imageName: appointments.coApplicantInitialsImage ?? "")) // Here Image Saved With This Name ."MyImage.png"
                // fetching contract details
                
                let contractRequestArray = fetchGenerateContractFromAppointmentRequestForceSync(aptId: appointmentId)
                for contract in contractRequestArray
                {
                    let (appointmentId, requestParams, _) =  self.createGenerateContractParametersForApiCall(completedAppointmentRequest: contract)
                    completedAppointmentDictionary["ContractDetails"] = requestParams
                }
                let i360RequestArray = fetchi360FromAppointmentRequestForceSync(aptId: appointmentId)
                for i360 in i360RequestArray
                {
                    let (appointmentId, requestParams, _) =  self.createInitiate_i360_SyncParametersForApiCall(completedAppointmentRequest: i360)
                    completedAppointmentDictionary["i360Params"] = requestParams
                }
               let url = createAppointmentZip(appointmentID: String(appointmentId), data: completedAppointmentDictionary, imagePaths: imageString)
                HttpClientManager.SharedHM.CompressFileOfAppointment(appointmentId: String(appointmentId), fileURL: url) { success, message in
                    if(success ?? "") == "Success"
                    {
                        self.alert(message ?? "Debug log uploaded successfully", nil)
                    }
                    else
                    {
                        self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, nil)
                        HttpClientManager.SharedHM.showhideHUD(viewtype: .HIDE,title: "")
                        
                    }
                }
            
//                HttpClientManager.SharedHM.fetchDataBaseInfoAPi(parameter: parameter) { success, message in
//                    if(success ?? "") == "Success"{
//                        let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
//                            completedAppointmentDictionary.removeAll()
//                            print(message ?? "No msg")
//
//                        }
//                        self.alert("Debug data collected and sent to support team successfully." ?? AppAlertMsg.serverNotReached, [ok])
//                    }
//                    else
//                    {
//                        let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//                            completedAppointmentDictionary.removeAll()
//                            self.retrieveData()
//
//                        }
//                        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//                        self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
//                    }
//                }
                
                
            }
            
        }
        //HttpClientManager.SharedHM.showhideHUD(viewtype: .HIDE,title: "")
        
        
    }
    
    func getImagePath(imageName:String) -> String
    {
        let imagePath = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectoryURL(rfImage: imageName) ?? ""
        return imagePath
    }
    
    
    func createAppointmentZip(appointmentID: String, data: [String: Any], imagePaths: [String]) -> URL? {
        let fileManager = FileManager.default
        
        // Step 1: Create a folder named after the appointment ID
        let folderURL = fileManager.temporaryDirectory.appendingPathComponent(appointmentID)
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating folder: \(error)")
            return nil
        }
        
        // Step 2: Write room data to a text file
        let dataFileURL = folderURL.appendingPathComponent("data.txt")
        let dataText = data.map { "\($0): \($1)" }.joined(separator: "\n")
        do {
            try dataText.write(to: dataFileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing data to file: \(error)")
            return nil
        }
        
        // Step 3: Copy images to the folder
        for imagePath in imagePaths {
            let imageFileName = (imagePath as NSString).lastPathComponent
            let destinationURL = folderURL.appendingPathComponent(imageFileName)
            do {
                try fileManager.copyItem(atPath: imagePath, toPath: destinationURL.path)
            } catch {
                print("Error copying image: \(error)")
            }
        }
        
        let refloorOfflineAssetURL = folderURL.appendingPathComponent("Refloor_Offline_Asset")
            if fileManager.fileExists(atPath: refloorOfflineAssetURL.path) {
                do {
                    try fileManager.removeItem(at: refloorOfflineAssetURL)
                    print("Removed existing 'Refloor_Offline_Asset' folder.")
                } catch {
                    print("Error removing 'Refloor_Offline_Asset' folder: \(error)")
                    //return .fa(error)
                }
            }
        
        // Step 5: Copy the folder to "On My iPad" section
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error accessing 'On My iPad' section.")
           // return .failure(NSError(domain: "FileManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to access 'On My iPad' section"]))
            return nil
        }
        let destinationFolderURL = documentsURL.appendingPathComponent(appointmentID)
        
        do {
            if fileManager.fileExists(atPath: destinationFolderURL.path) {
                try fileManager.removeItem(at: destinationFolderURL)
            }
            try fileManager.copyItem(at: folderURL, to: destinationFolderURL)
            print("Folder copied to 'On My iPad' section.")
        } catch {
            print("Error copying folder to 'On My iPad': \(error)")
            //return .failure(error)
        }
        
        // Step 4: Create a zip file
        let zipFilePath = fileManager.temporaryDirectory.appendingPathComponent("\(appointmentID).zip")
        do {
            try Zip.zipFiles(paths: [folderURL], zipFilePath: zipFilePath, password: nil, progress: nil)
            return zipFilePath
        } catch {
            print("Error zipping folder: \(error)")
            return nil
        }
    }

    func otherIncome(otherIncomedata:rf_OtherIncomeData) -> [String:Any]
    {
        var otherIncomeData:[String:Any] = [:]
        otherIncomeData["appointment_id"] = otherIncomedata.appointment_id
        otherIncomeData["sourceOfOtherIncome"] = otherIncomedata.sourceOfOtherIncome
        otherIncomeData["amountMonthly"] = otherIncomedata.amountMonthly
        otherIncomeData["nearestRelative"] = otherIncomedata.nearestRelative
        otherIncomeData["relationship"] = otherIncomedata.relationship
        otherIncomeData["addressRelationship"] = otherIncomedata.addressRelationship
        otherIncomeData["addressRelationshipStreet"] = otherIncomedata.addressRelationshipStreet
        otherIncomeData["addressRelationshipStreet2"] = otherIncomedata.addressRelationshipStreet2
        otherIncomeData["addressRelationshipCity"] = otherIncomedata.addressRelationshipCity
        otherIncomeData["addressRelationshipState"] = otherIncomedata.addressRelationshipState
        otherIncomeData["addressRelationshipZip"] = otherIncomedata.addressRelationshipZip
        otherIncomeData["phoneNumberRelationhip"] = otherIncomedata.phoneNumberRelationhip
        otherIncomeData["propertyDetails"] = otherIncomedata.propertyDetails
        otherIncomeData["lenderName"] = otherIncomedata.lenderName
        otherIncomeData["lenderAddress"] = otherIncomedata.lenderAddress
        otherIncomeData["lenderAddressStreet"] = otherIncomedata.lenderAddressStreet
        otherIncomeData["lenderAddressStreet2"] = otherIncomedata.lenderAddressStreet2
        otherIncomeData["lenderAddressCity"] = otherIncomedata.lenderAddressCity
        otherIncomeData["lenderAddressState"] = otherIncomedata.lenderAddressState
        otherIncomeData["lenderAddressZip"] = otherIncomedata.lenderAddressZip
        otherIncomeData["lenderPhone"] = otherIncomedata.lenderPhone
        otherIncomeData["originalPurchasePrice"] = otherIncomedata.originalPurchasePrice
        otherIncomeData["originalMortageAmount"] = otherIncomedata.originalMortageAmount
        otherIncomeData["monthlyMortagePayment"] = otherIncomedata.monthlyMortagePayment
        otherIncomeData["dateAquired"] = otherIncomedata.dateAquired
        otherIncomeData["presentBalance"] = otherIncomedata.presentBalance
        otherIncomeData["presentValueOfHome"] = otherIncomedata.presentValueOfHome
        otherIncomeData["secondMortage"] = otherIncomedata.secondMortage
        otherIncomeData["lenderNameOrPhone"] = otherIncomedata.lenderNameOrPhone
        otherIncomeData["originalAmount"] = otherIncomedata.originalAmount
        otherIncomeData["presentBalanceSecondMortage"] = otherIncomedata.presentBalanceSecondMortage
        otherIncomeData["monthlyPayment"] = otherIncomedata.monthlyPayment
        otherIncomeData["otherObligations"] = otherIncomedata.otherObligations
        otherIncomeData["totalMonthlyPayments"] = otherIncomedata.totalMonthlyPayments
        otherIncomeData["checkingAccountNo"] = otherIncomedata.checkingAccountNo
        otherIncomeData["nameOfBank"] = otherIncomedata.nameOfBank
        otherIncomeData["bankPhoneNumber"] = otherIncomedata.bankPhoneNumber
        otherIncomeData["insuranceCompany"] = otherIncomedata.insuranceCompany
        otherIncomeData["agent"] = otherIncomedata.agent
        otherIncomeData["insurancePhoneNo"] = otherIncomedata.insurancePhoneNo
        
        otherIncomeData["coverage"] = otherIncomedata.coverage
        otherIncomeData["typeOfCreditRequested"] = otherIncomedata.typeOfCreditRequested
        otherIncomeData["additional_income"] = otherIncomedata.additional_income
        otherIncomeData["second_mortage"] = otherIncomedata.second_mortage
        otherIncomeData["lender_name_or_phone"] = otherIncomedata.lender_name_or_phone
        otherIncomeData["checking_account_no"] = otherIncomedata.checking_account_no
        otherIncomeData["checking_routing_no"] = otherIncomedata.checking_routing_no
        otherIncomeData["name_of_bank"] = otherIncomedata.name_of_bank
        otherIncomeData["applicant_signature_date"] = otherIncomedata.applicant_signature_date
        otherIncomeData["co_applicant_signature_date"] = otherIncomedata.co_applicant_signature_date
        otherIncomeData["hunterMessageStatus"] = otherIncomedata.hunterMessageStatus
        otherIncomeData["present_balance"] = otherIncomedata.present_balance
        otherIncomeData["present_value_of_home"] = otherIncomedata.present_value_of_home
        otherIncomeData["original_amount"] = otherIncomedata.original_amount
        otherIncomeData["present_balance_second_mortage"] = otherIncomedata.present_balance_second_mortage
        otherIncomeData["monthly_payment"] = otherIncomedata.monthly_payment
       return otherIncomeData
    }
    func coApplicantData(coApplicantdata:rf_CoApplicationData) -> [String:Any]
    {
        var coApplicantData:[String:Any] = [:]
        coApplicantData["appointment_id"] = coApplicantdata.ethnicity
        coApplicantData["ethnicity"] = coApplicantdata.race
        coApplicantData["race"] = coApplicantdata.sex
        coApplicantData["sex"] = coApplicantdata.sex
        coApplicantData["CoapplicantEmail"] = coApplicantdata.CoapplicantEmail
        coApplicantData["maritalStatus"] = coApplicantdata.maritalStatus
        coApplicantData["applicantFirstName"] = coApplicantdata.applicantFirstName
        coApplicantData["applicantMiddleName"] = coApplicantdata.applicantMiddleName
        coApplicantData["applicantLastName"] = coApplicantdata.applicantLastName
        coApplicantData["driversLicense"] = coApplicantdata.driversLicense
        coApplicantData["driversLicenseExpDate"] = coApplicantdata.driversLicenseExpDate
        coApplicantData["driversLicenseIssueDate"] = coApplicantdata.driversLicenseIssueDate
        coApplicantData["dateOfBirth"] = coApplicantdata.dateOfBirth
        coApplicantData["socialSecurityNumber"] = coApplicantdata.socialSecurityNumber
        coApplicantData["addressOfApplicant"] = coApplicantdata.addressOfApplicant
        coApplicantData["addressOfApplicantStreet"] = coApplicantdata.addressOfApplicantStreet
        coApplicantData["addressOfApplicantStreet2"] = coApplicantdata.addressOfApplicantStreet2
        coApplicantData["addressOfApplicantCity"] = coApplicantdata.addressOfApplicantCity
        coApplicantData["addressOfApplicantState"] = coApplicantdata.addressOfApplicantState
        coApplicantData["addressOfApplicantZip"] = coApplicantdata.addressOfApplicantZip
        coApplicantData["previousAddressOfApplicant"] = coApplicantdata.previousAddressOfApplicant
        coApplicantData["previousAddressOfApplicantStreet"] = coApplicantdata.previousEmployersAddressStreet
        coApplicantData["previousAddressOfApplicantStreet2"] = coApplicantdata.previousEmployersAddressStreet2
        coApplicantData["previousAddressOfApplicantCity"] = coApplicantdata.previousAddressOfApplicantCity
        coApplicantData["previousAddressOfApplicantState"] = coApplicantdata.previousAddressOfApplicantState
        coApplicantData["previousAddressOfApplicantZip"] = coApplicantdata.previousAddressOfApplicantZip
        coApplicantData["cellPhone"] = coApplicantdata.cellPhone
        coApplicantData["homePhone"] = coApplicantdata.homePhone
        coApplicantData["howLong"] = coApplicantdata.howLong
        coApplicantData["previousAddressHowLong"] = coApplicantdata.previousAddressHowLong
        coApplicantData["presentEmployer"] = coApplicantdata.presentEmployer
        coApplicantData["yearsOnJob"] = coApplicantdata.yearsOnJob
        coApplicantData["occupation"] = coApplicantdata.occupation
        coApplicantData["presentEmployersAddress"] = coApplicantdata.presentEmployersAddress
        coApplicantData["presentEmployersAddressStreet"] = coApplicantdata.presentEmployersAddressStreet
        coApplicantData["presentEmployersAddressStreet2"] = coApplicantdata.presentEmployersAddressStreet2
        coApplicantData["presentEmployersAddressCity"] = coApplicantdata.previousEmployersAddressCity
        coApplicantData["presentEmployersAddressState"] = coApplicantdata.presentEmployersAddressState
        coApplicantData["presentEmployersAddressZip"] = coApplicantdata.presentEmployersAddressZip
        coApplicantData["earningsFromEmployment"] = coApplicantdata.earningsFromEmployment
        coApplicantData["supervisorOrDepartment"] = coApplicantdata.supervisorOrDepartment
        coApplicantData["employersPhoneNumber"] = coApplicantdata.employersPhoneNumber
        coApplicantData["previousEmployersAddress"] = coApplicantdata.previousEmployersAddress
        coApplicantData["previousEmployersAddressStreet"] = coApplicantdata.previousEmployersAddressStreet
        coApplicantData["previousEmployersAddressStreet2"] = coApplicantdata.previousEmployersAddressStreet2
        coApplicantData["previousEmployersAddressCity"] = coApplicantdata.previousEmployersAddressCity
        coApplicantData["previousEmployersAddressState"] = coApplicantdata.previousEmployersAddressState
        coApplicantData["previousEmployersAddressZip"] = coApplicantdata.previousEmployersAddressZip
        coApplicantData["earningsPerMonth"] = coApplicantdata.earningsPerMonth
        coApplicantData["yearsOnJobPreviousEmployer"] = coApplicantdata.yearsOnJobPreviousEmployer
        coApplicantData["occupationPreviousEmployer"] = coApplicantdata.occupationPreviousEmployer
        coApplicantData["previousEmployersPhoneNumber"] = coApplicantdata.previousEmployersPhoneNumber
        coApplicantData["otherRace"] = coApplicantdata.otherRace
        return coApplicantData
    }
    func applicantData(applicantdata:rf_ApplicantData) -> [String:Any]
    {
        var applicantData:[String:Any] = [:]
        applicantData["ethnicity"] = applicantdata.ethnicity
        applicantData["race"] = applicantdata.race
        applicantData["sex"] = applicantdata.sex
        applicantData["applicantEmail"] = applicantdata.applicantEmail
        applicantData["applicantEmail"] = applicantdata.applicantEmail
        applicantData["maritalStatus"] = applicantdata.maritalStatus
        applicantData["applicantFirstName"] = applicantdata.applicantFirstName
        
        applicantData["applicantMiddleName"] = applicantdata.applicantMiddleName
        applicantData["applicantLastName"] = applicantdata.applicantLastName
        applicantData["driversLicense"] = applicantdata.driversLicense
        applicantData["driversLicenseExpDate"] = applicantdata.driversLicenseExpDate
        applicantData["driversLicenseIssueDate"] = applicantdata.driversLicenseIssueDate
        applicantData["dateOfBirth"] = applicantdata.dateOfBirth
        applicantData["socialSecurityNumber"] = applicantdata.socialSecurityNumber
        applicantData["addressOfApplicant"] = applicantdata.addressOfApplicant
        applicantData["addressOfApplicantStreet"] = applicantdata.addressOfApplicantStreet
        applicantData["addressOfApplicantStreet2"] = applicantdata.addressOfApplicantStreet2
        applicantData["addressOfApplicantCity"] = applicantdata.addressOfApplicantCity
        applicantData["addressOfApplicantState"] = applicantdata.addressOfApplicantState
        
        applicantData["addressOfApplicantZip"] = applicantdata.addressOfApplicantZip
        applicantData["previousAddressOfApplicant"] = applicantdata.previousAddressOfApplicant
        applicantData["previousAddressOfApplicantStreet"] = applicantdata.previousEmployersAddressStreet
        applicantData["previousAddressOfApplicantStreet2"] = applicantdata.previousEmployersAddressStreet2
        applicantData["previousAddressOfApplicantCity"] = applicantdata.previousAddressOfApplicantCity
        applicantData["previousAddressOfApplicantState"] = applicantdata.previousAddressOfApplicantState
        applicantData["previousAddressOfApplicantZip"] = applicantdata.previousAddressOfApplicantZip
        applicantData["cellPhone"] = applicantdata.cellPhone
        applicantData["homePhone"] = applicantdata.homePhone
        applicantData["howLong"] = applicantdata.howLong
        applicantData["previousAddressHowLong"] = applicantdata.previousAddressHowLong
        applicantData["presentEmployer"] = applicantdata.presentEmployer
        applicantData["yearsOnJob"] = applicantdata.yearsOnJob
        applicantData["occupation"] = applicantdata.occupation
        applicantData["presentEmployersAddress"] = applicantdata.presentEmployersAddress
        applicantData["presentEmployersAddressStreet"] = applicantdata.presentEmployersAddressStreet
        applicantData["presentEmployersAddressStreet2"] = applicantdata.presentEmployersAddressStreet2
        applicantData["presentEmployersAddressCity"] = applicantdata.presentEmployersAddressCity
        applicantData["presentEmployersAddressState"] = applicantdata.presentEmployersAddressState
        applicantData["presentEmployersAddressZip"] = applicantdata.presentEmployersAddressZip
        applicantData["earningsFromEmployment"] = applicantdata.earningsFromEmployment
        applicantData["type_of_credit_requested"] = applicantdata.type_of_credit_requested
        applicantData["supervisorOrDepartment"] = applicantdata.supervisorOrDepartment
        applicantData["employersPhoneNumber"] = applicantdata.employersPhoneNumber
        
        applicantData["previousEmployersAddress"] = applicantdata.previousEmployersAddress
        applicantData["previousEmployersAddressStreet"] = applicantdata.presentEmployersAddressStreet
        applicantData["previousEmployersAddressStreet2"] = applicantdata.previousEmployersAddressStreet2
        applicantData["previousEmployersAddressCity"] = applicantdata.previousEmployersAddressCity
        applicantData["previousEmployersAddressState"] = applicantdata.previousEmployersAddressState
        applicantData["previousEmployersAddressZip"] = applicantdata.previousEmployersAddressZip
        applicantData["earningsPerMonth"] = applicantdata.earningsPerMonth
        applicantData["yearsOnJobPreviousEmployer"] = applicantdata.yearsOnJobPreviousEmployer
        applicantData["occupationPreviousEmployer"] = applicantdata.occupationPreviousEmployer
        applicantData["previousEmployersPhoneNumber"] = applicantdata.previousEmployersPhoneNumber
        applicantData["otherRace"] = applicantdata.otherRace
        return applicantData
    }
    
    func roomDetails(roomdata:List<rf_completed_room>) -> [[String:Any]]
    {
        var roomData:[String:Any] = [:]
        var roomDataArray:[[String:Any]] = [[:]]
        for rooms in roomdata
        {
            
            roomData["room_id"] = rooms.room_id
            roomData["measurement_exist"] = rooms.measurement_exist
            roomData["customer_id"] = rooms.customer_id
            roomData["appointment_id"] = rooms.appointment_id
            roomData["room_name"] = rooms.room_name
            roomData["room_type"] = rooms.room_type
            roomData["drawing_id"] = rooms.drawing_id
            roomData["draw_image_name"] = rooms.draw_image_name
            roomData["room_summary_comment"] = rooms.room_summary_comment
            roomData["selected_room_color"] = rooms.selected_room_color
            roomData["selected_room_Upcharge"] = rooms.selected_room_Upcharge
            roomData["selected_room_UpchargePrice"] = rooms.selected_room_UpchargePrice
            roomData["selected_room_molding"] = rooms.selected_room_molding
            roomData["room_strike_status"] = rooms.room_strike_status
            roomData["extraPrice"] = rooms.extraPrice
            roomData["extraPriceToExclude"] = rooms.extraPriceToExclude
            roomData["room_area"] = rooms.room_area
            roomData["stairCount"] = rooms.stairCount
            roomData["stairWidth"] = rooms.stairWidth
            roomData["draw_area_adjusted"] = rooms.draw_area_adjusted
            roomData["room_perimeter"] = rooms.room_perimeter
            roomData["material_image_url"] = rooms.material_image_url
            roomData["floor_id"] = rooms.floor_id
            
            var roomAttachments:[String] = []
            if rooms.room_attachments.count > 0
            {
                for roomImages in rooms.room_attachments
                {
                    roomAttachments.append(roomImages)
                }
                roomData["room_attachments"] = roomAttachments
            }
            if (rooms.transArray.count) > 0
            {
                var transition = transitionDetails(transitiondata: rooms.transArray)
                roomData["transArray"] = transition
            }
            
            var questions = questionDetails(questiondata: rooms.questionnaires)
            roomData["questionnaires"] = questions
            roomDataArray.append(roomData)
        }
        return roomDataArray
        
    }
    
    func questionDetails(questiondata:List<rf_master_question>) -> [[String:Any]]
    {
        var questionData:[String:Any] = [:]
        var questionDataArray:[[String:Any]] = [[:]]
        for questions in questiondata
        {
            questionData["id"] = questions.id
            questionData["room_id"] = questions.room_id
            questionData["appointment_id"] = questions.appointment_id
            questionData["question_name"] = questions.question_name
            questionData["amount"] = questions.amount
            questionData["amount_included"] = questions.amount_included
            if (questions.rf_AnswerOFQustion.count) > 0
            {
                var answer = answerDetails(answerDetailsdata:questions.rf_AnswerOFQustion)
                questionData["rf_AnswerOFQustion"] = answer
            }
            questionDataArray.append(questionData)
        }
        return questionDataArray
    }
    func answerDetails(answerDetailsdata:List<rf_AnswerForQuestion>) -> [[String:Any]]
    {
        var answerData:[String:Any] = [:]
        var answerDataArray:[[String:Any]] = [[:]]
        for answer in answerDetailsdata
        {
            var answerValue:[String] = []
            answerData["question_id"] = answer.question_id
            answerData["appointment_id"] = answer.appointment_id
            for answerDetails in answer.answer
            {
                answerValue.append(answerDetails)
            }
            answerData["answer"] = answerValue
            answerDataArray.append(answerData)
        }
        return answerDataArray
    }
    
    func transitionDetails(transitiondata:List<rf_transitionData>) -> [[String:Any]]
    {
        var transitionData:[String:Any] = [:]
        var transitionArray:[[String:Any]] = [[:]]
        for transition in transitiondata
        {
            transitionData["name"] = transition.name
            transitionData["color"] = transition.color
            transitionData["transsquarefeet"] = transition.transsquarefeet
            transitionArray.append(transitionData)
        }
        return transitionArray
        
    }
}
class ViewLogTableViewCell:UITableViewCell{
    @IBOutlet weak var transactionMsgLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendReviewLinkBtn: UIButton!
    @IBOutlet weak var transactionMsgLbl: UILabel!
    @IBOutlet weak var appointmentIdLabel: UILabel!
    @IBOutlet weak var appointmentLogsLabel: UILabel!
    @IBOutlet weak var syncBtn: UIButton!
    @IBOutlet weak var appointmentStatusLabel: UILabel!
    @IBOutlet weak var stopSyncButton: UIButton!
    
    @IBOutlet weak var syncNowButton: UIButton!
}
