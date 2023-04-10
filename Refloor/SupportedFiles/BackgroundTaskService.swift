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
    var comments:String = String()
    var sendPhysical:Bool = Bool()
    
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
            
            
            self.startSyncProcess(comments: self.comments, sendPhysical: self.sendPhysical)
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
    func startSyncProcess(comments:String,sendPhysical:Bool){
        self.comments = comments
        self.sendPhysical = sendPhysical
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
                
                self.startSyncProcess(comments: self.comments, sendPhysical: self.sendPhysical)
                
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
                
                self.startSyncProcess(comments: self.comments, sendPhysical: self.sendPhysical)
                
            }
            
        }
        
    }
    
    // MARK: - CREATE PARAMETERS
    func createCustomerAndRoomParametersForApiCall(completedAppointmentRequest:rf_Completed_Appointment_Request) -> (appointmentId: Int, requestParams: [String:Any], requestUrl: String){
        //UserData.init().token ?? ""
        var parameterToPass:[String:Any] = [:]
        var jwtToken:String = String()
        let appointment_id = completedAppointmentRequest.appointment_id
        let apiUrl = completedAppointmentRequest.request_url ?? ""
        var paramsDict:[String:Any] = completedAppointmentRequest.request_parameter?.dictionaryValue() ?? [:]
        //jwtToken = completedAppointmentRequest.request_parameter ?? ""
       // paramsDict.removeValue(forKey: "data")
//        let contactApiData = self.createContractParameters()
//        var customerAndRoomData = self.createFinalParameterForCustomerApiCall()
//        for (key,value) in contactApiData{
//            customerAndRoomData[key] = value
//        }
//       let json = (customerAndRoomData as NSDictionary).JsonString()
        
        let decodeOption:[String:Bool] = ["verify_signature":false]
      parameterToPass = ["token": UserData.init().token ?? "" ,"decode_options":decodeOption,"data":paramsDict]
       // paramsDict["token"] = UserData.init().token ?? ""
        return (appointmentId: appointment_id, requestParams:parameterToPass, requestUrl: apiUrl)
    }
    func createFinalParameterForCustomerApiCall() -> [String:Any]{
        var customerDict: [String:Any] = [:]
        customerDict["appointment_id"] = AppointmentData().appointment_id ?? 0
        customerDict["data_completed"] = 0
        var customerData = createCustomerParameter()
        customerData["additional_comments"] = self.comments
        customerData["send_physical_document"] = self.sendPhysical ? 1 : 0
        customerDict["customer"] = customerData
        customerDict["rooms"] = createRoomParameters()
        customerDict["answer"] = createQuestionAnswerForAllRoomsParameter()
        customerDict["operation_mode"] = "offline"
        return customerDict
    }
    func getQuestionAnswerArrayForApiCall() -> [[String:Any]]{
        var questionAnswerArray:[[String:Any]] = []
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
            appointment.first?.rooms.forEach({ room in
                var questionAnswerDictForSingleRoom:[String:Any] = [:]
                let questionAnswers = room.questionnaires
                questionAnswers.forEach { question in
                    let room_id = question.room_id
                    let question_id = question.id
                    let answerObj = question.rf_AnswerOFQustion.first
                    var answerArray:[String] = []
                    answerObj?.answer.forEach({ answer in
                        answerArray.append(answer)
                    })
                    questionAnswerDictForSingleRoom["room_id"] = room_id
                    questionAnswerDictForSingleRoom["question_id"] = question_id
                    questionAnswerDictForSingleRoom["answer"] = answerArray
                    questionAnswerArray.append(questionAnswerDictForSingleRoom)
                }
            })
            
        }catch{
            print(RealmError.initialisationFailed.rawValue)
        }
        
        return questionAnswerArray
    }
    func createQuestionAnswerForAllRoomsParameter() -> [[String:Any]]{
        return self.getQuestionAnswerArrayForApiCall()
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
                let roomColorId = masterData?.flooring_colors.filter("color_name == %@",selectedColor).first?.material_id ?? 0
                var transitionArray: [[String:Any]] = []
                var transition1_name = ""
                var transition1_width = ""
                var transition2_name = ""
                var transition2_width = ""
                var transition3_name = ""
                var transition3_width = ""
                var transition4_name = ""
                var transition4_width = ""
                let isRoomExcluded = room.room_strike_status ? 1 : 0
                for i in 0..<room.transArray.count{
                    let name = room.transArray[i].name ?? ""
                    let width = room.transArray[i].transsquarefeet
                    let transitionDict:[String:Any] = ["name":name, "width": width]
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
                roomDict["room_id"] = room_id
                roomDict["room_name"] = room_name
                roomDict["room_area"] = room_area
                roomDict["room_area_image"] = room_area_image
                roomDict["room_adjusted_area"] = room_adjusted_area
                roomDict["room_perimeter"] = room_perimeter
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
    func createRoomParameters() -> [[String:Any]]{
        return self.getRoomArrayForApiCall()
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
    func getCustomerDetailsForApiCall() -> [String:Any]{
        var customerDetailsDict:[String:Any] = [:]
        do{
            _ = try Realm()
            let appointmentId = AppointmentData().appointment_id ?? 0
            let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId).first
            let mobile = appointment?.applicant_phone
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
            customerDetailsDict["mobile"] = mobile
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
    func createCustomerParameter() -> [String:Any]{
        return self.getCustomerDetailsForApiCall()
    }
    
    func createContractParameters() -> [String:Any] {
        let paymentDetails = self.getPaymentDetailsDataFromAppointmentDetail()
        print(paymentDetails)
        let paymentType = self.getPaymentMethodTypeFromAppointmentDetail()
        print(paymentType)
        let applicantDta = self.getApplicantAndIncomeDataFromAppointmentDetail()
        print(applicantDta)
        //let contactInfo = self.getContractDataOfAppointment()
        //print(contactInfo)
        var contractDict: [String:Any] = [:]
        contractDict["paymentdetails"] = paymentDetails
        contractDict["paymentmethod"] = paymentType
        contractDict["applicationInfo"] = applicantDta["data"]
        //contractDict["contractInfo"] = contactInfo
//        contractDict["data_completed"] = 0
//        contractDict["appointment_id"] = AppointmentData().appointment_id ?? 0
//        let contractDataDict: [String:Any] = ["data":contractDict]
//        print(contractDataDict)
        return contractDict //contractDataDict
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
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.CustomerAndRoom)
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
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.GenerateContract)
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
                self.updateAppointmentRequestSyncStatusAsComplete(appointmentId: appointmentId, requestTitle: RequestTitle.InitiateSync)
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
