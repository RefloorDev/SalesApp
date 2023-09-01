//
//  SummeryDetailsViewController.swift
//  Refloor
//
//  Created by sbek on 26/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

protocol SummeryEditDelegate {
    func SummeryEditDelegateInTransitionEditingDone()
    func SummeryEditDelegateInQustionariesEditingDone(summaryData:SummeryDetailsData)
    func SummeryEditDelegateInTilesEditingDone()
}
class SummeryDetailsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,SummeryEditDelegate,ExternalCollectionViewDelegateForTableView {
    
    
    
    static func initialization() -> SummeryDetailsViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SummeryDetailsViewController") as? SummeryDetailsViewController
    }
    var isStair = 0
    @IBOutlet weak var tableView: UITableView!
    var isADetailView = false
    var edit_for_qustionaries = 10
    var edit_for_transitions = 11
    var edit_for_tiles = 12
    var area = ""
    var edit_for_room_attachment = 13
    var summaryData:SummeryDetailsData!
    var tableViewDatas:[SummeryTableDataValues] = []
    var placeHolder = "Additional Comments..."
    var imagePicker: CaptureImage!
    var roomImagesArray:[UIImage] = []
    //arb
    var roomID = 0
    var roomName = ""
    var currentSurfaceAnswerScore = 0.0
    var qustionAnswer:[QuestionsMeasurementData] = []
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        setRoomImagesArray()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.roomID = self.summaryData.room_id ?? 0
        self.roomName = self.summaryData.room_name ?? ""
        setQuestion()
        self.setNavigationBarbackAndlogo(with: "Room Summary".uppercased())
        self.tableReaload()
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        
    }
    
    func setRoomImagesArray(){
        self.roomImagesArray.removeAll()
        DispatchQueue.global(qos: .default).async{
            if let transition = self.summaryData.attachments{
                for attachment in transition{
                    if let image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: attachment.url ?? ""){
                        self.roomImagesArray.append(image)
                    }
                }
            }
        }

    }
    
    func setQuestion(){
        let appointmentId = AppointmentData().appointment_id ?? 0
        var questionsList = RealmSwift.List<rf_master_question>()
        let roomID = self.summaryData.room_id ?? 0
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
        foreditingFunctions()
    }
    
    func foreditingFunctions()
    {
        for qustion in qustionAnswer
        {
            for answer in self.summaryData.questionaire ?? []
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
        print(qustionAnswer)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.summaryData.comments = textView.text!
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == placeHolder)
        {
            textView.text = ""
            textView.textColor = .white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == "" && textView.text == placeHolder)
        {
            textView.text = placeHolder
            textView.textColor = UIColor(displayP3Red: 88/255, green: 100/255, blue: 113/255, alpha: 1)
            //rgba(88, 100, 113, 1)
        }
    }
    
    func tableReaload()
    {
        tableViewDatas = []
        let tableViewData11 = SummeryTableDataValues(cellType: .heading, summeryData: nil,  qustionAnswer: nil, transitionObjcets: nil, isTransition: false, isHeading: true, heading: "\(summaryData.room_name ?? "") Summary")
        tableViewDatas.append(tableViewData11)
        
        let tableViewData1 = SummeryTableDataValues(cellType: .SubDetails, summeryData: summaryData, qustionAnswer: nil, transitionObjcets: nil, isTransition: false, isHeading: false, heading: "")
        if(self.isStair != 1)
        {
            tableViewDatas.append(tableViewData1)
        }
        
        
        
        let tableViewData0 = SummeryTableDataValues(cellType: .SubHeading, summeryData: nil,  qustionAnswer: nil, transitionObjcets: nil, isTransition: false, isHeading: true, heading: "ROOM Photos".uppercased())
        tableViewData0.tag = edit_for_room_attachment
        tableViewDatas.append(tableViewData0)
        if(summaryData.attachments?.count != 0)
        {
            
            
            let tableViewData = SummeryTableDataValues(cellType: .Transiion, summeryData: nil, qustionAnswer: nil, transitionObjcets: nil, isTransition: true, isHeading: false, heading: "")
            tableViewData.attachments = summaryData.attachments
            tableViewData.comments = summaryData.attachment_comments
            tableViewData.tag = -1
            tableViewDatas.append(tableViewData)
            
        }
        else
        {
            let tableViewData = SummeryTableDataValues(cellType: .SubHeading, summeryData: nil,  qustionAnswer: nil, transitionObjcets: nil, isTransition: false, isHeading: true, heading: "No Photos Added")
            tableViewData.isNoData = true
            tableViewDatas.append(tableViewData)
        }
        //        let tableViewData2 = SummeryTableDataValues(summeryData: nil, qustionAnswer: nil, transitionObjcets: nil, isTransition: true, isHeading: true, heading: "TILES COLOR")
        //         tableViewData2.tag = edit_for_tiles
        //        tableViewDatas.append(tableViewData2)
        //        let tableViewData3 = SummeryTableDataValues(summeryData: summaryData, qustionAnswer: nil, transitionObjcets: nil, isTransition: true, isHeading: true, heading: "")
        //        tableViewDatas.append(tableViewData3)
        //        let tableViewData4 = SummeryTableDataValues(summeryData: nil, qustionAnswer: nil, transitionObjcets: nil, isTransition: true, isHeading: true, heading: "Transitions".uppercased())
        //            tableViewData4.tag = edit_for_transitions
        //         tableViewDatas.append(tableViewData4)
        //        if(summaryData.transition?.count != 0)
        //        {
        //             var count = 1
        //            for transition in summaryData.transition ?? []
        //            {
        //                let tableViewData = SummeryTableDataValues(summeryData: nil, qustionAnswer: nil, transitionObjcets: transition, isTransition: true, isHeading: false, heading: "Transition: \(count)".uppercased())
        //                tableViewData.tag = count - 1
        //                tableViewDatas.append(tableViewData)
        //                count += 1
        //            }
        //
        //        }
        //        else
        //        {
        //            let tableViewData = SummeryTableDataValues(summeryData: nil, qustionAnswer: nil, transitionObjcets: nil, isTransition: true, isHeading: true, heading: "No Transition")
        //               tableViewData.isNoData = true
        //            tableViewDatas.append(tableViewData)
        //        }
        
        let tableViewData5 = SummeryTableDataValues(cellType: .SubHeading, summeryData: nil,  qustionAnswer: nil, transitionObjcets: nil, isTransition: false, isHeading: true, heading: "ROOM DETAILS:".uppercased())
        tableViewData5.tag = edit_for_qustionaries
        tableViewDatas.append(tableViewData5)
        
        if(summaryData.questionaire?.count != 0)
        {
            
            var count = 1
            for qustions in (summaryData.questionaire ?? []).filter({$0.answers?.first?.answer != ""})
            {
                let tableViewData = SummeryTableDataValues(cellType: .Qustions, summeryData: nil,  qustionAnswer: qustions, transitionObjcets: nil, isTransition: false, isHeading: false, heading: "\(count). ")
                tableViewDatas.append(tableViewData)
                count += 1
            }
            
        }
        else
        {
            let tableViewData = SummeryTableDataValues(cellType: .SubHeading, summeryData: nil,  qustionAnswer: nil, transitionObjcets: nil, isTransition: false, isHeading: true, heading: "No room details")
            tableViewData.isNoData = true
            tableViewDatas.append(tableViewData)
        }
        
        
        
        self.tableView.reloadData()
    }
    @IBAction func editButtonAction(_ sender: UIButton) {
        if(sender.tag == self.edit_for_tiles)
        {
            let tilesView = SelectTilesViewController.initialization()!
            tilesView.roomName = self.summaryData.room_name ?? ""
            tilesView.drowingImageID = self.summaryData.contract_measurement_id ?? 0
            tilesView.selectedTileID = self.summaryData.material_id ?? 0
            tilesView.delegate = self
            tilesView.comments = self.summaryData.material_comments ?? ""
            self.navigationController?.pushViewController(tilesView, animated: true)
        }
        else if(sender.tag == self.edit_for_qustionaries)
        {
            let furnitureQustions = FurnitureQustionsViewController.initialization()!
            furnitureQustions.roomName = self.summaryData.room_name ?? ""
            furnitureQustions.drowingImageID = self.summaryData.contract_measurement_id ?? 0
            furnitureQustions.roomID = self.summaryData.room_id ?? 0
            furnitureQustions.floorID = self.summaryData.floor_id ?? 0
            furnitureQustions.appoinmentID = self.summaryData.appointment_id ?? 0
            furnitureQustions.area = summaryData.adjusted_area ?? 0.0
            furnitureQustions.delegate = self
            furnitureQustions.summaryQustions = self.summaryData.questionaire ?? []
            self.deleteDiscountArrayFromDb() 
            self.navigationController?.pushViewController(furnitureQustions, animated: true)
        }
        else if(sender.tag == self.edit_for_transitions)
        {
            let transition = TransactionViewController.initialization()!
            transition.roomName = self.summaryData.room_name ?? ""
            transition.drowingImageID = self.summaryData.contract_measurement_id ?? 0
            transition.roomID = self.summaryData.room_id ?? 0
            transition.floorID = self.summaryData.floor_id ?? 0
            transition.appoinmentID = self.summaryData.appointment_id ?? 0
            transition.delegate = self
            transition.area = CGFloat(self.summaryData.room_area ?? 0)
            self.navigationController?.pushViewController(transition, animated: true)
        }
        else if(sender.tag == self.edit_for_room_attachment)
        {
            let next = AboutRoomViewController.initialization()!
            next.appoinmentID = self.summaryData.appointment_id ?? 0
            next.roomID = self.summaryData.room_id ?? 0
            next.roomName = self.summaryData.room_name ?? ""
            next.drowingImageID = self.summaryData.contract_measurement_id ?? 0
            next.area = CGFloat(self.summaryData.room_area ?? 0)
            next.delegate = self
            next.value = self.summaryData.attachment_comments ?? ""
            next.uploadedImage = self.summaryData.attachments ?? []
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return tableViewDatas.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(tableViewDatas.count == indexPath.row)
        {
            return cellforCommentsTableViewCell(tableView, indexPath: indexPath)
        }
        
        let tableViewData = tableViewDatas[indexPath.row]
        if(tableViewData.cellType == .heading)
        {
            
            return cellforheadingTableViewCell(tableView, indexPath: indexPath, tableValue: tableViewData)
        }
        else  if(tableViewData.cellType == .SubDetails)
        {
            return cellforSubDetailsTableViewCell(tableView, indexPath: indexPath, tableValue: tableViewData)
        }
        //        else if(indexPath.row == 2)
        //        {
        //            return cellforSubHeadingTableViewCell(tableView, indexPath: indexPath, tableValue: tableViewData, tag: edit_for_tiles)
        //        }
        //        else if(indexPath.row == 3)
        //        {
        //            return cellforTiesTableViewCell(tableView: tableView, indexPath: indexPath, tableValue: tableViewData)
        //        }
        else if(tableViewData.cellType == .SubHeading)
        {
            return cellforSubHeadingTableViewCell(tableView, indexPath: indexPath, tableValue: tableViewData, tag: tableViewData.tag)
        }
        else
        {
            if(tableViewData.isTransition)
            {
                return cellforTransiionTableViewCell(tableView, indexPath: indexPath, tableValue: tableViewData)
            }
            else
            {
                return cellforQustionsTableViewCell(tableView, indexPath: indexPath, tableValue: tableViewData)
            }
        }
    }
    
    func cellforheadingTableViewCell(_ tableView:UITableView,indexPath:IndexPath,tableValue:SummeryTableDataValues) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryDetailsHeadingTableViewCell") as! SummeryDetailsHeadingTableViewCell
        
        cell.headingLabel.text = "\(summaryData.room_name ?? "") Summary"
        return cell
    }
    
    func cellforSubDetailsTableViewCell(_ tableView:UITableView,indexPath:IndexPath,tableValue:SummeryTableDataValues) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryDetailsSubDetailsTableViewCell") as! SummeryDetailsSubDetailsTableViewCell
        
        cell.roomNameLabel.text = (tableValue.summeryData?.room_name ?? "").uppercased()
        if let attachments = tableValue.summeryData?.drawing_attachment
        {
            if attachments.count != 0
            {
                //cell.shapeMessurementImage.loadImageFormWeb(URL(string:attachments[0].url ?? ""))
                if let drawingImg = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:attachments[0].url ?? ""){
                    cell.shapeMessurementImage.image = drawingImg
                    let tap = UITapGestureRecognizer(target: self, action: #selector(tapshapeMessureImageRecognizer))
                    tap.numberOfTapsRequired = 1
                    cell.shapeMessurementImage.isUserInteractionEnabled = true
                    cell.shapeMessurementImage.addGestureRecognizer(tap)
                }
            }
        }
        if area == ""
        {
            
            area = "\(tableValue.summeryData?.room_area ?? 0)"
            
        }
        let ara = Double(tableValue.summeryData?.room_area ?? 0)
        
        cell.areaLabel.text = "Mearsured Area: \(ara.rounded(.awayFromZero).clean) sq.ft"
        let a = Double(tableValue.summeryData?.adjusted_area ?? 0)
        
        
        
        cell.messurementTF.text = "\(a.rounded(.awayFromZero).clean)"
        return cell
    }
    
    
    @objc func tapshapeMessureImageRecognizer()
    {
        if let attachments = summaryData.drawing_attachment
        {
            let imagePresent = ImageViewAndRemoveViewController.initialization()!
            
            imagePresent.position = 0
            imagePresent.attachments = [attachments[0]]
            imagePresent.isNoRemved = true
            self.present(imagePresent, animated: true, completion: nil)
        }
        
    }
    
    func cellforSubHeadingTableViewCell(_ tableView:UITableView,indexPath:IndexPath,tableValue:SummeryTableDataValues,tag:Int) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryDetailsSubHeadingTableViewCell") as! SummeryDetailsSubHeadingTableViewCell
        if indexPath.row == 0 || (!(isStair != 1) && (tableValue.heading ?? "").lowercased().contains("room photos"))
        {
            cell.bottomView.isHidden = true
        }
        else
        {
            cell.bottomView.isHidden = false
        }
        if !(tableValue.isNoData)
        {
            cell.headingLabel.text = tableValue.heading
            cell.editButton.tag = tag
            cell.nodataLabel.isHidden = true
            cell.headingLabel.isHidden = false
            cell.editButton.isHidden = false
        }
        else
        {
            cell.nodataLabel.isHidden = false
            cell.headingLabel.isHidden = true
            cell.editButton.isHidden = true
            cell.nodataLabel.text = tableValue.heading
        }
        return cell
    }
    
    func cellforTransiionTableViewCell(_ tableView:UITableView,indexPath:IndexPath,tableValue:SummeryTableDataValues) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryDetailsTransitionsTableViewCell") as! SummeryDetailsTransitionsTableViewCell
        cell.transitionsLabel.text = tableValue.heading
        if(tableValue.transitionObjcets != nil)
        {
            
            cell.collection_tag = tableValue.tag
            cell.delegate = self
            //cell.collectionViewReload(tableValue.transitionObjcets?.attachments ?? [])
            if (tableValue.transitionObjcets?.attachments ?? []).count == self.roomImagesArray.count{
                cell.collectionViewReload(self.roomImagesArray)
            }else{
                
            }
            
        }
        else
        {
            
            cell.delegate = self
            cell.collection_tag = tableValue.tag
            //cell.collectionViewReload(tableValue.attachments ?? [])
            cell.collectionViewReload(self.roomImagesArray)
            
        }
        return cell
    }
    func cellforQustionsTableViewCell(_ tableView:UITableView,indexPath:IndexPath,tableValue:SummeryTableDataValues) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryDetailsQustionsTableViewCell") as! SummeryDetailsQustionsTableViewCell
        //qustionAnswer
        
        cell.qustionLabel.text = (tableValue.heading ?? "") + (tableValue.qustionAnswer?.question ?? "")
        var answer = ""
        
        
        for values in tableValue.qustionAnswer?.answers ?? []
        {
            answer = (answer == "") ? values.answer ?? "" : (answer + "," + (values.answer ?? ""))
        }
        
        cell.answerLabel.text = (answer == "") ? "No Answer" : answer
        return cell
    }
    
    func cellforCommentsTableViewCell(_ tableView:UITableView,indexPath:IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryDetailsFooterTableViewCell") as! SummeryDetailsFooterTableViewCell
        cell.commentsTextView.delegate = self
        //cell.commentsTextView.leftSpace()
        cell.commentsTextView.leftSpace()
        cell.commentsTextView.text = (summaryData.comments == "") ? placeHolder:summaryData.comments
        cell.commentsTextView.textColor = (summaryData.comments == "") ? UIColor(displayP3Red: 88/255, green: 100/255, blue: 113/255, alpha: 1):UIColor.white
        
        return cell
    }
    func cellforTiesTableViewCell( tableView:UITableView,indexPath:IndexPath,tableValue:SummeryTableDataValues) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryDetailsTilesTableViewCell") as! SummeryDetailsTilesTableViewCell
        cell.aboutLabel.text = tableValue.summeryData?.material_comments
        cell.tileImageView.loadImageFormWeb(URL(string: tableValue.summeryData?.material_image_url ?? ""))
        return cell
    }
    @IBAction func textFieldEndEditing(_ sender: UITextField) {
        
        if let cell = tableView.cellForRow(at: [0,1]) as? SummeryDetailsSubDetailsTableViewCell
        {
            
            if let value = Double(sender.text ?? "")
            {
                
                summaryData.adjusted_area  = value
                cell.messurementTF.text = (summaryData.adjusted_area ?? 0).toRoundeString
                if isStair != 1
                {
                    let setDefaultAnswerTrueIndex = qustionAnswer.lastIndex { $0.setDefaultAnswer == true && $0.code == "VaporBarrier"}
                    if setDefaultAnswerTrueIndex != nil
                    {
                        let setDefaultAnswerTrueIndexInt = Int(setDefaultAnswerTrueIndex!)
                        if qustionAnswer[sender.tag].answerOFQustion?.singleSelection?.value == qustionAnswer[setDefaultAnswerTrueIndexInt].applicableCurrentSurface
                        {
                            var vapourBarrierValue : Int = Int()
                            let vapourValue = modf((summaryData.adjusted_area ?? 0) / 100)
                            if vapourValue.1 == 0.0
                            {
                                vapourBarrierValue = Int(vapourValue.0)
                            }
                            else
                            {
                                vapourBarrierValue = Int(vapourValue.0) + 1
                            }
                            summaryData.questionaire![setDefaultAnswerTrueIndexInt].answers![sender.tag].answer = String(vapourBarrierValue)
                            qustionAnswer[setDefaultAnswerTrueIndexInt].answerOFQustion = AnswerOFQustion(vapourBarrierValue)
                            tableReaload()
                        }
                    }
                }
//                self.updateAdjustedArea(appointmentId: AppointmentData().appointment_id ?? 0, roomId:self.summaryData.room_id ?? 0 , area: String(summaryData.adjusted_area ?? 0.0))
                
            }
            else
            {
                cell.messurementTF.text  = (summaryData.adjusted_area ?? 0).toRoundeString
                self.alert("Please enter correct adjustment area for updating", nil)
            }
        }
        
    }
    @IBAction func minusButtonAction(_ sender: UIButton) {
        
        if let cell = tableView.cellForRow(at: [0,1]) as? SummeryDetailsSubDetailsTableViewCell
        {
            if let value = summaryData.adjusted_area
            {
               
                if(value > 1)
                {
                    self.deleteDiscountArrayFromDb()
                    summaryData.adjusted_area  = value - 1
                    cell.messurementTF.text = "\(summaryData.adjusted_area ?? 0)"
                    if isStair != 1
                    {
                        let setDefaultAnswerTrueIndex = qustionAnswer.lastIndex { $0.setDefaultAnswer == true && $0.code == "VaporBarrier"}
                        if setDefaultAnswerTrueIndex != nil
                        {
                            let setDefaultAnswerTrueIndexInt = Int(setDefaultAnswerTrueIndex!)
                            if qustionAnswer[sender.tag].answerOFQustion?.singleSelection?.value == qustionAnswer[setDefaultAnswerTrueIndexInt].applicableCurrentSurface
                            {
                                var vapourBarrierValue : Int = Int()
                                let vapourValue = modf((summaryData.adjusted_area ?? 0) / 100)
                                if vapourValue.1 == 0.0
                                {
                                    vapourBarrierValue = Int(vapourValue.0)
                                }
                                else
                                {
                                    vapourBarrierValue = Int(vapourValue.0) + 1
                                }
                                qustionAnswer[setDefaultAnswerTrueIndexInt].answerOFQustion = AnswerOFQustion(vapourBarrierValue)
                                summaryData.questionaire![setDefaultAnswerTrueIndexInt].answers![sender.tag].answer = String(vapourBarrierValue)
                                tableReaload()
                            }
                        }
                    }
                }
            }
        }
        
    }
    @IBAction func pluseButtonAction(_ sender: UIButton) {
        if let cell = tableView.cellForRow(at: [0,1]) as? SummeryDetailsSubDetailsTableViewCell
        {
            if let value = summaryData.adjusted_area
            {
                self.deleteDiscountArrayFromDb()
                summaryData.adjusted_area  = value + 1
                cell.messurementTF.text = "\(summaryData.adjusted_area ?? 0)"
                if isStair != 1
                {
                    let setDefaultAnswerTrueIndex = qustionAnswer.lastIndex { $0.setDefaultAnswer == true && $0.code == "VaporBarrier"}
                    if setDefaultAnswerTrueIndex != nil
                    {
                        let setDefaultAnswerTrueIndexInt = Int(setDefaultAnswerTrueIndex!)
                        if qustionAnswer[sender.tag].answerOFQustion?.singleSelection?.value == qustionAnswer[setDefaultAnswerTrueIndexInt].applicableCurrentSurface
                        {
                            var vapourBarrierValue : Int = Int()
                            let vapourValue = modf((summaryData.adjusted_area ?? 0) / 100)
                            if vapourValue.1 == 0.0
                            {
                                vapourBarrierValue = Int(vapourValue.0)
                            }
                            else
                            {
                                vapourBarrierValue = Int(vapourValue.0) + 1
                            }
                            qustionAnswer[setDefaultAnswerTrueIndexInt].answerOFQustion = AnswerOFQustion(vapourBarrierValue)
                            summaryData.questionaire![setDefaultAnswerTrueIndexInt].answers![sender.tag].answer = String(vapourBarrierValue)
                            tableReaload()
                        }
                    }
                }
                //self.updateAdjustedArea(appointmentId: AppointmentData().appointment_id ?? 0, roomId:self.summaryData.room_id ?? 0 , area: String(summaryData.adjusted_area ?? 0.0))
            }
        }
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton)
    {
        //arb
        self.updateAdjustedArea(appointmentId: AppointmentData().appointment_id ?? 0, roomId:self.summaryData.room_id ?? 0 , area: String(summaryData.adjusted_area ?? 0.0))
        self.submitApiCall()
        self.updateRoomComment(appointmentId: AppointmentData().appointment_id ?? 0, roomId:self.summaryData.room_id ?? 0 , comment: summaryData.comments ?? "")
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "RoomMeasurementSummary"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        if(!self.isADetailView)
        {
            let summeryList = SummeryListViewController.initialization()!
            summeryList.appoinmentID = self.summaryData.appointment_id ?? 0
            
            AppDelegate.appoinmentslData.is_room_measurement_exist = true
            self.navigationController?.pushViewController(summeryList, animated: true)
        }
        else
        {
            self.performSegueToReturnBack()
        }
        //
       // summeryDetailsUpdateApi()
    }
    
    func summeryDetailsDataApiCall(_ masuremetID:Int)
    {
        HttpClientManager.SharedHM.RoomSummeryDetailsApi(masuremetID) { (result,message, value) in
            if(result == "Success")
            {
                if(value ?? []).count != 0
                {
                    
                    self.summaryData = value![0]
                    self.tableReaload()
                }
                else
                {
                    self.alert("No record available", nil)
                }
            }
            else
            {
                //self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func SummeryEditDelegateInTransitionEditingDone() {
        DispatchQueue.main.async
        {
            //self.summeryDetailsDataApiCall(self.summaryData.contract_measurement_id ?? 0)
            let attachments = self.loadRoomImage(appointmentId: AppointmentData().appointment_id ?? 0,roomId: self.summaryData.room_id ?? 0)
            var attachmentArr:[AttachmentDataValue] = []
            for image in attachments{
                attachmentArr.append(AttachmentDataValue(savedImageUrl: image))
            }
            self.summaryData.attachments = attachmentArr
            self.setRoomImagesArray()
            self.tableReaload()
        }
    }
    func SummeryEditDelegateInQustionariesEditingDone(summaryData:SummeryDetailsData) {
        self.summaryData = summaryData
        self.tableReaload()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.summeryDetailsDataApiCall(self.summaryData.contract_measurement_id ?? 0)
//        }
    }
    func SummeryEditDelegateInTilesEditingDone() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.summeryDetailsDataApiCall(self.summaryData.contract_measurement_id ?? 0)
        }
    }
    func summeryDetailsUpdateApi(){
   
        if let cell = self.tableView.cellForRow(at: [0,1]) as? SummeryDetailsSubDetailsTableViewCell
        {
            if let value =  Double(cell.messurementTF.text ?? "")
            {
                summaryData.adjusted_area = value
            }
        }
        
        let data:[String:Any] = ["contract_measurement_id":summaryData.contract_measurement_id ?? 0,"room_id":summaryData.room_id ?? 0,"adjusted_area":summaryData.adjusted_area ?? 0,"comments":summaryData.comments ?? "", "token":UserData.init().token ?? ""]
        
        HttpClientManager.SharedHM.UpdateSummeryDetails(parameter: data) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                if(!self.isADetailView)
                {
                    let summeryList = SummeryListViewController.initialization()!
                    summeryList.appoinmentID = self.summaryData.appointment_id ?? 0
                    AppDelegate.appoinmentslData.is_room_measurement_exist = true
                    self.navigationController?.pushViewController(summeryList, animated: true)
                }
                else
                {
                    self.performSegueToReturnBack()
                }
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
                    
                    self.summeryDetailsUpdateApi()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                //self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func externalCollectionViewDidSelectbutton(index:Int,tag:Int)
    {
        if tag != -1
        {
            if let data = summaryData.transition
            {
                if let attach = data[tag].attachments
                {
                    let imagePresent = ImageViewAndRemoveViewController.initialization()!
                    
                    imagePresent.position = index
                    imagePresent.attachments = attach
                    imagePresent.isNoRemved = true
                    self.present(imagePresent, animated: true, completion: nil)
                }
            }
        }
        else
        {
            
            let imagePresent = ImageViewAndRemoveViewController.initialization()!
            
            imagePresent.position = index
            imagePresent.attachments = summaryData.attachments ?? []
            imagePresent.isNoRemved = true
            self.present(imagePresent, animated: true, completion: nil)
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
    
    func  submitApiCall()
    {
        // set value of answerOFQuestion in db
        let appointmentId = AppointmentData().appointment_id ?? 0
        
        let questionsForAppointment = getQuestionsForAppointment(appointmentId: appointmentId, roomId: roomID)
        var extraCost:Double = 0.0
        var extraCostExclude:Double = 0.0
        var extrapromoToexclude:Double = 0.0
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
                            dict = ["questionIdUnique":questionUniqueIdentifier,"id":questionId,"rf_AnswerOFQustion":questionsArray,"appointment_id":appointmentId,"room_id":roomID,"room_name":roomName]
                            realm.create(rf_master_question.self, value: dict, update: .all)
                            questionsForAppointment[i].rf_AnswerOFQustion = questionsArray
                            
                            let additionalCost = self.calculateExtraPrice(question: question, answerOfQuestion: questionsArray)
                            if question.exclude_from_discount{
                                extraCostExclude = extraCostExclude + additionalCost
                            }
                            if question.exclude_from_promotion
                            {
                                extrapromoToexclude = extrapromoToexclude + additionalCost
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
        self.saveExtraCostExcludeToCompletedAppointment(roomId: self.roomID, extraCostExclude: extraCostExclude,extraPromoPriceToExclude: extrapromoToexclude)
        //to save stair count and width to appointment room details
        if roomName.localizedCaseInsensitiveContains("stair"){
            self.saveStairDetailsToCompletedAppointment(roomId: self.roomID)
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
    
    
}
extension SummeryDetailsViewController: ImagePickerDelegate {

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
