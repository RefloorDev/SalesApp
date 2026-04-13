//
//  SummeryListViewController.swift
//  Refloor
//
//  Created by sbek on 27/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift
import JavaScriptCore
@MainActor
class SummeryListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DropDownForTableViewCellDelegate {
    
    
    
    static func initialization() -> SummeryListViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SummeryListViewController") as? SummeryListViewController
    }
    @IBOutlet weak var applyAllSelectDeliveryTxtFld: UITextField!
    @IBOutlet weak var applyAllBtn: UIButton!
    @IBOutlet weak var applyAllSelectColorImageView: UIImageView!
    @IBOutlet weak var applyAllSelectMoldingTxtFld: UITextField!
    @IBOutlet weak var applyAllSelectColorTxtFld: UITextField!
    @IBOutlet weak var vapourBarrierLbl: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var swipeLeftLbl: UILabel!
    @IBOutlet weak var MoldingTitleLbl: UILabel!
    @IBOutlet weak var MoldingView: UIView!
    var imagePicker: CaptureImage!
    var validationTileColorRoomName = ""
    var validationMoldingColorRoomName = ""
    var appoinmentID:Int = 0
    var stairCount:Int = 0
    var tableValues:[SummeryListData] = []
    var area:Double = 0
    var isFromStatus = false
    var summaryDetailsData:[SummeryDetailsData] = []
    
    var isselectedColor = 0
    var isselectedMolding = 0
    var globalMeasurement_id:Int = 0
    var globalColor_id:Int = 0
    var globalMoldingName = ""
    var vaporbarrierValue:Double = 0.0
    
    var moldingNamesArray:[String] = []
    var moldingPriceArray:[Double] = []
    var floorColorNamesArray:Results<rf_floorColour_results>!
    var stairColourNamesArray:Results<rf_stairColour_results>!
    
    var applyAllSelectedColour:String = String()
    var applyAllColourUpCharge:Double = Double()
    var applyAllSelectedMaterialFileName:String = String()
    var applyAllSelectedMoldName:String = String()
    var applyAllSelectedMoldPrice:Double = Double()
    var firstLoad = 1
    
    var stairIndex = -1
    var roomIndex = -1
    var officeLocationId = AppDelegate.appoinmentslData.officeLocationId
    var cellDefaultDelivery:String = String()
    var applyDefaultDelivery:String = String()
    var cellDeliveryOptions:[String] = []
    var applyDeliveryOptions:[String] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        floorColorNamesArray = getFloorColorList()
        stairColourNamesArray = getStairColorList()
        self.setNavigationBarbackAndlogo(with: "Measurement Summary".uppercased())
        if !(isFromStatus)
        {
            if let firstViewController = self.navigationController?.viewControllers[0]
            {
                self.navigationController?.viewControllers = [firstViewController,self]
                
            }
            
        }
        else
        {
            self.addNewButton.isHidden = true
            self.nextButton.isHidden = true
        }
        applyAllSelectColorImageView.image = UIImage(named: "AppIcon")
        applyAllBtn.isUserInteractionEnabled = false
        applyAllBtn.setTitleColor(UIColor().colorFromHexString("A6AFB9"), for: .normal)
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        logScreenEvent(screen: ScreenNames.measurementist) {
            var networkMessage = ""
            let speedTest = NetworkSpeedTest()
            speedTest.testUploadSpeed { speed in
                print("Upload speed: \(speed) Mbps")
                networkMessage = String(format: "%.2f", speed)
                networkMessage += "Mbps"
                //DispatchQueue.main.async {
                
                let (_,timeZone) = Date().getCompletedDateStringAndTimeZone()
                let parameters:[String:Any] = ["appointment_id": AppointmentData().appointment_id ?? 0,"screen_name":ScreenNames.measurementist,"screen_entry_date":Date().getSyncDateAsString(),"network_strength":networkMessage,"timezone":timeZone,"CreatedDate": Date().getSyncDateAsString()]
                HttpClientManager.SharedHM.liveScreenLogsAPi(parameter: parameters)
        }
        
        }
        
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        loadRefreshData()
    }

    
    override func performSegueToReturnBack() {
        if (isFromStatus)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let details = CustomerDetailsOneViewController.initialization()!
            details.floorLevelData = AppDelegate.floorLevelData
            details.floorShapeData = []
            details.roomData = AppDelegate.roomData
            details.appoinmentslData = AppDelegate.appoinmentslData
            details.isBothParties = AppDelegate.appoinmentslData.isBothParties ?? 0
            self.navigationController?.pushViewController(details, animated: true)
        }
    }
    
    
    
    func loadRefreshData(){
        tableValues = self.getRoomsSummary(appointmentId: AppointmentData().appointment_id ?? 0)
        
        if tableValues.count != 0{
            self.tableReload(tableValues)
            self.swipeLeftLbl.isHidden = false
        }else{
            self.tableReload(tableValues)
            self.swipeLeftLbl.isHidden = true
        }
    }
    
    func calculateFloorColorUpchargeAndExtraCost(rooms:[SummeryListData]) -> (totalUpcharge: Double, extraCost: Double, extraCostExclude: Double, totalStairCountOfAllRooms: Int, extraPromoCostExcluded: Double){
            var upCharge: Double = 0.0
            var totalExtraCost: Double = 0.0
            var totalExtraCostToReduce: Double = 0.0
            var totalExtraPromoPriceToReduce:Double = 0.0
            var totalStairCount = 0
            for roomData in rooms{
                if ((roomData.color ?? "") != "" && (roomData.striked ?? "").lowercased() == "false"){
                    let currentRoomUpcharge = ((roomData.adjusted_area ?? 0.0) * (roomData.colorUpCharge ?? 0.0))
                    let roomId = roomData.room_id ?? 0
                    self.saveUpchargeCostPerRoomToCompletedAppointment(roomId: roomId, upChargeCost: currentRoomUpcharge)
                    totalExtraCost = totalExtraCost +  self.getExtraCostFromCompletedAppointment(roomId: roomId )
                    let (discountcostReduced,promoCostreduced) = self.getExtraCostExcludeFromCompletedAppointment(roomId: roomId)
                    totalExtraCostToReduce = totalExtraCostToReduce + discountcostReduced
                    totalExtraPromoPriceToReduce = totalExtraPromoPriceToReduce + promoCostreduced
                    upCharge =  upCharge + currentRoomUpcharge
                    if (roomData.room_name ?? "").localizedCaseInsensitiveContains("stair") {
                        totalStairCount = totalStairCount + (roomData.stair_count ?? 0)
                    }
                }
            }
            return (upCharge, totalExtraCost,totalExtraCostToReduce,totalStairCount,totalExtraPromoPriceToReduce)
        }
    func calculateMoldingPrice(rooms:[SummeryListData]) -> (Double)
    {
        var totalMouldingPrice :Double = 0.0
        for roomData in rooms
        {
            let roomNameSubstr = roomData.room_name?.contains("STAIRS")
            if roomNameSubstr != true
            {
                if ((roomData.moulding ?? "") != "" && (roomData.striked ?? "").lowercased() == "false")
                {
                    let roomPerimeter = Double(roomData.room_perimeter ?? 0.0)
                    let currentRoomMoldingCharge = ((roomData.mouldingPrice ?? 0.0) * (roomPerimeter))
                    
                    totalMouldingPrice = totalMouldingPrice +  currentRoomMoldingCharge
                    
                }
            }
        }
        return totalMouldingPrice
    }
    
    
    @IBAction func scheduleListAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addNewButtonAction(_ sender: Any) {
        let room = SelectARoomViewController.initialization()!
        room.appoinmentsData = AppDelegate.appoinmentslData
        self.applyAllSelectedColour = ""
        self.applyAllSelectedMoldName = ""
        self.navigationController?.pushViewController(room, animated: true)
    }
    
    @IBAction func applyAllDeliveryBtnAction(_ sender: UIButton) 
    {
        if applyAllSelectMoldingTxtFld.text == "Select Molding"
        {
            self.alert("Please select Molding first", nil)
        }
        else
        {
            applyDeliveryOptions = getMoldDeliveryOptions(for: applyAllSelectMoldingTxtFld.text! , isCell: false)
            if applyDeliveryOptions.count > 0
            {
                self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, applyDeliveryOptions, -1, delegate: self, tag: 6, cell: sender.tag)
            }
            else
            {
                self.alert("Delivery not available for this Molding type", nil)
            }
        }
    }
    
    @IBAction func applyAllSelectMoldingdropBtnAction(_ sender: UIButton)
    {
        var value:[String] = []
        var moldingPriceValue :[Double] = []
        let  moldValue = self.getMoldList()
        value = moldValue.compactMap({$0.name})
        moldingPriceValue = moldValue.compactMap({$0.unit_price})
        self.moldingPriceArray = moldingPriceValue
        self.moldingNamesArray = value
        if(value.count != 0)
        {
            self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 4, cell: sender.tag)
        }
        else
        {
            self.alert("Not Available", nil)
        }
    }
    @IBAction func applyAllBtnAction(_ sender: UIButton)
    {
        var isGlueDown:Bool = Bool()
        for rooms in tableValues
        {
            
            
            if rooms.room_area != 0
            {
                if  applyAllSelectColorTxtFld.text != "Select Color"
                {
                    // auto calculation for gluedown
                    let masterData = getMasterDataFromDB()
                    if masterData.autoAnswerLogicList.count > 0
                    {
                        let autoAnswerLogicListArray = masterData.autoAnswerLogicList
                        let hasMatchingColorWithGlueDown = floorColorNamesArray.contains {
                            $0.color == self.applyAllSelectedColour && $0.glueDown == 1
                        }

                        if hasMatchingColorWithGlueDown
                        {
                            isGlueDown = true
                            let roomName = rooms.room_name ?? ""
                            let roomID = rooms.room_id ?? 0
                            let summaryData = self.createSummaryData(roomID: roomID, roomName: roomName)
                            let questionnaire = summaryData.questionaire
                            if questionnaire!.count > 0
                            {
                                var excludedQuestions:[SummeryQustionsDetails] = []
                                for excludedId in autoAnswerLogicListArray[0].questionLines[0].excludedQuestionId
                                {
                                    excludedQuestions.append(contentsOf: (questionnaire?.filter({$0.question_id == excludedId}))!)
                                }
                                if excludedQuestions.count > 0
                                {
                                    var answered = false
                                    for answers in excludedQuestions
                                    {
                                        if answers.answers![0].answer != ""
                                        {
                                            if answered == true
                                            {
                                                answered = true
                                            }
                                            else
                                            {
                                                answered = true
                                            }
                                        }
                                    }
                                    if answered == false
                                    {
                                        let roomId = rooms.room_id
                                        let appointmentId = AppointmentData().appointment_id ?? 0
                                        let currentCoveringAnswer = getAnswer(for: "CurrentCoveringType", appointmentId: appointmentId, roomId: roomId ?? 0)
                                        let existingSubSurfaceAnswer = getAnswer(for: "ExistingSubSurface", appointmentId: appointmentId, roomId: roomId ?? 0)
                                        let removeCurrentCoveringAnswer = getAnswer(for: "RemoveCurrentCovering", appointmentId: appointmentId, roomId: roomId ?? 0 )
                                        
                                        let formula = autoAnswerLogicListArray[0].questionLines[0].code ?? ""//"room_area / 32 if !actual_surface.lowercased().contains(\"concrete\")"
                                        let variables: [String: Any] = [
                                            "room_area": rooms.adjusted_area!,
                                            "current_surface": currentCoveringAnswer,
                                            "sub_surface": existingSubSurfaceAnswer,
                                            "remove_current_surface": removeCurrentCoveringAnswer
                                        ]
                                        
                                        if let result = applyFormula(formula, variables: variables) {
                                            print("Result: \(result)")
                                            let realm = try! Realm()
                                            try! realm.write {
                                                var plywoodValueStr:String = String()
                                                let plywoodValue = result
                                                if plywoodValue == floor(plywoodValue)
                                                {
                                                    plywoodValueStr = String(Int(plywoodValue) )
                                                }
                                                else
                                                {
                                                    plywoodValueStr = String(Int(plywoodValue) + 1)
                                                }
                                                
                                                // Check if answer already exists for this question
                                                let excludedId = autoAnswerLogicListArray[0].questionLines[0].questionId
                                                if let question = realm.objects(rf_master_question.self).filter("id == %d AND room_id == %d AND appointment_id == %d", excludedId, roomId,appoinmentID).first {
                                                    if let existingAnswer = question.rf_AnswerOFQustion.first {
                                                        if !existingAnswer.answer.contains(plywoodValueStr) {
                                                            existingAnswer.answer.append(plywoodValueStr)
                                                            let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
                                                            
                                                            let answerDict = ["id":UUID().uuidString,"question_id":question.id,"appointment_id":question.appointment_id,"answer":[plywoodValueStr]]
                                                            newAnswer.append(rf_AnswerForQuestion(qstnAnsDict: answerDict))
                                                            print("Created new answer object with plywood value: \(plywoodValueStr)")
                                                            var dict:[String:Any] = [:]
                                                            let questionUniqueIdentifier = question.questionIdUnique
                                                            let questionId = question.id
                                                            dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":roomId,"room_name":roomName]
                                                            print("---dict2------", dict, " question : ", question.question_name)
                                                            realm.create(rf_master_question.self, value: dict, update: .all)
                                                            print("Appended new plywood value to existing answer: \(plywoodValueStr)")
                                                        } else {
                                                            print("Answer already contains the plywood value. Skipping.")
                                                        }
                                                    } else {
                                                        // Create and append new rf_AnswerForQuestion
                                                        
                                                        let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
                                                        
                                                        let answerDict = ["id":UUID().uuidString,"question_id":question.id,"appointment_id":question.appointment_id,"answer":[plywoodValueStr]]
                                                        print("Created new answer object with plywood value: \(plywoodValueStr)")
                                                        var dict:[String:Any] = [:]
                                                        let questionUniqueIdentifier = question.questionIdUnique
                                                        let questionId = question.id
                                                        dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":roomId,"room_name":roomName]
                                                        print("---dict2------", dict, " question : ", question.question_name)
                                                        realm.create(rf_master_question.self, value: dict, update: .all)
                                                    }
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            
                                            
                                            // Should print 5.0
                                        } else {
                                            print("Condition not met or invalid formula")
                                        }
                                        
                                        
                                        
                                        //calculateAnswerForGlueDownPlywood(roomArea: tableValues[cell].adjusted_area!, calulationCode: autoAnswerLogicListArray[0].questionLines[0].code!,roomId:tableValues[cell].room_id!,roomName:tableValues[cell].room_name!,excludedId:autoAnswerLogicListArray[0].questionLines[0].questionId)
                                    
                                
                                    }
                                }
                                
                            }
                        }
                        else
                        {
//                            let appointmentId = AppointmentData().appointment_id ?? 0
//                            let realm = try! Realm()
//                            if let question = realm.objects(rf_master_question.self).filter("id == %d AND room_id == %d AND appointment_id == %d", autoAnswerLogicListArray[0].questionLines[0].questionId, rooms.room_id!,appoinmentID).first {
//                                
//                                try! realm.write
//                                {
//                                    if let existingAnswer = question.rf_AnswerOFQustion.first {
//                                        let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
//                                        
//                                        let answerDict = ["id":UUID().uuidString,"question_id":-1,"appointment_id":question.appointment_id,"answer":[]]
//                                        newAnswer.append(rf_AnswerForQuestion(qstnAnsDict: answerDict))
//                                        
//                                        // Append it to rf_master_question
//                                        //question.rf_AnswerOFQustion.append(newAnswer)
//                                        
//                                        //print("Created new answer object with plywood value: \(plywoodValueStr)")
//                                        var dict:[String:Any] = [:]
//                                        let questionUniqueIdentifier = question.questionIdUnique
//                                        let questionId = question.id
//                                        dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":rooms.room_id!,"room_name":rooms.room_name!]
//                                        print("---dict2------", dict, " question : ", question.question_name)
//                                        realm.create(rf_master_question.self, value: dict, update: .all)
//                                    }
//                                }
//                            }
                        }
                    }
                    self.updateRoomMoldOrColor(roomID: rooms.room_id ?? 0, moldName: "", isColor: true, colorName: applyAllSelectedColour, colorImageUrl: applyAllSelectedMaterialFileName, colorUpCharge: applyAllColourUpCharge, moldPrice: 0.0,deliveryOptions: "",isGlueDown: isGlueDown)
                }
                else
                {
                    self.updateRoomMoldOrColor(roomID: rooms.room_id ?? 0, moldName: "", isColor: true, colorName: rooms.color ?? "", colorImageUrl: rooms.material_image_url ?? "", colorUpCharge: rooms.colorUpCharge ?? 0.0, moldPrice: 0.0,deliveryOptions: "")
                }
                
                if applyAllSelectMoldingTxtFld.text != "" && applyAllSelectedMoldName != ""
                {
                    if rooms.room_name!.contains("STAIRS") && rooms.room_area == 0.0
                    {
                    }
                    else
                    {
                        if applyAllSelectedMoldName == ""
                        {
                            applyAllSelectedMoldName = rooms.moulding ?? ""
                            applyAllSelectedMoldPrice = rooms.mouldingPrice ?? 0.0
                        }
                        if applyDefaultDelivery != ""
                        {
                            self.updateRoomMoldOrColor(roomID: rooms.room_id ?? 0, moldName: applyAllSelectedMoldName, moldPrice: applyAllSelectedMoldPrice,deliveryOptions: applyAllSelectDeliveryTxtFld.text!)
                        }
                        else
                        {
                            self.updateRoomMoldOrColor(roomID: rooms.room_id ?? 0, moldName: applyAllSelectedMoldName, moldPrice: applyAllSelectedMoldPrice)
                        }
                    }
                }
            }
        }
        
        self.loadRefreshData()
    }
    
    @IBAction func applyAllSelectColorDropDownBtnAction(_ sender: UIButton)
    {
        var value:[String] = []
        value = self.floorColorNamesArray.compactMap({$0.color})
        if(value.count != 0)
        {
            self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 3, cell: sender.tag,selectedIndex: roomIndex,floorColor: floorColorNamesArray,isColour: true)
        }
        else
        {
            self.alert("Not Available", nil)
        }
    }
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if(validationTileColorRoomName != "")
        {
            self.alert("Please choose flooring color for \(validationTileColorRoomName)", nil)
            
        }
        else if (validationMoldingColorRoomName != "")
        {
            self.alert("Please choose molding option for \(validationMoldingColorRoomName)", nil)
            
        }
        else
        {
            if(self.area > 0 || self.stairCount > 0)
            {
                let roomsWithoutImage = tableValues.filter({$0.room_image_url == ""})
                if roomsWithoutImage.count > 0{
                    self.alert("Please add image for \(roomsWithoutImage[0].name ?? "room")", nil)
                    return
                }
                for room in tableValues{
                    if self.checkIfAnswerPendingForAnyMandatoryQuestion(appointmentId: appoinmentID, roomId: room.room_id ?? -1,roomName: room.name ?? "",roomArea: room.room_area ?? 0.0){
                        self.alert("Please answer mandatory questions for \(room.name ?? "room")", nil)
                        return
                    }
                }
                //arb
                let appointmentId = AppointmentData().appointment_id ?? 0
                let currentClassName = String(describing: type(of: self))
                let classDisplayName = "MeasurementList"
                getAppointmentResultToShow(className: classDisplayName, isNextBtn: true)
                self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
                //
                let paymentOptions = PaymentOptionsNewViewController.initialization()!
                paymentOptions.area = self.area
                
                
                for rooms in tableValues
                {
                    let summaryData = self.createSummaryData(roomID: rooms.room_id ?? 0, roomName: rooms.room_name ?? "")
                    let questionAnswer = setQuestion(summaryData: summaryData)
                    submitApiCall(roomID: rooms.room_id ?? 0, qustionAnswer: questionAnswer, roomName: rooms.room_name ?? "")
                }
               
                //arb
                let (totalUpchargeForAllRooms,extraCostConsideringQuestions, extraCostToExclude,totalStairCount, extraPromoCostExcluded) = self.calculateFloorColorUpchargeAndExtraCost(rooms: self.tableValues)
                let totalMoldingPrice = calculateMoldingPrice(rooms: self.tableValues)
                print(totalUpchargeForAllRooms)
                print(extraCostConsideringQuestions)
                paymentOptions.stairCount = totalStairCount
                paymentOptions.totalUpchargeCost = totalUpchargeForAllRooms
                paymentOptions.totalExtraCost = extraCostConsideringQuestions + vaporbarrierValue
                paymentOptions.totalMoldingPrice = totalMoldingPrice
                paymentOptions.totalExtraCostToReduce = extraCostToExclude
                paymentOptions.totalExtraPromoCostToReduced = extraPromoCostExcluded + vaporbarrierValue + totalMoldingPrice 
                paymentOptions.vapurBarrierValue = vaporbarrierValue
                paymentOptions.discount_exclude_amount = extraCostToExclude
                //
                self.navigationController?.pushViewController(paymentOptions, animated: true)
            }
            else
            {
                self.alert("Please choose at least one room to proceed", nil)
            }
        }
    }
//    func  submitApiCall()
//    {
//        // set value of answerOFQuestion in db
//        let appointmentId = AppointmentData().appointment_id ?? 0
//        for rooms in tableValues
//        {
//            let questionsForAppointment = getQuestionsForAppointment(appointmentId: appointmentId, roomId: rooms.room_id ?? 0)
//        var extraCost:Double = 0.0
//        var extraCostExclude:Double = 0.0
//        var extrapromoToexclude:Double = 0.0
//        for i in 0..<questionsForAppointment.count{
//            let questionsArray = List<rf_AnswerForQuestion>()
//            let question = questionsForAppointment[i]
//            let qustionAnswer = setQuestion()
//            let questionAnswerForQuestionIdArr = self.qustionAnswer.filter({$0.id == question.id})
//            if questionAnswerForQuestionIdArr.count == 1{
//                let questionAnswerForQuestionId = questionAnswerForQuestionIdArr.first!
//                if let answerOFQustion = questionAnswerForQuestionId.answerOFQustion{
//                    let rf_answerOfQstn = chooseAnswerBasedOnQuestionType(question: question, answer: answerOFQustion)
//                    questionsArray.append(rf_AnswerForQuestion(qstnAnsDict: rf_answerOfQstn))
//                    do{
//                        let realm = try Realm()
//                        try realm.write{
//                            var dict:[String:Any] = [:]
//                            let questionUniqueIdentifier = question.questionIdUnique
//                            let questionId = question.id
//                            dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":questionsArray,"appointment_id":appointmentId,"room_id":roomID,"room_name":roomName]
//                            print("---dict2------", dict, " question : ", question.question_name)
//                            realm.create(rf_master_question.self, value: dict, update: .all)
//                            questionsForAppointment[i].rf_AnswerOFQustion = questionsArray
//                            
//                            let additionalCost = self.calculateExtraPrice(question: question, answerOfQuestion: questionsArray)
//                            print("------additionalCost1 : ", additionalCost, " question1 : ", question.question_code)
//                            if question.exclude_from_discount{
//                                extraCostExclude = extraCostExclude + additionalCost
//                                print("------additionalCost_extraCostExclude1 : ", extraCostExclude)
//                            }
//                            if question.exclude_from_promotion
//                            {
//                                extrapromoToexclude = extrapromoToexclude + additionalCost
//                                print("------additionalCost_extrapromoToexclude : ", extrapromoToexclude)
//                            }
//                            extraCost = extraCost + additionalCost
//                            print("------additionalCost_extraCost1 : ", extraCost)
//                        }
//                    }catch{
//                        print(RealmError.initialisationFailed)
//                    }
//                }
//            }
//            
//            
//        }
//        
//        print("additionalCost for room", extraCost)
//        self.saveQuestionAndAnswerToCompletedAppointment(roomId: roomID, questionAndAnswer: questionsForAppointment)
//        //save extra cost of selected room to appointment
//        self.saveExtraCostToCompletedAppointment(roomId: self.roomID, extraCost: extraCost)
//        //save extra cost to exclude
//        self.saveExtraCostExcludeToCompletedAppointment(roomId: self.roomID, extraCostExclude: extraCostExclude,extraPromoPriceToExclude: extrapromoToexclude)
//        //to save stair count and width to appointment room details
//        if roomName.localizedCaseInsensitiveContains("stair"){
//            self.saveStairDetailsToCompletedAppointment(roomId: self.roomID)
//        }
//    }
//    }
    
//    func setQuestion(summaryData:SummeryDetailsData) -> [QuestionsMeasurementData]
//    {
//        let appointmentId = AppointmentData().appointment_id ?? 0
//        var questionsList = RealmSwift.List<rf_master_question>()
//        let roomID = summaryData.room_id ?? 0
//        questionsList = self.getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID)
//        var qustionAnswer: [QuestionsMeasurementData] = []
//        questionsList.forEach{ question in
//            if /*!roomName.localizedCaseInsensitiveContains("stair")*/  summaryData.room_area != 0 {
//                if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "rooms"){
//                    qustionAnswer.append(QuestionsMeasurementData(masterQuestions: question))
//                }
//            }else{
//                if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "stairs"){
//                    qustionAnswer.append(QuestionsMeasurementData(masterQuestions: question))
//                }
//            }
//           
//        }
//        
//        self.qustionAnswer = qustionAnswer
//        foreditingFunctions()
//    }
    
    
    
    
    func setQuestion(summaryData:SummeryDetailsData) -> [QuestionsMeasurementData]
    {
        
        var qustionAnswerArray:[QuestionsMeasurementData] = []
        let appointmentId = AppointmentData().appointment_id ?? 0
        var questionsList = RealmSwift.List<rf_master_question>()
        let roomID = summaryData.room_id ?? 0
        questionsList = self.getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID)
        var qustionAnswer: [QuestionsMeasurementData] = []
        questionsList.forEach{ question in
            if /*!roomName.localizedCaseInsensitiveContains("stair")*/  summaryData.room_area != 0 {
                if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "rooms"){
                    qustionAnswer.append(QuestionsMeasurementData(masterQuestions: question))
                }
            }else{
                if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "stairs"){
                    qustionAnswer.append(QuestionsMeasurementData(masterQuestions: question))
                }
            }
           
        }
        
        qustionAnswerArray = qustionAnswer
        let questionAnswer = foreditingFunctions(qustionAnswer: qustionAnswerArray, summaryData: summaryData)
        return questionAnswer
    }
    
    func foreditingFunctions(qustionAnswer:[QuestionsMeasurementData],summaryData:SummeryDetailsData) -> [QuestionsMeasurementData]
    {
        for qustion in qustionAnswer
        {
            for answer in summaryData.questionaire ?? []
            {
                if qustion.id == answer.question_id
                {
                    if(answer.question_type == "numerical_box")
                    {
                        if (answer.answers ?? []).count == 1
                        {
                            let value = Int(answer.answers![0].answer ?? "") ?? 0
                            let val =  AnswerOFQustion(value)
                            if answer.question_id == 9
                            {
                                let value = Double(answer.answers![0].answer ?? "") ?? 0.0
                                let strairVal = AnswerOFQustion(value)
                                qustion.answerOFQustion = strairVal
                            }
                            val.qustionLineID = answer.contract_question_line_id ?? 0
                            val.answerID = answer.answers![0].id ?? 0
                            
                            
                            if !( answer.question_id == 9)
                            {
                                qustion.answerOFQustion = val
                            }
                        }
                    }
                    else if(answer.question_type == "textbox")
                    {
                        if (answer.answers ?? []).count == 1
                        {
                            let value = answer.answers![0].answer ?? ""
                            let val =  AnswerOFQustion(value)
                            val.qustionLineID = answer.contract_question_line_id ?? 0
                            val.answerID = answer.answers![0].id ?? 0
                            qustion.answerOFQustion = val
                        }
                    }
                    else if(answer.question_type == "simple_choice")
                    {
                        if (answer.answers ?? []).count == 1
                        {
                            let value = QuoteLabelData(question_id: answer.answers![0].id ?? 0, value: answer.answers![0].answer ?? "")
                            let val =  AnswerOFQustion(value)
                            val.qustionLineID = answer.contract_question_line_id ?? 0
                            val.answerID = answer.answers![0].id ?? 0
                            qustion.answerOFQustion = val
                        }
                    }
                    else
                    {
                        var values:[QuoteLabelData] = []
                        for ans in answer.answers ?? []
                        {
                            let value = QuoteLabelData(question_id: ans.id ?? 0, value: ans.answer ?? "")
                            values.append(value)
                        }
                        let val =  AnswerOFQustion(values)
                        val.answerID = answer.answers![0].id ?? 0
                        val.qustionLineID = answer.contract_question_line_id ?? 0
                        qustion.answerOFQustion = val
                    }
                }
            }
        }
        return qustionAnswer
        print(qustionAnswer)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let summery = SummeryDetailsViewController.initialization()!
        let roomName = tableValues[indexPath.row].room_name ?? ""
        let roomID = tableValues[indexPath.row].room_id ?? 0
        let summaryData = self.createSummaryData(roomID: roomID, roomName: roomName) //arb
        summery.summaryData = summaryData
        summery.isADetailView = true
        
        if ((summaryData.room_name ?? "").localizedCaseInsensitiveContains("stair")) {
            summery.isStair = 1
        }
        self.navigationController?.pushViewController(summery, animated: true)
        //self.summeryDetailsDataApiCall(self.tableValues[indexPath.row].contract_measurement_id ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableValues.count //(tableValues.count - 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryListNewTableViewCell") as! SummeryListNewTableViewCell
        //cell.selectColorNewBgView.frame.size.width = cell.colorLabel.frame.size.width
        cell.colorLabel.setRightPaddingPoints(7)
        if ((tableValues[indexPath.row].color ?? "") != "Select Color")
        {
            cell.outOfStockView.clearGradient()
            cell.outOfStockView.applyGradient(colors: [UIColor().colorFromHexString("#72C36F00").cgColor,UIColor().colorFromHexString("#72C36F27").cgColor])
            cell.outOfStockLbl.text = "The selected item is available"
            cell.outOfStockLbl.textColor = UIColor().colorFromHexString("#72C36F")
        }
        
        cell.outOfStockView.layer.cornerRadius = 24
        cell.outOfStockView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMinXMinYCorner]


        let floorName = tableValues[indexPath.row].room_name ?? "Other"
        
        cell.strickView.isHidden = ((tableValues[indexPath.row].striked ?? "").lowercased() == "false")
        cell.floorNameLabel.text = floorName.uppercased()
        // cell.colorView.backgroundColor = .brown
        cell.colorLabel.text = ((tableValues[indexPath.row].color ?? "") == "") ? "Select Color" : (tableValues[indexPath.row].color ?? "")
        //((tableValues[indexPath.row].color ?? "") == "Select Color") ? cell.outOfStockView.isHidden = true : cell.outOfStockView.isHidden = false
        
        if ((tableValues[indexPath.row].color ?? "") == "Select Color")
        {
            cell.outOfStockView.isHidden = true
        }
        else
        {
            cell.outOfStockView.isHidden = false
        }
//        if !((tableValues[indexPath.row].color ?? "") == "Select Color") && tableValues[indexPath.row].room_area == 0.0
//        {
//            let index = stairColourNamesArray.firstIndex(of: stairColourNamesArray.filter({$0.color == self.tableValues[indexPath.row].color}).first ?? rf_stairColour_results()) ?? 0
//            stairIndex = index
//        }
//        else
//        {
//            let index = floorColorNamesArray.firstIndex(of: floorColorNamesArray.filter({$0.color == self.tableValues[indexPath.row].color}).first ?? rf_floorColour_results()) ?? 0
//            roomIndex = index
//        }
        cell.molding.text = ((tableValues[indexPath.row].moulding ?? "") == "") ? "Select Molding" : (tableValues[indexPath.row].moulding ?? "")
        //cell.summeryAttachmentView.loadImageFormWeb(URL(string: tableValues[indexPath.row].room_image_url ?? ""))
        cell.summeryAttachmentView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: tableValues[indexPath.row].room_image_url ?? "")
        cell.selectColor.tag = indexPath.row
        //cell.colorView.loadImageFormWeb(URL(string: tableValues[indexPath.row].material_image_url ?? ""))
        if tableValues[indexPath.row].material_image_url ?? "" == ""{
            cell.colorView.image = UIImage(named: "AppIcon")
        }else{
            print(tableValues[indexPath.row].material_image_url ?? "")
            cell.colorView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: tableValues[indexPath.row].material_image_url ?? "")
            
        }
        cell.selectColor.addTarget(self, action: #selector(getColorPopUpFromTableViewButton(sender:)), for: .touchUpInside)
        cell.selectMolding.tag = indexPath.row
        cell.deliveryBtn.tag = indexPath.row
        
        cell.areaLabel.text = "Area Measured: \((tableValues[indexPath.row].adjusted_area ?? 0).clean) Sq.Ft"
        cell.colorLabel.textColor = UIColor.white
        cell.molding.textColor = UIColor.white
        if(cell.colorLabel.text == "Select Color")
        {
            // isselectedColor=1
            // cell.colorLabel.borderWidth = 3
            cell.colorLabel.textColor = UIColor.redColor
            validationTileColorRoomName = tableValues[indexPath.row].room_name ?? ""
            
        }
        if(cell.molding.text == "Select Molding") && tableValues[indexPath.row].room_area != 0
        {
            
            validationMoldingColorRoomName = tableValues[indexPath.row].room_name ?? ""
            //
            //            if((tableValues[indexPath.row].stair_count ?? 0 ) > 0)
            //            {
            //                 isselectedMolding=0
            //            }
            //            else
            //            {
            //                 isselectedMolding=1
            //            }
            
            // cell.molding.borderWidth = 1
            cell.molding.textColor = UIColor.redColor
        }
        if cell.deliveryTxtFld.text == "Select Delivery" && tableValues[indexPath.row].room_area != 0
        {
            cell.deliveryTxtFld.textColor = UIColor.redColor
        }
        if tableValues[indexPath.row].deliveryOptions == "" ||  tableValues[indexPath.row].deliveryOptions == nil
        {
            cell.deliveryTxtFld.text = "Select Delivery"
            cell.deliveryTxtFld.textColor = UIColor.redColor
        }
        else
        {
            cell.deliveryTxtFld.text = tableValues[indexPath.row].deliveryOptions
            cell.deliveryTxtFld.textColor = UIColor.white
        }
        
        if((tableValues[indexPath.row].stair_count ?? 0 ) > 0 || ((tableValues[indexPath.row].room_name ?? "").localizedCaseInsensitiveContains("stair")) && tableValues[indexPath.row].room_area == 0.0)
        {
            //MoldingTitleLbl.isHidden = true
            // MoldingView.isHidden = true
            cell.areaLabel.text = "Stairs Count: \(tableValues[indexPath.row].stair_count ?? 0)"
              cell.selectMolding.isUserInteractionEnabled = false
            cell.molding.isUserInteractionEnabled = false
            cell.molding.alpha = 0.3
            cell.moldingHeader.alpha = 0.3
            cell.selectMolding.alpha = 0.3
            cell.moldingBgView.alpha = 0.3
            cell.deliveryBtn.isUserInteractionEnabled = false
            cell.deliveryTxtFld.isUserInteractionEnabled = false
            cell.deliveryView.alpha = 0.3
            cell.deliveryTxtFld.alpha = 0.3
            cell.deliveryLbl.alpha = 0.3
          //  cell.selectMolding.addTarget(self, action: #selector(moldingAlert(sender:)), for: .touchUpInside)
        }
        else
        {
            // MoldingTitleLbl.isHidden = false
            // MoldingView.isHidden = false
            cell.selectMolding.isUserInteractionEnabled = true
            cell.selectMolding.alpha = 1
            cell.molding.isUserInteractionEnabled = true
            cell.molding.alpha = 1
            cell.moldingHeader.alpha = 1
            cell.selectMolding.alpha = 1
            cell.moldingBgView.alpha = 1
            cell.selectMolding.addTarget(self, action: #selector(moldingRoomAlert(sender:)), for: .touchUpInside)
            cell.selectMolding.addTarget(self, action: #selector(getmoldingPopUpFromTableViewButton(sender:)), for: .touchUpInside)
            cell.deliveryBtn.isUserInteractionEnabled = true
            cell.deliveryTxtFld.isUserInteractionEnabled = true
            cell.deliveryView.alpha = 1
            cell.deliveryTxtFld.alpha = 1
            cell.deliveryLbl.alpha = 1
            cell.deliveryBtn.addTarget(self, action: #selector(deliveryPopUpFromTableView(sender:)), for: .touchUpInside)
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]?
    {
        
        
        let exclude = UITableViewRowAction(style: .normal, title: (((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? "Exclude": "Include").uppercased()) { action, index in
            //self.DeleteroomMeasurement(self.tableValues[editActionsForRowAt.row], false, message: "Successfully \(((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? "Excluded": "Included")")
            //arb
            let roomId = self.tableValues[editActionsForRowAt.row].room_id ?? 0
            let isStriked = self.tableValues[editActionsForRowAt.row].striked ?? "" == "false" ? true : false
            self.includeOrExcludeRoom(roomID: roomId, isInclude: isStriked)
            self.deleteDiscountArrayFromDb() 
            let okBtn = UIAlertAction(title: "OK", style: .cancel)
            self.alert("Successfully \(((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? "Excluded": "Included")", [okBtn])
            self.loadRefreshData()
            //
            
        }
        exclude.backgroundColor = ((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? UIColor().colorFromHexString("#292562"): .greenColor
        
        
        
        let edit = UITableViewRowAction(style: .normal, title: "Delete".uppercased()) { action, index in
           // self.DeleteroomMeasurement(self.tableValues[editActionsForRowAt.row], true, message: "Successfully Deleted")
            let roomId = self.tableValues[editActionsForRowAt.row].room_id ?? 0
            self.deleteRoom(roomID:roomId)
            self.deleteDiscountArrayFromDb()
            let appointmentId = AppointmentData().appointment_id ?? 0
            self.deleteCustomRoomName(appointmentId: appointmentId, roomId: String(roomId))
            self.loadRefreshData()
        }
        edit.backgroundColor = UIColor().colorFromHexString("#A7B0BA")
        return [exclude, edit]
    }
    func tableReload(_ values:[SummeryListData])
    {
        //SummeryDetailsData
        summaryDetailsData.removeAll()
        self.tableValues = values
        var area:Double = 0
        var stairTemp:Int = 0
        var validationTempTileColorRoomName = ""
        var validationTempMoldingColorRoomName = ""
        var vaporArea:Double = 0
        //var validationTileColor = ""
        
        for value in values
        {
            if (value.striked ?? "").lowercased() == "false"
            {
                area += value.adjusted_area ?? 0
                stairTemp += value.stair_count ?? 0
                if(value.color == "Select Color")
                {
                    validationTempTileColorRoomName = value.room_name ?? ""
                }
                if value.stair_count == 0 || value.stair_count == nil
                {
                    self.summaryDetailsData.append(self.createSummaryData(roomID: value.room_id!, roomName: value.room_name!))
                }
                if(value.moulding == "")
                {
                    
                  //  if(value.room_name != "Stairs")
                    let string = value.room_name!
                    if(!((string.contains("STAIR")) || (string.contains("stair")) || (string.contains("Stair"))) && value.room_area! > 0)
                    {
                        validationTempMoldingColorRoomName = value.room_name ?? ""
                    }
                }
            }
        }
        self.area = area
        self.stairCount = stairTemp
        self.validationTileColorRoomName = validationTempTileColorRoomName
        self.validationMoldingColorRoomName = validationTempMoldingColorRoomName
        self.headingLabel.text = "Total Area Measured - \(self.area.clean) Sq.Ft"
        if summaryDetailsData.count > 0
        {
            for summery in summaryDetailsData
            {
                if summery.questionaire!.count > 0
                {
                    
                    //let vaporBarrierQuestionIndex = summery.questionaire?.
                    for roomsAndQuestion in summery.questionaire!
                    {
                        
                        
                        if (roomsAndQuestion.name == "VaporBarrierBool" && roomsAndQuestion.answers![0].answer == "Yes" && roomsAndQuestion.calculate_order_wise == true)
                        {
                            vaporArea += summery.adjusted_area!
                        }
                    }
                }
            }
        }
        var vapourBarrierValue : Int = Int()
        let vapourValue = modf(vaporArea / 100)
        if vapourValue.1 == 0.0
        {
            vapourBarrierValue = Int(vapourValue.0)
        }
        else
        {
            vapourBarrierValue = Int(vapourValue.0) + 1
        }
        self.vapourBarrierLbl.text = "Vapor Barrier - \(vapourBarrierValue)"
        if UserDefaults.standard.value(forKey: "VaporBarrierAmount") != nil
        {
            vaporbarrierValue = UserDefaults.standard.value(forKey: "VaporBarrierAmount") as! Double
            vaporbarrierValue = vaporbarrierValue * Double(vapourBarrierValue)
        }
        self.tableView.reloadData()
    }
    @objc func deliveryPopUpFromTableView(sender:UIButton)
    {
        if tableValues[sender.tag].moulding == ""
        {
            self.alert("Please select Molding first", nil)
        }
        else
        {
            cellDeliveryOptions = getMoldDeliveryOptions(for: tableValues[sender.tag].moulding! , isCell: true)
            if cellDeliveryOptions.count > 0
            {
                self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, cellDeliveryOptions, -1, delegate: self, tag: 5, cell: sender.tag)
            }
            else
            {
                //cellDeliveryOptions = getMoldDeliveryOptions(for: tableValues[sender.tag].moulding! , isCell: true)
                self.alert("Delivery not available for this Molding type", nil)
            }
        }
    }
    @objc func getColorPopUpFromTableViewButton(sender:UIButton)
    {
        var value:[String] = []
        //arb
        if tableValues[sender.tag].room_name!.contains("STAIRS") && tableValues[sender.tag].room_area == 0.0//roomName.contains("STAIRS")
        {
            value = self.stairColourNamesArray.compactMap({$0.color})
        }
        else
        {
            
            value = self.floorColorNamesArray.compactMap({$0.color})
        }
        
        //
//        for val in tableValues[sender.tag].material_colors ?? []
//        {
//            value.append(val.color ?? "Unknown")
//        }
//        if !((tableValues[sender.tag].color ?? "") == "Select Color") && tableValues[sender.tag].room_area == 0.0
//        {
//            let index = stairColourNamesArray.firstIndex(of: stairColourNamesArray.filter({$0.color_name == self.tableValues[sender.tag].color}).first ?? rf_stairColour_results()) ?? -1
//            stairIndex = index
//        }
//        else
//        {
//            let index = floorColorNamesArray.firstIndex(of: floorColorNamesArray.filter({$0.color_name == self.tableValues[sender.tag].color}).first ?? rf_floorColour_results()) ?? -1
//            roomIndex = index
//        }
        
        if(value.count != 0)
        {
           if tableValues[sender.tag].room_area == 0.0
            {
               self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 1, cell: sender.tag,selectedIndex: stairIndex,stairColour: stairColourNamesArray,isColour: true)
           }
            else
            {
                self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 1, cell: sender.tag,selectedIndex: roomIndex,floorColor: floorColorNamesArray,isColour: true)
            }
        }
        else
        {
            self.alert("Not Available", nil)
        }
        
    }
    @objc func getmoldingPopUpFromTableViewButton(sender:UIButton)
    {
        //  self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, ["VINYL WHITE","PRIMED WHITE","UNFINISHED","MATCHING"], -1, delegate: self, tag: 2, cell: sender.tag)
        
        
        var value:[String] = []
        var moldingPriceValue :[Double] = []
        //arb
        let  moldValue = self.getMoldList()
        value = moldValue.compactMap({$0.name})
        moldingPriceValue = moldValue.compactMap({$0.unit_price})
        self.moldingPriceArray = moldingPriceValue
        self.moldingNamesArray = value
        //let deliveryOptions = moldValue.compactMap({$0.deliveryOptions})
        
        //
//        for val in tableValues[sender.tag].molding_Type ?? []
//        {
//            value.append(val.name ?? "Unknown")
//        }
        
        if(value.count != 0)
        {
            self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 2, cell: sender.tag)
        }
        else
        {
            self.alert("Not Available", nil)
        }
        
        
        
        
        
    }
    
    func getMoldDeliveryOptions(for moldingName: String,isCell:Bool) -> [String] {
        var deliveryOptionsArray: [String] = []
        do {
            let realm = try Realm()
            
            // Fetch the molding object with the specified molding_id
            if let molding = realm.objects(rf_master_molding.self).filter("name == %@", moldingName).first {
                // Access the delivery options and convert to an array
                deliveryOptionsArray = Array(molding.deliveryOptions)
                if isCell
                {
                    cellDefaultDelivery = molding.defaultDelivery ?? ""
                }
                else
                {
                    applyDefaultDelivery = molding.defaultDelivery ?? ""
                }
            }
        } catch {
            print(RealmError.initialisationFailed.rawValue)
        }
        return deliveryOptionsArray
    }
//    @objc func moldingAlert(sender:UIButton)
//    {
//        self.alert("Molding option is not available for Stairs", nil)
//    }
    @objc func moldingRoomAlert(sender:UIButton)
    {
        //self.alert("Molding option is not available for Stairs", nil)
    }
    func updateTitleColorApi(measurement_id:Int,material_id:Int)
    {
        globalMeasurement_id = measurement_id
        globalColor_id = material_id
        let parameter:[String : Any] =  ["token":UserData.init().token ?? "","data": [ "measurement_id": measurement_id,"material_id":material_id]]
        
        HttpClientManager.SharedHM.UpdateTilesColorApi(parameter: parameter) { (success, message) in
            if(success ?? "").lowercased() == "success" || (success ?? "").lowercased() == "true"
            {
                // self.isselectedColor = 0
                self.summertListApi()
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.updateTitleColorApi(measurement_id: self.globalMeasurement_id,material_id: self.globalColor_id)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func updateMouldingApi(measurement_id:Int,moulding_type:String)
    {
        globalMeasurement_id = measurement_id
        globalMoldingName = moulding_type
        
        let parameter:[String : Any] =  ["token":UserData.init().token ?? "","data": [ "measurement_id": measurement_id,"moulding_type":moulding_type]]
        
        HttpClientManager.SharedHM.UpdateMoldingApi(parameter: parameter) { (success, message) in
            if(success ?? "").lowercased() == "success" || (success ?? "").lowercased() == "true"
            {
                //   self.isselectedMolding = 0
                self.summertListApi()
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.updateMouldingApi(measurement_id: self.globalMeasurement_id,moulding_type: self.globalMoldingName)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    
    func  submitApiCall(roomID:Int,qustionAnswer:[QuestionsMeasurementData],roomName:String)
    {
        // set value of answerOFQuestion in db
        let appointmentId = AppointmentData().appointment_id ?? 0
        
        let questionsForAppointment = getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID)
        var extraCost:Double = 0.0
        var extraCostExclude:Double = 0.0
        var extrapromoToexclude:Double = 0.0
        var stair_Count:String = ""
        var currentSurfaceAnswerScore = 0.0
        for i in 0..<questionsForAppointment.count{
            let questionsArray = List<rf_AnswerForQuestion>()
            let question = questionsForAppointment[i]
            let questionAnswerForQuestionIdArr = qustionAnswer.filter({$0.id == question.id})
            
            if questionAnswerForQuestionIdArr.count == 1{
                let questionAnswerForQuestionId = questionAnswerForQuestionIdArr.first!
                if let answerOFQustion = questionAnswerForQuestionId.answerOFQustion{
                    let rf_answerOfQstn = chooseAnswerBasedOnQuestionType(question: question, answer: answerOFQustion)
                    questionsArray.append(rf_AnswerForQuestion(qstnAnsDict: rf_answerOfQstn))
                    do{
                        let realm = try Realm()
                        try realm.write{
                            var dict:[String:Any] = [:]
                            let questionUniqueIdentifier = question.questionIdUnique
                            let questionId = question.id
                            dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":questionsArray,"appointment_id":appointmentId,"room_id":roomID,"room_name":roomName]
                            print("---dict2------", dict, " question : ", question.question_name)
                            realm.create(rf_master_question.self, value: dict, update: .all)
                            questionsForAppointment[i].rf_AnswerOFQustion = questionsArray
                            
                            if question.question_code == "StairCount" {
                                stair_Count = questionsArray.first?.answer.first ?? ""
                            }
                            if question.question_code == "CurrentCoveringType"
                            {
                                //extra_price = 0.0
                                currentSurfaceAnswerScore = question.quote_label.filter({$0.value == questionsArray.first?.answer.first ?? ""}).first?.answer_score ?? 0.0
                                //return currentSurfaceAnswerScore//satheesh
                            }
//                            else
//                            {
//                                currentSurfaceAnswerScore = 0.0
//                            }
                            let additionalCost = self.calculateExtraPrice(question: question, answerOfQuestion: questionsArray, roomID: roomID,stair_Count: stair_Count,currentSurfaceAnswerScore: currentSurfaceAnswerScore)
                            print("------additionalCost1 : ", additionalCost, " question1 : ", question.question_code)
                            if question.exclude_from_discount{
                                extraCostExclude = extraCostExclude + additionalCost
                                print("------additionalCost_extraCostExclude1 : ", extraCostExclude)
                            }
                            if question.exclude_from_promotion
                            {
                                extrapromoToexclude = extrapromoToexclude + additionalCost
                                print("------additionalCost_extrapromoToexclude : ", extrapromoToexclude)
                            }
                            extraCost = extraCost + additionalCost
                            print("------additionalCost_extraCost1 : ", extraCost)
                        }
                    }catch{
                        print(RealmError.initialisationFailed)
                    }
                }
            }
            
            
        }
        
        print("additionalCost for room", extraCost)
        self.saveQuestionAndAnswerToCompletedAppointment(roomId: roomID, questionAndAnswer: questionsForAppointment)
        //save extra cost of selected room to appointment
        self.saveExtraCostToCompletedAppointment(roomId: roomID, extraCost: extraCost)
        //save extra cost to exclude
        self.saveExtraCostExcludeToCompletedAppointment(roomId: roomID, extraCostExclude: extraCostExclude,extraPromoPriceToExclude: extrapromoToexclude)
        //to save stair count and width to appointment room details
        if roomName.localizedCaseInsensitiveContains("stair"){
            self.saveStairDetailsToCompletedAppointment(roomId: roomID)
        }
    }
    
    func calculateExtraPrice(question:rf_master_question,answerOfQuestion:List<rf_AnswerForQuestion>,roomID: Int,stair_Count:String = "",currentSurfaceAnswerScore:Double = 0.0) -> Double{
        var extra_price :Double = 0.0
        var amount :Double = 0.0
        var amountIncluded :Double = 0.0
        var simpleChoiceTypeCheck :Bool = false
        var answer_score :Double = 0.0
//        var stair_Count = ""
//        var currentSurfaceAnswerScore = 0.0
        //var roomID = 0
        
//        if question.question_code == "StairCount" {
//            stair_Count = answerOfQuestion.first?.answer.first ?? ""
//        }
        
        let answerData1 = answerOfQuestion.first?.answer.first
        if question.question_code == "StairCoverRisers" {
            if let answer = answerData1 {
                if answer.contains("White Risers") {
                    do {
                        answer_score = question.quote_label.filter({$0.value == answerOfQuestion.first?.answer.first ?? ""}).first?.answer_score ?? 0.0
                        return (Double(stair_Count) ?? 0.0) * answer_score
                    } catch {
                        return 0
                    }
                }
            }
        }
        
        if question.question_code == "CurrentCoveringType"{
            extra_price = 0.0
           // currentSurfaceAnswerScore = question.quote_label.filter({$0.value == answerOfQuestion.first?.answer.first ?? ""}).first?.answer_score ?? 0.0
            return 0.0//currentSurfaceAnswerScore//satheesh
        }
        amount = question.amount
        amountIncluded = Double(question.amount_included)
        let answerData = answerOfQuestion.first?.answer.first
        if question.question_code == "RemoveCurrentCovering"{
            if let answer = answerData{
                if answer == "Yes"{
                    let room_area = self.getTotalAdjustedAreaForRoom(roomId: roomID)
                    if room_area != 0
                    {
                        let net_room_area = room_area - amountIncluded > 0 ? room_area - amountIncluded : 0
                        extra_price = net_room_area * currentSurfaceAnswerScore
                    }
                    else
                    {
                        let coverRisersAnswer = self.getCoverRisersAnswer(roomId: roomID)
                        let (stairWidth,stairCount) = self.getStairWidthAndCount(roomId: roomID)
                        if coverRisersAnswer == "Yes"
                        {
                            extra_price = (stairWidth * stairCount * 2.4) * currentSurfaceAnswerScore
                        }
                        else
                        {
                            extra_price = (stairWidth * stairCount * 1.6 ) * currentSurfaceAnswerScore
                        }
                    }
                }
            }
        }else{
            if question.question_type == "simple_choice"{
                if let answer = answerData{
                    if answer == "No" || answer == ""{
                        extra_price = 0.0
                        return extra_price//satheesh
                    }else{
                        if amount == 0{
                            let answerScore = question.quote_label.filter({$0.value == answerOfQuestion.first?.answer.first ?? ""}).first?.answer_score ?? 0.0
                            amount = answerScore
                            simpleChoiceTypeCheck = true
                        }
                        else if(amount != 0 && answer != "")
                        {
                            simpleChoiceTypeCheck = true
                        }
                    }
                    
                }
            }
            
            switch question.calculation_type ?? "" {
            case "fixed":
                if let answer = answerData{
                    let answer = (Double(answer) ?? 0.0)
                    if(answer == 0 && !simpleChoiceTypeCheck)
                    {
                        extra_price = amount * answer
                    }
                    else{
                        extra_price = amount
                        
                    }
                }
            case "unit":
                if let answer = answerData{
                    if question.question_type == "simple_choice" && answer == "Yes" && question.calculate_order_wise == false{
                        extra_price = amount
                    }
                    else if question.question_type == "numerical_box"
                    {
                        extra_price = (Double(answer) ?? 0.0) * amount
                    }
                }
            case "sqft":
                if question.question_type == "simple_choice"{
                    let room_area = self.getTotalAdjustedAreaForRoom(roomId: roomID)
                    let net_room_area = (room_area - amountIncluded) > 0 ? room_area - amountIncluded : 0
                    extra_price = net_room_area * amount
                }else{
                    if question.multiply_with_area{
                        let room_area = self.getTotalAdjustedAreaForRoom(roomId: roomID)
                        let net_room_area = (room_area - amountIncluded) > 0 ? room_area - amountIncluded : 0
                        if let answer = answerData{
                            extra_price = net_room_area * amount * (Double(answer) ?? 0.0)
                        }
                    }else{
                        if let answer = Double(answerData ?? "0.0"){
                            let net_answer_data = (answer - amountIncluded) > 0 ? answer - amountIncluded : 0
                            extra_price = net_answer_data * amount
                        }
                    }
                }
            default:
                break
            }
            
        }
        return extra_price
    }
    
    
    
    
    func summertListApi()
    {
        HttpClientManager.SharedHM.RoomSummeryListApi(appoinmentID) { (result, message, value) in
            if(result == "Success")
            {
                if(value ?? []).count != 0
                {
                    self.tableReload(value!)
                    self.swipeLeftLbl.isHidden = false
                }
                else
                {
                    let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                        self.tableReload(value!)
                        self.swipeLeftLbl.isHidden = true
                        //self.performSegueToReturnBack()
                    }
                    self.alert("You didn't measured any room" , [ok])
                    
                    
                }
            }
            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.summertListApi()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                //                let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                //                    self.performSegueToReturnBack()
                //                }
                //                self.alert(message ?? AppAlertMsg.serverNotReached , [ok])
            }
        }
        
    }
    
    
    func chooseAnswerBasedOnQuestionType(question:rf_master_question,answer:AnswerOFQustion) -> [String:Any]{
        let questionType = question.question_type
        switch questionType {
        case "simple_choice":
            let value = [(answer.singleSelection?.value ?? "")]
            let param:[String:Any] = ["question_id":question.id ,"answer":value]
            return param
        case "numerical_box":
            let value = ["\(answer.numberVaue ?? 0)"]
            if((answer.numberVaue ?? 0) != 0)
            {
                let param:[String:Any] = ["question_id":question.id ,"answer":value]
                return param
            }
            else if question.id == 9
            {
                let param:[String:Any] = ["question_id":question.id ,"answer":[String(answer.stairWidthDouble)]]
                return param
            }
        case "textbox":
            let value = [(answer.textValue ?? "")]
            if((answer.textValue ?? "") == "")
            {
                let param:[String:Any] = ["question_id":question.id ,"answer":value]
                return param
            }
        case "multiple_choice":
            var value:[String] = []
            for ans in answer.multySelection ?? []
            {
                value.append(ans.value ?? "")
            }
            let param:[String:Any] = ["question_id":question.id ,"answer":value]
            return param
        default:
            return [:]
        }
        return [:]
    }
    func summeryDetailsDataApiCall(_ masuremetID:Int)
    {
        globalMeasurement_id = masuremetID
        HttpClientManager.SharedHM.RoomSummeryDetailsApi(masuremetID) { (result,message, value) in
            if(result == "Success")
            {
                if(value ?? []).count != 0
                {
                    let summery = SummeryDetailsViewController.initialization()!
                    summery.summaryData = value![0]
                    if(value![0].room_name == "Stairs")
                    {
                        summery.isStair = 1
                    }
                    summery.isADetailView = true
                    self.navigationController?.pushViewController(summery, animated: true)
                }
                else
                {
                    self.alert("No record available", nil)
                }
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.summeryDetailsDataApiCall(self.globalMeasurement_id)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                //self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func DeleteroomMeasurement(_ data:SummeryListData,_ isDelete:Bool,message:String)
    {
        let data = ["contract_measurement_id":data.contract_measurement_id ?? 0,"operation":(isDelete) ? "delete": "strike"] as [String : Any]
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        HttpClientManager.SharedHM.DeleteRoomMeasurement(parameter: parameter) { (result, errormessage, valuse) in
            if(result == "True")
            {
                //  let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.summertListApi()
                /// }
                // self.alert(message, [ok])
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.summertListApi()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(errormessage ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return ((self.tableValues[indexPath.row].color ?? "") == "Select Color") ? 200 : 300
//    }
    
    func DropDownDidSelectedAction(index: Int, item: String, tag: Int, cell: Int) 
    {
        
        let masterData = getMasterDataFromDB()
        let officeLocationId = AppDelegate.appoinmentslData.officeLocationId
        if(tag == 2)
        {
            //cell molding
            //  let moudlings = ["VINYL WHITE","PRIMED WHITE","UNFINISHED","MATCHING"]
            //   updateMouldingApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, moulding_type: moudlings[index])
            
            
            //arb
            let selectedMold = self.moldingNamesArray[index]
            let moldPrice = self.moldingPriceArray[index]
            let roomId = self.tableValues[cell].room_id ?? 0
            cellDeliveryOptions = getMoldDeliveryOptions(for: item , isCell: true)
            self.updateRoomMoldOrColor(roomID: roomId, moldName: selectedMold, moldPrice: moldPrice,deliveryOptions: cellDefaultDelivery)
            self.loadRefreshData()
            //
            
            //updateMouldingApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, moulding_type: self.tableValues[cell].molding_Type?[index].name ?? "")
            
            
            
        }
        else if tag == 1
        {
            //updateTitleColorApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, material_id: self.tableValues[cell].material_colors?[index].material_id ?? 0)
            //arb
            if tableValues[cell].room_name!.contains("STAIRS") && tableValues[cell].room_area == 0.0
            {
                
                var isSpecialOrder = false
                var isMarketOutOfStock = false
                for officeids in self.stairColourNamesArray[index].special_order_location_ids
                {
                    if officeids == officeLocationId
                    {
                        isSpecialOrder = true
                    }
                }
                for marketIds in self.stairColourNamesArray[index].Office_location_ids
                {
                    if marketIds == officeLocationId
                    {
                        isMarketOutOfStock = true
                    }
                }
//                if self.stairColourNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */&& InOfficeLocation == true
//                {
//                    let installer = AppointmentPaymentSummaryViewController.initialization()!
//                    installer.isOutOfstock = true
//                    self.present(installer, animated: true, completion: nil)
////                    self.alert("Stock Not Available", nil)
////                    return
//                }
                
//                if self.stairColourNamesArray[index].in_stock == 0
//                {
//                    if self.stairColourNamesArray[index].specialOrder == 1
//                    {
                       if isSpecialOrder && isMarketOutOfStock || isMarketOutOfStock && !isSpecialOrder
                        {
                           let installer = AppointmentPaymentSummaryViewController.initialization()!
                           installer.isOutOfstock = true
                           installer.isSpecialOrder = false
                           self.present(installer, animated: true, completion: nil)
                       }
                        else
                            
                        {
                            stairIndex = index
                            let selectedColor = self.stairColourNamesArray[index].color ?? ""
                            let selectedColorUpCharge = self.stairColourNamesArray[index].color_upcharge
                            let selectedMaterialFileName = self.getStairImageName(atIndex: index + 1)
                            //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
                            let roomId = self.tableValues[cell].room_id ?? 0
                            self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0)
                            self.loadRefreshData()
                            AppDelegate.appoinmentslData.isSpecialOrder = true
                            if isSpecialOrder && !isMarketOutOfStock
                            {
                                let installer = AppointmentPaymentSummaryViewController.initialization()!
                                installer.isOutOfstock = true
                                installer.isSpecialOrder = true
                                self.present(installer, animated: true, completion: nil)
                            }
                        }
//                    }
//                    else
//                    {
//                        let installer = AppointmentPaymentSummaryViewController.initialization()!
//                        installer.isOutOfstock = true
//                        self.present(installer, animated: true, completion: nil)
//                    }
//                }
//                
//                else //(self.stairColourNamesArray[index].specialOrder == 0 && InOfficeLocation == false) || (self.stairColourNamesArray[index].specialOrder == 1)
//                {
//                    stairIndex = index
//                    let selectedColor = self.stairColourNamesArray[index].color ?? ""
//                    let selectedColorUpCharge = self.stairColourNamesArray[index].color_upcharge
//                    let selectedMaterialFileName = self.getStairImageName(atIndex: index + 1)
//                    //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
//                    let roomId = self.tableValues[cell].room_id ?? 0
//                    self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0)
//                    self.loadRefreshData()
//                }
//                if (self.stairColourNamesArray[index].specialOrder == 1) //&& InOfficeLocation == false
//                {
//                    stairIndex = index
//                    let selectedColor = self.stairColourNamesArray[index].color ?? ""
//                    let selectedColorUpCharge = self.stairColourNamesArray[index].color_upcharge
//                    let selectedMaterialFileName = self.getStairImageName(atIndex: index + 1)
//                    //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
//                    let roomId = self.tableValues[cell].room_id ?? 0
//                    self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0)
//                    self.loadRefreshData()
//                }
            }
            else
            {
                
                // Auto Answer logic playwood/gluedown
                let masterData = getMasterDataFromDB()
                if masterData.autoAnswerLogicList.count > 0
                {
                    let autoAnswerLogicListArray = masterData.autoAnswerLogicList
                    if floorColorNamesArray[index].glueDown == 1
                    {
                        let roomName = tableValues[cell].room_name ?? ""
                        let roomID = tableValues[cell].room_id ?? 0
                        let summaryData = self.createSummaryData(roomID: roomID, roomName: roomName)
                        let questionnaire = summaryData.questionaire
                        if questionnaire!.count > 0
                        {
                            var excludedQuestions:[SummeryQustionsDetails] = []
                            for excludedId in autoAnswerLogicListArray[0].questionLines[0].excludedQuestionId
                            {
                                excludedQuestions.append(contentsOf: (questionnaire?.filter({$0.question_id == excludedId}))!)
                            }
                            if excludedQuestions.count > 0
                            {
                                var answered = false
                                for answers in excludedQuestions
                                {
                                    if answers.answers![0].answer != ""
                                    {
                                        if answered == true
                                        {
                                            answered = true
                                        }
                                        else
                                        {
                                            answered = true
                                        }
                                    }
                                }
                                if answered == false
                                {
                                    let roomId = tableValues[cell].room_id
                                    let appointmentId = AppointmentData().appointment_id ?? 0
                                    let currentCoveringAnswer = getAnswer(for: "CurrentCoveringType", appointmentId: appointmentId, roomId: roomId ?? 0)
                                    let existingSubSurfaceAnswer = getAnswer(for: "ExistingSubSurface", appointmentId: appointmentId, roomId: roomId ?? 0)
                                    let removeCurrentCoveringAnswer = getAnswer(for: "RemoveCurrentCovering", appointmentId: appointmentId, roomId: roomId ?? 0 )
                                    
                                    let formula = autoAnswerLogicListArray[0].questionLines[0].code ?? ""//"room_area / 32 if !actual_surface.lowercased().contains(\"concrete\")"
                                    let variables: [String: Any] = [
                                        "room_area": tableValues[cell].adjusted_area!,
                                        "current_surface": currentCoveringAnswer,
                                        "sub_surface": existingSubSurfaceAnswer,
                                        "remove_current_surface": removeCurrentCoveringAnswer
                                    ]
                                    
                                    if let result = applyFormula(formula, variables: variables) {
                                        print("Result: \(result)")
                                        let realm = try! Realm()
                                        try! realm.write {
                                            var plywoodValueStr:String = String()
                                            let plywoodValue = result
                                            if plywoodValue == floor(plywoodValue)
                                            {
                                                plywoodValueStr = String(Int(plywoodValue) )
                                            }
                                            else
                                            {
                                                plywoodValueStr = String(Int(plywoodValue) + 1)
                                            }
                                            
                                            // Check if answer already exists for this question
                                            let excludedId = autoAnswerLogicListArray[0].questionLines[0].questionId
                                            if let question = realm.objects(rf_master_question.self).filter("id == %d AND room_id == %d AND appointment_id == %d", excludedId, roomId,appoinmentID).first {
                                                if let existingAnswer = question.rf_AnswerOFQustion.first {
                                                    if !existingAnswer.answer.contains(plywoodValueStr) {
                                                        existingAnswer.answer.append(plywoodValueStr)
                                                        let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
                                                        
                                                        let answerDict = ["id":UUID().uuidString,"question_id":question.id,"appointment_id":question.appointment_id,"answer":[plywoodValueStr]]
                                                        newAnswer.append(rf_AnswerForQuestion(qstnAnsDict: answerDict))
                                                        print("Created new answer object with plywood value: \(plywoodValueStr)")
                                                        var dict:[String:Any] = [:]
                                                        let questionUniqueIdentifier = question.questionIdUnique
                                                        let questionId = question.id
                                                        dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":roomId,"room_name":roomName]
                                                        print("---dict2------", dict, " question : ", question.question_name)
                                                        realm.create(rf_master_question.self, value: dict, update: .all)
                                                        print("Appended new plywood value to existing answer: \(plywoodValueStr)")
                                                    } else {
                                                        print("Answer already contains the plywood value. Skipping.")
                                                    }
                                                } else {
                                                    // Create and append new rf_AnswerForQuestion
                                                    
                                                    let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
                                                    
                                                    let answerDict = ["id":UUID().uuidString,"question_id":question.id,"appointment_id":question.appointment_id,"answer":[plywoodValueStr]]
                                                    print("Created new answer object with plywood value: \(plywoodValueStr)")
                                                    var dict:[String:Any] = [:]
                                                    let questionUniqueIdentifier = question.questionIdUnique
                                                    let questionId = question.id
                                                    dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":roomId,"room_name":roomName]
                                                    print("---dict2------", dict, " question : ", question.question_name)
                                                    realm.create(rf_master_question.self, value: dict, update: .all)
                                                }
                                            }
                                        }
                                    
                                
                                        
                                        
                                        
                                        
                                        // Should print 5.0
                                    } else {
                                        print("Condition not met or invalid formula")
                                    }
                                    
                                    
                                    
                                    //calculateAnswerForGlueDownPlywood(roomArea: tableValues[cell].adjusted_area!, calulationCode: autoAnswerLogicListArray[0].questionLines[0].code!,roomId:tableValues[cell].room_id!,roomName:tableValues[cell].room_name!,excludedId:autoAnswerLogicListArray[0].questionLines[0].questionId)
                                }
                            }
                            
                        }
                    }
                    else
                    {
//                        let appointmentId = AppointmentData().appointment_id ?? 0
//                        let realm = try! Realm()
//                        if let question = realm.objects(rf_master_question.self).filter("id == %d AND room_id == %d AND appointment_id == %d", autoAnswerLogicListArray[0].questionLines[0].questionId, tableValues[cell].room_id!,appoinmentID).first {
//                            
//                            try! realm.write
//                            {
//                                if let existingAnswer = question.rf_AnswerOFQustion.first {
//                                    let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
//                                    
//                                    let answerDict = ["id":UUID().uuidString,"question_id":-1,"appointment_id":question.appointment_id,"answer":[]]
//                                    newAnswer.append(rf_AnswerForQuestion(qstnAnsDict: answerDict))
//
//                                    // Append it to rf_master_question
//                                    //question.rf_AnswerOFQustion.append(newAnswer)
//
//                                    //print("Created new answer object with plywood value: \(plywoodValueStr)")
//                                    var dict:[String:Any] = [:]
//                                    let questionUniqueIdentifier = question.questionIdUnique
//                                    let questionId = question.id
//                                    dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":tableValues[cell].room_id!,"room_name":tableValues[cell].room_name!]
//                                    print("---dict2------", dict, " question : ", question.question_name)
//                                    realm.create(rf_master_question.self, value: dict, update: .all)
//                                }
//                            }
//                        }
                    }
                    
                }
                
                
                let selectedColor = self.floorColorNamesArray[index].color ?? ""
                var isSpecialOrder = false
                var isMarketOutOfStock = false
                for officeids in self.floorColorNamesArray[index].special_order_location_ids
                {
                    if officeids == officeLocationId
                    {
                        isSpecialOrder = true
                    }
                }
                for marketIds in self.floorColorNamesArray[index].Office_location_ids
                {
                    if marketIds == officeLocationId
                    {
                        isMarketOutOfStock = true
                    }
                }
//                if self.floorColorNamesArray[index].in_stock == 0
//                {
//                    if self.floorColorNamesArray[index].specialOrder == 1
//                    {
                       if isSpecialOrder && isMarketOutOfStock || isMarketOutOfStock && !isSpecialOrder
                        {
                           let installer = AppointmentPaymentSummaryViewController.initialization()!
                           installer.isOutOfstock = true
                           installer.isSpecialOrder = false
                           self.present(installer, animated: true, completion: nil)
                       }
                        else
                        {
                            roomIndex = index
                            let NotOfficeLocation = self.floorColorNamesArray[index].Office_location_ids.filter({$0 == officeLocationId})
                            let selectedColorUpCharge = self.floorColorNamesArray[index].color_upcharge
                            let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
                            //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
                            let roomId = self.tableValues[cell].room_id ?? 0
                            var isGlueDown = false
                            if self.floorColorNamesArray[index].glueDown == 0
                            {
                                isGlueDown = false
                            }
                            else
                            {
                                isGlueDown = true
                            }
                            self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0,isGlueDown:isGlueDown)
                            self.loadRefreshData()
                            AppDelegate.appoinmentslData.isSpecialOrder = true
                            if isSpecialOrder && !isMarketOutOfStock
                            {
                                let installer = AppointmentPaymentSummaryViewController.initialization()!
                                installer.isOutOfstock = true
                                installer.isSpecialOrder = true
                                self.present(installer, animated: true, completion: nil)
                            }
//                        }
//                    }
//                    else
//                    {
//                        let installer = AppointmentPaymentSummaryViewController.initialization()!
//                        installer.isOutOfstock = true
//                        self.present(installer, animated: true, completion: nil)
//                    }
                }
//                if self.floorColorNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */ && InOfficeLocation == true
//                {
//                    let installer = AppointmentPaymentSummaryViewController.initialization()!
//                    installer.isOutOfstock = true
//                    self.present(installer, animated: true, completion: nil)
//                }
//                else //if (self.floorColorNamesArray[index].specialOrder == 0 && InOfficeLocation == false) || self.floorColorNamesArray[index].specialOrder == 1
//                {
//                    roomIndex = index
//                    let NotOfficeLocation = self.floorColorNamesArray[index].Office_location_ids.filter({$0 == officeLocationId})
//                    let selectedColorUpCharge = self.floorColorNamesArray[index].color_upcharge
//                    let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
//                    //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
//                    let roomId = self.tableValues[cell].room_id ?? 0
//                    var isGlueDown = false
//                    if self.floorColorNamesArray[index].glueDown == 0
//                    {
//                        isGlueDown = false
//                    }
//                    else
//                    {
//                        isGlueDown = true
//                    }
//                    self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0,isGlueDown:isGlueDown)
//                    self.loadRefreshData()
//                }
//                else if (self.floorColorNamesArray[index].specialOrder == 1) //&& InOfficeLocation == false
//                {
//                    roomIndex = index
//                    let NotOfficeLocation = self.floorColorNamesArray[index].Office_location_ids.filter({$0 == officeLocationId})
//                    let selectedColorUpCharge = self.floorColorNamesArray[index].color_upcharge
//                    let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
//                    //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
//                    let roomId = self.tableValues[cell].room_id ?? 0
//                    self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0)
//                    self.loadRefreshData()
//                }
                
                
                
               
              
            }
            //
        }
        else if tag == 3
        {
            roomIndex = index
            var isSpecialOrder = false
            var isMarketOutOfStock = false
            for officeids in self.floorColorNamesArray[index].special_order_location_ids
            {
                if officeids == officeLocationId
                {
                    isSpecialOrder = true
                }
            }
            for marketIds in self.floorColorNamesArray[index].Office_location_ids
            {
                if marketIds == officeLocationId
                {
                    isMarketOutOfStock = true
                }
            }
           // if self.floorColorNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */ && InOfficeLocation == true
//            {
//                let installer = AppointmentPaymentSummaryViewController.initialization()!
//                installer.isOutOfstock = true
//                self.present(installer, animated: true, completion: nil)
//            }
//                if self.floorColorNamesArray[index].in_stock == 0
//                {
//                    if self.floorColorNamesArray[index].specialOrder == 1
//                    {
                       if isSpecialOrder && isMarketOutOfStock || isMarketOutOfStock && !isSpecialOrder
                        {
                           let installer = AppointmentPaymentSummaryViewController.initialization()!
                           installer.isOutOfstock = true
                           installer.isSpecialOrder = false
                           self.present(installer, animated: true, completion: nil)
                       }
                        else
                        {
                            roomIndex = index
                            applyAllBtn.isUserInteractionEnabled = true
                            applyAllBtn.setTitleColor(.white, for: .normal)
                            applyAllSelectColorTxtFld.text = item
                            let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
                            applyAllSelectColorImageView.image =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: selectedMaterialFileName)
                            self.applyAllSelectedColour = self.floorColorNamesArray[index].color ?? ""
                            self.applyAllColourUpCharge = self.floorColorNamesArray[index].color_upcharge
                            self.applyAllSelectedMaterialFileName = self.getFllorImageName(atIndex: index)
                            AppDelegate.appoinmentslData.isSpecialOrder = true
                            if isSpecialOrder && !isMarketOutOfStock
                            {
                                let installer = AppointmentPaymentSummaryViewController.initialization()!
                                installer.isOutOfstock = true
                                installer.isSpecialOrder = true
                                self.present(installer, animated: true, completion: nil)
                            }
                            
//                        }
//                    }
//                    else
//                    {
//                        let installer = AppointmentPaymentSummaryViewController.initialization()!
//                        installer.isOutOfstock = true
//                        self.present(installer, animated: true, completion: nil)
//                    }
                }
//            else //if (self.floorColorNamesArray[index].specialOrder == 0  && InOfficeLocation == false) || (self.floorColorNamesArray[index].specialOrder == 1)
//            {
//                roomIndex = index
//                applyAllBtn.isUserInteractionEnabled = true
//                applyAllBtn.setTitleColor(.white, for: .normal)
//                applyAllSelectColorTxtFld.text = item
//                let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
//                applyAllSelectColorImageView.image =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: selectedMaterialFileName)
//                self.applyAllSelectedColour = self.floorColorNamesArray[index].color ?? ""
//                self.applyAllColourUpCharge = self.floorColorNamesArray[index].color_upcharge
//                self.applyAllSelectedMaterialFileName = self.getFllorImageName(atIndex: index)
//                
//               
//                
//            }
            
            
//            if (self.floorColorNamesArray[index].specialOrder == 1) && InOfficeLocation == false
//            {
//                
//                roomIndex = index
//                applyAllBtn.isUserInteractionEnabled = true
//                applyAllBtn.setTitleColor(.white, for: .normal)
//                applyAllSelectColorTxtFld.text = item
//                let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
//                applyAllSelectColorImageView.image =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: selectedMaterialFileName)
//                self.applyAllSelectedColour = self.floorColorNamesArray[index].color ?? ""
//                self.applyAllColourUpCharge = self.floorColorNamesArray[index].color_upcharge
//                self.applyAllSelectedMaterialFileName = self.getFllorImageName(atIndex: index)
//            }
            
        }
        else if tag == 4
        {
//            if self.floorColorNamesArray[index].specialOrder == 0 && self.floorColorNamesArray[index].in_stock == 0
//            {
//                self.alert("Stock Not Available", nil)
//                return
//            }
            applyAllBtn.isUserInteractionEnabled = true
            applyAllBtn.setTitleColor(.white, for: .normal)
            applyAllSelectMoldingTxtFld.text = item
            self.applyAllSelectedMoldName = self.moldingNamesArray[index]
            self.applyAllSelectedMoldPrice = self.moldingPriceArray[index]
            applyDeliveryOptions = getMoldDeliveryOptions(for: item , isCell: false)
            if applyDefaultDelivery == ""
            {
                applyAllSelectDeliveryTxtFld.text = "Select Delivery"
            }
            else
            {
                applyAllSelectDeliveryTxtFld.text = applyDefaultDelivery
            }
            
            
//            let selectedMold = self.moldingNamesArray[index]
//            let moldPrice = self.moldingPriceArray[index]
        }
        else if tag == 5
        {
            let roomId = self.tableValues[cell].room_id ?? 0
            self.updateRoomMoldOrColor(roomID: roomId, moldName: self.tableValues[cell].moulding!, moldPrice: self.tableValues[cell].mouldingPrice!,deliveryOptions: item)
            //self.updateRoomMoldOrColor(roomID: roomId, moldName: ,deliveryOptions: cellDefaultDelivery)
            self.loadRefreshData()
        }
        else if tag == 6
        {
            applyAllSelectDeliveryTxtFld.text = item 
        }
    }
    
    
    
    func getAnswer(for code: String, appointmentId: Int, roomId: Int) -> String? {
        let realm = try! Realm()
        
        return realm.objects(rf_master_question.self)
            .filter("appointment_id == %d AND question_code == %@ AND room_id == %d", appointmentId, code, roomId)
            .first?
            .rf_AnswerOFQustion.first?
            .answer.first
    }
    
    
    
    
    
    func calculateAnswerForGlueDownPlywood(roomArea: Double, calulationCode: String, roomId: Int, roomName: String,excludedId:Int) {
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
//        let appointmentId = AppointmentData().appointment_id ?? 0
//        let realm = try! Realm()
//
//        var codeCurrentSurface = ""
//
//        // Extract surface from formula (e.g., "current_surface != 'Concrete / Cement / Gypsum'")
//        let condition = calulationCode//#"room_area / 32 if !actual_surface.lowercased().contains("concrete")"#
//        //let pattern = #"contains\\\(\\?"([^"]+)"\\?\)"#
//
//        let pattern = "contains\\(\\\\\"([^\\\\\"]+)"
//
//        do {
//            let regex = try NSRegularExpression(pattern: pattern)
//            if let match = regex.firstMatch(in: calulationCode, range: NSRange(calulationCode.startIndex..., in: calulationCode)) {
//                // Extract the first capture group (the word in quotes)
//                let wordRange = match.range(at: 1)
//                if let swiftRange = Range(wordRange, in: calulationCode) {
//                    let word = String(calulationCode[swiftRange])
//                    codeCurrentSurface = word
//                    print("Extracted word: \(word)") // Output: "concrete"
//                }
//            } else {
//                print("No match found")
//            }
//        } catch {
//            print("Regex error: \(error)")
//        }
//
//
//        // Check if current surface matches the exclusion rule
//        
//        var removeExisting = false
//        if let removeCoveringType = realm.objects(rf_master_question.self)
//            .filter("appointment_id == %d AND question_code == %@", appointmentId, "RemoveCurrentCovering").first,
//           let removeCurrentTypeAnswer = removeCoveringType.rf_AnswerOFQustion.first {
//            removeExisting = removeCurrentTypeAnswer.answer.contains("Yes")
//        }
//        
//        let currentSurfaceQuestionCode = removeExisting ? "ExistingSubSurface" : "CurrentCoveringType"
////        guard let currentSurfaceQuestion = realm.objects(rf_master_question.self)
////            .filter("appointment_id == %d AND question_code == %@", appointmentId, currentSurfaceQuestionCode).first else {
////            // Handle error - question not found
////            return
////        }
//        
//        
//        
//        if let currentSurfaceQuestion = realm.objects(rf_master_question.self).filter("appointment_id == %d AND question_code == %@", appointmentId, currentSurfaceQuestionCode).first,
//           let existingSurfaceAnswer = currentSurfaceQuestion.rf_AnswerOFQustion.first {
//
//            if existingSurfaceAnswer.answer.contains(where: {
//                $0.lowercased().contains(codeCurrentSurface.lowercased())
//            }) {
//                print("Current surface '\(existingSurfaceAnswer.answer)' contains '\(codeCurrentSurface)'. Skipping plywood calculation.")
//                print("Current surface matches exclusion. Skipping plywood calculation.")
//                let appointmentId = AppointmentData().appointment_id ?? 0
//                let realm = try! Realm()
//                if let question = realm.objects(rf_master_question.self).filter("id == %d AND room_id == %d AND appointment_id == %d", excludedId, roomId,appoinmentID).first {
//                    
//                    try! realm.write
//                    {
//                        if let existingAnswer = question.rf_AnswerOFQustion.first {
//                            let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
//                            
//                            let answerDict = ["id":UUID().uuidString,"question_id":-1,"appointment_id":question.appointment_id,"answer":[]]
//                            newAnswer.append(rf_AnswerForQuestion(qstnAnsDict: answerDict))
//                            
//                            // Append it to rf_master_question
//                            //question.rf_AnswerOFQustion.append(newAnswer)
//                            
//                            //print("Created new answer object with plywood value: \(plywoodValueStr)")
//                            var dict:[String:Any] = [:]
//                            let questionUniqueIdentifier = question.questionIdUnique
//                            let questionId = question.id
//                            dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":roomId,"room_name":roomName]
//                            print("---dict2------", dict, " question : ", question.question_name)
//                            realm.create(rf_master_question.self, value: dict, update: .all)
//                        }
//                    }
//                }
//                return
//            }
//        }
//
//        // Find the rf_master_question with id == 12
//        if let question = realm.objects(rf_master_question.self).filter("id == %d AND room_id == %d AND appointment_id == %d", excludedId, roomId,appointmentId).first {
//
//            try! realm.write {
//                var plywoodValueStr:String = String()
//                let plywoodValue = roomArea / 32
//                //let progressValue = modf(plywoodValue / 100)
//                if plywoodValue == floor(plywoodValue)
//                {
//                    plywoodValueStr = String(Int(plywoodValue) )
//                }
//                else
//                {
//                    plywoodValueStr = String(Int(plywoodValue) + 1)
//                }
////                let countProgress = (progressValue.0 * 100.0)
////                 plywoodValueStr = String(Int(plywoodValue) + 1)
//
//                // Check if answer already exists for this question
//                if let existingAnswer = question.rf_AnswerOFQustion.first {
//                    if !existingAnswer.answer.contains(plywoodValueStr) {
//                        existingAnswer.answer.append(plywoodValueStr)
//                        let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
//                        
//                        let answerDict = ["id":UUID().uuidString,"question_id":question.id,"appointment_id":question.appointment_id,"answer":[plywoodValueStr]]
//    //                    newAnswer.id = UUID().uuidString
//    //                    newAnswer.question_id = question.id
//    //                    newAnswer.appointment_id = question.appointment_id
//    //                    newAnswer.answer.append(plywoodValueStr)
//                        newAnswer.append(rf_AnswerForQuestion(qstnAnsDict: answerDict))
//
//                        // Append it to rf_master_question
//                        //question.rf_AnswerOFQustion.append(newAnswer)
//
//                        print("Created new answer object with plywood value: \(plywoodValueStr)")
//                        var dict:[String:Any] = [:]
//                        let questionUniqueIdentifier = question.questionIdUnique
//                        let questionId = question.id
//                        dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":roomId,"room_name":roomName]
//                        print("---dict2------", dict, " question : ", question.question_name)
//                        realm.create(rf_master_question.self, value: dict, update: .all)
//                        print("Appended new plywood value to existing answer: \(plywoodValueStr)")
//                    } else {
//                        print("Answer already contains the plywood value. Skipping.")
//                    }
//                } else {
//                    // Create and append new rf_AnswerForQuestion
//                    
//                    let newAnswer = List<rf_AnswerForQuestion>()//rf_AnswerForQuestion()
//                    
//                    let answerDict = ["id":UUID().uuidString,"question_id":question.id,"appointment_id":question.appointment_id,"answer":[plywoodValueStr]]
////                    newAnswer.id = UUID().uuidString
////                    newAnswer.question_id = question.id
////                    newAnswer.appointment_id = question.appointment_id
////                    newAnswer.answer.append(plywoodValueStr)
//                    newAnswer.append(rf_AnswerForQuestion(qstnAnsDict: answerDict))
//
//                    // Append it to rf_master_question
//                    //question.rf_AnswerOFQustion.append(newAnswer)
//
//                    print("Created new answer object with plywood value: \(plywoodValueStr)")
//                    var dict:[String:Any] = [:]
//                    let questionUniqueIdentifier = question.questionIdUnique
//                    let questionId = question.id
//                    dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":newAnswer,"appointment_id":appointmentId,"room_id":roomId,"room_name":roomName]
//                    print("---dict2------", dict, " question : ", question.question_name)
//                    realm.create(rf_master_question.self, value: dict, update: .all)
//                }
//            }
//
//            // Optional debug log
//            
//
//        } else {
//            print("rf_master_question with id 12 not found.")
//        }
    }
    
    
    func applyFormula(_ formula: String, variables: [String: Any]) -> Double? {
        // 1. Prepare variables
        var evaluatedVariables = variables
        
        // Handle actual_surface derivation
        if let remove = variables["remove_current_surface"] as? String {
            evaluatedVariables["actual_surface"] = (remove.uppercased() == "YES")
                ? variables["sub_surface"]
                : variables["current_surface"]
        }
        
        // 2. Check if we should skip calculation (if contains "concrete")
        if let surface = evaluatedVariables["actual_surface"] as? String,
           surface.lowercased().contains("concrete") {
            return nil // Skip calculation
        }
        
        // 3. Extract the calculation part (before " if ")
        let calculationPart = formula.components(separatedBy: " if ").first?.trimmingCharacters(in: .whitespaces) ?? formula
        
        // 4. Perform the calculation
        return evaluateSimpleMathExpression(calculationPart, variables: evaluatedVariables)
    }

    private func evaluateSimpleMathExpression(_ expression: String, variables: [String: Any]) -> Double? {
        // Replace variable names with their values
        var replacedExpression = expression
        for (key, value) in variables {
            if let number = value as? NSNumber {
                replacedExpression = replacedExpression.replacingOccurrences(of: key, with: "\(number.doubleValue)")
            }
        }
        
        // Use NSExpression just for simple math
        let expr = NSExpression(format: replacedExpression)
        return expr.expressionValue(with: nil, context: nil) as? Double
    }
    
    
    
    
    
    
    
    

    
    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePicker = CaptureImage(presentationController: self, delegate: self)
            self.imagePicker.present(from: sender)
            
        }
        
        func imageUploadScreenShot(_ image:UIImage,_ name:String )
        {
            HttpClientManager.SharedHM.AttachmentScreenShotsFn(image, name) { (success, message, value) in
                if(success ?? "") == "Success"
                {
                  
                    
                    self.alert(message ?? "", nil)
                }
                else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                {
                    
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        self.fourceLogOutbuttonAction()
                    }
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
                    
                }
                else
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.imageUploadScreenShot(image,name)
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    
                    // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
                }
            }
        }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension SummeryListViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?,imageName:String?)
    {
        guard let image = image
                
        else
        {
            return
        }
        let imageNameStr = Date().toString()
        let name = "Snapshot" + String(imageNameStr) + ".JPG"
        let snapShotImageName = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: image, saveImgName: name)
        let appointmentId = AppointmentData().appointment_id ?? 0
        _ = self.saveSnapshotImage(savedImageName: snapShotImageName, appointmentId: appointmentId)
        //self.imageUploadScreenShot(image,imageName ?? name)
        
    }
}
