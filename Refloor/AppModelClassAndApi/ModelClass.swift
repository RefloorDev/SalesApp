//
//  ModelClass.swift
//  Refloor
//
//  Created by sbek on 15/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftUI
import ObjectMapper_Realm

class UserLoginData: Mappable
{
    var result: String?
    var message:String?
    var values:[UserLoginDataValue]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        values <- map["values"]
    }
}
class AttachmentDataMap: Mappable
{
    var result: String?
    var message:String?
    var values:[AttachmentDataValue]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        values <- map["values"]
    }
}




class AttachmentDataValue:NSObject, Mappable
{
    var id:Int?
    var name: String?
    var url:String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        name <- map["name"]
        url <- map["url"]
        id <- map["id"]
    }
    
    init(savedImageUrl:String, savedImageName: String = "", id: Int = 0) {
        self.id = id
        self.name = savedImageName
        self.url = savedImageUrl
         
    }
}


class TransitionListDataMap: Mappable
{
    var result: String?
    var message:String?
    var values:[TransitionDataValue]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        values <- map["transition_data"]
    }
}
class TransitionDataValue: Mappable
{
    var id:Int?
    var floor_id:Int?
    var room_id:Int?
    var company_id:Int?
    var name: String?
    var transition_width:Double?
    var attachment:[AttachmentDataValue]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        name <- map["name"]
        transition_width <- map["transition_width"]
        id <- map["id"]
        floor_id <- map["floor_id"]
        room_id <- map["room_id"]
        company_id <- map["company_id"]
        attachment <- map["attachments"]
    }
}
class FormUpdateDataMap: Mappable
{
    var id: String?
    var request_id:String?
    var attempt:String?
    var status:String?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        request_id <- map["request_id"]
        attempt <- map["attempt"]
        status <- map["status"]
    }
}


class CommenDataMap: Mappable
{
    var result: String?
    var message:String?
    var override_json_result:Int?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        override_json_result <- map["override_json_result"]
    }
}
class BuildStatus: Mappable
{
    var bnumber: String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        bnumber <- map["build"]
    }
}

class CommenImageQuestionDataMap: Mappable
{
    var result: String?
    var message:String?
    var override_json_result:Int?
    var summeryDetails:[SummeryDetailsData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        override_json_result <- map["override_json_result"]
        summeryDetails <- map["values"]
    }
}
class CommenDataPDF: Mappable
{
    var result: String?
    var document: String?
    var message:String?
    var override_json_result:Int?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        document <- map["document_url"]
        override_json_result <- map["override_json_result"]
    }
}
class UserData: NSObject
{
    var user_id: Int?
    var user_name :String?
    var token: String?
    var restrict_geolocation: Int?
    public static func isLogedIn() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "User_isLogedIn")
    }
    public static func setLogedInVal(_ isLogedIn:Bool)
    {
        UserDefaults.standard.set(isLogedIn, forKey: "User_isLogedIn")
    }
    
    
    public static func setBaseURLStatus(_ baseURLStatus:Bool)
    {
        UserDefaults.standard.set(baseURLStatus, forKey: "BaseURLStatus")
    }
    
    public static func setLogedInDate(loginDate:NSDate)
    {
        UserDefaults.standard.set(loginDate, forKey: "User_isLogedInDate")
    }
    
    public static func getLoggedInDate() -> NSDate
    {
        let date = UserDefaults.standard.object(forKey: "User_isLogedInDate") as! Date
        // let df = DateFormatter()
        // df.dateFormat = "dd/MM/yyyy"
        
        return date as NSDate
    }
    init(userID:Int,userName:String,token:String,restrict_geolocation:Int) {
        self.user_id = userID
        self.user_name = userName
        self.token = token
        self.restrict_geolocation = restrict_geolocation
        UserDefaults.standard.set(userID, forKey: "User_ID")
        UserDefaults.standard.set(userName, forKey: "User_Name")
        UserDefaults.standard.set(token, forKey: "User_Token")
        UserDefaults.standard.set(restrict_geolocation, forKey: "restrict_geolocation")
    }
    override init() {
        self.user_id = UserDefaults.standard.integer(forKey: "User_ID")
        self.user_name = UserDefaults.standard.string(forKey: "User_Name")
        self.token = UserDefaults.standard.string(forKey: "User_Token")
    }
    
}


class UserLoginDataValue: Mappable
{
    var user_id: Int?
    var user_name :String?
    var token: String?
    var can_view_phone_number : Int?
    var company_logo_url : String?
    var restrict_geolocation: Int?
    
    required init?(map: ObjectMapper.Map)
    {
    }
    
    func mapping(map: ObjectMapper.Map) {
        user_id <- map["user_id"]
        user_name <- map["user_name"]
        token <- map["token"]
        can_view_phone_number <- map["can_view_phone_number"]
        company_logo_url <- map["company_logo_url"]
        restrict_geolocation <- map["restrict_geolocation"]
        
    }
}
class AppointmentData: NSObject
{
    var appointment_id: Int?
    
    public static func saveSelectedAppointmentId(appointment_id:Int)
    {
        UserDefaults.standard.set(appointment_id, forKey: "Selected_Appointment_Id")
    }
    
    public static func getSelectedAppointmentId() -> Int
    {
        UserDefaults.standard.integer(forKey: "Selected_Appointment_Id")
    }
    
    override init() {
        self.appointment_id = UserDefaults.standard.integer(forKey: "Selected_Appointment_Id")
       
    }
    
    init(appointment_id:Int) {
        self.appointment_id = appointment_id
        UserDefaults.standard.set(appointment_id, forKey: "Selected_Appointment_Id")
    }
    
}

class SalesApiData: Mappable
{
    var result: String?
    var message:String?
    var roomData:[RoomDataValue]?
    var floorShapeData:[FloorShapeDataValue]?
    var floorLevelData:[FloorLevelDataValue]?
    var appoinmentslData:[AppoinmentDataValue]?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        roomData <- map["room_data"]
        floorShapeData <- map["floor_shape"]
        floorLevelData <- map["floor_level"]
        appoinmentslData <- map["appointment_details"]
        
    }
}
class RoomDataApiData: Mappable
{
    var result: String?
    var message:String?
    var roomData:[RoomDataValue]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        roomData <- map["values"]
    }
}


class RoomDataValue: Mappable,Encodable
{
    var id: Int?
    var name :String?
    var note: String?
    var company_id: Int?
    var image :String?
    var measurement_exist:String?
    var is_custom_room:String?
    var custom_room_measurement_id:Int?
    var roomCategory:String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    init(roomData:rf_master_roomname)
    {
        self.id = roomData.room_id
        self.name = roomData.room_name
        self.note = roomData.note
        self.company_id = roomData.company_id
        self.image = roomData.image
        self.roomCategory = roomData.room_category
        //self.measurement_exist = roomData.mea
        //self.is_custom_room = roomData.isc
        //self.custom_room_measurement_id = roomData.cus
    }

   
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["name"]
        note <- map["note"]
        company_id <- map["company_id"]
        image <- map["image"]
        measurement_exist <- map["measurement_exist"]
        is_custom_room <- map["is_custom_room"]
        custom_room_measurement_id <- map["custom_room_measurement_id"]
        roomCategory <- map["room_category"]
        
    }
}
class FloorShapeDataValue: Mappable
{
    var id: Int?
    var name :String?
    var note: String?
    var company_id: Int?
    var image :String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["name"]
        note <- map["note"]
        company_id <- map["company_id"]
        image <- map["image"]
        
    }
}
class FloorLevelDataValue: Mappable
{
    var id: Int?
    var name :String?
    var note: String?
    var company_id: Int?
    var image :String?
    var prefix :String?
    var superscript_symbol: String?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["name"]
        note <- map["note"]
        company_id <- map["company_id"]
        image <- map["image"]
        prefix <- map["prefix"]
        superscript_symbol <- map["superscript_symbol"]
        
    }
}

class AppoinmentDataValue:Object,Mappable
{
    var  id : Int?
    var  name :String?
    var  customer_name: String?
    var improveit_appointment_id:String?
    var  applicant_first_name:String?
    
    
    var  applicant_middle_name:String?
    var  applicant_last_name:String?
    var  co_applicant_first_name:String?
    var  co_applicant_middle_name:String?
    var  co_applicant_last_name:String?
    var  co_applicant_email:String?
    var  co_applicant_phone:String?
    
    var  co_applicant_address:String?
    var  co_applicant_city:String?
    var  co_applicant_state:String?
    var  co_applicant_zip:String?
    var  co_applicant_secondary_phone:String?
    var  co_applicant_skipped  : Int?
    
    
    
    var customer_id : Int?
    var co_applicant :String?
    var appointment_date :String?
    var appointment_datetime :String?
    var street: String?
    var street2 :String?
    var city :String?
    var state: String?
    var state_id  : Int?
    var country_id  : Int?
    var state_code :String?
    var country: String?
    var salesperson_id  : Int?
    var country_code :String?
    var phone :String?
    var mobile: String?
    var email :String?
    var zip:String?
    var sales_person :String?
    var partner_latitude : Double?
    var partner_longitude : Double?
    var is_room_measurement_exist : Bool?
    var recisionDate : String?
    var officeLocationId:Int?
    var externalEntityKey = RealmSwift.List<rf_External_Entity_Key>()
    
    var appointmentStatus:AppointmentStatus!
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    
    init(listOfAppointment:rf_master_appointment){
        self.id = listOfAppointment.id
        self.name = listOfAppointment.name
        self.customer_name = listOfAppointment.customer_name
        self.improveit_appointment_id = listOfAppointment.improveit_appointment_id
        self.applicant_first_name = listOfAppointment.applicant_first_name
        self.applicant_middle_name = listOfAppointment.applicant_middle_name
        self.applicant_last_name = listOfAppointment.applicant_last_name
        self.co_applicant_first_name = listOfAppointment.co_applicant_first_name
        self.co_applicant_middle_name = listOfAppointment.co_applicant_middle_name
        self.co_applicant_last_name = listOfAppointment.co_applicant_last_name
        self.co_applicant_email = listOfAppointment.co_applicant_email
        self.co_applicant_phone = listOfAppointment.co_applicant_phone
        self.co_applicant_address = listOfAppointment.co_applicant_address
        self.co_applicant_city = listOfAppointment.co_applicant_city
       // self.co_applicant_state = listOfAppointment.co_applicant_state
        self.co_applicant_zip = listOfAppointment.co_applicant_zip
        self.co_applicant_secondary_phone = listOfAppointment.co_applicant_secondary_phone
       // self.co_applicant_skipped = listOfAppointment.co_applicant_skipped
        self.customer_id  = listOfAppointment.customer_id
        self.co_applicant = listOfAppointment.co_applicant
        self.appointment_date = listOfAppointment.appointment_date
        self.appointment_datetime  = listOfAppointment.appointment_datetime
        self.street = listOfAppointment.street
        self.street2 = listOfAppointment.street2
        self.city = listOfAppointment.city
        self.state = listOfAppointment.state
        self.state_id = listOfAppointment.state_id
        self.country_id = listOfAppointment.country_id
        self.state_code = listOfAppointment.state_code
        self.country = listOfAppointment.country
        self.salesperson_id = listOfAppointment.salesperson_id
        self.country_code = listOfAppointment.country_code
        self.phone  = listOfAppointment.phone
        self.mobile = listOfAppointment.mobile
        self.email = listOfAppointment.email
        self.zip = listOfAppointment.zip
        self.sales_person  = listOfAppointment.sales_person
        self.partner_latitude  = listOfAppointment.partner_latitude
        self.partner_longitude  = listOfAppointment.partner_longitude
        self.is_room_measurement_exist = listOfAppointment.is_room_measurement_exist
        self.recisionDate = listOfAppointment.recisionDate
        self.officeLocationId = listOfAppointment.officeLocationId
        self.externalEntityKey = listOfAppointment.externalEntityKey
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["name"]
        customer_name <- map["customer_name"]
        customer_id <- map["customer_id"]
        co_applicant <- map["co_applicant"]
        appointment_date <- map["appointment_date"]
        appointment_datetime <- map["appointment_datetime"]
        street <- map["street"]
        street2 <- map["street2"]
        city <- map["city"]
        state_id <- map["state_id"]
        state <- map["state"]
        state_code <- map["state_code"]
        country_id <- map["country_id"]
        country <- map["country"]
        country_code <- map["country_code"]
        phone <- map["phone"]
        mobile <- map["mobile"]
        email <- map["email"]
        sales_person <- map["sales_person"]
        salesperson_id <- map["salesperson_id"]
        partner_latitude <- map["partner_latitude"]
        partner_longitude <- map["partner_longitude"]
        zip <- map["zip"]
        is_room_measurement_exist <- map["is_room_measurement_exist"]
        applicant_first_name <- map["applicant_first_name"]
        
        applicant_middle_name <- map["applicant_middle_name"]
        applicant_last_name <- map["applicant_last_name"]
        
        co_applicant_first_name <- map["co_applicant_first_name"]
        co_applicant_middle_name <- map["co_applicant_middle_name"]
        co_applicant_last_name <- map["co_applicant_last_name"]
        co_applicant_email <- map["co_applicant_email"]
        co_applicant_phone <- map["co_applicant_phone"]
        
        co_applicant_address <- map["co_applicant_address"]
        co_applicant_city <- map["co_applicant_city"]
        co_applicant_state <- map["co_applicant_state_code"]
        co_applicant_zip <- map["co_applicant_zip"]
        co_applicant_secondary_phone <- map["co_applicant_secondary_phone"]
        recisionDate <- map["recision_date"]
        officeLocationId <- map["office_location_id"]
        externalEntityKey <- (map["external_entity_keys"],ListTransform<rf_External_Entity_Key>())
        
    }
}
class QustionDataMap: Mappable
{
    var result: String?
    var message:String?
    var questions_measurement:[QuestionsMeasurementData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        questions_measurement <- map["questions_measurement"]
    }
}

class QuestionsMeasurementData: Mappable
{
    var id: Int?
    var name :String?
    var max_allowed_limit: Int?
    var code: String?
    var company_id: Int?
    var description :String?
    var question_type :String?
    var validation_required: Bool?
    var validation_email_required :Bool?
    var validation_error_msg :String?
    var multiply_with_area : Bool?
    var mandatory_answer: Bool?
    var Error_message: String?
    var Refelct_in_cost: Bool?
    var calculation_type :String?
    var default_answer: String?
    var amount: Double?
    var setDefaultAnswer : Bool?
    var applicableCurrentSurface : String?
    var calculate_order_wise:Bool?
    var aaplicableRoom : [ApplicableRoom]?
    var quote_label :[QuoteLabelData]?
    var answerOFQustion:AnswerOFQustion?
    required init?(map: ObjectMapper.Map){
    }
    
    init(){
        
    }
    
    init(masterQuestions:rf_master_question){
        self.id = masterQuestions.id
        self.name = masterQuestions.question_name
        self.max_allowed_limit = masterQuestions.max_allowed_limit
        self.code = masterQuestions.question_code
        self.company_id = masterQuestions.company_id
        self.description = masterQuestions.description1
        self.question_type = masterQuestions.question_type
        self.validation_required = masterQuestions.validation_required
        self.validation_email_required = masterQuestions.validation_email_required
        self.multiply_with_area = masterQuestions.multiply_with_area
        self.validation_error_msg = masterQuestions.error_message
        self.mandatory_answer = masterQuestions.mandatory_answer
        self.Error_message = masterQuestions.error_message
        self.Refelct_in_cost = masterQuestions.refelct_in_cost
        self.calculation_type = masterQuestions.calculation_type
        self.default_answer = masterQuestions.default_answer
        self.amount = masterQuestions.amount
        self.setDefaultAnswer = masterQuestions.setDefaultAnswer
        self.calculate_order_wise = masterQuestions.calculate_order_wise
        self.applicableCurrentSurface = masterQuestions.applicableCurrentSurface
        
        var applicableRoomdetails :[ApplicableRoom] = []
        for rooms in masterQuestions.applicableRooms
        {
            applicableRoomdetails.append(ApplicableRoom(applicableRoomsDetails: rooms))
        }
        self.aaplicableRoom = applicableRoomdetails
        var questionDetails:[QuoteLabelData] = []
        for question in masterQuestions.quote_label{
            questionDetails.append(QuoteLabelData(questionDetails: question) )
        }
        self.quote_label  = questionDetails
        if var answerOfQtn:rf_AnswerForQuestion = masterQuestions.rf_AnswerOFQustion.first{
            
        }
        //self.answerOFQustion = AnswerOFQustion(rf_AnsOFQustion: masterQuestions.rf_AnswerOFQustion)
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["name"]
        code <- map["code"]
        max_allowed_limit <- map["max_allowed_limit"]
        company_id <- map["company_id"]
        description <- map["description"]
        question_type <- map["question_type"]
        validation_required <- map["validation_required"]
        validation_email_required <- map["validation_email_required"]
        validation_error_msg <- map["validation_error_msg"]
        mandatory_answer <- map["mandatory_answer"]
        Error_message <- map["Error_message"]
        Refelct_in_cost <- map["Refelct_in_cost"]
        calculation_type <- map["calculation_type"]
        default_answer <- map["default_answer"]
        amount <- map["amount"]
        quote_label <- map["quote_label"]
        aaplicableRoom <- map["applicable_rooms"]
        calculate_order_wise <- map["calculate_order_wise"]
        setDefaultAnswer <- map["set_default_answer"]
        applicableCurrentSurface <- map["applicable_current_surface"]
        
        
        
    }
}
class AnswerOFQustion:NSObject
{
    var answerID:Int = 0
    var qustionLineID:Int = 0
    var numberVaue:Int?
    var textValue:String?
    var singleSelection:QuoteLabelData?
    var multySelection:[QuoteLabelData]?
    init(_ numberVaue:Int)
    {
        self.numberVaue = numberVaue
    }
    init(_ textValue:String)
    {
        self.textValue = textValue
    }
    init(_ singleSelection:QuoteLabelData)
    {
        self.singleSelection = singleSelection
    }
    init(_ multySelection:[QuoteLabelData])
    {
        self.multySelection = multySelection
    }
    
    init(rf_AnsOFQustion: rf_AnswerOFQustion){
        self.answerID = rf_AnsOFQustion.answerID
        self.qustionLineID = rf_AnsOFQustion.qustionLineID
        self.numberVaue = rf_AnsOFQustion.numberVaue
        self.textValue = rf_AnsOFQustion.textValue
        self.singleSelection = rf_AnsOFQustion.singleSelection
        self.multySelection = rf_AnsOFQustion.multySelection
    }
}

class ApplicableRoom: Mappable
{
    var room_id:Int?
    var room_name:String?
    init(room_id:Int,room_name:String) {
        self.room_id = room_id
        self.room_name = room_name
    }
    init(applicableRoomsDetails:rf_AnswerapplicableRooms){
        self.room_id = applicableRoomsDetails.room_id
        self.room_name = applicableRoomsDetails.room_name
    }
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        room_id <- map["room_id"]
        room_name <- map["room_name"]
    }
}


class QuoteLabelData: Mappable
{
    var question_id: Int?
    var sequence :Int?
    var value: String?
    var is_correct: Int?
    var answer_score :Double?
    init(question_id:Int,value:String) {
        self.question_id = question_id
        self.value = value
    }
    init(questionDetails:rf_master_question_detail){
        self.question_id = questionDetails.question_id
        self.sequence = questionDetails.sequence
        self.value = questionDetails.value
        self.is_correct = questionDetails.is_correct ? 1 : 0
        self.answer_score = questionDetails.answer_score
    }
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        question_id <- map["question_id"]
        sequence <- map["sequence"]
        value <- map["value"]
        is_correct <- map["is_correct"]
        answer_score <- map["answer_score"]
        
        
    }
    
    
}


class SummeryData:NSObject
{   var roomData:RoomDataValue!
    var floorLevelData:FloorLevelDataValue!
    var appoinmentslData:AppoinmentDataValue!
    var area:Float = 0
    var qustionAnswer:[QuestionsMeasurementData] = []
    var shapeSelected:UIImage!
    var shapeView:UIImage!
    var transitionObjcets:[TransitionDataValue] = []
    var comments:String!
    init(roomData:RoomDataValue,floorLevelData:FloorLevelDataValue,appoinmentslData:AppoinmentDataValue,area:Float,qustionAnswer:[QuestionsMeasurementData],shapeSelected:UIImage,shapeView:UIImage,transitionObjcets:[TransitionDataValue])
    {
        self.roomData = roomData
        self.floorLevelData = floorLevelData
        self.appoinmentslData = appoinmentslData
        self.area = area
        self.qustionAnswer = qustionAnswer
        self.shapeSelected = shapeSelected
        self.shapeView = shapeView
        self.transitionObjcets = transitionObjcets
        self.comments = ""
    }
}
enum SummeryTableCellTyepe
{
    case heading
    case SubDetails
    case SubHeading
    case Transiion
    case Qustions
}
class SummeryTableDataValues:NSObject
{
    var cellType:SummeryTableCellTyepe
    var summeryData:SummeryDetailsData?
    var qustionAnswer:SummeryQustionsDetails?
    var transitionObjcets:SummeryTransitionDetails?
    var isTransition:Bool!
    var isHeading:Bool!
    var heading:String?
    var comments:String?
    var attachments:[AttachmentDataValue]?
    var tag = 0
    var isNoData = false
    init(cellType:SummeryTableCellTyepe,summeryData:SummeryDetailsData?,qustionAnswer:SummeryQustionsDetails?,transitionObjcets:SummeryTransitionDetails?,isTransition:Bool,isHeading:Bool,heading:String?)
    {
        self.summeryData = summeryData
        self.qustionAnswer = qustionAnswer
        self.transitionObjcets = transitionObjcets
        self.isTransition = isTransition
        self.isHeading = isHeading
        self.heading = heading
        self.cellType = cellType
    }
}


class MeterialsDataMap: Mappable
{
    var result: String?
    var message:String?
    var material_list_data:[MeterialsData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        material_list_data <- map["material_list_data"]
    }
}
class MeterialsData: Mappable
{
    var material_id: Int?
    var name :String?
    var color: String?
    var material_image_url :String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        material_id <- map["material_id"]
        name <- map["name"]
        color <- map["color"]
        material_image_url <- map["material_image_url"]
    }
}


class OrderStatusDataMap: Mappable
{
    var result: String?
    var message:String?
    var orderStatus_list_data:[OrderStatusData]?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        orderStatus_list_data <- map["appointment_result"]
    }
}
class OrderStatusData: Mappable
{
    var id: Int?
    var statusresult :String?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        statusresult <- map["result"]
        
        
    }
    init(appointmentResult:rf_master_appointments_results_demoedNotDemoed){
        self.id = appointmentResult.id
        self.statusresult = appointmentResult.result
    }
    
}

class AppointmentResultData: Mappable
{
    var id: Int?
    var reason:String?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["reason_id"]
        reason <- map["reason"]
        
        
    }
    init(appointmentResultData:rf_appointment_result_reasons_results){
        self.id = appointmentResultData.reasonId
        self.reason = appointmentResultData.reason
    }
    
}

class MessuerementDataMap: Mappable
{
    var result: String?
    var message:String?
    var contract_measurement_id:Int?
    var summeryDetails:[SummeryDetailsData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        contract_measurement_id <- map["contract_measurement_id"]
        summeryDetails <- map["values"]
    }
}
class TileMeterailsDataMap: Mappable
{
    var result: String?
    var message:String?
    var material_list_data:[TileMeterailsData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        material_list_data <- map["values"]
    }
}
class TileMeterailsData: Mappable
{
    var material_id: Int?
    var name :String?
    var color: String?
    var material_image_url :String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        material_id <- map["material_id"]
        name <- map["name"]
        color <- map["color"]
        material_image_url <- map["material_image_url"]
    }
}
class SummeryDetailsDataMap: Mappable
{
    var result: String?
    var message:String?
    var summeryDetails:[SummeryDetailsData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        summeryDetails <- map["values"]
    }
}
class SummeryDetailsData:NSObject, Mappable
{
    var contract_measurement_id: Int?
    var name :String?
    var material_id: Int?
    var material_image_url :String?
    var material_comments:String?
    var floor_id: Int?
    var floor_name :String?
    var superscript_symbol:String?
    var prefix:String?
    var room_id: Int?
    var room_name :String?
    var appointment_id: Int?
    var room_area :Double?
    var stair_count :Double?
    var adjusted_area:Double?
    var comments: String?
    var striked :String?
    var attachments:[AttachmentDataValue]?
    var attachment_comments:String?
    var drawing_attachment:[AttachmentDataValue]?
    var transition:[SummeryTransitionDetails]?
    var questionaire:[SummeryQustionsDetails]?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        contract_measurement_id <-  map["contract_measurement_id"]
        material_id <- map["material_id"]
        name <- map["name"]
        material_image_url <- map["material_image_url"]
        floor_id <- map["floor_id"]
        floor_name <- map["floor_name"]
        room_id <- map["room_id"]
        room_name <- map["room_name"]
        appointment_id <- map["appointment_id"]
        room_area <- map["room_area"]
        comments <- map["comments"]
        striked <- map["striked"]
        transition <- map["transition"]
        questionaire <- map["questionaire"]
        drawing_attachment <- map["drawing_attachment"]
        material_comments <- map["material_comments"]
        superscript_symbol <- map["superscript_symbol"]
        attachments <- map["attachments"]
        attachment_comments <- map["attachment_comments"]
        prefix <- map["prefix"]
        adjusted_area <- map["adjusted_area"]
        stair_count <- map["stair_count"]
        
    }
    
    override init(){
        
    }
}

class SummeryTransitionDetails: Mappable
{
    var id: Int?
    var name :String?
    
    var transition_width: Double?
    var attachments :[AttachmentDataValue]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        name <- map["name"]
        transition_width <- map["transition_width"]
        attachments <- map["attachments"]
        
    }
    init(id: Int = 0,name :String,transition_width: Double = 0.0,attachments :[AttachmentDataValue] = []){
        self.id = id
        self.name = name
        self.transition_width = transition_width
        self.attachments = attachments
         
    }
}

class SummeryQustionsDetails: Mappable
{
    var contract_question_line_id: Int?
    var question_id:Int?
    var name :String?
    var question:String?
    var question_type:String?
    var answers :[SummeryQustionAnswerData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        contract_question_line_id <- map["contract_question_line_id"]
        name <- map["name"]
        answers <- map["answers"]
        question_type <- map["question_type"]
        question <- map["question"]
        question_id <- map["question_id"]
    }
    
     init(question_id:Int,name :String,question:String,question_type:String,answers :[SummeryQustionAnswerData]){
         self.question_id = question_id
         self.name = name
         self.question = question
         self.question_type = question_type
         self.answers = answers
    }
}

class SummeryQustionAnswerData: Mappable
{
    var id: Int?
    var answer :String?
    var contract_question_line_id: Int?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        contract_question_line_id <- map["contract_question_line_id"]
        answer <- map["answer"]
        id <- map["id"]
        
    }
    
    init(id:Int,answer :String){
        self.id = id
        self.answer = answer
    }
}

class SummeryListDataMap: Mappable
{
    var result: String?
    var message:String?
    var summeryList:[SummeryListData]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        summeryList <- map["values"]
    }
}

class SummeryListData: Mappable
{
    var contract_measurement_id: Int?
    var name :String?
    var total_area:Double?
    var moulding:String?
    var mouldingPrice: Double?
    var total_adjusted_area:Double?
    var material_id: Int?
    var color:String?
    var material_image_url :String?
    var material_comments:String?
    var floor_id: Int?
    var floor_name :String?
    var superscript_symbol:String?
    var prefix:String?
    var room_id: Int?
    var room_image_url:String?
    var room_name :String?
    var appointment_id: Int?
    var room_area :Double?
    var room_perimeter : Float?
    var adjusted_area:Double?
    var comments: String?
    var striked :String?
    var stair_count :Int?
    var material_colors:[MaterialColors]?
    var molding_Type:[MoldingType]?
    var total_stair_count :Int?
    var colorUpCharge : Double?
    var colorUpChargePrice : Double?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        contract_measurement_id <-  map["contract_measurement_id"]
        material_id <- map["material_id"]
        name <- map["name"]
        material_image_url <- map["material_image_url"]
        floor_id <- map["floor_id"]
        floor_name <- map["floor_name"]
        room_id <- map["room_id"]
        room_name <- map["room_name"]
        appointment_id <- map["appointment_id"]
        room_area <- map["room_area"]
        room_perimeter <- map["room_perimeter"]
        comments <- map["comments"]
        striked <- map["striked"]
        material_comments <- map["material_comments"]
        superscript_symbol <- map["superscript_symbol"]
        prefix <- map["prefix"]
        total_area <- map["total_area"]
        adjusted_area <- map["adjusted_area"]
        total_adjusted_area <- map["total_adjusted_area"]
        room_image_url <- map["room_image_url"]
        moulding <- map["moulding"]
        mouldingPrice <- map ["mouldingPrice"]
        material_colors <- map["material_colors"]
        molding_Type <- map["molding_type"]
        stair_count <- map["stair_count"]
        total_stair_count <- map["total_stair_count"]
        color <- map["color"]
    }
    
    init(){
        
    }
    
}

class MaterialColors: Mappable
{
    var material_id: Int?
    var name: String?
    var color:String?
    var material_image_url:String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        material_id <- map["material_id"]
        name <- map["name"]
        color <- map["color"]
        material_image_url <- map["material_image_url"]
        
    }
}

class MoldingType: Mappable
{
    var molding_id: Int?
    var name: String?
    var unit_price: Double?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        molding_id <- map["molding_id"]
        name <- map["name"]
        unit_price <- map["unit_price"]
        
        
    }
}


class PaymentApiData: Mappable
{
    var result: String?
    var message:String?
    var values:[PaymentValue]?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        values <- map["values"]
        
        
    }
}


class PaymentValue: Mappable
{
    var PaymentPlanValueDetails:[PaymentPlanValue]?
    var PaymentOptionDataValueDetail:[PaymentOptionDataValue]?
    var PaymentMeterialDataValueDetails:[PaymentMeterialDataValue]?
    var PaymentPromoDataValueDetails:[MonthlyPromoDataValue]?
    var adminFee: Int?
    var minimumFee: Double?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        PaymentPlanValueDetails <- map["payment_plans"]
        PaymentOptionDataValueDetail <- map["payment_options"]
        PaymentMeterialDataValueDetails <- map["materials"]
        PaymentPromoDataValueDetails <- map["monthly_promo"]
        adminFee <- map["admin_fee"]
        minimumFee <- map["min_sale_price"]
        
        
    }
}


class PaymentPlanValue: Mappable
{
    var id: Int?
    var plan_title :String?
    var plan_subtitle: String?
    var company_id: Int?
    var description :String?
    var cost_per_sqft: Double?
    var floor_standard :String?
    var warranty :String?
    var minimum_Sale_price: Double?
    var sequence :String?
    var monthly_promo:Double?
    var discount: Int?
    var discount_minimum: Int?
    var discount_maximum: Int?
    var isNotAvailable = false
    var material_cost: Double?
    var additional_cost: Double?
    var discount_exclude_amount: Double?
    var eligible_for_discounts: String?
    var unit_of_measure: String?
    var grade: String?
    var stair_cost: Double?
    var stair_msrp: Double?
    var stairProductId: Int?
    required init?(map: ObjectMapper.Map){
    }
//    init(costPerSqft:Double)
//    {
//        self.cost_per_sqft = costPerSqft
//    }
    
    init(paymentPlan:rf_master_product_package){
        self.id = paymentPlan.id
        self.plan_title = paymentPlan.plan_title
        self.plan_subtitle = paymentPlan.plan_subtitle
        self.company_id = paymentPlan.company_id
        self.description = paymentPlan.description1
        self.cost_per_sqft = paymentPlan.cost_per_sqft
        self.floor_standard = ""
        self.warranty = paymentPlan.warranty_info
        self.minimum_Sale_price = paymentPlan.min_Sale_Price
        self.sequence = String(paymentPlan.sequence)
        self.monthly_promo = Double(paymentPlan.monthly_promo)
        //self.discount = discount.discount
        //self.discount_minimum = discount.discount_minimum
        //self.discount_maximum = discount.discount_maximum
        //self.isNotAvailable = discount.isNotAvailable
        self.material_cost = paymentPlan.material_cost
        //self.additional_cost = discount.additional_cost
        //self.discount_exclude_amount = discount.discount_exclude_amount
        self.eligible_for_discounts = paymentPlan.eligible_for_discounts
        self.unit_of_measure = paymentPlan.unit_of_measure
        self.grade = paymentPlan.grade
        self.stair_cost = paymentPlan.stair_cost
        self.stair_msrp = paymentPlan.stair_Msrp
        self.stairProductId = paymentPlan.stairProductId
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        plan_title <- map["plan_title"]
        plan_subtitle <- map["plan_subtitle"]
        company_id <- map["company_id"]
        description <- map["description"]
        warranty <- map["warranty_info"]
        minimum_Sale_price <- map["min_sale_price"]
        floor_standard <- map["floor_standard"]
        sequence <- map["sequence"]
        company_id <- map["company_id"]
        cost_per_sqft <- map["cost_per_sqft"]
        print("COST:",cost_per_sqft ?? 0)
        discount <- map["discount"]
        discount_minimum <- map["discount_minimum"]
        discount_maximum <- map["discount_maximum"]
        monthly_promo <- map["monthly_promo"]
        material_cost <- map["material_cost"]
        print("MRP:",material_cost ?? 0)
        additional_cost <- map["additional_cost"]
        discount_exclude_amount <- map["discount_exclude_amount"]
        eligible_for_discounts <- map["eligible_for_discounts"]
        unit_of_measure <- map["unit_of_measure"]
        stair_cost <- map["stair_cost"]
        stair_msrp <- map["stair_Msrp"]
        stairProductId <- map["stair_product_id"]
    }
    
    
}

class SignatureApiData: Mappable
{
    var result: String?
    var message:String?
    var applicant_signature_image:[AttachmentDataValue]?
    var co_applicant_signature_image:[AttachmentDataValue]?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        applicant_signature_image <- map["applicant_signature_image"]
        co_applicant_signature_image <- map["co_applicant_signature_image"]
    }
}


class PaymentOptionDataValue: Mappable
{
    var id: Int?
    var sequenceid: Int?
    var title :String?
    var subtitle: String?
    var interest_rate:Double?
    var Name:String?
    var Description__c:String?
    var Down_Payment__c:String?
    var Final_Payment__c:String?
    var Payment_Factor__c:String?
    var Secondary_Payment_Factor__c:String?
    var Balance_Due__c:String?
    var Payment_Info__c:String?
    var down_payment_message:String?
    var isHidden: Bool = false
    var start_date: String?
    var end_date: String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    init(paymentOption:rf_master_payment_option){
        print("------paymentOption : ", paymentOption)
        self.id = paymentOption.id
        self.sequenceid = paymentOption.sequence
        //self.interest_rate = paymentOption.int
        self.Name = paymentOption.name
        self.Description__c = paymentOption.description__c
        self.Down_Payment__c = paymentOption.down_payment__c
        self.Final_Payment__c = paymentOption.final_payment__c
        self.Payment_Factor__c = paymentOption.payment_factor__c
        self.Secondary_Payment_Factor__c = paymentOption.Secondary_Payment_Factor__c
        self.Balance_Due__c = paymentOption.balance_Due__c
        self.Payment_Info__c = paymentOption.payment_info__c
        self.down_payment_message = paymentOption.down_payment_message
        self.start_date = paymentOption.start_date
        self.end_date = paymentOption.end_date
        //self.isHidden = self.isHidden
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        sequenceid <- map["sequence"]
        title <- map["title"]
        subtitle <- map["subtitle"]
        interest_rate <- map["interest_rate"]
        Name <- map["Name"]
        Description__c <- map["Description__c"]
        Down_Payment__c <- map["Down_Payment__c"]
        Final_Payment__c <- map["Final_Payment__c"]
        Payment_Factor__c <- map["Payment_Factor__c"]
        Secondary_Payment_Factor__c <- map["Secondary_Payment_Factor__c"]
        Balance_Due__c <- map["Balance_Due__c"]
        Payment_Info__c <- map["Payment_Info__c"]
        down_payment_message <- map["down_payment_message"]
        start_date <- map["start_date"]
        end_date <- map["end_date"]
    }
}


class MonthlyPromoDataValue: Mappable
{
    
    var code:String?
    var amount:String?
    var type:String?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    init(discountPromo:rf_master_discount){
        self.code = discountPromo.code
        self.amount = discountPromo.amount
        self.type = discountPromo.type
    }
    func mapping(map: ObjectMapper.Map) {
        
        code <- map["Code"]
        amount <- map["Amount"]
        type <- map["Type"]
        
    }
}
class PaymentMeterialDataValue: Mappable
{
    var material_id: Int?
    var name :String?
    var color: String?
    var material_image_url :String?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        material_id <- map["material_id"]
        name <- map["name"]
        color <- map["color"]
        material_image_url <- map["material_image_url"]
        
    }
    init(){
        
    }
}
class QuotationApiData: Mappable
{
    var result: String?
    var message:String?
    var values:[QuotationValue]?
    var order_id: Int?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        message <- map["message"]
        result <- map["result"]
        values <- map["values"]
        order_id <- map["order_id"]
        
    }
}


class QuotationValue: Mappable
{
    var QuotationPaymentPlanValueDetails:[QuotationPaymentDetails]?
    var QuotationPaymentOptionDataValueDetail:[DownPaymentDataValue]?
    var QuotationPaymentMethodlDataValue:[PaymentMethodDataValue]?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        QuotationPaymentPlanValueDetails <- map["payment_details"]
        QuotationPaymentOptionDataValueDetail <- map["downpayment_percetages"]
        QuotationPaymentMethodlDataValue <- map["downpayment_method"]
        
    }
}


class QuotationPaymentDetails: Mappable
{
    
    var package :String?
    var total_area:Double?
    var actual_price :Double?
    var discount_percentage :Double?
    var price_after_discount :Double?
    var tax_percentage:Double?
    var amount_taxed: Double?
    var total_amount: Double?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        package <- map["package"]
        total_area <- map["total_area"]
        actual_price <- map["actual_price"]
        discount_percentage <- map["discount_percentage"]
        price_after_discount <- map["price_after_discount"]
        tax_percentage <- map["tax_percentage"]
        amount_taxed <- map["amount_taxed"]
        total_amount <- map["total_amount "]
        
    }
}

class DownPaymentDataValue: Mappable
{
    var id: Int?
    var name :String?
    var percentage: Int?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["name"]
        percentage <- map["percentage"]
        
    }
}
class PaymentMethodDataValue: Mappable
{
    var id: Int?
    var name :String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
class CashData: Mappable
{
    var result: String?
    var message:String?
    var document:String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        document <- map["document"]
        
        
    }
}

class dataBaseData: Mappable
{
    var result:String?
    var message:String?
    var override_json_result:Int?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        override_json_result <- map["override_json_result"]
    }
    
}


class autoLogoutData: Mappable
{
    var result:String?
    var message:String?
    var enableAutoLogout:Int?
    var autoLogoutTime:String?
    var override_json_result:Int?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        enableAutoLogout <- map["enable_auto_logout"]
        autoLogoutTime <- map["auto_logout_time"]
        override_json_result <- map["override_json_result"]
    }
    
}

class InstallerDatesSubmit: Mappable
{
    var result:String?
    var message:String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
    }
}

// versatile api

class VersatileModelClass: Codable
{
    var type:String?
    var url:String?
    
    enum CodingKeys: String, CodingKey {

        case type = "type"
        case url = "url"
       
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        
    }
}

//get versatileApplication Status

class CreditApplicationStatus: Codable
{
    var result:String?
    var data: CreditApplicationStatusDetails?
    var message:String?
    var override_json_result:Int?
    
    
    enum CodingKeys: String, CodingKey {

        case result = "result"
        case data = "data"
        case message = "message"
        case override_json_result = "override_json_result"
       
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent(String.self, forKey: .result)
        data = try values.decodeIfPresent(CreditApplicationStatusDetails.self, forKey: .data)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        override_json_result = try values.decodeIfPresent(Int.self, forKey: .override_json_result)
        
    }
}

class CreditApplicationStatusDetails: Codable
{
    var applicationId:String?
    var provider: String?
    var providerRefrence:String?
    var status:String?
    var approvedAmount:Double?
    required init?(map: ObjectMapper.Map){
    }
    
    
    enum CodingKeys: String, CodingKey {

        case applicationId = "application_id"
        case provider = "provider"
        case providerRefrence = "provider_reference"
        case status = "status"
        case approvedAmount = "approved_amount"
       
       
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        applicationId = try values.decodeIfPresent(String.self, forKey: .applicationId)
        provider = try values.decodeIfPresent(String.self, forKey: .provider)
        providerRefrence = try values.decodeIfPresent(String.self, forKey: .providerRefrence)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        approvedAmount = try values.decodeIfPresent(Double.self, forKey: .approvedAmount)
       
        
    }
}

// additional comments api

class AdditionalComments: Mappable
{
    var result:String?
    var message:String?
    var override_json_result:Int?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        override_json_result <- map["override_json_result"]
    }
}

class InstallerDates: Mappable
{
    var result:String?
    var message:String?
    var data:DatesValues?
    var override_json_result:Int?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        data <- map["data"]
        override_json_result <- map["override_json_result"]
    }
}
class DatesValues: Mappable
{
    var availableDates:[AvailableDatesValues]?
    var saleOrderId: Int?
    required init?(map: ObjectMapper.Map)
    {
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        availableDates <- map["available_dates"]
        saleOrderId <- map["sale_order_id"]
       
    }
}

class AvailableDatesValues: Mappable
{
    var installationId:Int?
    var startDate:String?
    var endDate:String?
    var crewId:Int?
    var crewName:String?
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        installationId <- map["installation_id"]
        startDate <- map["start_date"]
        endDate <- map["end_date"]
        crewId <- map["crew_id"]
        crewName <- map["crew_name"]
        
       
    }
}

class CashDataResponse: Mappable
{
    var result: String?
    var message:String?
    var document:String?
    var paymentStatus:String?
    var paymentMessage:String?
    var authorize_transaction_id:String?
    var card_type:String?
    
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        document <- map["document"]
        paymentStatus <- map["payment_status"]
        paymentMessage <- map["payment_message"]
        authorize_transaction_id <- map["authorize_transaction_id"]
        card_type <- map["card_type"]
        
    }
}
class SignData: Mappable
{
    var result: String?
    var message:String?
    var signed:String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        signed <- map["signed"]
        
        
    }
}

class ApplicationData:NSObject
{
    var ethnicity, race, sex, applicantEmail, maritalStatus: String?
    var applicantFirstName: String?
    var applicantMiddleName, applicantLastName, driversLicense, driversLicenseExpDate, driversLicenseIssueDate: String?
    var dateOfBirth, socialSecurityNumber, addressOfApplicant, addressOfApplicantStreet: String?
    var addressOfApplicantStreet2, addressOfApplicantCity, addressOfApplicantState, addressOfApplicantZip: String?
    var previousAddressOfApplicant, previousAddressOfApplicantStreet, previousAddressOfApplicantStreet2, previousAddressOfApplicantCity: String?
    var previousAddressOfApplicantState, previousAddressOfApplicantZip, cellPhone, homePhone: String?
    var howLong, previousAddressHowLong, presentEmployer, yearsOnJob: String?
    var occupation, presentEmployersAddress, presentEmployersAddressStreet, presentEmployersAddressStreet2: String?
    var presentEmployersAddressCity, presentEmployersAddressState, presentEmployersAddressZip: String?
    var earningsFromEmployment,type_of_credit_requested: String?
    var supervisorOrDepartment, employersPhoneNumber, previousEmployersAddress, previousEmployersAddressStreet: String?
    var previousEmployersAddressStreet2, previousEmployersAddressCity, previousEmployersAddressState, previousEmployersAddressZip: String?
    var earningsPerMonth: String?
    var yearsOnJobPreviousEmployer, occupationPreviousEmployer, previousEmployersPhoneNumber, otherRace: String?
    init( applicantFirstName: String, applicantMiddleName: String, applicantLastName: String, driversLicense: String, driversLicenseExpDate: String, driversLicenseIssueDate: String, dateOfBirth: String, socialSecurityNumber: String, addressOfApplicant: String, addressOfApplicantStreet: String, addressOfApplicantStreet2: String, addressOfApplicantCity: String, addressOfApplicantState: String, addressOfApplicantZip: String, previousAddressOfApplicant: String, previousAddressOfApplicantStreet: String, previousAddressOfApplicantStreet2: String, previousAddressOfApplicantCity: String, previousAddressOfApplicantState: String, previousAddressOfApplicantZip: String, cellPhone: String, homePhone: String, howLong: String, previousAddressHowLong: String, presentEmployer: String, yearsOnJob: String, occupation: String, presentEmployersAddress: String, presentEmployersAddressStreet: String, presentEmployersAddressStreet2: String, presentEmployersAddressCity: String, presentEmployersAddressState: String, presentEmployersAddressZip: String, earningsFromEmployment: String, supervisorOrDepartment: String, employersPhoneNumber: String, previousEmployersAddress: String, previousEmployersAddressStreet: String, previousEmployersAddressStreet2: String, previousEmployersAddressCity: String, previousEmployersAddressState: String, previousEmployersAddressZip: String, earningsPerMonth: String, yearsOnJobPreviousEmployer: String, occupationPreviousEmployer: String, previousEmployersPhoneNumber: String, ethnicity: String, race: String, sex: String, maritalStatus: String, applicantEmail: String,type_of_credit_requested:String, otherRace:String)
    {
        self.applicantFirstName = applicantFirstName
        self.applicantEmail = applicantEmail
        self.applicantMiddleName = applicantMiddleName
        self.applicantLastName = applicantLastName
        self.driversLicense = driversLicense
        self.driversLicenseExpDate = driversLicenseExpDate
        self.driversLicenseIssueDate = driversLicenseIssueDate
        self.dateOfBirth = dateOfBirth
        self.socialSecurityNumber = socialSecurityNumber
        self.addressOfApplicant = addressOfApplicant
        self.addressOfApplicantStreet = addressOfApplicantStreet
        self.addressOfApplicantStreet2 = addressOfApplicantStreet2
        self.addressOfApplicantCity = addressOfApplicantCity
        self.addressOfApplicantState = addressOfApplicantState
        self.addressOfApplicantZip = addressOfApplicantZip
        self.previousAddressOfApplicant = previousAddressOfApplicant
        self.previousAddressOfApplicantStreet = previousAddressOfApplicantStreet
        self.previousAddressOfApplicantStreet2 = previousAddressOfApplicantStreet2
        self.previousAddressOfApplicantCity = previousAddressOfApplicantCity
        self.previousAddressOfApplicantState = previousAddressOfApplicantState
        self.previousAddressOfApplicantZip = previousAddressOfApplicantZip
        self.cellPhone = cellPhone
        self.homePhone = homePhone
        self.howLong = howLong
        self.previousAddressHowLong = previousAddressHowLong
        self.presentEmployer = presentEmployer
        self.yearsOnJob = yearsOnJob
        self.occupation = occupation
        self.presentEmployersAddress = presentEmployersAddress
        self.presentEmployersAddressStreet = presentEmployersAddressStreet
        self.presentEmployersAddressStreet2 = presentEmployersAddressStreet2
        self.presentEmployersAddressCity = presentEmployersAddressCity
        self.presentEmployersAddressState = presentEmployersAddressState
        self.presentEmployersAddressZip = presentEmployersAddressZip
        self.earningsFromEmployment = earningsFromEmployment
        self.supervisorOrDepartment = supervisorOrDepartment
        self.employersPhoneNumber = employersPhoneNumber
        self.previousEmployersAddress = previousEmployersAddress
        self.previousEmployersAddressStreet = previousEmployersAddressStreet
        self.previousEmployersAddressStreet2 = previousEmployersAddressStreet2
        self.previousEmployersAddressCity = previousEmployersAddressCity
        self.previousEmployersAddressState = previousEmployersAddressState
        self.previousEmployersAddressZip = previousEmployersAddressZip
        self.earningsPerMonth = earningsPerMonth
        self.yearsOnJobPreviousEmployer = yearsOnJobPreviousEmployer
        self.occupationPreviousEmployer = occupationPreviousEmployer
        self.previousEmployersPhoneNumber = previousEmployersPhoneNumber
        self.type_of_credit_requested = type_of_credit_requested
        self.ethnicity = ethnicity
        self.race = race
        self.sex = sex
        self.maritalStatus = maritalStatus
        self.otherRace = otherRace
        
    }
}

class CoApplicationData:NSObject
{
    var ethnicity, race, sex, CoapplicantEmail, maritalStatus: String?
    var applicantFirstName: String?
    var applicantMiddleName, applicantLastName, driversLicense, driversLicenseExpDate, driversLicenseIssueDate: String?
    var dateOfBirth, socialSecurityNumber, addressOfApplicant, addressOfApplicantStreet: String?
    var addressOfApplicantStreet2, addressOfApplicantCity, addressOfApplicantState, addressOfApplicantZip: String?
    var previousAddressOfApplicant, previousAddressOfApplicantStreet, previousAddressOfApplicantStreet2, previousAddressOfApplicantCity: String?
    var previousAddressOfApplicantState, previousAddressOfApplicantZip, cellPhone, homePhone: String?
    var howLong, previousAddressHowLong, presentEmployer, yearsOnJob: String?
    var occupation, presentEmployersAddress, presentEmployersAddressStreet, presentEmployersAddressStreet2: String?
    var presentEmployersAddressCity, presentEmployersAddressState, presentEmployersAddressZip: String?
    var earningsFromEmployment: String?
    var supervisorOrDepartment, employersPhoneNumber, previousEmployersAddress, previousEmployersAddressStreet: String?
    var previousEmployersAddressStreet2, previousEmployersAddressCity, previousEmployersAddressState, previousEmployersAddressZip: String?
    var earningsPerMonth: String?
    var yearsOnJobPreviousEmployer, occupationPreviousEmployer, previousEmployersPhoneNumber, otherRace: String?
    
        
    
    
    init( applicantFirstName: String, applicantMiddleName: String, applicantLastName: String, driversLicense: String, driversLicenseExpDate: String, driversLicenseIssueDate: String, dateOfBirth: String, socialSecurityNumber: String, addressOfApplicant: String, addressOfApplicantStreet: String, addressOfApplicantStreet2: String, addressOfApplicantCity: String, addressOfApplicantState: String, addressOfApplicantZip: String, previousAddressOfApplicant: String, previousAddressOfApplicantStreet: String, previousAddressOfApplicantStreet2: String, previousAddressOfApplicantCity: String, previousAddressOfApplicantState: String, previousAddressOfApplicantZip: String, cellPhone: String, homePhone: String, howLong: String, previousAddressHowLong: String, presentEmployer: String, yearsOnJob: String, occupation: String, presentEmployersAddress: String, presentEmployersAddressStreet: String, presentEmployersAddressStreet2: String, presentEmployersAddressCity: String, presentEmployersAddressState: String, presentEmployersAddressZip: String, earningsFromEmployment: String, supervisorOrDepartment: String, employersPhoneNumber: String, previousEmployersAddress: String, previousEmployersAddressStreet: String, previousEmployersAddressStreet2: String, previousEmployersAddressCity: String, previousEmployersAddressState: String, previousEmployersAddressZip: String, earningsPerMonth: String, yearsOnJobPreviousEmployer: String, occupationPreviousEmployer: String, previousEmployersPhoneNumber: String, ethnicity: String, race: String, sex: String, maritalStatus: String, CoapplicantEmail: String,otherRace:String)
    {
        self.applicantFirstName = applicantFirstName
        self.CoapplicantEmail = CoapplicantEmail
        self.applicantMiddleName = applicantMiddleName
        self.applicantLastName = applicantLastName
        self.driversLicense = driversLicense
        self.driversLicenseIssueDate = driversLicenseIssueDate
        self.driversLicenseExpDate = driversLicenseExpDate
        self.dateOfBirth = dateOfBirth
        self.socialSecurityNumber = socialSecurityNumber
        self.addressOfApplicant = addressOfApplicant
        self.addressOfApplicantStreet = addressOfApplicantStreet
        self.addressOfApplicantStreet2 = addressOfApplicantStreet2
        self.addressOfApplicantCity = addressOfApplicantCity
        self.addressOfApplicantState = addressOfApplicantState
        self.addressOfApplicantZip = addressOfApplicantZip
        self.previousAddressOfApplicant = previousAddressOfApplicant
        self.previousAddressOfApplicantStreet = previousAddressOfApplicantStreet
        self.previousAddressOfApplicantStreet2 = previousAddressOfApplicantStreet2
        self.previousAddressOfApplicantCity = previousAddressOfApplicantCity
        self.previousAddressOfApplicantState = previousAddressOfApplicantState
        self.previousAddressOfApplicantZip = previousAddressOfApplicantZip
        self.cellPhone = cellPhone
        self.homePhone = homePhone
        self.howLong = howLong
        self.previousAddressHowLong = previousAddressHowLong
        self.presentEmployer = presentEmployer
        self.yearsOnJob = yearsOnJob
        self.occupation = occupation
        self.presentEmployersAddress = presentEmployersAddress
        self.presentEmployersAddressStreet = presentEmployersAddressStreet
        self.presentEmployersAddressStreet2 = presentEmployersAddressStreet2
        self.presentEmployersAddressCity = presentEmployersAddressCity
        self.presentEmployersAddressState = presentEmployersAddressState
        self.presentEmployersAddressZip = presentEmployersAddressZip
        self.earningsFromEmployment = earningsFromEmployment
        self.supervisorOrDepartment = supervisorOrDepartment
        self.employersPhoneNumber = employersPhoneNumber
        self.previousEmployersAddress = previousEmployersAddress
        self.previousEmployersAddressStreet = previousEmployersAddressStreet
        self.previousEmployersAddressStreet2 = previousEmployersAddressStreet2
        self.previousEmployersAddressCity = previousEmployersAddressCity
        self.previousEmployersAddressState = previousEmployersAddressState
        self.previousEmployersAddressZip = previousEmployersAddressZip
        self.earningsPerMonth = earningsPerMonth
        self.yearsOnJobPreviousEmployer = yearsOnJobPreviousEmployer
        self.occupationPreviousEmployer = occupationPreviousEmployer
        self.previousEmployersPhoneNumber = previousEmployersPhoneNumber
        
        self.ethnicity = ethnicity
        self.race = race
        self.sex = sex
        self.maritalStatus = maritalStatus
        self.otherRace = otherRace
        
        
        
    }
}




class OtherIncomeData:NSObject
{
    
    var sourceOfOtherIncome: String?
    var amountMonthly: Int?
    var nearestRelative, relationship, addressRelationship, addressRelationshipStreet: String?
    var addressRelationshipStreet2, addressRelationshipCity, addressRelationshipState, addressRelationshipZip, phoneNumberRelationhip, propertyDetails,applicant_mortgage_company: String?
    var additional_monthly_income: Double?
    var lenderName,lenderAddressStreet, lenderAddressStreet2, lenderAddressCity, lenderAddressState: String?
    var lenderAddressZip, lenderPhone: String?
    var originalPurchasePrice, originalMortageAmount, monthlyMortagePayment: Double?
    var dateAquired: String?
    var presentBalance, presentValueOfHome: Double?
    var secondMortage, lenderNameOrPhone: String?
    var originalAmount, presentBalanceSecondMortage, monthlyPayment: Double?
    var otherObligations: String?
    var totalMonthlyPayments: Double?
    var checkingAccountNo, nameOfBank, bankPhoneNumber, insuranceCompany: String?
    var agent, insurancePhoneNo, coverage,present_balance_second_mortage: String?
    
    var additional_income,second_mortage,lender_name_or_phone,checking_account_no,checking_routing_no,name_of_bank,applicant_signature_date,co_applicant_signature_date,hunterMessageStatus: String
    
    var present_balance, present_value_of_home,original_amount,monthly_payment : Double
    
    var typeOfCreditRequested:String?
    init( sourceOfOtherIncome: String, amountMonthly: Int, nearestRelative: String, relationship: String, addressRelationship: String, addressRelationshipStreet: String, addressRelationshipStreet2: String, addressRelationshipCity: String, addressRelationshipState: String, addressRelationshipZip: String, phoneNumberRelationhip: String, propertyDetails: String, applicant_mortgage_company: String, additional_monthly_income: Double, lenderAddressStreet: String, lenderAddressStreet2: String, lenderAddressCity: String, lenderAddressState: String, lenderAddressZip: String, lenderPhone: String, originalPurchasePrice: Double, originalMortageAmount: Double, monthlyMortagePayment: Double, dateAquired: String, presentBalance: Double, presentValueOfHome: Double, secondMortage: String, lenderNameOrPhone: String, originalAmount: Double, presentBalanceSecondMortage: Double, monthlyPayment: Double, otherObligations: String, totalMonthlyPayments: Double, checkingAccountNo: String, nameOfBank: String, bankPhoneNumber: String, insuranceCompany: String, agent: String, insurancePhoneNo: String, coverage: String, typeOfCreditRequested: String,additional_income: String,second_mortage:String,lender_name_or_phone:String,checking_account_no:String,checking_routing_no:String,name_of_bank:String,applicant_signature_date:String,co_applicant_signature_date:String,hunterMessageStatus:String,present_balance:Double,present_value_of_home:Double,original_amount:Double,present_balance_second_mortage:String,monthly_payment:Double,lenderName:String)
    {
        self.sourceOfOtherIncome = sourceOfOtherIncome
        self.amountMonthly = amountMonthly
        self.nearestRelative = nearestRelative
        self.relationship = relationship
        self.addressRelationship = addressRelationship
        self.addressRelationshipStreet = addressRelationshipStreet
        self.addressRelationshipStreet2 = addressRelationshipStreet2
        self.addressRelationshipCity = addressRelationshipCity
        self.addressRelationshipState = addressRelationshipState
        self.addressRelationshipZip = addressRelationshipZip
        self.phoneNumberRelationhip = phoneNumberRelationhip
        self.propertyDetails = propertyDetails
        self.applicant_mortgage_company = applicant_mortgage_company
        self.additional_monthly_income = additional_monthly_income
        self.lenderAddressStreet = lenderAddressStreet
        self.lenderAddressStreet2 = lenderAddressStreet2
        self.lenderAddressCity = lenderAddressCity
        self.lenderAddressState = lenderAddressState
        self.lenderAddressZip = lenderAddressZip
        self.lenderPhone = lenderPhone
        self.originalPurchasePrice = originalPurchasePrice
        self.originalMortageAmount = originalMortageAmount
        self.monthlyMortagePayment = monthlyMortagePayment
        self.dateAquired = dateAquired
        self.presentBalance = presentBalance
        self.presentValueOfHome = presentValueOfHome
        self.secondMortage = secondMortage
        self.lenderNameOrPhone = lenderNameOrPhone
        self.originalAmount = originalAmount
        self.presentBalanceSecondMortage = presentBalanceSecondMortage
        self.monthlyPayment = monthlyPayment
        self.otherObligations = otherObligations
        self.totalMonthlyPayments = totalMonthlyPayments
        self.checkingAccountNo = checkingAccountNo
        self.nameOfBank = nameOfBank
        self.bankPhoneNumber = bankPhoneNumber
        self.insuranceCompany = insuranceCompany
        self.agent = agent
        self.insurancePhoneNo = insurancePhoneNo
        self.coverage = coverage
        self.lenderName = lenderName
        
        self.additional_income = additional_income
        self.second_mortage = second_mortage
        self.lender_name_or_phone = lender_name_or_phone
        self.checking_account_no = checking_account_no
        self.checking_routing_no = checking_routing_no
        self.name_of_bank = name_of_bank
        self.applicant_signature_date = applicant_signature_date
        self.co_applicant_signature_date = co_applicant_signature_date
        self.hunterMessageStatus = hunterMessageStatus
        
        self.present_balance = present_balance
        self.present_value_of_home = present_value_of_home
        self.original_amount = original_amount
        self.present_balance_second_mortage = present_balance_second_mortage
        self.monthly_payment = monthly_payment
    }
}

class TransitionData:NSObject
{
    var name :String?
    var color: String?
    var transsquarefeet :Float?
    var transHeight :String?
    var transitionHeightId:Int
    init( name: String, color: String, transsquarefeet: Float, transHeight:String,transitionHeightId:Int)
    {
        self.name = name
        self.color = color
        self.transsquarefeet = transsquarefeet
        self.transHeight = transHeight
        self.transitionHeightId = transitionHeightId
        
    }
}

class ContractData:NSObject
{
    
    //contract_scheduling_Btn, contract_motion_btn, contract_floor_protection_Btn, contract_plumbing_Btn, contract_plumbing_option_Btn,contract_plumbing_option_Btn2, contract_additional_other_cost_Btn, contract_additional_other_subfloor_Btn, contract_additional_other_leveling_Btn, contract_additional_other_screwdown_Btn, contract_additional_other_hardwood_removal_Btn, contract_additional_other_door_removal_Btn, contract_additional_other_bifold_removal_Btn,contract_floor_protection, contract_right_to_cure_Btn, contract_owner_responsibility_Btn,electronicsAuthorizationBtn,electronicsAuthorizationBtn2
    
    var contract_owner_reviewed_status, contract_transition, contract_molding_status,contract_molding_none_status,contract_molding_waterproof_status, contract_molding_unfinished_status,contract_molding_CovedBaseboard_status, contract_risk_free_status, contract_lifetime_guarantee_status, contract_lead_safe_status,contract_deposit_status, contract_final_payment_status, contract_time_of_performance_status,contract_notices_to_owners_status,contract_notices_of_cancellation,contract_scheduling_status, contract_motion_status, contract_floor_protection_status, contract_plumbing_status, contract_plumbing_option_status, contract_additional_other_cost_status, contract_additional_other_subfloor_status, contract_additional_other_leveling_status, contract_additional_other_screwdown_status, contract_additional_other_hardwood_removal_status, contract_additional_other_door_removal_status,contract_additional_other_bifold_removal_status,contract_floor_protection, contract_right_to_cure_status, contract_owner_responsibility_status,electronicsAuthorization1Status,electronicsAuthorization2Status,electronicsAuthorization3Status: Int
    
    var dictionary: [String: Any] {
        return ["contract_owner_reviewed_status": contract_owner_reviewed_status,
                "contract_transition": contract_transition,
                "contract_molding_status": contract_molding_status,
                "contract_molding_none_status":contract_molding_none_status,
                "contract_molding_waterproof_status":contract_molding_waterproof_status,
                "contract_molding_unfinished_status":contract_molding_unfinished_status,
                "contract_molding_CovedBaseboard_status":contract_molding_CovedBaseboard_status,
                "contract_risk_free_status":contract_risk_free_status,
                "contract_lifetime_guarantee_status":contract_lifetime_guarantee_status,
                "contract_lead_safe_status":contract_lead_safe_status,
                "contract_deposit_status":contract_deposit_status,
                "contract_final_payment_status":contract_final_payment_status,
                "contract_time_of_performance_status":contract_time_of_performance_status,
                "contract_notices_to_owners_status":contract_notices_to_owners_status,
                "contract_notices_of_cancellation":contract_notices_of_cancellation,
                
                "contract_scheduling_status":contract_scheduling_status,
                "contract_motion_status":contract_motion_status,
                "contract_floor_protection_status":contract_floor_protection_status,
                "contract_plumbing_status":contract_plumbing_status,
                "contract_plumbing_option_status":contract_plumbing_option_status,
                "contract_additional_other_cost_status":contract_additional_other_cost_status,
                "contract_additional_other_subfloor_status":contract_additional_other_subfloor_status,
                "contract_additional_other_leveling_status":contract_additional_other_leveling_status,
                "contract_additional_other_screwdown_status":contract_additional_other_screwdown_status,
                "contract_additional_other_hardwood_removal_status":contract_additional_other_hardwood_removal_status,
                "contract_additional_other_door_removal_status":contract_additional_other_door_removal_status,
                "contract_additional_other_bifold_removal_status":contract_additional_other_bifold_removal_status,
                "contract_floor_protection":contract_floor_protection,
                "contract_right_to_cure_status":contract_right_to_cure_status,
                "contract_owner_responsibility_status":contract_owner_responsibility_status,
                "electronicsAuthorization1Status":electronicsAuthorization1Status,
                "electronicsAuthorization2Status":electronicsAuthorization2Status,
                "electronicsAuthorization3Status":electronicsAuthorization3Status
        ]
    }
    
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    //contract_owner_reviewed_status, contract_transition, contract_molding_status,contract_molding_none_status,contract_molding_waterproof_status, contract_molding_unfinished_status, contract_risk_free_status, contract_lifetime_guarantee_status, contract_lead_safe_status,contract_deposit_status, contract_final_payment_status, contract_time_of_performance_status,contract_notices_to_owners_status,contract_notices_of_cancellation,contract_scheduling_status, contract_motion_status, contract_floor_protection_status, contract_plumbing_status, contract_plumbing_option_status, contract_additional_other_cost_status, contract_additional_other_subfloor_status, contract_additional_other_leveling_status, contract_additional_other_screwdown_status, contract_additional_other_hardwood_removal_status, contract_additional_other_door_removal_status,contract_additional_other_bifold_removal_status,contract_floor_protection, contract_right_to_cure_status, contract_owner_responsibility_status,electronicsAuthorization1Status,electronicsAuthorization2Status
    
    init(contract_owner_reviewed_status: Int, contract_transition: Int, contract_molding_status: Int,contract_molding_none_status: Int, contract_molding_waterproof_status: Int, contract_molding_unfinished_status: Int, contract_molding_CovedBaseboard_status:Int,contract_risk_free_status: Int, contract_lifetime_guarantee_status: Int, contract_lead_safe_status:Int,contract_deposit_status: Int, contract_final_payment_status: Int,contract_time_of_performance_status:Int, contract_notices_to_owners_status:Int,contract_notices_of_cancellation:Int, contract_scheduling_status: Int,contract_motion_status:Int,  contract_floor_protection_status: Int, contract_plumbing_status: Int, contract_plumbing_option_status: Int, contract_additional_other_cost_status: Int, contract_additional_other_subfloor_status: Int, contract_additional_other_leveling_status: Int, contract_additional_other_screwdown_status: Int,  contract_additional_other_hardwood_removal_status: Int, contract_additional_other_door_removal_status: Int, contract_additional_other_bifold_removal_status: Int,contract_floor_protection:Int, contract_right_to_cure_status: Int, contract_owner_responsibility_status:Int,electronicsAuthorization1Status:Int,electronicsAuthorization2Status: Int,electronicsAuthorization3Status:Int)
    
    {
        self.contract_owner_reviewed_status = contract_owner_reviewed_status
        self.contract_transition = contract_transition
        self.contract_molding_status = contract_molding_status
        self.contract_molding_none_status = contract_molding_none_status
        self.contract_molding_waterproof_status = contract_molding_waterproof_status
        self.contract_molding_unfinished_status = contract_molding_unfinished_status
        self.contract_molding_CovedBaseboard_status = contract_molding_CovedBaseboard_status
        self.contract_risk_free_status = contract_risk_free_status
        self.contract_lifetime_guarantee_status = contract_lifetime_guarantee_status
        self.contract_deposit_status = contract_deposit_status
        self.contract_final_payment_status = contract_final_payment_status
        self.contract_lead_safe_status = contract_lead_safe_status
        self.contract_notices_to_owners_status = contract_notices_to_owners_status
        self.contract_notices_of_cancellation = contract_notices_of_cancellation
        self.contract_scheduling_status = contract_scheduling_status
        self.contract_motion_status = contract_motion_status
        self.contract_time_of_performance_status = contract_time_of_performance_status
        self.contract_floor_protection_status = contract_floor_protection_status
        self.contract_plumbing_status = contract_plumbing_status
        self.contract_plumbing_option_status = contract_plumbing_option_status
        self.contract_additional_other_cost_status = contract_additional_other_cost_status
        self.contract_additional_other_subfloor_status = contract_additional_other_subfloor_status
        self.contract_additional_other_leveling_status = contract_additional_other_leveling_status
        self.contract_additional_other_screwdown_status = contract_additional_other_screwdown_status
        self.contract_additional_other_hardwood_removal_status = contract_additional_other_hardwood_removal_status
        self.contract_additional_other_door_removal_status = contract_additional_other_door_removal_status
        self.contract_additional_other_bifold_removal_status = contract_additional_other_bifold_removal_status
        self.contract_floor_protection = contract_floor_protection
        self.contract_right_to_cure_status = contract_right_to_cure_status
        self.contract_owner_responsibility_status = contract_owner_responsibility_status
        self.electronicsAuthorization1Status = electronicsAuthorization1Status
        self.electronicsAuthorization2Status = electronicsAuthorization2Status
        self.electronicsAuthorization3Status = electronicsAuthorization3Status
        
    }
    
    convenience override init(){
        self.init()
    }
}

class PaymentOption: NSObject{
    var payment_method: String? = ""
    var card_number: String? = ""
    var expiry_date: String? = ""
    var card_name: String? = ""
    var card_pinorcvv: String? = ""
    var check_number: String? = ""
    var check_routing_number: String? = ""
    var check_account_number: String? = ""
    
    override init(){
        
    }
    var dictionary: [String: String?] {
        return ["payment_method":payment_method,
                "card_number":card_number,
                "expiry_date":expiry_date,
                "card_name":card_name,
                "card_pinorcvv":card_pinorcvv,
                "check_number":check_number,
                "check_routing_number":check_routing_number,
                "check_account_number":check_account_number
               ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
}
//struct EncodingData:Codable
//{
//    var data:CustomerEncodingDecodingDetails?
//}

struct CustomerEncodingDecodingDetails:Codable
{
//    var operation_mode:String?
//    var appVersion:String?
//    var paymentDetails:PaymentDetailAppointment?
//    var answer:[AnswerDetails]?
    var applicationInfo:ApplicantInfoDetailsSecret?
   // var appointmentId:Int?
    var paymentMethods:paymentMethodDetailsSecret?
//    var rooms:[RoomsDetails]?
//    var customer:CustomerDetails?
//    var dataCompleted:Int?
    enum CodingKeys: String, CodingKey
    {
//        case operation_mode = "operation_mode"
//        case appVersion = "app_version"
//        case paymentDetails = "paymentdetails"
//        case answer = "answer"
        case applicationInfo = "applicationInfo"
       // case appointmentId = "appointment_id"
        case paymentMethods = "paymentmethod"
//        case rooms = "rooms"
//        case customer = "customer"
//        case dataCompleted = "data_completed"
    }
}
struct PaymentDetailAppointment:Codable
{
    var discount:Int?
    var financeAmount:Int?
    var selectedPackageId:Int?
    var photoPermission:Int?
    var paymentMethod:String?
    var finalPayment:Int?
    var savings:Int?
    var downPaymentAmount:Int?
    var additionalCost:Double?
    var msrp:Double?
    var price:Double?
    var coApplicantSkip:Int?
    var installationdate:String?
    var appointmentId:Int?
    var financeOptionId:Int?
    var discountHistoryLine:[discountHistoryLineDetails]?
    var adjustment:Double?
    var specialPriceId:Int?
    var stairSpecialPriceId:Int?
    
    enum CodingKeys: String, CodingKey
    {
        case discount = "discount"
        case financeAmount = "finance_amount"
        case selectedPackageId = "selected_package_id"
        case photoPermission = "photo_permission"
        case paymentMethod = "payment_method"
        case finalPayment = "final_payment"
        case savings = "savings"
        case downPaymentAmount = "down_payment_amount"
        case additionalCost = "additional_cost"
        case msrp = "msrp"
        case price = "price"
        case coApplicantSkip = "coapplicant_skip"
        case installationdate = "installation_date"
        case appointmentId = "appointment_id"
        case financeOptionId = "finance_option_id"
        case discountHistoryLine = "discount_history_line"
        case adjustment = "adjustment"
        case specialPriceId = "special_price_id"
        case stairSpecialPriceId = "stair_special_price_id"
    }
    
}
struct discountHistoryLineDetails:Codable
{
    var promotype:Int?
    var value:String?
    var actualPrice:Double?
    var type:String?
    var salePrice:Double?
    var discountAmount:Double?
    
    enum CodingKeys: String, CodingKey
    {
        case promotype = "promo_type"
        case value = "value"
        case actualPrice = "actual_price"
        case type = "type"
        case salePrice = "sale_price"
        case discountAmount = "discount_amount"
    }
    
}
struct AnswerDetails:Codable
{
    var roomid:Int?
    var answer:[String]?
    var answerId:Int?
    
    enum CodingKeys: String, CodingKey
    {
        case roomid = "room_id"
        case answer = "answer"
        case answerId = "question_id"
    }
}
struct ApplicantInfoDetailsSecret:Codable
{
    var coApplicantPresentEmployersState:String?
    var addressRelationshipCity:String?
    var coApplicantSignatureDate:String?
    var coApplicantPreviousEmployerCity:String?
    var coApplicantDateOfBirth:String?
    var coApplicantPreviousStreet2:String?
    var dateAcquired:String?
    var hunterMessageStatus:String?
    var occupationPreviousEmployer:String?
    var zip:String?
    var homePhone:String?
    var presentValueOfHome:Int?
    var previousAddressOfApplicantStreet:String?
    var coApplicantPreviousEmployersZip:String?
    var typeOfCreditRequest:String?
    var coApplicantEarningsFromEmployment:Int?
    var coApplicantCity:String?
    var totalPrice:String?
    var coApplicantPresentEmployersStreet:String?
    var coApplicantSupervisorOrDepartment:String?
    var coApplicantOccupation:String?
    var coApplicantPresentEmployerAddress:String?
    var coApplicantdriversLicenseIssueDate:String?
    var samePropertyAddress:String?
    var socialSecurityNumber:String?
    var checkingRoutingNo:String?
    var applicantMortgageCompany:String?
    var earningsFromEmployment:Int?
    var coApplicantPreviousEmployersPhoneNumber:String?
    var driverseLicenseIssueDate:String?
    var applicantEmail:String?
    var race:String?
    var coApplicantRace:String?
    var coApplicantLastName:String?
    var insuranceCompany:String?
    var previousAddressOfApplicantZip:String?
    var applicantOtherRace:String?
    var addressOfApplicantZip:String?
    var previousAddressHowLong:String?
    var addressOfApplicantCity:String?
    var ethnicity:String?
    var addressRelationshipStreet:String?
    var coApplicantDriversLicenseExpiryDate:String?
    var coApplicantPreviousEmployersAddress:String?
    var lenderAddressCity:String?
    var applicantNotFurnishInfo:String?
    var coApplicantOtherRace:String?
    var originalPurchasePrice:Int?
    var coApplicantFirstName:String?
    var downPayment:String?
    var earningsPerMonth:String?
    var coApplicantPreviousZip:String?
    var street2:String?
    var ownersIfDifferent:String?
    var coApplicantHowLong:String?
    var lenderPhone:String?
    var secondMortage:String?
    var additionalIncome:String?
    var previousEmployersAddressStreet:String?
    var presentEmployer:String?
    var propertyDetails:String?
    var cellPhone:String?
    var presentBalanceSecondMortage:Int?
    var monthlyMortagePayment:Int?
    var coApplicantSkip:Int?
    var previousAddressOfApplicant:String?
    var city:String?
    var coApplicantPreviousStreet:String?
    var owners:String?
    var coApplicantSocialSecurityNumber:String?
    var employersPhoneNumber:String?
    var applicantLastName:String?
    var coApplicantEmployersPhoneNumber:String?
    var totalMonthlyPayment:Int?
    var coApplicantEarningsPerMonth:Int?
    var originalAmount:Int?
    var supervisorOrDepartment:String?
    var relationship:String?
    
    var coApplicantAddressOfApplicant:String?
    var presentBalance:Int?
    var coApplicantSecondaryPhone:String?
    var applicantMiddleName:String?
    var coApplicantPreviousEmployersStreet:String?
    var previousAddressOfApplicantStreet2:String?
    var coApplicantPreviousEmployersState:String?
    var dateOfBirth:String?
    var coApplicantYearsOnJob:String?
    var addressRealtionShip:String?
    var street:String?
    var presentEmployersAddressStreet2:String?
    var phoneNumberRealtionShip:String?
    var coApplicantPreviousAddressOfApplicant:String?
    var jointCreditinitials:String?
    var coApplicantPresentEmployersstreet2:String?
    var coApplicantMaritalStatus:String?
    var coApplicantMiddleName:String
    var addressRealtionshipStreet2:String?
    var amountfinanced:String?
    var typeOfLoan:String?
    var coApplicantState:String?
    var driverseLicense:String?
    var coApplicantstreet:String?
    var yearsOnJobPreviousEmployer:String?
    var applicantFirstName:String?
    var insurancePhoneNumber:String?
    var coApplicantSex:String?
    var lenderAddress:String?
    var otherObligation:Int?
    var sex:String?
    var previousEmployerAddressStreet2:String?
    var coverage:String?
    var applicantSignatureDate:String?
    var monthlyPayment:Int?
    var presentEmployersAddressState:String?
    var coApplicantEmail:String?
    var workTobeDone:String?
    var presentEmployersAddressStreet:String?
    var lendersAddressState:String?
    var originalMortageAmount:Int?
    
    var amountMonthly:Int?
    var coApplicantEthnicity:String?
    var addressRelationshipState:String?
    var coApplicantPhone:String?
    var presentEmployersAddressZip:String?
    var previousEmployersAddressZip:String?
    var sourceOfOtherIncome:String?
    var lenderNameorPhone:String?
    var yearsOnJob:String?
    var coApplicantNotFurnishInfo:String?
    var agent:String?
    var previousEmployersPhoneNumber:String?
    var previousAddressOfApplicantCity:String?
    var nameOfBank:String?
    var coApplicantStreet2:String?
    var addressOfApplicantState:String?
    var occupation:String?
    var coApplicantPresentEmployerZip:String?
    var coApplicantPreviousState:String?
    var addressOfProperty:String?
    var lenderAddressStreet:String?
    var bankPhoneNumber:String?
    var appointmentId:Int?
    var coApplicantOccupationPreviousEmployer:String?
    var coApplicantdriverLicense:String?
    var howLong:String?
    var coApplicantPresentEmployersCity:String?
    var previousEmployersAddress:String?
    var previousEmployersAddressState:String?
    var coApplicantPreviousCity:String?
    var nearestRelative:String?
    var addressOfApplicantStreet:String?
    var addressOfApplicantStreet2:String?
    var typeOfProperty:String?
    var maritalStatus:String?
    var presentEmployersAddress:String?
    var coApplicantZip:String?
    var lenderAddressStreet2:String?
    var state:String?
    var coApplicantYearsOnJobPreviousEmployer:String?
    var previousEmployerAddressCity:String?
    var addressOfApplicant:String?
    var checkingAccountNumber:String?
    var addressRelationshipZip:String?
    var previousAddressOfApplicantState:String?
    var additionalMonthlyIncome:Int?
    var presentEmployersAddressCity:String?
    var coApplicantPreviousEmployersStreet2:String?
    var lenderAddressZip:String?
    var driverLicenseExpdate:String?
    var coApplicantPresentEmployer:String?
    

    
    enum CodingKeys: String, CodingKey
    {
        case coApplicantPresentEmployersState = "co_applicant_present_employers_state"
        case addressRelationshipCity = "address_relationship_city"
        case coApplicantSignatureDate = "co_applicant_signature_date"
        case coApplicantPreviousEmployerCity = "co_applicant_previous_employers_city"
        case coApplicantDateOfBirth = "co_applicant_date_of_birth"
        case coApplicantPreviousStreet2 = "co_applicant_previous_street2"
        case dateAcquired = "date_aquired"
        case hunterMessageStatus = "hunterMessageStatus"
        case occupationPreviousEmployer = "occupation_previous_employer"
        case zip = "zip"
        case homePhone = "home_phone"
        case presentValueOfHome = "present_value_of_home"
        case previousAddressOfApplicantStreet = "previous_address_of_applicant_street"
        case coApplicantPreviousEmployersZip = "co_applicant_previoust_employers_zip"
        case typeOfCreditRequest = "type_of_credit_requested"
        case coApplicantEarningsFromEmployment = "co_applicant_earnings_from_employment"
        case coApplicantCity = "co_applicant_city"
        case totalPrice = "total_price"
        case coApplicantPresentEmployersStreet = "co_applicant_present_employers_street"
        case coApplicantSupervisorOrDepartment = "co_applicant_supervisor_or_department"
        case coApplicantOccupation = "co_applicant_occupation"
        case coApplicantPresentEmployerAddress = "co_applicant_present_employers_address"
        case coApplicantdriversLicenseIssueDate = "co_applicant_drivers_license_issue_date"
        case samePropertyAddress = "same_property_address"
        case socialSecurityNumber = "social_security_number"
        case checkingRoutingNo = "checking_routing_no"
        case applicantMortgageCompany = "applicant_mortgage_company"
        case earningsFromEmployment = "earnings_from_employment"
        case coApplicantPreviousEmployersPhoneNumber = "co_applicant_previous_employers_phone_number"
        case driverseLicenseIssueDate = "drivers_license_issue_date"
        case applicantEmail = "applicant_email"
        case race = "race"
        case coApplicantRace = "co_applicant_race"
        case coApplicantLastName = "co_applicant_last_name"
        case insuranceCompany = "insurance_company"
        case previousAddressOfApplicantZip = "previous_address_of_applicant_zip"
        case applicantOtherRace = "applicant_otherRace"
        case addressOfApplicantZip = "address_of_applicant_zip"
        case previousAddressHowLong = "previous_address_how_long"
        case addressOfApplicantCity = "address_of_applicant_city"
        case ethnicity = "ethnicity"
        case addressRelationshipStreet = "address_relationship_street"
        case coApplicantDriversLicenseExpiryDate = "co_applicant_drivers_license_exp_date"
        case coApplicantPreviousEmployersAddress = "co_applicant_previous_employers_address"
        case lenderAddressCity = "lender_address_city"
        case applicantNotFurnishInfo = "applicant_not_furnish_info"
        case coApplicantOtherRace = "co_applicant_otherRace"
        case originalPurchasePrice = "original_purchase_price"
        case coApplicantFirstName = "co_applicant_first_name"
        case downPayment = "downpayment"
        case earningsPerMonth = "earnings_per_month"
        case coApplicantPreviousZip = "co_applicant_previous_zip"
        case street2 = "street2"
        case ownersIfDifferent = "owners_if_different"
        case coApplicantHowLong = "co_applicant_how_long"
        case lenderPhone = "lender_phone"
        case secondMortage = "second_mortage"
        case additionalIncome = "additional_income"
        case previousEmployersAddressStreet = "previous_employers_address_street"
        case presentEmployer = "present_employer"
        case propertyDetails = "property_details"
        case cellPhone = "cell_phone"
        case presentBalanceSecondMortage = "present_balance_second_mortage"
        case monthlyMortagePayment = "monthly_mortage_payment"
        case coApplicantSkip = "co_applicant_skip"
        case previousAddressOfApplicant = "previous_address_of_applicant"
        case city = "city"
        case coApplicantPreviousStreet = "co_applicant_previous_street"
        case owners = "owners"
        case coApplicantSocialSecurityNumber = "co_applicant_social_security_number"
        case employersPhoneNumber = "employers_phone_number"
        case applicantLastName = "applicant_last_name"
        case coApplicantEmployersPhoneNumber = "co_applicant_employers_phone_number"
        case totalMonthlyPayment = "total_monthly_payments"
        case coApplicantEarningsPerMonth = "co_applicant_earnings_per_month"
        case originalAmount = "original_amount"
        case supervisorOrDepartment = "supervisor_or_department"
        case relationship = "relationship"
        case coApplicantAddressOfApplicant = "co_applicant_address_of_applicant"
        case presentBalance = "present_balance"
        case coApplicantSecondaryPhone = "co_applicant_secondary_phone"
        case applicantMiddleName = "applicant_middle_name"
        case coApplicantPreviousEmployersStreet = "co_applicant_previous_employers_street"
        case previousAddressOfApplicantStreet2 = "previous_address_of_applicant_street2"
        case coApplicantPreviousEmployersState = "co_applicant_previous_employers_state"
        case dateOfBirth = "date_of_birth"
        case coApplicantYearsOnJob = "co_applicant_years_on_job"
        case addressRealtionShip = "address_relationship"
        case street = "street"
        case presentEmployersAddressStreet2 = "present_employers_address_street2"
        case phoneNumberRealtionShip = "phone_number_relationship"
        case coApplicantPreviousAddressOfApplicant = "co_applicant_previous_address_of_applicant"
        case jointCreditinitials = "joint_credit_initials"
        case coApplicantPresentEmployersstreet2 = "co_applicant_present_employers_street2"
        case coApplicantMaritalStatus = "co_applicant_marital_status"
        case coApplicantMiddleName = "co_applicant_middle_name"
        case addressRealtionshipStreet2 = "address_relationship_street2"
        case amountfinanced = "amount_financed"
        case typeOfLoan = "type_of_loan"
        case coApplicantState = "co_applicant_state"
        case driverseLicense = "drivers_license"
        case coApplicantstreet = "co_applicant_street"
        case yearsOnJobPreviousEmployer = "years_on_job_previous_employer"
        case applicantFirstName = "applicant_first_name"
        case insurancePhoneNumber = "insurance_phone_no"
        case coApplicantSex = "co_applicant_sex"
        case lenderAddress = "lender_address"
        case otherObligation = "other_obligations"
        case sex = "sex"
        case previousEmployerAddressStreet2 = "previous_employers_address_street2"
        case coverage = "coverage"
        case applicantSignatureDate = "applicant_signature_date"
        case monthlyPayment = "monthly_payment"
        case presentEmployersAddressState = "present_employers_address_state"
        case coApplicantEmail = "co_applicant_email"
        case workTobeDone = "work_to_be_done"
        case presentEmployersAddressStreet = "present_employers_address_street"
        case lendersAddressState = "lender_address_state"
        case originalMortageAmount = "original_mortage_amount"
        case amountMonthly = "amount_monthly"
        case coApplicantEthnicity = "co_applicant_ethnicity"
        case addressRelationshipState = "address_relationship_state"
        case coApplicantPhone = "co_applicant_phone"
        case presentEmployersAddressZip = "present_employers_address_zip"
        case previousEmployersAddressZip = "previous_employers_address_zip"
        case sourceOfOtherIncome = "source_of_other_income"
        case lenderNameorPhone = "lender_name_or_phone"
        case yearsOnJob = "years_on_job"
        case coApplicantNotFurnishInfo = "co_appicant_not_furnish_info"
        case agent = "agent"
        case previousEmployersPhoneNumber = "previous_employers_phone_number"
        case previousAddressOfApplicantCity = "previous_address_of_applicant_city"
        case nameOfBank = "name_of_bank"
        case coApplicantStreet2 = "co_applicant_street2"
        case addressOfApplicantState = "address_of_applicant_state"
        case occupation = "occupation"
        case coApplicantPresentEmployerZip = "co_applicant_present_employers_zip"
        case coApplicantPreviousState = "co_applicant_previous_state"
        case addressOfProperty = "address_of_property"
        case lenderAddressStreet = "lender_address_street"
        case bankPhoneNumber = "bank_phone_number"
        case appointmentId = "appointment_id"
        case coApplicantOccupationPreviousEmployer = "co_applicant_occupation_previous_employer"
        case coApplicantdriverLicense = "co_applicant_drivers_license"
        case howLong = "how_long"
        case coApplicantPresentEmployersCity = "co_applicant_present_employers_city"
        case previousEmployersAddress = "previous_employers_address"
        case previousEmployersAddressState = "previous_employers_address_state"
        case coApplicantPreviousCity = "co_applicant_previous_city"
        case nearestRelative = "nearest_relative"
        case addressOfApplicantStreet = "address_of_applicant_street"
        case addressOfApplicantStreet2 = "address_of_applicant_street2"
        case typeOfProperty = "type_of_property"
        case maritalStatus = "marital_status"
        case presentEmployersAddress = "present_employers_address"
        case coApplicantZip = "co_applicant_zip"
        case lenderAddressStreet2 = "lender_address_street2"
        case state = "state"
        case coApplicantYearsOnJobPreviousEmployer = "co_applicant_years_on_job_previous_employer"
        case previousEmployerAddressCity = "previous_employers_address_city"
        case addressOfApplicant = "address_of_applicant"
        case checkingAccountNumber = "checking_account_no"
        case addressRelationshipZip = "address_relationship_zip"
        case previousAddressOfApplicantState = "previous_address_of_applcant_state"
        case additionalMonthlyIncome = "additional_monthly_income"
        case presentEmployersAddressCity = "present_employers_address_city"
        case coApplicantPreviousEmployersStreet2 = "co_applicant_previous_employers_street2"
        case lenderAddressZip = "lender_address_zip"
        case driverLicenseExpdate = "drivers_license_exp_date"
        case coApplicantPresentEmployer = "co_applicant_present_employer"
    }
}
struct paymentMethodDetailsSecret:Codable
{
    var cardNumber:String?
    var checkingRoutingNumber:String?
    var expiryDate:String?
    var cardName:String?
    var checkAccountNumber:String?
    var cardPinOrCvv:String?
    var paymentMethod:String?
    var checkNumber:String?
    enum CodingKeys: String, CodingKey
    {
        case cardNumber = "card_number"
        case checkingRoutingNumber = "check_routing_number"
        case expiryDate = "expiry_date"
        case cardName = "card_name"
        case checkAccountNumber = "check_account_number"
        case cardPinOrCvv = "card_pinorcvv"
        case paymentMethod = "payment_method"
        case checkNumber = "check_number"
    }
}
struct RoomsDetails:Codable
{
    var roomId:Int?
    var materialId:Int?
    var roomName:String?
    var roomAdjustedArea:String?
    var transition:[transitionDetails]?
    var roomPerimeter:Double?
    var roomComments:String?
    var roomAreaImage:String?
    var excludeFromCalculation:Int?
    var roomArea:String?
    var roomImageName:[String]?
    var mouldingType:String?
    
    enum CodingKeys: String, CodingKey
    {
        case roomId = "room_id"
        case materialId = "material_id"
        case roomName = "room_name"
        case roomAdjustedArea = "room_adjusted_area"
        case transition = "transitions"
        case roomPerimeter = "room_perimeter"
        case roomComments = "room_comments"
        case roomAreaImage = "room_area_image"
        case excludeFromCalculation = "exclude_from_calculation"
        case roomArea = "room_area"
        case roomImageName = "room_image_names"
        case mouldingType = "moulding_type"
    }
}
struct transitionDetails:Codable
{
    var name:String?
    var width:Double?
    
    enum CodingKeys: String, CodingKey
    {
        case name = "name"
        case width = "width"
    }
}
struct CustomerDetails:Codable
{
    var country:String?
    var coApplicantPhone:String?
    var street2:String?
    var zip:String?
    var salesPerson:String?
    var countryCode:String?
    var appointmnetResult:String?
    var coApplicantEmail:String?
    var street:String?
    var ApplicantFirstName:String?
    var city:String?
    var customerId:String?
    var appointmentDate:String?
    var partnerLatitude:Int?
    var coApplicantLastName:String?
    var state:String?
    var applicantMiddleName:String?
    var coApplicantMiddleName:String?
    var AdditionalComments:String?
    var countryId:Int?
    var coApplicantCity:String?
    var appointmentId:Int?
    var coApplicantSecondaryPhone:String?
    var coApplicantState:String?
    var salesPersonId:Int?
    var partnerLongtitude:Int?
    var coApplicantZip:String?
    var sendPhysicaldocument:Int?
    var timeZone:String?
    var completedDate:String?
    var applicantLastName:String?
    var coApplicantFirstName:String?
    
    enum CodingKeys: String, CodingKey
    {
        case country = "country"
        case coApplicantPhone = "co_applicant_phone"
        case street2 = "street2"
        case zip = "zip"
        case salesPerson = "sales_person"
        case countryCode = "country_code"
        case appointmnetResult = "appointment_result"
        case coApplicantEmail = "co_applicant_email"
        case street = "street"
        case ApplicantFirstName = "applicant_first_name"
        case city = "city"
        case customerId = "customer_id"
        case appointmentDate = "appointment_date"
        case partnerLatitude = "partner_latitude"
        case coApplicantLastName = "co_applicant_last_name"
        case state = "state"
        case applicantMiddleName = "applicant_middle_name"
        case coApplicantMiddleName = "co_applicant_middle_name"
        case AdditionalComments = "additional_comments"
        case countryId = "country_id"
        case coApplicantCity = "co_applicant_city"
        case appointmentId = "appointment_id"
        case coApplicantSecondaryPhone = "co_applicant_secondary_phone"
        case coApplicantState = "co_applicant_state"
        case salesPersonId = "salesperson_id"
        case partnerLongtitude = "partner_longitude"
        case coApplicantZip = "co_applicant_zip"
        case sendPhysicaldocument = "send_physical_document"
        case timeZone = "timezone"
        case completedDate = "completed_date"
        case applicantLastName = "applicant_last_name"
        case coApplicantFirstName = "co_applicant_first_name"
    }
}
