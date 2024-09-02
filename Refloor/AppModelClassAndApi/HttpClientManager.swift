

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SystemConfiguration
import RealmSwift
//import Firebase
enum SHOWHIDEHUD {
    case SHOW
    case HIDE
}

class HttpClientManager: NSObject {
    
    
    
    
    //MARK: - Shared Instance
    
    static let SharedHM = HttpClientManager()
    
    
    //MARK: - API Keys
    
    let LoginAPIKeys: NSArray = ["emailAddress","phoneNumber","salesId","userId"]
    
    //MARK:- Internet
    
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            //   self.showNetworkAlert(message: AppAlertMsg.NetWorkAlertMessage)
            return false
        }
        var flags : SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            // self.showNetworkAlert(message: AppAlertMsg.NetWorkAlertMessage)
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        if (isReachable && !needsConnection)
        {
            return true
        }
        else
        {
            //   self.showNetworkAlert(message: AppAlertMsg.NetWorkAlertMessage)
            return false
        }
    }
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
    func showhideHUDDark(viewtype: SHOWHIDEHUD,title: String)
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
    
    //MARK:- get Device Token
    
    func getDeviceToken() -> String {
        
        if (UserDefaults.standard.object(forKey:  "deviceToken") != nil) {
            return UserDefaults.standard.string(forKey: "deviceToken")!
        }
        return Defaults.defaultDEVICETOCKEN
        
    }
    struct Defaults
    {
        static let defaultDEVICETOCKEN = "DEVICETOCKEN"
        
    }
    
    func getFireBaseKey() -> String {
        
        if (UserDefaults.standard.object(forKey:  "FIR") != nil) {
            return UserDefaults.standard.string(forKey: "FIR")!
        }
        return "FIREBASE"
        
    }
    //MARK: - Device Type
    
    
    
    
    
    
    //MARK: - User Authentication
    func Authentication(usernae:String,password:String,completion:@escaping (_ success: String?, _ object: String?,_ user_details : [UserLoginDataValue]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Authentication is being processed. Please wait...")
            
            let URL = AppURL().authenticate
            print(URL)
            //let regid = UIDevice.current.identifierForVendor!.uuidString
            let fcmToken = UserDefaults.standard.string(forKey: "fireBaseToken") as! String
            let isoffline = 1
            
            //            if(regid == "")
            //            {
            //                regid = "13131313132112121"
            //            }
            
            let version = ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!)
            let parameters = ["login":usernae,"password":password,"device_reg_id":fcmToken,"restrict_multi_login":isoffline,"device_name":AppDetails.deviceName,"device_os":AppDetails.osVersion,"app_version":version] as [String : Any]
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<UserLoginData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                if response != nil
                {
                    
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.values)
                        
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - AppoinmentList
    
    func getMasterDataFromDB() -> MasterData{
        var masterData:MasterData!
        do{
            let realm = try Realm()
            masterData =  realm.objects(MasterData.self).first
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return masterData
    }
    func AppinmentListApi(completion:@escaping (_ success: String?, _ object: String?,_ user_details : Appointments? ) -> ()){
        print(Realm.Configuration.defaultConfiguration.fileURL)
        if self.connectedToNetwork()
        {
            self.showhideHUD(viewtype: .SHOW, title:"New appointments are being updated. Please wait...")
            
            let URL = AppURL().SalesScheduleList
            
            let parameters = ["token":UserData.init().token ?? ""]
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseJSON { response in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                switch response.result {
                case .success:
                    if response.result.value != nil {
                        let jsonString = String(data: response.data!, encoding: .utf8)!
                        print(jsonString)
                        if let responseData = Appointments(JSONString: jsonString){
                            //print(responseData.appointments[0].id)
                            do{
                                let realm = try Realm()
                                let appointments = realm.objects(Appointments.self)
                                let appointmentObj = realm.objects(rf_master_appointment.self)
                                try realm.write {
                                    realm.delete(appointments)
                                    realm.delete(appointmentObj)
                                }
                            }catch{
                                print(RealmError.writeFailed.rawValue)
                            }
                            
                            do{
                                let realm = try Realm()
                                try realm.write{
                                    let appointmentsFromApi = responseData.appointments
//                                    let masterData = self.getMasterDataFromDB()
//                                    masterData.appointments = appointmentsFromApi
//                                    appo
                                    appointmentsFromApi.forEach { appointment in
                                        if realm.objects(rf_master_appointment.self).filter("id == %d" ,appointment.id).count == 0{
                                            realm.add(appointment)
                                        }
                                    }
                                    //realm.add(responseData)
                                    
//                                    let appointment = Appointments(masterAppointment:responseData.appointments)
//                                    realm.add(appointment)
                                    completion(responseData.result,responseData.message ,responseData)
                                    return
                                }
                            }catch{
                                print(RealmError.writeFailed.rawValue)
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    //sync bhoomi api and update changes on middleware
    func BackendApiSyncCallDirect(){
        
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().Sync_master_data
            
            let parameters = ["token":UserData.init().token ?? ""]
            print("--token---", UserData.init().token ?? "")
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<CommenDataMap>) in
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                print("test", response?.result)
                
                
            }
        }
        
    }
    
    //api for getting appointment resuls list
    func OrderStatustListApi(completion:@escaping (_ success: String?, _ object: String?,_ user_details : OrderStatusDataMap? ) -> ()){
        
        print("Inside OrderStatustListApi: ")
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "The appointment results are being loaded. Please wait...")
            
            let URL = AppURL().get_appointment_result
            
            let parameters = ["token":UserData.init().token ?? ""]
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<OrderStatusDataMap>) in
                
                
                
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response)
                        print("response result1 : ", response?.message)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    
    //api for submitting appointment results whether domoed or sold etc
    func submitOrderStatustListApi(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String? ) -> ()){
        
        print("submitOrderStatusListApi: ", parameter)
        if self.connectedToNetwork() {
            // self.showhideHUD(viewtype: .SHOW, title: "")
            
            // let URL = AppURL().submit_appointment_result
            let URL = AppURL().submit_appointment_result_without_upload
            print("-----URL------", URL)
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataMap>) in
                print("parameters1 : ", parameter)
                // self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    print("submitOrderStatustListApi_result : ", response)
                    completion(response?.result!,response?.message)
                }
                
                
                else
                {
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    func submitOrderStatustUploadData(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String? ) -> ()){
        print("Inside submitOrderStatustUploadData: ")
        
        if self.connectedToNetwork() {
            // self.showhideHUD(viewtype: .SHOW, title: "")
            
            // let URL = AppURL().submit_appointment_result
            let URL = AppURL().submit_appointment_file_upload
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataMap>) in
                
                // self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                _ = response.result.value
                
                
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    //MARK: - SubmitAppointments
    func SubmitAppointmentsApi(parameter:[String:Any],completion:@escaping (_ success: String?, _ object: String?,_ user_details : Int? ) -> ()){
        print("Inside SubmitAppointmentsApi: ")
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Submitting Customer Details. Please wait...")
            
            let URL = AppURL().update_appointments
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                    else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    // MARK: - AttachmentMaping
    func AttachmentsMapFn(_ attachments:UIImage,_ imagename: String,completion:@escaping (_ success: String?, _ object: String?,_ access : [AttachmentDataValue]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Uploading image. Please wait...")
            
            let URL = AppURL().CreateAttachment
            let user = UserData.init()
            let parameters = ["token":user.token ?? ""]
            
            let imageData = attachments.jpegData(compressionQuality: 0.0)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "attachment", fileName: imagename, mimeType: "image/jpeg")
                for (key, value) in parameters
                {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)! , withName: key)
                }
            }, to:URL)
            { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            //print response.result
                            let value = response.result.value
                            let result = Mapper<AttachmentDataMap>().map(JSONObject: value)
                            
                            self.showhideHUD(viewtype: .HIDE, title: "")
                            completion(result?.result,result?.message,result?.values)
                            
                        }
                        break
                    case .failure(let encodingError):
                        self.showhideHUD(viewtype: .HIDE, title: "")
                        completion("false",encodingError.localizedDescription,nil)
                        break
                    //print encodingError.description
                    }}
            }
            
            //            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<AttachmentClass>) in
            //
            //                self.showhideHUD(viewtype: .HIDE, title: "")
            //                print(response.result.value.debugDescription)
            //                let response = response.result.value
            //                if response?.message == nil{
            //                    response?.message = ""
            //                }
            //                if response?.result == nil{
            //                    response?.result = ""
            //                }
            //                if response != nil{
            //                    completion(response?.result,
            //                               response?.message!, response?.atachments)
            //                }
            //                else{
            //                    completion("false", AppAlertMsg.serverNotReached,nil)
            //                }
            //            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    // MARK: - AttachmentScreenShotsFn
    func AttachmentScreenShotsFn(_ attachments:UIImage,_ imagename: String,completion:@escaping (_ success: String?, _ object: String?,_ access : [AttachmentDataValue]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Uploading screen shot image. Please wait...")
            
            let URL = AppURL().uploadScreeshot
          //  var appointmentId = String(AppDelegate.appoinmentslData.id ?? 0)
            let parameters:[String:String] = ["token":UserData.init().token ?? "", "appointment_id":String(AppDelegate.appoinmentslData.id ?? 0)]
            
            let imageData = attachments.jpegData(compressionQuality: 0.0)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "attachment", fileName: imagename, mimeType: "image/jpeg")
                for (key, value) in parameters
                {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)! , withName: key)
                }
            }, to:URL)
            { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            //print response.result
                            let value = response.result.value
                            let result = Mapper<AttachmentDataMap>().map(JSONObject: value)
                            
                            self.showhideHUD(viewtype: .HIDE, title: "")
                            completion(result?.result,result?.message,result?.values)
                            
                        }
                        break
                    case .failure(let encodingError):
                        self.showhideHUD(viewtype: .HIDE, title: "")
                        completion("false",encodingError.localizedDescription,nil)
                        break
                    //print encodingError.description
                    }}
            }
            
            //            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<AttachmentClass>) in
            //
            //                self.showhideHUD(viewtype: .HIDE, title: "")
            //                print(response.result.value.debugDescription)
            //                let response = response.result.value
            //                if response?.message == nil{
            //                    response?.message = ""
            //                }
            //                if response?.result == nil{
            //                    response?.result = ""
            //                }
            //                if response != nil{
            //                    completion(response?.result,
            //                               response?.message!, response?.atachments)
            //                }
            //                else{
            //                    completion("false", AppAlertMsg.serverNotReached,nil)
            //                }
            //            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    //MARK: - transition list
    func TransitionListsApi(parameter:[String:Any],completion:@escaping (_ success: String?, _ object: String?,_ user_details : [TransitionDataValue]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().filter_transitions
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<TransitionListDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.values)
                        
                    }
                    else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - Add Transition
    func AddTransitionApi(parameter:[String:Any],completion:@escaping (_ success: String?, _ object: String?,_ user_details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().add_transitions
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK: - DeleteImage
    func DeleteImageApi(parameter:[String:Any],completion:@escaping (_ success: String?, _ object: String?,_ user_details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Removing image. Please wait...")
            
            let URL = AppURL().UnlinkAttachment
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK: - DeleteImage
    func DeleteTransactionApi(parameter:[String:Any],completion:@escaping (_ success: String?, _ object: String?,_ user_details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().remove_transition
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK: - QustionsListForMessurements
    func QustionsListForMessurementsApi(parameter:[String:Any],completion:@escaping (_ success: String?, _ object: String?,_ user_details : [QuestionsMeasurementData]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().get_measurement_questions
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<QustionDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.questions_measurement)
                        
                    }
                    else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - SubmitContractMessurementsQuestionsApi
    func SubmitContractMessurementsQuestionsApi(parameter:[String:Any],completion:@escaping (_ success: String?, _ object: String?,_ user_details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Saving Questionnaire details. Please wait...")
            
            let URL = AppURL().add_contract_measurement_questions
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject
            { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    
    
    //MARK: - MesurementSubmit
    func MesurementSubmitMapFn(room_area:String,perimeter:Float,attachments:UIImage,imagename: String,floor_id:String,room:RoomDataValue,appointment_id:String,trasData:[TransitionData],completion:@escaping (_ success: String?, _ object: String?,_ access : Int?,_ details : [SummeryDetailsData]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Submitting measurement details. Please wait...")
            
            
            let a = trasData.indices.contains(0) ? String(trasData[0].transsquarefeet!) : ""
            
            let URL = AppURL().add_contract_room_measurement
            let user = UserData.init()
            //var parameters:[String:String] = ["token":user.token ?? "","room_area":room_area,"floor_id":floor_id,"room_id":"\(room.id ?? 0)","appointment_id":appointment_id,"room_perimeter":"\(perimeter)"]
            var parameters:[String:String] = ["token":user.token ?? "","room_area":room_area,"floor_id":floor_id,"room_id":"\(room.id ?? 0)","appointment_id":appointment_id,"room_perimeter":"\(perimeter)","transition1_name":trasData.indices.contains(0) ? trasData[0].name! : "","transition2_name":trasData.indices.contains(1) ? trasData[1].name! : "","transition3_name":trasData.indices.contains(2) ? trasData[2].name! : "","transition4_name":trasData.indices.contains(3) ? trasData[3].name! : "","transition1_width":trasData.indices.contains(0) ? String(trasData[0].transsquarefeet!) : "","transition2_width":trasData.indices.contains(1) ? String(trasData[1].transsquarefeet!) : "","transition3_width":trasData.indices.contains(2) ? String(trasData[2].transsquarefeet!) : "","transition4_width":trasData.indices.contains(3) ? String(trasData[3].transsquarefeet!) : ""]
            
            if (room.is_custom_room == "True") || room.custom_room_measurement_id != nil
            {
                parameters = ["token":user.token ?? "","room_area":room_area,"floor_id":floor_id,"room_id":"\(room.id ?? 0)","appointment_id":appointment_id,"room_measurement_id":"\(room.custom_room_measurement_id ?? 0)","room_perimeter":"\(perimeter)"]
            }
            
            
            let imageData = attachments.jpegData(compressionQuality: 0.4)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "attachment", fileName: imagename, mimeType: "image/jpeg")
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)! , withName: key)
                }
            }, to:URL)
            { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            //print response.result
                            let value = response.result.value
                            let result = Mapper<MessuerementDataMap>().map(JSONObject: value)
                            
                            self.showhideHUD(viewtype: .HIDE, title: "")
                            completion(result?.result,result?.message,result?.contract_measurement_id,result?.summeryDetails)
                            
                        }
                        break
                    case .failure(let encodingError):
                        self.showhideHUD(viewtype: .HIDE, title: "")
                        completion("false",encodingError.localizedDescription,nil,nil)
                        break
                    //print encodingError.description
                    }}
            }
            
            //            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<AttachmentClass>) in
            //
            //                self.showhideHUD(viewtype: .HIDE, title: "")
            //                print(response.result.value.debugDescription)
            //                let response = response.result.value
            //                if response?.message == nil{
            //                    response?.message = ""
            //                }
            //                if response?.result == nil{
            //                    response?.result = ""
            //                }
            //                if response != nil{
            //                    completion(response?.result,
            //                               response?.message!, response?.atachments)
            //                }
            //                else{
            //                    completion("false", AppAlertMsg.serverNotReached,nil)
            //                }
            //            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil,nil)
            
        }
    }
    
    
    //MARK: - api for adding stair details
    func StairtSubmitMapFn(floor_id:String,room:RoomDataValue,appointment_id:String,completion:@escaping (_ success: String?, _ object: String?,_ access : Int?,_ details : [SummeryDetailsData]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().add_contract_stair_room_measurement
            let user = UserData.init()
            var parameters:[String:String] = ["token":user.token ?? "","floor_id":floor_id,"room_id":"\(room.id ?? 0)","appointment_id":appointment_id]
            if (room.is_custom_room == "True") || room.custom_room_measurement_id != nil
            {
                parameters = ["token":user.token ?? "","floor_id":floor_id,"room_id":"\(room.id ?? 0)","appointment_id":appointment_id,"room_measurement_id":"\(room.custom_room_measurement_id ?? 0)"]
            }
            
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseObject
            { (response:DataResponse<MessuerementDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil
                {
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message,response?.contract_measurement_id,response?.summeryDetails)
                        
                    }
                    
                    else
                    {
                        completion("false", response?.message,nil,nil)
                    }
                }
                
            }
            
        }
        else
        {
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil,nil)
            
        }
    }
    //MARK: - TilesMaterialListApi
    func TilesMaterialListApi(completion:@escaping (_ success: String?, _ object: String?,_ user_details : [TileMeterailsData]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().material_list
            
            let parameters = ["token":UserData.init().token ?? ""]
            
            Alamofire.request(URL, method: .post, parameters: parameters,encoding: JSONEncoding.default).responseObject { (response:DataResponse<TileMeterailsDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.material_list_data)
                        
                    }else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - TilesMaterialUpdateApi
    func TilesMaterialUpdateApi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ user_details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().update_material
            
            
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message, response?.override_json_result)
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    //MARK: - TilesMaterialListApiviaPaymentPlan
    func TilesMaterialListApiviaPaymentPlan(_ pymentplanID:Int,completion:@escaping (_ success: String?, _ object: String?,_ user_details : [TileMeterailsData]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().material_list
            let data = ["payment_plan_id":pymentplanID]
            let parameters:Parameters = ["token":UserData.init().token ?? "","data":data]
            
            Alamofire.request(URL, method: .post, parameters: parameters,encoding: JSONEncoding.default).responseObject { (response:DataResponse<TileMeterailsDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.material_list_data)
                        
                    }else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - TilesMaterialUpdateApiViaPaymentPlan
    func TilesMaterialUpdateApiViaPaymentPlan(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ user_details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().select_material_from_plan
            
            
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message, response?.override_json_result)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - CreateSalesQuotationAPi
    func CreateSalesQuotationAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ user_details : QuotationApiData? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Payment details is being processed. Please wait...")
            
            let URL = AppURL().create_sale_quotation
            
            
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<QuotationApiData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message, response)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - api for creating sales quotation
    func CreateSalesQuotationForSatusAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ user_details : QuotationApiData? ) -> ()){
        print("Inside CreateSalesQuotationForSatusAPi: ")
        
        if self.connectedToNetwork() {
            // self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().create_sale_quotation
            
            
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<QuotationApiData>) in
                
                // self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message, response)
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - RoomListDetailsApi
    func RoomListDetailsApi(_ appointment_id:Int, completion:@escaping (_ success: String?, _ object: String?,_ details : [RoomDataValue]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Room list is being updated. Please wait...")
            
            let URL = AppURL().RoomsScheduleList
            
            let parameters:Parameters = ["token":UserData.init().token ?? "","appointment_id":appointment_id]
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<RoomDataApiData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.roomData)
                        
                    }else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK: - RoomSummeryDetailsApi
    func RoomSummeryDetailsApi(_ contractroomID:Int, completion:@escaping (_ success: String?, _ object: String?,_ details : [SummeryDetailsData]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Saving room details. Please wait...")
            
            let URL = AppURL().summary_contract_room_measurement_line
            let data = ["contract_room_id":contractroomID]
            let parameters:Parameters = ["token":UserData.init().token ?? "","data":data]
            
            Alamofire.request(URL, method: .post, parameters: parameters,encoding: JSONEncoding.default).responseObject { (response:DataResponse<SummeryDetailsDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.summeryDetails)
                        
                    }else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK: - RoomSummeryListApi
    func RoomSummeryListApi(_ appointment_id:Int, completion:@escaping (_ success: String?, _ object: String?,_ details : [SummeryListData]? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Room Summary is being updated. Please wait...")
            
            let URL = AppURL().list_contract_room_measurement_line
            let data = ["appointment_id":appointment_id]
            let parameters:Parameters = ["token":UserData.init().token ?? "","data":data]
            
            Alamofire.request(URL, method: .post, parameters: parameters,encoding: JSONEncoding.default).responseObject { (response:DataResponse<SummeryListDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.summeryList)
                        
                    }else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK:- UpdateTilesColor
    func UpdateTilesColorApi(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Saving floor color details. Please wait...")
            
            let URL = AppURL().update_material_room
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result!,response?.message)
                }
                
                
                else
                {
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    //MARK:- UpdateMolding
    func UpdateMoldingApi(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Saving molding type details. Please wait...")
            
            let URL = AppURL().update_moulding
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result!,response?.message)
                }
                
                
                else
                {
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    //MARK: - RoomSummeryListApi
    func AddoRommToListApi(appointment_id:Int,room_name:String, completion:@escaping (_ success: String?, _ object: String?,_ details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().add_custom_rooms
            
            let parameters:Parameters = ["token":UserData.init().token ?? "","appointment_id":appointment_id,"room_name":room_name]
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - CheckRoomAvailability
    func CheckRoomAvailability(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?,_ details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().check_room_availability
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                    else
                    {
                        completion("fail", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("fail", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK: - DeleteRoomMeasurement
    func DeleteRoomMeasurement(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?,_ details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            
            self.showhideHUD(viewtype: .SHOW, title: "Updating room status. Please wait...")
            
            let URL = AppURL().delete_room_details
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                    else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    //MARK: - UpdateSummeryDetails
    func UpdateSummeryDetails(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?,_ details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Saving room details. Please wait...")
            
            let URL = AppURL().update_contract_room_measurement
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                    else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - UpdateQustionoriesApi
    func UpdateQustionoriesApi(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?,_ details : Int? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Saving Questionnaire details. Please wait...")
            
            let URL = AppURL().update_contract_measurement_questions
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result!,response?.message, response?.override_json_result)
                        
                    }
                    else
                    {
                        completion("false", AppAlertMsg.serverNotReached,nil)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - api for getting payment plan details
    func GetPaymentListApi(completion:@escaping (_ success: String?,_  object: String?,_ user_details : PaymentApiData? ) -> ()){
        
        print("---packes_start_date----")
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Package detail is being updated. Please wait...")
            
            let URL = AppURL().payment_paln_details
            
            let parameters:Parameters = ["token":UserData.init().token ?? "", "appointment_id":AppDelegate.appoinmentslData.id ?? 0]
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<PaymentApiData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        print("---packes_start_date----", response?.result)
                        completion(response?.result!,response?.message, response)
                        
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    
    //CommenResultForListId
    //MARK: - CreateSalesQuotationAPi
    func PaymentRequestAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ details : String? ) -> ())
    {
        
        
        if self.connectedToNetwork()
        {
            self.showhideHUD(viewtype: .SHOW, title: "The contract document is being generated for signature. Please wait... ")
            
            let URL = AppURL().create_payment_transaction_cash
            
            
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CashData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message, response?.document)
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    
    //MARK: -  api for credit/debit card payment
    func PaymentRequestCardAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ details : String? ) -> ())
    {
        
        
        if self.connectedToNetwork()
        {
            self.showhideHUD(viewtype: .SHOW, title: "The contract document is being generated for signature. Please wait... ")
            
            let URL = AppURL().create_payment_transaction_card
            
            
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CashData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message, response?.document)
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: -  api for check payment
    func PaymentRequestCheckAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ details : String? ) -> ())
    {
        
        
        if self.connectedToNetwork()
        {
            self.showhideHUD(viewtype: .SHOW, title: "The contract document is being generated for signature. Please wait... ")
            
            let URL = AppURL().create_payment_transaction_check
            
            
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CashData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message, response?.document)
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: -  api for checking document status whether signed and validate or not
    func checkDocumentSigned(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?,_ details : String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().check_document_status
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<SignData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result!,response?.message, response?.signed)
                }
                
                
                else
                {
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: -  Not using
    func rejectSalesAppointment(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String? ) -> ()){
        
        print("Inside rejectSalesAppointment: ")
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().propose_reject_quote
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result!,response?.message)
                }
                
                
                else
                {
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    //MARK: -  Not using
    func prposedSalesAppointment(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String? ) -> ()){
        
        print("Inside prposedSalesAppointment: ")
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = AppURL().propose_reject_quote
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result!,response?.message)
                }
                
                
                else
                {
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    //MARK:- RoomDetailsUpdateApi
    func RoomDetailsUpdateApi(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?,_ details : [SummeryDetailsData]? ) -> ()){
        
        //question
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Saving room details. Please wait...")
            
            let URL = AppURL().update_summary_contract_room_measurement_line
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CommenImageQuestionDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result!,response?.message,response?.summeryDetails)
                }
                
                
                else
                {
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    
    // MARK: - SignatureMaping
    func SignatureMapingpFn(_ applicant_signature:UIImage,_ coapplicant_signature:UIImage?,credit_card:String,finance_application:String,contract:String,appointment_id:String,applicant_initial:UIImage?,coapplicant_initial:UIImage?,completion:@escaping (_ success: String?, _ object: String?,_ data : SignatureApiData? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "The contract document is being generated. Please wait...")
            
            let URL = AppURL().add_applicant_signature
            let user = UserData.init()
            let parameters = ["token":user.token ?? "","appointment_id":appointment_id,"contract":contract,"finance_application":finance_application,"credit_card":credit_card]
            
            // let imageData = applicant_signature.jpegData(compressionQuality: 1)
            let imageData = applicant_signature.jpegData(compressionQuality: 0.4)
            
            
            
            /*  let coApplicantImageData = coapplicant_signature?.jpegData(compressionQuality: 1)
             Alamofire.upload(multipartFormData: { (multipartFormData) in
             multipartFormData.append(imageData!, withName: "applicant_signature", fileName: "applicant_signature.jpeg", mimeType: "image/jpeg")*/
            //   let coApplicantImageData = coapplicant_signature?.jpegData(compressionQuality: 1)
            let applicant_initialImageData = applicant_initial?.jpegData(compressionQuality: 0.4)
            let coapplicant_initialImageData = coapplicant_initial?.jpegData(compressionQuality: 0.4)
            let coApplicantImageData = coapplicant_signature?.jpegData(compressionQuality: 0.4)
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "applicant_signature", fileName: "applicant_signature.jpeg", mimeType: "image/jpeg")
                
                
                
                if(coapplicant_signature != nil)
                {
                    multipartFormData.append(coApplicantImageData!, withName: "co_applicant_signature", fileName: "co_applicant_signature.jpeg", mimeType: "image/jpeg")
                }
                if(applicant_initialImageData != nil)
                {
                    multipartFormData.append(applicant_initialImageData!, withName: "applicant_initial", fileName: "applicant_initial.jpeg", mimeType: "image/jpeg")
                }
                if(coapplicant_initialImageData != nil)
                {
                    multipartFormData.append(coApplicantImageData!, withName: "co_applicant_initial", fileName: "co_applicant_initial.jpeg", mimeType: "image/jpeg")
                }
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)! , withName: key)
                }
            }, to:URL)
            { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            //print response.result
                            let value = response.result.value
                            let result = Mapper<SignatureApiData>().map(JSONObject: value)
                            
                            self.showhideHUD(viewtype: .HIDE, title: "")
                            completion(result?.result,result?.message,result)
                            
                        }
                        break
                    case .failure(let encodingError):
                        self.showhideHUD(viewtype: .HIDE, title: "")
                        completion("false",encodingError.localizedDescription,nil)
                        break
                    //print encodingError.description
                    }}
            }
            
            //            Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<AttachmentClass>) in
            //
            //                self.showhideHUD(viewtype: .HIDE, title: "")
            //                print(response.result.value.debugDescription)
            //                let response = response.result.value
            //                if response?.message == nil{
            //                    response?.message = ""
            //                }
            //                if response?.result == nil{
            //                    response?.result = ""
            //                }
            //                if response != nil{
            //                    completion(response?.result,
            //                               response?.message!, response?.atachments)
            //                }
            //                else{
            //                    completion("false", AppAlertMsg.serverNotReached,nil)
            //                }
            //            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK:- FormUpdateApi
    func FormUpdateApi(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: FormUpdateDataMap? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "")
            
            let URL = "https://hooks.zapier.com/hooks/catch/6718723/ofq05bh"
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<FormUpdateDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.status,response)
                }
                else
                {
                    completion("false", nil)
                }
            }
            
            
        }
        else{
            completion("fail", nil)
            
        }
    }
    
    //MARK:- capturepaymentApi
    func CapturePaymentApi(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?, _ details : String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "The contract details is being submitted. Please wait…")
            // self.showhideHUD(viewtype: .SHOW, title: "Payment is being processed. Please wait...")
            
            
            let URL = AppURL().capture_payment_without_upload
            // let URL = AppURL().capture_payment
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataPDF>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message,response?.document)
                }
                else
                {
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    func DataUploadFromMiddleware(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?, _ details : String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            //self.showhideHUD(viewtype: .SHOW, title: "The contract details is being submitted. Please wait…")
            // self.showhideHUD(viewtype: .SHOW, title: "Payment is being processed. Please wait...")
            
            
            let URL = AppURL().do_file_upload
            // let URL = AppURL().capture_payment
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataPDF>) in
                
                //   self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    //completion(response?.result,response?.message,response?.document)
                }
                else
                {
                    //  completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK:- api for checking whether contract signed or not
    func CapturePaymentApiStatus(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String?, _ details : String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            // self.showhideHUD(viewtype: .SHOW, title: "Payment is being processed. Please wait...")
            self.showhideHUD(viewtype: .SHOW, title: "The contract details is being submitted. Please wait…")
            
            let URL = AppURL().get_contract_document_status
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CommenDataPDF>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message,response?.document)
                }
                else
                {
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK:- createcreditapplication
    func createcreditapplication(parameter:[String:Any],completion:@escaping (_ success: String?,_ object: String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            self.showhideHUD(viewtype: .SHOW, title: "Applicant and income details are being processed. Please wait... ")
            
            let URL = AppURL().create_credit_application
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding:JSONEncoding.default).responseObject { (response:DataResponse<CommenDataMap>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message)
                }
                else
                {
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
            
            
        }
        else{
            completion("fail", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    //MARK:- api for creating credit application pdf
    func CreateCreditApplicationPdf(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String?,_ details : String? ) -> ())
    {
        
        if self.connectedToNetwork()
        {
            self.showhideHUD(viewtype: .SHOW, title: "The contract document is being generated. Please wait...")
            
            let URL = AppURL().generate_credit_application
            
            // Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response:DataResponse<UserLoginData>)
            
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject { (response:DataResponse<CashData>) in
                
                self.showhideHUD(viewtype: .HIDE, title: "")
                
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    
                    completion(response?.result,response?.message, response?.document)
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    func CheckBuildStatus(completion:@escaping (_ buildNumber: String?) -> ()){
        
        
        if self.connectedToNetwork() {
            // self.showhideHUD(viewtype: .SHOW, title: "Removing image. Please wait...")
            
            let URL = AppURL().check_app_build_status
            
            Alamofire.request(URL, method: .get).responseObject { (response:DataResponse<BuildStatus>) in
                
                // self.showhideHUD(viewtype: .HIDE, title: "")
                // print(response.result.value.debugDescription)
                let response = response.result.value
                
                if response != nil{
                    if(response?.bnumber != nil)
                    {
                        completion(response?.bnumber)
                        
                    }
                }
                else{
                    // completion("false", AppAlertMsg.serverNotReached,nil)
                }
            }
        }
        else{
            //  completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //arb - Offline storage
    //MARK: - OFFLINE STORAGE - Get Master Data
    func getMasterDataApi(completion:@escaping (_ success: String?) -> ()){
        
        if self.connectedToNetwork()
        {
            self.showhideHUD(viewtype: .SHOW, title:"Fetching Master Data. Please wait till the sync process is completed.")
            
            let URL =  AppURL().get_master_data //"http://demo1010851.mockable.io/masterData" //
            
            let parameters = ["token":UserData.init().token ?? ""]
            
            Alamofire.request(URL, method: .post, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    if response.result.value != nil {
                        
                        let jsonString = String(data: response.data!, encoding: .utf8)!
                        print(jsonString)
                        if let responseData = MasterData(JSONString: jsonString){
                            print(responseData)
                            do{
                                let realm = try Realm()
                                let results =  realm.objects(MasterData.self)
                                let rooms = realm.objects(rf_master_roomname.self)
                                let floorColors = realm.objects(rf_master_color_list.self)
                                let discount = realm.objects(rf_master_discount.self)
                                let molding = realm.objects(rf_master_molding.self)
                                let product = realm.objects(rf_master_product_package.self)
                                let question = realm.objects(rf_master_question.self)
                                let questionDetail = realm.objects(rf_master_question_detail.self)
                                let imagesArr = realm.objects(FloorImageStorage.self)
                                let appointments = realm.objects(rf_master_appointment.self)
                                let payment = realm.objects(rf_master_payment_option.self)
                                let appointmentResults = realm.objects(rf_master_appointment_results.self)
                                let specialPriceResults = realm.objects(rf_specialPrice_results.self)
                                let promotionCodesResult = realm.objects(rf_promotionCodes_results.self)
                                let transitionHeightResults = realm.objects(rf_transitionHeights_results.self)
                                let floorColourList = realm.objects(rf_floorColour_results.self)
                                let stairColourList = realm.objects(rf_stairColour_results.self)
                                let ruleList = realm.objects(rf_ruleList_results.self)
                                let contract_document = realm.objects(rf_contract_document_templates_results.self)
                                                               // var tempcontract_document:rf_contract_document_templates_results!
                                let fields = realm.objects(rf_fields.self)
                                let appointmentResultsReasons = realm.objects(rf_appointment_result_reasons_results.self)
                                let external_credentials = realm.objects(rf_extrenal_credential_results.self)
                            
                                try realm.write {
                                    realm.delete(results)
                                    realm.delete(rooms)
                                    realm.delete(floorColors)
                                    realm.delete(discount)
                                    realm.delete(molding)
                                    realm.delete(product)
                                    realm.delete(question)
                                    realm.delete(questionDetail)
                                    realm.delete(imagesArr)
                                    realm.delete(appointments)
                                    realm.delete(payment)
                                    realm.delete(appointmentResults)
                                    realm.delete(specialPriceResults)
                                    realm.delete(promotionCodesResult)
                                    realm.delete(transitionHeightResults)
                                    realm.delete(floorColourList)
                                    realm.delete(stairColourList)
                                    realm.delete(ruleList)
                                    realm.delete(contract_document)
                                    realm.delete(fields)
                                    realm.delete(appointmentResultsReasons)
                                    realm.delete(external_credentials)
                                }
                            }catch{
                                print(RealmError.writeFailed.rawValue)
                            }
                            do{
                                let realm = try Realm()
                                try realm.write{
                                    realm.add(responseData)
                                    completion("Success")
                                    return
                                }
                            }catch{
                                print(RealmError.writeFailed.rawValue)
                            }
                        }
                        self.showhideHUD(viewtype: .HIDE, title: "Fetching Master Data Completed")
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        else{
            completion("Failed")
            return
            
        }
    }
    
    //MARK: - Update Customer & Room Information
    func updateCustomerAndRoomInfoAPi(parameter:Parameters,isOnlineCollectBtnPressed:Bool,completion:@escaping (_ success: String?, _ object: String? , _ paymentStatus: String? , _ paymentMessage: String?, _ transactionId: String?,  _ cardType: String?) -> ()){
        if self.connectedToNetwork() {
            
            if isOnlineCollectBtnPressed == true
            {
                self.showhideHUD(viewtype: .SHOW, title: "Processing Payment")
            }
            
            let URL = AppURL().syncCustomerAndRoomInfo
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                manager.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CashDataResponse>) in
                    // print(response.result.value.debugDescription)
                    //                if let error = response.result.error
                    //                {
                    //                    if error._code == NSURLErrorTimedOut
                    //                    {
                    //                        print("TimeOut")
                    //                    }
                    //                }
                    let response = response.result.value
                    if response != nil{
                        if(response?.result != nil)
                        {
                            completion(response?.result,response?.message,response?.paymentStatus,response?.paymentMessage,response?.authorize_transaction_id, response?.card_type)
                            self.showhideHUD(viewtype: .HIDE, title: "")
                        }
                    }
                    else{
                        completion("false", AppAlertMsg.serverNotReached,response?.paymentStatus,response?.paymentMessage,response?.authorize_transaction_id, response?.card_type)
                        self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,"","","","")
            
        }
    }
    
    
    //MARK: - Update Contract Information
//    func updateContractInfoAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String? ) -> ()){
//        
//        
//        if self.connectedToNetwork() {
//            
//            let URL = AppURL().syncContactInfo
//            
//            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CashData>) in
//                
//                
//                let response = response.result.value
//                
//                if response != nil{
//                    if(response?.result != nil)
//                    {
//                        completion(response?.result,response?.message)
//                    }
//                }
//                else{
//                    completion("false", AppAlertMsg.serverNotReached)
//                }
//            }
//        }
//        else{
//            completion("false", AppAlertMsg.NetWorkAlertMessage)
//            
//        }
//    }
    
    func fetchDataBaseInfoAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ message: String? ) -> ()){
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().fetchDataBaseRawValue
            self.showhideHUD(viewtype: .SHOW, title: "Uploading Data. Please wait…")
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject {
                (response:DataResponse<dataBaseData>) in
                self.showhideHUD(viewtype: .HIDE)
               // print(response.result.value.debugDescription)
                print(response.result)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message)
                        self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    func autoLogoutAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ message: String?, _ autologoutTime:String? , _ enableAutoLogout:Int?) -> ()){
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().autoLogout
            //self.showhideHUD(viewtype: .SHOW, title: "Logging out. Please wait.")
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject {
                (response:DataResponse<autoLogoutData>) in
                self.showhideHUD(viewtype: .HIDE)
               // print(response.result.value.debugDescription)
                print(response.result)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        if response?.result == "AuthFailed" || response?.result == "authfailed"
                        {
                            completion(response?.result,response?.message,"",0)
                            self.showhideHUD(viewtype: .HIDE, title: "")
                        }
                        else
                        {
                            completion(response?.result,response?.message,(response?.autoLogoutTime)!,response?.enableAutoLogout)
                            self.showhideHUD(viewtype: .HIDE, title: "")
                        }
                    }
                }
                else{
                    completion("false","","",0)
                }
            }
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false","","",0)
            
        }
    }
    
    
    // versatile api
    
    func versatileAPi(url:String,apiKey:String,entityKey:String,parameter:Parameters,completion:@escaping (_ success: String?, _ message: String?) -> ()){
        
        if self.connectedToNetwork() {
            
            let URL = url//masterData.versatileURL
            let headers = ["Content-Type":"application/json","X-API-Key":apiKey,"X-Entity-Key":entityKey]
            self.showhideHUD(viewtype: .SHOW, title: "Loading versatile credit platforms.")
            Alamofire.request(URL, method: .post, parameters: parameter, encoding: JSONEncoding.default ,headers: headers).responseJSON { response in
                self.showhideHUD(viewtype: .HIDE)
                print(response)
                if let jsonData = response.data {
                    let signInObject = try? JSONDecoder().decode(VersatileModelClass.self, from: jsonData)
                    completion(signInObject?.type,signInObject?.url)
                }
            }
            
    
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false",AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    
    // hunter api
    
    func hunterAPi(url:String,apiKey:String,entityKey:String,parameter:Parameters,completion:@escaping (_ success: String?, _ message: String?) -> ()){
        
        if self.connectedToNetwork() {
            let URL = url//masterData.versatileURL
            let headers = ["Content-Type":"application/json","apiKey":apiKey,"apiSecret":entityKey]
            self.showhideHUD(viewtype: .SHOW, title: "Loading hunter financial platforms.")
            Alamofire.request(URL, method: .post, parameters: parameter, encoding: JSONEncoding.default ,headers: headers).responseJSON { response in
                self.showhideHUD(viewtype: .HIDE)
                print(response)
                if let jsonData = response.data {
                    let signInObject = try? JSONDecoder().decode(VersatileModelClass.self, from: jsonData)
                    completion(signInObject?.type,signInObject?.url)
                }
            }
            
    
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false",AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    
    // CrediApplicationStatus api
    
    
    func versatileStatusAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ message:String?, _ creditApplicationDetails: CreditApplicationStatusDetails?) -> ()){
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().getCreditApplicationStatus
            let token = UserData().token
            let headers = ["Authorization":"Bearer \(token!)"]
            self.showhideHUD(viewtype: .SHOW, title: "Fetching loan status.")
            Alamofire.request(URL, method: .post, parameters: parameter, encoding: JSONEncoding.default ,headers: headers).responseJSON { response in
                self.showhideHUD(viewtype: .HIDE)
                print(response)
                if let jsonData = response.data {
                    let signInObject = try? JSONDecoder().decode(CreditApplicationStatus.self, from: jsonData)
                    if signInObject?.data != nil
                    {
                        if let creditData = signInObject?.data
                        {
                            completion(signInObject?.result,signInObject?.message, creditData)
                        }
                    }
                    else
                    {
                        completion(signInObject?.result,signInObject?.message, nil)
                    }
                    
                }
            }
            
    
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false",AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    
    // func additional comments api
    
    func additionalCommentsAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ message: String?) -> ()){
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().additionalComments
            self.showhideHUD(viewtype: .SHOW, title: "Creating Sale Order")
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject {
                (response:DataResponse<AdditionalComments>) in
                self.showhideHUD(viewtype: .HIDE)
               // print(response.result.value.debugDescription)
                print(response.result)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        
                        completion(response?.result,response?.message)
                            self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                }
                else{
                    completion("false",AppAlertMsg.NetWorkAlertMessage ??
                        AppAlertMsg.serverNotReached)
                }
            }
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false",AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    
    func installerDatesAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ message: String?, _ installationDates:[AvailableDatesValues]?, _ saleOrderId: Int? ) -> ()){
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().installationDates
            self.showhideHUD(viewtype: .SHOW, title: "Fetching available installer schedule dates. Please wait…")
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject {
                (response:DataResponse<InstallerDates>) in
                self.showhideHUD(viewtype: .HIDE)
               // print(response.result.value.debugDescription)
                print(response.result)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        
                        completion(response?.result,response?.message,response?.data?.availableDates,response?.data?.saleOrderId)
                            self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                }
                else{
                    completion("false",AppAlertMsg.NetWorkAlertMessage ??
                        AppAlertMsg.serverNotReached, [] , 0)
                }
            }
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false",AppAlertMsg.NetWorkAlertMessage, [], 0)
            
        }
    }
    
    func installerDatesSubmitAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ message: String? ) -> ()){
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().installationDatesSubmit
            self.showhideHUD(viewtype: .SHOW, title: "Submitting Installation Request. Please wait.")
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject {
                (response:DataResponse<InstallerDatesSubmit>) in
                self.showhideHUD(viewtype: .HIDE)
               // print(response.result.value.debugDescription)
                print(response.result)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        
                        completion(response?.result,response?.message)
                            self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                }
                else{
                    completion("false",AppAlertMsg.NetWorkAlertMessage ??
                               AppAlertMsg.serverNotReached)
                }
            }
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false",AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    
    // GeoLocation
    
    func geoLocationTimeSubmitAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ message: String? ) -> ()){
        
        if self.connectedToNetwork() {
            
            
            let URL = AppURL().geoLocationLogs
            self.showhideHUD(viewtype: .HIDE, title: "")
            Alamofire.request(URL, method: .post, parameters: parameter).responseObject {
                (response:DataResponse<InstallerDatesSubmit>) in
                self.showhideHUD(viewtype: .HIDE)
               // print(response.result.value.debugDescription)
                print(response.result)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        
                        completion(response?.result,response?.message)
                            self.showhideHUD(viewtype: .HIDE, title: "")
                    }
                }
                else{
                    completion("false",AppAlertMsg.NetWorkAlertMessage ??
                               AppAlertMsg.serverNotReached)
                }
            }
           // completion("false", AppAlertMsg.serverNotReached)
        }
        else{
            completion("false",AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    // MARK: - Sync Images Upload
    func syncImagesOfAppointment(appointmentId: String,roomId:String, attachments:UIImage,  imagename: String,imageType:String,dataCompleted:String = "",roomName:String,networkMessage:String,completion:@escaping (_ success: String?, _ message: String?,_ imageName : String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            
            let URL = AppURL().syncImageInfo
            let user = UserData.init()
            var parameters:[String:String] = [:]
            if dataCompleted != ""{
                parameters = ["token":user.token ?? "","appointment_id":appointmentId,"image_type":imageType,"room_id":roomId,"image_name":imagename,"data_completed":dataCompleted,"room_name":roomName,"network_strength":networkMessage]
            }else{
                parameters = ["token":user.token ?? "","appointment_id":appointmentId,"image_type":imageType,"room_id":roomId,"image_name":imagename,"room_name":roomName,"network_strength":networkMessage]
            }
            
            let imageData = attachments.jpegData(compressionQuality: 0.0)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "file", fileName: imagename, mimeType: "image/jpeg")
                for (key, value) in parameters
                {
                    
                    multipartFormData.append(value.data(using: String.Encoding.utf8)! , withName: key)
                }
            }, to:URL)
            { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            //print response.result
                            let value = response.result.value
                            let result = Mapper<OfflineAttachment>().map(JSONObject: value)
                            
                            completion(result?.result,result?.message,result?.image_name)
                            
                        }
                        break
                    case .failure(let encodingError):
                        completion("false",encodingError.localizedDescription,nil)
                        break
                    }}
            }
            
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage,nil)
            
        }
    }
    
    //MARK: - Generate Contract in Server Side
    func generateContactAPi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            
            let URL = AppURL().syncGenerateContractDocumentInServer
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: URLEncoding.default).responseObject { (response:DataResponse<CashData>) in
                
                
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    //MARK: - Initiate Sync i360
    func initiateSync_i360_APi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String? ) -> ()){
        
        if self.connectedToNetwork() {
            
            let URL = AppURL().syncInitiate_i360
            
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CashData>) in
                
                
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    //MARK: - Generate Contract in Server Side
    func uploadLogsToServer(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            
            let URL = AppURL().uploadAppointmentLogs
            self.showhideHUD(viewtype: .SHOW, title: "Uploading logs. Please wait.")
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: JSONEncoding.default).responseObject { (response:DataResponse<CashData>) in
                
                self.showhideHUD(viewtype: .HIDE)
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
    
    //MARK: - Logout
    func logoutApi(parameter:Parameters,completion:@escaping (_ success: String?, _ object: String? ) -> ()){
        
        
        if self.connectedToNetwork() {
            
            let URL = AppURL().logoutApi
            self.showhideHUD(viewtype: .SHOW, title: "Logging out. Please wait.")
            Alamofire.request(URL, method: .post, parameters: parameter,encoding: URLEncoding.default).responseObject { (response:DataResponse<CashData>) in
                self.showhideHUD(viewtype: .HIDE)
                
                let response = response.result.value
                
                if response != nil{
                    if(response?.result != nil)
                    {
                        completion(response?.result,response?.message)
                    }
                }
                else{
                    completion("false", AppAlertMsg.serverNotReached)
                }
            }
        }
        else{
            completion("false", AppAlertMsg.NetWorkAlertMessage)
            
        }
    }
}

class NetworkSpeedTest {

    func testUploadSpeed(completion: @escaping (Double) -> Void) {
        // Generate data to upload (1 MB of data in this example)
        let dataSize = 1 * 1024 * 1024 // 1 MB
        let data = Data(repeating: 0, count: dataSize)
        
        // Start measuring time
        let startTime = Date()
        
        // URL to upload data
        let url = URL(string: "https://odoo.myx.ac")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            // End measuring time
            let endTime = Date()
            
            // Calculate time taken in seconds
            let timeInterval = endTime.timeIntervalSince(startTime)
            
            // Calculate upload speed in Mbps
            let speed = Double(dataSize) * 8 / timeInterval / (1024 * 1024) // Mbps
            
            // Return the upload speed
            completion(speed)
        }
        
        // Start the upload task
        task.resume()
    }
}


