//
//  SyncManager.swift
//  SyncTest
//
//  Created by Rihesh R on 28/12/21.
//


import Foundation
import BackgroundTasks
import RealmSwift
import JWTCodable
import CryptoKit
import CommonCrypto

// How to Make a Background Task
//step 1 : click on your project >> Signing & Capabilities >> click on "+ Capability" and added Background fetch & Background processing

//step 2 : open Info.plist and add a new key "Permitted background task scheduler identifiers" and after that give it an identifier
// We need only one background task, so we add background Task identifier named "com.oneteamus.liveflier"

class BackgroundTaskService {
    static public let shared = BackgroundTaskService()
    private init() {}
    
    var timer = Timer()
    var testResult = "TEST"
    var i = 1
    var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    func enterBackground() {
        print("Enter Background !!")
        
        //step 4: cancel all Background Task before start new one !
        cancelAllTaskRequests()
        
        //step 5: request The Background Task
        requestUplouadBackgroungTask()
    }
    
}

extension BackgroundTaskService {
    
    func cancelAllTaskRequests() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    //step 3 : you need to register the backround Task immediately when app launch
    func registerBackgroundTaks() {
        // notice that this identifier is the same on info.plist file
        /* BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.oneteamus.liveflier", using: nil) { task in
         
         // step 4 : handle the background task and notice that we cast the task as a BGProcessingTask
         // inside this function you will do whatever you want to do on background task
         self.handleDataUploadingTask(task: task as! BGProcessingTask)
         }
         */
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.oneteamus.liveflier",
            using: DispatchQueue.global()
        ) { task in
            self.handleDataUploadingTask(task: task as! BGProcessingTask)
        }
    }
    
    
    func requestUplouadBackgroungTask() {
        
        // Here we must request the background task
        
        // notice that :-
        // There is 2 type on background :
        
        // - BGAppRefreshTask it only to refresh the content exactly it's that same as Background fetch on old iOS versions that mean it must finish on only 30 sec!
        
        // - BGProcessingTask is for doing things that take minutes to finish and that what we need here
        
        //again when we want to request the background task we need to write the same identifier
        let request = BGProcessingTaskRequest(identifier: "com.oneteamus.liveflier")
        
        //Notice we need Internet that why we must make it true, so the system will do this task only if there is internet!
        request.requiresNetworkConnectivity = true // Need to true if your task needs to network process. Defaults to false.
        
        // but we don't need power (device charging)
        //Apple recommends making it true. if you will do a task that will take a long time to complete
        //Like making a Backup
        //Training the ML module etc
        //Remember if you did allow the ExternalPower, you would remove the limit on CPU and GPU of the device
        request.requiresExternalPower = false
        
        //This also required if you want a delay
        //for example, you can make the task after 1 minute by multiply to 1
        // you can also schedule the task to happen every week for example
        
        //Note: Apple said EarliestBeginDate should not be set to too far into the future.
        
        
        
        do {
            // don't forget to sumbit the request
            testResult = "Submit"
            // backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
            
            //let taskID = beginBackgroundUpdateTask()
            
            
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Finish doing this task", expirationHandler: {
                
                // End the task if time expires
                
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                
                
            })
            try BGTaskScheduler.shared.submit(request)
            
        } catch {
            print("Could not schedule image : \(error)")
        }
        
    }
    
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: ({}))
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
    
    func handleDataUploadingTask(task: BGProcessingTask) {
        // it's importing to recall it here
        // the reason why is because you want to schedule a new background task while you are execute current Background Task
        requestUplouadBackgroungTask() // Recall
        
        testResult = "Success"
        // if for any reason the system choose to stop the task it will do anything inside this
        // you need to stop everything you are doing right now
        task.expirationHandler = {
            //This Block call by System
            //Cancel your all taks & queues
            self.cancelAllTaskRequests()
            
        }
        //self.uploadData()
        print("BG Task Started !!")
        
        
        let appointmentRequestArray = fetchAppointmentRequest()
        if(appointmentRequestArray.count == 0)
        {
            print("Task completed !!")
            
            timer.invalidate()
            task.setTaskCompleted(success: true)
        }
        else{
            print("API started !!")
            
            // self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
            print("START ALL PENDING SYNC OPERATIONS")
            
            
            self.startSyncProcess()
            //   })
            
            
        }
        
    }
    
    // MARK: - FETCH PENDING APPOINTMENT DATA TO SYNC
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
    
    //func to mark the status of api once its successfully completed -> "sync_status" = true
    // MARK: - UPDATE STATUS OF COMPLETED APPOINTMENT IN DB
    func updateAppointmentRequestSyncStatusAsComplete(appointmentId: Int, requestTitle: RequestTitle, imageName:String = "",paymentStatus:String,paymentMessage:String){
        let appointment = self.getAppointmentData(appointmentId: appointmentId)
        let firstName = appointment?.applicant_first_name ?? ""
        let lastName = appointment?.applicant_last_name ?? ""
        let name = lastName == ""  ? firstName : firstName + " " + lastName
        let date = appointment?.appointment_datetime ?? ""
        do{
            let realm = try Realm()
            try realm.write{
                if requestTitle != RequestTitle.ImageUpload{
                    let appointmentRequest = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d AND reqest_title == %@", appointmentId, requestTitle.rawValue)
                    var dict:[String:Any] = [:]
                    if appointmentRequest.count > 0{
//                        if let appointmentRequestObj = appointmentRequest.first{
//                            dict = ["id": appointmentRequestObj.id,
//                                    "sync_status" : true]
//                            realm.create(rf_Completed_Appointment_Request.self, value: dict, update: .all)
//                        }
                    for obj in appointmentRequest
                    {

//                            if let appointmentRequestObj = obj{
                        dict = ["id": obj.id,
                                    "sync_status" : true]

                            realm.create(rf_Completed_Appointment_Request.self, value: dict, update: .all)
                     //   }
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
    
    // MARK: - GET DATA TO SYNC
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
    
    func determineIfAnyPendingAppointmentsToSinkForAppointmentId(appointmentId:Int) -> Bool{
        var isAppointmentsPendingToSink = false
        do{
            let realm = try Realm()
            let allAppointmentsAvailable = realm.objects(rf_Completed_Appointment_Request.self).filter("appointment_id == %d" , appointmentId)
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
    
    // MARK: - START SYNC ACTION
    func startSyncProcess(){
        var syncDelayValue:Int = 0
        print("Timer called")
        var ifAnyApiFailed = false
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            print("Inside API !!")
            let appointmentRequestArray = getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
            
            if(appointmentRequestArray.count == 0)
            {
                if(SceneDelegate.timer.isValid)
                {
                    SceneDelegate.timer.invalidate()
                }
                self.cancelAllTaskRequests()
                
            }
            
            for appointmentRequest in appointmentRequestArray
            {
//                count = count + 1
//                if count > 1{
//                    break
//                }

              
                print("Date Before \(Date().toString())")
                    switch appointmentRequest.reqest_title {
                    case RequestTitle.CustomerAndRoom.rawValue:
                        let (appointmentId, requestParams, _) =  self.createCustomerAndRoomParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        self.syncCustomerAndRoomData(appointmentId: appointmentId, parameter: requestParams){ ifSuccess in
                            
                            if !ifSuccess{
                                print("Spinner Count:1")
                                ifAnyApiFailed = true
                                return
                            }else{
                                print("Spinner Count:2")
                                ifAnyApiFailed = false
                            }
                        }
                        break
//                    case RequestTitle.ContactDetails.rawValue:
//                        let (appointmentId, requestParams, _) =  self.createContractDetailsParametersForApiCall(completedAppointmentRequest: appointmentRequest)
//                        self.syncContractData(appointmentId: appointmentId, parameter: requestParams){ ifSuccess in
//                            if !ifSuccess{
//                                print("Spinner Count:3")
//                                ifAnyApiFailed = true
//                                return
//                            }else{
//                                print("Spinner Count:4")
//                                ifAnyApiFailed = false
//                            }
//                        }
//                        break
                    case RequestTitle.ImageUpload.rawValue:
                        let requestParams =  self.createImageUploadParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        self.syncImages(imageDict: requestParams){ ifSuccess in
                            if !ifSuccess{
                                print("Spinner Count:5")
                                ifAnyApiFailed = true
                                return
                            }else{
                                print("Spinner Count:6")
                                ifAnyApiFailed = false
                            }
                        }
                        break
                    case RequestTitle.GenerateContract.rawValue:
                        let (appointmentId, requestParams, _) =  self.createGenerateContractParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        self.syncGenerateContract(appointmentId:appointmentId,parameter: requestParams){ ifSuccess in
                            if !ifSuccess{
                                print("Spinner Count:7")
                                ifAnyApiFailed = true
                                return
                            }else{
                                print("Spinner Count:8")
                                ifAnyApiFailed = false
                            }
                        }
                        break
                    case RequestTitle.InitiateSync.rawValue:
                        let (appointmentId, requestParams, _) = self.createInitiate_i360_SyncParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        syncDelayValue = syncDelayValue + 1
                        if HttpClientManager.SharedHM.connectedToNetwork(){
                            print("Spinner Count:9")
                            self.sync_i360(appointmentId: appointmentId, parameter: requestParams,sync_delay:syncDelayValue)
                            //  self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync)
                            
                            if (UIApplication.getTopViewController() as? CustomerListViewController) != nil {
                                NotificationCenter.default.post(name: Notification.Name("UpdateAppointments"), object: nil)
                            }
                        }
                        break
                    case .none:
                        break
                    case .some(_):
                        break
                    }
                    
                
            }
            
            if ifAnyApiFailed
            {
                
                self.startSyncProcess()
                
            }
            
        }
        
    }
    
    func startManualSyncProcess(){
        var syncDelayValue:Int = 0
        print("Timer called")
        var ifAnyApiFailed = false
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            print("Inside API !!")
            let appointmentRequestArray = getAppointmentsToSyncFromDB(requestTitle: RequestTitle.CustomerAndRoom)
            
            if(appointmentRequestArray.count == 0)
            {
                if(SceneDelegate.timer.isValid)
                {
                    SceneDelegate.timer.invalidate()
                }
                self.cancelAllTaskRequests()
                
            }
            
            for appointmentRequest in appointmentRequestArray
            {
                
                print("Date Before \(Date().toString())")
                    switch appointmentRequest.reqest_title {
                    case RequestTitle.CustomerAndRoom.rawValue:
                        let (appointmentId, requestParams, _) =  self.createCustomerAndRoomParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        self.syncCustomerAndRoomData(appointmentId: appointmentId, parameter: requestParams){ ifSuccess in
                            
                            if !ifSuccess{
                                print("Spinner Count:1")
                                ifAnyApiFailed = true
                                return
                            }else{
                                print("Spinner Count:2")
                                ifAnyApiFailed = false
                            }
                        }
                        break
//                    case RequestTitle.ContactDetails.rawValue:
//                        let (appointmentId, requestParams, _) =  self.createContractDetailsParametersForApiCall(completedAppointmentRequest: appointmentRequest)
//                        self.syncContractData(appointmentId: appointmentId, parameter: requestParams){ ifSuccess in
//                            if !ifSuccess{
//                                print("Spinner Count:3")
//                                ifAnyApiFailed = true
//                                return
//                            }else{
//                                print("Spinner Count:4")
//                                ifAnyApiFailed = false
//                            }
//                        }
//                        break
                    case RequestTitle.ImageUpload.rawValue:
                        let requestParams =  self.createImageUploadParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        self.syncImages(imageDict: requestParams){ ifSuccess in
                            if !ifSuccess{
                                print("Spinner Count:5")
                                ifAnyApiFailed = true
                                return
                            }else{
                                print("Spinner Count:6")
                                ifAnyApiFailed = false
                            }
                        }
                        break
                    case RequestTitle.GenerateContract.rawValue:
                        let (appointmentId, requestParams, _) =  self.createGenerateContractParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        self.syncGenerateContract(appointmentId:appointmentId,parameter: requestParams){ ifSuccess in
                            if !ifSuccess{
                                print("Spinner Count:7")
                                ifAnyApiFailed = true
                                return
                            }else{
                                print("Spinner Count:8")
                                ifAnyApiFailed = false
                            }
                        }
                        break
                    case RequestTitle.InitiateSync.rawValue:
                        let (appointmentId, requestParams, _) = self.createInitiate_i360_SyncParametersForApiCall(completedAppointmentRequest: appointmentRequest)
                        syncDelayValue = syncDelayValue + 1
                        if HttpClientManager.SharedHM.connectedToNetwork(){
                            print("Spinner Count:9")
                            self.sync_i360(appointmentId: appointmentId, parameter: requestParams,sync_delay:syncDelayValue)
                            //  self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync)
                            
                            if (UIApplication.getTopViewController() as? CustomerListViewController) != nil {
                                NotificationCenter.default.post(name: Notification.Name("UpdateAppointments"), object: nil)
                            }
                        }
                        break
                    case .none:
                        break
                    case .some(_):
                        break
                    }
                    
                
            }
            
            if ifAnyApiFailed
            {
                
                self.startSyncProcess()
                
            }
            
        }
        
    }
    
    // MARK: - CREATE PARAMETERS
    func createCustomerAndRoomParametersForApiCall(completedAppointmentRequest:rf_Completed_Appointment_Request) -> (appointmentId: Int, requestParams: [String:Any], requestUrl: String){
        var parameterToPass:[String:Any] = [:]
        let appointment_id = completedAppointmentRequest.appointment_id
        let apiUrl = completedAppointmentRequest.request_url ?? ""
        var paramsDict:[String:Any] = completedAppointmentRequest.request_parameter?.dictionaryValue() ?? [:]
        //jwtToken = completedAppointmentRequest.request_parameter ?? ""
       // paramsDict.removeValue(forKey: "data")
        
        
        let decodeOption:[String:Bool] = ["verify_signature":false]
      parameterToPass = ["token": UserData.init().token ?? "" ,"decode_options":decodeOption,"data":paramsDict]
       // paramsDict["token"] = UserData.init().token ?? ""
        return (appointmentId: appointment_id, requestParams:parameterToPass, requestUrl: apiUrl)
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
    
    //get appointments data from master or completed appointment
    // MARK: - GET APPOINTMENTS DATA FROM MASTER OR COMPLETED APPOINTMENT
    func getAppointmentData(appointmentId:Int) -> rf_master_appointment!{
        var appointmentData : rf_master_appointment!
        let appointmentId = AppointmentData().appointment_id ?? 0
        do{
            let realm = try Realm()
            if let appointment = realm.objects(rf_master_appointment.self).filter("id == %d",appointmentId).first{
                appointmentData = appointment
            }else if let appointment = realm.objects(rf_completed_appointment.self).filter("appointment_id == %d",appointmentId).first{
                appointmentData = rf_master_appointment(appointmentObj: appointment)
            }
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        return appointmentData
    }
    
    // MARK: - CustomerAndRoom Sync Api
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
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncStarted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date)
        HttpClientManager.SharedHM.updateCustomerAndRoomInfoAPi(parameter: parameter, isOnlineCollectBtnPressed: false) { success, message,payment_status,payment_message  in
            if(success ?? "") == "Success"{
                print(message ?? "No msg")
                //Writing Logs
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                //
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncCompleted.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.CustomerAndRoom,paymentStatus: payment_status ?? "",paymentMessage: payment_message ?? "")
                completion(true)
            }else{
                //Writing Logs
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.customerDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.roomDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                //
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.packageDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.paymentDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.creditFormDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.contractDetailsSyncFailed.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date,payment_status: payment_status ?? "",payment_message: payment_message ?? "")
                completion(false)
            }
        }
    }
    
    // MARK: - Contract Sync Api
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
    
    // MARK: - Image Sync Api
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
        HttpClientManager.SharedHM.syncImagesOfAppointment(appointmentId: String(appoint_id), roomId: room_id_str, attachments: file, imagename: image_name, imageType: image_type) { success, message, imageName in
            if(success ?? "") == "Success"{
                print(message ?? "No msg")
                if let imageNam = imageName{
                    self.addImageCompleteLogs(appointmentId: appoint_id)
                    self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appoint_id, requestTitle:  RequestTitle.ImageUpload, imageName: imageNam,paymentStatus: "",paymentMessage: "")
                    completion(true)
                }
                completion(false)
            }else{
                self.addImageFailLogs(appointmentId: appoint_id, errorMessage: "Error image upload not complete")
                completion(false)
            }
        }
        
    }
    
    // MARK: - Generate Contract Sync Api
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
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.GenerateContract,paymentStatus: "",paymentMessage: "")
                self.deleteSyncCompletedAppointmentFromAppointmentDB(appointmentId: appointmentId)
                completion(true)
            }else{
                self.saveLogDetailsForAppointment(appointmentId: appointmentId, logMessage: AppointmentLogMessages.generateContractSyncCompleted.rawValue, time: Date().getSyncDateAsString(),errorMessage: message ?? "Error Occured",name:name ,appointmentDate:date)
                completion(false)
            }
        }
    }
    
    // MARK: - i360 Sync Api
    func sync_i360(appointmentId:Int, parameter:[String:Any],sync_delay:Int){
        var params = parameter
        var data = params["data"] as? [String:Any] ?? [:]
        data["sync_delay"] = sync_delay
        params["data"] = data
        print("*&*&*&*&&**&* sync_delay = \(sync_delay)")
        HttpClientManager.SharedHM.initiateSync_i360_APi(parameter: params) { success, message in
            if(success ?? "") == "Success"{
                print(message ?? "No msg")
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync,paymentStatus: "",paymentMessage: "")
                if (UIApplication.getTopViewController() as? ViewLogListViewController) != nil {
                    NotificationCenter.default.post(name: Notification.Name("UpdateLogView"), object: nil)
                }
            }
        }
    }
    
    // MARK: - Save log for image start
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
    
    // MARK: - Save log for image complete
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
    
    // MARK: - Save log for image failed
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
    
    // MARK: - Save log in DB
    func saveLogDetailsForAppointment(appointmentId: Int, logMessage: String ,time:String, errorMessage: String = "",name:String,appointmentDate:String,payment_status:String = "",payment_message:String = ""){
        do{
            let realm = try Realm()
            var dict:[String:Any] = [:]
            try realm.write{
                let appointmentLogs = realm.objects(rf_Appointment_Logs.self).filter("appointment_id == %@",appointmentId)
                if appointmentLogs.count == 0{
                    let logList = RealmSwift.List<rf_Appointment_Log_Data>()
                    logList.append(rf_Appointment_Log_Data(message: logMessage, time: time, appointmentId: appointmentId,customerName: name, appointmentDateTime: appointmentDate))
                    let dict:[String:Any] = ["appointment_id":appointmentId,"sync_message":logList,"appBaseUrl":BASE_URL,"paymentStatus":payment_status,"paymentMessage":payment_message]
                    realm.create(rf_Appointment_Logs.self, value: dict, update: .all)
                }else{
                    if let appointmentLogsAlreadyExist = appointmentLogs.first{
                        let logArrayList = appointmentLogsAlreadyExist.sync_message
                        logArrayList.append(rf_Appointment_Log_Data(message: logMessage, time: time, appointmentId: appointmentId,customerName: name, appointmentDateTime: appointmentDate))
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
    
    // MARK: - Load log from DB
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
    
    // MARK: - Delete Completed appointment
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
}
