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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 4,//3

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
                   // For iOS 10 display notification (sent via APNS)
                   UNUserNotificationCenter.current().delegate = self
                   
                   let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                   UNUserNotificationCenter.current().requestAuthorization(
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
        
    }
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        UIApplication.shared.applicationIconBadgeNumber = 0
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

