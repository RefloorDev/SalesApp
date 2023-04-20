//
//  MHPAppConstats.swift
//  MyHansonsProject
//
//  Created by Apps17 on 6/8/17.
//  Copyright © 2017 ARM. All rights reserved.
//com.oneteamus.liveflier
//com.oneteamus.LightApp

import UIKit

var BASE_URL = ""

struct AppURL {
    
    //App Details
   
    //offline Deve//2445
    // var BASE_URL = "http://server.oneteamus.com:2445/api/"

    //Offline live//2446
     //let BASE_URL = "http://server.oneteamus.com:2445/api/"
    
    //Offline live//7007  - new server
     //let LIVE_BASE_URL = "http://server.oneteamus.com:2446/api/"
     //let LIVE_BASE_URL = "http://35.199.10.7:7007/api/"
    let LIVE_BASE_URL = "http://odoo.myx.ac:7007/api/"
//http://server.oneteamus.com:2446
    //LIVE
    // let BASE_URL = "http://35.245.254.221:7007/api/"
   
    //Training
    // let BASE_URL = "http://35.245.254.221:6006/api/"
    
    //Training New Server
     //let TRAINING_BASE_URL = "http://35.199.10.7:6006/api/"
    let TRAINING_BASE_URL = "http://odootraining.myx.ac:6006/api/"
    //authenticate login api
     var authenticate = BASE_URL + "authenticate"
    
    //sync bhoomi api and update changes on middleware
     let Sync_master_data = BASE_URL + "sync_master_data"
    
    //api for getting sales schedule
     let SalesScheduleList = BASE_URL + "get_appointments"
    
    //api for update customer details
     let update_appointments = BASE_URL + "update_appointments"
    
    //api for attching images
     let CreateAttachment = BASE_URL + "CreateAttachment"
    
    //api for adding transitions
     let add_transitions = BASE_URL + "add_transitions"
    
    //api for filtering transition
     let filter_transitions = BASE_URL + "filter_transitions"
    
    //api for deleting image
     let UnlinkAttachment = BASE_URL + "UnlinkAttachment"
    
    //api for deleting added transitions
     let remove_transition = BASE_URL + "remove_transition"
    
    //api for getting questinaries
     let get_measurement_questions = BASE_URL + "get_measurement_questions"
    //api for updating selected questions
     let add_contract_measurement_questions = BASE_URL + "add_contract_measurement_questions"
    
    //api for adding room image with calculated area
     let add_contract_room_measurement = BASE_URL + "add_contract_room_measurement"
    
    //api for adding stair details
     let add_contract_stair_room_measurement = BASE_URL + "add_contract_stair_room_measurement"
    
    
    //api for getting tile color list
     let material_list = BASE_URL + "material_list"
    
    //api for updating tile color
     let update_material = BASE_URL + "update_material"
    
    //api fir getting all added room list with details
     let summary_contract_room_measurement_line = BASE_URL + "summary_contract_room_measurement_line"
    
    //api fir getting rom details
     let list_contract_room_measurement_line = BASE_URL + "list_contract_room_measurement_line"
    
    //api for delete added room
     let delete_room_details = BASE_URL + "edit_contract_room_measurement_line"
    
    //api for checking whether it added room or not
     let check_room_availability = BASE_URL + "check_appointment_room_status"
    
    //api for updating added questionaries
     let update_contract_measurement_questions = BASE_URL + "update_contract_measurement_questions"
    
    //api for updating adjusted area and comments from room summary details
     let update_contract_room_measurement = BASE_URL + "update_contract_room_measurement"
    
    //api for getting payment plan details
     let payment_paln_details = BASE_URL + "PaymentPlanList"
    
    //api not using
     let select_material_from_plan = BASE_URL + "select_material_from_plan"
    
    //api for creating sales quotation
     let create_sale_quotation = BASE_URL + "create_sale_quotation"
    
    //api for checking document status whether signed and validate or not
     let check_document_status = BASE_URL + "check_document_status"
    
    //api not using
     let propose_reject_quote = BASE_URL + "propose_reject_quote"
    
    //api for getting the all room list with selected status
     let RoomsScheduleList = BASE_URL + "RoomsScheduleList"
    
    //api not using
     let add_custom_rooms = BASE_URL + "add_custom_rooms"
    
    //api for adding room images minimum tw and maximum 8
     let update_summary_contract_room_measurement_line = BASE_URL + "update_summary_contract_room_measurement_line"
    
    //api for uploading applicant and co applicant signature
    
     let add_applicant_signature = BASE_URL + "add_applicant_signature"
    
    //api for creating payment token using credit/debit card
     let capture_payment = BASE_URL + "capture_payment"
    
     let capture_payment_without_upload = BASE_URL + "capture_payment_without_upload"
    
     let do_file_upload = BASE_URL + "do_file_upload"
    
    // Api for checking whether contract signed or not
     let get_contract_document_status = BASE_URL + "get_contract_document_status"
    
    
    
    //api for cash payment
     let create_payment_transaction_cash = BASE_URL + "create_payment_transaction_cash"
    
    //api for credit/debit card payment
     let create_payment_transaction_card = BASE_URL + "create_payment_transaction_card"
    
    //api for check payment
     let create_payment_transaction_check = BASE_URL + "create_payment_transaction_check"
    
    //api for uploading credit application details for applicant and co-applicant
     let create_credit_application = BASE_URL + "create_credit_application"
    
    //api for creating credit application pdf
     let generate_credit_application = BASE_URL + "generate_credit_application"
    
    //api for updating molding details
     let update_moulding = BASE_URL + "update_moulding"
    
    //api for updating floor color selection
     let update_material_room = BASE_URL + "update_material_room"
    
    //api for submitting appointment results whether domoed or sold etc
     let submit_appointment_result = BASE_URL + "submit_appointment_result"
    
     let submit_appointment_result_without_upload = BASE_URL + "submit_appointment_result_without_upload"
    
     let submit_appointment_file_upload = BASE_URL + "submit_appointment_file_upload"
    
    //api for attching images
     let uploadScreeshot = BASE_URL + "add_screenshots"
    
    //api for getting appointment resuls list
     let get_appointment_result = BASE_URL + "get_appointment_result"
    
     let check_app_build_status = "https://www.oneteam.us/testflight/refloor/phpinfo.php"
    
    //arb
     let get_master_data = BASE_URL + "get_master_data"
    
     //let syncCustomerAndRoomInfo = BASE_URL + "update_customer_and_room_information"
     //let syncCustomerAndRoomInfo = BASE_URL + "create_order_and_update_measurements_encoded_v2"//"create_order_and_update_measurements_encoded"
     //let syncContactInfo = BASE_URL + "update_contract_information"
    let syncCustomerAndRoomInfo = BASE_URL + "create_order_and_update_measurements"//"create_order_and_update_measurements_encoded"
     let syncImageInfo = BASE_URL + "upload_images"
     let syncGenerateContractDocumentInServer = BASE_URL + "generate_contract_document"
     let syncInitiate_i360 = BASE_URL + "initiate_sync_to_i360_json"
     let uploadAppointmentLogs = BASE_URL + "update_sync_log"
     let logoutApi = BASE_URL + "logout_from_device"
     let fetchDataBaseRawValue = BASE_URL + "fetch_database_raw_data"
     let autoLogout = BASE_URL + "check_auto_logout"
}


struct AppAlertMsg {
    
    
    static let NetWorkAlertMessage = "No internet connection currently available. Please move to an area with a better internet connection and click Retry to proceed."
    //static let serverNotReached = "We are having issue with communicating our server (API timed out). Please tap on Retry button to try again. If issue continues, please reach out to the support."
    // Updated Message
    static let serverNotReached = "We are having issues communicating with our server. Please tap the Retry button to try again. If the issue continues, please reach out to support"
    static let maxDiscountAmountMessage = "The maximum discount amount has been applied"
    //App Alert Msg
    //    static let NetWorkAlertMessage = "No internet connection. Please move to an area with a better internet connection and click Retry to proceed."
    //     static let serverNotReached = "The server could not be reached because of a connection problem. Please click Retry to proceed."
    //static let serverNotReached = "Please check your internet connection"
    //static let serverNotReached = "No internet connection. Please move to an area with a better internet connection and click Retry to proceed."
    
    static let NoNotification = "No notification"
    
    //Register Alert
    static let FULL_NAME_EMPTY = "First Name cannot be empty"
    static let USERNAME_EMPTY = "Username cannot be empty"
    static let INVALID_BOTH = "Invalid Username or Password."
    static let INVALID_TOKEN = "Invalid token"
    static let APPOINMENT_EMPTY = "Appointment ID cannot be empty"
    static let PROVIDE_EMAIL = "Email Address cannot be empty"
    static let ADDRESS_EMPTY = "Address cannot be empty"
    static let CONFIRM_PASSWORD_EMPTY = "Confirm password cannot be empty"
    static let LOGIN_ID_EMPTY = "Login ID cannot be empty"
    static let PASSWORD_EMPTY = "Password cannot be empty"
    static let INVALID_APPOINMENTID = "Invalid Appointment ID"
    static let PH_EMAIL_EMPTY = "Phone Number/Email Address cannot be empty"
    static let INVALID_PHONE = "Invalid Phone Number"
    static let INVALID_EMAIL = "Invalid Email Address"
    static let SELECT_ORDERID = "Select Order"
    static let REVIEWALREADY_COMPLETED = "You have already submitted the review."
    static let FIRST_NAME_ATLEAST = "First name must be at least 3 characters long"
    static let USERNAME_ATLEAST = "Username must be at least 3 characters long"
    static let FIRSTNAME_ATLEAST = "First name must be at least 3 characters long"
    static let PASSWORD_NOT_MATCH = "Passwords do not match"
    static let PASSWORD_ATLEAST = "Passwords must be at least 6 characters long"
    static let LAST_NAME = "Last Name cannot be empty"
    static let FULL_NAME_NUMERIC = "First Name cannot contain numeric characters"
    static let LAST_NAME_NUMERIC = "Last Name cannot contain numeric characters"
    static let USERNAME_NUMERIC = "Username cannot contain numeric characters"
    static let LOGOUT_MSG       = "Are you sure you want to logout?"
    static let NO_SURVAY       = "No Survey Available"
    static let SELECT_ANSWER   = "Please select your answer"
    static let PLEASE_ENTER_TITLE   = "Please enter a title."
    static let PLEASE_ENTER_DES   = "Please enter description."
    static let APPOINTMENT_SYNC_MESSAGE   = "We are getting new appointments. Please wait."
    static let ORDER_SAVE_SYNC_MESSAGE   = "The appointment results has been saved."
    static let APPOINTMENT_SYNC_TO_I360_MESSAGE   = "Please wait till the sync process completes."
}

struct Validation {
    static let specialCharString = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]|\"<>,.~`/:;?-=\\¥'£•¢")
}

enum RequestTitle: String{
    case CustomerAndRoom = "Sales_Update"
   // case ContactDetails = "Sales_Payment"
    case ImageUpload = "Sales_Images"
    case GenerateContract = "Sales_Contract_Generate"
    case InitiateSync = "Sales_Sync_Update"
}

enum RequestType: String{
    case post = "POST"
    case formData = "FORM_DATA"
}

enum AppointmentStatus{
    case start
    case sync
    case complete
}

enum AppointmentLogMessages: String{
    
    case appointmentLogStarted = "Appointment created..."
    case appointmentStarted = "Appointment started..."
    
    case customerDetailsSyncStarted = "Customer details sync started..."
    case customerDetailsSyncCompleted = "Customer details sync completed..."
    case customerDetailsSyncFailed = "Customer details sync failed..."
    
    case roomDetailsSyncStarted = "Room details sync started..."
    case roomDetailsSyncCompleted = "Room details sync completed..."
    case roomDetailsSyncFailed = "Room details sync failed..."
    
    case packageDetailsSyncStarted = "Package details sync started..."
    case packageDetailsSyncCompleted = "Package details sync completed..."
    case packageDetailsSyncFailed = "Package details sync failed..."
    
    case paymentDetailsSyncStarted = "Payment details sync started..."
    case paymentDetailsSyncCompleted = "Payment details sync completed..."
    case paymentDetailsSyncFailed = "Payment details sync failed..."
    
    case creditFormDetailsSyncStarted = "Credit form details sync started..."
    case creditFormDetailsSyncCompleted = "Credit form details sync completed..."
    case creditFormDetailsSyncFailed = "Credit form details sync failed..."
    
    case contractDetailsSyncStarted = "Contract details sync started..."
    case contractDetailsSyncCompleted = "Contract details sync completed..."
    case contractDetailsSyncFailed = "Contract details sync failed..."
    
    case roomMeasurementSyncStarted = "Room measurement images sync started..."
    case roomMeasurementSyncCompleted = "Room measurement images sync completed..."
    case roomMeasurementSyncFailed = "Room measurement images sync failed..."
    
    case roomPhotosSyncStarted = "Room photos sync started..."
    case roomPhotosSyncCompleted = "Room photos sync completed..."
    case roomPhotosSyncIncomplete = "Room photos sync incomplete..."
    
    case signatureSyncStarted = "Signature details sync started..."
    case signatureSyncCompleted = "Signature details sync completed..."
    case signatureSyncFailed = "Signature details sync failed..."
    
    case initialsSyncStarted = "Initials  sync started..."
    case initialsSyncCompleted = "Initials  sync completed..."
    case initialsSyncFailed = "Initials  sync failed..."
    
    case snapshotDetailsSyncStarted = "Snapshot details sync started..."
    case snapshotDetailsSyncCompleted = "Snapshot details sync completed..."
    case snapshotDetailsSyncFailed = "Snapshot details sync failed..."
    
    case generateContractSyncStarted = "Creating contract started..."
    case generateContractSyncCompleted = "Creating contract completed..."
    case generateContractSyncFailed = "Creating contract failed..."
    
    case appointmentSyncCompleted = "Appointment sync completed..."
    
}
