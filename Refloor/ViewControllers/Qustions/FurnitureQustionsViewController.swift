//
//  FurnitureQustionsViewController.swift
//  Refloor
//
//  Created by sbek on 04/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

class FurnitureQustionsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DropDownDelegate,MultySelectionDelegate,UITextViewDelegate {
    
    
    
    static func initialization() -> FurnitureQustionsViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "FurnitureQustionsViewController") as? FurnitureQustionsViewController
    }
    var currentSurfaceAnswerScore = 0.0
    var stair_Count = ""
    var roomName = ""
    var roomID = 0
    var floorID = 0
    var appoinmentID = 0
    var isStair = 0
    var drowingImageID = 0
    var area:CGFloat = 0
    var placeHolder = "Type Here"
    var summaryQustions:[SummeryQustionsDetails] = []
    var delegate:SummeryEditDelegate?
    var isUpdated = true
    var imagePicker: CaptureImage!
    var isMiscellaneousTxtView = false
    var perimeter = 0.0
    var miscelleneous_Comments = "Enter your comments about Miscellaneous Charge"
    @IBOutlet weak var perimeterHeightConsrtraint: NSLayoutConstraint!
    @IBOutlet weak var areaheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var perimeterLbl: UILabel!
    var qustionAnswer:[QuestionsMeasurementData] = []
    var removeCurrentCoveringAnswer: String? = nil
    var currentCoveringTypeAnswer: String? = nil
    var existingSubSurfaceAnswer: String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        if miscelleneous_Comments == ""
        {
            miscelleneous_Comments = "Enter your comments about Miscellaneous Charge"
        }
        if area != 0.0
        {
            areaLbl.text = "Area: \(area) Sq.Ft"
            let perimeterString = String(format: "%.2f", perimeter)
            perimeterLbl.text = "Perimeter: \(perimeterString) ft"
            areaheightConstraint.constant = 36
            perimeterHeightConsrtraint.constant = 36
            //String(format: "%.2f", speed)
        }
        else
        {
            areaLbl.isHidden = true
            perimeterLbl.isHidden = true
            areaheightConstraint.constant = 30
            perimeterHeightConsrtraint.constant = 30
        }
        print("-----viewDidLoad-----")
        if !isUpdated{
            self.addQuestions()
        }
        let appointmentId = AppointmentData().appointment_id ?? 0
        if self.getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID).isEmpty{
            self.addQuestions()
        }
        if(delegate == nil)
        {
            self.setNavigationBarbaclogoAndStatus(with: "ROOM DETAILS - \(roomName)")
        }
        else
        {
            self.setNavigationBarbackAndlogo(with: "ROOM DETAILS - \(roomName)")
        }
        
        //arb
//        questionsListApiCall()
        var questionsList = RealmSwift.List<rf_master_question>()
        questionsList = self.getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID)
        var qustionAnswer: [QuestionsMeasurementData] = []
        questionsList.forEach{ question in
            print("questionsList : ", questionsList)
            //if !roomName.localizedCaseInsensitiveContains("stair") && area != 0
            if area != 0
            {
                if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "rooms"){
                qustionAnswer.append(QuestionsMeasurementData(masterQuestions: question))
                }
            }else{
                if (question.applicableTo ?? "" == "common" || question.applicableTo ?? "" == "stairs"){
                    qustionAnswer.append(QuestionsMeasurementData(masterQuestions: question))
                }
            }
        }
        
        
        self.qustionAnswer = qustionAnswer
        
        if(self.delegate == nil && self.isUpdated)
        {
            self.foreditingFunctions()
           // self.tableView.reloadData()
        }
        else
        {
            self.foreditingFunctions()
        }
        //
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if(delegate == nil) {
            print("setDefaultAnswerForToiletQuestion1")
            setDefaultAnswerForToiletQuestion()
        } else {
            print("setDefaultAnswerForToiletQuestion2")
        }
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    
    func setDefaultAnswerForToiletQuestion() {
        print("roomName : ", roomName)
        if roomName.lowercased().contains("bathroom") {
            print("inside setDefaultAnswerForToiletQuestion")
            if let toiletQuestionIndex = qustionAnswer.firstIndex(where: { $0.code == "Toilet" }) {
                
                // Fetch the "Yes" answer from quote_label if it exists
                if let yesAnswer = qustionAnswer[toiletQuestionIndex].quote_label?.first(where: { $0.value == "Yes" }) {
                    
                    // Set the default answer to "Yes" for the "Toilet" question
                    qustionAnswer[toiletQuestionIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                    print("Default answer set to 'Yes' for question 'Toilet'")
                } else {
                    print("No 'Yes' option found in quote_label for 'Toilet' question.")
                }
            }
        }
    }
    
    func addQuestions(){
        do{
            let realm = try Realm()
            try realm.write{
                let masterData = realm.objects(MasterData.self)
                if let questionsFromMaster = masterData.first?.questionnaires{
                    let appointmentId = AppointmentData().appointment_id ?? 0
                    let alreadyAddedQuestions = realm.objects(rf_master_question.self).filter("appointment_id == %d AND room_id == %d",appointmentId , roomID)
                    realm.delete(alreadyAddedQuestions)
                    var dict:[String:Any] = [:]
                    questionsFromMaster.forEach { question in
                        //dict["questionIdUnique"] = question.questionIdUnique
                        dict["id"] = question.id
                        dict["room_id"] = roomID
                        dict["appointment_id"] = AppointmentData().appointment_id ?? 0
                        dict["question_name"] = question.question_name
                        dict["question_code"] = question.question_code
                        dict["company_id"] = question.company_id
                        dict["max_allowed_limit"] = question.max_allowed_limit
                        dict["description1"] = question.description1
                        dict["question_type"] = question.question_type
                        dict["validation_required"] = question.validation_required
                        dict["validation_email_required"] = question.validation_email_required
                        dict["validation_error_msg"] = question.validation_error_msg
                        dict["mandatory_answer"] = question.mandatory_answer
                        dict["multiply_with_area"] = question.multiply_with_area
                        dict["error_message"] = question.error_message
                        dict["refelct_in_cost"] = question.refelct_in_cost
                        dict["calculation_type"] = question.calculation_type
                        dict["refelct_in_cost"] = question.refelct_in_cost
                        dict["amount"] = question.amount
                        dict["amount_included"] = question.amount_included
                        dict["sequence"] = question.sequence
                        dict["default_answer"] = question.default_answer
                        dict["exclude_from_discount"] = question.exclude_from_discount
                        dict["exclude_from_promotion"] = question.exclude_from_promotion
                        dict["quote_label"] = question.quote_label
                        dict["last_updated_date"] = question.last_updated_date
                        dict["applicableTo"] = question.applicableTo
                        dict["applicableCurrentSurface"] = question.applicableCurrentSurface
                        dict["setDefaultAnswer"] = question.setDefaultAnswer
                        dict["calculate_order_wise"] = question.calculate_order_wise
                        dict["applicableRooms"] = List<rf_AnswerapplicableRooms>()
                        dict["rf_AnswerOFQustion"] = List<rf_AnswerOFQustion>()
                        realm.create(rf_master_question.self, value: dict, update: .all)
                    }
                }
            }
        }catch{
            print(RealmError.initialisationFailed)
        }
    }

    @IBAction func skipButtonAction(_ sender: Any) {
        
        if(self.delegate == nil)
        {
           // self.summeryDetailsDataApiCall()
            let summery = SummeryDetailsViewController.initialization()!
            if(self.isStair == 1)
            {
                summery.isStair = self.isStair
            }
            summery.summaryData = self.createSummaryData(roomID: roomID, roomName: roomName) //arb
            self.navigationController?.pushViewController(summery, animated: true)
        }
        else
        {
            self.performSegueToReturnBack()
            self.delegate?.SummeryEditDelegateInQustionariesEditingDone(summaryData: self.createSummaryData(roomID: roomID, roomName: roomName))
        }
        
    }
    
    
    
    @IBAction func numericalTFDidEndAction(_ sender: UITextField) {
        
        
        if let cell = tableView.cellForRow(at: [0, (sender.tag + 1)]) as? QustionsTableViewCell
        {
            if let value2 =  Int(sender.text ?? "")
            {
                if !(sender.text ?? "").contains(".")
                {
                    if qustionAnswer[sender.tag].max_allowed_limit != 0
                    {
                        if qustionAnswer[sender.tag].code == "StairWidth"
                        {
                            if value2 < 3 { // Automatically set to 3 if value is less than
                                
                                self.alert("Stair width value must be at least 3.", nil)
                                sender.text = String(qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble)
                                return
                            }
                            
                            if value2 > qustionAnswer[sender.tag].max_allowed_limit!
                            {
                                print("reached max value")
                                self.alert("Stair width value exceeded maximum limit", nil)
                                sender.text = String(qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble)
                                return
                            }
                            qustionAnswer[sender.tag].answerOFQustion?.stairWidthDouble = Double(value2)
                            cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion?.stairWidthDouble ?? 0.0)"
                            self.tableView.reloadData()
                        }
                        else if qustionAnswer[sender.tag].code == "RipMultipleLayers"
                        {
                            if value2 > qustionAnswer[sender.tag].max_allowed_limit!
                            {
                                print("reached max value")
                                self.alert("Rip multiple layer value exceeded maximum limit", nil)
                                sender.text = String(qustionAnswer[sender.tag].answerOFQustion!.numberVaue!)
                                return
                            }
                        }
                    }
                    else if qustionAnswer[sender.tag].code == "miscellaneouscharge"
                    {
                        if value2 > 0
                        {
                            qustionAnswer[sender.tag].answerOFQustion!.numberVaue =  value2
                            cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 0)"
                            self.tableView.reloadData()
                        }
                    }
                    qustionAnswer[sender.tag].answerOFQustion!.numberVaue =  value2
                    if area != 0.0
                    {
                    let buildUpLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftBuildUpLeveling"})
                    let trueSelfLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftTrueSelfLeveling"})
                    let removeSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "RemoveCurrentCovering" })!
                    let removeSurfaceAnswer = qustionAnswer[removeSurfaceIndex].answerOFQustion?.singleSelection?.value
                    let currentSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "CurrentCoveringType" })!
                    let subSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "ExistingSubSurface" })!
                    if sender.tag == buildUpLevelingIndex || sender.tag == trueSelfLevelingIndex
                    {
                        
                        if qustionAnswer[buildUpLevelingIndex!].answerOFQustion?.numberVaue ?? 0 > 0 || qustionAnswer[trueSelfLevelingIndex!].answerOFQustion?.numberVaue ?? 0 > 0
                        {
                            if removeSurfaceAnswer != nil
                            {
                                if removeSurfaceAnswer == "Yes"
                                {
                                    if let subSurfaceAnswer = qustionAnswer[subSurfaceIndex].answerOFQustion?.singleSelection?.value
                                    {
                                        if subSurfaceAnswer == "Concrete / Cement / Gypsum"
                                        {
                                            if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                                print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                                if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                                                    qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                    tableView.reloadData()
                                                } else {
                                                    print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                                                }
                                            }
                                        }
                                        else if subSurfaceAnswer == "Plywood / OSB" || subSurfaceAnswer == "Particle Board" || subSurfaceAnswer == "Adhesive on Concrete / Gypsum" || subSurfaceAnswer == "Epoxy"
                                        {
                                            if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                                print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                                if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                                                    qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                    tableView.reloadData()
                                                } else {
                                                    print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                                                }
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if let currentSurfaceAnswer = qustionAnswer[currentSurfaceIndex].answerOFQustion?.singleSelection?.value
                                    {
                                        if currentSurfaceAnswer == "Concrete / Cement / Gypsum"
                                        {
                                            if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                                print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                                if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                                                    qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                    tableView.reloadData()
                                                } else {
                                                    print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                                                }
                                            }
                                        }
                                        else if currentSurfaceAnswer == "Ceramic Tile (backerboard)" || currentSurfaceAnswer == "Ceramic Tile (mud bed)" || currentSurfaceAnswer == "Epoxy" || currentSurfaceAnswer == "Glued Down Hard Surface" || currentSurfaceAnswer == "Glued Down Hard Surface" || currentSurfaceAnswer == "Hardwood or Engineered Hardwood" || currentSurfaceAnswer == "Particle Board" || currentSurfaceAnswer == "Plywood / OSB" || currentSurfaceAnswer == "Adhesive Concrete/Cement/Gypsum"
                                        {
                                            if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                                print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                                if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                                                    qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                    tableView.reloadData()
                                                } else {
                                                    print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                                                }
                                            }
                                            
                                            
                                            //  (selectedValue == "Ceramic Tile (backerboard)" || currentCoveringTypeAnswer == "Ceramic Tile (mud bed)" || selectedValue == "Epoxy" || selectedValue == "Glued Down Hard Surface" || selectedValue == "Hardwood or Engineered Hardwood" || selectedValue == "Particle Board" || selectedValue == "Plywood / OSB" || selectedValue == "Adhesive Concrete/Cement/Gypsum")
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "" }) {
                                    qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                    tableView.reloadData()
                                } else {
                                    print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                                }
                            }
                        }
                    }
                }
                    cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 0)"
                }
                else
                {
                    sender.text = String(qustionAnswer[sender.tag].answerOFQustion!.numberVaue!)
                    self.alert("Please enter a valid value", nil)
                }
            }
            else
            {
                if qustionAnswer[sender.tag].code == "StairWidth" {
                    sender.text = String(qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble)
                } else {
                    sender.text = String(qustionAnswer[sender.tag].answerOFQustion!.numberVaue!)
                    self.alert("Please enter a valid value", nil)
                }
            }
            
            
            
        }
        
        
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.tag == qustionAnswer.count + 1
        {
            let miscellaneousCharge = qustionAnswer.lastIndex(where: {$0.code == "miscellaneouscharge"}) ?? 0
            if (self.qustionAnswer[miscellaneousCharge].answerOFQustion?.numberVaue ?? 0 ) > 0
            {
                if textView.text == "Enter your comments about Miscellaneous Charge"
                {
                    textView.text = ""
                }
                textView.textColor = .white
                isMiscellaneousTxtView = true
                return
            }
        }
        if(placeHolder == (textView.text ?? ""))
        {
           
            textView.textColor = .white
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.tag == qustionAnswer.count + 1
        {
            if textView.text == ""
            {
                textView.text = "Enter your comments about Miscellaneous Charge"
                textView.textColor = UIColor().colorFromHexString("#586471")
                isMiscellaneousTxtView = false
                miscelleneous_Comments = textView.text
                return
            }
            else
            {
                miscelleneous_Comments = textView.text
                return
            }
        }
        else
        {
            let value = textView.text ?? ""
            
            if(value).removeUnvantedcharactoes() == ""
            {
                textView.text = placeHolder
                textView.textColor = UIColor.placeHolderColor
                self.qustionAnswer[textView.tag].answerOFQustion = nil
            }
            else
            {
                self.qustionAnswer[textView.tag].answerOFQustion = AnswerOFQustion(value)
                
            }
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        
        if textView.tag != qustionAnswer.count + 1
        {
            let  value = textView.text ?? ""
            self.qustionAnswer[textView.tag].answerOFQustion = AnswerOFQustion(value)
            return true
        }
        else
        {
            let restrictedCharacters = CharacterSet(charactersIn: "<>&\"'")
            
            // Check if the input contains any restricted characters
            if text.rangeOfCharacter(from: restrictedCharacters) != nil {
                return false // Don't allow the change
            }
            miscelleneous_Comments = textView.text + text
        }
//            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_., "
//            if range.location == 0 && text == " "
//            {
//                return false
//            }
//                let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
//                let filtered = text.components(separatedBy: cs).joined(separator: "")
//            self.miscelleneous_Comments = textView.text
//                return (text == filtered)
//        }
        return true
    }
    
    
    
    @IBAction func pluseButtonAction(_ sender: UIButton) {
        let masterData = getMasterDataFromDB()
        if qustionAnswer[sender.tag].max_allowed_limit != 0
        {
            if qustionAnswer[sender.tag].code == "StairWidth"
            {
                if qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble == masterData.max_stair_width//qustionAnswer[sender.tag].max_allowed_limit
                {
                    print("reached max value")
                    self.alert("Stair width value exceeded maximum limit", nil)
                    return
                }
                else
                {
                    if let cell = tableView.cellForRow(at: [0, (sender.tag + 1)]) as? QustionsTableViewCell
                    {
                        qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble =  (qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble) + 0.5
                        
                        cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble)"
                        self.tableView.reloadData()
                    }
                    return
                }
            }
            else if qustionAnswer[sender.tag].code == "RipMultipleLayers"
            {
                if qustionAnswer[sender.tag].answerOFQustion!.numberVaue == qustionAnswer[sender.tag].max_allowed_limit
                {
                   print("reached max value")
                    self.alert("Rip multiple layer value exceeded maximum limit", nil)
                    return
                }
            }
        }
//        else
//        {
//            if qustionAnswer[sender.tag].id == 32
//            {
//                self.tableView.reloadData()
//            }
//        }
        if let cell = tableView.cellForRow(at: [0, (sender.tag + 1)]) as? QustionsTableViewCell
        {
            qustionAnswer[sender.tag].answerOFQustion!.numberVaue =  (qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 0) + 1
            
            
            cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? -1)"
            if area != 0.0
            {
            let buildUpLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftBuildUpLeveling"})
            let trueSelfLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftTrueSelfLeveling"})
            let removeSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "RemoveCurrentCovering" })!
            let removeSurfaceAnswer = qustionAnswer[removeSurfaceIndex].answerOFQustion?.singleSelection?.value
            let currentSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "CurrentCoveringType" })!
            let subSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "ExistingSubSurface" })!
            if sender.tag == buildUpLevelingIndex || sender.tag == trueSelfLevelingIndex
            {
                
                
                if removeSurfaceAnswer != nil
                {
                    if removeSurfaceAnswer == "Yes"
                    {
                        if let subSurfaceAnswer = qustionAnswer[subSurfaceIndex].answerOFQustion?.singleSelection?.value
                        {
                            if subSurfaceAnswer == "Concrete / Cement / Gypsum"
                            {
                                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                        tableView.reloadData()
                                    } else {
                                        print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                                    }
                                }
                            }
                            else if subSurfaceAnswer == "Plywood / OSB" || subSurfaceAnswer == "Particle Board" || subSurfaceAnswer == "Adhesive on Concrete / Gypsum" || subSurfaceAnswer == "Epoxy"
                            {
                                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                        tableView.reloadData()
                                    } else {
                                        print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        if let currentSurfaceAnswer = qustionAnswer[currentSurfaceIndex].answerOFQustion?.singleSelection?.value
                        {
                            if currentSurfaceAnswer == "Concrete / Cement / Gypsum"
                            {
                                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                        tableView.reloadData()
                                    } else {
                                        print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                                    }
                                }
                            }
                            else if currentSurfaceAnswer == "Ceramic Tile (backerboard)" || currentSurfaceAnswer == "Ceramic Tile (mud bed)" || currentSurfaceAnswer == "Epoxy" || currentSurfaceAnswer == "Glued Down Hard Surface" || currentSurfaceAnswer == "Glued Down Hard Surface" || currentSurfaceAnswer == "Hardwood or Engineered Hardwood" || currentSurfaceAnswer == "Particle Board" || currentSurfaceAnswer == "Plywood / OSB" || currentSurfaceAnswer == "Adhesive Concrete/Cement/Gypsum"
                            {
                                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                        tableView.reloadData()
                                    } else {
                                        print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                                    }
                                }
                                
                                
                                //  (selectedValue == "Ceramic Tile (backerboard)" || currentCoveringTypeAnswer == "Ceramic Tile (mud bed)" || selectedValue == "Epoxy" || selectedValue == "Glued Down Hard Surface" || selectedValue == "Hardwood or Engineered Hardwood" || selectedValue == "Particle Board" || selectedValue == "Plywood / OSB" || selectedValue == "Adhesive Concrete/Cement/Gypsum")
                            }
                        }
                    }
                }
            }
        }
            if qustionAnswer[sender.tag].code == "miscellaneouscharge"
            {
                self.tableView.reloadData()
            }
        }
        
    }
    
    @IBAction func minusButtonAction(_ sender: UIButton) {
        if let cell = tableView.cellForRow(at: [0, (sender.tag + 1)]) as? QustionsTableViewCell
        {
            if qustionAnswer[sender.tag].code == "StairWidth"
            {
                if ((qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble) > 3.0)
                {
                    qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble =  (qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble) - 0.5
                    
                    cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.stairWidthDouble)"
                    self.tableView.reloadData()
                }
            }
            if ((qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 0) > 0)
            {
                qustionAnswer[sender.tag].answerOFQustion!.numberVaue =  (qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 1) - 1
                if area != 0.0
                {
                let buildUpLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftBuildUpLeveling"})
                let trueSelfLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftTrueSelfLeveling"})
                let removeSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "RemoveCurrentCovering" })!
                let removeSurfaceAnswer = qustionAnswer[removeSurfaceIndex].answerOFQustion?.singleSelection?.value
                let currentSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "CurrentCoveringType" })!
                let subSurfaceIndex = qustionAnswer.firstIndex(where: { $0.code == "ExistingSubSurface" })!
                if sender.tag == buildUpLevelingIndex || sender.tag == trueSelfLevelingIndex
                {
                    
                    if qustionAnswer[buildUpLevelingIndex!].answerOFQustion?.numberVaue ?? 0 > 0 || qustionAnswer[trueSelfLevelingIndex!].answerOFQustion?.numberVaue ?? 0 > 0
                    {
                        if removeSurfaceAnswer != nil
                        {
                            if removeSurfaceAnswer == "Yes"
                            {
                                if let subSurfaceAnswer = qustionAnswer[subSurfaceIndex].answerOFQustion?.singleSelection?.value
                                {
                                    if subSurfaceAnswer == "Concrete / Cement / Gypsum"
                                    {
                                        if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                            print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                            if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                                                qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                tableView.reloadData()
                                            } else {
                                                print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                                            }
                                        }
                                    }
                                    else if subSurfaceAnswer == "Plywood / OSB" || subSurfaceAnswer == "Particle Board" || subSurfaceAnswer == "Adhesive on Concrete / Gypsum" || subSurfaceAnswer == "Epoxy"
                                    {
                                        if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                            print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                            if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                                                qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                tableView.reloadData()
                                            } else {
                                                print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if let currentSurfaceAnswer = qustionAnswer[currentSurfaceIndex].answerOFQustion?.singleSelection?.value
                                {
                                    if currentSurfaceAnswer == "Concrete / Cement / Gypsum"
                                    {
                                        if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                            print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                            if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                                                qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                tableView.reloadData()
                                            } else {
                                                print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                                            }
                                        }
                                    }
                                    else if currentSurfaceAnswer == "Ceramic Tile (backerboard)" || currentSurfaceAnswer == "Ceramic Tile (mud bed)" || currentSurfaceAnswer == "Epoxy" || currentSurfaceAnswer == "Glued Down Hard Surface" || currentSurfaceAnswer == "Glued Down Hard Surface" || currentSurfaceAnswer == "Hardwood or Engineered Hardwood" || currentSurfaceAnswer == "Particle Board" || currentSurfaceAnswer == "Plywood / OSB" || currentSurfaceAnswer == "Adhesive Concrete/Cement/Gypsum"
                                    {
                                        if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                                            print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                                            if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                                                qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                                tableView.reloadData()
                                            } else {
                                                print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                                            }
                                        }
                                        
                                        
                                        //  (selectedValue == "Ceramic Tile (backerboard)" || currentCoveringTypeAnswer == "Ceramic Tile (mud bed)" || selectedValue == "Epoxy" || selectedValue == "Glued Down Hard Surface" || selectedValue == "Hardwood or Engineered Hardwood" || selectedValue == "Particle Board" || selectedValue == "Plywood / OSB" || selectedValue == "Adhesive Concrete/Cement/Gypsum")
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                            print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                            if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "" }) {
                                qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                tableView.reloadData()
                            } else {
                                print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                            }
                        }
                    }
                }
            }
                
                cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? -1)"
            }
            if qustionAnswer[sender.tag].code == "miscellaneouscharge"
            {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if(validation() == "")
        {
            if(delegate == nil)
            {
                self.submitApiCall()
            }
            else
            {
                self.submitApiCall()
                //arb comment
//                if(self.summaryQustions.count != 0)
//                {
//                    self.updateApi()
//                }
//                else
//                {
//                    self.submitApiCall()
//                }
            }
        }
        else
        {
            self.alert(validation(), nil)
        }
    }
    @IBAction func dropDownButtonAction(_ sender: UIButton) {
        if(qustionAnswer[sender.tag].question_type == "simple_choice")
        {
            var names:[String] = []
            for value in qustionAnswer[sender.tag].quote_label ?? []
            {
                names.append(value.value ?? "N/A")
            }
            
            self.DropDownDefaultfunction(sender, sender.bounds.width, names, -1, delegate: self, tag: sender.tag)
        }
        else
        {
            let multy = SelectionViewController.initialization()!
            multy.delegate = self
            multy.tag  = sender.tag
            multy.quote_label = qustionAnswer[sender.tag].quote_label ?? []
            multy.selectedQuote_Label = (qustionAnswer[sender.tag].answerOFQustion == nil) ? [] : (qustionAnswer[sender.tag].answerOFQustion!.multySelection ?? [])
            multy.question = qustionAnswer[sender.tag].name ?? ""
            self.navigationController?.pushViewController(multy, animated: true)
        }
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        let miscellaneousCharge = qustionAnswer.lastIndex(where: {$0.code == "miscellaneouscharge"}) ?? 0
        if (self.qustionAnswer[miscellaneousCharge].answerOFQustion?.numberVaue ?? 0 ) > 0
        {
            return qustionAnswer.count + 2
        }
        else
        {
            return qustionAnswer.count + 1
        }
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
            var cell = QustionsTableViewCell()
            if(indexPath.row == 0)
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "HeaderQustionsTableViewCell") as! QustionsTableViewCell
                //  cell.skipButton.isHidden = (self.delegate != nil)
                
                cell.nextButton.setTitle((self.delegate != nil) ? "Save":"Next", for: .normal)
                // cell.areaLabel.text = "\((self.roomData.name ?? "Unknown")) > Total Area: \(area) Sq.Fts"
                cell.headingLabel.text =  "What is in this room ?"
            }
        else if indexPath.row == qustionAnswer.count + 1
        {
            print(indexPath.row)
             cell = self.tableView.dequeueReusableCell(withIdentifier: "MiscellaneousTextEntryTableViewCell") as! QustionsTableViewCell
            cell.miscellaneousTxtView.leftSpace()
            cell.miscellaneousTxtView.delegate = self
            cell.miscellaneousTxtView.tag = indexPath.row
            if miscelleneous_Comments != "Enter your comments about Miscellaneous Charge" || miscelleneous_Comments == ""
            {
                cell.miscellaneousTxtView.text = miscelleneous_Comments
                cell.miscellaneousTxtView.textColor = .white
            }
            else
            {
                cell.miscellaneousTxtView.text = "Enter your comments about Miscellaneous Charge"
            }
            
                       // return cell
            //cell = setCellForNumerical(indexPath.row - 2)
        }
            else
            {
                let index = indexPath.row - 1
                
                if(qustionAnswer[index].question_type ?? "") == "numerical_box"
                {
                    cell = setCellForNumerical(index)
                }
                else if(qustionAnswer[index].question_type ?? "") == "textbox"
                {
                    cell = setCellForTextEntry(index)
                }
                else
                {
                    cell = setCellForDropDown(index)
                }
                
            }
            return cell
        
          //
                    
        
        
//
    }
    
    
    func setCellForNumerical(_ index:Int) -> QustionsTableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NumericalBoxQustionsTableViewCell") as! QustionsTableViewCell
        
        cell.numerical_Qustion_Label.text = "\(index + 1). " + (qustionAnswer[index].name ?? "N/A")
        cell.numerical_Pluse_Button.tag = index
        cell.numerilcal_Minus_Button.tag = index
        if(qustionAnswer[index].answerOFQustion == nil)
        {
            qustionAnswer[index].answerOFQustion = AnswerOFQustion(0)
            print(" qustionAnswer[index].answerOFQustion : ",  qustionAnswer[index].answerOFQustion?.numberVaue)
        }
        print("Indexpath : \(index) numberValue: \(qustionAnswer[index].answerOFQustion?.numberVaue ?? -1)")
        print("Indexpath : \(qustionAnswer[index].question_type) numberValue: \(qustionAnswer[index].answerOFQustion?.numberVaue ?? -1)")
        
        cell.numerical_Answer_Label.tag = index
        if qustionAnswer[index].code == "StairWidth"
        {
            print("Indexpath : \(index) numberValue: \(qustionAnswer[index].answerOFQustion?.numberVaue ?? -1)")
            cell.numerical_Answer_Label.text = "\(qustionAnswer[index].answerOFQustion?.stairWidthDouble ?? 0.0)"
        }
        else
        {
            cell.numerical_Answer_Label.text = "\(qustionAnswer[index].answerOFQustion?.numberVaue ?? -1)"
        }
        cell.numerical_Answer_Label.isUserInteractionEnabled = true
        return cell
    }
    func setCellForTextEntry(_ index:Int) -> QustionsTableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TextEntryQustionsTableViewCell") as! QustionsTableViewCell
        cell.entry_Qustion_Label.text = "\(index + 1). " + (qustionAnswer[index].name ?? "N/A")
        cell.entry_Answer_TextView.delegate = self
        cell.entry_Answer_TextView.tag = index
        cell.entry_Answer_TextView.text = ((qustionAnswer[index].answerOFQustion?.textValue ?? "") == "" ) ? placeHolder : (qustionAnswer[index].answerOFQustion?.textValue ?? "")
        cell.entry_Answer_TextView.textColor = ((qustionAnswer[index].answerOFQustion?.textValue ?? "") == "" ) ? UIColor.placeHolderColor : UIColor.white
        return cell
    }
    func setCellForDropDown(_ index:Int) -> QustionsTableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SelectionQustionsTableViewCell") as! QustionsTableViewCell
        cell.selection_Qustion_Label.text = "\(index + 1). " + (qustionAnswer[index].name ?? "N/A")
        var name = ""
        if(qustionAnswer[index].question_type == "simple_choice")
        {
            if(qustionAnswer[index].answerOFQustion != nil)
            {
                if let value = qustionAnswer[index].answerOFQustion?.singleSelection
                {
                    name = value.value ?? "N/A"
                }
            }
        }
        else
        {
            if(qustionAnswer[index].answerOFQustion != nil)
            {
                if let values = qustionAnswer[index].answerOFQustion?.multySelection
                {
                    for value in values
                    {
                        let text = value.value ?? "N/A"
                        name = (name == "") ? text : "\(name),\n\(text)"
                    }
                }
            }
            
        }
        cell.selection_Answer_Label.text = (name == "") ? "Select Item" : name
        cell.selection_Answer_Label.textColor = (name == "") ? UIColor.placeHolderColor : UIColor.white
        cell.selection_DropDown_Button.tag = index
        
        // Q4 Deepa Start
        if let questionCode = qustionAnswer[index].code {
              if questionCode == "RemoveCurrentCovering" {
                  removeCurrentCoveringAnswer = name
              }
              
              if questionCode == "CurrentCoveringType" {
                  currentCoveringTypeAnswer = name
              }
            
            if questionCode == "ExistingSubSurface" {
                existingSubSurfaceAnswer = name
              }
          }
          
          // Check if both answers are set after the slight delay
//          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//              if let removeAnswer = self.removeCurrentCoveringAnswer,
//                 let currentCoverAnswer = self.currentCoveringTypeAnswer, let existingSubSurface = self.existingSubSurfaceAnswer {
//                  self.checkAndSelectPrimerTypeAnswer(removeCurrentCoveringAnswer: removeAnswer, currentCoveringTypeAnswer: currentCoverAnswer, existingSubSurfaceAnswer: existingSubSurface)
//              } else {
//                  print("Waiting for both answers to be set.")
//              }
//          }
        // Q4 Deepa
        
        return cell
    }
    
    // Q4 Deepa Start
    func checkAndSelectPrimerTypeAnswer(removeCurrentCoveringAnswer: String?, currentCoveringTypeAnswer: String?, existingSubSurfaceAnswer: String?) {
        
        if (removeCurrentCoveringAnswer == "No" && currentCoveringTypeAnswer == "Concrete / Cement / Gypsum") || (removeCurrentCoveringAnswer == "Yes" && existingSubSurfaceAnswer == "Concrete / Cement / Gypsum") {
            
            if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                    qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                    tableView.reloadData()
                } else {
                    print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                }
            }
            
        }
        
        if (removeCurrentCoveringAnswer == "No" && (currentCoveringTypeAnswer == "Ceramic Tile (backerboard)" || currentCoveringTypeAnswer == "Ceramic Tile (mud bed)" || currentCoveringTypeAnswer == "Epoxy" || currentCoveringTypeAnswer == "Glued Down Hard Surface" || currentCoveringTypeAnswer == "Hardwood or Engineered Hardwood" || currentCoveringTypeAnswer == "Particle Board" || currentCoveringTypeAnswer == "Plywood / OSB" || currentCoveringTypeAnswer == "Adhesive Concrete/Cement/Gypsum")) || (removeCurrentCoveringAnswer == "Yes" && (existingSubSurfaceAnswer == "Plywood / OSB" || existingSubSurfaceAnswer == "Particle Board" || existingSubSurfaceAnswer == "Adhesive on Concrete / Gypsum" || existingSubSurfaceAnswer == "Epoxy")) {
            
            if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                    qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                    tableView.reloadData()
                } else {
                    print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                }
            }
            
        }
        
        if (currentCoveringTypeAnswer == "Concrete / Cement / Gypsum") || (removeCurrentCoveringAnswer == "Yes" && existingSubSurfaceAnswer == "Concrete / Cement / Gypsum") {
            if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
                      if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "Yes" }) {
                          qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                          tableView.reloadData()
                      }
                  }
        } else {
            if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
                      if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "No" }) {
                          qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                          tableView.reloadData()
                      }
                  }
        }
    }
    // Q4 Deepa
    
    
    func foreditingFunctions()
    {
        for qustion in qustionAnswer
        {
//            if let levellingSolutionIndex =  qustionAnswer.firstIndex(where: { $0.code == "PrimerType"})
//             {
////                let value = QuoteLabelData(question_id: summaryQustions[levellingSolutionIndex].answers![0].id ?? 0, value: summaryQustions[levellingSolutionIndex].answers![0].answer ?? "")
////                let val =  AnswerOFQustion(value)
////                val.qustionLineID = summaryQustions[levellingSolutionIndex].contract_question_line_id ?? 0
////                val.answerID = summaryQustions[levellingSolutionIndex].answers![0].id ?? 0
////                qustion.answerOFQustion = val
//
////
////                let levellingSolutionIndexInt = Int(levellingSolutionIndex)
////                let value1 = qustionAnswer[levellingSolutionIndexInt].answerOFQustion
////                qustionAnswer[levellingSolutionIndexInt].answerOFQustion = AnswerOFQustion( qustionAnswer[levellingSolutionIndexInt].quote_label![0])
////                qustionAnswer[levellingSolutionIndexInt].answerOFQustion?.qustionLineID = value1?.qustionLineID ?? 0
////                qustionAnswer[levellingSolutionIndexInt].answerOFQustion?.answerID = value1?.answerID ?? 0
//            }
            for answer in summaryQustions
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
        self.tableView.reloadData()
    }
    
    func questionsListApiCall()
    {
        let parameter:[String:Any] = ["token":UserData.init().token ?? "","room_id":roomID]
        HttpClientManager.SharedHM.QustionsListForMessurementsApi(parameter: parameter) { (result, message, values) in
            if(result ?? "") == "Success"
            {
                self.qustionAnswer = values ?? []
                if(self.delegate == nil && self.isUpdated)
                {
                    self.tableView.reloadData()
                }
                else
                {
                    self.foreditingFunctions()
                }
            }
            else
            {
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        //Q4 Changes Deepa Start
              let selectedValue = item
              let questionCode = qustionAnswer[tag].code  // Assuming `code` holds the question code
                print("Selected Value: \(selectedValue), Question Code: \(questionCode)")
        //Q4 Changes Deepa
        
        if(delegate == nil)
        {
            qustionAnswer[tag].answerOFQustion = AnswerOFQustion( qustionAnswer[tag].quote_label![index])
        }
        else
        {
            let value = qustionAnswer[tag].answerOFQustion
            qustionAnswer[tag].answerOFQustion = AnswerOFQustion( qustionAnswer[tag].quote_label![index])
            qustionAnswer[tag].answerOFQustion?.qustionLineID = value?.qustionLineID ?? 0
            qustionAnswer[tag].answerOFQustion?.answerID = value?.answerID ?? 0
        }
        let buildUpLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftBuildUpLeveling"})
        let trueSelfLevelingIndex = qustionAnswer.firstIndex(where: { $0.code == "SqftTrueSelfLeveling"})
        //Q4 Changes Deepa Start
              if questionCode == "CurrentCoveringType" {
                  if selectedValue == "Carpet" || selectedValue == "Floating Floor (LVP or Laminate)" {
                      print("inside_DropDownDidSelectedAction")

                      if let removeCoveringIndex = qustionAnswer.firstIndex(where: { $0.code == "RemoveCurrentCovering" }) {
                          print("Found RemoveCurrentCovering at index: \(removeCoveringIndex)")
                          if let yesAnswer = qustionAnswer[removeCoveringIndex].quote_label?.first(where: { $0.value == "Yes" }) {
                              // Set the default answer to "Yes" for the "Toilet" question
                              qustionAnswer[removeCoveringIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                              
                              tableView.reloadData()
                              print("Default answer set to 'Yes' for question 'RemoveCurrentCovering'")
                          } else {
                              print("No 'Yes' option found in quote_label for 'RemoveCurrentCovering' question.")
                          }
                      }
                      
                  } else {
                      if let removeCoveringIndex = qustionAnswer.firstIndex(where: { $0.code == "RemoveCurrentCovering" }) {
                          print("Found RemoveCurrentCovering at index: \(removeCoveringIndex)")
                          if let yesAnswer = qustionAnswer[removeCoveringIndex].quote_label?.first(where: { $0.value == "No" }) {
                              // Set the default answer to "Yes" for the "Toilet" question
                              qustionAnswer[removeCoveringIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                              
                              tableView.reloadData()
                              print("Default answer set to 'Yes' for question 'RemoveCurrentCovering'")
                          } else {
                              print("No 'Yes' option found in quote_label for 'RemoveCurrentCovering' question.")
                          }
                      }
                  }
                  
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                      if (removeCurrentCoveringAnswer == "No" && selectedValue == "Concrete / Cement / Gypsum" && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                          
                          if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                              print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                              if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                                  qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                  tableView.reloadData()
                              } else {
                                  print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                              }
                          }
                      }
                      
                      if (removeCurrentCoveringAnswer == "No" && (selectedValue == "Ceramic Tile (backerboard)" || currentCoveringTypeAnswer == "Ceramic Tile (mud bed)" || selectedValue == "Epoxy" || selectedValue == "Glued Down Hard Surface" || selectedValue == "Hardwood or Engineered Hardwood" || selectedValue == "Particle Board" || selectedValue == "Plywood / OSB" || selectedValue == "Adhesive Concrete/Cement/Gypsum") && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                          
                          if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                              print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                              if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                                  qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                  tableView.reloadData()
                              } else {
                                  print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                              }
                          }
                      }
                      
//                      if (selectedValue == "Concrete / Cement / Gypsum") {
//                          if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
//                              if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "Yes" }) {
//                                  qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                                  tableView.reloadData()
//                              }
//                          }
//                      } else {
//                          if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
//                              if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "No" }) {
//                                  qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                                  tableView.reloadData()
//                              }
//                          }
//                      }
                  }
              }
        //Q4 Changes Deepa
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            if questionCode == "ExistingSubSurface" {
                if (removeCurrentCoveringAnswer == "Yes" && selectedValue == "Concrete / Cement / Gypsum" && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                    
                    if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                        print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                        if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                            qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                            tableView.reloadData()
                        } else {
                            print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                        }
                    }
                }
                
                if  (removeCurrentCoveringAnswer == "Yes" && (selectedValue == "Plywood / OSB" || selectedValue == "Particle Board" || selectedValue == "Adhesive on Concrete / Gypsum" || selectedValue == "Epoxy") && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                    
                    if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                        print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                        if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                            qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                            tableView.reloadData()
                        } else {
                            print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                        }
                    }
                }
                
                if (removeCurrentCoveringAnswer == "Yes" && selectedValue == "Concrete / Cement / Gypsum") {
                    if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
                        if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "Yes" }) {
                            qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                            tableView.reloadData()
                        }
                    }
                } else {
                    if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
                        if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "No" }) {
                            qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        if questionCode == "RemoveCurrentCovering" {
            if (selectedValue == "Yes" && existingSubSurfaceAnswer == "Concrete / Cement / Gypsum" && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                
                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                        tableView.reloadData()
                    } else {
                        print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                    }
                }
            }
            
            if  (selectedValue == "Yes" && (existingSubSurfaceAnswer == "Plywood / OSB" || existingSubSurfaceAnswer == "Particle Board" || existingSubSurfaceAnswer == "Adhesive on Concrete / Gypsum" || existingSubSurfaceAnswer == "Epoxy") && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                
                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                        tableView.reloadData()
                    } else {
                        print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                    }
                }
            }
            
            
            if (selectedValue == "No" && currentCoveringTypeAnswer == "Concrete / Cement / Gypsum" && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                
                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Porous" }) {
                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                        tableView.reloadData()
                    } else {
                        print("No 'Porous' option found in quote_label for 'PrimerType' question.")
                    }
                }
            }
            
            if (selectedValue == "No" && (currentCoveringTypeAnswer == "Ceramic Tile (backerboard)" || currentCoveringTypeAnswer == "Ceramic Tile (mud bed)" || currentCoveringTypeAnswer == "Epoxy" || currentCoveringTypeAnswer == "Glued Down Hard Surface" || currentCoveringTypeAnswer == "Hardwood or Engineered Hardwood" || currentCoveringTypeAnswer == "Particle Board" || selectedValue == "Plywood / OSB" || currentCoveringTypeAnswer == "Adhesive Concrete/Cement/Gypsum") && ((qustionAnswer[buildUpLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0 || (qustionAnswer[trueSelfLevelingIndex ?? 0].answerOFQustion?.numberVaue) ?? 0 > 0)) {
                
                if let primerTypeIndex = qustionAnswer.firstIndex(where: { $0.code == "PrimerType" }) {
                    print("Found RemoveCurrentCovering at index: \(primerTypeIndex)")
                    if let yesAnswer = qustionAnswer[primerTypeIndex].quote_label?.first(where: { $0.value == "Non-Porous" }) {
                        qustionAnswer[primerTypeIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                        tableView.reloadData()
                    } else {
                        print("No 'Non-Porous' option found in quote_label for 'PrimerType' question.")
                    }
                }
            }
            
//            if (selectedValue == "Yes" && existingSubSurfaceAnswer == "Concrete / Cement / Gypsum") {
//                if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
//                    if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "Yes" }) {
//                        qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                        tableView.reloadData()
//                    }
//                }
//            } else {
//                if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
//                    if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "No" }) {
//                        qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
//                        tableView.reloadData()
//                    }
//                }
//            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            if questionCode == "VaporBarrierBool" {
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    if (existingSubSurfaceAnswer == "Concrete / Cement / Gypsum" && removeCurrentCoveringAnswer == "Yes") || (currentCoveringTypeAnswer == "Concrete / Cement / Gypsum") {
                        if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
                            if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "Yes" }) {
                                qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                tableView.reloadData()
                            }
                        }
                    } else {
                        if let vaporBarrierBoolIndex = qustionAnswer.firstIndex(where: { $0.code == "VaporBarrierBool" }) {
                            if let yesAnswer = qustionAnswer[vaporBarrierBoolIndex].quote_label?.first(where: { $0.value == "No" }) {
                                qustionAnswer[vaporBarrierBoolIndex].answerOFQustion = AnswerOFQustion(yesAnswer)
                                tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        // qustionAnswer[setDefaultAnswerTrueIndexInt].answerOFQustion = AnswerOFQustion(vapourBarrierValue)
        
            //var setDefaultAnswerTrueIndex = qustionAnswer.firstIndex(of: qustionAnswer.filter({$0.setde == UnitNumberId}).first ?? Unit_list()) ?? 0
        let roomNameSubStr = roomName.contains("STAIRS")
        if roomNameSubStr != true && area != 0.0
        {
                if tag == 0
                {
 
                    let setDefaultAnswerTrueIndex = qustionAnswer.lastIndex { $0.code == "VaporBarrierBool"}
                   
                    if setDefaultAnswerTrueIndex != nil
                    {
                        let setDefaultAnswerTrueIndexInt = Int(setDefaultAnswerTrueIndex!)
                        UserDefaults.standard.set(qustionAnswer[setDefaultAnswerTrueIndexInt].amount, forKey: "VaporBarrierAmount")
                        if qustionAnswer[tag].answerOFQustion?.singleSelection?.value == qustionAnswer[setDefaultAnswerTrueIndexInt].applicableCurrentSurface//"Concrete / Cement"
                        {
                            var vapourBarrierValue : Int = Int()
                            let vapourValue = modf(area / 100)
                            if vapourValue.1 == 0.0
                            {
                                vapourBarrierValue = Int(vapourValue.0)
                            }
                            else
                            {
                                vapourBarrierValue = Int(vapourValue.0) + 1
                            }
                           
                            //qustionAnswer[setDefaultAnswerTrueIndexInt].amount
                            qustionAnswer[setDefaultAnswerTrueIndexInt].answerOFQustion = AnswerOFQustion(qustionAnswer[setDefaultAnswerTrueIndexInt].quote_label![1])
                            //qustionAnswer[17].answerOFQustion?.numberVaue = vapourBarrierValue
                            //self.tableView.reloadRows(at: [[setDefaultAnswerTrueIndexInt,(setDefaultAnswerTrueIndexInt + 1)]], with: .automatic)
                        }
                        else
                        {
                            qustionAnswer[setDefaultAnswerTrueIndexInt].answerOFQustion = AnswerOFQustion(qustionAnswer[setDefaultAnswerTrueIndexInt].quote_label![0])
                            //qustionAnswer[17].answerOFQustion?.numberVaue = vapourBarrierValue
                            //self.tableView.reloadRows(at: [[setDefaultAnswerTrueIndexInt,(setDefaultAnswerTrueIndexInt + 1)]], with: .automatic)
                        }
                    }
                }
            }
            
        
        
        self.tableView.reloadRows(at: [[0,(tag + 1)]], with: .automatic)
    }
    
    func MultySelectionSelectedAction(_ items: [QuoteLabelData], _ tag: Int) {
        if(delegate == nil)
        {
            qustionAnswer[tag].answerOFQustion = AnswerOFQustion(items)
            
        }
        else
        {
            let value = qustionAnswer[tag].answerOFQustion
            qustionAnswer[tag].answerOFQustion = AnswerOFQustion(items)
            qustionAnswer[tag].answerOFQustion?.qustionLineID = value?.qustionLineID ?? 0
            qustionAnswer[tag].answerOFQustion?.answerID = value?.answerID ?? 0
        }
        self.tableView.reloadRows(at: [[0,(tag + 1)]], with: .automatic)
    }
    
    
    func
    validation () -> String
    {
        var value = 0
        for question in self.qustionAnswer
        {
            // q4 changes
            let TrueSelfLeveling = qustionAnswer.lastIndex(where: { $0.code == "SqftTrueSelfLeveling" }) ?? 0
            let BuildUpLeveling = qustionAnswer.lastIndex(where: { $0.code == "SqftBuildUpLeveling" }) ?? 0
            let PrimerType = qustionAnswer.lastIndex(where: { $0.code == "PrimerType" }) ?? 0
            let miscellaneousCharge = qustionAnswer.lastIndex(where: {$0.code == "miscellaneouscharge"}) ?? 0
           let selectedAnswer = self.qustionAnswer[PrimerType].answerOFQustion?.singleSelection
            
            let StairCount = qustionAnswer.lastIndex(where: {$0.code == "StairCount"}) ?? 0
            let StairWidth = qustionAnswer.lastIndex(where: {$0.code == "StairWidth"}) ?? 0
            
            print("StairCount answer1 : ", self.qustionAnswer[StairCount].answerOFQustion?.numberVaue)
            print("StairCount answer2 : ", self.qustionAnswer[StairCount].answerOFQustion?.stairWidthDouble)
            
            print("StairWidth answer1 : ", self.qustionAnswer[StairWidth].answerOFQustion?.numberVaue)
            print("StairWidth answer2 : ", self.qustionAnswer[StairWidth].answerOFQustion?.stairWidthDouble)
         
            print("question : ", qustionAnswer)
            
            print("mandatory value : ", "\(question.mandatory_answer == true)", ", NUMVAL: ", ((self.qustionAnswer[StairCount].answerOFQustion?.numberVaue ?? 0) > 0), ", STRWDT: ", "\((self.qustionAnswer[StairCount].answerOFQustion?.stairWidthDouble ?? 0.0) > 0.0)", "textvalue : ", "\((self.qustionAnswer[StairCount].answerOFQustion?.textValue?.count ?? 0) > 0)")
            
            if ((question.mandatory_answer == true) &&  !((((self.qustionAnswer[value].answerOFQustion?.numberVaue ?? 0) > 0) || (self.qustionAnswer[value].answerOFQustion?.stairWidthDouble ?? 0.0) > 0.0) || ((self.qustionAnswer[value].answerOFQustion?.textValue?.count ?? 0) > 0) ||
                                                            ((self.qustionAnswer[value].answerOFQustion?.singleSelection) != nil) ||
                                                            ((self.qustionAnswer[value].answerOFQustion?.multySelection?.count ?? 0) > 0)))
            {
         
                let questionNumber = value + 1
                return "Please answer question number \(questionNumber)"
            } else if roomName.contains("STAIRS") {
                if ((question.mandatory_answer == true) && !((self.qustionAnswer[StairCount].answerOFQustion?.numberVaue ?? 0) > 0) ) {
                    var StairCount = qustionAnswer.lastIndex(where: {$0.code == "StairCount"}) ?? 0
                    StairCount = StairCount + 1
                    return "Please answer question number \(StairCount)"
                }
            }
           // q4 changes
            else  if (((self.qustionAnswer[TrueSelfLeveling].answerOFQustion?.numberVaue ?? 0) > 0) || ((self.qustionAnswer[BuildUpLeveling].answerOFQustion?.numberVaue ?? 0) > 0)) &&
                        ((self.qustionAnswer[PrimerType].answerOFQustion?.singleSelection?.value) ?? "") == ""  {
                
                //Q4_Change Primer Type Mandatory dropdown
                return "You must select a primer type"

            }
             if (self.qustionAnswer[miscellaneousCharge].answerOFQustion?.numberVaue ?? 0 ) > 0
            {
                if miscelleneous_Comments == "Enter your comments about Miscellaneous Charge"
                {
                   return "You must enter comments about miscellaneous charge"
                }
//                 else
//                 {
//                    self.miscelleneous_Comments =
//                }
            }
            
            
            //                    guard (self.qustionAnswer[0].answerOFQustion?.multySelection?.count ?? 0) > 0 else {
            //
            //                                         return "Please answer the question \(value)"
            //
            //                                      }
            
            value += 1
            //                    if(value == 3)
            //                    {
            //                        break
            //                    }
        }
        print("question1 : ", qustionAnswer)
        return ""
    }
    
//    func updateApi()
//    {
//        // var datas:[[String:Any]] = []
//        //        for question in qustionAnswer
//        //        {
//        //            if let answer = question.answerOFQustion
//        //            {
//        //                if(question.question_type == "simple_choice")
//        //                {
//        //                    var questions:[[String:Any]] = []
//        //                    let value = (answer.singleSelection?.value ?? "")
//        //                    let param:[String:Any] = ["id":answer.answerID ,"contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"answer":value]
//        //                    questions.append(param)
//        //                    let data:[String:Any] = ["contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"name":"","room_id":roomID,"floor_id":floorID,"appointment_id":appoinmentID,"answers":questions]
//        //                    datas.append(data)
//        //
//        //                }
//        //                else if(question.question_type == "numerical_box")
//        //                {
//        //                     var questions:[[String:Any]] = []
//        //                    let value = "\(answer.numberVaue ?? 0)"
//        //                    if ((answer.numberVaue ?? 0) != 0)
//        //                    {
//        //                     let param:[String:Any] = ["id":answer.answerID ,"contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"answer":value]
//        //                        questions.append(param)
//        //                    let data:[String:Any] = ["contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"name":"","room_id":roomID,"floor_id":floorID,"appointment_id":appoinmentID,"answers":questions]
//        //                        datas.append(data)
//        //                    }
//        //                }
//        //                else if(question.question_type == "textbox")
//        //                {
//        //                    var questions:[[String:Any]] = []
//        //                    let value = (answer.textValue ?? "")
//        //                    if(value != "")
//        //                    {
//        //                    let param:[String:Any] = ["id":answer.answerID ,"contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"answer":value]
//        //                     questions.append(param)
//        //                    let data:[String:Any] = ["contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"name":"","room_id":roomID,"floor_id":floorID,"appointment_id":appoinmentID,"answers":questions]
//        //                                           datas.append(data)
//        //                    }
//        //                }
//        //                else if(question.question_type == "multiple_choice")
//        //                {    var questions:[[String:Any]] = []
//        //                    var value:String = ""
//        //                    for ans in answer.multySelection ?? []
//        //                    {
//        //                        value = (value == "") ? value : (value + ", " + (ans.value ?? ""))
//        //                    }
//        //                    let param:[String:Any] = ["id":answer.answerID ,"contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"answer":value]
//        //                     questions.append(param)
//        //                    let data:[String:Any] = ["contract_question_line_id":question.answerOFQustion?.qustionLineID ?? 0,"name":"","room_id":roomID,"floor_id":floorID,"appointment_id":appoinmentID,"answers":questions]
//        //                                                             datas.append(data)
//        //                }
//        //            }
//        //        }
//        //
//        //
//        //
//        //        let parameter:[String:Any] = ["token":UserData.init().token ?? "","data":datas]
//        var questions:[[String:Any]] = []
//
//        for question in qustionAnswer
//        {
//            if let answer = question.answerOFQustion
//            {
//                if(question.question_type == "simple_choice")
//                {
//                    let value = [(answer.singleSelection?.value ?? "")]
//                    let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                    questions.append(param)
//
//                }
//                else if(question.question_type == "numerical_box")
//                {
//                    let value = ["\(answer.numberVaue ?? 0)"]
//                    if((answer.numberVaue ?? 0) != 0)
//                    {
//                        let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                        questions.append(param)
//                    }
//                }
//                else if(question.question_type == "textbox")
//                {
//                    let value = [(answer.textValue ?? "")]
//                    if((answer.textValue ?? "") == "")
//                    {
//                        let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                        questions.append(param)
//                    }
//                }
//                else if(question.question_type == "multiple_choice")
//                { var value:[String] = []
//                    for ans in answer.multySelection ?? []
//                    {
//                        value.append(ans.value ?? "")
//                    }
//                    let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                    questions.append(param)
//                }
//            }
//        }
//
//
//        let data:[String:Any] = ["name":"","room_id":roomID,"floor_id":floorID,"appointment_id": appoinmentID,"room_measurement_id":drowingImageID,"questions":questions]
//        let parameter:[String:Any] = ["token":UserData.init().token ?? "","data":data]
//        HttpClientManager.SharedHM.UpdateQustionoriesApi(parameter: parameter) { (result, message, value) in
//            if(result ?? "") == "Success"
//            {
//
//                self.performSegueToReturnBack()
//                self.delegate?.SummeryEditDelegateInQustionariesEditingDone(summaryData: <#SummeryDetailsData#>)
//
//            }
//            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
//            {
//
//                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
//
//                    self.fourceLogOutbuttonAction()
//                }
//
//                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
//
//            }
//            else
//            {
//                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//
//                    self.updateApi()
//                }
//                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
//                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
//            }
//        }
//    }
    
    
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
            else if question.question_code == "StairWidth"
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
    
//    func createSummaryData() -> SummeryDetailsData{
//        let summaryData =  SummeryDetailsData()
//        let appointmentId = AppointmentData().appointment_id ?? 0
//        let appointment =  getCompletedAppointmentsFromDB(appointmentId:appointmentId)
//        let room = appointment.first?.rooms.filter("room_id == %d", roomID)
//        if room?.count == 1{
//            summaryData.name = roomName
//            summaryData.room_name = roomName
//            summaryData.room_id = roomID
//            summaryData.appointment_id = appointmentId
//            summaryData.room_area = Double(room?.first?.room_area ?? "0.0")
//            summaryData.stair_count = room?.first?.room_type == "Floor" ? 0 : 0
//            summaryData.adjusted_area = room?.first?.draw_area_adjusted == nil ? Double(room?.first?.room_area ?? "0.0") : Double(room?.first?.draw_area_adjusted ?? "0.0")
//            summaryData.comments = room?.first?.room_summary_comment ?? ""
//            summaryData.striked = (room?.first?.room_strike_status ?? false) ? "1" : "0"
//            var room_Attachments:[AttachmentDataValue] = []
//            if let roomAttachments = room?.first?.room_attachments{
//                for room in roomAttachments{
//                    room_Attachments.append(AttachmentDataValue(savedImageUrl: room, savedImageName: "", id: 0))
//                }
//            }
//            summaryData.attachments = room_Attachments
//            summaryData.attachment_comments = ""
//            summaryData.drawing_attachment = [AttachmentDataValue(savedImageUrl: room?.first?.draw_image_name ?? "", savedImageName: "", id: 0)]
//            var transtionDetails:[SummeryTransitionDetails] = []
//            if let transArray = room?.first?.transArray{
//                for transData in transArray{
//                    transtionDetails.append(SummeryTransitionDetails(name: transData.name ?? ""))
//                }
//                summaryData.transition = transtionDetails
//            }
//        }
//        var questionsArray:[SummeryQustionsDetails] = []
//        let questions = List<rf_master_question>()
//        if let questionsArr = appointment.first?.questionnaires{
//            for question in questionsArr{
//                if !roomName.localizedCaseInsensitiveContains("stair") {
//                    if (!((question.question_name ?? "").localizedCaseInsensitiveContains("stair"))){
//                        questions.append(question)
//                    }
//                }else{
//                    if ((question.question_name ?? "").localizedCaseInsensitiveContains("stair")){
//                        questions.append(question)
//                    }
//                }
//            }
//            for qstnAnswer in questions{
//                let answer = SummeryQustionAnswerData(id: qstnAnswer.id, answer: (qstnAnswer.rf_AnswerOFQustion.first?.answer.first ?? ""))
//                let qtn = SummeryQustionsDetails(question_id: qstnAnswer.id, name: qstnAnswer.question_code ?? "", question: qstnAnswer.question_name ?? "", question_type: qstnAnswer.question_type ?? "", answers: [answer])
//                questionsArray.append(qtn)
//            }
//        }
//        summaryData.questionaire = questionsArray
//       return summaryData
//    }
    func calculateExtraPrice(question:rf_master_question,answerOfQuestion:List<rf_AnswerForQuestion>) -> Double{
        var extra_price :Double = 0.0
        var amount :Double = 0.0
        var amountIncluded :Double = 0.0
        var simpleChoiceTypeCheck :Bool = false
        var answer_score :Double = 0.0
        
        if question.question_code == "StairCount" {
            stair_Count = answerOfQuestion.first?.answer.first ?? ""
        }
        
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
        
        print("question.question_code : ", question.question_code)
        if question.question_code == "CurrentCoveringType"{
            extra_price = 0.0
            currentSurfaceAnswerScore = question.quote_label.filter({$0.value == answerOfQuestion.first?.answer.first ?? ""}).first?.answer_score ?? 0.0
            print("currentSurfaceAnswerScore : ", currentSurfaceAnswerScore)
            return extra_price//satheesh
        }
        amount = question.amount
        amountIncluded = Double(question.amount_included)
        let answerData = answerOfQuestion.first?.answer.first
        if question.question_code == "RemoveCurrentCovering"{
            if let answer = answerData{
                if answer == "Yes"{
                    let room_area = self.getTotalAdjustedAreaForRoom(roomId: roomID)
                    let net_room_area = room_area - amountIncluded > 0 ? room_area - amountIncluded : 0
                    extra_price = net_room_area * currentSurfaceAnswerScore
                    print("extra_price : ", extra_price,  " currentSurfaceAnswerScore : ", currentSurfaceAnswerScore)
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
                            print("----answerScore---- : ", answerScore)
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
                    if question.question_type == "simple_choice" && answer == "Yes" && question.calculate_order_wise != true{
                        extra_price = amount
                    }else if question.question_type == "numerical_box"{
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
    
    func  submitApiCall()
    {
        
        // set value of answerOFQuestion in db
        let appointmentId = AppointmentData().appointment_id ?? 0
        let questionsForAppointment = getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID)
        var extraCost:Double = 0.0
        var extraCostExclude:Double = 0.0
        var extraPromoCostExcluded: Double = 0.0
        for i in 0..<questionsForAppointment.count{
            let questionsArray = List<rf_AnswerForQuestion>()
            let question = questionsForAppointment[i]
            let questionAnswerForQuestionIdArr = self.qustionAnswer.filter({$0.id == question.id})
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
                            dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":questionsArray,"appointment_id":appointmentId,"room_id":roomID,"room_name":roomName,"calculate_order_wise":question.calculate_order_wise]
                            print("--------dict----------", dict, " question : ", question.question_name)
                            realm.create(rf_master_question.self, value: dict, update: .all)
                            questionsForAppointment[i].rf_AnswerOFQustion = questionsArray
                            
                            let additionalCost = self.calculateExtraPrice(question: question, answerOfQuestion: questionsArray)
                            print("------additionalCost : ", additionalCost, " question : ", question.question_code)
                            if question.exclude_from_discount{
                                extraCostExclude = extraCostExclude + additionalCost
                                print("------additionalCost_extraCostExclude : ", extraCostExclude)
                            }
                            if question.exclude_from_promotion
                            {
                                extraPromoCostExcluded = extraPromoCostExcluded + additionalCost
                                print("------additionalCost_extraPromoCostExcluded : ", extraPromoCostExcluded)
                            }
                            extraCost = extraCost + additionalCost
                            additional_cost = Int(extraCost)
                            print("------additionalCost_extraCost : ", extraCost)
                        }
                    }catch{
                        print(RealmError.initialisationFailed)
                    }
                }
                
            }
            
        }
        if miscelleneous_Comments != "Enter your comments about Miscellaneous Charge" && miscelleneous_Comments != ""
        {
            
            saveRoomMiscellaneousComments(miscellanousComments: self.miscelleneous_Comments, appointmentId: appointmentId, roomId: roomID)
        }
        
        self.saveQuestionAndAnswerToCompletedAppointment(roomId: roomID, questionAndAnswer: questionsForAppointment)
        //save extra cost of selected room to appointment
        self.saveExtraCostToCompletedAppointment(roomId: self.roomID, extraCost: extraCost)
        //save extra cost to exclude
        self.saveExtraCostExcludeToCompletedAppointment(roomId: self.roomID, extraCostExclude: extraCostExclude, extraPromoPriceToExclude: extraPromoCostExcluded)
        //to save stair count and width to appointment room details
        let room_area = self.getTotalAdjustedAreaForRoom(roomId: roomID)
        if room_area == 0{
            self.saveStairDetailsToCompletedAppointment(roomId: self.roomID)
        }
        
        //arb
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "RoomQuestionnaire"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        
        if(self.delegate == nil)
        {
            //arb
            let summery = SummeryDetailsViewController.initialization()!
            if(self.isStair == 1)
            {
                summery.isStair = self.isStair
            }
            summery.summaryData = self.createSummaryData(roomID: roomID, roomName: roomName) //arb
            self.navigationController?.pushViewController(summery, animated: true)
        }
        else
        {
            self.performSegueToReturnBack()
            self.delegate?.SummeryEditDelegateInQustionariesEditingDone(summaryData: self.createSummaryData(roomID: roomID, roomName: roomName))
        }
        
    
        
       
//
//        //
//        var questions:[[String:Any]] = []
//
//        for question in qustionAnswer
//        {
//            if let answer = question.answerOFQustion
//            {
//                if(question.question_type == "simple_choice")
//                {
//                    let value = [(answer.singleSelection?.value ?? "")]
//                    let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                    questions.append(param)
//
//                }
//                else if(question.question_type == "numerical_box")
//                {
//                    let value = ["\(answer.numberVaue ?? 0)"]
//                    if((answer.numberVaue ?? 0) != 0)
//                    {
//                        let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                        questions.append(param)
//                    }
//                }
//                else if(question.question_type == "textbox")
//                {
//                    let value = [(answer.textValue ?? "")]
//                    if((answer.textValue ?? "") == "")
//                    {
//                        let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                        questions.append(param)
//                    }
//                }
//                else if(question.question_type == "multiple_choice")
//                { var value:[String] = []
//                    for ans in answer.multySelection ?? []
//                    {
//                        value.append(ans.value ?? "")
//                    }
//                    let param:[String:Any] = ["question_id":question.id ?? 0,"answer":value]
//                    questions.append(param)
//                }
//            }
//        }
//
//
//        let data:[String:Any] = ["name":"","room_id":roomID,"floor_id":floorID,"appointment_id": appoinmentID,"questions":questions,"room_measurement_id":drowingImageID]
//        let parameter:[String:Any] = ["token":UserData.init().token ?? "","data":data]
//
//        HttpClientManager.SharedHM.SubmitContractMessurementsQuestionsApi(parameter: parameter) { (result, message, value) in
//            if(result ?? "") == "Success"
//            {
//
//                if(self.delegate == nil)
//                {
//                    //                let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
//                    self.summeryDetailsDataApiCall()
//                    // }
//                    // self.alert("Successfully Updated", [ok])
//                }
//                else
//                {
//                    self.performSegueToReturnBack()
//                    self.delegate?.SummeryEditDelegateInQustionariesEditingDone()
//                }
//
//            }
//            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
//            {
//
//                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
//
//                    self.fourceLogOutbuttonAction()
//                }
//
//                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
//
//            }
//            else
//            {
//                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//
//                    self.submitApiCall()
//                }
//                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
//                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
//            }
//        }
        
    }
    
    func summeryDetailsDataApiCall()
    {
        if(self.delegate == nil)
        {
            HttpClientManager.SharedHM.RoomSummeryDetailsApi(self.drowingImageID) { (result,message, value) in
                if(result == "Success")
                {
                    if(value ?? []).count != 0
                    {
                        let summery = SummeryDetailsViewController.initialization()!
                        summery.summaryData = value![0]
                        if(self.isStair == 1)
                        {
                            summery.isStair = self.isStair
                        }
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
                        
                        self.summeryDetailsDataApiCall()
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
                }
            }
        }
        else
        {
            self.performSegueToReturnBack()
            self.delegate?.SummeryEditDelegateInTilesEditingDone()
        }
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
extension FurnitureQustionsViewController: ImagePickerDelegate {

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



