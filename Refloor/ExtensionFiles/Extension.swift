//
//  Extension.swift
//  EmpolyeesApp
//
//  Created by sbek on 07/02/19.
//  Copyright © 2019 oneteamus. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
//import SDWebImage
import CoreLocation
import DropDown
import RealmSwift
import SwiftUI
import JWTCodable
import CryptoKit
import CommonCrypto


enum MyErrors: String, Error {
   case badError = "I think it went wrong here"
   case evilError = "This should have never happened"
}

extension UILabel {
    
    func startBlink() {
        UIView.animate(withDuration: 0.4,
                       delay:0.0,
                       options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0.3 },
                       completion: nil)
    }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
extension UITextField{
    func setPlaceHolderWithColor(placeholder:String,colour:UIColor)
    {
        self.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                        attributes: [NSAttributedString.Key.foregroundColor: colour])
    }
    func setLeftPaddingPoints(_ amount:CGFloat){
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
    func setRightPaddingPoints(_ amount:CGFloat) {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    
}
extension CGFloat
{
    var toString: String {
        let value = String(Float(self))
        if(value.split(separator: ".").count == 2)
        {
            let valuearray = value.split(separator: ".")
            if(String(valuearray[1]).count > 2)
            {
                let secondTempValue = String(valuearray[1])
                
                let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + String(secondTempValue.character(at: 1) ?? "0")
                return finalvalue
            }
        }
        
        return value
    }
    
    
    //    var clean: String {
    //       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    //    }
}
extension Float
{
    
    var toDoubleString: String
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        let value = formattedNumber ?? String(Float(self))
        if(value.split(separator: ".").count == 2)
        {
            let valuearray = value.split(separator: ".")
            if(String(valuearray[1]).count > 2)
            {
                let secondTempValue = String(valuearray[1])
                
                let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + String(secondTempValue.character(at: 1) ?? "0")
                return finalvalue
            }
            else if (String(valuearray[1]).count == 1)
            {   let secondTempValue = String(valuearray[1])
                let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + "0"
                return finalvalue
            }
        }
        else
        {
            return value + ".00"
        }
        
        
        return value
    }
}
extension Double
{
    var toString: String {
        let toString = String(self)
        return toString
    }
    var toDoubleString: String
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        let value = formattedNumber ?? String(Float(self))
        if(value.split(separator: ".").count == 2)
        {
            let valuearray = value.split(separator: ".")
            if(String(valuearray[1]).count > 2)
            {
                let secondTempValue = String(valuearray[1])
                
                let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + String(secondTempValue.character(at: 1) ?? "0")
                return finalvalue
            }
            else if (String(valuearray[1]).count == 1)
            {   let secondTempValue = String(valuearray[1])
                let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + "0"
                return finalvalue
            }
        }
        else
        {
            return value + ".00"
        }
        
        
        return value
    }
    var toRoundCommaString:String{
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        let value = formattedNumber ?? String(Float(self))
        if(value.split(separator: ".").count == 2)
        {
            let valuearray = value.split(separator: ".")
            if(String(valuearray[1]).count > 2)
            {
                let secondTempValue = String(valuearray[1])
                
                let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + String(secondTempValue.character(at: 1) ?? "0")
                return finalvalue
            }
        }
        return value
    }
    
    var toRoundeString: String {
        let value = String(Float(self))
        if(value.split(separator: ".").count == 2)
        {
            let valuearray = value.split(separator: ".")
            if(String(valuearray[1]).count > 2)
            {
                let secondTempValue = String(valuearray[1])
                
                let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + String(secondTempValue.character(at: 1) ?? "0")
                return finalvalue
            }
        }
        
        return value
    }
    
    
    var clean: String {
                
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        let value = formattedNumber ?? String(Float(self))
        
        let valuearray = value.split(separator: ".")
        return String(valuearray[0])
    }
    
    var noDecimal: String {
        
        
        
        //   let numberFormatter = NumberFormatter()
        // numberFormatter.numberStyle = NumberFormatter.Style.none
        
        //   let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        let value =  String(Double(self))
        
        //       if(value.split(separator: ".").count == 2)
        //       {
        //           let valuearray = value.split(separator: ".")
        //           if(String(valuearray[1]).count > 2)
        //           {
        //               let secondTempValue = String(valuearray[1])
        //
        //               let finalvalue = String(valuearray[0]) + "." + String(secondTempValue.character(at: 0) ?? "0") + String(secondTempValue.character(at: 0) ?? "0")
        //               return finalvalue
        //           }
        //       }
        
        //        return String(format: "%\(f)f", Double(value))
        let valuearray = value.split(separator: ".")
        
        return String(valuearray[0])
    }
    
    
}
extension UIView{
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    func addDashedBorder(size:CGSize) {
        let color = UIColor().colorFromHexString("#A7B0BA").cgColor//UIColor.black.cgColor
            //#A7B0BA
            let shapeLayer:CAShapeLayer = CAShapeLayer()
            let frameSize = size
            let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
            
            shapeLayer.bounds = shapeRect
            shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = color
            shapeLayer.lineWidth = 1
            shapeLayer.lineJoin = CAShapeLayerLineJoin.round
            shapeLayer.lineDashPattern = [5,5]
            shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 4).cgPath
            
            self.layer.addSublayer(shapeLayer)
        }
    
    func setDeSelected(_ color:UIColor)
    {
        if let textField = self as? UITextField
        {
            textField.layer.borderColor = color.cgColor
            textField.layer.borderWidth = 0
        }
        else if let label = self as? UILabel
        {
            label.textColor = color
        }
        else
        {
            for sublayer in self.layer.sublayers ?? []
            {
                sublayer.removeFromSuperlayer()
            }
            self.borderWidth = 0
            self.borderColor = UIColor.clear
            self.layer.sublayers = []
        }
    }
    func setSelected(_ color:UIColor)
    {
        if let textField = self as? UITextField
        {
            textField.layer.borderColor = color.cgColor
            textField.layer.borderWidth = 1
        }
        else if let label = self as? UILabel
        {
            label.textColor = color
        }
        else
        {
            setboarderDashedLines()
            self.borderWidth = 1
            self.borderColor = UIColor.red
        }
    }
    
    func setboarderDashedLines()
    {
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.red.cgColor
        yourViewBorder.lineDashPattern = [4, 4]
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: self.bounds).cgPath
        self.layer.addSublayer(yourViewBorder)
    }
    func hideorShow(_ isHide:Bool)
    {
        UIView.animate(withDuration: 0.3) {
            self.isHidden = isHide
            self.layoutIfNeeded()
        }
    }
    func hideWithConstrain(_ constrain:NSLayoutConstraint,_ value:CGFloat ,_ isHide:Bool)
    {
        UIView.animate(withDuration: 0.3) {
            self.isHidden = isHide
            constrain.constant = value
            self.layoutIfNeeded()
        }
    }
    func setShadow(color:UIColor,size:CGSize,opacity:Float)
    {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = opacity
    }
    @IBInspectable var ShadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    @IBInspectable var ShadowSize: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    @IBInspectable var ShadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension Int{
    func toString() -> String
    {
        return String(self)
    }
}
extension String{
    
    func getSyncDateAsDate() -> Date{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM hh:mm:ss a"
        formatter1.amSymbol = "AM"
        formatter1.pmSymbol = "PM"
        formatter1.locale = Locale(identifier: "en_US_POSIX")
        formatter1.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = formatter1.date(from: self){
            return date
        }
        return Date()
    }
    func dateconverterEncoding(_ dateString:String ) ->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let resultString = dateFormatter.string(from: date!)
        return resultString
    }
    
    
    func setForTempartureValue() -> String
    {
        let stringArray = self.split(separator: ".")
        if(stringArray.count > 1)
        {
            return String(stringArray[0]) + "." + String(stringArray[1].first ?? "0")
        }
        else
        {
            return self
        }
    }
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
    
    func logDate() -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        //formatter.timeZone = TimeZone(identifier: "UTC")
        if let date = formatter.date(from: self){
            return date
        }
        return Date()
    }
    
    func promoSpecialDate(_ dateString:String ) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let resultString = dateFormatter.string(from: date!)
//        let resultdate = resultString.recisionDate()
//        return resultdate
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        dateFormatter1.dateStyle = .short
        if let resultDate = dateFormatter1.date(from: resultString)
        {
            return resultDate
        }
        return Date()
    }
    func autoLogoutDate() -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        if let date = formatter.date(from: self){
            return date
        }
        return Date()
    }
    
    func recisionDate() -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        if let date = formatter.date(from: self){
            return date
        }
        return Date()
    }
    
    func specialStartDate() -> Date
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        //formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        formatter.dateFormat = "YYYY-MM-dd hh:mm a"
        formatter.timeZone = TimeZone.current
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = formatter.date(from: self){
            return date
        }
        return Date()
    }
    
//    func specialEndDate() -> Date
//    {
//        let formatter = DateFormatter()
//        //formatter.locale = Locale(identifier: "en_US_POSIX")
//       // formatter.timeZone = TimeZone(abbreviation: "GMT-20:59")
//        formatter.dateFormat = "YYYY-MM-dd hh:mm a"
//        formatter.timeZone = TimeZone.current
//        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        if let date = formatter.date(from: self){
//            return date
//        }
//        return Date()
//    }
//
}

extension UIColor
{
    static let greenColor:UIColor = UIColor(displayP3Red: 100/255, green: 207/255, blue: 101/255, alpha: 1)
    //green : rgba(89, 207, 101, 1)
    static let ashColor:UIColor = UIColor(displayP3Red: 88/255, green: 100/255, blue: 113/255, alpha: 1) //rgba(88, 100, 113, 1)
    static let redColor:UIColor = UIColor(displayP3Red: 201/255, green: 63/255, blue: 72/255, alpha: 1) //rgba(201, 63, 72, 1)
    static  let AppColor:UIColor =  UIColor.white
    static  let placeHolderColor:UIColor = UIColor(displayP3Red: 167/255, green: 176/255, blue: 186/255, alpha: 1) //rgba(167, 176, 186, 1)
    static  let RandomColor:UIColor = UIColor(red:   .random(),
                                              green: .random(),
                                              blue:  .random(),
                                              alpha: 1.0)
    
    
    
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    func colorFromHexString (_ hex:String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return .red }
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return .red
        }
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIView {
    func applyGradient(colors: [CGColor], startPoint: CGPoint = CGPoint(x: 1, y: 0.5), endPoint: CGPoint = CGPoint(x: 0, y: 0.1)) {
        // Create a CAGradientLayer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        //gradientLayer.opacity = 0.5
        
        // Ensure the gradient is applied behind all other subviews
        if let sublayers = self.layer.sublayers, sublayers.count > 0 {
            self.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            self.layer.addSublayer(gradientLayer)
        }
    }
    func clearGradient() {
            // Remove any existing gradient layers
            self.layer.sublayers?.forEach { layer in
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
}



extension UIViewController:OrderStatusViewDelegate
{

    // Location from address for geoLocation
    
    func getCoordinatesFromAddress(address: String, completion: @escaping ((Double, Double)?) -> Void) {
        // Encode the address to be URL safe
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let apiKey = AppDetails.GOOGLE_MAP_KEY
        
        // Construct the URL for the Geocoding API request
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedAddress)&key=\(apiKey)"
        let url = URL(string: urlString)!
        
        // Create a URLSession task to fetch the data
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for errors
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            // Check if data is available
            guard let data = data else {
                print("Data is nil.")
                completion(nil)
                return
            }
            
            // Parse the JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let geometry = results[0]["geometry"] as? [String: Any],
                   let location = geometry["location"] as? [String: Double],
                   let lat = location["lat"],
                   let lng = location["lng"] {
                    completion((lat, lng))
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        // Start the URLSession task
        task.resume()
    }
    
    //Dynamic Contract update
    func getContractUpdateDocumentField(value:Int) -> RealmSwift.List<rf_fields>{
            var contractUpdateDocumentField : RealmSwift.List<rf_fields>!
            
            do{
                let realm = try Realm()
                let masterData = realm.objects(MasterData.self)
                if let contractFields = masterData.first?.contract_document_templates[value].fields{
                    contractUpdateDocumentField = contractFields
                }
            }catch{
                print(RealmError.initialisationFailed.rawValue)
            }
            return contractUpdateDocumentField
        }
    func getContractUpdateDocument() -> RealmSwift.List<rf_contract_document_templates_results>{
            var contractupdatedocument : RealmSwift.List<rf_contract_document_templates_results>!
            
            do{
               
                let realm = try Realm()
                let masterData = realm.objects(MasterData.self)
                if let contractDocument = masterData.first?.contract_document_templates{
                    contractupdatedocument = contractDocument
                    
                }
            }catch{
                print(RealmError.initialisationFailed.rawValue)
            }
            return contractupdatedocument
        }
    
    // AutoLogout
    func checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed:Bool)
    {
        let group = DispatchGroup()
        let token = UserData.init().token ?? ""
        var parameter : [String:Any] = [:]
        parameter = ["token":token]
        var autoLogoutTimeResult:String = String()
        var enableAutoLogoutResult:Int = Int()
        group.enter()
        //AutoLogout Api call
        HttpClientManager.SharedHM.autoLogoutAPi(parameter: parameter) { success, message, autoLogoutTime, enableAutoLogout in
            if(success ?? "") == "Success"
            {
                autoLogoutTimeResult = autoLogoutTime ?? ""
                enableAutoLogoutResult = enableAutoLogout ?? 0
                group.leave()
            }
            else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
        }
        group.notify(queue: DispatchQueue.main)
        {
            
       /*     if enableAutoLogoutResult == 0
            {
                return
            }
            else
            {
                let currentDateAndTime = Date().dateToString().autoLogoutDate()
                let masterDataAutoLogoutDate = autoLogoutTimeResult
                if masterDataAutoLogoutDate != ""
                {
                    let currentTime = self.getDate()
                    let isTimetoLogout = Date().compareTimeToAutoLogout(firstTime: currentTime, secondTime: masterDataAutoLogoutDate)
                    if isTimetoLogout
                    {
                        
                        let userLoggedInTime = UserDefaults.standard.value(forKey: "LoggedInTime") as! Date
                        var LogoutDateString = Date().autoLogoutdateToString()
                        LogoutDateString = LogoutDateString + " " + masterDataAutoLogoutDate
                        let LogoutDateStringDate = LogoutDateString.autoLogoutDate()
                        var masterLogoutDateString = LogoutDateString.autoLogoutDate()
                        if masterDataAutoLogoutDate == "00:00:00"
                        {
                            if LogoutDateStringDate < userLoggedInTime
                            {
                                
                                masterLogoutDateString = Calendar.current.date(byAdding: .day, value: 1, to: masterLogoutDateString)!
                            }
                            else
                            {
                                masterLogoutDateString = Calendar.current.date(byAdding: .day, value: -1, to: masterLogoutDateString)!
                            }
                        }
                        if userLoggedInTime < masterLogoutDateString
                        {
                            

                            let masterdataAutoLogoutTime = masterLogoutDateString
                            var onedayMinus = Calendar.current.date(byAdding: .day, value: -1, to: masterdataAutoLogoutTime)
                            onedayMinus = Calendar.current.date(byAdding: .minute, value: -1, to: onedayMinus!)
                            onedayMinus = Calendar.current.date(byAdding: .second, value: -1, to: onedayMinus!)
                            onedayMinus = Calendar.current.date(byAdding: .minute, value: 1, to: onedayMinus!)
                            let isTimeToAutoLogoutCall = currentDateAndTime.isBetween(date: onedayMinus!, andDate: masterdataAutoLogoutTime)
                            print(isTimeToAutoLogoutCall)
                            if isTimeToAutoLogoutCall
                            {
                                return
                            }
                            else
                            {
                                _ = self.isTimeToAutoLogout(isRefreshBtnPressed:isRefreshBtnPressed)
                                return
                            }
                        }
                        else
                        {
                            let userLoggedInDate = userLoggedInTime.autoLogoutdateToString()
                            let masterLogoutDate = masterLogoutDateString.autoLogoutdateToString()
                            if userLoggedInDate == masterLogoutDate
                            {
                                return
                            }
                            _ = self.isTimeToAutoLogout(isRefreshBtnPressed:isRefreshBtnPressed)
                            return
                        }
                    }
                    else
                    {
                        var userLoggedInTime = UserDefaults.standard.value(forKey: "LoggedInTime") as! Date
                        var LogoutDateString = Date().autoLogoutdateToString()
                        LogoutDateString = LogoutDateString + " " + masterDataAutoLogoutDate
                        var masterLogoutDateString = LogoutDateString.autoLogoutDate()
                        if userLoggedInTime > masterLogoutDateString
                        {
                            return
                        }
                        else
                        {
                            _ = self.isTimeToAutoLogout(isRefreshBtnPressed:isRefreshBtnPressed)
                            return
                        }
//
//
                    }
                
                }
                else
                {
                    return
                }
            } */
       }
    }


    func isTimeToAutoLogout(isRefreshBtnPressed:Bool) -> Bool
    {
                if determineIfAnyPendingAppointmentsToSink()
                {
                    if isRefreshBtnPressed
                    {
                        self.alert("Please sync all pending appointments in order to get today's appointment list", nil)
                    }
                    else
                    {
                        self.alert("There are pending appointments for syncing. Please sync all appointments, logout and relogin.", nil)
                    }
                    return false
                }
                else
        {
                    let params:[String:Any] = ["token":UserData.init().token ?? ""]
                    HttpClientManager.SharedHM.logoutApi(parameter: params) { result, message in
                        DispatchQueue.main.async{
                            if (result ?? "") == "Success"
                            {
                                UserData.setLogedInVal(false)
                                //UserDefaults.standard.set(false, forKey: "isAutoLogout")
                                BASE_URL = ""
                                UserDefaults.standard.set(BASE_URL, forKey: "BASE_URL")
                                //self.deleteAllAppointments()
                                self.navigationController?.pushViewController(LoginViewController.initialization()!, animated: true)
                                
                                
                            }
                        }
                        
                    }
                }
        return true
    }
    
    func getDate()->String{
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
       }
    
//    func autoLogout() -> (autoLogoutTime:String,enableAutoLogout:Int)
//    {
//        let token = UserData.init().token ?? ""
//        var parameter : [String:Any] = [:]
//        parameter = ["token":token]
//        var autoLogoutTimeResult:String = String()
//        var enableAutoLogoutResult:Int = Int()
//        HttpClientManager.SharedHM.autoLogoutAPi(parameter: parameter) { success, autoLogoutTime, enableAutoLogout in
//            if(success ?? "") == "Success"{
//                enableAutoLogoutResult = enableAutoLogout ?? 0
//                autoLogoutTimeResult = autoLogoutTime ?? ""
//
//
//                    //print(message ?? "No msg")
//                   //
//
//
//
//                //self.alert("Auto Logging out successfully." , [ok])
//
//            }
//            else
//            {
//                enableAutoLogoutResult = enableAutoLogout ?? 0
//                autoLogoutTimeResult = autoLogoutTime ?? ""
//                //return(false,autoLogoutTime)
//                //let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//
//                    //self.autoLogout()
//
//                //}
//               // let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//                //self.alert(AppAlertMsg.serverNotReached, [yes,no])
//            }
//        }
//        return (autoLogoutTimeResult,enableAutoLogoutResult)
//    }
    
    
    //    func dictionaryToJson(){
    //        guard let postData = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
    //            return
    //        }
    //    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    func DropDownDefaultfunction(_ view:UIView,_ width:CGFloat,_ values:[String], _ selectedIntex:Int,delegate:DropDownDelegate?,tag:Int)
    {
        let dropDown = DropDown()
        let appearance = DropDown.appearance()
        appearance.cellHeight = 50
        dropDown.anchorView =  view
        dropDown.dismissMode = .onTap
        dropDown.width = width
        dropDown.dataSource = values
        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? MyCell else { return }
            cell.optionLabel.font = UIFont.systemFont(ofSize: 20.0)
            if selectedIntex == index || selectedIntex == -2 {
                
                cell.optionLabel.textColor = UIColor.black
            }else{
                
                cell.optionLabel.textColor = UIColor.black
            }
            
        }
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            delegate?.DropDownDidSelectedAction(index, item, tag)
        }
        
        
        
        
    };
    
    func DropDownDefaultfunctionForTableCell(_ view:UIView,_ width:CGFloat,_ values:[String], _ selectedIntex:Int,delegate:DropDownForTableViewCellDelegate?,tag:Int,cell:Int,selectedIndex:Int = -2,stairColour:Results<rf_stairColour_results>? = nil, floorColor:Results<rf_floorColour_results>? = nil,isColour:Bool = false)
    {
        let dropDown = DropDown()
        let appearance = DropDown.appearance()
        appearance.cellHeight = 50
        dropDown.anchorView =  view
        dropDown.dismissMode = .onTap
        dropDown.width = width + 15
        dropDown.dataSource = values
        var stairArray = stairColour
        var floorArray = floorColor
        let officeLocationId = AppDelegate.appoinmentslData.officeLocationId
       // var selectedArray = (stairColour != nil ? stairColour : floorColor)
        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? MyCell else { return }
            
            
            if isColour
            {
                if selectedIndex >= 0 || selectedIndex == -1
                {
                    if selectedIndex == index
                    {
                        cell.optionLabel.textColor = UIColor().colorFromHexString("#2A8BF6")
                    }
                    else if stairArray != nil
                    {
                        var InOfficeLocation = false
                        for officeids in stairArray![index].Office_location_ids
                        {
                            if officeids == officeLocationId
                            {
                                InOfficeLocation = true
                            }
                        }
                        if (stairArray![index].specialOrder == 0  && InOfficeLocation == false && stairArray![index].in_stock == 0)
                        {
                            cell.optionLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
                            
                        }
                        if (stairArray![index].specialOrder == 0  && InOfficeLocation == true && stairArray![index].in_stock == 1)
                        {
                            cell.optionLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
                        }
                        else//if  stairArray![index].specialOrder == 1
                        {
                            cell.optionLabel.textColor = UIColor.black
                            
                        }
                    }
                    else if floorArray != nil
                    {
                        var InOfficeLocation = false
                        for officeids in floorArray![index].Office_location_ids
                        {
                            if officeids == officeLocationId
                            {
                                InOfficeLocation = true
                            }
                        }
                        if (floorArray![index].specialOrder == 0 && InOfficeLocation == false && floorArray![index].in_stock == 0)
                        {
                            cell.optionLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
                        }
                        if (floorArray![index].specialOrder == 0 && InOfficeLocation == true && floorArray![index].in_stock == 1)
                        {
                            cell.optionLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
                        }
                        else
                        {
                            cell.optionLabel.textColor = UIColor.black
                        }
                    }
                    else
                    {
                        cell.optionLabel.textColor = UIColor.black
                    }
                }
                else
                {
                    if selectedIntex == index || selectedIntex == -2
                    {
                        
                        cell.optionLabel.textColor = UIColor.black
                    }else{
                        
                        cell.optionLabel.textColor = UIColor.gray
                    }
                }
            }
            else
            {
                if selectedIntex == index || selectedIntex == -1
                {
                    
                    cell.optionLabel.textColor = UIColor.black
                }else{
                    
                    cell.optionLabel.textColor = UIColor.gray
                }
            }
            
        }
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            delegate?.DropDownDidSelectedAction(index: index, item: item, tag: tag, cell: cell)
        }
        
        
        
        
    }
    @objc func nextAction()
    {
        
    }
    
    @objc func refreshAction()
    {
        
    }
    
    
    func setNavigationBarbacklogoAndNext(name:String)
    {
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 600, height: 45))
        nameLabel.text = name.uppercased()
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 35)
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 45))
        subView.backgroundColor = .clear
        subView.addSubview(nameLabel)
        let barName = UIBarButtonItem(customView: subView)
        let btnback = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        let barBtnback = UIBarButtonItem(customView: btnback)
        
        let btnnext = UIButton(frame: CGRect(x: 0, y: 0, width: 190, height: 45))
        
        // let mySelectedAttributedTitle = NSAttributedString(string: "Next", attributes: [NSAttributedString.Key.font : UIFont.init(name: "Avenir-Heavy", size: 25)!])
        btnnext.setTitle("Next", for: .normal)
        btnnext.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 25)!
        btnnext.setTitleColor(.white, for: .normal)
        btnnext.backgroundColor = UIColor.redColor
        btnnext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        let barBtnnext = UIBarButtonItem(customView: btnnext)
        //           let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 45))
        //           image.image = UIImage(named: "tabLogo")
        
        //self.navigationItem.titleView = image
        self.navigationItem.leftBarButtonItems = [barBtnback,barName]
        self.navigationItem.rightBarButtonItem = barBtnnext
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.additionalSafeAreaInsets.top = 20
        
    }
    func setNavigationBarbacklogoResetAndNext(name:String)
    {
        
        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let btnback = UIButton(frame: CGRect(x: 45, y: 40, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        let barBtnback = UIBarButtonItem(customView: btnback)
        navView.addSubview(btnback)
        
        let nameLabel = UILabel(frame: CGRect(x: 110, y: 40, width: 600, height: 45))
        nameLabel.text = name.uppercased()
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 30)
        navView.addSubview(nameLabel)
        
        let btnnext = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 200, y: 40, width: 165, height: 54))
        btnnext.setTitle("Next", for: .normal)
        btnnext.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 25)!
        btnnext.setTitleColor(.white, for: .normal)
        btnnext.backgroundColor = UIColor().colorFromHexString("#292562")
        btnnext.borderColor = UIColor().colorFromHexString("#A7B0BA")
        btnnext.borderWidth = 1
        btnnext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        navView.addSubview(btnnext)
        
        
        let btnclear = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 380, y: 40, width: 165, height: 54))
        btnclear.setTitle("Clear All", for: .normal)
        btnclear.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 25)!
        btnclear.setTitleColor(.white, for: .normal)
        btnclear.backgroundColor = UIColor().colorFromHexString("#586471")
        btnclear.addTarget(self, action: #selector(resetButtonAction), for: .touchUpInside)
        navView.addSubview(btnclear)
        
        let takeScreenShot = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 460, y: 40, width: 52, height: 52))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        navView.addSubview(takeScreenShot)
        
    }
    @objc func resetButtonAction()
    {
        
    }
    
    @objc func doregenerateBack()
    {
        
    }
    
    func downloadImage(from url: URL,companylogoString:String) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
            
                if let image = UIImage(data: data){
//                    let imageData:NSData = image.jpegData(compressionQuality: 0.5)! as NSData
//                  if  let imageCompression = UIImage(data: imageData as Data)
//                    {
//                if let imageData = NSData(base64Encoded: companylogoString, options: [])
//                {
//                    let image = UIImage(data: imageData as Data)
                    self?.saveImage(imageName: "logoImage.png", image: image)
                 // }
                }
            else{
                    if let data = try? Data.init(contentsOf: url){
                        let pdfData = data as CFData
                        let provider:CGDataProvider = CGDataProvider(data: pdfData)!
                        let pdfDoc:CGPDFDocument = CGPDFDocument(provider)!
                        let pdfPage:CGPDFPage = pdfDoc.page(at: 1)!
                        var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
                        pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
                        print("\(pageRect.width) by \(pageRect.height)")
                        UIGraphicsBeginImageContext(pageRect.size)
                        let context:CGContext = UIGraphicsGetCurrentContext()!
                        context.saveGState()
                        context.translateBy(x: 0.0, y: pageRect.size.height)
                        context.scaleBy(x: 1.0, y: -1.0)
                        context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
                        context.drawPDFPage(pdfPage)
                        context.restoreGState()
                        let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                        UIGraphicsEndImageContext()
                        self?.saveImage(imageName: "logoImage.png", image: pdfImage)
                    }
                    
                }
            }
        }
    }
    
    func savePdf(urlString:String) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            
        }
    }
    
    
    func downloadDiscountSuccessPopupImage(from url: URL, code: String) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                if let image = UIImage(data: data){
                    _ = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: image, saveImgName: code)
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func setNavigationBarbacklogoAndSubmit()
    {
        let btnback = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(doregenerateBack), for: .touchUpInside)
        btnback.isUserInteractionEnabled = true
        let btnnext = UIButton(frame: CGRect(x: 0, y: 5, width: 190, height: 45))
        
        // let mySelectedAttributedTitle = NSAttributedString(string: "Next", attributes: [NSAttributedString.Key.font : UIFont.init(name: "Avenir-Heavy", size: 25)!])
        btnnext.setTitle("  Process Down Payment  ", for: .normal)
        btnnext.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 22)!
        btnnext.setTitleColor(.white, for: .normal)
        //  btnnext.layer.cornerRadius = 0.1 * btnnext.bounds.size.width
        btnnext.backgroundColor = UIColor.redColor
        // btnnext.backgroundColor = UIColor(hex: "#A74646")
        btnnext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        btnnext.isUserInteractionEnabled = true
        let barBtnback = UIBarButtonItem(customView: btnback)
        let barBtnnext = UIBarButtonItem(customView: btnnext)
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 45))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 128).isActive = true
        image.heightAnchor.constraint(equalToConstant: 45).isActive = true
        if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
            image.image = savedLogoImage
        }else{
            image.image = UIImage(named: "tabLogo")
        }
        
        let orderstatus = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
        orderstatus.isUserInteractionEnabled = true
        let barorderstatus = UIBarButtonItem(customView: orderstatus)
        
        
        self.navigationItem.titleView = image
        self.navigationItem.leftBarButtonItem = barBtnback
        //  self.navigationItem.rightBarButtonItem = barBtnnext
        
        let takeScreenShot = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        let ScreenShotBtn = UIBarButtonItem(customView: takeScreenShot)
        
        self.navigationItem.rightBarButtonItems = [ScreenShotBtn,barorderstatus,barBtnnext]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.additionalSafeAreaInsets.top = 20
        
    }
    
    
    func setNavigationBarbacklogoAndDone()
    {
//        let btnback = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
//        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
//        btnback.addTarget(self, action: #selector(doregenerateBack), for: .touchUpInside)
//        btnback.isUserInteractionEnabled = true
//        let btnnext = UIButton(frame: CGRect(x: 0, y: 0, width: 190, height: 45))
//
//        // let mySelectedAttributedTitle = NSAttributedString(string: "Next", attributes: [NSAttributedString.Key.font : UIFont.init(name: "Avenir-Heavy", size: 25)!])
//        btnnext.setTitle("Save", for: .normal)
//        btnnext.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 25)!
//        btnnext.setTitleColor(.white, for: .normal)
//        btnnext.backgroundColor = UIColor.redColor
//        btnnext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
//        btnnext.isUserInteractionEnabled = true
//        let barBtnback = UIBarButtonItem(customView: btnback)
//        let barBtnnext = UIBarButtonItem(customView: btnnext)
//        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 45))
//        image.contentMode = .scaleAspectFit
//        image.translatesAutoresizingMaskIntoConstraints = false
//        image.widthAnchor.constraint(equalToConstant: 128).isActive = true
//        image.heightAnchor.constraint(equalToConstant: 45).isActive = true
//        if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
//            image.image = savedLogoImage
//        }else{
//            image.image = UIImage(named: "tabLogo")
//        }
//
//        let orderstatus = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
//        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
//        orderstatus.isUserInteractionEnabled = true
//        let barorderstatus = UIBarButtonItem(customView: orderstatus)
//
//        let takeScreenShot = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
//        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
//        let ScreenShotBtn = UIBarButtonItem(customView: takeScreenShot)
//
//        self.navigationItem.titleView = image
//        self.navigationItem.leftBarButtonItem = barBtnback
//        self.navigationItem.rightBarButtonItems = [ScreenShotBtn,barorderstatus,barBtnnext]
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
//        self.setStatusBarBackgroundColor(color: UIColor.clear)
//        navigationController?.navigationBar.barTintColor = UIColor.clear
//        self.navigationController?.additionalSafeAreaInsets.top = 20
        
        
        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        
        let btnback = UIButton(frame: CGRect(x: 45, y: 40, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(doregenerateBack), for: .touchUpInside)
        navView.addSubview(btnback)
        
        let takeScreenShot = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 110, y: 40, width: 45, height: 45))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        navView.addSubview(takeScreenShot)
        
        
        let orderstatus = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 170, y: 40, width: 45, height: 45))
        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
        navView.addSubview(orderstatus)
        
        let btnnext = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 380, y: 40, width: 190, height: 45))
        btnnext.setTitle("Save", for: .normal)
        btnnext.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 25)!
        btnnext.setTitleColor(.white, for: .normal)
        btnnext.backgroundColor = UIColor().colorFromHexString("#292562")
        btnnext.borderWidth = 1
        btnnext.borderColor = UIColor().colorFromHexString("#A7B0BA")
        btnnext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        navView.addSubview(btnnext)
        
        let image = UIImageView(frame: CGRect(x:  UIScreen.main.bounds.width - 560, y: 40, width: 128, height: 45))
        image.contentMode = .scaleAspectFit
        if BASE_URL == "https://odoostage.myx.ac/api/"
        {
            image.image = UIImage(named: "RefloorStage")
            //viewLogButton.setBackgroundImage(UIImage(named: "RefloorStage"), for: .normal)
        }
        else
        {
            if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
                image.image = savedLogoImage
            }else{
                image.image = UIImage(named: "tabLogo")
            }
        }
        navView.addSubview(image)
    }
    
    
    
    func setNavigationBarbacklogoAndSubmitDisable()
    {
        let btnback = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        // btnback.addTarget(self, action: #selector(doregenerateBack), for: .touchUpInside)
        btnback.isUserInteractionEnabled = false
        
        let btnnext = UIButton(frame: CGRect(x: 0, y: 5, width: 190, height: 45))
        
        // let mySelectedAttributedTitle = NSAttributedString(string: "Next", attributes: [NSAttributedString.Key.font : UIFont.init(name: "Avenir-Heavy", size: 25)!])
        btnnext.setTitle("  Process Down Payment  ", for: .normal)
        btnnext.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 22)!
        btnnext.setTitleColor(.white, for: .normal)
        //  btnnext.layer.cornerRadius = 0.1 * btnnext.bounds.size.width
        btnnext.backgroundColor = UIColor.redColor
        // btnnext.backgroundColor = UIColor(hex: "#A74646")
        //btnnext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        let barBtnback = UIBarButtonItem(customView: btnback)
        let barBtnnext = UIBarButtonItem(customView: btnnext)
        btnnext.isUserInteractionEnabled = false
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 45))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 128).isActive = true
        image.heightAnchor.constraint(equalToConstant: 45).isActive = true
        if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
            image.image = savedLogoImage
        }else{
            image.image = UIImage(named: "tabLogo")
        }
        
        let orderstatus = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
        orderstatus.isUserInteractionEnabled = false
        let barorderstatus = UIBarButtonItem(customView: orderstatus)
        
        let takeScreenShot = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        let ScreenShotBtn = UIBarButtonItem(customView: takeScreenShot)
        
        self.navigationItem.titleView = image
        self.navigationItem.leftBarButtonItem = barBtnback
        //  self.navigationItem.rightBarButtonItem = barBtnnext
        self.navigationItem.rightBarButtonItems = [ScreenShotBtn,barorderstatus,barBtnnext]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.additionalSafeAreaInsets.top = 20
        
    }
    
    
    func setNavigationBarbacklogoAndDoneDisable()
    {
        let btnback = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        //   btnback.addTarget(self, action: #selector(doregenerateBack), for: .touchUpInside)
        btnback.isUserInteractionEnabled = false
        let btnnext = UIButton(frame: CGRect(x: 0, y: 0, width: 190, height: 45))
        
        // let mySelectedAttributedTitle = NSAttributedString(string: "Next", attributes: [NSAttributedString.Key.font : UIFont.init(name: "Avenir-Heavy", size: 25)!])
        btnnext.setTitle("Done", for: .normal)
        btnnext.titleLabel?.font = UIFont.init(name: "Avenir-Heavy", size: 25)!
        btnnext.setTitleColor(.white, for: .normal)
        btnnext.backgroundColor = UIColor.redColor
        // btnnext.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        btnnext.isUserInteractionEnabled = false
        let barBtnback = UIBarButtonItem(customView: btnback)
        let barBtnnext = UIBarButtonItem(customView: btnnext)
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 45))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 128).isActive = true
        image.heightAnchor.constraint(equalToConstant: 45).isActive = true
        if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
            image.image = savedLogoImage
        }else{
            image.image = UIImage(named: "tabLogo")
        }
        
        let orderstatus = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
        orderstatus.isUserInteractionEnabled = false
        let barorderstatus = UIBarButtonItem(customView: orderstatus)
        
        let takeScreenShot = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        let ScreenShotBtn = UIBarButtonItem(customView: takeScreenShot)
        
        self.navigationItem.titleView = image
        self.navigationItem.leftBarButtonItem = barBtnback
        self.navigationItem.rightBarButtonItems = [ScreenShotBtn,barorderstatus,barBtnnext]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.additionalSafeAreaInsets.top = 20
        
    }
    
    
    func setNavigationBarbackAndlogo2(with name:String)
    {

        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let btnback = UIButton(frame: CGRect(x: 45, y: 40, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        navView.addSubview(btnback)
        
        let nameLabel = UILabel(frame: CGRect(x: 110, y: 40, width: 600, height: 45))
        nameLabel.text = name.uppercased()
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 35)
        navView.addSubview(nameLabel)
        
        let image = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 200, y: 40, width: 128, height: 48))
        image.contentMode = .scaleAspectFit
        if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
            image.image = savedLogoImage
        }else{
            image.image = UIImage(named: "tabLogo")
        }
        navView.addSubview(image)
    }
   func schedulerSuccessNavBar()
    {
        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let logo = UIImageView()
        if BASE_URL == "https://odoostage.myx.ac/api/"
        {
            logo.image = UIImage(named: "RefloorStage")
            //viewLogButton.setBackgroundImage(UIImage(named: "RefloorStage"), for: .normal)
        }
        else
        {
            logo.image = UIImage(named: "refloorLogo")
        }
        navView.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.widthAnchor.constraint(equalToConstant: 126).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 48).isActive = true
        logo.centerXAnchor.constraint(equalTo: navView.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: navView.centerYAnchor).isActive = true
        
        //logo.backgroundColor = .green
        
    }
    
    
    func shedulerInstallerNavBar(with name:String,submitText:String)
    {
        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let nameLabel = UILabel(frame: CGRect(x: 70, y: 40, width: 600, height: 45))
        nameLabel.text = name.uppercased()
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 35)
        navView.addSubview(nameLabel)
        
        let submitbutn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 230, y: 40, width: 165, height: 54))
        submitbutn.addTarget(self, action: #selector(insallerSubmitBtnAction(sender: )), for: .touchUpInside)
        submitbutn.backgroundColor = UIColor().colorFromHexString("#292562")
        submitbutn.borderColor = UIColor().colorFromHexString("#A7B0BA")
        submitbutn.borderWidth = 1
        submitbutn.setTitle(submitText, for: .normal)
        submitbutn.setTitleColor(UIColor().colorFromHexString("#FFFFFF"), for: .normal)
        submitbutn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24)
        navView.addSubview(submitbutn)
        
        let skipbutn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 405, y: 40, width: 165, height: 54))
        skipbutn.addTarget(self, action: #selector(insallerSkipBtnAction(sender: )), for: .touchUpInside)
        skipbutn.backgroundColor = UIColor().colorFromHexString("#A7B0BA")
        skipbutn.setTitle("Skip", for: .normal)
        skipbutn.setTitleColor(UIColor().colorFromHexString("#2D343D"), for: .normal)
        skipbutn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24)
        navView.addSubview(skipbutn)
    }
    
    @objc func insallerSubmitBtnAction(sender:UIButton)
    {
        
    }
    @objc func insallerSkipBtnAction(sender:UIButton)
    {
        
    }
    
    
    
    
    func setNavigationBarbackAndlogo(with name:String)
    {
        
        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let btnback = UIButton(frame: CGRect(x: 45, y: 40, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        navView.addSubview(btnback)
        
        let nameLabel = UILabel(frame: CGRect(x: 110, y: 40, width: 600, height: 45))
        nameLabel.text = name.uppercased()
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 35)
        navView.addSubview(nameLabel)
        
        
        let image = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 310, y: 40, width: 126, height: 48))
        image.contentMode = .scaleAspectFit
        if BASE_URL == "https://odoostage.myx.ac/api/"
        {
            image.image = UIImage(named: "RefloorStage")
            //viewLogButton.setBackgroundImage(UIImage(named: "RefloorStage"), for: .normal)
        }
        else
        {
            if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
                image.image = savedLogoImage
            }else{
                image.image = UIImage(named: "tabLogo")
            }
        }
        navView.addSubview(image)
        
        let orderstatus = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 162, y: 40, width: 52, height: 52))
        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
        navView.addSubview(orderstatus)
        
        let takeScreenShot = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 95, y: 40, width: 52, height: 52))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        navView.addSubview(takeScreenShot)
        
    }
    func setNavigationPackageBarbackAndlogo(with name:String)
    {
        
        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let btnback = UIButton(frame: CGRect(x: 25, y: 40, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        navView.addSubview(btnback)
        
        let nameLabel = UILabel(frame: CGRect(x: 95, y: 40, width: 600, height: 45))
        nameLabel.text = name.uppercased()
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 35)
        navView.addSubview(nameLabel)
        
        
        let image = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 295, y: 40, width: 126, height: 48))
        image.contentMode = .scaleAspectFit
        if BASE_URL == "https://odoostage.myx.ac/api/"
        {
            image.image = UIImage(named: "RefloorStage")
            //viewLogButton.setBackgroundImage(UIImage(named: "RefloorStage"), for: .normal)
        }
        else
        {
            if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
                image.image = savedLogoImage
            }else{
                image.image = UIImage(named: "tabLogo")
            }
        }
        navView.addSubview(image)
        
        let orderstatus = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 142, y: 40, width: 52, height: 52))
        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
        navView.addSubview(orderstatus)
        
        let takeScreenShot = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 75, y: 40, width: 52, height: 52))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        navView.addSubview(takeScreenShot)
        
    }
    
    func setNavigationBarbaclogoAndStatus(with name:String)
    {
        
        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let btnback = UIButton(frame: CGRect(x: 65, y: 40, width: 45, height: 45))
        btnback.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        navView.addSubview(btnback)
        
        let nameLabel = UILabel(frame: CGRect(x: 130, y: 40, width: 600, height: 45))
        nameLabel.text = name.uppercased()
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 35)
        navView.addSubview(nameLabel)
        
        
        let image = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 415, y: 40, width: 126, height: 48))
        image.contentMode = .scaleAspectFit
        if BASE_URL == "https://odoostage.myx.ac/api/"
        {
            image.image = UIImage(named: "RefloorStage")
            //viewLogButton.setBackgroundImage(UIImage(named: "RefloorStage"), for: .normal)
        }
        else
        {
            if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
                image.image = savedLogoImage
            }else{
                image.image = UIImage(named: "tabLogo")
            }
        }
        navView.addSubview(image)
        
        let orderstatus = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 245, y: 40, width: 52, height: 52))
        orderstatus.setBackgroundImage(UIImage(named: "status_close"), for: .normal)
        orderstatus.addTarget(self, action: #selector(OrderstatusBarButtonAction), for: .touchUpInside)
        navView.addSubview(orderstatus)
        
        let statusback = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 177, y: 40, width: 52, height: 52))
        statusback.setBackgroundImage(UIImage(named: "statusIcon"), for: .normal)
        statusback.addTarget(self, action: #selector(statusBarButtonAction), for: .touchUpInside)
        navView.addSubview(statusback)
        
        let takeScreenShot = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 110, y: 40, width: 52, height: 52))
        takeScreenShot.setBackgroundImage(UIImage(named: "screenshot"), for: .normal)
        takeScreenShot.addTarget(self, action: #selector(screenShotBarButtonAction(sender:)), for: .touchUpInside)
        navView.addSubview(takeScreenShot)
    }
    @objc func OrderstatusBarButtonAction()
    {
        //        if AppDelegate.appoinmentslData.id != nil
        //        {
        let order  = OrderStatusViewController.initialization()!
        order.delegate = self
        let currentClassName = String(describing: type(of: self))
        order.appointmentResults = self.getAppointmentResultToShow(className: currentClassName, isNextBtn: false)
        self.present(order, animated: true, completion: nil)
        //}
        //        else
        //        {
        //            self.alert("No record available", nil)
        //        }
    }
    @objc func screenShotBarButtonAction(sender:UIButton)
    {
        
    }
    
    
    // open func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
    /*  var screenshotImage :UIImage?
     let layer = UIApplication.shared.keyWindow!.layer
     let scale = UIScreen.main.scale
     UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
     if let context = UIGraphicsGetCurrentContext() {
     layer.render(in: context)
     screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     if let tempimage = screenshotImage {
     let imageName = Date().toString()
     
     //  self.imageUploadScreenShot(tempimage,"Screenshot_\(imageName)")
     //  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
     }
     }*/
    
    //}
    
    
    //MARK:- OrderstatusDelegate
    func OrderStatusViewDelegateResult() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    @objc func statusBarButtonAction()
    {
        if(AppDelegate.appoinmentslData.is_room_measurement_exist ?? false)
        {
            let summeryList = SummeryListViewController.initialization()!
            summeryList.appoinmentID = AppDelegate.appoinmentslData.id ?? 0
            summeryList.isFromStatus = true
            self.navigationController?.pushViewController(summeryList, animated: true)
        }
        else
        {
            self.alert("No record available", nil)
        }
        
    }
//     func logOutbuttAction()
//    {
//        if self.determineIfAnyPendingAppointmentsToSink(){
//            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            self.alert("There are pending appointments to be synced. Please wait till the syncing process is completed in order to logout from Refloor app. ", [ok])
//        }else{
//            //call logout api
//            if HttpClientManager.SharedHM.connectedToNetwork(){
//                let yes = UIAlertAction(title: "Yes", style:.default) { (_) in
//                    let params:[String:Any] = ["token":UserData.init().token ?? ""]
//                    HttpClientManager.SharedHM.logoutApi(parameter: params) { result, message in
//                        DispatchQueue.main.async{
//                            if (result ?? "") == "Success"
//                            {
//                                UserData.setLogedInVal(false)
//                                self.navigationController?.pushViewController(LoginViewController.initialization()!, animated: true)
//                                
//                            }else{
//                                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//                                    self.logOutbuttAction()
//                                }
//                                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                                
//                                self.alert(message ?? AppAlertMsg.NetWorkAlertMessage, [yes,no])
//                            }
//                        }
//                    }
//                }
//                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
//                self.alert("Are you sure you want to logout?", [yes,no])
//            }else{
//                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//                    self.logOutbuttAction()
//                }
//                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                
//                self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
//            }
//        }
//    }
    
    @objc func logOutbuttonAction(sender:UIButton)
    {
        if self.determineIfAnyPendingAppointmentsToSink(){
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            self.alert("There are pending appointments to be synced. Please wait till the syncing process is completed in order to logout from Refloor app. ", [ok])
        }else{
            //call logout api
            if HttpClientManager.SharedHM.connectedToNetwork(){
                let yes = UIAlertAction(title: "Yes", style:.default) { (_) in
                    let params:[String:Any] = ["token":UserData.init().token ?? ""]
                    HttpClientManager.SharedHM.logoutApi(parameter: params) { result, message in
                        DispatchQueue.main.async{
                            if (result ?? "") == "Success"
                            {
                                UserData.setLogedInVal(false)
                                //UserDefaults.standard.set(false, forKey: "isAutoLogout")
                                BASE_URL = ""
                                UserDefaults.standard.set(BASE_URL, forKey: "BASE_URL")
                                //self.deleteAllAppointments()
                                self.navigationController?.pushViewController(LoginViewController.initialization()!, animated: true)
                                
                            }
                            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
                            {
                                
                                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                                    
                                    self.fourceLogOutbuttonAction()
                                }
                                
                                self.alert((message) ?? AppAlertMsg.serverNotReached, [yes])
                                
                            }
                            else{
                                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                                    self.logOutbuttonAction(sender: sender)
                                }
                                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                
                                self.alert(message ?? AppAlertMsg.NetWorkAlertMessage, [yes,no])
                            }
                        }
                    }
                }
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                self.alert("Are you sure you want to logout?", [yes,no])
            }else{
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    self.logOutbuttonAction(sender: sender)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
            }
        }
    }
    
    @objc func viewLogbuttonAction(sender:UIButton){
        print("go to view log page")
        self.navigationController?.pushViewController(ViewLogListViewController.initialization()!, animated: true)
        //        if self.getAppointmentLogsFromDB().count > 0{
        //            self.navigationController?.pushViewController(ViewLogListViewController.initialization()!, animated: true)
        //        }else{
        //            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        //            self.alert(("Currently log details are not available."), [ok])
        //        }
    }
   
    
    @objc func fourceLogOutbuttonAction()
    {
        UserData.setLogedInVal(false)
        //    UserData.setLogedInVal(false)
        //        let isoDate = "1970-04-14T10:44:00+0000"
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        //        let date = dateFormatter.date(from:isoDate)!
        //        UserData.setLogedInDate(loginDate:date as NSDate)
        self.navigationController?.pushViewController(LoginViewController.initialization()!, animated: true)
        
        
    }
    func setNavigationBarWithNameAndBackBtn(with name:String)
    {
        let btnback = UIButton()
        btnback.setBackgroundImage(UIImage(), for: .normal)
        
        let barBtnback = UIBarButtonItem(customView: btnback)
        
        
        let nameLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 400, height: 45))
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 35)
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 460, height: 45))
        subView.backgroundColor = .clear
        subView.addSubview(nameLabel)
        
        let barName = UIBarButtonItem(customView: subView)
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 128, height: 45))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 128).isActive = true
        image.heightAnchor.constraint(equalToConstant: 45).isActive = true
        if let savedLogoImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
            image.image = savedLogoImage
        }else{
            image.image = UIImage(named: "tabLogo")
        }
        let barLogo = UIBarButtonItem(customView: image)
        self.navigationItem.titleView = image
        self.navigationItem.leftBarButtonItems = [barBtnback ,barName]
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.additionalSafeAreaInsets.top = 20
    }
    
    
    
    func setNavigationBarLogoAndLogout(with name:String)
    {

        var navView = UIView()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  110))
        navView.layer.masksToBounds = false
        navView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        self.view.addSubview(navView)
        
        let nameLabel = UILabel(frame: CGRect(x: 70, y: 40, width: 400, height: 45))
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.minimumScaleFactor = 0.2
        nameLabel.font = UIFont(name: "Avenir-Black", size: 34)
        navView.addSubview(nameLabel)
        
        let logoutbutn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 120, y: 40, width: 52, height: 52))
        logoutbutn.setBackgroundImage(UIImage(named: "logout"), for: .normal)
        logoutbutn.addTarget(self, action: #selector(logOutbuttonAction(sender: )), for: .touchUpInside)
        navView.addSubview(logoutbutn)
        
        let refreshtbutn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 187, y: 40, width: 52, height: 52))
        refreshtbutn.setBackgroundImage(UIImage(named: "refreshBtn"), for: .normal)
        refreshtbutn.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
        navView.addSubview(refreshtbutn)
        
        let viewLogButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 254, y: 40, width: 52, height: 52))
       
            viewLogButton.setBackgroundImage(UIImage(named: "viewLog"), for: .normal)
        viewLogButton.addTarget(self, action: #selector(viewLogbuttonAction), for: .touchUpInside)
        navView.addSubview(viewLogButton)
        
        let image = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - 407, y: 40, width: 128, height: 48))
        image.contentMode = .scaleAspectFit
        //image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = UIColor.clear
        if BASE_URL == "https://odoostage.myx.ac/api/"
        {
            image.image = UIImage(named: "RefloorStage")
            //viewLogButton.setBackgroundImage(UIImage(named: "RefloorStage"), for: .normal)
        }
        else
        {
            if let savedLogoImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"logoImage"){
                //            image.image = image.image?.withRenderingMode(.alwaysTemplate)
                //image.tintColor = UIColor().colorFromHexString("#2D343D")
                image.image = savedLogoImage
                image.contentMode = .scaleAspectFit
            }else{
                image.image = UIImage(named: "tabLogo")
            }
        }
        
        navView.addSubview(image)
        
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
        //           guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        //
        //           statusBar.backgroundColor = color
    }
    func setClearNavigationBar(){
        //removeBackButton
        let btnback = UIButton()
        btnback.setBackgroundImage(UIImage(), for: .normal)
        
        let barBtnback = UIBarButtonItem(customView: btnback)
        self.navigationItem.leftBarButtonItem = barBtnback
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.additionalSafeAreaInsets.top = 20
        
    }
    func setClearNavigationBarWithBlueBack()
    {
        
        //Back Button
        let btnback = UIButton(frame: CGRect(x: 0, y: 20, width: 24, height: 24))
        btnback.setBackgroundImage(UIImage(named: "BlueBack"), for: .normal)
        
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        
        
        let barBtnback = UIBarButtonItem(customView: btnback)
        self.navigationItem.leftBarButtonItem = barBtnback
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    func setClearNavigationBarWithBack(){
        
        
        
        //Back Button
        let btnback = UIButton(frame: CGRect(x: 0, y: 20, width: 24, height: 24))
        btnback.setBackgroundImage(UIImage(named: "clearBackButton"), for: .normal)
        
        btnback.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        
        
        let barBtnback = UIBarButtonItem(customView: btnback)
        self.navigationItem.leftBarButtonItem = barBtnback
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.setStatusBarBackgroundColor(color: UIColor.clear)
        navigationController?.navigationBar.barTintColor = UIColor.clear
        
    }
    
    func setNavigationBarbackAndNotfication(name:String) {
        
        //Name Label
        
        let attribute = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font:UIFont(name:"SFProDisplay-Medium", size: 21)!]
        
        //Notification Button
        let btnNotify = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        btnNotify.setBackgroundImage(UIImage(named: "bell-notify"), for: .normal)
        
        
        
        
        let notfiy = UIBarButtonItem(customView: btnNotify)
        
        
        self.navigationItem.rightBarButtonItems = [notfiy]
        self.navigationController?.navigationBar.titleTextAttributes = attribute
        //navigation title
        self.navigationItem.title = name
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.AppColor
        self.setStatusBarBackgroundColor(color: UIColor.AppColor)
        navigationController?.navigationBar.barTintColor = UIColor.white
        
    }
    
    
    
    
    func setNavigationBarCustomBackName(name:String) {
        
        //Name Label
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.AppColor, NSAttributedString.Key.font:UIFont(name:"SFProDisplay-Medium", size: 21)!]
        //navigation title
        var size:CGFloat = 20
        var color = UIColor.black
        
        self.navigationItem.title = name
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: (size == 20) ? 24:28))
        nameLabel.autoresizingMask = .flexibleWidth
        nameLabel.adjustsFontSizeToFitWidth = true
        let attribute = [NSAttributedString.Key.foregroundColor:color, NSAttributedString.Key.font:UIFont(name:"SFProDisplay-Medium", size: size)!]
        nameLabel.attributedText = NSAttributedString(string: name, attributes: attribute)
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        backButton.setBackgroundImage(UIImage(named: "BlueBack"), for: .normal)
        backButton.addTarget(self, action: #selector(performSegueToReturnBack), for: .touchUpInside)
        
        
        let name = UIBarButtonItem(customView: nameLabel)
        let back = UIBarButtonItem(customView: backButton)
        
        
        self.navigationItem.leftBarButtonItems = [back,name]
        
        
        //navigation title
        
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.AppColor
        self.setStatusBarBackgroundColor(color: UIColor.AppColor)
        navigationController?.navigationBar.barTintColor = UIColor.white
        
    }
    
    
    
    
    
    func setNavigationBarNameAndShareButton(name:String) {
        
        //Name Label
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.AppColor, NSAttributedString.Key.font:UIFont(name:"SFProDisplay-Medium", size: 21)!]
        //navigation title
        self.navigationItem.title = name
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 24))
        let attribute = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font:UIFont(name:"SFProDisplay-Medium", size: 21)!]
        nameLabel.attributedText = NSAttributedString(string: name, attributes: attribute)
        //Notification Button
        let btnshare = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        btnshare.setBackgroundImage(UIImage(named: "menu"), for: .normal)
        btnshare.addTarget(self, action: #selector(shareButtontaped), for: .touchUpInside)
        
        let name = UIBarButtonItem(customView: nameLabel)
        
        let share = UIBarButtonItem(customView: btnshare)
        
        self.navigationItem.leftBarButtonItem = name
        self.navigationItem.rightBarButtonItems = [share]
        
        //navigation title
        
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.AppColor
        self.setStatusBarBackgroundColor(color: UIColor.AppColor)
        navigationController?.navigationBar.barTintColor = UIColor.white
        
    }
    @objc func shareButtontaped()
    {
        
    }
    func setNavigationBarWithNameOnly(name: String)
    {
        //Name Label
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.AppColor, NSAttributedString.Key.font:UIFont(name:"SFProDisplay-Medium", size: 23)!]
        //navigation title
        self.navigationItem.title = name
        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 28))
        let attribute = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font:UIFont(name:"SFProDisplay-Medium", size: 21)!]
        nameLabel.attributedText = NSAttributedString(string: name, attributes: attribute)
        
        
        
        
        let name = UIBarButtonItem(customView: nameLabel)
        
        
        self.navigationItem.leftBarButtonItem = name
        
        
        //navigation title
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.AppColor
        self.setStatusBarBackgroundColor(color: UIColor.AppColor)
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    @objc func performSegueToReturnBack()  {
        
       
        if let nav = self.navigationController {
//            let currentClassName = String(describing: type(of: self))
//            let appointmentId = AppointmentData().appointment_id ?? 0
//            let realm = try! Realm()
//            let completionTimesArr = realm.objects(ScreenCompletion.self).filter("appointment_id == %d AND className == %@", appointmentId, currentClassName)
//          //  if let completionTime = completionTimesArr.first{
//                try! realm.write {
//                    realm.delete(completionTimesArr)
//               // }
//            }
            nav.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func alert(_ message:String ,_ buttons:[UIAlertAction]?)
    {
        let alert = UIAlertController(title: AppDetails.APP_NAME, message: message, preferredStyle: .alert)
        if ((buttons ?? []).count == 0)
        {
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        else
        {
            for button in buttons!
            {
                alert.addAction(button)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //arb
    // Save image to file and saves its filename in DB
    public func saveImage(imageName: String, image: UIImage) {
        
        _ = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: image, saveImgName: imageName)
        do {
            //try data.write(to: fileURL)
            if imageName.contains("FloorColor")
            {
                let mystorage = FloorImageStorage()
                mystorage.imageName = imageName
                let realm = try! Realm()
                let images = realm.objects(FloorImageStorage.self).filter("imageName == %@", imageName)
                if images.isEmpty{
                    try realm.write{
                        realm.add(mystorage)
                    }
                    
                }
            }
            else
            {
                let mystorage = StairImageStorage()
                mystorage.imageName = imageName
                let realm = try! Realm()
                let images = realm.objects(StairImageStorage.self).filter("imageName == %@", imageName)
                if images.isEmpty{
                    try realm.write{
                        realm.add(mystorage)
                    }
                    
                }
            }
        } catch let error {
            print("error saving file with error", error)
        }
        
    }
    
    
    
    //Gets the image from file by specifying the name
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
            
        }
        
        return nil
    }
    //download photo and saves it in file and its filename in DB
    func downloadPhoto(imageUrlArray:[[String:String]], type: OfflineImageType){
            // var downloadstastus:Int = 0
            var downloadstatus:[String: Int] = ["percentage": 1]
            var progress:CGFloat! = 0
            //let totalCount = Double(imageUrlArray.filter({URL(string: $0.keys) != nil}).count)
            let totalCount = Double(imageUrlArray.count)
            print(totalCount)
            DispatchQueue.global().async {
                // progressImgArray.removeAll() // this is the image array
                let group = DispatchGroup()
                for i in 0..<imageUrlArray.count {
                    for (key,value) in imageUrlArray[i]
                    {
                    let type = i
                    guard let url = URL(string: key)
                    else {
                        continue
                    }
                    
                    print(url)
                    print("-------GROUP ENTER-------")
                    
                    group.enter()
                    
                    if HttpClientManager.SharedHM.connectedToNetwork(){
                        
                        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                            print(response?.suggestedFilename ?? url.lastPathComponent)
                            
                            if let imgData = data, let image = UIImage(data: imgData) {
                                let progressValue = modf(totalCount / 100)
                                let countProgress = (progressValue.0 * 100.0)
                                let progessPerDownload = CGFloat(countProgress/totalCount)
                                let progessPerDownloadRounded = progessPerDownload.rounded()
                                progress = progress + progessPerDownloadRounded
                                progress = progress <= 100 ? progress : 100
                                downloadstatus.updateValue(Int(progress ?? 0), forKey: "percentage")
                                
                                NotificationCenter.default.post(name: Notification.Name("MasterDataComplete"), object: nil, userInfo: downloadstatus)
                                
                                
                                self.saveImage(imageName: "\(value)"+"\(i)", image: image)
                                
                            } else if let error = error {
                                
                                print("Sync Error:\(error)")
                                
                                //                            downloadstatus.updateValue(1008, forKey: "percentage")
                                //                            NotificationCenter.default.post(name: Notification.Name("MasterDataComplete"), object: nil, userInfo: downloadstatus)
                                
                            }
                            group.leave()
                        }).resume()
                        
                    }
                    
                    else
                    {
                        downloadstatus.updateValue(1008, forKey: "percentage")
                        NotificationCenter.default.post(name: Notification.Name("MasterDataComplete"), object: nil, userInfo: downloadstatus)
                        
                    }
                    
                    group.wait()
                }
                    
                }
                group.notify(queue: .main) {
                    print("Goodbye")
                    
                    downloadstatus.updateValue(0, forKey: "percentage")
                    NotificationCenter.default.post(name: Notification.Name("MasterDataComplete"), object: nil, userInfo: downloadstatus)
                    
                }
            }
        }
    //payment option different types
    func getPaymentOptionAndValues(payment_method: String, paymentOptionDict:[String:Any]) -> PaymentOption {
        let paymentOption = PaymentOption()
        switch payment_method {
        case "cash":
            paymentOption.payment_method = "cash"
            paymentOption.card_number =  ""
            paymentOption.expiry_date =  ""
            paymentOption.card_name =  ""
            paymentOption.card_pinorcvv =  ""
            paymentOption.check_number =  ""
            paymentOption.check_routing_number =  ""
            paymentOption.check_account_number = ""
        case "credit_card":
            paymentOption.payment_method = "credit_card"
            paymentOption.card_number = paymentOptionDict["card_number"] as? String ?? ""
            paymentOption.expiry_date = paymentOptionDict["card_expiry"] as? String ?? ""
            paymentOption.card_name = paymentOptionDict["card_holder_name"] as? String ?? ""
            paymentOption.card_pinorcvv = paymentOptionDict["cardpin"] as? String ?? ""
            paymentOption.check_number =  ""
            paymentOption.check_routing_number =  ""
            paymentOption.check_account_number = ""
        case "debit_card":
            paymentOption.payment_method = "debit_card"
            paymentOption.card_number = paymentOptionDict["card_number"] as? String ?? ""
            paymentOption.expiry_date = paymentOptionDict["card_expiry"] as? String ?? ""
            paymentOption.card_name = paymentOptionDict["card_holder_name"] as? String ?? ""
            paymentOption.card_pinorcvv = paymentOptionDict["cardpin"] as? String ?? ""
            paymentOption.check_number =  ""
            paymentOption.check_routing_number =  ""
            paymentOption.check_account_number = ""
        case "check":
            paymentOption.payment_method = "check"
            paymentOption.card_number =  ""
            paymentOption.expiry_date =  ""
            paymentOption.card_name =  ""
            paymentOption.card_pinorcvv =  ""
            paymentOption.check_number = paymentOptionDict["check_number"] as? String ?? ""
            paymentOption.check_routing_number = paymentOptionDict["check_routing_number"] as? String ?? ""
            paymentOption.check_account_number = paymentOptionDict["check_account_number"] as? String ?? ""
        default:
            break
        }
        return paymentOption
    }
    
    func getRefreshedAppointmentsFromDB() -> [AppoinmentDataValue]{
        var appoinmentsList:[AppoinmentDataValue] = []
        do{
            let realm = try Realm()
            let appointments = realm.objects(rf_master_appointment.self)
            for appointment in appointments{
                appoinmentsList.append(AppoinmentDataValue(listOfAppointment:appointment))
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appoinmentsList
    }
    
    func deleteSyncCompletedAppointmentFromAppointmentDB(appointmentId:Int) {
        do{
            let realm = try Realm()
            let appointments = realm.objects(rf_master_appointment.self).filter("id == %d",appointmentId)
            if appointments.count == 1{
                try realm.write{
                    if let appointment = appointments.first{
                        realm.delete(appointment)
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    func deleteAnyAppointmentLogsTable(appointmentId:Int) {
        do{
            let realm = try Realm()
            let appointments = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d",appointmentId)
                try realm.write{
//                    for appointment in appointments
//                    {
                        realm.delete(appointments)
                   // }
//                    if let appointment = appointments.first{
                       
                    //}
                }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    func deleteCustomRoomName(appointmentId:Int,roomId:String)
    {
        do{
            let realm = try Realm()
            let appointments = realm.objects(rf_customRoomName.self).filter("appointment_id == %d AND roomId == %d",appointmentId , roomId)
                try realm.write{
//                    for appointment in appointments
//                    {
                        realm.delete(appointments)
                   // }
//                    if let appointment = appointments.first{
                       
                    //}
                }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    func deleteAllAppointments() {
        do{
            let realm = try Realm()
            let appointments = realm.objects(rf_completed_appointment.self)
                try realm.write{
//                    for appointment in appointments
//                    {
                        realm.delete(appointments)
                   // }
//                    if let appointment = appointments.first{
                       
                    //}
                }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    
    //delete single or all appointment logs
    func deleteAppointmentLog(appointmentId:Int, deleteAll:Bool) {
        do{
            let realm = try Realm()
            if deleteAll{
                let appointments = realm.objects(rf_Appointment_Logs.self)
                let appointmentLogData = realm.objects(rf_Appointment_Log_Data.self)
                if appointments.count > 0{
                    try realm.write{
                        appointments.forEach { appointmentLog in
                            realm.delete(appointmentLog)
                        }
                    }
                }
                if appointmentLogData.count > 0{
                    try realm.write{
                        appointmentLogData.forEach { appointmentLog in
                            realm.delete(appointmentLog)
                        }
                    }
                }
                
            }else{
                let appointments = realm.objects(rf_Appointment_Logs.self).filter("appointment_id == %d",appointmentId)
                let appointmentLog = realm.objects(rf_Appointment_Log_Data.self).filter("appointment_id == %d",appointmentId)
                if appointments.count == 1{
                    try realm.write{
                        if let appointment = appointments.first{
                            realm.delete(appointment)
                        }
                    }
                }
                if appointmentLog.count > 0{
                    try realm.write{
                        appointmentLog.forEach { log in
                            realm.delete(log)
                        }
                    }
                }
                
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    //func to show all the rooms from db (eg: BAR, BEDROOM,CLOSET...)
    func getMasterRoomFromDB() -> [RoomDataValue]{
        var roomList:[RoomDataValue] = []
        do{
            let realm = try Realm()
            let results =  realm.objects(MasterData.self)
            if let rooms = results.first?.rooms.sorted(byKeyPath: "room_name", ascending: true){
                for room in rooms{
                    roomList.append(RoomDataValue(roomData: room))
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return roomList
    }
    
    func getcustomRoomNameByApt(appointmentId:Int) -> [RoomDataValue]
    {
        var roomList:[RoomDataValue] = []
        do{
            let realm = try Realm()
            
            let rooms = realm.objects(rf_customRoomName.self).filter("appointment_id == %d",appointmentId )
            if rooms.count > 0
            {
//                if let results = rooms.sorted(byKeyPath: "roomId",ascending: false)
//                {
                    for room in rooms{
                        roomList.append(RoomDataValue(roomData: rf_master_roomname(customRoomName: room)))
                    }
                //}
            }
            return roomList
            
        }
        catch{
            print(RealmError.initialisationFailed)
        }
        return roomList
    }
    //Get master data values stored in DB
    func getMasterDataFromDB() -> MasterData{
        var masterData:MasterData!
        do{
            let realm = try Realm()
            masterData =  realm.objects(MasterData.self).first
            
        } catch let error {
            print("error : ", error)
//            if let myError = error as? MyErrors {
//                   print(myError.rawValue)
//               }
//            print(RealmError.initialisationFailed.rawValue)
        }
        return masterData
    }
    
    func deleteRoomById(appointmentId: Int, roomId:Int){
        do{
            let realm = try Realm()
            let room = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            try realm.write{
                realm.delete(room)
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        self.deleteRoomFromAppointment(appointmentId: appointmentId, roomId: roomId)
    }
    
    func deleteRoomFromAppointment(appointmentId: Int,roomId:Int){
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                try realm.write{
                    let rooms = appointment.rooms
                    rooms.forEach{ room in
                        if room.room_id == roomId{
                            realm.delete(room)
                        }
                    }
                }
                
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func checkIfAtleastOneRoomAddedUnderAppointment(appointmentId:Int) -> Bool{
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                let rooms = appointment.rooms
                if rooms.count > 0{
                    return true
                }
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        return false
    }
    
    func getDrawingPath(appointmentId: Int, roomId:Int) -> String{
        do{
            let realm = try Realm()
            
            let room = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            if let drawImageUrl = room.first?.draw_image_name{
                return drawImageUrl
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        return ""
        
    }
    
    func getCompletedRoomFromDB(appointmentId:Int) -> RealmSwift.List<rf_completed_room> {
        var rooms:  RealmSwift.List<rf_completed_room>!
        do{
            let realm = try Realm()
            if let appointment = realm.objects(rf_completed_appointment.self).filter("appointment_id == %d", (appointmentId)).first{
                rooms = appointment.rooms
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return rooms
    }
    
    
    
    func getAppointmentLogsFromDB() -> Results<rf_Appointment_Logs> {
        var appointmentLogs:  Results<rf_Appointment_Logs>!
        do{
            let realm = try Realm()
            appointmentLogs = realm.objects(rf_Appointment_Logs.self)
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentLogs
    }
    
    func getAppointmentLogDetailsFromDB() -> Results<rf_Appointment_Log_Data> {
        var appointmentLogs : Results<rf_Appointment_Log_Data>!
        do{
            let realm = try Realm()
            appointmentLogs = realm.objects(rf_Appointment_Log_Data.self)
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentLogs
    }
    
    
    func saveRoomImage(savedImageName: String,appointmentId: Int,roomId:Int) -> RealmSwift.List<String>{
        var savedRooms = RealmSwift.List<String>()
        do{
            let realm = try Realm()
            //let alreadySavedUrls = realm.object(ofType: rf_completed_room.self, forPrimaryKey: roomId)?.room_attachments
            let rooms = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            for room in rooms{
                try realm.write{
                    room.room_attachments.append(savedImageName)
                    room.appointment_id = appointmentId
                    savedRooms = room.room_attachments
                    //realm.add(savedRooms, update: .all)
                    realm.create(rf_completed_room.self, value: ["id":room.id,"appointment_id": appointmentId,"room_id":roomId, "room_attachments":room.room_attachments], update: .all)
                    
                }
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        self.saveCreatedRoomToAppointment(appointmentId: appointmentId,roomId: roomId)
        return savedRooms
    }
    func saveRoomMiscellaneousComments(miscellanousComments: String,appointmentId: Int,roomId:Int) 
    {
        do{
            let realm = try Realm()
            //let alreadySavedUrls = realm.object(ofType: rf_completed_room.self, forPrimaryKey: roomId)?.room_attachments
            let rooms = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            for room in rooms{
                try realm.write{
                    room.appointment_id = appointmentId
                    //realm.add(savedRooms, update: .all)
                    realm.create(rf_completed_room.self, value: ["id":room.id,"appointment_id": appointmentId,"room_id":roomId, "miscellaneous_comments":miscellanousComments], update: .all)
                    
                }
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        self.saveCreatedRoomToAppointment(appointmentId: appointmentId,roomId: roomId)
    }
    
    func saveSnapshotImage(savedImageName: String,appointmentId: Int) -> RealmSwift.List<String>{
        var savedRooms = RealmSwift.List<String>()
        do{
            let realm = try Realm()
            let appointment = realm.objects(rf_completed_appointment.self).filter("appointment_id == %d",appointmentId)
            if appointment.count > 0 {
                if let snapshots = appointment.first?.snanpshotImages{
                    try realm.write{
                        snapshots.append(savedImageName)
                        savedRooms = snapshots
                        let dict:[String:Any] = ["appointment_id":appointmentId,"snanpshotImages":snapshots]
                        realm.create(rf_completed_appointment.self, value: dict, update: .all)
                    }
                }
            }else{
                let imgList = RealmSwift.List<String>()
                imgList.append(savedImageName)
                try realm.write{
                    let dict:[String:Any] = ["appointment_id":appointmentId,"snanpshotImages":imgList]
                    realm.create(rf_completed_appointment.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        return savedRooms
    }
    func createJWTToken(parameter:[String : Any]) -> String
     {
         let header = JWTHeader(typ: "JWT", alg: .hs256)
         let signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
         var jwtToken:String = String()
         let json = (parameter as NSDictionary).JsonString()
         let data = json.data(using: .utf8)
                 
         let decoder = JSONDecoder()
                 
         if let data = data, let model = try? decoder.decode(paymentMethodDetailsSecret.self, from: data) {
             print(model)
             let jwt = JWT<paymentMethodDetailsSecret>(header: header, payload: model, signature: signature)
             jwtToken = JWTEncoder.shared.encode(jwt: jwt) ?? ""
             print(jwtToken)
         
         }
         return jwtToken
     }
     
     func createJWTTokenApplicantInfo(parameter:[String : Any]) -> String
      {
          let header = JWTHeader(typ: "JWT", alg: .hs256)
          let signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
          var jwtToken:String = String()
          let json = (parameter as NSDictionary).JsonString()
          let data = json.data(using: .utf8)
                  
          let decoder = JSONDecoder()
                  
          if let data = data, let model = try? decoder.decode(ApplicantInfoDetailsSecret.self, from: data) {
              print(model)
              let jwt = JWT<ApplicantInfoDetailsSecret>(header: header, payload: model, signature: signature)
              jwtToken = JWTEncoder.shared.encode(jwt: jwt) ?? ""
              print(jwtToken)
          
          }
          return jwtToken
      }
    
    func deleteRoomImage(savedImageUrlString: String,appointmentId: Int, roomId:Int) -> Bool{
        let savedRooms = rf_completed_room()
        var status = false
        do{
            let realm = try Realm()
            //let alreadySavedUrls = realm.object(ofType: rf_completed_room.self, forPrimaryKey: roomId)?.room_attachments
            let rooms = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            if let room = rooms.first{
                let alreadySavedUrls = room.room_attachments
                let savedUrls = alreadySavedUrls
                if savedUrls.count > 0{
                    savedRooms.room_attachments = savedUrls
                }
                try realm.write{
                    if let index = savedRooms.room_attachments.firstIndex(of: savedImageUrlString) {
                        savedRooms.room_attachments.remove(at:index)
                        savedRooms.appointment_id = appointmentId
                        realm.create(rf_completed_room.self, value: ["id":room.id,"appointment_id": appointmentId,"room_id":roomId, "room_attachments":savedRooms.room_attachments], update: .all)
                        status = true
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        return status
    }
    
    func deleteRoomAttachmentImagesFromDirectory(appointmentId: Int, roomId:Int)  {
        do{
            let realm = try Realm()
            let room = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            if room.count == 1{
                for roomAttachmentUrl in room.first!.room_attachments{
                    _ = ImageSaveToDirectory.SharedImage.deleteImageFromDocumentDirectory(rfImage: roomAttachmentUrl)
                    _ = self.deleteRoomImage(savedImageUrlString: roomAttachmentUrl, appointmentId: appointmentId, roomId: roomId)
                }
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
    }
    
    func saveCreatedRoomToAppointment(appointmentId: Int,roomId:Int){
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                try realm.write{
                    let room = realm.objects(rf_completed_room.self).filter("appointment_id == %d",appointmentId)
                    appointment.rooms.removeAll()
                    appointment.rooms.append(objectsIn: room)
                    realm.create(rf_completed_appointment.self, value: ["appointment_id": appointmentId, "rooms":appointment.rooms], update: .all)
                    
                }
            }
            
        }catch{
            print(RealmError.initialisationFailed)
        }
    }
    
    func saveCustomRoomName(roomId:String,appointmentId: Int, roomName:String, isConfirm:Bool,isNextBtn:Bool)
    {
        do
        {
            let realm = try Realm()
             let appointment = realm.objects(rf_customRoomName.self).filter("roomId == %d",roomId)
            for room in appointment
            {
                try realm.write
                {
                    room.name = roomName
                    if isNextBtn
                    {
                        room.isConfirm = true
                    }
                    //let customRoom = realm.objects(rf_customRoomName.self).filter("roomId == %d",roomId)
                    //realm.delete(appointment)
                    realm.create(rf_customRoomName.self, value: ["roomId": roomId,"appointment_id": appointmentId, "roomName":roomName, "isConfirm": isConfirm], update: .all)
                }
            }
            
        }catch{
            print(RealmError.initialisationFailed)
        }
    }
    
    func saveDynamicContractData(templateId:Int,documentURL:String,name:String,type:String)
    {
        do
        {
            let realm = try Realm()
             let contract = realm.objects(rf_contract_document_templates_results.self).filter("template_id == %d",templateId)
            for contractValue in contract
            {
                try realm.write
                {

                    
                    if let contractData = try? Data(contentsOf: URL(string: contractValue.document_url!)!)
                            {
                        contractValue.data = contractData
                            }
                    
    
                    realm.create(rf_customRoomName.self, value: ["template_id": templateId,"document_url": documentURL, "name":name, "type": type], update: .all)
                }
            }
            
        }catch{
            print(RealmError.initialisationFailed)
        }
    }
    
    func identifyMoldingTypesSelectedForRooms() -> [String]{
        var moldingTypeArray:[String] = []
        do{
            let appointmentId = AppointmentData().appointment_id ?? 0
            let realm = try Realm()
            let rooms = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_strike_status == %@" , appointmentId, false)
            rooms.forEach { room in
                if !(moldingTypeArray.contains(room.selected_room_molding ?? "")){
                    moldingTypeArray.append(room.selected_room_molding ?? "")
                }
            }
            return moldingTypeArray
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return moldingTypeArray
    }
    
    func loadRoomImage(appointmentId: Int,roomId:Int) -> RealmSwift.List<String> {
        var images = RealmSwift.List<String>()
        do{
            let realm = try Realm()
            let appointment =  realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)
            if let room = appointment?.rooms.filter("room_id == \(roomId)").first{
                let imagesList = room.room_attachments
                images = imagesList
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
        
        return images
    }
    
    func loadSnapshotImage(appointmentId: Int) -> RealmSwift.List<String> {
        var images = RealmSwift.List<String>()
        do{
            let realm = try Realm()
            let appointment =  realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)
            if let imagesArr = appointment?.snanpshotImages{
                images = imagesArr
            }
            return images
        }catch{
            print(RealmError.initialisationFailed)
        }
        
        return images
    }
    
    func getCompletedRoomsFromDB(appointmentId:Int,roomId:Int) -> Results<rf_completed_room>{
        var completedRoom:Results<rf_completed_room>!
        do{
            let realm = try Realm()
            completedRoom = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d" , appointmentId, roomId)
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return completedRoom
    }
    
    
    
    func getCompletedAppointmentsFromDB(appointmentId:Int) -> Results<rf_completed_appointment>{
        var completedAppointment:Results<rf_completed_appointment>!
        do{
            let realm = try Realm()
            completedAppointment = realm.objects(rf_completed_appointment.self).filter("appointment_id == %d" , appointmentId)
            
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return completedAppointment
    }
    
    func getQuestionsForAppointment(appointmentId:Int,roomId: Int) -> RealmSwift.List<rf_master_question>{
        let qtns = RealmSwift.List<rf_master_question>()
        do{
            let realm = try Realm()
            if realm.objects(rf_master_question.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId).count > 0{
                let questions = realm.objects(rf_master_question.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
                qtns.removeAll()
                questions.forEach { question in
                    qtns.append(question)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return qtns
    }
    
    func getAnswerForQuestion(appointmentId:Int, questionId: Int) -> RealmSwift.Results<rf_AnswerForQuestion>{
        var answer : Results<rf_AnswerForQuestion>!
        do{
            let realm = try Realm()
            if realm.objects(rf_AnswerForQuestion.self).filter("appointment_id == %d AND question_id == %d",appointmentId , questionId).count > 0{
                answer = realm.objects(rf_AnswerForQuestion.self).filter("appointment_id == %d AND question_id == %d",appointmentId , questionId)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return answer
    }
    
    func checkIfAnswerPendingForAnyMandatoryQuestion(appointmentId:Int,roomId: Int, roomName: String,roomArea:Double) -> Bool{
        var isStair = false
        if roomArea == 0.0 {
            isStair = true
        }
        do{
            let realm = try Realm()
            if realm.objects(rf_master_question.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId).count > 0{
                var questions = realm.objects(rf_master_question.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
                if isStair{
                    questions = questions.filter("applicableTo == %@ OR applicableTo == %@","common","stairs")
                }else{
                    questions = questions.filter("applicableTo == %@ OR applicableTo == %@","common","rooms")
                }
                let mandatoryQuestions = questions.filter("mandatory_answer == %@",true)
                let mandatoryQuestionsUnanswered =  mandatoryQuestions.filter("ANY rf_AnswerOFQustion.@count == 0")
                return (mandatoryQuestionsUnanswered.count > 0) ? true : false
            }else{
                return true
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return false
    }
    
    func checkIfRoomExist(appointmentId: Int,roomId:Int) -> (roomExist:Bool, room: Results<rf_completed_room>?){
        do{
            let realm = try Realm()
            let room = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            if room.count == 1{
                return (true,room)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return (false,nil)
    }
    func checkIfCustomRoomExists(appointmentId: Int,roomId:String) -> Bool
    {
        do{
            let realm = try Realm()
            let room = realm.objects(rf_customRoomName.self).filter("appointment_id == %d AND roomId == %@",appointmentId , roomId)
            if room.count == 1{
                return (true)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return (false)
    }
    
    func getCustomRoomName(appointmentId: Int,roomId:String) -> String
    {
        var roomName:String = String()
        do{
            let realm = try Realm()
            let room = realm.objects(rf_customRoomName.self).filter("appointment_id == %d AND roomId == %@",appointmentId , roomId)
            if room.count == 1{
                roomName = (room.first?.name)!
                return roomName
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return roomName
    }
    
    
    
    func checkIfRoomDrawImageExist(appointmentId: Int) -> Bool{
        do{
            let realm = try Realm()
            if let appointment = realm.objects(rf_completed_appointment.self).filter("appointment_id == %d",appointmentId).first{
                let rooms = appointment.rooms
                let snapshots = appointment.snanpshotImages
                if rooms.filter("draw_image_name != %@", "").count > 0{
                    return true
                }else if rooms.filter("room_attachments.@count > 0").count > 0{
                    return true
                }else if snapshots.count > 0{
                    return true
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return false
    }
    
    func updateAdjustedArea(appointmentId: Int,roomId:Int,area:String){
        do{
            let realm = try Realm()
            let room = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            if room.count == 1{
                if let id = room.first?.id{
                    let dict:[String:Any] = ["id": id ,"draw_area_adjusted":area,"room_id":roomId]
                    try realm.write{
                        realm.create(rf_completed_room.self, value: dict, update: .all)
                    }
                }
            }
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    
    func updateRoomComment(appointmentId: Int,roomId:Int,comment:String,miscellaneous_comments:String){
        do{
            let realm = try Realm()
            let room = realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomId)
            if room.count == 1{
                if let id = room.first?.id{
                    let dict:[String:Any] = ["id":id ,"room_summary_comment":comment,"room_id":roomId,"miscellaneous_comments":miscellaneous_comments]
                    try realm.write{
                        realm.create(rf_completed_room.self, value: dict, update: .all)
                    }
                }
            }
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    
    func updateAppointmentData(appointmentChangesDict:[String:Any]){
        do{
            let realm = try Realm()
            try realm.write{
                realm.create(rf_master_appointment.self, value: appointmentChangesDict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func getRoomsSummary(appointmentId: Int) -> [SummeryListData]{
        var summaryListArray : [SummeryListData] = []
        do{
            let realm = try Realm()
            let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)
            if let rooms = appointment?.rooms{
                for room in rooms{
                    let summaryList = SummeryListData()
                    summaryList.striked = room.room_strike_status ? "true" : "false"
                    summaryList.room_name = room.room_name
                    summaryList.room_id = room.room_id
                    summaryList.name = room.room_name
                    summaryList.color = room.selected_room_color ?? "Select Color"
                    summaryList.moulding = room.selected_room_molding ?? ""
                    summaryList.mouldingPrice = room.selected_room_MoldingPrice
                    summaryList.room_image_url = room.room_attachments.first ?? ""
                    summaryList.room_area = Double(room.draw_area_adjusted ?? "0.0")
                    summaryList.material_image_url = room.material_image_url
                    summaryList.adjusted_area = Double(room.draw_area_adjusted ?? "0.0")
                    summaryList.stair_count = Int(room.stairCount ?? "0")
                    summaryList.colorUpCharge = room.selected_room_Upcharge
                    summaryList.colorUpChargePrice = room.selected_room_UpchargePrice
                    summaryList.room_perimeter = room.room_perimeter
                    //summaryList.miscellaneous_comments = room.miscellaneous_comments
                    summaryListArray.append(summaryList)
                }
            }
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return summaryListArray
    }
    
    func includeOrExcludeRoom(roomID:Int, isInclude: Bool){
        let appointmentId = AppointmentData().appointment_id ?? 0
        let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
        if let room = appointment.first?.rooms.filter("room_id == %d", roomID){
            do{
                let realm = try Realm()
                try realm.write{
                    if let id = room.first?.id{
                        let dict:[String:Any] = ["id": id,"room_id":roomID,"room_strike_status":isInclude]
                        realm.create(rf_completed_room.self, value: dict, update: .all)
                    }
                }
            }catch{
                print(RealmError.initialisationFailed.rawValue)
            }
        }
    }
    
    
    func determineIfAnyPendingAppointmentsToSink() -> Bool{
        var isAppointmentsPendingToSink = false
        do{
            let realm = try Realm()
            let allAppointmentsAvailable = realm.objects(rf_Completed_Appointment_Request.self)
            if !(allAppointmentsAvailable.isEmpty){
                for appointment in allAppointmentsAvailable{
                    if appointment.sync_status == false{
                        isAppointmentsPendingToSink = true
                        break
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return isAppointmentsPendingToSink
    }
    
    
    
    func updateRoomMoldOrColor(roomID:Int, moldName: String,isColor:Bool = false, colorName: String = "", colorImageUrl: String = "", colorUpCharge: Double = 0.0, moldPrice: Double = 0.0){
        let appointmentId = AppointmentData().appointment_id ?? 0
        let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
        if let room = appointment.first?.rooms.filter("room_id == %d", roomID){
            do{
                let realm = try Realm()
                try realm.write{
                    var dict:[String:Any] = [:]
                    if let id = room.first?.id{
                        if !isColor{
                            
                            dict = ["id":id, "room_id":roomID, "selected_room_molding":moldName, "selected_room_MoldingPrice": moldPrice]
                            
                        }else{
                            dict = ["id":id,"room_id":roomID,"selected_room_color":colorName,"material_image_url":colorImageUrl, "selected_room_Upcharge": colorUpCharge ,"selected_room_MoldingPrice": moldPrice]
                        }
                    }
                    realm.create(rf_completed_room.self, value: dict, update: .all)
                }
            }catch{
                print(RealmError.initialisationFailed.rawValue)
            }
        }
    }
    
    func deleteRoom(roomID:Int){
        let appointmentId = AppointmentData().appointment_id ?? 0
        let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
        if let room = appointment.first?.rooms.filter("room_id == %d", roomID){
            do{
                let realm = try Realm()
                try realm.write{
                    realm.delete(room)
                }
            }catch{
                print(RealmError.initialisationFailed.rawValue)
            }
        }
    }
    
    func saveApplicantOneDataToAppointmentDetail(applicantInfo: rf_ApplicantData){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = ["applicantData":applicantInfo,"appointment_id":appointmentId]
                //realm.create(rf_master_appointment.self, value: dict, update: .all)
                
                realm.create(rf_completed_appointment.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    
    func saveCoApplicantDataToAppointmentDetail(coApplicantInfo: rf_CoApplicationData){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = ["coApplicantData":coApplicantInfo,"appointment_id":appointmentId]
                //realm.create(rf_master_appointment.self, value: dict, update: .all)
                realm.create(rf_completed_appointment.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func deleteCoApplicantDataFromAppointmentDetail(){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                if let _ = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                    let dict:[String:Any] = ["coApplicantData":rf_CoApplicationData(),"appointment_id":appointmentId]
                    realm.create(rf_completed_appointment.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func deleteCoApplicantSignatureAndInitialsFromAppointmentDetail(){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                if let _ = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                    let dict:[String:Any] = ["coApplicantSignatureImage":"","appointment_id":appointmentId,"coApplicantInitialsImage":""]
                    realm.create(rf_completed_appointment.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func saveContractDataOfAppointment(appointmentId:Int, contractData: NSDictionary) {
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = ["contractData":contractData.JsonString(),"appointment_id":appointmentId]
                realm.create(rf_completed_appointment.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    
    func savePaymentMethodTypeToAppointmentDetail(paymentType: NSDictionary){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = ["paymentType":paymentType.JsonString(),"appointment_id":appointmentId]
                realm.create(rf_completed_appointment.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }

    
    func getPaymentMethodTypeFromAppointmentDetail() -> [String: Any]{
        let appointmentId = AppointmentData().appointment_id ?? 0
        var dictionary: [String: Any] = [:]
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                let paymentTypeDictString = appointment.paymentType
                dictionary =  paymentTypeDictString?.dictionaryValue() ?? [:]
                return dictionary
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return dictionary
    }
    
    func getContractDataOfAppointment() -> [String: Any]{
        let appointmentId = AppointmentData().appointment_id ?? 0
        var dictionary: [String: Any] = [:]
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                let contractDataDictString = appointment.contractData
                dictionary =  contractDataDictString?.dictionaryValue() ?? [:]
                return dictionary
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return dictionary
    }
    
    func saveOtherIncomeDetailsToAppointmentDetail(otherIncomeInfo: rf_OtherIncomeData){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = ["otherIncomeData":otherIncomeInfo,"appointment_id":appointmentId]
                //realm.create(rf_master_appointment.self, value: dict, update: .all)
                realm.create(rf_completed_appointment.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
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
    
    func loadLogDetailsForAppointment(appointmentId: Int) -> [String]{
        var logs:[String] = []
        do{
            let realm = try Realm()
            let appointmentLogs = realm.objects(rf_Appointment_Logs.self).filter("appointment_id == %@",appointmentId)
            if let logList = appointmentLogs.first?.sync_message{
                logList.forEach { log in
                    logs.append(log.sync_message ?? "")
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return logs
    }
    
    
    func saveToCustomerDetailsOnceUpdatedInApplicantForm(appointmentId:Int, customerDetailsDict:[String:Any]){
        do{
            let realm = try Realm()
            if let _ = realm.objects(rf_completed_appointment.self).filter("appointment_id == %@",appointmentId).first{
                try realm.write{
                    var dict:[String:Any?] = [:]
                    if customerDetailsDict["applicant_first_name"] as? String != "" && customerDetailsDict["applicant_first_name"] != nil{
                        let applicant_phone = customerDetailsDict["home_phone"]
                        let applicant_street = customerDetailsDict["street2"]
                        let applicant_street2 = customerDetailsDict["street"]
                        let applicant_state_code = customerDetailsDict["state_code"]
                        let applicant_city = customerDetailsDict["city"]
                        let applicant_zip = customerDetailsDict["zip"]
                        //appointment.state = customerDetailsDict["state"]
                        let applicant_country = customerDetailsDict["country"]
                        let country_code = customerDetailsDict["country_code"]
                        //appointment.phone = customerDetailsDict["phone"] as? String
                        let applicant_email = customerDetailsDict["email"]
                        let applicant_first_name = customerDetailsDict["applicant_first_name"]
                        let applicant_middle_name = customerDetailsDict["applicant_middle_name"]
                        let applicant_last_name = customerDetailsDict["applicant_last_name"]
                        dict = ["appointment_id": appointmentId,
                                "applicant_phone":applicant_phone,
                                "applicant_street":applicant_street,
                                "applicant_street2":applicant_street2,
                                "applicant_state_code":applicant_state_code,
                                "applicant_city":applicant_city,
                                "applicant_zip":applicant_zip,
                                "applicant_country":applicant_country,
                                "country_code":country_code,
                                "applicant_email":applicant_email,
                                "applicant_first_name":applicant_first_name,
                                "applicant_middle_name":applicant_middle_name,
                                "applicant_last_name":applicant_last_name]
                    }
                    if customerDetailsDict["co_applicant_first_name"] as? String != "" && customerDetailsDict["co_applicant_first_name"] != nil {
                        let co_applicant_first_name = customerDetailsDict["co_applicant_first_name"]
                        let co_applicant_middle_name = customerDetailsDict["co_applicant_middle_name"]
                        let co_applicant_last_name = customerDetailsDict["co_applicant_last_name"]
                        let co_applicant_email = customerDetailsDict["co_applicant_email"]
                        let co_applicant_secondary_phone = customerDetailsDict["co_applicant_secondary_phone"]
                        let co_applicant_address = customerDetailsDict["co_applicant_address"]
                        let co_applicant_city = customerDetailsDict["co_applicant_city"]
                        let co_applicant_state = customerDetailsDict["co_applicant_state"]
                        let co_applicant_zip = customerDetailsDict["co_applicant_zip"]
                        let co_applicant_phone = customerDetailsDict["co_applicant_phone"]
                        dict["co_applicant_first_name"] = co_applicant_first_name
                        dict["co_applicant_middle_name"] = co_applicant_middle_name
                        dict["co_applicant_last_name"] = co_applicant_last_name
                        dict["co_applicant_email"] = co_applicant_email
                        dict["co_applicant_secondary_phone"] = co_applicant_secondary_phone
                        dict["co_applicant_address"] = co_applicant_address
                        dict["co_applicant_city"] = co_applicant_city
                        dict["co_applicant_state"] = co_applicant_state
                        dict["co_applicant_zip"] = co_applicant_zip
                        dict["co_applicant_phone"] = co_applicant_phone
                    }
                    
                    realm.create(rf_completed_appointment.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func saveApplicantAndIncomeDataToAppointmentDetail(data: NSDictionary){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = ["applicantAndIncomeData":data.JsonString(),"appointment_id":appointmentId]
                realm.create(rf_completed_appointment.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func savePaymentDetailsToAppointmentDetail(data: NSDictionary){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = ["paymentDetails":data.JsonString(),"appointment_id":appointmentId]
                realm.create(rf_completed_appointment.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func checkIfPaymentDetailsExistForAppointment(appointmentId: Int) -> Bool{
        do{
            let realm = try Realm()
            if let appointment = realm.objects(rf_completed_appointment.self).filter("appointment_id == %d", appointmentId).first{
                if let paymentDetailsStr = appointment.paymentDetails{
                    if paymentDetailsStr != ""{
                        return true
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return false
    }
    
    func deleteAllAppointmentRequestForThisAppointmentId(appointmentId: Int){
        do{
            let realm = try Realm()
            try realm.write{
                let appointmentRequest = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d", appointmentId)
                if appointmentRequest.count > 0 {
                    appointmentRequest.forEach { appointmentRequestObj in
                        realm.delete(appointmentRequestObj)
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func deleteAllRoomImagesFromAppointmentRequest(){
        do{
            let realm = try Realm()
            try realm.write{
                let appointmentRequest = realm.objects(rf_Completed_Appointment_Request.self).filter("reqest_title == %d AND sync_status == %@", RequestTitle.ImageUpload.rawValue,true)
                if appointmentRequest.count > 0 {
                    appointmentRequest.forEach { appointmentRequestObj in
                        let imageName = appointmentRequestObj.image_name ?? ""
                        if imageName != ""{
                            _ = ImageSaveToDirectory.SharedImage.deleteImageFromDocumentDirectory(rfImage: imageName)
                        }
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    
    
    func checkAppointmentStatusOfAppointmentId(appointmentId: Int) -> AppointmentStatus{
        do{
            let realm = try Realm()
            let appointmentRequest = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d", appointmentId)
            
            if appointmentRequest.count == 0 { //ie this is an appointment yet to start
                return AppointmentStatus.start
            }else if appointmentRequest.filter("sync_status == %@",false).count > 0{ // atleast one enty yet to sync
                return AppointmentStatus.sync
            }
            else if appointmentRequest.filter("sync_status == %@",true).count > 1
            {
                return AppointmentStatus.complete
            }
            else if appointmentRequest.filter("sync_status == %@ AND reqest_title == %@",true,"Sales_Update").count == 1{
                return AppointmentStatus.start
            }
            else{
                // all synced, hide appointment
                return AppointmentStatus.complete
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        
        return AppointmentStatus.start
    }
    func getCompletedAppointmentData() -> Results<rf_completed_appointment>!{
        var appointmentData : Results<rf_completed_appointment>!
        do{
            let realm = try Realm()
             let appointment = realm.objects(rf_completed_appointment.self)
                appointmentData = appointment
            return appointmentData
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentData
    }
    
    
    func createDBAppointmentRequest(requestTitle: RequestTitle, requestUrl: String, requestType: RequestType ,requestParameter: NSDictionary,imageName:String){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                let dict:[String:Any] = [ "appointment_id": appointmentId,
                                          "reqest_title": requestTitle.rawValue,
                                          "request_url": requestUrl,
                                          "request_parameter" : requestParameter.JsonString(),
                                          "request_type" : requestType.rawValue,
                                          "sync_status" : true,
                                          "image_name": imageName]
                realm.create(rf_Completed_Appointment_Request.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func createAppointmentRequest(requestTitle: RequestTitle, requestUrl: String, requestType: RequestType ,requestParameter: NSDictionary,imageName:String){
        print("createAppointmentRequest : ", requestParameter)
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            try realm.write{
                
             let dict:[String:Any] = [ "appointment_id": appointmentId,
                                      "reqest_title": requestTitle.rawValue,
                                      "request_url": requestUrl,
                                      "request_parameter" : requestParameter.JsonString(),
                                      "request_type" : requestType.rawValue,
                                      "sync_status" : false,
                                      "image_name": imageName]
                print("Dictionary to be created/updated in Realm: \(dict)")
                print("Dictionary to be created/updated in Realm1: \(rf_Completed_Appointment_Request.self)")
                realm.create(rf_Completed_Appointment_Request.self, value: dict, update: .all)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func fetchAppointmentRequest() -> RealmSwift.Results<rf_Completed_Appointment_Request>{
        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
        do{
            let realm = try Realm()
            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@",false)
            return appointmentRequestArray
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentRequestArray
    }
    
    func fetchAppointmentRequest(for appointmentId : Int) -> RealmSwift.Results<rf_Completed_Appointment_Request>{
        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
        do{
            let realm = try Realm()
            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@ AND appointment_id == %d",false, appointmentId)
            return appointmentRequestArray
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentRequestArray
    }
    
    func fetchCustomerAndRoomFromAppointmentRequest() -> RealmSwift.Results<rf_Completed_Appointment_Request>{
        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
        do{
            let realm = try Realm()
            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@ AND reqest_title == %@",false,RequestTitle.CustomerAndRoom.rawValue)
            return appointmentRequestArray
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentRequestArray
    }
//    func fetchContractFromAppointmentRequest() -> RealmSwift.Results<rf_Completed_Appointment_Request>{
//        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
//        do{
//            let realm = try Realm()
//            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@ AND reqest_title == %@",false,RequestTitle.ContactDetails.rawValue)
//            return appointmentRequestArray
//        }catch{
//            print(RealmError.initialisationFailed.rawValue)
//        }
//        return appointmentRequestArray
//    }
    
    func fetchImageAppointmentRequest() -> RealmSwift.Results<rf_Completed_Appointment_Request>{
        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
        do{
            let realm = try Realm()
            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@ AND image_name != %@",false,"")
            return appointmentRequestArray
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentRequestArray
    }
    
    func fetchGenerateContractFromAppointmentRequest() -> RealmSwift.Results<rf_Completed_Appointment_Request>{
        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
        do{
            let realm = try Realm()
            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@ AND reqest_title == %@",false,RequestTitle.GenerateContract.rawValue)
            return appointmentRequestArray
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentRequestArray
    }
    
    func fetchi360FromAppointmentRequest() -> RealmSwift.Results<rf_Completed_Appointment_Request>{
        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
        do{
            let realm = try Realm()
            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@ AND reqest_title == %@",false,RequestTitle.InitiateSync.rawValue)
            return appointmentRequestArray
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentRequestArray
    }
    
    
    func updateAppointmentRequestSyncStatusAsComplete(appointmentId: Int, requestTitle: RequestTitle, imageName:String = ""){
        do{
            let realm = try Realm()
            try realm.write{
                if requestTitle != RequestTitle.ImageUpload{
                    let appointmentRequest = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d AND reqest_title == %@", appointmentId, requestTitle.rawValue)
                    var dict:[String:Any] = [:]
                    if appointmentRequest.count == 1{
                        if let appointmentRequestObj = appointmentRequest.first{
                            dict = ["id": appointmentRequestObj.id,
                                    "sync_status" : true]
                            realm.create(rf_Completed_Appointment_Request.self, value: dict, update: .all)
                        }
                    }
                }
                else{
                    let appointmentRequest = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d AND reqest_title == %@ AND image_name == %@", appointmentId, requestTitle.rawValue, imageName)
                    var dict:[String:Any] = [:]
                    if appointmentRequest.count == 1{
                        if let appointmentRequestObj = appointmentRequest.first{
                            dict = ["id": appointmentRequestObj.id,
                                    "sync_status" : true]
                            realm.create(rf_Completed_Appointment_Request.self, value: dict, update: .all)
                        }
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    
    
    func getApplicantAndIncomeDataFromAppointmentDetail() -> [String: Any]{
        let appointmentId = AppointmentData().appointment_id ?? 0
        var dictionary: [String: Any] = [:]
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                let coApplicantDictString = appointment.applicantAndIncomeData
                dictionary =  coApplicantDictString?.dictionaryValue() ?? [:]
                return dictionary
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return dictionary
    }
    
    func getPaymentDetailsDataFromAppointmentDetail() -> [String: Any]{
        let appointmentId = AppointmentData().appointment_id ?? 0
        var dictionary: [String: Any] = [:]
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                let paymentDetailsDictString = appointment.paymentDetails
                dictionary =  paymentDetailsDictString?.dictionaryValue() ?? [:]
                //add progressive discount data
                let array = self.getDiscountArrayToSend()
                var disArray: [[String:Any]] = []
                for discount in array{
                    let disDict = discount.toDictionary()
                    disArray.append(disDict)
                }
                dictionary["discount_history_line"] = disArray
                return dictionary
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return dictionary
    }
    
    func getSalesPersonName() -> String{
        var salesPerson = ""
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            let appointment = realm.objects(rf_master_appointment.self).filter("id == %d",appointmentId).first
            salesPerson = appointment?.sales_person ?? ""
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return salesPerson
    }
    
    func getMasterAppointmentOfficeLocationId() -> Int{
        var officeLocationId = 0
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            let appointment = realm.objects(rf_master_appointment.self).filter("id == %d",appointmentId).first
            officeLocationId = appointment?.officeLocationId ?? 0
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return officeLocationId
    }
    
//    func fetchi360FromAppointmentRequest() -> RealmSwift.Results<rf_Completed_Appointment_Request>{
//        var appointmentRequestArray : Results<rf_Completed_Appointment_Request>!
//        do{
//            let realm = try Realm()
//            appointmentRequestArray = realm.objects(rf_Completed_Appointment_Request.self).filter("sync_status == %@ AND reqest_title == %@",false,RequestTitle.InitiateSync.rawValue)
//            return appointmentRequestArray
//        }catch{
//            print(RealmError.initialisationFailed.rawValue)
//        }
//        return appointmentRequestArray
//    }

    
    func specialPriceTable() -> RealmSwift.Results<rf_specialPrice_results>{
        var specialPriceData : Results<rf_specialPrice_results>!
        do{
            let realm = try Realm()
            specialPriceData = realm.objects(rf_specialPrice_results.self)
            return specialPriceData
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return specialPriceData
    }
    func ruleListTable() -> RealmSwift.Results<rf_ruleList_results>{
        var ruleLisData : Results<rf_ruleList_results>!
        do{
            let realm = try Realm()
            ruleLisData = realm.objects(rf_ruleList_results.self)
            return ruleLisData
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return ruleLisData
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
    
    
    func saveApplicantOrCoApplicantSignatureAndInitials(isApplicant:Bool,isSignature:Bool,fileName:String){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            if let _ = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                var dict:[String:Any] = [:]
                if isApplicant{
                    if isSignature{
                        dict = ["appointment_id":appointmentId,"applicantSignatureImage":fileName]
                    }else{
                        dict = ["appointment_id":appointmentId,"applicantInitialsImage":fileName]
                    }
                }else{
                    if isSignature{
                        dict = ["appointment_id":appointmentId,"coApplicantSignatureImage":fileName]
                    }else{
                        dict = ["appointment_id":appointmentId,"coApplicantInitialsImage":fileName]
                    }
                }
                try realm.write{
                    realm.create(rf_completed_appointment.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func getApplicantSignatureAndInitials() -> (signature:String , initial: String){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                let signatureImageName = appointment.applicantSignatureImage
                let initialsImageName = appointment.applicantInitialsImage
                return (signatureImageName ?? "",initialsImageName ?? "")
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return ("","")
    }
    
    func getCoApplicantSignatureAndInitials() -> (signature:String , initial: String){
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            if let appointment = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId){
                let signatureImageName = appointment.coApplicantSignatureImage
                let initialsImageName = appointment.coApplicantInitialsImage
                return (signatureImageName ?? "",initialsImageName ?? "")
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return ("","")
    }
    
    func getFllorImageName(atIndex index:Int) -> String{
        do{
            let realm = try Realm()
            let floorImages = realm.objects(FloorImageStorage.self)
            if floorImages.count - 1 >= index{
                let floorImage = floorImages[index]
                return floorImage.imageName
            }
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return ""
    }
    func getStairImageName(atIndex index:Int) -> String{
        do{
            let realm = try Realm()
            let floorImages = realm.objects(StairImageStorage.self)
            if floorImages.count - 1 >= index{
                let floorImage = floorImages[index]
                return floorImage.imageName
            }
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return ""
    }
    
    func createSummaryData(roomID:Int,roomName:String) -> SummeryDetailsData{
        let summaryData =  SummeryDetailsData()
        let appointmentId = AppointmentData().appointment_id ?? 0
        let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
        let room = appointment.first?.rooms.filter("room_id == %d", roomID)
        if room?.count == 1{
            //room?.first?.room_perimeter
            summaryData.name = roomName
            summaryData.room_name = roomName
            summaryData.room_id = roomID
            summaryData.appointment_id = appointmentId
            summaryData.room_area = Double(room?.first?.room_area ?? "0.0")
            summaryData.room_perimeter = Double(room?.first?.room_perimeter ?? 0.0)
            summaryData.stair_count = room?.first?.room_type == "Floor" ? 0 : 0
            summaryData.adjusted_area = room?.first?.draw_area_adjusted == nil ? Double(room?.first?.room_area ?? "0.0") : Double(room?.first?.draw_area_adjusted ?? "0.0")
            summaryData.comments = room?.first?.room_summary_comment ?? ""
            summaryData.striked = (room?.first?.room_strike_status ?? false) ? "1" : "0"
            summaryData.miscellaneous_comments = room?.first?.miscellaneous_comments ?? ""
            var room_Attachments:[AttachmentDataValue] = []
            if let roomAttachments = room?.first?.room_attachments
            {
                for room in roomAttachments
                {
                    room_Attachments.append(AttachmentDataValue(savedImageUrl: room, savedImageName: "", id: 0))
                }
            }
            summaryData.attachments = room_Attachments
            summaryData.attachment_comments = ""
            summaryData.drawing_attachment = [AttachmentDataValue(savedImageUrl: room?.first?.draw_image_name ?? "", savedImageName: "", id: 0)]
            var transtionDetails:[SummeryTransitionDetails] = []
            if let transArray = room?.first?.transArray{
                for transData in transArray{
                    transtionDetails.append(SummeryTransitionDetails(name: transData.name ?? ""))
                }
                summaryData.transition = transtionDetails
            }
        }
        var questionsArray:[SummeryQustionsDetails] = []
        let questions = RealmSwift.List<rf_master_question>()
        //arr
        let rooms = getCompletedRoomsFromDB(appointmentId: appointmentId, roomId: roomID)
        if let questionsArr = rooms.first?.questionnaires{
            for question in questionsArr{
                if /*!roomName.localizedCaseInsensitiveContains("stair") &&*/ rooms.first?.room_area != "0" && rooms.first?.room_area != nil{
                    if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "rooms"){
                        questions.append(question)
                    }
                }else{
                    if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "stairs"){
                        questions.append(question)
                        
                    }
                }
            }
            for qstnAnswer in questions{
                let answer = SummeryQustionAnswerData(id: qstnAnswer.id, answer: (qstnAnswer.rf_AnswerOFQustion.first?.answer.first ?? ""))
                let qtn = SummeryQustionsDetails(question_id: qstnAnswer.id, name: qstnAnswer.question_code ?? "", question: qstnAnswer.question_name ?? "", question_type: qstnAnswer.question_type ?? "", answers: [answer],calculate_order_wise: qstnAnswer.calculate_order_wise)
                questionsArray.append(qtn)
            }
        }
        summaryData.questionaire = questionsArray
        return summaryData
    }
    
    func getStairCountAndWidth(roomId:Int) -> [String:String]{
        var stairDict:[String:String] = [:]
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let masterQuestions = realm.objects(rf_master_question.self).filter("appointment_id == %d AND room_id == %d", appointmentId, roomId)
            let stairCountQstn = masterQuestions.filter("question_code == %@", "StairCount")
            if stairCountQstn.count == 1{
                stairDict["StairCount"] = stairCountQstn.first?.rf_AnswerOFQustion.first?.answer.first ?? ""
            }
            let stairWidthQstn = masterQuestions.filter("question_code == %@", "StairWidth")
            if stairWidthQstn.count == 1{
                stairDict["StairWidth"] = stairWidthQstn.first?.rf_AnswerOFQustion.first?.answer.first ?? ""
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return stairDict
    }
    
    func saveQuestionAndAnswerToCompletedAppointment(roomId:Int,questionAndAnswer: RealmSwift.List<rf_master_question>){
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let id = room?.first?.id{
                let dict:[String:Any] = ["id": id,"room_id":roomId, "questionnaires":questionAndAnswer]
                print("saveQuestionAndAnswerToCompletedAppointment : ", id, " room_id : ", roomId, " questionnaires : ", questionAndAnswer)
                try realm.write{
                    realm.create(rf_completed_room.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    func savemiscellaneousComments(miscelleneous_Comments:String,appointmentId:Int,roomID:Int)
    {
        let partiallyCompletedRoomToUpdate:[String:Any] = ["room_id":roomID ,"appointment_id":appointmentId,"miscellaneous_comments":miscelleneous_Comments]
        do{
            let realm = try Realm()
            try realm.write
            {
                if realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId,roomID).count == 0{
                    realm.create(rf_completed_room.self, value: partiallyCompletedRoomToUpdate, update: .all)
                }
            }
        }
        catch{
            print(RealmError.initialisationFailed)
        }
    }
    
    func getExtraCostFromCompletedAppointment(roomId:Int) -> Double{
        var extraCost: Double = 0.0
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let roomSel = room?.first{
                extraCost = roomSel.extraPrice
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return extraCost
    }
    
    func saveExtraCostToCompletedAppointment(roomId:Int, extraCost: Double){
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let id = room?.first?.id{
                let dict:[String:Any] = ["id":id, "room_id":roomId, "extraPrice":extraCost]
                print("extraCostOfAppointment : ", roomId, " id : ", id, "extraCost : ", extraCost)
                try realm.write{
                    realm.create(rf_completed_room.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func saveExtraCostExcludeToCompletedAppointment(roomId:Int, extraCostExclude: Double, extraPromoPriceToExclude: Double){
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let id = room?.first?.id{
                let dict:[String:Any] = ["id":id, "room_id":roomId, "extraPriceToExclude":extraCostExclude , "extraPromoPriceToExclude":extraPromoPriceToExclude]
                try realm.write{
                    realm.create(rf_completed_room.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func getExtraCostExcludeFromCompletedAppointment(roomId:Int) -> (extrapriceToExclude:Double,extraPromoPriceToExclude:Double){
        var extraCostToExclude: Double = 0.0
        var extraPromoPriceToExclude: Double = 0.0
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let roomSel = room?.first{
                extraCostToExclude = roomSel.extraPriceToExclude
                extraPromoPriceToExclude = roomSel.extraPromoPriceToExclude
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return (extraCostToExclude,extraPromoPriceToExclude)
    }
    
    func saveUpchargeCostPerRoomToCompletedAppointment(roomId:Int, upChargeCost: Double){
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let id = room?.first?.id{
                let dict:[String:Any] = ["id":id, "room_id":roomId, "selected_room_UpchargePrice":upChargeCost]
                try realm.write{
                    realm.create(rf_completed_room.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func saveStairDetailsToCompletedAppointment(roomId:Int){
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let id = room?.first?.id{
                let stairsDict = self.getStairCountAndWidth(roomId: roomId)
                let stairCount = stairsDict["StairCount"] ?? ""
                let stairWidth = stairsDict["StairWidth"] ?? ""
                print("stairCount : ", stairCount, " stairWidth : ", stairWidth)
                let dict:[String:Any] = ["id":id, "room_id":roomId, "stairCount":stairCount, "stairWidth":stairWidth]
                try realm.write{
                    realm.create(rf_completed_room.self, value: dict, update: .all)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func getTotalAdjustedAreaForRoom(roomId:Int) -> Double{
        var roomArea: Double = 0.0
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            let room = appointment.first?.rooms.filter("room_id == %d", roomId)
            if let roomAreaAdjusted = room?.first?.draw_area_adjusted{
                roomArea = Double(roomAreaAdjusted) ?? 0.0
            }else{
                if let roomAreaCal = room?.first?.room_area{
                    roomArea = Double(roomAreaCal) ?? 0.0
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return roomArea
    }
    
    func getTotalAdjustedAreaForAllRooms() -> Double{
        var roomArea: Double = 0.0
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            appointment.first?.rooms.forEach({ room in
                if let roomAreaAdjusted = room.draw_area_adjusted{
                    roomArea = roomArea + (Double(roomAreaAdjusted) ?? 0.0)
                }else{
                    if let roomAreaCal = room.room_area{
                        roomArea = roomArea + (Double(roomAreaCal) ?? 0.0)
                    }
                }
            })
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return roomArea
    }
    
    func getRoomArrayForApiCall() -> [[String:Any]]{
        var roomArray: [[String:Any]] = []
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let masterData = realm.objects(MasterData.self).first
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            appointment.first?.rooms.forEach({ room in
                var roomDict:[String:Any] = [:]
                let room_id = room.room_id
                let room_name = room.room_name
                let room_area = room.room_area
                let room_area_image = room.draw_image_name
                let room_adjusted_area = room.draw_area_adjusted
                let room_perimeter = room.room_perimeter
                let moldingName = room.selected_room_molding
                let selectedColor = room.selected_room_color ?? ""
                let isCustomRoom = room.is_custom_room
                let mis_comments = room.miscellaneous_comments
                var roomColorId:Int = Int()
                if room_name!.contains("STAIRS") && (room_area == "0" || room_area == nil)
                {
                    roomColorId = masterData?.stairColourList.filter("color == %@",selectedColor).first?.material_id ?? 0
                }
                else
                {
                     roomColorId = masterData?.floorColourList.filter("color == %@",selectedColor).first?.material_id ?? 0
                    
                }
                var transitionArray: [[String:Any]] = []
//                var transition1_name = ""
//                var transition1_width = ""
//                var transition2_name = ""
//                var transition2_width = ""
//                var transition3_name = ""
//                var transition3_width = ""
//                var transition4_name = ""
//                var transition4_width = ""
                let isRoomExcluded = room.room_strike_status ? 1 : 0
                for i in 0..<room.transArray.count{
                    let name = room.transArray[i].name ?? ""
                    let width = room.transArray[i].transsquarefeet
                    let height = room.transArray[i].transHeight ?? "0"
                    let transitionHeightId = room.transArray[i].transitionHeightId
                    let transitionDict:[String:Any] = ["name":name, "width": width, "height": height , "transition_height_id":transitionHeightId]
                    transitionArray.append(transitionDict)
//                    switch i {
//
//                    case 0:
//                        transition1_name = room.transArray[i].name ?? ""
//                        transition1_width = "\(room.transArray[i].transsquarefeet)"
//                    case 1:
//                        transition2_name = room.transArray[i].name ?? ""
//                        transition2_width = "\(room.transArray[i].transsquarefeet)"
//                    case 2:
//                        transition3_name = room.transArray[i].name ?? ""
//                        transition3_width = "\(room.transArray[i].transsquarefeet)"
//                    case 3:
//                        transition4_name = room.transArray[i].name ?? ""
//                        transition4_width = "\(room.transArray[i].transsquarefeet)"
//                    default:
//                        break
//                    }
                }
                let room_comments = room.room_summary_comment ?? ""
                var room_image_names:[String] = []
                for i in 0..<room.room_attachments.count{
                    room_image_names.append(room.room_attachments[i])
                }
                if isCustomRoom == 1
                {
                    roomDict["room_id"] = 0
                    roomDict["is_custom_room"] = isCustomRoom
                }
                else
                {
                    roomDict["room_id"] = room_id
                }
                roomDict["room_name"] = room_name
                roomDict["room_area"] = room_area
                roomDict["room_area_image"] = room_area_image
                roomDict["room_adjusted_area"] = room_adjusted_area
                roomDict["room_perimeter"] = room_perimeter
                roomDict["misc_charge_comments"] = mis_comments
//                roomDict["transition1_name"] = transition1_name
//                roomDict["transition1_width"] = transition1_width
//                roomDict["transition2_name"] = transition2_name
//                roomDict["transition2_width"] = transition2_width
//                roomDict["transition3_name"] = transition3_name
//                roomDict["transition3_width"] = transition3_width
//                roomDict["transition4_name"] = transition4_name
//                roomDict["transition4_width"] = transition4_width
                roomDict["transitions"] = transitionArray
                roomDict["room_comments"] = room_comments
                roomDict["room_image_names"] = room_image_names
                roomDict["moulding_type"] = moldingName
                roomDict["material_id"] = roomColorId
                roomDict["exclude_from_calculation"] = isRoomExcluded
                roomArray.append(roomDict)
            })
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return roomArray
    }
    
    func getQuestionAnswerArrayForApiCall() -> [[String:Any]]{
        var questionAnswerArray:[[String:Any]] = []
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            var room_name:String = String()
            appointment.first?.rooms.forEach({ room in
                var questionAnswerDictForSingleRoom:[String:Any] = [:]

                let questionAnswers = room.questionnaires
                questionAnswers.forEach { question in
                    let isCustomRoomExists = self.checkIfCustomRoomExists(appointmentId: appointmentId, roomId: String(question.room_id))
                    
                    let room_id = question.room_id
                    let question_id = question.id
                    let calculate_order_wise = question.calculate_order_wise
                    if question.room_name != ""
                    {
                        room_name = question.room_name!
                    }
                     room_name = room_name
                    
                    let answerObj = question.rf_AnswerOFQustion.first
                    var answerArray:[String] = []
                    answerObj?.answer.forEach({ answer in
                        answerArray.append(answer)
                    })
                    if isCustomRoomExists
                    {
                        questionAnswerDictForSingleRoom["room_id"] = 0
                    }
                    else
                    {
                        questionAnswerDictForSingleRoom["room_id"] = room_id
                    }
                    questionAnswerDictForSingleRoom["question_id"] = question_id
                    questionAnswerDictForSingleRoom["answer"] = answerArray
                    questionAnswerDictForSingleRoom["room_name"] = room_name
                    if calculate_order_wise
                    {
                        questionAnswerDictForSingleRoom["calculate_order_wise"] = 1
                    }
                    else
                    {
                        questionAnswerDictForSingleRoom["calculate_order_wise"] = 0
                    }
                    questionAnswerArray.append(questionAnswerDictForSingleRoom)
                }
            })
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        
        return questionAnswerArray
    }
    
    func getCustomerDetailsForApiCall() -> [String:Any]{
        var customerDetailsDict:[String:Any] = [:]
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId).first
           // let mobile = appointment?.applicant_phone
            let street2 = appointment?.applicant_street2
            let street = appointment?.applicant_street
            let state_code = appointment?.applicant_state_code
            let city = appointment?.applicant_city
            let zip = appointment?.applicant_zip
            let appointment_id = appointment?.appointment_id
            let customer_id = ""
            let appointment_date = appointment?.appointment_date
            let state = ""
            let country_id = appointment?.applicant_country_id
            let country = appointment?.applicant_country
            let country_code = appointment?.applicant_country_code
            let phone = appointment?.applicant_phone
            let email = appointment?.applicant_email
            let sales_person = appointment?.sales_person
            let salesperson_id = appointment?.salesperson_id
            let partner_latitude = appointment?.partner_latitude
            let partner_longitude = appointment?.partner_longitude
            let applicant_first_name = appointment?.applicant_first_name
            let applicant_middle_name = appointment?.applicant_middle_name
            let applicant_last_name = appointment?.applicant_last_name
            let co_applicant_first_name = appointment?.co_applicant_first_name
            let co_applicant_middle_name = appointment?.co_applicant_middle_name
            let co_applicant_last_name = appointment?.co_applicant_last_name
            let co_applicant_email = appointment?.co_applicant_email
            let co_applicant_secondary_phone = appointment?.co_applicant_secondary_phone
            let co_applicant_address = appointment?.co_applicant_address
            let co_applicant_city = appointment?.co_applicant_city
            let co_applicant_state = appointment?.co_applicant_state
            let co_applicant_zip = appointment?.co_applicant_zip
            let co_applicant_phone = appointment?.co_applicant_phone
            //customerDetailsDict["mobile"] = mobile
            customerDetailsDict["street2"] = street2
            customerDetailsDict["street"] = street
            customerDetailsDict["state_code"] = state_code
            customerDetailsDict["city"] = city
            customerDetailsDict["zip"] = zip
            customerDetailsDict["appointment_id"] = appointment_id
            customerDetailsDict["customer_id"] = customer_id
            customerDetailsDict["appointment_date"] = appointment_date
            customerDetailsDict["state"] = state
            customerDetailsDict["country_id"] = country_id
            customerDetailsDict["country"] = country
            customerDetailsDict["country_code"] = country_code
            customerDetailsDict["phone"] = phone
            customerDetailsDict["email"] = email
            customerDetailsDict["sales_person"] = sales_person
            customerDetailsDict["salesperson_id"] = salesperson_id
            customerDetailsDict["partner_latitude"] = partner_latitude
            customerDetailsDict["partner_longitude"] = partner_longitude
            customerDetailsDict["applicant_first_name"] = applicant_first_name
            customerDetailsDict["applicant_middle_name"] = applicant_middle_name
            customerDetailsDict["applicant_last_name"] = applicant_last_name
            customerDetailsDict["co_applicant_first_name"] = co_applicant_first_name
            customerDetailsDict["co_applicant_middle_name"] = co_applicant_middle_name
            customerDetailsDict["co_applicant_last_name"] = co_applicant_last_name
            customerDetailsDict["co_applicant_email"] = co_applicant_email
            customerDetailsDict["co_applicant_secondary_phone"] = co_applicant_secondary_phone
            customerDetailsDict["co_applicant_address"] = co_applicant_address
            customerDetailsDict["co_applicant_city"] = co_applicant_city
            customerDetailsDict["co_applicant_state"] = co_applicant_state
            customerDetailsDict["co_applicant_zip"] = co_applicant_zip
            customerDetailsDict["co_applicant_phone"] = co_applicant_phone
            customerDetailsDict["appointment_result"] = "Sold"
            
            let (date,timeZone) = Date().getCompletedDateStringAndTimeZone()
            customerDetailsDict["completed_date"] = date
            customerDetailsDict["timezone"] = timeZone
            
            //arb
            let appoint = self.getAppointmentData(appointmentId: appointmentId)
            if applicant_first_name == nil{
                customerDetailsDict["applicant_first_name"] = appoint?.applicant_first_name
            }
            if applicant_last_name  == nil{
                customerDetailsDict["applicant_last_name"] = appoint?.applicant_last_name
            }
            if appointment_date == nil{
                customerDetailsDict["appointment_date"] = appoint?.appointment_datetime
                customerDetailsDict["appointment_datetime"] = appoint?.appointment_datetime
            }
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return customerDetailsDict
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func getRoomDrawingForApiCall() -> [[String:Any]]{
        var imageUploadDictArray: [[String:Any]] = []
        var customRoomName:String = String()
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            appointment.first?.rooms.forEach({ room in
                let isCustomRoomExists = self.checkIfCustomRoomExists(appointmentId: appointmentId, roomId: String(room.room_id))
                if isCustomRoomExists
                {
                    customRoomName = self.getCustomRoomName(appointmentId: appointmentId, roomId:  String(room.room_id))
                }
                if let drawImage =  room.draw_image_name{
                    let image_type = "measurement_image"
                    let room_id = room.room_id
                    let room_name = room.room_name
                    let image_name = drawImage
                    // let file = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: image_name)
                    var imageUploadDict: [String:Any] = [:]
                    imageUploadDict["appointment_id"] = appointmentId
                    imageUploadDict["image_type"] = image_type
                    if isCustomRoomExists
                    {
                        imageUploadDict["room_id"] = 0
                        imageUploadDict["room_name"] = customRoomName
                    }
                    else
                    {
                        imageUploadDict["room_id"] = room_id
                        imageUploadDict["room_name"] = room_name
                    }
                    imageUploadDict["image_name"] = image_name
                    imageUploadDict["data_completed"] = 0
                    imageUploadDictArray.append(imageUploadDict)
                }
            })
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return imageUploadDictArray
    }
    
    func getRoomImagesForApiCall() -> [[String:Any]]{
        var imageUploadDictArray: [[String:Any]] = []
        var customRoomName:String = String()
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            appointment.first?.rooms.forEach({ room in
                for roomAttachment in room.room_attachments{
                    let isCustomRoomExists = self.checkIfCustomRoomExists(appointmentId: appointmentId, roomId: String(room.room_id))
                    if isCustomRoomExists
                    {
                        customRoomName = self.getCustomRoomName(appointmentId: appointmentId, roomId:  String(room.room_id))
                    }
                    var image_type = ""
                    
                    let room_id = room.room_id
                    let room_name = room.room_name
                    let image_name = roomAttachment
                    if  image_name.contains("Attachment"){
                        image_type = "room_photo"
                    }else{
                        image_type = "protrusion_image"
                    }
                        //
                    var imageUploadDict: [String:Any] = [:]
                    imageUploadDict["appointment_id"] = appointmentId
                    imageUploadDict["image_type"] = image_type
                    if isCustomRoomExists
                    {
                        imageUploadDict["room_id"] = 0
                        imageUploadDict["room_name"] = customRoomName
                    }
                    else
                    {
                        imageUploadDict["room_id"] = room_id
                        imageUploadDict["room_name"] = room_name
                    }
                    imageUploadDict["image_name"] = image_name
                    imageUploadDict["data_completed"] = 0
                    imageUploadDictArray.append(imageUploadDict)
                }
            })
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return imageUploadDictArray
    }
    
    func getApplicantSignatureForApiCall() -> [[String:Any]]{
        var imageUploadDictArray: [[String:Any]] = []
        var customRoomName:String = String()
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            if let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId).first{
                let room = appointment.rooms.first
                let applicantSignatureImageName = appointment.applicantSignatureImage
                let isCustomRoomExists = self.checkIfCustomRoomExists(appointmentId: appointmentId, roomId: String(room?.room_id ?? 0))
                if isCustomRoomExists
                {
                    customRoomName = self.getCustomRoomName(appointmentId: appointmentId, roomId:  String(room?.room_id ?? 0))
                }
                var image_type = "applicant_signature"
                var room_id = room?.room_id
                let room_name = room?.room_name
                var image_name = (applicantSignatureImageName ?? "")
                //var file = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: image_name)
                var imageUploadDict: [String:Any] = [:]
                imageUploadDict["appointment_id"] = appointmentId
                imageUploadDict["image_type"] = image_type
                if isCustomRoomExists
                {
                    imageUploadDict["room_id"] = 0
                    imageUploadDict["room_name"] = customRoomName
                }
                else
                {
                    imageUploadDict["room_id"] = room_id
                    imageUploadDict["room_name"] = room_name
                }
                imageUploadDict["image_name"] = image_name
                imageUploadDict["data_completed"] = 0
               
                imageUploadDictArray.append(imageUploadDict)
                //initials
                let applicantInitialsImageName = appointment.applicantInitialsImage
                image_type = "applicant_initial"
                room_id = room?.room_id
                image_name = (applicantInitialsImageName ?? "")
                //file = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: image_name)
                imageUploadDict = [:]
                imageUploadDict["appointment_id"] = appointmentId
                imageUploadDict["image_type"] = image_type
                if isCustomRoomExists
                {
                    imageUploadDict["room_id"] = 0
                    imageUploadDict["room_name"] = customRoomName
                }
                else
                {
                    imageUploadDict["room_id"] = room_id
                    imageUploadDict["room_name"] = room_name
                }
                imageUploadDict["image_name"] = image_name
                imageUploadDict["data_completed"] = 0
                imageUploadDictArray.append(imageUploadDict)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return imageUploadDictArray
    }
    
    func getCoApplicantSignatureForApiCall() -> [[String:Any]]{
        var imageUploadDictArray: [[String:Any]] = []
        var customRoomName:String = String()
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            if let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId).first{
                let room = appointment.rooms.first
                let coApplicantSignatureImageName = appointment.coApplicantSignatureImage
                let isCustomRoomExists = self.checkIfCustomRoomExists(appointmentId: appointmentId, roomId: String(room?.room_id ?? 0))
                if isCustomRoomExists
                {
                    customRoomName = self.getCustomRoomName(appointmentId: appointmentId, roomId:  String(room?.room_id ?? 0))
                }
                var image_type = "co_applicant_signature"
                var room_id = room?.room_id
                var room_name = room?.room_name
                var image_name = (coApplicantSignatureImageName ?? "")
                var imageUploadDict: [String:Any] = [:]
                if image_name != ""{
                    imageUploadDict["appointment_id"] = appointmentId
                    imageUploadDict["image_type"] = image_type
                    if isCustomRoomExists
                    {
                        imageUploadDict["room_id"] = 0
                        imageUploadDict["room_name"] = customRoomName
                    }
                    else
                    {
                        imageUploadDict["room_id"] = room_id
                        imageUploadDict["room_name"] = room_name
                    }
                    imageUploadDict["image_name"] = image_name
                    imageUploadDict["data_completed"] = 0
                    
                    imageUploadDictArray.append(imageUploadDict)
                }
                //initials
                let coApplicantInitialsImageName = appointment.coApplicantInitialsImage
                image_type = "co_applicant_initial"
                room_id = room?.room_id
                image_name = coApplicantInitialsImageName ?? ""
                if image_name != ""{
                    imageUploadDict = [:]
                    imageUploadDict["appointment_id"] = appointmentId
                    imageUploadDict["image_type"] = image_type
                    if isCustomRoomExists
                    {
                        imageUploadDict["room_id"] = 0
                        imageUploadDict["room_name"] = customRoomName
                    }
                    else
                    {
                        imageUploadDict["room_id"] = room_id
                        imageUploadDict["room_name"] = room_name
                    }
                    imageUploadDict["image_name"] = image_name
                    imageUploadDict["data_completed"] = 0
                    imageUploadDictArray.append(imageUploadDict)
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return imageUploadDictArray
    }
    
    func getSnapShotImagesForApiCall() -> [[String:Any]]{
        var imageUploadDictArray: [[String:Any]] = []
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            appointment.first?.snanpshotImages.forEach({ snapshotImage in
                let image_type = "snapshot"
                let image_name = snapshotImage
                var imageUploadDict: [String:Any] = [:]
                imageUploadDict["appointment_id"] = appointmentId
                imageUploadDict["image_type"] = image_type
                imageUploadDict["room_id"] = 0
                imageUploadDict["image_name"] = image_name
                imageUploadDict["data_completed"] = 0
                imageUploadDictArray.append(imageUploadDict)
            })
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return imageUploadDictArray
    }
    
    func getMoldList() -> RealmSwift.List<rf_master_molding> {
        var moldNamesArray = RealmSwift.List<rf_master_molding>()
        do{
            let realm = try Realm()
            let masterData = realm.objects(MasterData.self)
            if let moldData = masterData.first?.molding_types{
                moldNamesArray = moldData
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return moldNamesArray
    }
    
    func getColorList() -> Results<rf_master_color_list> {
        var colorNamesArray : Results<rf_master_color_list>!
        do{
            let realm = try Realm()
            let colors = realm.objects(rf_master_color_list.self)
            colorNamesArray = colors
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return colorNamesArray
    }
    func getFloorColorList() -> Results<rf_floorColour_results> {
        var colorNamesArray : Results<rf_floorColour_results>!
        do{
            let realm = try Realm()
            let colors = realm.objects(rf_floorColour_results.self)
            colorNamesArray = colors
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return colorNamesArray
    }
    func getStairColorList() -> Results<rf_stairColour_results> {
        var colorNamesArray : Results<rf_stairColour_results>!
        do{
            let realm = try Realm()
            let colors = realm.objects(rf_stairColour_results.self)
            colorNamesArray = colors
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return colorNamesArray
    }
    
    func getDiscountList() -> RealmSwift.List<rf_master_discount> {
        var discountCouponsArray = RealmSwift.List<rf_master_discount>()
        do{
            let realm = try Realm()
            let masterData = realm.objects(MasterData.self)
            if let discountCoupons = masterData.first?.discount_coupons{
                discountCouponsArray = discountCoupons
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return discountCouponsArray
    }
    func getPromoDropDownValue() -> RealmSwift.List<rf_promotionCodes_results> {
        var discountCouponsArray = RealmSwift.List<rf_promotionCodes_results>()
        do{
            let realm = try Realm()
            let masterData = realm.objects(MasterData.self)
            if let discountCoupons = masterData.first?.promotionCodes{
                discountCouponsArray = discountCoupons
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return discountCouponsArray
    }
    
    func externalCredentialsValue() -> RealmSwift.List<rf_extrenal_credential_results>
    {
        var externalCredentialArray = RealmSwift.List<rf_extrenal_credential_results>()
        do
        {
            let realm = try Realm()
            let masterData = realm.objects(MasterData.self)
            if let credentialArray = masterData.first?.external_credentials
            {
                externalCredentialArray = credentialArray
            }
        }
        catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return externalCredentialArray
    }
    func getAptResultReason() -> RealmSwift.List<rf_appointment_result_reasons_results> {
        var AppointmentResultReasonArray = RealmSwift.List<rf_appointment_result_reasons_results>()
        do{
            let realm = try Realm()
            let masterData = realm.objects(MasterData.self)
            if let AppointmentResultReason = masterData.first?.appointment_result_reasons{
                AppointmentResultReasonArray = AppointmentResultReason
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return AppointmentResultReasonArray
    }
    func getTransitionheightDropDownValue() -> RealmSwift.List<rf_transitionHeights_results> {
        var discountCouponsArray = RealmSwift.List<rf_transitionHeights_results>()
        do{
            let realm = try Realm()
            let masterData = realm.objects(MasterData.self)
            if let discountCoupons = masterData.first?.transitionHeights{
                discountCouponsArray = discountCoupons
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return discountCouponsArray
    }
    
    func getDiscountArrayToSend() -> [DiscountObject]{
        var discountsArray : [DiscountObject] = []
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            let discountData = realm.objects(DiscountObject.self).filter("appointment_id == %d", appointmentId)
            let discounts = discountData.toArray(ofType: DiscountObject.self)
            if discounts.count > 0{
                discountsArray = discounts
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return discountsArray
    }
    
    func getScreenCompletionArrayToSend() -> [[String:String]]{
        var screenCompletionArray : [[String:String]] = []
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let screenCompletionData = realm.objects(ScreenCompletion.self).filter("appointment_id == %d",appointmentId)
            screenCompletionData.forEach { screenCompletionTimeObj in
                let screenName = screenCompletionTimeObj.displayName ?? ""
                let screenCompletionTime = screenCompletionTimeObj.completionTime ?? ""
                let screenCompletionDict = ["screen_name":screenName,"completion_time":screenCompletionTime]
                screenCompletionArray.append(screenCompletionDict)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return screenCompletionArray
    }
    
    func deleteDiscountArrayFromDb(){
        do{
            let realm = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            try realm.write{
                let discountData = realm.objects(DiscountObject.self).filter("appointment_id == %d", appointmentId)
                if discountData.count > 0 {
                    discountData.forEach { discount in
                        realm.delete(discount)
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
    }
    
    func saveRealmArray(_ objects: [Object]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(objects)
        }
    }
    
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
    func getTodayWeekDay()-> String{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let weekDay = dateFormatter.string(from: (AppDelegate.appoinmentslData.appointment_date?.logDate())!)
            return weekDay
      }
    
    func getAppointmentResultToShow(className: String,isNextBtn:Bool) -> RealmSwift.List<rf_master_appointments_results_demoedNotDemoed>{
        let classOrderTuple = [(index:1,name:"Customer1",class_Name: "CustomerDetailsOneViewController"),(index:2,name:"Customer2",class_Name: "CustomerDetailsTowViewController"),(index:3,name:"RoomSelection",class_Name: "SelectARoomViewController"),(index:4,name:"RoomDrawing",class_Name: "CustomShapeLineViewController"),(index:5,name:"RoomImageUploading",class_Name: "AboutRoomViewController"),(index:6,name:"RoomQuestionnaire",class_Name: "FurnitureQustionsViewController"),(index:7,name:"RoomMeasurementSummary",class_Name: "SummeryDetailsViewController"),(index:8,name:"MeasurementList",class_Name: "SummeryListViewController"),(index:9,name:"PaymentOption",class_Name: "PaymentOptionsNewViewController"),(index:10,name:"DownFinalPayment",class_Name: "DownFinalPaymentViewController"),(index:11,name:"PaymentSummary",class_Name: "PaymentDetailsViewController"),(index:12,name:"ApplicantInformation",class_Name: "ApplicantFormViewControllerForm"),(index:13,name:"CoApplicantInformation",class_Name: "CoApplicantFormViewControllerForm"),(index:14,name:"OtherIncomeObligation",class_Name: "OtherIncomeViewControllerForm"),(index:15,name:"Signature",class_Name: "SignatureSubmitViewController"),(index:16,name:"CollectDownPayment",class_Name: "DownPaymentViewController"),(index:17,name:"CancellationPolicy",class_Name: "CancellationPolicyViewController"),(index:18,name:"ContractDocument",class_Name: "WebViewViewController")]
        let realm  = try! Realm()
        let appointmentId = AppointmentData().appointment_id ?? 0
        let appointmentResults = realm.objects(rf_master_appointments_results_demoedNotDemoed.self).filter("appointmentId == %d",appointmentId)
        if let currentClassTuple = classOrderTuple.filter({$0.class_Name == className}).first{
            for appointment in appointmentResults
            {
                
            if appointment.appointmentId == appointmentId
            {
                let appointmentResultsFiltered = appointment.result ?? "" == "Not Demoed" && appointment.islastAvailableScreen == false && appointment.appointmentId == appointmentId
                
            if appointmentResultsFiltered == true{
                let notDemoedVC_name = appointment.lastAvailableScreen ?? ""
                if let notDemoedVC = classOrderTuple.filter({$0.name == notDemoedVC_name}).first{
                    let notDemoedVCIndex = notDemoedVC.index
                    let currentClassIndex = currentClassTuple.index
//                    if currentClassIndex == notDemoedVCIndex
//                    {
//
//                        let realm = try! Realm()
//
//
//                                let discountData = realm.objects(rf_master_appointments_results_demoedNotDemoed.self).filter("id == %d AND appointmentId == %d ", 2,appointmentId)
//                                if let thisResult = discountData.first
//                                {
//                                    try! realm.write{
//                                        thisResult.islastAvailableScreen = true
//                                    }
//                                }
//
//                       return realmResultToListConverter(appointmentResults: appointmentResults)
//                    }
                    if isNextBtn == true
                    {
                        if appointment.islastAvailableScreen == false
                        {
                        let realm = try! Realm()
                        
                        
                        let discountData = realm.objects(rf_master_appointments_results_demoedNotDemoed.self).filter("id == %d AND appointmentId == %d ", 2,appointmentId)
                        if let thisResult = discountData.first
                        {
                            try! realm.write{
                                thisResult.islastAvailableScreen = true
                            }
                        }
                        
                        return realmResultToListConverter(appointmentResults: appointmentResults)
                        }
                    }
                     if currentClassIndex > notDemoedVCIndex{
                         if appointment.islastAvailableScreen == false
                         {
                         let realm = try! Realm()
                         
                         
                         let discountData = realm.objects(rf_master_appointments_results_demoedNotDemoed.self).filter("id == %d AND appointmentId == %d ", 2,appointmentId)
                         if let thisResult = discountData.first
                         {
                             try! realm.write{
                                 thisResult.islastAvailableScreen = true
                             }
                         }
                         
                         return realmResultToListConverter(appointmentResults: appointmentResults)
                         }
                         else
                         {
                             let result = RealmSwift.List<rf_master_appointments_results_demoedNotDemoed>()
                             result.removeAll()
                 //                        let realm = try! Realm()
                 //                        let demoedNotSoldAppointResultArr = realm.objects(rf_master_appointment_results.self).filter("result != %@", "Not Demoed")
                         let demoedNotSoldAppointResult = appointmentResults.filter({$0.result ?? "" != "Not Demoed" && $0.result ?? "" == "Not Demoed"})
                             result.append(demoedNotSoldAppointResult.first ?? rf_master_appointments_results_demoedNotDemoed())
                             return result
                         }
                    }
                    else if currentClassIndex == notDemoedVCIndex
                    {
                        if appointment.islastAvailableScreen == true
                        {
                            return realmResultToListConverter(appointmentResults: appointmentResults)
                        }
                        else if isNextBtn == false && appointment.islastAvailableScreen == false
                        {
                            return realmResultToListConverter(appointmentResults: appointmentResults)
                        }
                        
                    }
                    else if currentClassIndex < notDemoedVCIndex{
                        if appointment.islastAvailableScreen == true
                        {
                        let result = RealmSwift.List<rf_master_appointments_results_demoedNotDemoed>()
                        result.removeAll()
//                        let realm = try! Realm()
//                        let demoedNotSoldAppointResultArr = realm.objects(rf_master_appointment_results.self).filter("result != %@", "Not Demoed")
                        let demoedNotSoldAppointResult = appointmentResults.filter({$0.result ?? "" != "Not Demoed"})
                        result.append(demoedNotSoldAppointResult.first ?? rf_master_appointments_results_demoedNotDemoed())
                        return result
                        }
                        else
                        {
                            return realmResultToListConverter(appointmentResults: appointmentResults)
                        }
                    }
                }
            }
        }
//                else
//                {
//                    
//                }
        }
        }
        
//
//            let result = RealmSwift.List<rf_master_appointments_results_demoedNotDemoed>()
//            result.removeAll()
////                        let realm = try! Realm()
////                        let demoedNotSoldAppointResultArr = realm.objects(rf_master_appointment_results.self).filter("result != %@", "Not Demoed")
//        let demoedNotSoldAppointResult = appointmentResults.filter({$0.result ?? "" != "Not Demoed"})
//            result.append(demoedNotSoldAppointResult.first ?? rf_master_appointments_results_demoedNotDemoed())
        //let realm = try! Realm()
        
        
        let discountData = realm.objects(rf_master_appointments_results_demoedNotDemoed.self).filter("id == %d AND appointmentId == %d ", 2,appointmentId)
        if let thisResult = discountData.first
        {
            try! realm.write{
                thisResult.islastAvailableScreen = true
            }
        }
        
        return realmResultToListConverter(appointmentResults: appointmentResults)
            //return result
   //     return realmResultToListConverter(appointmentResults: appointmentResults)

        //return appointmentResults
    }
    
}
func realmResultToListConverter(appointmentResults:Results<rf_master_appointments_results_demoedNotDemoed>) -> RealmSwift.List<rf_master_appointments_results_demoedNotDemoed>
{
    let resultValue = RealmSwift.List<rf_master_appointments_results_demoedNotDemoed>()
    for results in appointmentResults
    {
        if results.islastAvailableScreen == false
        {
        resultValue.append(results)
        }
        
        
    }
    return resultValue
}

enum OfflineImageType: String{
    case floorColor = "FloorColor"
    case stairColor = "StairColor"
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}

//extension Object {
//    func toDictionary() -> [String: Any] {
//        let properties = self.objectSchema.properties.map { $0.name }
//        var mutabledic = self.dictionaryWithValues(forKeys: properties)
//        for prop in self.objectSchema.properties as [Property] {
//            // find lists
//            if let nestedObject = self[prop.name] as? Object {
//                mutabledic[prop.name] = nestedObject.toDictionary()
//            } else if let nestedListObject = self[prop.name] as? RLMSwiftCollectionBase {
//                var objects = [[String: Any]]()
//                for index in 0..<nestedListObject._rlmCollection.count  {
//                    let object = nestedListObject._rlmCollection[index] as! Object
//                    objects.append(object.toDictionary())
//                }
//                mutabledic[prop.name] = objects
//            }
//        }
//        return mutabledic
//    }
//}


extension RealmCollection
{
    func toArray<T>() ->[T]
    {
        return self.compactMap{$0 as? T}
    }
}

extension String
{
    

    public func getViewController() -> UIViewController? {
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            if let viewControllerType = Bundle.main.classNamed("\(appName).\(self)") as? UIViewController.Type {
                return viewControllerType.init()
            }
        }
        return nil
    }
    func setAttributedString(normalFont:UIFont,attractedFont:UIFont,normalColour:UIColor,attractedColor:UIColor,startingPoint:Int,length:Int) -> NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(string: self, attributes: [
            .font: normalFont,
            .foregroundColor: normalColour
        ])
        
        attributedString.addAttributes([
            .font: attractedFont,
            .foregroundColor: attractedColor
        ], range: NSRange(location: startingPoint, length: length))
        return attributedString
    }
    
    var html2AttributedString: NSAttributedString?
    {
        do {
            return try NSAttributedString(data: data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    public var withoutHtml: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        return attributedString.string
    }
    
    func dictionaryValue() -> [String: Any]
    {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                return json!
                
            } catch {
                print("Error converting to JSON")
            }
        }
        return NSDictionary() as! [String : Any]
    }
    
}


extension NSDictionary{
    func JsonString() -> String
    {
        do{
            let jsonData: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String.init(data: jsonData, encoding: .utf8)!
        }
        catch
        {
            return "error converting"
        }
    }
}

extension UITableView{
    func ReloadWithHightIncrease(_ NoOfRows:Int ,_ RowHight:Int,_ HightConstrain:NSLayoutConstraint ){
        HightConstrain.constant = CGFloat(NoOfRows * RowHight)
        self.reloadData()
    }
    func reloadWithNodataMessage(_ label:UILabel,_ rowCount:Int)
    {
        var isTableHide = false
        var isLabelHide = true
        if(rowCount <= 0)
        {
            isTableHide = true
            isLabelHide = false
        }
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.isHidden = isTableHide
            label.isHidden = isLabelHide
        }) { (_) in
            self.reloadData()
        }
    }
}



extension Date {
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    func isBetween(date date1: Date, andDate date2: Date) -> Bool
    {
            //return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
        //return (min(date1, date2) ... max(date1, date2)).contains(self)
        //return date1.timeIntervalSince1970 < self.timeIntervalSince1970 && date2.timeIntervalSince1970 > self.timeIntervalSince1970
                return (min(date1, date2) ... max(date1, date2)) ~= self
        }
    
    func toString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    func appointmentDateStr() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd MMM hh:mm a"
        return formatter2.string(from: self) ?? ""
       
    }
    func currentTimeMillis() -> Int64 {
            return Int64(self.timeIntervalSince1970 * 1000)
        }
    func dateToString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: self)
    }
    func autoLogoutdateToString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datestr =  dateFormatter.string(from: self)
        datestr = dateFormatter.string(from: self.DateOnly(datestr: datestr))
        return datestr
    }
    
}
extension String
{
    
    func validateEmail() -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
        
    }
    func validatePhone() -> Bool
    {
        return self.count > 9 && self.count < 18
    }
    func removeUnvantedcharactoes() ->String
    {
        var str : NSString = self as NSString
        str = str.replacingOccurrences(of: "(", with: "") as NSString
        str = str.replacingOccurrences(of: ")", with: "") as NSString
        str = str.replacingOccurrences(of: "-", with: "") as NSString
        str = str.replacingOccurrences(of: "+", with: "") as NSString
        str = str.replacingOccurrences(of: ".", with: "") as NSString
        str = str.replacingOccurrences(of: "'", with: "") as NSString
        str = str.replacingOccurrences(of: " ", with: "") as NSString
        return str as String
    }
    func removeUnvantedcharactoesUnerScore() ->String
    {
        var str : NSString = self as NSString
        str = str.replacingOccurrences(of: "(", with: "") as NSString
        str = str.replacingOccurrences(of: ")", with: "") as NSString
        str = str.replacingOccurrences(of: "+", with: "") as NSString
        str = str.replacingOccurrences(of: ".", with: "") as NSString
        str = str.replacingOccurrences(of: "'", with: "") as NSString
        str = str.replacingOccurrences(of: " ", with: "") as NSString
        return str as String
    }
    func DateFromStringForServerLeave() -> Date
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter2.date(from: self) ?? Date()
    }
    
    func VaildDateFromStringForServerLeave() -> Bool
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd MMM hh:mm a"
        if formatter2.date(from: self) != nil {
            return true
        } else {
            return false
        }
    }
    
    func installerDate(installationDate:String) -> String
    {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormat.date(from: installationDate)
        dateFormat.dateFormat = "dd MMM yyyy"
        return dateFormat.string(from: dateObj!)
    }
    
    func getInstallerWeekDay(installerDate:Date)-> String{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let weekDay = dateFormatter.string(from: installerDate)
            return weekDay
      }
    
}
extension UIImageView
{
    func loadImageFormWeb(_ url:URL?)
    {
        
        self.sd_addActivityIndicator()
        self.sd_showActivityIndicatorView()
        self.sd_setImage(with: url, placeholderImage: UIImage(named: "profilePic"))
        
    }
    func loadImageFormWebForNotification(_ url:URL?)
    {
        self.sd_addActivityIndicator()
        self.sd_showActivityIndicatorView()
        self.sd_setImage(with: url, placeholderImage: UIImage(named: "NotificationPlaceHolder"))
        
    }
    func loadLogoImageFromUrl(url:String){
        self.contentMode = .scaleAspectFit
        self.sd_addActivityIndicator()
        self.sd_showActivityIndicatorView()
        self.sd_setImage(with: URL(string: url) , placeholderImage: UIImage(named: "tabLogo"))
    }
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
extension UIImage {
    /*
     @brief decode image base64
     */
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
    
    
    func JpgImagetoBase64() -> String{
        let imageData = self.jpegData(compressionQuality: 1)!
        return imageData.base64EncodedString()
    }
    func PngImagetoBase64() -> String{
        let imageData = self.pngData()!
        return imageData.base64EncodedString()
    }
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resizedWell() -> UIImage? {
        var canvas = self.size
        if(self.size.width > 1500 )
        {
            //          canvas = CGSize(width: 1000, height: 750)
        }
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    static func decodeBase64(toImage strEncodeData: String!) -> UIImage {
        
        
        
        if let decData = Data(base64Encoded: strEncodeData, options: .ignoreUnknownCharacters), strEncodeData.count > 0 {
            return UIImage(data: decData) ?? UIImage()
        }
        return UIImage()
    }
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
extension Date{
    func logDataAsString() -> String{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM hh:mm:ss a"
        formatter1.amSymbol = "AM"
        formatter1.pmSymbol = "PM"
        return formatter1.string(from: self)
    }
   
    func getSyncDateAsString() -> String{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter1.string(from: self)
    }
    func getMasterDataSyncDateAsString() -> String{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return formatter1.string(from: self)
    }
    
    func getCompletedDateStringAndTimeZone() -> (date:String,timeZone:String){
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter1.string(from: self)
        let timeZone = TimeZone.current.abbreviation()!
        return (dateStr,timeZone)
    }
    
    func dateconverterForDaily(_ dateString:String ) ->String
    {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        let dates = formatter2.date(from: dateString)
        if(dates != nil)
        {
            return formatter1.string(from: dates!)
        }
        else
        {
            return dateString
        }
    }
    
    func dateconverterForWeekly(_ dateString:String ) ->String{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd(EE)"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        let dates = formatter2.date(from: dateString)
        if(dates != nil)
        {
            return formatter1.string(from: dates!)
        }
        else
        {
            return dateString
        }
    }
    func dateconverterForMonthly(_ dateString:String ) ->String{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        let dates = formatter2.date(from: dateString)
        if(dates != nil)
        {
            return formatter1.string(from: dates!)
        }
        else
        {
            return dateString
        }
    }
    
    func dateconverter(_ dateString:String ) ->String{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM (EE) yyyy"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        let dates = formatter2.date(from: dateString)
        if(dates != nil)
        {
            return formatter1.string(from: dates!)
        }
        else
        {
            return dateString
        }
    }
    func dateForApproval(_ dateString:String) ->String
    {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM yyyy (EE)"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd/MM/yyyy"
        let dates = formatter2.date(from: dateString)
        if(dates != nil)
        {
            return formatter1.string(from: dates!)
        }
        else
        {
            return "__ __, __"
        }
    }
    func dateconverterForSummery(_ dateString:String) ->String{
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd MMM yyyy (EE)"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        let dates = formatter2.date(from: dateString)
        if(dates != nil)
        {
            return formatter1.string(from: dates!)
        }
        else
        {
            return "__ __, __"
        }
    }
    func DateFromString(_ dateString:String) -> Date
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        return formatter2.date(from: dateString)!
    }
    func DateFromStringForServer() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MM/dd/yyyy"//"yyyy-dd-MM"
        return formatter2.string(from: self)
    }
    func SignatureDate() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd"
        return formatter2.string(from: self)
    }
    func DateFromStringForServerRefloor() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MM-dd-YYYY"
        return formatter2.string(from: self)
    }
    
    
    
    
    func DateForCaleder() -> String {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd MMM (EE)"
        return formatter2.string(from: self)
    }
    func DateFromStringForAppStatus() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "EEEE dd MMM"
        return formatter2.string(from: self)
    }
    func DateFromStringForCardExpry() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MM/YY"
        return formatter2.string(from: self)
    }
    func DateFromStringForLocalMSG() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd MMM (EE)"
        return formatter2.string(from: self)
    }
    func DateFromStringForLocal() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd MMM (EE) yyyy"
        return formatter2.string(from: self)
    }
    func DateFromStringForServerLeave() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter2.string(from: self)
    }
    func DateFromStringForServerLeave2() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter2.string(from: self)
    }
    func DateFromStringForServerNotication() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        return formatter2.string(from: self)
    }
    func DateFromStringMonthDate() -> String
    {
        let formatter2 = DateFormatter()
        // formatter2.dateFormat = "YYYY-MM-dd"
        formatter2.dateFormat = "MM/dd/YYYY"
        return formatter2.string(from: self)
    }
    func TimeOnly() -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "h:mm a"
        return formatter2.string(from: self)
    }
    func TimeOnlyForCustomerList(datestr:String) -> String
    {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd HH:mm:ss"
        if let dateserver = formatter2.date(from: datestr)
        {
            return dateserver.TimeOnly()
        }
        return "Not Available"
    }

    
    func upcommingCurrentPastFinder(datestr:String) -> Int
    {
        var passtring = 0
        let serverFormatter = DateFormatter()
        if(datestr != "")
        {
            
            let fornowdate = datestr + " 00:00:00"
            
            serverFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            if let dateserver = serverFormatter.date(from: fornowdate)
            {
                let dateOnlyserver = serverFormatter.date(from: fornowdate)!
                let todayDate = serverFormatter.date(from:"\(serverFormatter.string(from: Date()).split(separator: " ")[0] + " 00:00:00")")!
                if(todayDate>dateOnlyserver)
                {
                    passtring = 2
                }
                else if(todayDate == dateOnlyserver)
                {
                    passtring = 1
                }
                else
                {
                    passtring = 0
                }
                return passtring
            }
        }
        return passtring
    }
    
    
    
    func DateForStatus(datestr:String) -> String
    {
        var passtring = ""
        let serverFormatter = DateFormatter()
        if(datestr != "")
        {
            let datstr = String(datestr.split(separator: "T")[0]) + " " + String(String(datestr.split(separator: "T")[1]).split(separator: ".")[0])
            let fornowdate = String(datestr.split(separator: "T")[0]) + " 00:00:00"
            
            serverFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            if let dateserver = serverFormatter.date(from: datstr)
            {
                let dateOnlyserver = serverFormatter.date(from: fornowdate)!
                let todayDate = serverFormatter.date(from:"\(serverFormatter.string(from: Date()).split(separator: " ")[0] + " 00:00:00")")!
                if(todayDate>dateOnlyserver)
                {
                    if(todayDate.PrevoisDateCount(num: 1) == dateOnlyserver)
                    {
                        passtring = "Yesterday" + dateserver.TimeOnly()
                    }
                    else
                    {
                        passtring = dateserver.DateFromStringForAppStatus()
                    }
                }
                else if(todayDate == dateOnlyserver)
                {
                    passtring = "Today" + dateserver.TimeOnly()
                }
                else
                {
                    passtring = dateserver.DateFromStringForAppStatus()
                }
                return passtring
            }
        }
        return passtring
    }
    
    
    func DateForChat(datestr:String) -> String
    {
        var passtring = ""
        let serverFormatter = DateFormatter()
        if(datestr != "")
        {
            let datstr = "\(datestr.split(separator: " ")[0])" + " 00:00:00"
            
            serverFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            if let dateserver = serverFormatter.date(from: datestr)
            {
                let dateOnlyserver = serverFormatter.date(from: datstr)!
                let todayDate = serverFormatter.date(from:"\(serverFormatter.string(from: Date()).split(separator: " ")[0] + " 00:00:00")")!
                if(todayDate>dateOnlyserver)
                {
                    if(todayDate.PrevoisDateCount(num: 1) == dateOnlyserver)
                    {
                        passtring = "Yesterday" + dateserver.TimeOnly()
                    }
                    else
                    {
                        passtring = dateserver.DateFromStringForLocalMSG()
                    }
                }
                else if(todayDate == dateOnlyserver)
                {
                    passtring = "Today" + dateserver.TimeOnly()
                }
                else
                {
                    passtring = dateserver.DateFromStringForLocalMSG()
                }
                return passtring
            }
        }
        return passtring
    }
    func compareTimeToAutoLogout(firstTime:String,secondTime:String) -> Bool
     {
         let formatter = DateFormatter()
           formatter.dateFormat = "HH:mm:ss"
         var firstDate = Calendar.current.dateComponents([.hour,.minute,.second], from: formatter.date(from: firstTime)!)//formatter.date(from: firstTime)
           var secondDate = Calendar.current.dateComponents([.hour,.minute,.second], from: formatter.date(from: secondTime)!)
         if secondDate.hour == 00
         {
             secondDate.hour = 24
         }
         if firstDate.hour == 00
         {
             firstDate.hour = 24
         }
         if firstDate.hour! < secondDate.hour!
         {
             return true
         }
         else if firstDate.hour == secondDate.hour
         {
             if firstDate.minute! < secondDate.minute!
             {
                 return true
             }
             else if firstDate.minute == secondDate.minute
             {
                 
                 return true
                 
             }
             else
             {
                 return false
             }
         }
         else
         {
             return false
         }
     }

    func DateOnly(datestr:String) -> Date {
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "YYYY-MM-dd"
        let date = formatter2.date(from: datestr) ?? Date()
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
    }
    func PreviosMounthDate() -> Date
    {
        let toDate =  self
        let fromDate = Calendar.current.date(byAdding: .month, value: -1, to: toDate)
        return fromDate!
    }
    func PreviosDate() -> Date
    {
        let toDate =  self
        let fromDate = Calendar.current.date(bySetting: .day, value: -1, of: toDate)
        let date =  Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: fromDate!)
        return date!
    }
    func PrevoisDateCount(num:Int) -> Date
    {
        let toDate =  self
        let fromDate = Calendar.current.date(byAdding: .day, value: 0 - num, to: toDate)
        return fromDate!
    }
    
    
}

extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
class MyLeftCustomFlowLayout:UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = 2.0
        
        let horizontalSpacing:CGFloat = 5
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY
                || layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            }
            
            if layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            }
            else {
                layoutAttribute.frame.origin.x = leftMargin
            }
            
            leftMargin += layoutAttribute.frame.width + horizontalSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}
class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        // Copy each item to prevent "UICollectionViewFlowLayout has cached frame mismatch" warning
        guard let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
        // Constants
        let leftPadding: CGFloat = 8
        let interItemSpacing = minimumInteritemSpacing
        
        // Tracking values
        var leftMargin: CGFloat = leftPadding // Modified to determine origin.x for each item
        var maxY: CGFloat = -1.0 // Modified to determine origin.y for each item
        var rowSizes: [[CGFloat]] = [] // Tracks the starting and ending x-values for the first and last item in the row
        var currentRow: Int = 0 // Tracks the current row
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute represents its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Register its origin.x in rowSizes for use later
                if rowSizes.count == 0 {
                    // Add to first row
                    rowSizes = [[leftMargin, 0]]
                } else {
                    // Append a new row
                    rowSizes.append([leftMargin, 0])
                    currentRow += 1
                }
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
            
            // Add right-most x value for last item in the row
            rowSizes[currentRow][1] = leftMargin - interItemSpacing
        }
        
        // At this point, all cells are left aligned
        // Reset tracking values and add extra left padding to center align entire row
        leftMargin = leftPadding
        maxY = -1.0
        currentRow = 0
        attributes.forEach { layoutAttribute in
            
            // Each layoutAttribute is its own item
            if layoutAttribute.frame.origin.y >= maxY {
                
                // This layoutAttribute represents the left-most item in the row
                leftMargin = leftPadding
                
                // Need to bump it up by an appended margin
                let rowWidth = rowSizes[currentRow][1] - rowSizes[currentRow][0] // last.x - first.x
                let appendedMargin = (collectionView!.frame.width - leftPadding  - rowWidth - leftPadding) / 2
                leftMargin += appendedMargin
                
                currentRow += 1
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}
//extension UIView {
//    func traverseRadius(_ radius: Float) {
//        layer.cornerRadius = CGFloat(radius)
//
//        for subview: UIView in subviews {
//            subview.traverseRadius(radius)
//        }
//    }
//}

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone15,4":                                    return "iPhone 15"
            case "iPhone15,5":                                    return "iPhone 15 Plus"
            case "iPhone16,1":                                    return "iPhone 15 Pro"
            case "iPhone16,2":                                    return "iPhone 15 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
