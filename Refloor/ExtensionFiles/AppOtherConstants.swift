//
//  MHPAppConstats.swift
//  MyHansonsProject
//
//  Created by Apps17 on 6/8/17.
//  Copyright © 2017 ARM. All rights reserved.
//

import UIKit

struct AppDetails {
    //App Details
    static let APP_NAME = "Refloor"
    static let ITUNES_URL = ""
    static let BUNDIL_ID = ""
    static let LANGUAGE_CODE = AppLanguage.getAppLanguage()
    static let GOOGLE_MAP_KEY = "AIzaSyACAwHfZTycvArwSqXqNuML3MkGIX3cZN8"
}



struct AppColors {
    static let TheamColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
    static let AppVailotColor = UIColor(displayP3Red: 30/255, green: 49/255, blue: 234/255, alpha: 1) //rgba(30, 49, 234, 1)
    static let AppGrayColor = UIColor(displayP3Red: 153/255, green: 153/255, blue: 153/255, alpha: 1) //rgba(153, 153, 153, 1)
    static let AppDarkGrayColor = UIColor(displayP3Red: 89/255, green: 96/255, blue: 113/255, alpha: 1) //rgba(89, 96, 113, 1)
    static let AppGreenColor = UIColor(displayP3Red: 94/255, green: 216/255, blue: 85/255, alpha: 1) //rgba(94, 216, 85, 1)
    static let AppRedColor = UIColor(displayP3Red: 245/255, green: 37/255, blue: 103/255, alpha: 1) //rgba(245, 37, 103, 1)
    static let AppLightGreenColor = UIColor(displayP3Red: 140/255, green: 212/255, blue: 0/255, alpha: 1) //rrgba(140, 212, 0, 1)
    static let AppHeaderLightPinkColor =  UIColor(displayP3Red: 170/255, green: 169/255, blue: 204/255, alpha: 1) //rgba(170, 169, 204, 1)
    
    
    
    
}

struct AppLanguage {
    
    static let EnglisLabelText = "English"
    static let ArabicLabelText = "Arabic"
    static let English = "en"
    static let Arabic = "ar"
    static func getAppLanguage() -> String
    {
        let value = UserDefaults.standard.string(forKey: "AppLanguage") ?? ""
        if(value == "")
        {
            return AppLanguage.English
        }
        else
        {
            return value
        }
    }
    func setDefaultAppLanguage(_ language:String)
    {
        UserDefaults.standard.set(language, forKey: "AppLanguage")
    }
    
}

struct AppIntigers {
}
struct PushNotification{
    static let Approved = "Approved"
    static let Declained = "Declained"
    static let code = 911
}
struct LocationAccess{
    static let Approved = "Approved"
    static let Declained = "Declained"
    static let code = 922
}

struct AppViewTitle {
    //App Title
    
}

struct AppAlertTitle {
    //App Alert Title
    
}






struct storyboardIdentifier {
    
    static let mainStoryBoard   = "Main"
    
    
    
    
}

struct KeyConstants {
    // API response Key
    static let key_token  = "token"

}

struct MHPCellIdentifier {
    //App cell Identifiers
    
}

// MARK: - Device Parameter

enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    
    
}

struct ShapeID
{
    static let l_shape = 1
}
