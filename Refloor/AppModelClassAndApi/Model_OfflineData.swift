//
//  Model_OfflineData.swift
//  Refloor
//
//  Created by Arun Rajendrababu on 18/11/21.
//  Copyright © 2021 oneteamus. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm
import UIKit

public struct ListTransform<T: RealmSwift.Object>: TransformType where T: BaseMappable {
    
    public typealias Serialize = (List<T>) -> ()
    private let onSerialize: Serialize
    
    public init(onSerialize: @escaping Serialize = { _ in }) {
        self.onSerialize = onSerialize
    }
    
    public typealias Object = List<T>
    public typealias JSON = Array<Any>
    
    public func transformFromJSON(_ value: Any?) -> List<T>? {
        let list = List<T>()
        if let objects = Mapper<T>().mapArray(JSONObject: value) {
            list.append(objectsIn: objects)
        }
        self.onSerialize(list)
        return list
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value?.compactMap { $0.toJSON() }
    }
    
}

class FloorImageStorage:Object{
    @objc dynamic var imageName:String = ""
}


class MasterData : Object, Mappable {
    @objc dynamic var result : String?
    @objc dynamic var message : String?
    var rooms = List<rf_master_roomname>()
    var questionnaires = List<rf_master_question>()
    var flooring_colors = List<rf_master_color_list>()
    var molding_types = List<rf_master_molding>()
    var discount_coupons = List<rf_master_discount>()
    var product_plans = List<rf_master_product_package>()
    var payment_options = List<rf_master_payment_option>()
    var appointments = List<rf_master_appointment>()
    var appointmentResults = List<rf_master_appointment_results>()
    var specialPrice = List<rf_specialPrice_results>()
    var promotionCodes = List<rf_promotionCodes_results>()
    var transitionHeights = List<rf_transitionHeights_results>()
    var floorColourList = List<rf_floorColour_results>()
    var stairColourList = List<rf_stairColour_results>()
    @objc dynamic var min_sale_price : Double = 1500.0
    @objc dynamic var max_no_transitions: Int = 4
    @objc dynamic var resitionDate : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        result <- map["result"]
        message <- map["message"]
        rooms <- (map["rooms"], ListTransform<rf_master_roomname>())
        questionnaires <- (map["questionnaires"], ListTransform<rf_master_question>())
        flooring_colors <- (map["flooring_colors"], ListTransform<rf_master_color_list>())
        molding_types <- (map["molding_types"], ListTransform<rf_master_molding>())
        discount_coupons <- (map["discount_coupons"], ListTransform<rf_master_discount>())
        product_plans <- (map["product_plans"], ListTransform<rf_master_product_package>())
        payment_options <- (map["payment_options"], ListTransform<rf_master_payment_option>())
        appointments <- (map["appointments"], ListTransform<rf_master_appointment>())
        appointmentResults <- (map["appointment_results"], ListTransform<rf_master_appointment_results>())
        specialPrice <- (map["special_prices"], ListTransform<rf_specialPrice_results>())
        promotionCodes <- (map["promotion_codes"], ListTransform<rf_promotionCodes_results>())
        transitionHeights <- (map["transition_heights"], ListTransform<rf_transitionHeights_results>())
        floorColourList <- (map["floor_colors_list"], ListTransform<rf_floorColour_results>())
        stairColourList <- (map["stair_colors_list"], ListTransform<rf_stairColour_results>())
        min_sale_price <- map["min_sale_price"]
        max_no_transitions <- map["max_no_transitions"]
        resitionDate <- map ["recision_date"]
    }
    
}


class Appointments : Object,Mappable {
    @objc dynamic var result : String?
    var appointments = List<rf_master_appointment>()
    @objc dynamic var message : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    convenience init(masterAppointment:List<rf_master_appointment>){
        self.init()
        self.appointments = masterAppointment
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        result <- map["result"]
        appointments <- (map["appointments"], ListTransform<rf_master_appointment>())
        message <- map["message"]
    }
}

class rf_master_roomname : Object, Mappable {
    @objc dynamic var room_id = 0
    @objc dynamic var room_name : String?
    @objc dynamic var product_category : String?
    @objc dynamic var last_updated_date : String?
    @objc dynamic var note : String?
    @objc dynamic var company_id  = 0
    @objc dynamic var image : String?
    @objc dynamic var room_category : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        room_id <- map["id"]
        room_name <- map["name"]
        product_category <- map["product_category"]
        last_updated_date <- map["last_updated_date"]
        note <- map["note"]
        company_id <- map["company_id"]
        image <- map["image"]
        room_category <- map["room_category"]
    }
    
}

class rf_master_payment_option : Object, Mappable {
    @objc dynamic var id = 0
    @objc dynamic var name : String?
    @objc dynamic var description__c : String?
    @objc dynamic var down_payment__c : String?
    @objc dynamic var final_payment__c : String?
    @objc dynamic var payment_factor__c : String?
    @objc dynamic var Secondary_Payment_Factor__c:String?
    @objc dynamic var balance_Due__c : String?
    @objc dynamic var payment_info__c : String?
    @objc dynamic var sequence : Int = 0
    @objc dynamic var last_updated_date : String?
    @objc dynamic var down_payment_message:String?
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        name <- map["Name"]
        description__c <- map["Description__c"]
        down_payment__c <- map["Down_Payment__c"]
        final_payment__c <- map["Final_Payment__c"]
        payment_factor__c <- map["Payment_Factor__c"]
        Secondary_Payment_Factor__c <- map["Secondary_Payment_Factor__c"]
        balance_Due__c <- map["Balance_Due__c"]
        payment_info__c <- map["Payment_Info__c"]
        sequence <- map["sequence"]
        last_updated_date <- map["last_updated_date"]
        down_payment_message <- map["down_payment_message"]
    }
}

class rf_AnswerForQuestion:Object{
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var question_id: Int = -1
    @objc dynamic var appointment_id = AppointmentData().appointment_id ?? 0
    var answer = List<String>()
    
    
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    override init(){
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    init(qstnAnsDict:[String:Any]){
        if qstnAnsDict.count > 0{
            self.question_id = qstnAnsDict["question_id"] as! Int
            if let answerArray = qstnAnsDict["answer"]{
                let answerStrArray = answerArray as! [String]
                for answer in answerStrArray{
                    self.answer.append(answer)
                }
            }
        }
    }
}

class rf_master_question :Object, Mappable {
    @objc dynamic var questionIdUnique = UUID().uuidString
    @objc dynamic var id = 0
    @objc dynamic var room_id = 0
    let ofAppointment = LinkingObjects(fromType: rf_completed_appointment.self, property: "questionnaires")
    @objc dynamic var appointment_id = AppointmentData().appointment_id ?? 0
    @objc dynamic var question_name : String?
    @objc dynamic var question_code : String?
    @objc dynamic var company_id = 0
    @objc dynamic var description1 : String? = ""
    @objc dynamic var question_type : String?
    @objc dynamic var validation_required : Bool = false
    @objc dynamic var validation_email_required : Bool = false
    @objc dynamic var validation_error_msg : String?
    @objc dynamic var mandatory_answer : Bool = false
    @objc dynamic var multiply_with_area : Bool = false
    @objc dynamic var error_message : String?
    @objc dynamic var refelct_in_cost : Bool = false
    @objc dynamic var calculation_type : String?
    @objc dynamic var amount = 0.0
    @objc dynamic var amount_included  = 0
    @objc dynamic var sequence = 0
    @objc dynamic var default_answer : String?
    @objc dynamic var exclude_from_discount : Bool = false
    @objc dynamic var exclude_from_promotion : Bool = false
    @objc dynamic  var setDefaultAnswer : Bool = false
    @objc dynamic var applicableCurrentSurface : String?
    var quote_label = List<rf_master_question_detail>()
    var rf_AnswerOFQustion = List<rf_AnswerForQuestion>()
    var applicableRooms = List<rf_AnswerapplicableRooms>()
    
    @objc dynamic var last_updated_date : String?
    @objc dynamic var applicableTo: String?
    
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
   
    
    
    override static func primaryKey() -> String? {
        return "questionIdUnique"
        //return "room_id"
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        question_name <- map["name"]
        question_code <- map["code"]
        company_id <- map["company_id"]
        description1 <- map["description"]
        question_type <- map["question_type"]
        validation_required <- map["validation_required"]
        validation_email_required <- map["validation_email_required"]
        validation_error_msg <- map["validation_error_msg"]
        mandatory_answer <- map["mandatory_answer"]
        multiply_with_area <- map["multiply_with_area"]
        error_message <- map["Error_message"]
        refelct_in_cost <- map["Refelct_in_cost"]
        calculation_type <- map["calculation_type"]
        amount <- map["amount"]
        amount_included <- map["amount_included"]
        sequence <- map["sequence"]
        default_answer <- map["default_answer"]
        exclude_from_discount <- map["exclude_from_discount"]
        exclude_from_promotion <- map["exclude_from_promotion"]
        quote_label <- (map["quote_label"], ListTransform<rf_master_question_detail>())
        last_updated_date <- map["last_updated_date"]
        applicableTo <- map["applicable_to"]
        setDefaultAnswer <- map["set_default_answer"]
        applicableCurrentSurface <- map["applicable_current_surface"]
        applicableRooms <- (map["applicable_rooms"], ListTransform<rf_AnswerapplicableRooms>())
        //not from api
        rf_AnswerOFQustion <- map["rf_AnswerOFQustion"]
        //
    }
    
}

//class rf_question :Object {
//    //@objc dynamic var questionIdUnique = UUID().uuidString
//    @objc dynamic var id = 0
//    @objc dynamic var appointment_id = AppointmentData().appointment_id ?? 0
//    @objc dynamic var question_name : String?
//    @objc dynamic var question_code : String?
//    @objc dynamic var company_id = 0
//    @objc dynamic var description1 : String? = ""
//    @objc dynamic var question_type : String?
//    @objc dynamic var validation_required : Bool = false
//    @objc dynamic var validation_email_required : Bool = false
//    @objc dynamic var validation_error_msg : String?
//    @objc dynamic var mandatory_answer : Bool = false
//    @objc dynamic var error_message : String?
//    @objc dynamic var refelct_in_cost : Bool = false
//    @objc dynamic var calculation_type : String?
//    @objc dynamic var amount = 0.0
//    @objc dynamic var amount_included  = 0
//    @objc dynamic var sequence = 0
//    @objc dynamic var default_answer : String?
//    @objc dynamic var exclude_from_discount : Bool = false
//    var quote_label = List<rf_master_question_detail>()
//    var rf_AnswerOFQustion = List<rf_AnswerForQuestion>()
//    @objc dynamic var last_updated_date : String?
//    @objc dynamic var applicableTo: String?
//
//
//    convenience init(masterQuestion:rf_master_question) {
//        self.init()
//        self.id = masterQuestion.id
//        self.appointment_id = masterQuestion.appointment_id
//        self.question_name = masterQuestion.question_name
//        self.question_code = masterQuestion.question_code
//        self.company_id = masterQuestion.company_id
//        self.description1 = masterQuestion.description1
//        self.validation_required = masterQuestion.validation_required
//        self.validation_email_required = masterQuestion.validation_email_required
//        self.validation_error_msg = masterQuestion.validation_error_msg
//        self.mandatory_answer = masterQuestion.mandatory_answer
//        self.error_message = masterQuestion.error_message
//        self.refelct_in_cost = masterQuestion.refelct_in_cost
//        self.calculation_type = masterQuestion.calculation_type
//        self.amount = masterQuestion.amount
//        self.amount_included = masterQuestion.amount_included
//        self.sequence = masterQuestion.sequence
//        self.default_answer = masterQuestion.default_answer
//        self.exclude_from_discount = masterQuestion.exclude_from_discount
//        self.quote_label = masterQuestion.quote_label
//        self.rf_AnswerOFQustion = masterQuestion.rf_AnswerOFQustion
//        self.last_updated_date = masterQuestion.last_updated_date
//        self.applicableTo = masterQuestion.applicableTo
//
//    }
//}

class rf_AnswerapplicableRooms :Object, Mappable
{
    @objc dynamic var room_id : Int = 0
    @objc dynamic var room_name : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        room_id <- map["room_id"]
        room_name <- map["room_name"]
    }
}

class rf_master_question_detail : Object,Mappable {
    @objc dynamic var question_id : Int = 0
    @objc dynamic var sequence : Int = 0
    @objc dynamic var value : String?
    @objc dynamic var is_correct : Bool = false
    @objc dynamic var answer_score : Double = 0.0
    @objc dynamic var last_updated_date : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
//    override static func primaryKey() -> String? {
//        return "value"
//    }
    
    func mapping(map: ObjectMapper.Map) {
        
        question_id <- map["question_id"]
        sequence <- map["sequence"]
        value <- map["value"]
        is_correct <- map["is_correct"]
        answer_score <- map["answer_score"]
        last_updated_date <- map["last_updated_date"]
    }
    
}


class rf_floorColour_results : Object,Mappable {
    @objc dynamic var material_id : Int = 0
    @objc dynamic var color_name : String?
    @objc dynamic var color : String?
    @objc dynamic var material_image_url : String?
    @objc dynamic var color_upcharge: Double = 0.0
    @objc dynamic var last_updated_date : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        material_id <- map["material_id"]
        color_name <- map["name"]
        color <- map["color"]
        material_image_url <- map["material_image_url"]
        color_upcharge <- map["color_up_charge_price"]
    }
    
}

class rf_stairColour_results : Object,Mappable {
    @objc dynamic var material_id : Int = 0
    @objc dynamic var color_name : String?
    @objc dynamic var color : String?
    @objc dynamic var material_image_url : String?
    @objc dynamic var color_upcharge: Double = 0.0
    @objc dynamic var last_updated_date : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        material_id <- map["material_id"]
        color_name <- map["name"]
        color <- map["color"]
        material_image_url <- map["material_image_url"]
        color_upcharge <- map["color_up_charge_price"]
    }
    
}

class rf_master_color_list : Object,Mappable {
    @objc dynamic var material_id : Int = 0
    @objc dynamic var color_name : String?
    @objc dynamic var material_image_url : String?
    @objc dynamic var color_upcharge: Double = 0.0
    @objc dynamic var last_updated_date : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        material_id <- map["material_id"]
        color_name <- map["color"]
        material_image_url <- map["material_image_url"]
        color_upcharge <- map["color_up_charge_price"]
        material_image_url <- map["material_image_url"]
        last_updated_date <- map["last_updated_date"]
    }
    
}

class rf_master_molding : Object,Mappable {
    @objc dynamic var molding_id : Int = 0
    @objc dynamic var name : String?
    @objc dynamic var last_updated_date : String?
    @objc dynamic var unit_price : Double = 0.0
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        molding_id <- map["molding_id"]
        name <- map["name"]
        last_updated_date <- map["last_updated_date"]
        unit_price <- map["unit_price"]
    }
    
}

class rf_master_discount : Object,Mappable {
    @objc dynamic var code : String?
    @objc dynamic var displayName : String?
    @objc dynamic var amount : String?
    @objc dynamic var type : String?
    @objc dynamic var last_updated_date : String?
    @objc dynamic var promoUrlImage : String?
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        code <- map["Code"]
        displayName <- map["DisplayName"]
        amount <- map["Amount"]
        type <- map["Type"]
        last_updated_date <- map["last_updated_date"]
        promoUrlImage <- map["promo_image_url"]
    }
}


class rf_master_product_package :Object, Mappable {
    @objc dynamic var id : Int = 0
    @objc dynamic var plan_title : String?
    @objc dynamic var plan_subtitle : String?
    @objc dynamic var description1 : String?
    @objc dynamic var material_cost : Double = 0.0
    @objc dynamic var warranty : String?
    @objc dynamic  var sequence : Int = 0
    @objc dynamic var company_id : Int = 0
    @objc dynamic var cost_per_sqft : Double = 0.0
    @objc dynamic var monthly_promo : Int = 0
    @objc dynamic var warranty_info : String?
    @objc dynamic var min_Sale_Price : Double = 0.0
    @objc dynamic var eligible_for_discounts : String?
    @objc dynamic var unit_of_measure : String?
    @objc dynamic var grade : String?
    @objc dynamic var stair_cost : Double = 0.0
    @objc dynamic var stair_Msrp :Double = 0.0
    @objc dynamic var last_updated_date : String?
    @objc dynamic var stairProductId: Int = 0
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        plan_title <- map["plan_title"]
        plan_subtitle <- map["plan_subtitle"]
        description1 <- map["description"]
        material_cost <- map["material_cost"]
        warranty <- map["warranty"]
        sequence <- map["sequence"]
        company_id <- map["company_id"]
        cost_per_sqft <- map["cost_per_sqft"]
        monthly_promo <- map["monthly_promo"]
        warranty_info <- map["warranty_info"]
        min_Sale_Price <- map["min_sale_price"]
        eligible_for_discounts <- map["eligible_for_discounts"]
        unit_of_measure <- map["unit_of_measure"]
        grade <- map["grade"]
        stair_cost <- map["stair_cost"]
        stair_Msrp <- map["stair_msrp"]
        last_updated_date <- map["last_updated_date"]
        stairProductId <- map["stair_product_id"]
    }
    
}

class rf_SummeryDetailsData:Object
{
    @objc dynamic var contract_measurement_id: Int = 0
    @objc dynamic var name :String?
    @objc dynamic var material_id: Int = 0
    @objc dynamic var material_image_url :String?
    @objc dynamic var material_comments:String?
    @objc dynamic var floor_id: Int = 0
    @objc dynamic var floor_name :String?
    @objc dynamic var superscript_symbol:String?
    @objc dynamic var prefix:String?
    @objc dynamic var room_id: Int = 0
    @objc dynamic var room_name :String?
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var room_area :Double = 0.0
    @objc dynamic var stair_count :Double = 0.0
    @objc dynamic var adjusted_area:Double = 0.0
    @objc dynamic var comments: String?
    @objc dynamic var striked :String?
    var attachments = List<String>() //:[AttachmentDataValue]?
    @objc dynamic var attachment_comments:String?
    @objc dynamic var drawing_attachment: String?
    var transition = List<rf_transitionData>() //[SummeryTransitionDetails]?
    var questionaire  = List<rf_SummeryQustionsDetails>() //:[SummeryQustionsDetails]?
    override static func primaryKey() -> String? {
        return "appointment_id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
}

class rf_SummeryQustionsDetails: Object
{
    @objc dynamic var contract_question_line_id: Int = 0
    @objc dynamic var question_id:Int = 0
    @objc dynamic var name :String?
    @objc dynamic var question:String?
    @objc dynamic var question_type:String?
    var answers  = List<rf_SummeryQustionAnswerData>()
    
    override static func primaryKey() -> String? {
        return "question_id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
}

class rf_SummeryQustionAnswerData: Object
{
    @objc dynamic var id: Int = 0
    @objc dynamic var answer :String?
    @objc dynamic var contract_question_line_id: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
}

class rf_master_appointments_results_demoedNotDemoed : Object
{
    @objc dynamic var appointmentId = AppointmentData().appointment_id ?? 0
    @objc dynamic var id = 0
    @objc dynamic var result : String?
    @objc dynamic var lastAvailableScreen : String?
    @objc dynamic var islastAvailableScreen:Bool = false
    
    

    override init(){
        
    }
    convenience init(appointmentId: Int,id:Int,result:String,lastAvailableScreen:String,islastAvailableScreen:Bool){
        self.init()
        self.appointmentId = appointmentId
        self.id = id
        self.result = result
        self.lastAvailableScreen = lastAvailableScreen
        self.islastAvailableScreen = islastAvailableScreen
    }
   
}
class rf_specialPrice_results : Object ,Mappable
{
    @objc dynamic var specialPriceId = 0
    @objc dynamic var officeLocationId = 0
    @objc dynamic var productTmplId = 0
    @objc dynamic var startDate : String?
    @objc dynamic var endDate : String?
    @objc dynamic var specialPriceName : String?
    @objc dynamic var listPrice = 0.0
    @objc dynamic var msrp = 0.0
    @objc dynamic var maxDiscount = 0.0
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        specialPriceId <- map["special_price_id"]
        officeLocationId <- map["office_location_id"]
        productTmplId <- map["product_tmpl_id"]
        startDate <- map["start_date"]
        endDate <- map["end_date"]
        specialPriceName <- map["name"]
        listPrice <- map["list_price"]
        msrp <- map["msrp"]
        maxDiscount <- map["max_discount"]
    }
}



class rf_promotionCodes_results : Object ,Mappable
{
    @objc dynamic var promotionCodeId = 0
    @objc dynamic var name :String?
    @objc dynamic var discount = 0.0
    @objc dynamic var startDate : String?
    @objc dynamic var endDate : String?
    @objc dynamic var calculationType :String?
   
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        promotionCodeId <- map["promotion_code_id"]
        name <- map["name"]
        discount <- map["discount"]
        startDate <- map["start_date"]
        endDate <- map["end_date"]
        calculationType <- map["calculation_type"]
    }
}
class rf_transitionHeights_results :Object , Mappable
{
    @objc dynamic var transitionHeightId = 0
    @objc dynamic var name :String?
    @objc dynamic var sequence = 0
   
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        transitionHeightId <- map["transition_height_id"]
        name <- map["name"]
        sequence <- map["sequence"]
    }
}

class rf_master_appointment_results : Object, Mappable {
    @objc dynamic var id = 0
    @objc dynamic var result : String?
    @objc dynamic var lastAvailableScreen : String?
    @objc dynamic var isLastAvailableScreenShowedOnce:Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        result <- map["result"]
        lastAvailableScreen <- map["last_available_screen"]
    }
}

class rf_master_appointment : Object, Mappable {
    @objc dynamic var id = 0
    @objc dynamic var name : String?
    @objc dynamic var customer_name : String?
    @objc dynamic var applicant_first_name : String?
    @objc dynamic var applicant_middle_name : String?
    @objc dynamic var applicant_last_name : String?
    @objc dynamic var co_applicant_first_name : String?
    @objc dynamic var co_applicant_middle_name : String?
    @objc dynamic var co_applicant_last_name : String?
    @objc dynamic var co_applicant_phone : String?
    @objc dynamic var co_applicant_email : String?
    @objc dynamic var co_applicant_address : String?
    @objc dynamic var co_applicant_city : String?
    @objc dynamic var co_applicant_state_id : String?
    @objc dynamic var co_applicant_state_code : String?
    @objc dynamic var co_applicant_state_name : String?
    @objc dynamic var co_applicant_zip : String?
    @objc dynamic var co_applicant_secondary_phone : String?
    @objc dynamic var is_room_measurement_exist = false
    @objc dynamic var customer_id = 0
    @objc dynamic var co_applicant : String?
    @objc dynamic var appointment_date : String?
    @objc dynamic var appointment_datetime : String?
    @objc dynamic var street : String?
    @objc dynamic var street2 : String?
    @objc dynamic var city : String?
    @objc dynamic var state_id = 0
    @objc dynamic var state_code : String?
    @objc dynamic var state : String?
    @objc dynamic var country_id = 0
    @objc dynamic var country : String?
    @objc dynamic var zip : String?
    @objc dynamic var country_code : String?
    @objc dynamic var phone : String?
    @objc dynamic var mobile : String?
    @objc dynamic var email : String?
    @objc dynamic var sales_person : String?
    @objc dynamic var salesperson_id = 0
    @objc dynamic var partner_latitude = 0.0
    @objc dynamic var partner_longitude = 0.0
    @objc dynamic var co_applicant_skipped  : Int = 0
    @objc dynamic var applicantData: rf_ApplicantData!
    @objc dynamic var coApplicantData: rf_CoApplicationData!
    @objc dynamic var otherIncomeData: rf_OtherIncomeData!
    @objc dynamic var applicantAndIncomeData: String?
    @objc dynamic var recisionDate:String?
    @objc dynamic var officeLocationId = 0
   
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    init(appointmentObj:[String:Any]){
        appointment_date = appointmentObj["appointment_date"] as? String ?? ""
        applicant_first_name = appointmentObj["applicant_first_name"] as? String ?? ""
        applicant_middle_name = appointmentObj["applicant_middle_name"] as? String ?? ""
        applicant_last_name = appointmentObj["applicant_last_name"] as? String ?? ""
        street = appointmentObj["state"] as? String ?? ""
        street2 = appointmentObj["state2"] as? String ?? ""
        city = appointmentObj["city"] as? String ?? ""
        state_code = appointmentObj["state_code"] as? String ?? ""
        zip = appointmentObj["zip"] as? String ?? ""
        phone = appointmentObj["phone"] as? String ?? ""
        country_code = appointmentObj["appointment_date"] as? String ?? ""
        country = appointmentObj["country_code"] as? String ?? ""
        email = appointmentObj["email"] as? String ?? ""
        //country_id = appointmentObj["appointment_date"] as? String ?? ""
        co_applicant_first_name = appointmentObj["co_applicant_first_name"] as? String ?? ""
        co_applicant_middle_name = appointmentObj["co_applicant_middle_name"] as? String ?? ""
        co_applicant_last_name = appointmentObj["co_applicant_last_name"] as? String ?? ""
        co_applicant_address = appointmentObj["co_applicant_address"] as? String ?? ""
        co_applicant_city = appointmentObj["co_applicant_city"] as? String ?? ""
        co_applicant_zip = appointmentObj["co_applicant_zip"] as? String ?? ""
        co_applicant_secondary_phone = appointmentObj["co_applicant_secondary_phone"] as? String ?? ""
        co_applicant_phone = appointmentObj["co_applicant_phone"] as? String ?? ""
        co_applicant_email = appointmentObj["co_applicant_email"] as? String ?? ""
        sales_person = appointmentObj["sales_person"] as? String ?? ""
        salesperson_id = appointmentObj["salesperson_id"] as? Int ?? 0
        partner_latitude = appointmentObj["partner_latitude"] as? Double ?? 0.0
        partner_longitude = appointmentObj["appointment_date"] as? Double ?? 0.0
        recisionDate = appointmentObj["recision_date"] as? String ?? ""
        officeLocationId = appointmentObj["office_location_id"] as? Int ?? 0
    }
    
     init(appointmentData:AppoinmentDataValue) {
        self.id = appointmentData.id ?? 0
        self.name = appointmentData.name
        self.customer_name = appointmentData.customer_name
        self.applicant_first_name = appointmentData.applicant_first_name
        self.applicant_middle_name = appointmentData.applicant_middle_name
        self.applicant_last_name = appointmentData.applicant_last_name
        self.co_applicant_first_name = appointmentData.co_applicant_first_name
        self.co_applicant_middle_name = appointmentData.co_applicant_middle_name
        self.co_applicant_last_name = appointmentData.co_applicant_last_name
        self.co_applicant_email = appointmentData.co_applicant_email
        self.co_applicant_phone = appointmentData.co_applicant_phone
        self.co_applicant_address = appointmentData.co_applicant_address
        self.co_applicant_city = appointmentData.co_applicant_city
        self.co_applicant_state_name = appointmentData.co_applicant_state
        self.co_applicant_zip = appointmentData.co_applicant_zip
        self.co_applicant_secondary_phone = appointmentData.co_applicant_secondary_phone
        self.co_applicant_skipped = appointmentData.co_applicant_skipped ?? 0
        self.customer_id  = appointmentData.customer_id ?? 0
        self.co_applicant = appointmentData.co_applicant
        self.appointment_date = appointmentData.appointment_date
        self.appointment_datetime  = appointmentData.appointment_datetime
        self.street = appointmentData.street
        self.street2 = appointmentData.street2
        self.city = appointmentData.city
        self.state = appointmentData.state
        self.state_id = appointmentData.state_id ?? 0
        self.country_id = appointmentData.country_id ?? 0
        self.state_code = appointmentData.state_code
        self.country = appointmentData.country
        self.salesperson_id = appointmentData.salesperson_id ?? 0
        self.country_code = appointmentData.country_code
        self.phone  = appointmentData.phone
        self.mobile = appointmentData.mobile
        self.email = appointmentData.email
        self.zip = appointmentData.zip
        self.sales_person  = appointmentData.sales_person
        self.partner_latitude  = appointmentData.partner_latitude ?? 0.0
        self.partner_longitude  = appointmentData.partner_longitude ?? 0.0
        self.is_room_measurement_exist = appointmentData.is_room_measurement_exist ?? false
        self.recisionDate = appointmentData.recisionDate
         self.officeLocationId = appointmentData.officeLocationId ?? 0
    }
    
    init(appointmentObj:rf_completed_appointment) {
        id = appointmentObj.appointment_id
        appointment_date = appointmentObj.appointment_date
        customer_id = appointmentObj.customer_id
        applicant_first_name = appointmentObj.applicant_first_name
        applicant_middle_name = appointmentObj.applicant_middle_name
        applicant_last_name = appointmentObj.applicant_last_name
        street = appointmentObj.applicant_street
        street2 = appointmentObj.applicant_street2
        city = appointmentObj.applicant_city
        state_code = appointmentObj.applicant_state_code
        zip = appointmentObj.applicant_zip
        phone = appointmentObj.applicant_phone
        country_code = appointmentObj.applicant_country_code
        country = appointmentObj.applicant_country
        email = appointmentObj.applicant_email
        country_id = appointmentObj.applicant_country_id
        co_applicant_first_name = appointmentObj.co_applicant_first_name
        co_applicant_middle_name = appointmentObj.co_applicant_middle_name
        co_applicant_last_name = appointmentObj.co_applicant_last_name
        co_applicant_address = appointmentObj.co_applicant_address
        co_applicant_city = appointmentObj.co_applicant_city
        co_applicant_zip = appointmentObj.co_applicant_zip
        co_applicant_secondary_phone = appointmentObj.co_applicant_secondary_phone
        co_applicant_phone = appointmentObj.co_applicant_phone
        co_applicant_email = appointmentObj.co_applicant_email
        sales_person = appointmentObj.sales_person
        salesperson_id = appointmentObj.salesperson_id
        partner_latitude = appointmentObj.partner_latitude
        partner_longitude = appointmentObj.partner_longitude
        recisionDate = appointmentObj.recisionDate
        officeLocationId = appointmentObj.officeLocationId
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        name <- map["name"]
        customer_name <- map["customer_name"]
        applicant_first_name <- map["applicant_first_name"]
        applicant_middle_name <- map["applicant_middle_name"]
        applicant_last_name <- map["applicant_last_name"]
        co_applicant_first_name <- map["co_applicant_first_name"]
        co_applicant_middle_name <- map["co_applicant_middle_name"]
        co_applicant_last_name <- map["co_applicant_last_name"]
        co_applicant_phone <- map["co_applicant_phone"]
        co_applicant_email <- map["co_applicant_email"]
        co_applicant_address <- map["co_applicant_address"]
        co_applicant_city <- map["co_applicant_city"]
        co_applicant_state_id <- map["co_applicant_state_id"]
        co_applicant_state_code <- map["co_applicant_state_code"]
        co_applicant_state_name <- map["co_applicant_state_name"]
        co_applicant_zip <- map["co_applicant_zip"]
        co_applicant_secondary_phone <- map["co_applicant_secondary_phone"]
        is_room_measurement_exist <- map["is_room_measurement_exist"]
        customer_id <- map["customer_id"]
        co_applicant <- map["co_applicant"]
        appointment_date <- map["appointment_date"]
        appointment_datetime <- map["appointment_datetime"]
        street <- map["street"]
        street2 <- map["street2"]
        city <- map["city"]
        state_id <- map["state_id"]
        state_code <- map["state_code"]
        state <- map["state"]
        country_id <- map["country_id"]
        country <- map["country"]
        zip <- map["zip"]
        country_code <- map["country_code"]
        phone <- map["phone"]
        mobile <- map["mobile"]
        email <- map["email"]
        sales_person <- map["sales_person"]
        salesperson_id <- map["salesperson_id"]
        partner_latitude <- map["partner_latitude"]
        partner_longitude <- map["partner_longitude"]
        recisionDate <- map["recision_date"]
        officeLocationId <- map["office_location_id"]
    }
    
}

class Appointment_results : Mappable {
     var id : Int = 0
     var result : String?
    
//    required convenience init?(map: ObjectMapper.Map) {
//        self.init()
//    }
    required init?(map: ObjectMapper.Map){
    }
    
     func mapping(map: ObjectMapper.Map) {
        
        id <- map["id"]
        result <- map["result"]
    }
}



class rf_completed_appointment:Object{
    @objc dynamic var appointment_id = 0
    // an appointment can have many rooms
    var rooms = List<rf_completed_room>()
    var questionnaires = List<rf_master_question>()
    var snanpshotImages =  List<String>()
    @objc dynamic var appointment_date : String?
    @objc dynamic var appointment_datetime : String?
    @objc dynamic var customer_id = 0
    @objc dynamic var applicant_first_name: String?
    @objc dynamic var applicant_middle_name: String?
    @objc dynamic var applicant_last_name: String?
    @objc dynamic var applicant_street: String?
    @objc dynamic var applicant_street2: String?
    @objc dynamic var applicant_city: String?
    @objc dynamic var applicant_state_code: String?
    @objc dynamic var applicant_zip: String?
    @objc dynamic var applicant_phone: String?
    @objc dynamic var applicant_country_code: String?
    @objc dynamic var applicant_country: String?
    @objc dynamic var applicant_email: String?
    @objc dynamic var sales_person: String?
    @objc dynamic var salesperson_id : Int = 0
    @objc dynamic var partner_latitude : Double = 0.0
    @objc dynamic var partner_longitude : Double = 0.0
    @objc dynamic var applicant_country_id = 0
    @objc dynamic var co_applicant_first_name: String?
    @objc dynamic var co_applicant_middle_name: String?
    @objc dynamic var co_applicant_last_name: String?
    @objc dynamic var co_applicant_address: String?
    @objc dynamic var co_applicant_city: String?
    @objc dynamic var co_applicant_state: String?
    @objc dynamic var co_applicant_zip: String?
    @objc dynamic var co_applicant_secondary_phone: String?
    @objc dynamic var co_applicant_phone: String?
    @objc dynamic var co_applicant_email: String?
    @objc dynamic var applicantData: rf_ApplicantData!
    @objc dynamic var coApplicantData: rf_CoApplicationData?
    @objc dynamic var otherIncomeData: rf_OtherIncomeData!
    @objc dynamic var applicantAndIncomeData: String?
    @objc dynamic var paymentDetails: String?
    @objc dynamic var applicantSignatureImage : String?
    @objc dynamic var applicantInitialsImage : String?
    @objc dynamic var coApplicantSignatureImage : String?
    @objc dynamic var coApplicantInitialsImage : String?
    @objc dynamic var paymentType: String?
    @objc dynamic var contractData : String?
    @objc dynamic var recisionDate : String?
    @objc dynamic var sync_status = false
    @objc dynamic var officeLocationId = 0
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    override static func primaryKey() -> String? {
        return "appointment_id"
    }
    
    init(appointmentObj:rf_master_appointment) {
        appointment_id = appointmentObj.id
        appointment_date = appointmentObj.appointment_date
        appointment_datetime = appointmentObj.appointment_datetime
        customer_id = appointmentObj.customer_id
        applicant_first_name = appointmentObj.applicant_first_name
        applicant_middle_name = appointmentObj.applicant_middle_name
        applicant_last_name = appointmentObj.applicant_last_name
        applicant_street = appointmentObj.street
        applicant_street2 = appointmentObj.street2
        applicant_city = appointmentObj.city
        applicant_state_code = appointmentObj.state_code
        applicant_zip = appointmentObj.zip
        applicant_phone = appointmentObj.phone
        applicant_country_code = appointmentObj.country_code
        applicant_country = appointmentObj.country
        applicant_email = appointmentObj.email
        applicant_country_id = appointmentObj.country_id
        co_applicant_first_name = appointmentObj.co_applicant_first_name
        co_applicant_middle_name = appointmentObj.co_applicant_middle_name
        co_applicant_last_name = appointmentObj.co_applicant_last_name
        co_applicant_address = appointmentObj.co_applicant_address
        co_applicant_city = appointmentObj.co_applicant_city
        co_applicant_state = appointmentObj.co_applicant_state_name
        co_applicant_zip = appointmentObj.co_applicant_zip
        co_applicant_secondary_phone = appointmentObj.co_applicant_secondary_phone
        co_applicant_phone = appointmentObj.co_applicant_phone
        co_applicant_email = appointmentObj.co_applicant_email
        sales_person = appointmentObj.sales_person
        salesperson_id = appointmentObj.salesperson_id
        partner_latitude = appointmentObj.partner_latitude
        partner_longitude = appointmentObj.partner_longitude
        recisionDate = appointmentObj.recisionDate
        officeLocationId = appointmentObj.officeLocationId
    }
}

class rf_completed_room: Object{
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var room_id: Int = 0
    var questionnaires = List<rf_master_question>()
    let ofAppointment = LinkingObjects(fromType: rf_completed_appointment.self, property: "rooms")
    @objc dynamic var measurement_exist: String? = "false"
    @objc dynamic var customer_id: Int = 0
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var room_name: String?
    @objc dynamic var room_type: String?
    @objc dynamic var drawing_id: Int = 0
    @objc dynamic var draw_image_name: String?
    @objc dynamic var room_summary_comment: String?
    @objc dynamic var selected_room_color: String?
    @objc dynamic var selected_room_Upcharge: Double = 0.0
    @objc dynamic var selected_room_UpchargePrice: Double = 0.0
    @objc dynamic var selected_room_molding: String?
    @objc dynamic var selected_room_MoldingPrice: Double = 0.0
    @objc dynamic var room_strike_status: Bool = false
    @objc dynamic var extraPrice: Double = 0.0
    @objc dynamic var extraPriceToExclude: Double = 0.0
    @objc dynamic var extraPromoPriceToExclude: Double = 0.0
    @objc dynamic var sync_status: Bool = false
    //arb
    @objc dynamic var room_area: String?
    @objc dynamic var stairCount: String?
    @objc dynamic var stairWidth: String?
    @objc dynamic var draw_area_adjusted: String?
    @objc dynamic var room_perimeter: Float = 0.0
    @objc dynamic var material_image_url: String?
    var room_attachments =  List<String>()
    @objc dynamic var floor_id: String?
    var transArray = List<rf_transitionData>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
}

class rf_AnswerOFQustion:Object
{
    @objc dynamic var answerID:Int = 0
    @objc dynamic var qustionLineID:Int = 0
    @objc dynamic var numberVaue:Int = 0
    @objc dynamic var textValue:String?
    var singleSelection:QuoteLabelData?
    var multySelection:[QuoteLabelData]? = []
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    init(answerOfQstn: AnswerOFQustion){
        self.answerID = answerOfQstn.answerID
        self.qustionLineID = answerOfQstn.qustionLineID
        self.numberVaue = answerOfQstn.numberVaue ?? 0
        self.textValue = answerOfQstn.textValue
        self.singleSelection = answerOfQstn.singleSelection
        self.multySelection = answerOfQstn.multySelection
    }
    
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
    
    
}

class rf_transitionData:Object
{
    @objc dynamic var name :String?
    @objc dynamic var color: String?
    @objc dynamic var transsquarefeet :Float = 0.0
    @objc dynamic var transHeight : String?
    @objc dynamic var transitionHeightId: Int = 0
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    init( name: String, color: String, transsquarefeet: Float, transHeight: String,transitionHeightId:Int)
    {
        self.name = name
        self.color = color
        self.transsquarefeet = transsquarefeet
        self.transHeight = transHeight
        self.transitionHeightId = transitionHeightId
        
    }
    
    init(transData:TransitionData){
        self.name = transData.name
        self.color = transData.color
        self.transsquarefeet = transData.transsquarefeet ?? 0.0
        self.transHeight = transData.transHeight
        self.transitionHeightId = transData.transitionHeightId 
    }
    
    
}



//class rf_opening_custom_object:Object
//{
//    @objc dynamic var name:String = ""
//    @objc dynamic var color:UIColor = UIColor()
//
//    required convenience init?(map: ObjectMapper.Map) {
//        self.init()
//    }
//    override init(){
//
//    }
//
//    init(name: String, color: UIColor) {
//        self.name = name
//        self.color = color
//    }
//
//    init(opening:OpeningCustomObject){
//        self.name = opening.name
//        self.color = opening.color
//    }
//
//}

class rf_ApplicantData:Object
{
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var ethnicity, race, sex, applicantEmail, maritalStatus: String?
    @objc dynamic var applicantFirstName: String?
    @objc dynamic var applicantMiddleName, applicantLastName, driversLicense, driversLicenseExpDate, driversLicenseIssueDate: String?
    @objc dynamic var dateOfBirth, socialSecurityNumber, addressOfApplicant, addressOfApplicantStreet: String?
    @objc dynamic var addressOfApplicantStreet2, addressOfApplicantCity, addressOfApplicantState, addressOfApplicantZip: String?
    @objc dynamic var previousAddressOfApplicant, previousAddressOfApplicantStreet, previousAddressOfApplicantStreet2, previousAddressOfApplicantCity: String?
    @objc dynamic var previousAddressOfApplicantState, previousAddressOfApplicantZip, cellPhone, homePhone: String?
    @objc dynamic var howLong, previousAddressHowLong, presentEmployer, yearsOnJob: String?
    @objc dynamic var occupation, presentEmployersAddress, presentEmployersAddressStreet, presentEmployersAddressStreet2: String?
    @objc dynamic var presentEmployersAddressCity, presentEmployersAddressState, presentEmployersAddressZip: String?
    @objc dynamic var earningsFromEmployment,type_of_credit_requested: String?
    @objc dynamic var supervisorOrDepartment, employersPhoneNumber, previousEmployersAddress, previousEmployersAddressStreet: String?
    @objc dynamic var previousEmployersAddressStreet2, previousEmployersAddressCity, previousEmployersAddressState, previousEmployersAddressZip: String?
    @objc dynamic var earningsPerMonth: String?
    @objc dynamic var yearsOnJobPreviousEmployer, occupationPreviousEmployer, previousEmployersPhoneNumber, otherRace: String?
    
    override static func primaryKey() -> String? {
        return "appointment_id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    init( applicantOneData: ApplicationData)
    {
        self.applicantFirstName = applicantOneData.applicantFirstName
        self.applicantEmail = applicantOneData.applicantEmail
        self.applicantMiddleName = applicantOneData.applicantMiddleName
        self.applicantLastName = applicantOneData.applicantLastName
        self.driversLicense = applicantOneData.driversLicense
        self.driversLicenseExpDate = applicantOneData.driversLicenseExpDate
        self.driversLicenseIssueDate = applicantOneData.driversLicenseIssueDate
        self.dateOfBirth = applicantOneData.dateOfBirth
        self.socialSecurityNumber = applicantOneData.socialSecurityNumber
        self.addressOfApplicant = applicantOneData.addressOfApplicant
        self.addressOfApplicantStreet = applicantOneData.addressOfApplicantStreet
        self.addressOfApplicantStreet2 = applicantOneData.addressOfApplicantStreet2
        self.addressOfApplicantCity = applicantOneData.addressOfApplicantCity
        self.addressOfApplicantState = applicantOneData.addressOfApplicantState
        self.addressOfApplicantZip = applicantOneData.addressOfApplicantZip
        self.previousAddressOfApplicant = applicantOneData.previousAddressOfApplicant
        self.previousAddressOfApplicantStreet = applicantOneData.previousAddressOfApplicantStreet
        self.previousAddressOfApplicantStreet2 = applicantOneData.previousAddressOfApplicantStreet2
        self.previousAddressOfApplicantCity = applicantOneData.previousAddressOfApplicantCity
        self.previousAddressOfApplicantState = applicantOneData.previousAddressOfApplicantState
        self.previousAddressOfApplicantZip = applicantOneData.previousAddressOfApplicantZip
        self.cellPhone = applicantOneData.cellPhone
        self.homePhone = applicantOneData.homePhone
        self.howLong = applicantOneData.howLong
        self.previousAddressHowLong = applicantOneData.previousAddressHowLong
        self.presentEmployer = applicantOneData.presentEmployer
        self.yearsOnJob = applicantOneData.yearsOnJob
        self.occupation = applicantOneData.occupation
        self.presentEmployersAddress = applicantOneData.presentEmployersAddress
        self.presentEmployersAddressStreet = applicantOneData.presentEmployersAddressStreet
        self.presentEmployersAddressStreet2 = applicantOneData.presentEmployersAddressStreet2
        self.presentEmployersAddressCity = applicantOneData.presentEmployersAddressCity
        self.presentEmployersAddressState = applicantOneData.presentEmployersAddressState
        self.presentEmployersAddressZip = applicantOneData.presentEmployersAddressZip
        self.earningsFromEmployment = applicantOneData.earningsFromEmployment
        self.supervisorOrDepartment = applicantOneData.supervisorOrDepartment
        self.employersPhoneNumber = applicantOneData.employersPhoneNumber
        self.previousEmployersAddress = applicantOneData.previousEmployersAddress
        self.previousEmployersAddressStreet = applicantOneData.previousEmployersAddressStreet
        self.previousEmployersAddressStreet2 = applicantOneData.previousEmployersAddressStreet2
        self.previousEmployersAddressCity = applicantOneData.previousEmployersAddressCity
        self.previousEmployersAddressState = applicantOneData.previousEmployersAddressState
        self.previousEmployersAddressZip = applicantOneData.previousEmployersAddressZip
        self.earningsPerMonth = applicantOneData.earningsPerMonth
        self.yearsOnJobPreviousEmployer = applicantOneData.yearsOnJobPreviousEmployer
        self.occupationPreviousEmployer = applicantOneData.occupationPreviousEmployer
        self.previousEmployersPhoneNumber = applicantOneData.previousEmployersPhoneNumber
        self.type_of_credit_requested = applicantOneData.type_of_credit_requested
        self.ethnicity = applicantOneData.ethnicity
        self.race = applicantOneData.race
        self.sex = applicantOneData.sex
        self.maritalStatus = applicantOneData.maritalStatus
        self.otherRace = applicantOneData.otherRace
        
    }
}

class rf_CoApplicationData:Object
{
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var ethnicity, race, sex, CoapplicantEmail, maritalStatus: String?
    @objc dynamic var applicantFirstName: String?
    @objc dynamic var applicantMiddleName, applicantLastName, driversLicense, driversLicenseExpDate, driversLicenseIssueDate: String?
    @objc dynamic var dateOfBirth, socialSecurityNumber, addressOfApplicant, addressOfApplicantStreet: String?
    @objc dynamic var addressOfApplicantStreet2, addressOfApplicantCity, addressOfApplicantState, addressOfApplicantZip: String?
    @objc dynamic var previousAddressOfApplicant, previousAddressOfApplicantStreet, previousAddressOfApplicantStreet2, previousAddressOfApplicantCity: String?
    @objc dynamic     var previousAddressOfApplicantState, previousAddressOfApplicantZip, cellPhone, homePhone: String?
    @objc dynamic var howLong, previousAddressHowLong, presentEmployer, yearsOnJob: String?
    @objc dynamic     var occupation, presentEmployersAddress, presentEmployersAddressStreet, presentEmployersAddressStreet2: String?
    @objc dynamic var presentEmployersAddressCity, presentEmployersAddressState, presentEmployersAddressZip: String?
    @objc dynamic var earningsFromEmployment: String?
    @objc dynamic var supervisorOrDepartment, employersPhoneNumber, previousEmployersAddress, previousEmployersAddressStreet: String?
    @objc dynamic var previousEmployersAddressStreet2, previousEmployersAddressCity, previousEmployersAddressState, previousEmployersAddressZip: String?
    @objc dynamic var earningsPerMonth: String?
    @objc dynamic var yearsOnJobPreviousEmployer, occupationPreviousEmployer, previousEmployersPhoneNumber, otherRace: String?
    
    override static func primaryKey() -> String? {
        return "appointment_id"
    }
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    init(coApplicantData: CoApplicationData)
    {
        self.applicantFirstName = coApplicantData.applicantFirstName
        self.CoapplicantEmail = coApplicantData.CoapplicantEmail
        self.applicantMiddleName = coApplicantData.applicantMiddleName
        self.applicantLastName = coApplicantData.applicantLastName
        self.driversLicense = coApplicantData.driversLicense
        self.driversLicenseIssueDate = coApplicantData.driversLicenseIssueDate
        self.driversLicenseExpDate = coApplicantData.driversLicenseExpDate
        self.dateOfBirth = coApplicantData.dateOfBirth
        self.socialSecurityNumber = coApplicantData.socialSecurityNumber
        self.addressOfApplicant = coApplicantData.addressOfApplicant
        self.addressOfApplicantStreet = coApplicantData.addressOfApplicantStreet
        self.addressOfApplicantStreet2 = coApplicantData.addressOfApplicantStreet2
        self.addressOfApplicantCity = coApplicantData.addressOfApplicantCity
        self.addressOfApplicantState = coApplicantData.addressOfApplicantState
        self.addressOfApplicantZip = coApplicantData.addressOfApplicantZip
        self.previousAddressOfApplicant = coApplicantData.previousAddressOfApplicant
        self.previousAddressOfApplicantStreet = coApplicantData.previousAddressOfApplicantStreet
        self.previousAddressOfApplicantStreet2 = coApplicantData.previousAddressOfApplicantStreet2
        self.previousAddressOfApplicantCity = coApplicantData.previousAddressOfApplicantCity
        self.previousAddressOfApplicantState = coApplicantData.previousAddressOfApplicantState
        self.previousAddressOfApplicantZip = coApplicantData.previousAddressOfApplicantZip
        self.cellPhone = coApplicantData.cellPhone
        self.homePhone = coApplicantData.homePhone
        self.howLong = coApplicantData.howLong
        self.previousAddressHowLong = coApplicantData.previousAddressHowLong
        self.presentEmployer = coApplicantData.presentEmployer
        self.yearsOnJob = coApplicantData.yearsOnJob
        self.occupation = coApplicantData.occupation
        self.presentEmployersAddress = coApplicantData.presentEmployersAddress
        self.presentEmployersAddressStreet = coApplicantData.presentEmployersAddressStreet
        self.presentEmployersAddressStreet2 = coApplicantData.presentEmployersAddressStreet2
        self.presentEmployersAddressCity = coApplicantData.presentEmployersAddressCity
        self.presentEmployersAddressState = coApplicantData.presentEmployersAddressState
        self.presentEmployersAddressZip = coApplicantData.presentEmployersAddressZip
        self.earningsFromEmployment = coApplicantData.earningsFromEmployment
        self.supervisorOrDepartment = coApplicantData.supervisorOrDepartment
        self.employersPhoneNumber = coApplicantData.employersPhoneNumber
        self.previousEmployersAddress = coApplicantData.previousEmployersAddress
        self.previousEmployersAddressStreet = coApplicantData.previousEmployersAddressStreet
        self.previousEmployersAddressStreet2 = coApplicantData.previousEmployersAddressStreet2
        self.previousEmployersAddressCity = coApplicantData.previousEmployersAddressCity
        self.previousEmployersAddressState = coApplicantData.previousEmployersAddressState
        self.previousEmployersAddressZip = coApplicantData.previousEmployersAddressZip
        self.earningsPerMonth = coApplicantData.earningsPerMonth
        self.yearsOnJobPreviousEmployer = coApplicantData.yearsOnJobPreviousEmployer
        self.occupationPreviousEmployer = coApplicantData.occupationPreviousEmployer
        self.previousEmployersPhoneNumber = coApplicantData.previousEmployersPhoneNumber
        self.ethnicity = coApplicantData.ethnicity
        self.race = coApplicantData.race
        self.sex = coApplicantData.sex
        self.maritalStatus = coApplicantData.maritalStatus
        self.otherRace = coApplicantData.otherRace
        
    }
}

class rf_OtherIncomeData:Object
{
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var sourceOfOtherIncome: String?
    @objc dynamic var amountMonthly: Int = 0
    @objc dynamic var nearestRelative, relationship, addressRelationship, addressRelationshipStreet: String?
    @objc dynamic var addressRelationshipStreet2, addressRelationshipCity, addressRelationshipState, addressRelationshipZip: String?
    @objc dynamic var phoneNumberRelationhip, propertyDetails, lenderName, lenderAddress: String?
    @objc dynamic var lenderAddressStreet, lenderAddressStreet2, lenderAddressCity, lenderAddressState: String?
    @objc dynamic var lenderAddressZip, lenderPhone: String?
    @objc dynamic var originalPurchasePrice: Double = 0.0
    @objc dynamic var originalMortageAmount: Double = 0.0
    @objc dynamic var monthlyMortagePayment: Double = 0.0
    @objc dynamic var dateAquired: String?
    @objc dynamic var presentBalance: Double = 0.0
    @objc dynamic var presentValueOfHome: Double = 0.0
    @objc dynamic var secondMortage, lenderNameOrPhone: String?
    @objc dynamic var originalAmount: Double = 0.0
    @objc dynamic var presentBalanceSecondMortage: Double = 0.0
    @objc dynamic var monthlyPayment: Double = 0.0
    @objc dynamic var otherObligations: String?
    @objc dynamic var totalMonthlyPayments: Double = 0.0
    @objc dynamic var checkingAccountNo, nameOfBank, bankPhoneNumber, insuranceCompany: String?
    @objc dynamic var agent, insurancePhoneNo, coverage: String?
    @objc dynamic var typeOfCreditRequested:String?
    @objc dynamic var additional_income:String?
    @objc dynamic var second_mortage:String?
    @objc dynamic var lender_name_or_phone :String?
    @objc dynamic var checking_account_no :String?
    @objc dynamic var checking_routing_no:String?
    @objc dynamic var name_of_bank :String?
    @objc dynamic var applicant_signature_date:String?
    @objc dynamic var co_applicant_signature_date:String?
    @objc dynamic var hunterMessageStatus:String?
    @objc dynamic var present_balance:Double = 0.0
    @objc dynamic var present_value_of_home :Double = 0.0
    @objc dynamic var original_amount:Double = 0.0
    @objc dynamic var present_balance_second_mortage:String?
    @objc dynamic var monthly_payment:Double = 0.0
    
    override static func primaryKey() -> String? {
        return "appointment_id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
    
    init(otherIncomeData: OtherIncomeData)
    {
        self.sourceOfOtherIncome = otherIncomeData.sourceOfOtherIncome
        self.amountMonthly = otherIncomeData.amountMonthly ?? 0
        self.nearestRelative = otherIncomeData.nearestRelative
        self.relationship = otherIncomeData.relationship
        self.addressRelationship = otherIncomeData.addressRelationship
        self.addressRelationshipStreet = otherIncomeData.addressRelationshipStreet
        self.addressRelationshipStreet2 = otherIncomeData.addressRelationshipStreet2
        self.addressRelationshipCity = otherIncomeData.addressRelationshipCity
        self.addressRelationshipState = otherIncomeData.addressRelationshipState
        self.addressRelationshipZip = otherIncomeData.addressRelationshipZip
        self.phoneNumberRelationhip = otherIncomeData.phoneNumberRelationhip
        self.propertyDetails = otherIncomeData.propertyDetails
        self.lenderName = otherIncomeData.lenderName
        self.lenderAddressStreet = otherIncomeData.lenderAddressStreet
        self.lenderAddressStreet2 = otherIncomeData.lenderAddressStreet2
        self.lenderAddressCity = otherIncomeData.lenderAddressCity
        self.lenderAddressState = otherIncomeData.lenderAddressState
        self.lenderAddressZip = otherIncomeData.lenderAddressZip
        self.lenderPhone = otherIncomeData.lenderPhone
        self.originalPurchasePrice = otherIncomeData.originalPurchasePrice ?? 0.0
        self.originalMortageAmount = otherIncomeData.originalMortageAmount ?? 0.0
        self.monthlyMortagePayment = otherIncomeData.monthlyMortagePayment ?? 0.0
        self.dateAquired = otherIncomeData.dateAquired
        self.presentBalance = otherIncomeData.presentBalance ?? 0.0
        self.presentValueOfHome = otherIncomeData.presentValueOfHome ?? 0.0
        self.secondMortage = otherIncomeData.secondMortage
        self.lenderNameOrPhone = otherIncomeData.lenderNameOrPhone
        self.originalAmount = otherIncomeData.originalAmount ?? 0.0
        self.presentBalanceSecondMortage = otherIncomeData.presentBalanceSecondMortage ?? 0.0
        self.monthlyPayment = otherIncomeData.monthlyPayment ?? 0.0
        self.otherObligations = otherIncomeData.otherObligations
        self.totalMonthlyPayments = otherIncomeData.totalMonthlyPayments ?? 0.0
        self.checkingAccountNo = otherIncomeData.checkingAccountNo
        self.nameOfBank = otherIncomeData.nameOfBank
        self.bankPhoneNumber = otherIncomeData.bankPhoneNumber
        self.insuranceCompany = otherIncomeData.insuranceCompany
        self.agent = otherIncomeData.agent
        self.insurancePhoneNo = otherIncomeData.insurancePhoneNo
        self.coverage = otherIncomeData.coverage
        self.additional_income = otherIncomeData.additional_income
        self.second_mortage = otherIncomeData.second_mortage
        self.lender_name_or_phone = otherIncomeData.lender_name_or_phone
        self.checking_account_no = otherIncomeData.checking_account_no
        self.checking_routing_no = otherIncomeData.checking_routing_no
        self.name_of_bank = otherIncomeData.name_of_bank
        self.applicant_signature_date = otherIncomeData.applicant_signature_date
        self.co_applicant_signature_date = otherIncomeData.co_applicant_signature_date
        self.hunterMessageStatus = otherIncomeData.hunterMessageStatus
        self.present_balance = otherIncomeData.present_balance
        self.present_value_of_home = otherIncomeData.present_value_of_home
        self.original_amount = otherIncomeData.original_amount
        self.present_balance_second_mortage = otherIncomeData.present_balance_second_mortage ?? ""
        self.monthly_payment = otherIncomeData.monthly_payment
    }
}

class rf_Completed_Appointment_Request:Object
{
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var reqest_title: String?
    @objc dynamic var request_url: String?
    @objc dynamic var request_parameter: String?
    @objc dynamic var request_type: String?
    @objc dynamic var sync_status: Bool = false
    @objc dynamic var image_name: String?
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
}

class rf_Appointment_Logs:Object
{
    @objc dynamic var appointment_id: Int = 0
    var sync_message =  List<rf_Appointment_Log_Data>()
    @objc dynamic var sync_error: String?
    @objc dynamic var appBaseUrl: String?
    @objc dynamic var paymentStatus:String?
    @objc dynamic var paymentMessage:String?
    
    override static func primaryKey() -> String? {
        return "appointment_id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    override init(){
        
    }
}
class rf_Appointment_Log_Data:Object{
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var sync_message : String?
    @objc dynamic var sync_time: String?
    @objc dynamic var customerName: String?
    @objc dynamic var appointmentDateTime: String?
    override init(){
        
    }
    convenience init(message:String,time:String,appointmentId:Int,customerName:String,appointmentDateTime:String){
        self.init()
        self.appointment_id = appointmentId
        self.sync_message = message
        self.sync_time = time
        self.customerName = customerName
        self.appointmentDateTime = appointmentDateTime
    }
}


class OfflineAttachment: Mappable
{
    var result: String?
    var message:String?
    var image_name:String?
    
    required init?(map: ObjectMapper.Map){
    }
    
    func mapping(map: ObjectMapper.Map) {
        result <- map["result"]
        message <- map["message"]
        image_name <- map["image_name"]
    }
}

class DiscountObject: Object {
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var promoType = -1
    @objc dynamic var type = "" //amount/percentage/promo
    @objc dynamic var value = "" //$, %, promoCode
    @objc dynamic var discountAmount = 0.0
    @objc dynamic var actualPrice = 0.0
    @objc dynamic var salePrice = 0.0
    @objc dynamic var excluded_amount_discount = 0.0
    override init(){
        
    }
    
    convenience init(appointment_id: Int,promoType:Int,type:String,value:String,discountAmount:Double,actualPrice:Double,salePrice:Double, excluded_amount_discount:Double){
        self.init()
        self.appointment_id = appointment_id
        self.promoType = promoType
        self.type = type
        self.value = value
        self.discountAmount = discountAmount
        self.actualPrice = actualPrice
        self.salePrice = salePrice
        self.excluded_amount_discount = excluded_amount_discount
    }
    
    func toDictionary() -> [String:Any]{
        return ["promo_type" : promoType, "type" : type, "value" : value , "discount_amount" : discountAmount, "actual_price" : actualPrice, "sale_price" : salePrice, "excluded_amount_discount": excluded_amount_discount]
    }
}


class ScreenCompletion: Object{
    @objc dynamic var appointment_id: Int = 0
    @objc dynamic var className : String?
    @objc dynamic var displayName : String?
    @objc dynamic var completionTime : String?
    
    override init(){
    }
    
    convenience init(appointment_id: Int,className : String,displayName : String,completionTime : String){
        self.init()
        self.appointment_id = appointment_id
        self.className = className
        self.displayName = displayName
        self.completionTime = completionTime
    }
    
}



