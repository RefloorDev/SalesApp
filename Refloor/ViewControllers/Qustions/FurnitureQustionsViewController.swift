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
    var roomName = ""
    var roomID = 0
    var floorID = 0
    var appoinmentID = 0
    var isStair = 0
    var drowingImageID = 0
    var placeHolder = "Type Here"
    var summaryQustions:[SummeryQustionsDetails] = []
    var delegate:SummeryEditDelegate?
    var isUpdated = true
    var imagePicker: CaptureImage!
    @IBOutlet weak var tableView: UITableView!
    var qustionAnswer:[QuestionsMeasurementData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
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
        //questionsListApiCall()
        var questionsList = RealmSwift.List<rf_master_question>()
        questionsList = self.getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID)
        var qustionAnswer: [QuestionsMeasurementData] = []
        questionsList.forEach{ question in
            if !roomName.localizedCaseInsensitiveContains("stair") {
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
                        dict["quote_label"] = question.quote_label
                        dict["last_updated_date"] = question.last_updated_date
                        dict["applicableTo"] = question.applicableTo
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
                    qustionAnswer[sender.tag].answerOFQustion!.numberVaue =  value2
                    cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 0)"
                }
                else
                {
                    self.alert("Please enter a valid value", nil)
                }
            }
            else
            {
                self.alert("Please enter a valid value", nil)
            }
            
            
            
        }
        
        
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(placeHolder == (textView.text ?? ""))
        {
            textView.text = ""
            textView.textColor = .white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
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
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let  value = textView.text ?? ""
        self.qustionAnswer[textView.tag].answerOFQustion = AnswerOFQustion(value)
        return true
    }
    
    
    
    @IBAction func pluseButtonAction(_ sender: UIButton) {
        if let cell = tableView.cellForRow(at: [0, (sender.tag + 1)]) as? QustionsTableViewCell
        {
            qustionAnswer[sender.tag].answerOFQustion!.numberVaue =  (qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 0) + 1
            
            cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? -1)"
        }
        
    }
    
    @IBAction func minusButtonAction(_ sender: UIButton) {
        if let cell = tableView.cellForRow(at: [0, (sender.tag + 1)]) as? QustionsTableViewCell
        {
            if ((qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 0) > 0)
            {
                qustionAnswer[sender.tag].answerOFQustion!.numberVaue =  (qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? 1) - 1
                
                cell.numerical_Answer_Label.text = "\(qustionAnswer[sender.tag].answerOFQustion!.numberVaue ?? -1)"
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qustionAnswer.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = QustionsTableViewCell()
        if(indexPath.row == 0)
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderQustionsTableViewCell") as! QustionsTableViewCell
            //  cell.skipButton.isHidden = (self.delegate != nil)
            
            cell.nextButton.setTitle((self.delegate != nil) ? "Save":"Next", for: .normal)
            // cell.areaLabel.text = "\((self.roomData.name ?? "Unknown")) > Total Area: \(area) Sq.Fts"
            cell.headingLabel.text =  "What is in this room ?"
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
            
        }
        cell.numerical_Answer_Label.tag = index
        cell.numerical_Answer_Label.text = "\(qustionAnswer[index].answerOFQustion?.numberVaue ?? -1)"
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
        
        return cell
    }
    
    
    func foreditingFunctions()
    {
        for qustion in qustionAnswer
        {
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
                            val.qustionLineID = answer.contract_question_line_id ?? 0
                            val.answerID = answer.answers![0].id ?? 0
                            qustion.answerOFQustion = val
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
            
            if ((question.mandatory_answer == true) &&  !(((self.qustionAnswer[value].answerOFQustion?.numberVaue ?? 0) > 0) || ((self.qustionAnswer[value].answerOFQustion?.textValue?.count ?? 0) > 0) ||
                                                            ((self.qustionAnswer[value].answerOFQustion?.singleSelection) != nil) ||
                                                            ((self.qustionAnswer[value].answerOFQustion?.multySelection?.count ?? 0) > 0)))
            {
                
                let questionNumber = value + 1
                return "Please answer question number \(questionNumber)"
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
        if question.question_code == "CurrentCoveringType"{
            extra_price = 0.0
            currentSurfaceAnswerScore = question.quote_label.filter({$0.value == answerOfQuestion.first?.answer.first ?? ""}).first?.answer_score ?? 0.0
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
                    if question.question_type == "simple_choice" && answer == "Yes"{
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
                            dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":questionsArray,"appointment_id":appointmentId,"room_id":roomID]
                            realm.create(rf_master_question.self, value: dict, update: .all)
                            questionsForAppointment[i].rf_AnswerOFQustion = questionsArray
                            
                            let additionalCost = self.calculateExtraPrice(question: question, answerOfQuestion: questionsArray)
                            if question.exclude_from_discount{
                                extraCostExclude = extraCostExclude + additionalCost
                            }
                            extraCost = extraCost + additionalCost
                        }
                    }catch{
                        print(RealmError.initialisationFailed)
                    }
                }
                
            }
            
        }
        
        self.saveQuestionAndAnswerToCompletedAppointment(roomId: roomID, questionAndAnswer: questionsForAppointment)
        //save extra cost of selected room to appointment
        self.saveExtraCostToCompletedAppointment(roomId: self.roomID, extraCost: extraCost)
        //save extra cost to exclude
        self.saveExtraCostExcludeToCompletedAppointment(roomId: self.roomID, extraCostExclude: extraCostExclude)
        //to save stair count and width to appointment room details
        if roomName.localizedCaseInsensitiveContains("stair"){
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
