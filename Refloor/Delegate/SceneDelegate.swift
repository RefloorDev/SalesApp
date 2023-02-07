//
//  SceneDelegate.swift
//  Refloor
//
//  Created by sbek on 16/03/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    public static var timer = Timer()
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        /*  let now = Date()
         let LastGoggedInDate =  UserData.getLoggedInDate()
         let df = DateFormatter()
         df.dateFormat = "dd/MM/yyyy"
         print("date is differemt:",df.string(from: now))
         print("date is differemt:",df.string(from:LastGoggedInDate as Date))
         if(df.string(from: now) != df.string(from:LastGoggedInDate as Date))
         {
         
         print("date is differemt")
         if let topVC = UIApplication.getTopViewController()
         {
         // topVC.view.addSubview(forgotPwdView)
         UserData.setLogedInVal(false)
         let isoDate = "1970-04-14T10:44:00+0000"
         let dateFormatter = DateFormatter()
         dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
         let date = dateFormatter.date(from:isoDate)!
         
         UserData.setLogedInDate(loginDate:date as NSDate)
         topVC.navigationController?.pushViewController(LoginViewController.initialization()!, animated: true)
         }
         // CustomerListViewController().autoLogOutbuttonAction()
         }*/
        
        
        
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        //code here
        if((UserData.isLogedIn() == true))
        {
            let customer = CustomerListViewController.initialization()!
            // customer.updateAppointmentOffline()
            // Called as the scene transitions from the background to the foreground.
            // Use this method to undo the changes made on entering the background.
            print("Hia")
            SceneDelegate.timer.invalidate()
        }
        
        
    }
    
    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
        let appointmentRequestArray = BackgroundTaskService.shared.getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
        
        if(appointmentRequestArray.count != 0)
        {
            if(!SceneDelegate.timer.isValid)
            {
                SceneDelegate.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
                    
                    print("TIMER WAKEUP Scene")
                    BackgroundTaskService.shared.startSyncProcess(comments: "", sendPhysical: false)
                })
            }
           
            BackgroundTaskService.shared.enterBackground()
        }
    }
    
    
}

