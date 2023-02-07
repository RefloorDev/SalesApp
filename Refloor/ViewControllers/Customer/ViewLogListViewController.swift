//
//  ViewLogListViewController.swift
//  Refloor
//
//  Created by Arun Rajendrababu on 07/01/22.
//  Copyright © 2022 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

class ViewLogListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    static func initialization() -> ViewLogListViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ViewLogListViewController") as? ViewLogListViewController
    }
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
    }
    
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
        cell.transactionMsgLbl.isHidden = true
        //cell.transactionMsgLblHeightConstraint.constant = 0
        cell.selectionStyle = .none
        var appStatus = "Sync Completed"
        if  self.fetchAppointmentRequest(for: appointmentLogsArray[indexPath.row].appointment_id).count > 0
        {
            appStatus = "Sync Pending"
        }
        if appStatus == "Sync Pending"
        {
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
            cell.appointmentStatusLabel.text = appStatus
           if appointmentLogsArray[indexPath.row].paymentStatus == "Success" || appointmentLogsArray[indexPath.row].paymentStatus == "Not Done"
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
            self.deleteAppointmentLog(appointmentId: 0, deleteAll: true)
            self.viewLogTableView.reloadData()
            DispatchQueue.main.async{
                self.deleteAllButton.isHidden = true
                self.uploadLogButton.isHidden = true
                self.noLogLabel.isHidden = false
                self.viewLogTableView.isHidden = true
                self.swipeDeleteTextButton.isHidden = true
            }
        }
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.alert("Are you sure you want to delete all logs?", [yes,no])
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
                    SceneDelegate.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
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
        let yes = UIAlertAction(title: "Upload", style:.default) { (_) in
            self.uploadLog()
        }
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.alert("Are you sure you want to upload all log files?\nOnce uploaded, it will be removed from this device.", [yes,no])
    }
    
    
    func uploadLog(){
        let appointmentLogs = self.getAppointmentLogDetailsFromDB()
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
                    self.deleteAppointmentLog(appointmentId: 0, deleteAll: true)
                    self.viewLogTableView.reloadData()
                    DispatchQueue.main.async{
                        self.deleteAllButton.isHidden = true
                        self.uploadLogButton.isHidden = true
                        self.noLogLabel.isHidden = false
                        self.viewLogTableView.isHidden = true
                        self.swipeDeleteTextButton.isHidden = true
                        self.syncAllButton.isHidden = true
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
        HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(parameter: parameter, isOnlineCollectBtnPressed: false) { success, message,payment_status,payment_message  in
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
        let room_id_str = String(room_id)
        HttpClientManager.SharedHM.syncImagesOfAppointment(appointmentId: String(appoint_id ?? 0), roomId: room_id_str, attachments: file, imagename: image_name, imageType: image_type) { success, message, imageName in
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
}
class ViewLogTableViewCell:UITableViewCell{
    @IBOutlet weak var transactionMsgLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionMsgLbl: UILabel!
    @IBOutlet weak var appointmentIdLabel: UILabel!
    @IBOutlet weak var appointmentLogsLabel: UILabel!
    @IBOutlet weak var syncBtn: UIButton!
    @IBOutlet weak var appointmentStatusLabel: UILabel!
}
