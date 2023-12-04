//
//  CustomerListViewController.swift
//  Refloor
//
//  Created by sbek on 17/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftUI


class CustomerListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIDocumentPickerDelegate {
    
    
    
    static func initialization() -> CustomerListViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CustomerListViewController") as? CustomerListViewController
    }
    @IBOutlet weak var customerListTableView: UITableView!
    @IBOutlet weak var customerNameSearchTF: UITextField!
    @IBOutlet weak var noAppointmentText: UILabel!
    @IBOutlet weak var masterDataLastSyncDateTimeLabel: UILabel!
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    var theApiValue:Appointments?
    var appoinmentsList : [AppoinmentDataValue]?
    var tempappoinmentsList : [AppoinmentDataValue]?
    var noAppoinmentLabel = UILabel()
    var isLoadedFirstTime = false
    var dispatchGroup =  DispatchGroup()
    var timer = Timer()
    var times:Int = 0;
    var comments:String = String()
    var sendPhysical:Bool = Bool()
    var masterDataLastSyncDateTime = ""
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        let masterData = self.getMasterDataFromDB()
       if masterData.contract_document_templates.first?.data == nil
        {
            for contract in masterData.contract_document_templates
            {
                self.saveDynamicContractData(templateId: contract.template_id , documentURL: contract.document_url ?? "", name: contract.name ?? "", type: contract.type ?? "")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAppointmentOffline), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAppointmentOffline), name: Notification.Name("UpdateAppointments"), object: nil)
        
        isLoadedFirstTime = true
        customerNameSearchTF.attributedPlaceholder =  NSAttributedString(string: "Customer Name",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeHolderColor])
        noAppoinmentLabel = UILabel(frame: CGRect(x: self.view.center.x - 200, y: self.view.center.y - 15, width: 400, height: 30))
        noAppoinmentLabel.font = UIFont(name:"Avenir-Medium", size: 26)
        noAppoinmentLabel.text = "No appointments available"
        customerNameSearchTF.setLeftPaddingPoints(20)
        noAppoinmentLabel.textAlignment = .center
        noAppoinmentLabel.textColor = UIColor.white
        self.noAppoinmentLabel.isHidden = true
        self.view.addSubview(noAppoinmentLabel)
        self.navigationController?.viewControllers = [self]
        //self.BackendApiSyncCall()
        // Do any additional setup after loading the view.
    }
    
   
    
    
    override func viewWillAppear(_ animated: Bool) {
        //
        masterDataLastSyncDateTime = UserDefaults.standard.value(forKey: "MasterDataSyncDate") as? String ?? ""
        masterDataLastSyncDateTimeLabel.text = "Master Data Last Synced On: " + masterDataLastSyncDateTime
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setNavigationBarLogoAndLogout(with: ("Sales Schedules").uppercased())
        //self.setNavigationBarbackAndlogo(with: "Customer 1 Details")
        self.customerNameSearchTF.text = ""
        //arb
        self.tempappoinmentsList = self.getRefreshedAppointmentsFromDB()
        self.appoinmentsList = self.getRefreshedAppointmentsFromDB()
        // remove if needed: appointments from master appointments - by comparing appointments present in rf_Completed_Appointment_Request table
        self.showMasterDataAppointmentsBasedOnCompletedAppointmentRequestFromDatabase()
        //
        
        if(self.appoinmentsList ?? []).count != 0
        {
            self.customerListTableView.reloadData()
            self.noAppoinmentLabel.isHidden = true
        }
        else
        {
            self.customerListTableView.reloadData()
            self.noAppoinmentLabel.isHidden = false
            //self.refreshAction()
            updateAppointmentOffline()
        }
        
        
        if !isLoadedFirstTime
        {
            //self.BackendApiSyncCall()
            
        }
        isLoadedFirstTime = false
        //  checkBuildStatus()
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let appointmentRequestArray = BackgroundTaskService.shared.getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
        if(appointmentRequestArray.count != 0)
        {
            if(!SceneDelegate.timer.isValid)
            {
                SceneDelegate.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
                    
                    print("TIMER WAKEUP Appointment")
                    BackgroundTaskService.shared.startSyncProcess()
                })
            }
            
            BackgroundTaskService.shared.enterBackground()
        }else{
            //delete item
            self.deleteAllRoomImagesFromAppointmentRequest()
        }
        
    }
    
    func showMasterDataAppointmentsBasedOnCompletedAppointmentRequestFromDatabase(){
        //arb
        
        self.appoinmentsList?.forEach({ appointment in
            let appointmentId = appointment.id ?? 0
            switch checkAppointmentStatusOfAppointmentId(appointmentId: appointmentId) {
            case AppointmentStatus.start:
                appointment.appointmentStatus = AppointmentStatus.start
                break
            case AppointmentStatus.sync:
                appointment.appointmentStatus = AppointmentStatus.sync
                break
            case AppointmentStatus.complete:
                appointment.appointmentStatus = AppointmentStatus.complete
                break
            }
        })
        self.appoinmentsList = self.appoinmentsList?.filter({$0.appointmentStatus == AppointmentStatus.start})
        self.tempappoinmentsList = self.appoinmentsList
        //
    }
    
    override func refreshAction()
    {
        if(!HttpClientManager.SharedHM.connectedToNetwork())
        {
            
            
            updateAppointmentOffline()
        }
        else
        {
            appoinmentLisApiCall()
        }
        
        //BackendApiSyncCall()
       
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: true)
    }
    
    @objc  func updateAppointmentOffline()
    {
        
        self.tempappoinmentsList = self.getRefreshedAppointmentsFromDB()
        self.appoinmentsList = self.getRefreshedAppointmentsFromDB()
        self.showMasterDataAppointmentsBasedOnCompletedAppointmentRequestFromDatabase()
        if(self.appoinmentsList ?? []).count != 0
        {
            
            self.customerListTableView.reloadData()
            self.noAppoinmentLabel.isHidden = true
        }
        else
        {
            self.customerListTableView.reloadData()
            self.noAppoinmentLabel.isHidden = false
        }
        
    }
    
    
    @IBAction func didValueChangedSearch(_ sender: UITextField)
    {
        if (self.tempappoinmentsList ?? []).count != 0
        {
            var appoinmnets:[AppoinmentDataValue] = []
            if(sender.text != "")
            {
                for appoinment in tempappoinmentsList ?? []
                {
                    
                    if((appoinment.customer_name ?? "").lowercased().contains((sender.text ?? "").lowercased()) || (appoinment.applicant_first_name ?? "").lowercased().contains((sender.text ?? "").lowercased()) || (appoinment.applicant_last_name ?? "").lowercased().contains((sender.text ?? "").lowercased()))
                    {
                        appoinmnets.append(appoinment)
                    }
                }
            }
            else
            {
                appoinmnets = tempappoinmentsList ?? []
            }
            self.appoinmentsList = appoinmnets
            if(self.appoinmentsList ?? []).count != 0
            {
                self.customerListTableView.reloadData()
                self.noAppoinmentLabel.isHidden = true
            }
            else
            {
                self.customerListTableView.reloadData()
                self.noAppoinmentLabel.isHidden = false
            }
        }
    }
    
    
    func appoinmentLisApiCall()
    {
        
        HttpClientManager.SharedHM.AppinmentListApi { (result, message, value) in
            if (result ?? "") == "Success"
            {
                self.theApiValue = value
                if( self.theApiValue != nil)
                {
                    
                    self.tempappoinmentsList = self.getRefreshedAppointmentsFromDB()
                    self.appoinmentsList = self.getRefreshedAppointmentsFromDB()
                    self.showMasterDataAppointmentsBasedOnCompletedAppointmentRequestFromDatabase()
                }
                
            }
            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message ?? value?.message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            else
            {
                // self.alert(message ?? AppAlertMsg.serverNotReached , nil)
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.appoinmentLisApiCall()
                    
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
            }
            if(self.appoinmentsList ?? []).count != 0
            {
                self.customerListTableView.reloadData()
                self.noAppoinmentLabel.isHidden = true
            }
            else
            {
                self.customerListTableView.reloadData()
                self.noAppoinmentLabel.isHidden = false
            }
            
        }
    }
    
    
    func BackendApiSyncCall()
    {
        HttpClientManager.SharedHM.BackendApiSyncCallDirect()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (appoinmentsList ?? []).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerListTableViewCell") as! CustomerListTableViewCell
        
        var name = ""
        if((appoinmentsList?[indexPath.row].applicant_first_name ?? "") != "")
        {
            name = "\((appoinmentsList?[indexPath.row].applicant_first_name ?? "")) \((appoinmentsList?[indexPath.row].applicant_middle_name ?? "")) \((appoinmentsList?[indexPath.row].applicant_last_name ?? ""))"
        }
        else
        {
            name = appoinmentsList?[indexPath.row].customer_name ?? "Unknown"
        }
        // cell.timeLabel.text = Date().TimeOnlyForCustomerList(datestr: appoinmentsList?[indexPath.row].appointment_date ?? "")
        cell.timeLabel.text =  appoinmentsList?[indexPath.row].appointment_datetime ?? ""
        
        
        cell.customerNameLabel.text = name
        
        
        // cell.cutomerphoneNumberLabel.text = ((appoinmentsList?[indexPath.row].mobile ?? "") == "") ? "No Phone Number" : (appoinmentsList?[indexPath.row].mobile ?? "")
        //        ((self.appoinmentsList?[indexPath.row].mobile ?? "") == "") ? (self.appoinmentsList?[indexPath.row].phone ?? "") : "No Phone Number"
        
        cell.cutomerphoneNumberLabel.text = self.appoinmentsList?[indexPath.row].phone ?? ""
        //arb
        if UserDefaults.standard.integer(forKey: "can_view_phone_number") == 1{
            cell.customerPhoneStackView.isHidden = false
        } else if UserDefaults.standard.integer(forKey: "can_view_phone_number") == 0{
            cell.customerPhoneStackView.isHidden = true
        }
        //cell.customerPhoneStackView.isHidden = true
        //
        var address = ""
        if let street = appoinmentsList?[indexPath.row].street2
        {
            address = street
        }
        if let street2 = appoinmentsList?[indexPath.row].street
        {
            if street2 != ""
            {
                address = (address == "") ? street2 : (address + ", " + street2)
            }
        }
        if let city = appoinmentsList?[indexPath.row].city
        {
            if city != ""
            {
                address = (address == "") ? city : (address + ", " + city)
            }
        }
        if let state = appoinmentsList?[indexPath.row].state_code
        {
            if state != ""
            {
                address = (address == "") ? state : (address + ", " + state)
            }
        }
        if let zip = appoinmentsList?[indexPath.row].zip
        {
            if zip != ""
            {
                address = (address == "") ? zip : (address + " " + zip)
            }
            else
            {
                address = (address + " " + "48083")
            }
        }
        else
        {
            address = (address + " " + "48083")
        }
        if address == ""
        {
            address = "N/A"
        }
        cell.customerLocationLabel.text = address
        cell.startButton.tag = indexPath.row
        //arb
        if self.appoinmentsList?[indexPath.row].appointmentStatus == AppointmentStatus.sync{
            cell.startButton.setTitle("Sync", for: .normal)
        }else if self.appoinmentsList?[indexPath.row].appointmentStatus == AppointmentStatus.start{
            cell.startButton.setTitle("Start", for: .normal)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func startButtonActionFromCustomerList(_ sender: UIButton) {
    let appointmentDateTimeString = self.appoinmentsList?[sender.tag].appointment_datetime
        let appointmentDateTime = convertStringToDate(appointmentDateTimeString!)
        print("appointmentDateTime", appointmentDateTime)

        
        let currentDate = Date()
        let currentTimeFormatted = getCurrentTimeFormatted()
        print("Current Time: \(currentTimeFormatted)")
        
        let dateString = currentTimeFormatted
//        let dateString = "01 Dec 06:59 AM"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM hh:mm a"

        let date = dateFormatter.date(from: dateString)
                    
        let time_difference = appointmentDateTime!.timeIntervalSince(date!)
        
        if (appointmentDateTime! < date!) || (time_difference > 2 * 60 * 60) {
            //  print("appointmentDateTime", appointmentDateTime, "date", date)
            
            // Q4_Change Confirmation Popup with Appointment date and time
            let yes = UIAlertAction(title: "Yes", style:.default) { (_) in
                self.createAppointResultDemoedNotDemoedDB(appointmentId:self.appoinmentsList![sender.tag].id ?? 0)
                //
                if self.appoinmentsList?[sender.tag].appointmentStatus == AppointmentStatus.start{
                    //            //print(getTodayWeekDay())
                    let details = CustomerDetailsOneViewController.initialization()!
                    details.appoinmentslData = self.appoinmentsList![sender.tag]
                    _ = AppointmentData(appointment_id: self.appoinmentsList![sender.tag].id ?? 0)
                    
                    UserDefaults.standard.set(self.appoinmentsList![sender.tag].recisionDate ?? "", forKey: "Recision_Date")
                    // let details = InstallerShedulerViewController.initialization()!
                    self.navigationController?.pushViewController(details, animated: true)
                }
            }
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            DispatchQueue.main.async
            {
                self.alert("Sure You Want To Begin With" + " " + "\(self.appoinmentsList![sender.tag].appointment_datetime ?? "")", [yes,no])
            }
        } else {
            self.createAppointResultDemoedNotDemoedDB(appointmentId:self.appoinmentsList![sender.tag].id ?? 0)
            //
            if self.appoinmentsList?[sender.tag].appointmentStatus == AppointmentStatus.start{
                //            //print(getTodayWeekDay())
                let details = CustomerDetailsOneViewController.initialization()!
                details.appoinmentslData = self.appoinmentsList![sender.tag]
                _ = AppointmentData(appointment_id: self.appoinmentsList![sender.tag].id ?? 0)
                
                UserDefaults.standard.set(self.appoinmentsList![sender.tag].recisionDate ?? "", forKey: "Recision_Date")
                // let details = InstallerShedulerViewController.initialization()!
                self.navigationController?.pushViewController(details, animated: true)
            }
        }
    }
    
    
    func getCurrentTimeFormatted() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set the locale to ensure correct parsing

        return dateFormatter.string(from: currentDate)
    }
    
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set the locale to ensure correct parsing

        return dateFormatter.date(from: dateString)
    }
    
   
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController){
            print("Cancelled")
        }

    func createAppointResultDemoedNotDemoedDB(appointmentId:Int)
    {
        let realm = try! Realm()
       if realm.objects(rf_master_appointments_results_demoedNotDemoed.self).filter("appointmentId == %d", appointmentId ).count == 0
        {
           let appointmentResultData = realm.objects(rf_master_appointment_results.self)
           for dataValues in appointmentResultData
           {
               let appointmentInDemoedNotDemoed = rf_master_appointments_results_demoedNotDemoed(appointmentId: appointmentId, id: dataValues.id , result: dataValues.result ?? "", lastAvailableScreen: dataValues.lastAvailableScreen ?? "", islastAvailableScreen: false)
               try! realm.write{
                   realm.add(appointmentInDemoedNotDemoed)
               }
           }

        }
//        if data.count > 0
//        {
//            for values in data
//            {
//               if values.appointmentId == appointmentId
//                {
//                   return
//               }
//                else
//                {
//                                    }
//            }
//        }
//        else
//        {
//            let appointmentResultData = realm.objects(rf_master_appointment_results.self)
//            for dataValues in appointmentResultData
//            {
//                let appointmentInDemoedNotDemoed = rf_master_appointments_results_demoedNotDemoed(appointmentId: appointmentId, id: dataValues.id , result: dataValues.result ?? "", lastAvailableScreen: dataValues.lastAvailableScreen ?? "", islastAvailableScreen: false)
//                try! realm.write{
//                    realm.add(appointmentInDemoedNotDemoed)
//                }
//            }
//        }
        
     
        
    
    
  
        
//            let discountData = realm.objects(rf_master_appointment_results.self).filter("id == %d ", 2)
//            if let thisResult = discountData.first
//            {
//                try! realm.write{
//                    thisResult.isLastAvailableScreenShowedOnce = false
//                }
//            }
    }
    
    func checkBuildStatus()
    {
        HttpClientManager.SharedHM.CheckBuildStatus() { (buildNumber) in
            if(buildNumber != nil)
            {
                if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    
                    let currentBuild = Float(text) ?? 0.0
                    let latestBuild = Float(buildNumber ?? "0.0")
                    
                    if(currentBuild < latestBuild!)
                    {
                        let yes = UIAlertAction(title: "Update", style:.default) { (_) in
                            
                            guard let url = URL(string: "https://www.oneteam.us/testflight/refloor/index.html") else { return }
                            UIApplication.shared.open(url)
                        }
                        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        self.alert("A new version of Refloor is available. Please update to latest version", [yes,no])
                    }
                }
            }
            
            else
            {
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
                
            }
        }
    }
    
}



