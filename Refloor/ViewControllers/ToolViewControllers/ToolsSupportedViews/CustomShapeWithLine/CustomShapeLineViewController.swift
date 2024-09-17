//
//  CustomShapeLineViewController.swift
//  Refloor
//
//  Created by sbek on 03/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.


import UIKit
import RealmSwift

class CustomShapeLineViewController: UIViewController,CustomViewDelegate,LineViewDelegate,DropDownDelegate,UITextFieldDelegate {
    
    
    
    @IBOutlet weak var masterView: UIView!
    
    static func initialization() -> CustomShapeLineViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CustomShapeLineViewController") as? CustomShapeLineViewController
    }
    
    
    @IBOutlet weak var tempAreaLabel: UILabel!
    @IBOutlet weak var graphMoodLabel: UILabel!
    @IBOutlet weak var drowingContentView: UIView!
    @IBOutlet weak var bottomToolView: UIView!
    @IBOutlet weak var bottomToolViewWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var areaTF: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rectangle_Button: UIButton!
    @IBOutlet weak var graphMode_Selection_Button: UIButton!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var horisontalButton: UIButton!
    @IBOutlet weak var verticalButton: UIButton!
    @IBOutlet weak var addView_WidthTF: UITextField!
    @IBOutlet weak var addView_HeightTF: UITextField!
    @IBOutlet weak var add_Button: UIButton!
    @IBOutlet weak var add_View_hight_Constrain: NSLayoutConstraint!
    @IBOutlet weak var bottomLineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selected_squareView_Name_label: UILabel!
    @IBOutlet weak var selected_horizotal_Button: UIButton!
    @IBOutlet weak var selected_vertical_Button: UIButton!
    @IBOutlet weak var seletced_SqureView_TF: UITextField!
    @IBOutlet weak var selected_View_Constrain: NSLayoutConstraint!
    @IBOutlet weak var selected_SquareView_Height_TF: UITextField!
    @IBOutlet weak var selected_View: UIView!
    var isResponder = false
    var drowingView:LineView!
    var labels:[UILabel] = []
    var respondeTag = -1
    var isVertical = true
    var areaValue:CGFloat = 0
    var perimeter:Float = 0
    var selectedOpening:SubSqureView?
    var orginalgraphXvalue = 0
    var intWidth:CGFloat = 0
    var width:CGFloat = 0
    var intHight:Int = 0
    var hight:CGFloat = 0
    var selectedPostion = 0
    var areaSquareFt = 0
    var yAxisLayerSharae:CAShapeLayer!
    var xAxisLayerSharae:CAShapeLayer!
    var roomData:RoomDataValue!
    var addData:CustomeShapeViewController!
    var messurementID = -1
    var imagePicker: CaptureImage!
    var transitionHeightDropDownArray:List<rf_transitionHeights_results>!
    
 //   var openingsList:[OpeningCustomObject] = [OpeningCustomObject(name: "No Transition", color: .white),OpeningCustomObject(name: "Reducer", color: .yellow),OpeningCustomObject(name: "Square Edge", color: .blue),OpeningCustomObject(name: "Stair Nose", color: .green),OpeningCustomObject(name: "Carpet", color: .red)]
    
    var openingsList:[OpeningCustomObject] = [OpeningCustomObject(name: "No Transition", color: .white),OpeningCustomObject(name: "Reducer", color: .yellow),OpeningCustomObject(name: "Square Edge", color: .blue),OpeningCustomObject(name: "Stair Nose", color: .green),OpeningCustomObject(name: "Carpet", color: .red),OpeningCustomObject(name: "Metal T", color: .cyan)]//,OpeningCustomObject(name: "Rubber", color: .magenta)]
     
  
    var currentOpening:Int = -1
    var appoinmentslData:AppoinmentDataValue!
    var path: UIBezierPath!
    var graph_minimunValue = minimumValue
    var summaryData:SummeryDetailsData!
    var transitionHeightvalue:[String] = []
    var transitionHeightId:Int = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        minimumValue = 40
        addView_WidthTF.delegate = self
        addView_HeightTF.delegate = self
        bottomLineViewTopConstraint.constant = 35
        addView_HeightTF.setLeftPaddingPoints(10)
        selected_SquareView_Height_TF.setLeftPaddingPoints(10)
        //
        //seletced_SqureView_TF.delegate = self
        
        transitionHeightDropDownArray = self.getTransitionheightDropDownValue()
        if transitionHeightDropDownArray.count > 0
        {
            transitionHeightvalue = transitionHeightDropDownArray!.compactMap({$0.name})
            //        var transitionHeightValueCopy = transitionHeightvalue
            //        transitionHeightvalue.removeAll()
            //        for index in 0...transitionHeightValueCopy.count - 1
            //        {
            //            var value = transitionHeightValueCopy[index]
            //            value = value.replacingOccurrences(of: "\"", with: "")
            //            transitionHeightvalue.append(value)
            //        }
            transitionHeightId = transitionHeightDropDownArray[0].transitionHeightId
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.drowingView = LineView(frame: CGRect(x: 0, y: 0, width: self.masterView.bounds.width - 300, height: self.masterView.bounds.height ))
            self.drowingView.delegate = self
            self.drowingView.backgroundColor = .clear
            self.setgraphView(self.drowingContentView)
            self.drowingContentView.addSubview(self.drowingView)
            self.scrollView.isHidden = true
            self.addViewHideORVisible(true)
            self.no_Squre_View_In_Tool()
            self.setNavigationBarbacklogoResetAndNext(name: self.roomData.name ?? "")
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    override func resetButtonAction() {
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.resetAllThing()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        self.alert("Are you sure you want to reset the current shape?", [yes,no])
        
    }
    override func performSegueToReturnBack() {
        let ok = UIAlertAction(title: "Yes", style: .default) { (_) in
//            if(self.messurementID == -1)
//            {
//                self.navigationController?.popViewController(animated: true)
//            }
//            else
//            {
                //self.DeleteroomMeasurement()
                let appointmentId = AppointmentData().appointment_id ?? 0
                let room_id = self.roomData.id ?? 0
                //delete images from document directory
                //1. drawing drawing
            let drawingPath = self.getDrawingPath(appointmentId: appointmentId, roomId: room_id)
                if drawingPath.count > 0{
                    _ = ImageSaveToDirectory.SharedImage.deleteImageFromDocumentDirectory(rfImage: drawingPath)
                }
                //2. Delete saved room images from document directory
                self.deleteRoomAttachmentImagesFromDirectory(appointmentId: appointmentId, roomId: room_id)
                
                //delete row from DB , this also delete room from appointment
                
                self.deleteRoomById(appointmentId: appointmentId, roomId: room_id)
                self.navigationController?.popViewController(animated: true)
           // }
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        // self.alert("Are you sure you want to go back? Selected room measurements will be deleted if you navigate back.", [ok,no])
        self.alert("Your current drawing will be lost. Are you sure?", [ok,no])
        
        
    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == seletced_SqureView_TF
//        {
//            if let text = textField.text {
//
//                    let newStr = (text as NSString)
//                    .replacingCharacters(in: range, with: string)
//                    if newStr.isEmpty {
//                        return true
//                    }
//                    let intvalue = Int(newStr)
//                return (intvalue! >= 0 && intvalue! <= 12)
//                }
//                return true
//        }
//        return true
//    }
    
    @IBAction func areaTFDidEndAction(_ sender: UITextField) {
        if let value2 =  Float(sender.text ?? "")
        {
            let a = Double(value2)
            
            self.areaValue = roundTheValue(CGFloat(value2))
            self.areaTF.text = "\(a.rounded().clean)"
        }
        else
        {
            self.alert("Wrong Value", nil)
        }
    }
    func roundTheValue(_ value:CGFloat) -> CGFloat
    {
        return CGFloat(Float(value * 100).rounded()/100)
    }
    @IBAction func AreaTFDidBegen(_ sender: UITextField) {
        
    }
    @IBAction func areaMinusButtonAction(_ sender: UIButton) {
        areaValue -= 1
        let a = Double(areaValue)
        self.areaTF.text = "\(a.rounded().clean)"
    }
    
    @IBAction func areaPluseButtonAction(_ sender: UIButton) {
        areaValue += 1
        let a = Double(areaValue)
        
        
        self.areaTF.text = "\(a.rounded().clean)"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == addView_WidthTF
        {
            let searchString = (addView_WidthTF.text as NSString?)?.replacingCharacters(in: range, with: string)
            if (searchString?.count)! > 1 {
                
                let inverseSet = CharacterSet(charactersIn: ".0123456789").inverted
                
                return ((string as NSString).rangeOfCharacter(from: inverseSet).location == NSNotFound)
                
            } else {
                
                let inverseSet = CharacterSet(charactersIn: ".123456789").inverted
                
                return ((string as NSString).rangeOfCharacter(from: inverseSet).location == NSNotFound)
            }
        }
        return true
    }
    
    override func nextAction() {
        
        
        //q4 changes // kavya
        
        var isSelected = addData?.add_Button.isSelected
        if(!self.drowingView.isConfirmed) {
            self.alert("Please press Done to complete the Room Drawing", nil)
        } else if selected_View.isHidden == true {     // Q4_Change Add Openings Popup
            self.alert("Please select add openings", nil)
        } else {
            let appointmentId = AppointmentData().appointment_id ?? 0
            let currentClassName = String(describing: type(of: self))
            let classDisplayName = "RoomDrawing"
            self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
            //
            self.messurementUpload()
        }
//        if(self.drowingView.isConfirmed)
//        {
//            //arb
//            let appointmentId = AppointmentData().appointment_id ?? 0
//            let currentClassName = String(describing: type(of: self))
//            let classDisplayName = "RoomDrawing"
//            self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
//            //
//            self.messurementUpload()
//        }
//        else
//        {
//            self.alert("Please press Done to complete the Room Drawing", nil)
//        }
    }
    func setgraphForMoodView(_ sender :UIView)
    {
        var graphValue = minimumValue
        if(graphValue == 30)
        {
            graphValue *= 2
            //self.graphMood.setTitle("2x", for: .normal)
            //self.graphMood.tag = 1
            
        }
        else if(graphValue == 20)
        {
            graphValue *= 3
            // self.graphMood.setTitle("3x", for: .normal)
            // self.graphMood.tag = 2
            
        }
        else if(graphValue == 10)
        {
            graphValue *= 4
            // self.graphMood.setTitle("4x", for: .normal)
            //self.graphMood.tag = 3
            
        }
        else if(graphValue == 5)
        {
            graphValue *= 10
            // self.graphMood.setTitle("10x", for: .normal)
            // self.graphMood.tag = 4
            
        }
        else if graphValue == 1
        {
            graphValue *= 50
            // self.graphMood.setTitle("50x", for: .normal)
            //self.graphMood.tag = 5
            
        }
        else if graphValue != 40
        {
            graphValue *= 100
            //   self.graphMood.setTitle("100x", for: .normal)
            //  self.graphMood.tag = 6
            
        }
        else
        {
            //   self.graphMood.setTitle("1x", for: .normal)
            //  self.graphMood.tag = 0
            
        }
        
        let xAxispath = UIBezierPath()
        let tmpwidth = sender.frame.width
        intWidth = tmpwidth / minimumValue
        width = ((intWidth ) * graphValue) + graphValue
        
        let tmphight = sender.frame.height
        intHight = Int(tmphight / graphValue)
        hight = CGFloat((intHight - 1) * Int(graphValue))
        // xAxis creattion
        for i in 0...(Int(intWidth) + 2)
        {
            let xvalue =  (Int(graphValue) * i)
            xAxispath.move(to: CGPoint(x: xvalue, y: 0))
            xAxispath.addLine(to: CGPoint(x:xvalue, y: Int(hight)))
            xAxispath.close()
            
        }
        
        
        
        // yAxis creattion
        for i in 0...(intHight + 3)
        {
            if( i != 0)
            {
                let yvalue =  (Int(graphValue) * i)
                xAxispath.move(to: CGPoint(x: 0, y: yvalue))
                xAxispath.addLine(to: CGPoint(x:Int(width), y: yvalue))
                xAxispath.close()
            }
            
        }
        
        if(yAxisLayerSharae == nil)
        {
            
            yAxisLayerSharae = CAShapeLayer()
            
            yAxisLayerSharae.backgroundColor = UIColor.clear.cgColor
            yAxisLayerSharae.path = xAxispath.cgPath
            yAxisLayerSharae.fillColor = UIColor.clear.cgColor
            yAxisLayerSharae.strokeColor = UIColor.lightGray.cgColor
            yAxisLayerSharae.lineWidth = 1.0
            sender.layer.addSublayer(yAxisLayerSharae)
        }
        else
        {
            yAxisLayerSharae.path = xAxispath.cgPath
        }
        
        
        
    }
    
    func setgraphView(_ sender :UIView)
    {
        graph_minimunValue = minimumValue
        
        if(graph_minimunValue == 30)
        {
            graph_minimunValue *= 2
            //               self.graphMood.setTitle("2x", for: .normal)
            //               self.graphMood.tag = 1
            orginalgraphXvalue = 1
        }
        else if(graph_minimunValue == 20)
        {
            graph_minimunValue *= 3
            //               self.graphMood.setTitle("3x", for: .normal)
            //               self.graphMood.tag = 2
            orginalgraphXvalue = 2
        }
        else if(graph_minimunValue == 10)
        {
            graph_minimunValue *= 4
            //               self.graphMood.setTitle("4x", for: .normal)
            //               self.graphMood.tag = 3
            orginalgraphXvalue = 3
        }
        else if(graph_minimunValue == 5)
        {
            graph_minimunValue *= 10
            //               self.graphMood.setTitle("10x", for: .normal)
            //               self.graphMood.tag = 4
            orginalgraphXvalue = 4
        }
        else if graph_minimunValue == 1
        {
            graph_minimunValue *= 50
            //               self.graphMood.setTitle("50x", for: .normal)
            //               self.graphMood.tag = 5
            orginalgraphXvalue = 5
        }
        else if graph_minimunValue != 40
        {
            graph_minimunValue *= 100
            //               self.graphMood.setTitle("100x", for: .normal)
            //               self.graphMood.tag = 6
            orginalgraphXvalue = 6
        }
        else
        {
            //               self.graphMood.setTitle("1x", for: .normal)
            //               self.graphMood.tag = 0
            orginalgraphXvalue = 0
        }
        
        let xAxispath = UIBezierPath()
        let tmpwidth = self.view.frame.width
        intWidth = tmpwidth / minimumValue
        width = ((intWidth ) * graph_minimunValue) + graph_minimunValue
        
        let tmphight = self.view.frame.height
        intHight = Int(tmphight / graph_minimunValue)
        hight = CGFloat((intHight + 1) * Int(graph_minimunValue))
        // xAxis creattion
        for i in 0...Int(intWidth + 2)
        {
            let xvalue =  (Int(graph_minimunValue) * i)
            xAxispath.move(to: CGPoint(x: xvalue, y: 0))
            xAxispath.addLine(to: CGPoint(x:xvalue, y: Int(hight)))
            xAxispath.close()
            
        }
        
        
        
        // yAxis creattion
        for i in 0...(intHight + 2)
        {
            if( i != 0)
            {
                let yvalue =  (Int(graph_minimunValue) * i)
                xAxispath.move(to: CGPoint(x: 0, y: yvalue))
                xAxispath.addLine(to: CGPoint(x:Int(width), y: yvalue))
                xAxispath.close()
            }
            
        }
        
        if(yAxisLayerSharae == nil)
        {
            
            yAxisLayerSharae = CAShapeLayer()
            
            yAxisLayerSharae.backgroundColor = UIColor.clear.cgColor
            yAxisLayerSharae.path = xAxispath.cgPath
            yAxisLayerSharae.fillColor = UIColor.clear.cgColor
            yAxisLayerSharae.strokeColor = UIColor.lightGray.cgColor
            yAxisLayerSharae.lineWidth = 1.0
            sender.layer.addSublayer(yAxisLayerSharae)
        }
        else
        {
            yAxisLayerSharae.path = xAxispath.cgPath
        }
        
        
        
    }
    
    
    @IBAction func graphMoodButtonAction(_ sender: UIButton)
    {
        self.DropDownDefaultfunction(sender, sender.bounds.width, ["1x","2x","3x","4x","10x","50x","100x"], self.orginalgraphXvalue, delegate: self, tag: 0)
        
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        
        if !(drowingView.isConfirmed)
        {
            drowingView.removeLastLine()
        }
    }
    
    @IBAction func clearAllButtonAction(_ sender: Any) {
        if !(drowingView.isConfirmed)
        {
            self.graphMode_Selection_Button.isUserInteractionEnabled = true
            
            drowingView.clearAllLine()
            self.tempAreaLabel.text = "Area: ?"
        }
    }
    
    @IBAction func confirmButton(_ sender: UIButton) {
        if(drowingView.isClosed)
        {
            drowingView.isConfirmed = true
            drowingView.drowShape(true)
        }
        else
        {
            //  self.alert("Please join your shape by connecting the starting point and ending point", nil)
            self.alert("Please connect all points to complete the measurement", nil)
        }
    }
    
    
    
    
    
    
    
    @IBAction func rectanglebuttonAction(_ sender: UIButton)
    {
        let masterData = self.getMasterDataFromDB()
        let maximumOpenings = masterData.max_no_transitions 
        if let openings = self.drowingView?.subSquareView,(openings.count >= maximumOpenings)
        {
            self.alert("You have added maximum number of transitions", nil)
        }
        else
        {
            let strings = openingsList.map { (opening) -> String in
                opening.name
            }
            self.DropDownDefaultfunction(sender, 200, strings, currentOpening, delegate: self, tag: 2)
            bottomLineViewTopConstraint.constant = 25
        }
        
       
        
        
       
//        self.rectangle_Button.borderColor = .white
//        self.rectangle_Button.borderWidth = 1
//        self.isVertical = true
//        self.rectangle_Button.borderWidth = 1
//        self.rectangle_Button.borderColor = UIColor.white
//        self.horisontalButton.borderColor = .clear
//        self.horisontalButton.borderWidth = 0
//        self.addViewHideORVisible(false)
        
    }
    func addViewHideORVisible(_ isHiddenView:Bool)
    {
        UIView.animate(withDuration: 0.3) {
            if(isHiddenView)
            {
                self.add_View_hight_Constrain.constant = 0
                self.rectangle_Button.borderColor = .clear
                self.rectangle_Button.borderWidth = 0
                self.addView.isHidden = true
            }
            else
            {
                self.add_View_hight_Constrain.constant = 330
                self.isVertical = true
                self.verticalButton.borderWidth = 1
                self.verticalButton.borderColor = self.openingsList[self.currentOpening].color
                self.horisontalButton.borderColor = .clear
                self.horisontalButton.borderWidth = 0
                self.addView_WidthTF.text = "1"
                self.addView_HeightTF.text = "0"
                self.addView.isHidden = false
            }
            self.addView.layoutIfNeeded()
        }
        
    }
    
    
    
    @IBAction func add_opens_orientation(_ sender: UIButton) {
        if(verticalButton == sender)
        {
            self.isVertical = true
            self.verticalButton.borderWidth = 1
            self.verticalButton.borderColor = self.openingsList[self.currentOpening].color
            self.horisontalButton.borderColor = .clear
            self.horisontalButton.borderWidth = 0
        }
        else
        {
            self.isVertical = false
            self.verticalButton.borderWidth = 0
            self.verticalButton.borderColor = UIColor.clear
            self.horisontalButton.borderColor = .white
            self.horisontalButton.borderWidth = 1
        }
    }
    
    @IBAction func add_View_addButtonAction(_ sender: Any) {
        
        
        if let value2 =  Float(self.addView_WidthTF.text ?? ""),currentOpening != -1
        {
            var addViewHeight = addView_HeightTF.text ?? "0"
           //addViewHeight = addViewHeight.replacingOccurrences(of: "\", with: "")
            if value2 == 0
            {
                self.alert("Please enter a valid value in width field.", nil)

            }
            if addView_HeightTF.text == ""
            {
                self.alert("Please enter a valid value in height field.", nil)
            }
            else
            {
                let hight = (!self.isVertical) ? 1 : CGFloat(value2 * 100) / 100
                let width = (!self.isVertical) ? CGFloat(value2 * 100) / 100 : 1
                
                addViewHideORVisible(true)
                drowingView.add_Sub_Square_View(xAsis: self.drowingView.buzierpath.bounds.maxX/2, yAxis: self.drowingView.buzierpath.bounds.maxY/2, width: width, hight: hight, delegate: self, isVertical: self.isVertical, objc: openingsList[currentOpening], addViewHeight: addViewHeight,transitionheightId: self.transitionHeightId)
                currentOpening = -1
                bottomLineViewTopConstraint.constant = 35
            }
        }
        else
        {
            self.alert("Please enter a correct width to continue", nil)
            
        }
        
        
        
    }
    
    
    
    
    
    func setSelectedSubSqureView(_ subView:SubSqureView)
    {
        if subView.custom_hight == 0.0
        {
            self.alert("Please enter a valid value in width field.", nil)
        }
        else
        {
            self.selected_View.isHidden = false
            self.selected_View_Constrain.constant = 350
            self.selectedOpening = subView
            // self.selected_squareView_Name_label.text = "Selected \(subView.object?.name ?? "")(\(subView.tag + 1))"
            self.selected_squareView_Name_label.text = "Selected \(subView.object?.name ?? "")"
            
            if !(subView.isVertical)
            {
                
                self.selected_vertical_Button.borderWidth = 1
                self.selected_vertical_Button.borderColor = UIColor.white
                self.selected_horizotal_Button.borderColor = .clear
                self.selected_horizotal_Button.borderWidth = 0
                self.seletced_SqureView_TF.text = String(format: "%.1f", subView.custom_width)//"\(subView.custom_width)"
                self.selected_SquareView_Height_TF.text = "\(subView.addViewHeight)" //addView_HeightTF.text
            }
            else
            {
                
                self.selected_vertical_Button.borderWidth = 0
                self.selected_vertical_Button.borderColor = UIColor.clear
                self.selected_horizotal_Button.borderColor = .white
                self.selected_horizotal_Button.borderWidth = 1
                self.seletced_SqureView_TF.text = String(format: "%.1f", subView.custom_hight)//"\(subView.custom_hight)"
                self.selected_SquareView_Height_TF.text = "\(subView.addViewHeight)" //addView_HeightTF.text
            }
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton)
    {
        if let view =  self.selectedOpening
        {
            drowingView.remove_Sub_Square_View(at: view.tag)
            no_Squre_View_In_Tool()
        }
    }
    
    //MARK:- Reset All
    func resetAllThing()
    {
        self.drowingView.clear_All_Sub_Square_View()
        self.drowingView.isConfirmed = false
        self.drowingView.isClosed = false
        self.graphMode_Selection_Button.isUserInteractionEnabled = true
        self.drowingView.clearAllLine()
        self.tempAreaLabel.text = "Area: ?"
        self.drowingView.removeAllPoints()
        self.drowingView.subSquareView = []
        self.scrollView.isHidden = true
        self.addViewHideORVisible(true)
        self.no_Squre_View_In_Tool()
        UIView.animate(withDuration: 0.2) {
            self.bottomToolView.isHidden = false
            self.bottomToolViewWidthConstrain.constant = 250
            self.view.layoutIfNeeded()
        }
    }
    
    
    func no_Squre_View_In_Tool()
    {
        self.selected_View.isHidden = true
        
        self.selected_View_Constrain.constant = 0
        self.selected_squareView_Name_label.text  = "No Selected Openings"
        self.seletced_SqureView_TF.text = ""
        self.selected_SquareView_Height_TF.text = ""
        self.selected_vertical_Button.borderWidth = 0
        self.selected_vertical_Button.borderColor = UIColor.clear
        self.selected_horizotal_Button.borderColor = .clear
        self.selected_horizotal_Button.borderWidth = 0
    }
    
    @IBAction func selectedVeritcalOrinationButtonAction(_ sender: UIButton) {
        if let view = self.selectedOpening
        {
            if !(view.isVertical)
            {
                view.changeOriantation(true)
                setSelectedSubSqureView(view)
            }
        }
    }
    @IBAction func selectedHorizontalOrinationButtonAction(_ sender: UIButton) {
        if let view = self.selectedOpening
        {
            if(view.isVertical)
            {
                view.changeOriantation(false)
                setSelectedSubSqureView(view)
            }
        }
    }
    @IBAction func HeightdropDownBtnClicked(_ sender: UIButton)
    {
        if transitionHeightvalue.count > 0
        {
            if sender.tag == 0
            {
                print("transition heights",transitionHeightvalue)
                self.DropDownDefaultfunction(sender, sender.bounds.width, transitionHeightvalue, 1, delegate: self, tag: 1)
            }
            else
            {
                print("transition heights",transitionHeightvalue)
                self.DropDownDefaultfunction(sender, sender.bounds.width, transitionHeightvalue, 1, delegate: self, tag: 3)
            }
        }
        else
        {
            self.alert("Not Available", nil)
        }
    }
    
    @IBAction func selectedViewpluseButtonAction(_ sender: UIButton) {
        if let view =  self.selectedOpening
        {
            if !(view.isVertical)
            {
                if(view.custom_width < 20)
                {
                    view.custom_hight = 1
                    view.custom_width += 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight < 20)
                {
                    view.custom_width = 1
                    view.custom_hight += 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_hight)"
                    view.custom_size_reload()
                }
            }
        }
    }
    
    @IBAction func selectedViewminusButtonAction(_ sender: UIButton) {
        if let view =  self.selectedOpening
        {
            if !(view.isVertical)
            {
                if(view.custom_width > 1.0)
                {
                    view.custom_hight = 1
                    view.custom_width -= 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight > 1.0)
                {
                    view.custom_width = 1
                    view.custom_hight -= 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_hight)"
                    view.custom_size_reload()
                }
            }
        }
        
    }
 
    
    
    func customViewDelegateResult(_ tag: Int) {
        
        setSelectedSubSqureView(self.drowingView.subSquareView[tag])
        self.drowingView.setSubSelectedView(at: tag)
        
        
    }
    
    
    func customeLabelDelegateResult(label: UILabel) {
        let value = self.respondeTag - 1
        isResponder = true
        if(value != (label.tag - 1))
        {
            if(value == -1 )
            {
                self.respondeTag = label.tag
                
                // self.side_TableView.reloadRows(at: [[0,self.respondeTag - 1]], with: .automatic)
            }
            else
            {
                self.respondeTag = label.tag
                //  self.side_TableView.reloadRows(at: [[0,value],[0,self.respondeTag - 1]], with: .automatic)
            }
        }
        
    }
    
    
    func LineViewArea_PerimeterResult(area:CGFloat,Perimeter:Float) {
        let a = Double(area)
        self.areaValue = CGFloat(a.rounded())
        self.perimeter =  Perimeter
        self.areaTF.text = "\(a.rounded().clean)"
        UIView.animate(withDuration: 0.2) {
            self.bottomToolView.isHidden = true
            self.bottomToolViewWidthConstrain.constant = 0
            self.scrollView.isHidden = false
            self.view.layoutIfNeeded()
        }
        
    }
    func LineDrawingStarted()
    {
        self.graphMode_Selection_Button.isUserInteractionEnabled = false
    }
    
    func LineViewTempAreaResult(area:CGFloat,isClosed:Bool,Perimeter:Float)
    {
        if(isClosed)
        {
            
            let a = Double(area)
            self.perimeter = Perimeter
            
            // self.areaValue = roundTheValue(CGFloat(area))
            //self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
            
            //  self.tempAreaLabel.text = "Area: \(area.toString) Sq.ft \(a.rounded().clean) Sq.ft"
            self.tempAreaLabel.text = "Area: \(a.rounded().clean) Sq.ft"
            //  self.tempAreaLabel.text = "Area: \(a.rounded(.awayFromZero).clean) Sq.ft"
        }
        else
        {
            self.tempAreaLabel.text = "Area: ?"
            
        }
    }
    
    
    
    
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        if tag == 1
       {
           addView_HeightTF.text = item
           //selected_SquareView_Height_TF.text = item
            let selectedValue = transitionHeightDropDownArray.filter({$0.name == item})
            transitionHeightId = selectedValue.first?.transitionHeightId ?? 0
       }
        else if tag == 3
        {
            selected_SquareView_Height_TF.text = item
            let selectedValue = transitionHeightDropDownArray.filter({$0.name == item})
            transitionHeightId = selectedValue.first?.transitionHeightId ?? 0
            let view =  self.selectedOpening
            view?.addViewHeight = item
        }
       else if tag != 2
        {
        switch index {
        case 0:
            minimumValue = 40
            self.graphMoodLabel.text = "1X"
        case 1:
            minimumValue = 30
            self.graphMoodLabel.text = "2X"
        case 2:
            minimumValue = 20
            self.graphMoodLabel.text = "3X"
        case 3:
            minimumValue = 10
            self.graphMoodLabel.text = "4X"
        case 4:
            minimumValue = 5
            self.graphMoodLabel.text = "10X"
        case 5:
            minimumValue = 1
            self.graphMoodLabel.text = "50X"
        case 6:
            minimumValue = 0.5
            self.graphMoodLabel.text = "100X"
        default:
            minimumValue = 40
            self.graphMoodLabel.text = "1X"
        }
        setgraphView(self.drowingContentView)
        if self.drowingView!.pointPath.count != 0
        {
        self.drowingView.drowShape(self.drowingView.isClosed)
        }
        }
         
        else
        {
            self.currentOpening = index
            //self.rectangle_Button.borderColor = openingsList[currentOpening].color
            //self.rectangle_Button.borderWidth = 1
            self.isVertical = true
            self.rectangle_Button.borderWidth = 1
            //self.rectangle_Button.borderColor = openingsList[currentOpening].color
            //self.horisontalButton.borderColor = .clear
            self.horisontalButton.borderWidth = 0
            self.addViewHideORVisible(false)
            self.view.bringSubviewToFront(addView)
        }
       }
    
    
    
    func messurementUpload()
    {
        var transArray:[TransitionData] = []
        if let openings = self.drowingView?.subSquareView,openings.count != 0
        {
            
            for opng in openings
            {
                if #available(iOS 14.0, *) {
                    print("item:\(opng.object?.name ?? "") color:\(opng.object?.color.accessibilityName ?? "") size: \(opng.getSize)")
                    let transData = TransitionData.init(name: opng.object?.name ?? "", color: opng.object?.color.accessibilityName ?? "", transsquarefeet: Float(opng.getSize),transHeight: opng.addViewHeight,transitionHeightId: opng.transitionHeightId)
                    transArray.append(transData)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        if let area  = Float(self.areaTF.text?.replacingOccurrences(of: ",", with: "") ?? "")
        {
            self.areaValue = CGFloat(area)
            var tempPerimeter = Double(self.perimeter).clean
            tempPerimeter = tempPerimeter.replacingOccurrences(of: ",", with: "")
            //arb
            //let appointment = getCompletedAppointmentsFromDB(appointmentId: appoinmentslData.id ?? 0)
            let customerId = appoinmentslData.customer_id ?? 0
            let appointmentId = appoinmentslData.id ?? 0
            let roomName = roomData.name ?? ""
            let roomType = roomName == "Stairs" ? "Stairs" : "Floor"
            let drawingImage = UIImage(view: self.drowingView)
            let imageNamewithDate = Date().toString()
            let drawingImageName = "Attachment_\(imageNamewithDate).JPG"
            let drawingImageSavedToFile = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: drawingImage, saveImgName: drawingImageName)
            let transDataArray = List<rf_transitionData>()
            transArray.forEach{ transData in
                transDataArray.append(rf_transitionData(transData: transData))
            }
            
//            let completedRoom:rf_completed_room = rf_completed_room()
//            completedRoom.room_id = self.roomData.id ?? 0
//            //completedRoom.ofAppointment = appointment
//            completedRoom.measurement_exist = "true"
//            completedRoom.customer_id = customerId
//            completedRoom.appointment_id = appointmentId
//            completedRoom.transArray = transDataArray
//            completedRoom.room_area = self.areaValue.toString
//            completedRoom.room_perimeter = Float(tempPerimeter) ?? 0
//            completedRoom.room_name = roomName
//            completedRoom.room_type = roomType
//            completedRoom.draw_image_name = drawingImageSavedToFile
            let (isRoomAlreadyExist,room) = self.checkIfRoomExist(appointmentId:appointmentId, roomId: self.roomData.id ?? 0)
            let isCustomRoomExists = self.checkIfCustomRoomExists(appointmentId: appointmentId, roomId: String(self.roomData.id ?? 0))
            var roomUniqueId = ""
            if isRoomAlreadyExist{
                roomUniqueId = room?.first?.id ?? ""
            }
            var partiallyCompletedRoomToUpdate:[String:Any] = ["room_id":self.roomData.id ?? 0,"measurement_exist":"true","customer_id":customerId,"appointment_id":appointmentId,"transArray":transDataArray,"room_area":self.areaValue.toString,"room_perimeter":Float(tempPerimeter) ?? 0,"room_name":roomName ,"room_type":roomType,"draw_image_name":drawingImageSavedToFile,"draw_area_adjusted":self.areaValue.toString]
            if roomUniqueId != ""{
                partiallyCompletedRoomToUpdate["id"] = roomUniqueId
            }
            if isCustomRoomExists
            {
                partiallyCompletedRoomToUpdate["is_custom_room"] = 1
                //partiallyCompletedRoomToUpdate["room_id"] = 0
            }
            //self.deleteRoomFromAppointment(appointmentId: appointmentId,roomId:self.roomData.id ?? 0)
            let next = AboutRoomViewController.initialization()!
            do{
                let realm = try Realm()
                try realm.write{
                    //////////////////
                    if let room = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)?.rooms.filter("room_id == %d", self.roomData.id ?? 0){
                        let room_attachments = room.first?.room_attachments
                        partiallyCompletedRoomToUpdate["room_attachments"] = room_attachments
                        
                    }
                   
                    realm.create(rf_completed_room.self, value: partiallyCompletedRoomToUpdate, update: .all)
                    
                    ////////////////////
                    
                    next.appoinmentID = self.appoinmentslData.id ?? 0
                    next.roomID = self.roomData.id ?? 0
                    next.roomName = self.roomData.name ?? ""
//                    next.drowingImageID = data ?? 0
                    next.area = self.areaValue
                    next.perimeter = Double(tempPerimeter)!
//                    //
//                    next.value = self.summaryData.attachment_comments ?? ""
//                    next.uploadedImage = self.summaryData.attachments ?? []
//                    next.summaryData = self.summaryData
//                    //
                    
                }
                self.deleteDiscountArrayFromDb() 
                self.navigationController?.pushViewController(next, animated: true)
            }
            catch{
                print(RealmError.writeFailed)
            }
            
            //save room details under appointment
            self.saveCreatedRoomToAppointment(appointmentId: appointmentId,roomId: self.roomData.id ?? 0)
            //
            
            //
//            HttpClientManager.SharedHM.MesurementSubmitMapFn(room_area: "\(self.areaValue.toString)",perimeter:Float(tempPerimeter) ?? 0, attachments: UIImage(view: self.drowingView), imagename: "messurementImage.jpeg", floor_id: "", room: self.roomData, appointment_id: "\(appoinmentslData.id ?? 0)",trasData:transArray) { (result, message, data, value) in
//
//                if(result == "Success")
//                {
//                    let next = AboutRoomViewController.initialization()!
//                    next.appoinmentID = self.appoinmentslData.id ?? 0
//                    next.roomID = self.roomData.id ?? 0
//                    next.roomName = self.roomData.name ?? ""
//                    next.drowingImageID = data ?? 0
//                    next.area = self.areaValue
//                    self.messurementID = data ?? 0
//                    if(value != nil)
//                    {
//                        self.summaryData = value![0]
//                        next.value = self.summaryData.attachment_comments ?? ""
//                        next.uploadedImage = self.summaryData.attachments ?? []
//                        next.summaryData = self.summaryData
//                    }
//                    self.navigationController?.pushViewController(next, animated: true)
//                }
//                else
//                {
//                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//
//                                        self.messurementUpload()
//                                    }
//                                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//                                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
//                    //self.alert(message ?? AppAlertMsg.serverNotReached, nil)
//                }
//
//            }
        }
        else
        {
            self.alert("Please enter correct value for area", nil)
        }
    }
    
    func DeleteroomMeasurement()
    {
        let data = ["contract_measurement_id":self.messurementID,"operation":"delete"] as [String : Any]
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        HttpClientManager.SharedHM.DeleteRoomMeasurement(parameter: parameter) { (result, errormessage, valuse) in
            if(result == "True")
            {
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                self.alert(errormessage ?? AppAlertMsg.serverNotReached, nil)
            }
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
class OpeningCustomObject:NSObject
{
     var name:String
    var color:UIColor
    init(name: String, color: UIColor) {
       self.name = name
       self.color = color
   }
}
extension CustomShapeLineViewController: ImagePickerDelegate {

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

