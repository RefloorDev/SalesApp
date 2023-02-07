//
//  CustomeShapeViewController.swift
//  Refloor
//
//  Created by sbek on 12/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class CustomeShapeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CustomViewDelegate,NineZeroDrowingViewDelegate,DropDownDelegate {
    
    
    static func initialization() -> CustomeShapeViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CustomeShapeViewController") as? CustomeShapeViewController
    }
    
    
    @IBOutlet weak var drowingScrollView: UIScrollView!
    @IBOutlet weak var drowingContentView: UIView!
    @IBOutlet weak var bottomToolView: UIView!
    @IBOutlet weak var bottomToolViewHightConstrain: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var side_TableView: UITableView!
    @IBOutlet weak var side_tableView_Hight_Constrain: NSLayoutConstraint!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var areaTF: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rectangle_Button: UIButton!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var horisontalButton: UIButton!
    @IBOutlet weak var verticalButton: UIButton!
    @IBOutlet weak var addView_WidthTF: UITextField!
    @IBOutlet weak var add_Button: UIButton!
    @IBOutlet weak var add_View_hight_Constrain: NSLayoutConstraint!
    @IBOutlet weak var selected_squareView_Name_label: UILabel!
    @IBOutlet weak var selected_horizotal_Button: UIButton!
    @IBOutlet weak var selected_vertical_Button: UIButton!
    @IBOutlet weak var seletced_SqureView_TF: UITextField!
    @IBOutlet weak var selected_View_Constrain: NSLayoutConstraint!
    @IBOutlet weak var selected_View: UIView!
    var isResponder = false
    var drowingView:NineZeroDrowingView!
    var labels:[UILabel] = []
    var respondeTag = -1
    var isVertical = true
    var areaValue:CGFloat = 0
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
    
    var floorLevelData:FloorLevelDataValue!
    var appoinmentslData:AppoinmentDataValue!
    var path: UIBezierPath!
    var graph_minimunValue = minimumValue
    override func viewDidLoad() {
        super.viewDidLoad()
        minimumValue = 40
        self.setNavigationBarbacklogoAndNext(name: "")
        drowingView = NineZeroDrowingView(frame: CGRect(x: 0, y: 0, width: 1500, height: 1500))
        drowingView.delegate = self
        drowingView.backgroundColor = .clear
        self.setgraphView(self.drowingContentView)
        self.drowingContentView.addSubview(self.drowingView)
        self.drowingScrollView.isScrollEnabled = false
        self.scrollView.isHidden = true
        addViewHideORVisible(true)
        no_Squre_View_In_Tool()
        // Do any additional setup after loading the view.
    }
    @IBAction func areaTFDidEndAction(_ sender: UITextField) {
        if let value2 =  Float(sender.text ?? "")
        {
            self.areaValue = CGFloat(value2)
            self.areaTF.text = "\(areaValue)"
        }
    }
    @IBAction func AreaTFDidBegen(_ sender: UITextField) {
    }
    @IBAction func areaMinusButtonAction(_ sender: UIButton) {
        areaValue -= 1
        self.areaTF.text = "\(areaValue)"
    }
    @IBAction func areaPluseButtonAction(_ sender: UIButton) {
        areaValue += 1
        self.areaTF.text = "\(areaValue)"
    }
    
    override func nextAction() {
        if(self.drowingView.isConfirmed)
        {
            //            let next = TransactionViewController.initialization()!
            //            next.appoinmentID = self.appoinmentslData.
            //            next.floorLevelData = self.floorLevelData
            //            next.roomData = self.roomData
            //
            //            next.area = Float(self.areaValue)
            //            self.navigationController?.pushViewController(next, animated: true)
        }
        else
        {
            self.alert("Please confirm your shape", nil)
        }
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
        for i in 0...Int(intWidth)
        {
            let xvalue =  (Int(graphValue) * i)
            xAxispath.move(to: CGPoint(x: xvalue, y: 0))
            xAxispath.addLine(to: CGPoint(x:xvalue, y: Int(hight)))
            xAxispath.close()
            
        }
        
        
        
        // yAxis creattion
        for i in 0...(intHight - 1)
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
        let tmpwidth = sender.frame.width
        intWidth = tmpwidth / minimumValue
        width = ((intWidth ) * graph_minimunValue) + graph_minimunValue
        
        let tmphight = sender.frame.height
        intHight = Int(tmphight / graph_minimunValue)
        hight = CGFloat((intHight - 1) * Int(graph_minimunValue))
        // xAxis creattion
        for i in 0...Int(intWidth)
        {
            let xvalue =  (Int(graph_minimunValue) * i)
            xAxispath.move(to: CGPoint(x: xvalue, y: 0))
            xAxispath.addLine(to: CGPoint(x:xvalue, y: Int(hight)))
            xAxispath.close()
            
        }
        
        
        
        // yAxis creattion
        for i in 0...(intHight - 1)
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
    
    
    @IBAction func graphMoodButtonAction(_ sender: UIButton) {
        self.DropDownDefaultfunction(sender, 100, ["1x","2x","3x","4x","5x","10x","50x","100x"], self.orginalgraphXvalue, delegate: self, tag: 0)
        
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
            drowingView.clearAllLine()
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
            self.alert("Please connect all points to complete the measurement", nil)
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomeShapeSideViewCell") as! CustomeShapeSideViewCell
        cell.side_TF_Label.text = "SIDE \(indexPath.row + 1) in ft"
        cell.side_TF.text = labels[indexPath.row].text
        cell.side_TF.tag = indexPath.row
        cell.side_minus_Button.tag = indexPath.row
        cell.side_pluse_Button.tag = indexPath.row
        if(respondeTag ==  labels[indexPath.row].tag && isResponder)
        {
            
            cell.side_TF.borderColor = UIColor.red
            cell.side_TF.borderWidth = 1
            cell.side_TF.becomeFirstResponder()
            cell.side_TF_Label.textColor = UIColor.red
        }
        else
        {
            cell.side_TF.borderColor = UIColor.white
            cell.side_TF.borderWidth = 1
            cell.side_TF_Label.textColor = UIColor.white
        }
        return cell
    }
    
    
    @IBAction func rectanglebuttonAction(_ sender: Any) {
        self.rectangle_Button.borderColor = .white
        self.rectangle_Button.borderWidth = 1
        self.isVertical = true
        self.rectangle_Button.borderWidth = 1
        self.rectangle_Button.borderColor = UIColor.white
        self.horisontalButton.borderColor = .clear
        self.horisontalButton.borderWidth = 0
        self.addViewHideORVisible(false)
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
                self.add_View_hight_Constrain.constant = 160
                self.addView_WidthTF.text = "1"
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
            self.verticalButton.borderColor = UIColor.white
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
        
        
        if let value2 =  Float(self.addView_WidthTF.text ?? "")
        {
            addViewHideORVisible(true)
            drowingView.add_Sub_Square_View(xAsis: self.drowingView.buzierpath.bounds.maxX/2, yAxis: self.drowingView.buzierpath.bounds.maxY/2, width: CGFloat(value2), hight: 1, delegate: self, isVertical: self.isVertical)
            
        }
        else
        {
            self.alert("Please enter a valid width to continue", nil)
            
        }
        
        
        
    }
    @IBAction func sideTextFieldDidBegen(_ sender: UITextField) {
        let value = self.respondeTag
        isResponder = false
        if(value != (sender.tag + 1))
        {
            if(value == -1)
            {
                self.respondeTag = sender.tag + 1
                self.side_TableView.reloadRows(at: [[0,self.respondeTag - 1]], with: .automatic)
            }
            else
            {
                self.respondeTag = sender.tag + 1
                self.side_TableView.reloadRows(at: [[0,value - 1],[0,self.respondeTag - 1]], with: .automatic)
            }
        }
        
    }
    @IBAction func sideTextFiledDidFinish(_ sender: UITextField) {
        
        if let cell = self.side_TableView.cellForRow(at: [0,sender.tag]) as? CustomeShapeSideViewCell
        {
            if let value = Float(cell.side_TF.text ?? "0")
            {
                if let oldValue = Float(self.labels[sender.tag].text ?? "0")
                {
                    if value != oldValue
                    {
                        self.drowingView.editValue(labels[sender.tag].tag, value: CGFloat(value) * minimumValue, oldValue: CGFloat(oldValue) * minimumValue)
                    }
                }
            }
        }
        
    }
    
    
    
    @IBAction func sidePluseButtonAction(_ sender: UIButton) {
        if let cell = self.side_TableView.cellForRow(at: [0,sender.tag]) as? CustomeShapeSideViewCell
        {
            if let value = Float(cell.side_TF.text ?? "0")
            {
                let newValue = value + 1
                self.drowingView.editValue(labels[sender.tag].tag, value: CGFloat(newValue) * minimumValue, oldValue: CGFloat(value) * minimumValue)
            }
        }
    }
    @IBAction func sideMinusButtonAction(_ sender: UIButton) {
        if let cell = self.side_TableView.cellForRow(at: [0,sender.tag]) as? CustomeShapeSideViewCell
        {
            if let value = Float(cell.side_TF.text ?? "0")
            {
                let newValue = value - 1
                if(newValue > 0)
                {
                    self.drowingView.editValue(labels[sender.tag].tag, value: CGFloat(newValue) * minimumValue, oldValue: CGFloat(value) * minimumValue)
                }
            }
        }
    }
    
    func setSelectedSubSqureView(_ subView:SubSqureView)
    {
        self.selected_View.isHidden = false
        self.selected_View_Constrain.constant = 250
        self.selectedOpening = subView
        self.selected_squareView_Name_label.text = "Selected Openings \(subView.tag + 1)"
        
        if(subView.isVertical)
        {
            
            self.selected_vertical_Button.borderWidth = 1
            self.selected_vertical_Button.borderColor = UIColor.white
            self.selected_horizotal_Button.borderColor = .clear
            self.selected_horizotal_Button.borderWidth = 0
            self.seletced_SqureView_TF.text = "\(subView.custom_width)"
        }
        else
        {
            
            self.selected_vertical_Button.borderWidth = 0
            self.selected_vertical_Button.borderColor = UIColor.clear
            self.selected_horizotal_Button.borderColor = .white
            self.selected_horizotal_Button.borderWidth = 1
            self.seletced_SqureView_TF.text = "\(subView.custom_hight)"
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
    
    
    func no_Squre_View_In_Tool()
    {
        self.selected_View.isHidden = true
        self.selected_View_Constrain.constant = 0
        self.selected_squareView_Name_label.text  = "No Selected Openings"
        self.seletced_SqureView_TF.text = ""
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
    
    @IBAction func selectedViewpluseButtonAction(_ sender: UIButton) {
        if let view =  self.selectedOpening
        {
            if !(view.isVertical)
            {
                if(view.custom_width < 10)
                {
                    view.custom_width += 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight < 10)
                {
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
                    view.custom_width -= 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight > 1.0)
                {
                    view.custom_hight -= 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_hight)"
                    view.custom_size_reload()
                }
            }
        }
        
    }
    
    func customViewDelegateResult(_ tag: Int) {
        setSelectedSubSqureView(self.drowingView.subSquareView[tag])
    }
    
    
    func customeLabelDelegateResult(label: UILabel) {
        let value = self.respondeTag - 1
        isResponder = true
        if(value != (label.tag - 1))
        {
            if(value == -1 )
            {
                self.respondeTag = label.tag
                
                self.side_TableView.reloadRows(at: [[0,self.respondeTag - 1]], with: .automatic)
            }
            else
            {
                self.respondeTag = label.tag
                self.side_TableView.reloadRows(at: [[0,value],[0,self.respondeTag - 1]], with: .automatic)
            }
        }
        
    }
    
    func changesDoneinDrowingView(area: CGFloat, isClosed: Bool, labels: [UILabel]) {
        UIView.animate(withDuration: 0.3) {
            self.areaValue = area
            self.areaTF.text = "\(area)"
            var tempLabels:[UILabel] = []
            var i = 0
            for label in labels
            {
                if(i != 0)
                {
                    tempLabels.append(label)
                }
                i += 1
            }
            tempLabels.append(labels[0])
            self.labels = tempLabels
            self.side_tableView_Hight_Constrain.constant = 45 * CGFloat(labels.count)
            self.scrollView.isHidden = !isClosed
            if(isClosed)
            {
                self.bottomToolView.isHidden = true
                self.side_TableView.reloadData()
                self.bottomToolViewHightConstrain.constant = 0
            }
            
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    
    
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        switch index {
        case 0:
            minimumValue = 40
        case 1:
            minimumValue = 30
        case 2:
            minimumValue = 20
        case 3:
            minimumValue = 10
        case 4:
            minimumValue = 5
        case 5:
            minimumValue = 1
        case 6:
            minimumValue = 0.5
        default:
            minimumValue = 40
        }
        setgraphView(self.drowingContentView)
        if self.drowingView!.pointPath.count != 0
        {
            self.drowingView.drowShape(self.drowingView.isClosed)
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

class CustomeShapeSideViewCell:UITableViewCell
{
    @IBOutlet weak var side_TF_Label: UILabel!
    @IBOutlet weak var side_TF: UITextField!
    @IBOutlet weak var side_pluse_Button: UIButton!
    @IBOutlet weak var side_minus_Button: UIButton!
}
