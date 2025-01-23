//
//  AppDelegate.swift
//  Refloor
//
//  Created by sbek on 16/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
import RealmSwift

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,MessagingDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let regid = UIDevice.current.identifierForVendor!.uuidString
    public static var roomData:[RoomDataValue] = []
    public static var floorLevelData:[FloorLevelDataValue] = []
    public static var appoinmentslData:AppoinmentDataValue!
    public static var locationManager: CLLocationManager?
    var notificationCenter: UNUserNotificationCenter?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        for family in UIFont.familyNames {
//                        print("family:", family)
//                        for font in UIFont.fontNames(forFamilyName: family) {
//                            print("font:", font)
//                        }
//                    }
        
//        let initialViewController = LoginViewController()
//            
//            // Embed it inside a UINavigationController
//            let navigationController = UINavigationController(rootViewController: initialViewController)
//            
//            // Set the rootViewController to the navigation controller
//            window?.rootViewController = navigationController
//            window?.makeKeyAndVisible()
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion:  21,//7, // production 12

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
        })
        Realm.Configuration.defaultConfiguration = config
        IQKeyboardManager.shared.enable = true
        if UserDefaults.standard.string(forKey: "BASE_URL") ?? "" == ""
        {
            BASE_URL = AppURL().LIVE_BASE_URL //Live url
            UserDefaults.standard.set(BASE_URL, forKey: "BASE_URL")
        }
        else
        {
            BASE_URL = UserDefaults.standard.string(forKey: "BASE_URL") ?? ""
        }
        //IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
        GMSServices.provideAPIKey(AppDetails.GOOGLE_MAP_KEY)
        GMSPlacesClient.provideAPIKey(AppDetails.GOOGLE_MAP_KEY)
        // Override point for customization after application launch.
        ImageSaveToDirectory.SharedImage.CreateFolderInDocumentDirectory()
        BackgroundTaskService.shared.registerBackgroundTaks()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
                  self.notificationCenter = UNUserNotificationCenter.current()
                   // For iOS 10 display notification (sent via APNS)
            self.notificationCenter!.delegate = self
                   
                   let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                   self.notificationCenter!.requestAuthorization(
                       options: authOptions,
                       completionHandler: {_, _ in })
               }
               else
               {
                   let settings: UIUserNotificationSettings =
                       UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                   application.registerUserNotificationSettings(settings)
               }
               application.applicationIconBadgeNumber=0
               application.registerForRemoteNotifications()
        AppDelegate.locationManager = CLLocationManager()
        AppDelegate.locationManager?.delegate = self
        let status = CLLocationManager.authorizationStatus()
               if status == .notDetermined {
                   // Request "When In Use" first
                   AppDelegate.locationManager?.requestWhenInUseAuthorization()
               } else if status == .authorizedWhenInUse {
                   // If already authorized for "When In Use," request "Always"
                   AppDelegate.locationManager?.requestAlwaysAuthorization()
               }
//        else if status == .denied
//        {
//            showLocationPermissionDeniedAlert()
//        }

        AppDelegate.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        AppDelegate.locationManager?.requestWhenInUseAuthorization()
//        AppDelegate.locationManager?.requestAlwaysAuthorization()
        //locationManager?.activityType = .automotiveNavigation
        //locationManager?.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                AppDelegate.locationManager?.requestAlwaysAuthorization()
                //promptToChangeLocationSettings()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            @unknown default:
                    break
                
            }
        } else {
            print("Location services are not enabled")
        }

        AppDelegate.locationManager?.startUpdatingLocation()
        geoLocationApiCallSync()
//            }
        

        return true
    }
   
    
    

    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           print("APNs token retrieved: \(deviceToken)")
           Messaging.messaging().apnsToken = deviceToken
           
           
           Messaging.messaging().token { token, error in
               if let error = error {
                   print("Error fetching FCM registration token: \(error)")
               } else if let token = token {
                   print("FCM registration token: \(token)")
                   // self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
               }
       }
       }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
            // If you are receiving a notification message while your app is in the background,
            // this callback will not be fired till the user taps on the notification launching the application.
            // TODO: Handle data of notification
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            // Messaging.messaging().appDidReceiveMessage(userInfo)
            // Print message ID.
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }
            
            // Print full message.
            print(userInfo)
        }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Unable to register for remote notifications: \(error.localizedDescription)")
        }
        
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            print("Firebase registration token: \(String(describing: fcmToken!))")
            
            
            UserDefaults.standard.set(fcmToken ?? "", forKey:"fireBaseToken")
            print(UserDefaults.standard.value(forKey: "fireBaseToken")!)
            //let dataDict:[String: String] = ["token": fcmToken ?? ""]
            //NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Refloor")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
        CustomerListViewController().BackendApiSyncCall()
        window?.endEditing(true)
        geoLocationApiCallSync()
        
    }
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
        geoLocationApiCallSync()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
            window?.endEditing(true)
        }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
        {
            UIApplication.shared.applicationIconBadgeNumber = 0
            var pushMessage:String = String()
            let userInfo = response.notification.request.content.userInfo
            for (key,value) in userInfo{
                print("key = \(key) , value = \(value)")
            }
            if let pushKey = userInfo["aps"] as? [String:Any]
            {
                if let pushAlert = pushKey["alert"] as? [String:Any]
                {
                    pushMessage = pushAlert["body"] as! String
                }
                
            }
                    
          
                    let sbMain = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sbMain.instantiateViewController(withIdentifier: "ViewLogListViewController") as! ViewLogListViewController
                               //vc.nNotificationID = notificationID
            let appointmentId = userInfo["gcm.notification.res_id"] as? String
            vc.appointmentId = appointmentId ?? ""
            vc.message = pushMessage 
                               if let topVC = UIApplication.getTopViewController() {
                                   topVC.navigationController?.pushViewController(vc, animated: false)
                }
                    }
        

    
}

extension AppDelegate : CLLocationManagerDelegate
{
    
    func saveScreenCompletionTimeToDb(appointmentId: Int, className: String, displayName: String, time: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let timeStr = dateFormatter.string(from: time)
        let realm = try! Realm()
            let completionTime = ScreenCompletion(appointment_id: appointmentId, className: className, displayName: displayName, completionTime: timeStr)
            try! realm.write {
                realm.add(completionTime)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("Exit GeoLocation region")
            let exitTime = Date().dateToString()
            var parameters:[String:Any] = [:]
            let currentClassName = String(describing: type(of: self))
            let classDisplayName = "GeoLocation"
            self.saveScreenCompletionTimeToDb(appointmentId: Int(region.identifier) ?? 0, className: currentClassName, displayName: classDisplayName, time: Date())
            let appointment = self.getAppointmentData(appointmentId: Int(region.identifier) ?? 0)
            let firstName = appointment?.applicant_first_name ?? ""
            let lastName = appointment?.applicant_last_name ?? ""
            let name = lastName == ""  ? firstName : firstName + " " + lastName
            let date = appointment?.appointment_datetime ?? ""
            let entryTime = geoLocationTimeForAppointments(appointmentId: Int(region.identifier) ?? 0)
            
            do
            {
                let realm = try Realm()
                try realm.write{
                    let appointmentId = Int(region.identifier)
                    let geoLocationValues:[String:Any] = ["appointmentId":appointmentId!, "entryTime": entryTime,"exitTime":exitTime,"syncStatus":false]
                    realm.create(rf_GeoLocationData.self, value: geoLocationValues, update: .all)
                    let token = UserData.init().token!
                    parameters = ["appointment_id":Int(region.identifier) ?? 0, "arrival_date":entryTime,"departure_date": exitTime,"token":token]
                    AppDelegate.locationManager?.stopMonitoringVisits()
                }
            }
            catch{
                print(RealmError.initialisationFailed)
            }
            // Do what you want if this information
            // self.handleEvent(forRegion: region)
           
            geoLocationApiCall(parameter:parameters) {success in
                if success!
                {
                    let appointmentId = Int(region.identifier)
                    let geoLocationValues:[String:Any] = ["appointmentId":appointmentId!, "entryTime": entryTime,"exitTime":exitTime,"syncStatus":true]
                    self.updatingGeolocationSyncValues(geoLocationValues: geoLocationValues)
                   
                }
            }
        
            
        }
        handleEvent(forRegion: region, action: "Exited Location")
    }
    
    func getAppointmentData(appointmentId:Int) -> rf_master_appointment!{
        var appointmentData : rf_master_appointment!
        do{
            let realm = try Realm()
            if let appointment = realm.objects(rf_master_appointment.self).filter("id == %d",appointmentId).first{
                appointmentData = appointment
            }else if let  appointmentReq = realm.objects(rf_Completed_Appointment_Request.self).filter("reqest_title == %d AND appointment_id == %d", RequestTitle.CustomerAndRoom.rawValue,appointmentId).first{
                let customerFullDict = appointmentReq.request_parameter?.dictionaryValue() ?? [:]
                //let customerFullDict = JWTDecoder.shared.decodeDict(jwtToken: appointmentReq.request_parameter ?? "")
                //let customerDictData = customerFullDict["data"] as? [String:Any]
                let customerDict = customerFullDict["customer"] as? [String:Any] ?? [:]
                appointmentData = rf_master_appointment(appointmentObj: customerDict)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentData
    }
    func saveLogDetailsForAppointment(appointmentId: Int, logMessage: String ,time:String, errorMessage: String = "",name:String,appointmentDate:String,payment_status:String = "",payment_message:String = ""){
        do{
            let realm = try Realm()
            var dict:[String:Any] = [:]
            try realm.write{
                let appointmentLogs = realm.objects(rf_Appointment_Logs.self).filter("appointment_id == %@",appointmentId)
                if appointmentLogs.count == 0{
                    let logList = RealmSwift.List<rf_Appointment_Log_Data>()
                    logList.append(rf_Appointment_Log_Data(message: logMessage, time: time, appointmentId: appointmentId,customerName:name,appointmentDateTime: appointmentDate))
                    let dict:[String:Any] = ["appointment_id":appointmentId,"sync_message":logList,"appBaseUrl":BASE_URL,"paymentStatus":payment_status,"paymentMessage":payment_message]
                    realm.create(rf_Appointment_Logs.self, value: dict, update: .all)
                }else{
                    if let appointmentLogsAlreadyExist = appointmentLogs.first{
                        let logArrayList = appointmentLogsAlreadyExist.sync_message
                        logArrayList.append(rf_Appointment_Log_Data(message: logMessage, time: time, appointmentId: appointmentId,customerName:name,appointmentDateTime: appointmentDate))
                        if payment_status == ""
                        {
                            let pay_message = appointmentLogsAlreadyExist.paymentMessage
                          
                           let pay_status = appointmentLogsAlreadyExist.paymentStatus
                            dict = ["appointment_id":appointmentId,"sync_message":logArrayList,"appBaseUrl":BASE_URL,"paymentStatus":pay_status ?? "","paymentMessage":pay_message ?? ""]
                        }
                        else
                        {
                            dict = ["appointment_id":appointmentId,"sync_message":logArrayList,"appBaseUrl":BASE_URL,"paymentStatus":payment_status ,"paymentMessage":payment_message ]
                        }
                        realm.create(rf_Appointment_Logs.self, value: dict, update: .all)
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func geoLocationApiCallSync()
    {
        let geoLocationData = geoLocationDataForSync() // for any data which is sync false to send to odoo
        for resultsData in geoLocationData
        {
            if resultsData.entryTime != "" || resultsData.exitTime != ""
            {
                let token = UserData.init().token!
                let parameter:[String:Any] = ["appointment_id":resultsData.appointmentId, "arrival_date":resultsData.entryTime!,"departure_date": resultsData.exitTime!,"token":token]
                geoLocationApiCall(parameter:parameter) {success in
                    var geoLocationValues:[String:Any] = parameter
                    geoLocationValues["syncStatus"] = true
                    self.updatingGeolocationSyncValues(geoLocationValues: geoLocationValues)
                }
                
            }
        }
    }
    
    func updatingGeolocationSyncValues(geoLocationValues:[String:Any])
    {
        do
        {
            let realm = try Realm()
            try realm.write{
                realm.create(rf_GeoLocationData.self, value: geoLocationValues, update: .all)
            }
        }
        catch{
            print(RealmError.initialisationFailed)
        }
    }
    func geoLocationApiCall(parameter:[String:Any],completion:@escaping (_ success: Bool?) -> ())
    {
       if HttpClientManager.SharedHM.connectedToNetwork()
        {
           let (_,timeZone) = Date().getCompletedDateStringAndTimeZone()
           var parameterToPass:[String:Any] = [:]
           parameterToPass = parameter
           parameterToPass["timezone"] = timeZone
           HttpClientManager.SharedHM.geoLocationTimeSubmitAPi(parameter: parameterToPass) {success, message in
               if success == "Success"
               {
                   completion(true)
               }
               else
               {
                   completion(false)
               }
           }
        }
    }
    func geoLocationTimeForAppointments(appointmentId:Int) -> String
    {
        var entryTime = ""
        do
        {
            let realm = try Realm()
            if let appointment = realm.objects(rf_GeoLocationData.self).filter("appointmentId == %d", (appointmentId)).first
            {
                entryTime = appointment.entryTime ?? ""
            }
        }
        catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return entryTime
    }
    func geoLocationExitTimeForAppointments(appointmentId:Int) -> String
    {
        var exitTime = ""
        do
        {
            let realm = try Realm()
            if let appointment = realm.objects(rf_GeoLocationData.self).filter("appointmentId == %d", (appointmentId)).first
            {
                exitTime = appointment.exitTime ?? ""
            }
        }
        catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return exitTime
    }
    func geoLocationDataForSync() -> RealmSwift.Results<rf_GeoLocationData>
    {
        var geoLocationData : Results<rf_GeoLocationData>!
        do
        {
            let realm = try Realm()
            geoLocationData = realm.objects(rf_GeoLocationData.self).filter("syncStatus == %@", (false))
            return geoLocationData
        }
        catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return geoLocationData
    }
    func handleEvent(forRegion region: CLRegion!,action: String) {
        // customize your notification content
//           let content = UNMutableNotificationContent()
//           content.title = "Refloor"
//        content.body = action
//        content.sound = UNNotificationSound.default
//
//           // when the notification will be triggered
//           var timeInSeconds: TimeInterval = 1 // 60s * 15 = 15min
//
//           // the actual trigger object
//           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
//                                                           repeats: false)
//
//           // notification unique identifier, for this example, same as the region to avoid duplicate notifications
//           let identifier = region.identifier
//
//           // the notification request object
//           let request = UNNotificationRequest(identifier: identifier,
//                                               content: content,
//                                               trigger: trigger)
//
//           // trying to add the notification request to notification center
//        UNUserNotificationCenter.current().add(request) { error in
//                    if let error = error {
//                        print("Error adding notification: \(error.localizedDescription)")
//                    }
//                }
    }
    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //alert("Entered region", nil)
        if region is CLCircularRegion {
            print("Did Enter geoLocation region")
            var parameters:[String:Any] = [:]
            let entryTime = geoLocationTimeForAppointments(appointmentId: Int(region.identifier)!)
            let appointment = self.getAppointmentData(appointmentId: Int(region.identifier) ?? 0)
            let firstName = appointment?.applicant_first_name ?? ""
            let lastName = appointment?.applicant_last_name ?? ""
            let name = lastName == ""  ? firstName : firstName + " " + lastName
            let date = appointment?.appointment_datetime ?? ""
            
            if entryTime == ""
            {
                let entryTime = Date().dateToString()
                do
                {
                    let realm = try Realm()
                    try realm.write{
                        let appointmentId = Int(region.identifier)
                        let entryTime:[String:Any] = ["appointmentId":appointmentId!, "entryTime": entryTime,"exitTime":"","syncStatus":false]
                        realm.create(rf_GeoLocationData.self, value: entryTime, update: .all)
                        let token = UserData.init().token!
                        parameters = ["appointment_id":Int(region.identifier) ?? 0, "arrival_date":entryTime,"departure_date": "","token":token]
                    }
                }
                catch{
                    print(RealmError.initialisationFailed)
                }
                
                geoLocationApiCall(parameter:parameters) {success in
                    if success!
                    {
                        let appointmentId = Int(region.identifier)
                        let geoLocationValues:[String:Any] = ["appointmentId":appointmentId!, "entryTime": entryTime,"exitTime":"","syncStatus":false]
                        self.updatingGeolocationSyncValues(geoLocationValues: geoLocationValues)
                       
                    }
                }
            }
            else
            {
                return
            }
            // Do what you want if this information
            // self.handleEvent(forRegion: region)
        }
        handleEvent(forRegion: region, action: "Enter Location")
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("The monitored regions are: \(manager.monitoredRegions)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
               switch status {
               case .denied:
                   // Show alert directing user to enable location
                   DispatchQueue.main.async {
                       let alertController = UIAlertController(
                           title: "Location Permission Denied",
                           message: "Please enable location services in Settings",
                           preferredStyle: .alert
                       )
                       alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                           if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                               UIApplication.shared.open(appSettings)
                           }
                       })
                       alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                       self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                   }

                   
               case .authorizedWhenInUse:
                   AppDelegate.locationManager?.requestAlwaysAuthorization()
                   
               default:
                   break
               }
           }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let monitoredRegions = manager.monitoredRegions
        print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        for region in monitoredRegions {
            if let circularRegion = region as? CLCircularRegion, circularRegion.contains(location.coordinate) {
                // The user is inside this region; handle accordingly
                //alert("User is inside the region", nil)
                print("Inside the area")
                var parameters:[String:Any] = [:]
                var entryTime = geoLocationTimeForAppointments(appointmentId: Int(region.identifier)!)
                //var exiTime = geoLocationExitTimeForAppointments(appointmentId: Int(region.identifier)!)
                var geoLocationValues:[String:Any] = [:]
                if entryTime == ""
                {
                    do
                    {
                        let realm = try Realm()
                        try realm.write{
                            let appointmentId = Int(region.identifier)
                            entryTime = Date().dateToString()
                            geoLocationValues = ["appointmentId":appointmentId!, "entryTime": entryTime,"exitTime":"","syncStatus":false]
                            realm.create(rf_GeoLocationData.self, value: geoLocationValues, update: .all)
                            let token = UserData.init().token!
                            parameters = ["appointment_id":Int(region.identifier) ?? 0, "arrival_date":entryTime,"departure_date": "","token":token]
                            //let entryTime = geoLocationTimeForAppointments(appointmentId: Int(region.identifier)!)
                            let appointment = self.getAppointmentData(appointmentId: Int(region.identifier) ?? 0)
                            let firstName = appointment?.applicant_first_name ?? ""
                            let lastName = appointment?.applicant_last_name ?? ""
                            let name = lastName == ""  ? firstName : firstName + " " + lastName
                            let date = appointment?.appointment_datetime ?? ""
                           
                        }
                    }
                    catch{
                        print(RealmError.initialisationFailed)
                    }
                    
                    
                    geoLocationApiCall(parameter:parameters) {success in
                        if success!
                        {
                            //let appointmentId = Int(region.identifier)
                            //let geoLocationValues:[String:Any] = ["appointmentId":appointmentId!, "entryTime": entryTime,"exitTime":exiTime,"syncStatus":true]
                            self.updatingGeolocationSyncValues(geoLocationValues: geoLocationValues)
                            
                        }
                    }
                }
                else
                {
                    return
                }
                

                //handleUserWithinRegion(circularRegion)
                break
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
            print("error:: \(error.localizedDescription)")
       }

}

