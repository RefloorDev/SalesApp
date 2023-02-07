//
//  L-ShapeViewController.swift
//  Refloor
//
//  Created by sbek on 13/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class L_Shape_ViewController: UIViewController,UIScrollViewDelegate,L_Shape_Custom_View_Tool_Delegete,CustomViewDelegate,L_Shape_Label_Delegate,L_Shape_CustomeView_Delegate,SubSqureToolDelegate {
    
    
    
    
    
    static func initialization() -> L_Shape_ViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "L_Shape_ViewController") as? L_Shape_ViewController
    }
    @IBOutlet weak var scrollView: UIScrollView!
    var path: UIBezierPath!
    
    @IBOutlet weak var toolBoxView: UIView!
    @IBOutlet weak var graphMood: UIButton!
    var yAxisLayerSharae:CAShapeLayer!
    var xAxisLayerSharae:CAShapeLayer!
    var roomData:RoomDataValue!
    var floorShapeData:FloorShapeDataValue!
    var floorLevelData:FloorLevelDataValue!
    var appoinmentslData:AppoinmentDataValue!
    var orginalgraphXvalue = 0
    var intWidth:CGFloat = 0
    var width:CGFloat = 0
    var intHight:Int = 0
    var hight:CGFloat = 0
    var selectedPostion = 0
    var areaSquareFt = 0
    var subViewArray:[CustomView] = []
    var selectedSubView = -1
    @IBOutlet weak var drowingView: UIView!
    var l_ShapeView:L_Shape_CustomView!
    var layerSharae:CAShapeLayer!
    var toolView:SubSqureToolView? = nil
    var name = ""
    var L_shape_1_Rectangle_width:CGFloat = 5
    var L_shape_1_Rectangle_hight:CGFloat = 10
    var L_shape_2_Rectangle_width:CGFloat = 10
    var L_shape_2_Rectangle_hight:CGFloat = 5
    var L_shpae_2_Rectangle_start_y_value = 0
    var isFlip = true
    var graph_minimunValue = minimumValue
    var l_shape_tool_box:L_Shape_CustomView_ToolBoxView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbacklogoAndNext(name: "")
        scrollView.delegate = self
        scrollView.contentMode = .scaleAspectFit
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        
        //   l_ShapeView.label_Delegate = self
        l_ShapeView = L_Shape_CustomView(frame: CGRect(x: 300, y: 300, width: 10, height: 10))
        l_ShapeView.setSides(L_shape_1_Rectangle_width, L_shape_1_Rectangle_hight, L_shape_2_Rectangle_width, L_shape_2_Rectangle_hight, name, isFlip)
        let cgrect =  CGRect(x: 0, y: 0, width: 300, height: self.toolBoxView.bounds.height)
        l_shape_tool_box = L_Shape_CustomView_ToolBoxView(frame: cgrect, side1Value: L_shape_1_Rectangle_width, side2Value: L_shape_1_Rectangle_hight, side3Value: L_shape_2_Rectangle_width, side4Value: L_shape_2_Rectangle_hight, delegate: self)
        self.setgraphView(self.drowingView)
        self.drowingView.addSubview(l_ShapeView)
        
        self.toolBoxView.addSubview(l_shape_tool_box)
        self.l_ShapeView.label_Delegate = self
        self.l_ShapeView.delegete = self
        l_shape_tool_box.areaLabel.text = "Area of shape: \(l_ShapeView.getArea()) sq.ft"
        l_shape_tool_box.subSqureDelegate = self
        // Do any additional setup after loading the view.
    }
    func setgraphForMoodView(_ sender :UIView)
    {
        var graphValue = minimumValue
        if(graphValue == 30)
        {
            graphValue *= 2
            self.graphMood.setTitle("2x", for: .normal)
            self.graphMood.tag = 1
            
        }
        else if(graphValue == 20)
        {
            graphValue *= 3
            self.graphMood.setTitle("3x", for: .normal)
            self.graphMood.tag = 2
            
        }
        else if(graphValue == 10)
        {
            graphValue *= 4
            self.graphMood.setTitle("4x", for: .normal)
            self.graphMood.tag = 3
            
        }
        else if(graphValue == 5)
        {
            graphValue *= 10
            self.graphMood.setTitle("10x", for: .normal)
            self.graphMood.tag = 4
            
        }
        else if graphValue == 1
        {
            graphValue *= 50
            self.graphMood.setTitle("50x", for: .normal)
            self.graphMood.tag = 5
            
        }
        else if graphValue != 40
        {
            graphValue *= 100
            self.graphMood.setTitle("100x", for: .normal)
            self.graphMood.tag = 6
            
        }
        else
        {
            self.graphMood.setTitle("1x", for: .normal)
            self.graphMood.tag = 0
            
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
            self.graphMood.setTitle("2x", for: .normal)
            self.graphMood.tag = 1
            orginalgraphXvalue = 1
        }
        else if(graph_minimunValue == 20)
        {
            graph_minimunValue *= 3
            self.graphMood.setTitle("3x", for: .normal)
            self.graphMood.tag = 2
            orginalgraphXvalue = 2
        }
        else if(graph_minimunValue == 10)
        {
            graph_minimunValue *= 4
            self.graphMood.setTitle("4x", for: .normal)
            self.graphMood.tag = 3
            orginalgraphXvalue = 3
        }
        else if(graph_minimunValue == 5)
        {
            graph_minimunValue *= 10
            self.graphMood.setTitle("10x", for: .normal)
            self.graphMood.tag = 4
            orginalgraphXvalue = 4
        }
        else if graph_minimunValue == 1
        {
            graph_minimunValue *= 50
            self.graphMood.setTitle("50x", for: .normal)
            self.graphMood.tag = 5
            orginalgraphXvalue = 5
        }
        else if graph_minimunValue != 40
        {
            graph_minimunValue *= 100
            self.graphMood.setTitle("100x", for: .normal)
            self.graphMood.tag = 6
            orginalgraphXvalue = 6
        }
        else
        {
            self.graphMood.setTitle("1x", for: .normal)
            self.graphMood.tag = 0
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
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drowingView
    }
    
    
    
    func add_a_View_to_subView_Result(width: CGFloat, isVertical: Bool, item_tag: Int, error: String?) {
        if(error != nil)
        {
            self.alert(error!, nil)
            return
        }
        
        self.l_ShapeView.add_Sub_Square_View(xAsis: self.l_ShapeView.center.x, yAxis: self.l_ShapeView.center.y, width: width, hight: 3, delegate: self, isVertical: isVertical)
        
    }
    
    func flip_L_shape_View() {
        self.isFlip = !self.isFlip
        l_ShapeView.setSides(L_shape_1_Rectangle_width, L_shape_1_Rectangle_hight, L_shape_2_Rectangle_width, L_shape_2_Rectangle_hight, name, isFlip)
    }
    
    func side_1_update_Value(value: CGFloat, error: String?) {
        if(error != nil)
        {
            self.alert(error!, nil)
            return
        }
        L_shape_1_Rectangle_width = value
        self.l_ShapeView.set_side1_width(L_shape_1_Rectangle_width)
    }
    
    func side_2_update_Value(value: CGFloat, error: String?) {
        if(error != nil)
        {
            self.alert(error!, nil)
            return
        }
        L_shape_1_Rectangle_hight = value
        self.l_ShapeView.set_side1_height(L_shape_1_Rectangle_hight)
    }
    
    func side_3_update_Value(value: CGFloat, error: String?) {
        if(error != nil)
        {
            self.alert(error!, nil)
            return
        }
        self.L_shape_2_Rectangle_width = value
        self.l_ShapeView.set_side2_width(L_shape_2_Rectangle_width)
    }
    
    func side_4_update_Value(value: CGFloat, error: String?) {
        if(error != nil)
        {
            self.alert(error!, nil)
            return
        }
        self.L_shape_2_Rectangle_hight = value
        self.l_ShapeView.set_side2_height(L_shape_2_Rectangle_hight)
    }
    
    func side_5_update_Value(value: CGFloat, error: String?) {
        if(error != nil)
        {
            self.alert(error!, nil)
            return
        }
        self.L_shape_2_Rectangle_hight = value
        self.l_ShapeView.set_side2_height(L_shape_2_Rectangle_hight)
    }
    func side_6_update_Value(value: CGFloat, error: String?) {
        if(error != nil)
        {
            self.alert(error!, nil)
            return
        }
        self.L_shape_2_Rectangle_width = value
        self.l_ShapeView.set_side2_width(L_shape_2_Rectangle_width)
    }
    func customViewDelegateResult(_ tag: Int) {
        if(self.l_ShapeView.subSquareView.count != tag)
        {
            self.l_ShapeView.setSubSelectedView(at: tag)
            self.l_shape_tool_box.setSelectedSubSqureView(self.l_ShapeView.subSquareView[tag])
        }
        
    }
    func L_Shape_Label_Tap_Result(label: UILabel, value: String, tag: Int) {
        if(tag == l_ShapeView.l_1_width_label_tag)
        {
            self.l_shape_tool_box.side1responder()
        }
        else if(tag == l_ShapeView.l_1_hight_label_tag)
        {
            self.l_shape_tool_box.side2responder()
        }
        else if(tag == l_ShapeView.l_2_width_label_tag)
        {
            self.l_shape_tool_box.side3responder()
        }
        else if(tag == l_ShapeView.l_2_hight_label_tag)
        {
            self.l_shape_tool_box.side4responder()
        }
        else if(tag == l_ShapeView.l_2_hight_label_tag)
        {
            self.l_shape_tool_box.side4responder()
        }
        else if(tag == l_ShapeView.l_1_2_hight_label_tag)
        {
            self.l_shape_tool_box.side6responder()
        }
        else if(tag == l_ShapeView.l_1_2_width_label_tag)
        {
            self.l_shape_tool_box.side5responder()
        }
    }
    func areaChnaged(_ area: CGFloat) {
        if(l_shape_tool_box != nil)
        {
            l_shape_tool_box.areaLabel.text = "Area of shape: \(area) sq.ft"
        }
        if(graph_minimunValue != minimumValue)
        {
            self.setgraphView(self.drowingView)
        }
    }
    
    
    func SubSqureViewDidDeleteView(_ int: Int) {
        self.l_ShapeView.remove_Sub_Square_View(at: int)
    }
    
    func SubSqureViewDidCloseToolview() {
        self.toolView = nil
    }
    
    func SubSqureViewDidChangeSize(size: CGSize) {
        
    }
    
    func side_responder(for side: Int) {
        self.l_ShapeView.setresponderfor(tag: side)
    }
    
    
    override func nextAction() {
        //        let next = TransactionViewController.initialization()!
        //        next.appoinmentslData = self.appoinmentslData
        //        next.floorLevelData = self.floorLevelData
        //        next.roomData = self.roomData
        //       
        //        next.area = Float(self.l_ShapeView.getArea())
        //        self.navigationController?.pushViewController(next, animated: true)
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
