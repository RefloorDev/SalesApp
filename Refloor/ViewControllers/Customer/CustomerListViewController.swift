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
import CoreLocation


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
    var geocoder = CLGeocoder()
    
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

    }
    override func viewWillAppear(_ animated: Bool) {
        //
//        self.locationManager = CLLocationManager()
//        self.locationManager!.delegate = self
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
        let masterData = self.getMasterDataFromDB()
        let restrictGeoLocation = UserDefaults.standard.value(forKey: "restrict_geolocation") as! Int
        if masterData.enableGeoLocation && restrictGeoLocation == 0
        {
            startGeoLocation(appointments: appoinmentsList!)
            
        }
        
    }
    
    func startGeoLocation(appointments:[AppoinmentDataValue])
    {
        if appointments.count > 0
        {
            for appointment in appointments {
                
                self.geoFencing(latitude: appointment.partner_latitude ?? 0.0, longtitude: appointment.partner_longitude ?? 0.0,appointmentId: appointment.id!)
                    //print("Lat: \(lat), Lon: \(lon)")
               // }
                
            }
        //let address = "1600 Amphitheatre Parkway, Mountain View, CA"
            
}
    }
    
    func geoFencing (latitude:CLLocationDegrees,longtitude:CLLocationDegrees,appointmentId:Int)
    {
        let masterData = self.getMasterDataFromDB()
        var radius = 1.0//Double(masterData.geoLocationRadius) * 0.305
        let geofenceRegionCenter = CLLocationCoordinate2DMake(latitude, longtitude)
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: radius,
                                              identifier: "\(appointmentId)")
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        //let locationManager = CLLocationManager()
        
        AppDelegate.locationManager?.startMonitoring(for: geofenceRegion)
        
        
        
        
        print("started monitoring")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        let masterData = self.getMasterDataFromDB()
        let restrictGeoLocation = UserDefaults.standard.value(forKey: "restrict_geolocation") as! Int
        if masterData.enableGeoLocation && restrictGeoLocation == 0
        {
            startGeoLocation(appointments: appoinmentsList!)
            
        }
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
            
            cell.customerNameLabel.text = name
            
            // cell.timeLabel.text = Date().TimeOnlyForCustomerList(datestr: appoinmentsList?[indexPath.row].appointment_date ?? "")
            cell.timeLabel.text =  appoinmentsList?[indexPath.row].appointment_datetime ?? ""
            
            
            
            
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
        if indexPath.row == 0
        {
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
            cell.locationImageView.isHidden = false
            cell.customerLocationLabel.text = address
        }
        else
        {
            cell.customerLocationLabel.text = ""
            cell.locationImageView.isHidden = true
        }
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
    
    @IBAction func startButtonActionFromCustomerList(_ sender: UIButton)
    {
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
                    if let convertedDateString = self.convertDateString(self.appoinmentsList![sender.tag].appointment_datetime ?? "") {
                                    //   print("convertedDateString", convertedDateString)
                                      self.alert("Are you sure you want to proceed with this" + " " + "\(convertedDateString) appointment?", [yes,no])
                                  }
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
        
        
     
//        createAppointResultDemoedNotDemoedDB(appointmentId:self.appoinmentsList![sender.tag].id ?? 0)
////
//        if self.appoinmentsList?[sender.tag].appointmentStatus == AppointmentStatus.start{
////            //print(getTodayWeekDay())
//            let details = CustomerDetailsOneViewController.initialization()!
//            details.appoinmentslData = self.appoinmentsList![sender.tag]
//            _ = AppointmentData(appointment_id: self.appoinmentsList![sender.tag].id ?? 0)
//
//            UserDefaults.standard.set(self.appoinmentsList![sender.tag].recisionDate ?? "", forKey: "Recision_Date")
//           // let details = InstallerShedulerViewController.initialization()!
//            self.navigationController?.pushViewController(details, animated: true)
//
//      }
        

    }
    
    func convertDateString(_ inputDateString: String) -> String? {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "dd MMM h:mm a"

           if let date = inputFormatter.date(from: inputDateString) {
               let outputFormatter = DateFormatter()

               // Include last two digits of the current year in the output format
               let currentYear = Calendar.current.component(.year, from: Date()) % 100
               outputFormatter.dateFormat = "MM/dd/\(String(format: "%02d", currentYear)) h:mma"

               return outputFormatter.string(from: date).lowercased()
           } else {
               return nil
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

//extension CustomerListViewController : CLLocationManagerDelegate
//{
////    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
////        if region is CLCircularRegion {
////            print("Exit GeoLocation region")
////            // Do what you want if this information
////            // self.handleEvent(forRegion: region)
////        }
////    }
//    
//    // called when user Enters a monitored region
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        alert("Entered region", nil)
//        if region is CLCircularRegion {
//            print("Did Enter geoLocation region")
//            let entryTime = Date().dateToString()
//            do
//            {
//                let realm = try Realm()
//                try realm.write{
//                    let appointmentId = Int(region.identifier)
//                    let entryTime:[String:Any] = ["appointment_id":appointmentId!, "entryTime": entryTime,"exitTime":""]
//                    realm.create(rf_GeoLocationData.self, value: entryTime, update: .all)
//                }
//            }
//            catch{
//                print(RealmError.initialisationFailed)
//            }
//            // Do what you want if this information
//            // self.handleEvent(forRegion: region)
//        }
//    }
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        print("The monitored regions are: \(manager.monitoredRegions)")
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//           if status == .authorizedWhenInUse {
//               locationManager?.requestLocation()
//           }
//       }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let monitoredRegions = manager.monitoredRegions
//
//        for region in monitoredRegions {
//            if let circularRegion = region as? CLCircularRegion, circularRegion.contains(location.coordinate) {
//                // The user is inside this region; handle accordingly
//                alert("User is inside the region", nil)
//                //handleUserWithinRegion(circularRegion)
//                break
//            }
//        }
//    }
//
//}



