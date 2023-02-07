//
//  L_Shape_CustomView_ToolBoxView.swift
//  Refloor
//
//  Created by sbek on 15/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

protocol L_Shape_Custom_View_Tool_Delegete {
    func add_a_View_to_subView_Result(width:CGFloat,isVertical:Bool,item_tag:Int,error:String?)
    func flip_L_shape_View()
    func side_1_update_Value(value:CGFloat,error:String?)
    func side_2_update_Value(value:CGFloat,error:String?)
    func side_3_update_Value(value:CGFloat,error:String?)
    func side_4_update_Value(value:CGFloat,error:String?)
    func side_5_update_Value(value:CGFloat,error:String?)
    func side_6_update_Value(value:CGFloat,error:String?)
    func side_responder(for side:Int)
}
class responderTFObjcet:NSObject
{
    var textFiled:UITextField!
    var label:UILabel!
    init(textFiled:UITextField,label:UILabel) {
        self.textFiled = textFiled
        self.label = label
    }
}

class L_Shape_CustomView_ToolBoxView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var wallColorButton: UIButton!
    @IBOutlet weak var wallWidthTF: UITextField!
    @IBOutlet weak var wallWidth_AR_Button: UIButton!
    @IBOutlet weak var side_1_TF: UITextField!
    @IBOutlet weak var side_1_pluse_Button: UIButton!
    @IBOutlet weak var side_1_minus_Button: UIButton!
    @IBOutlet weak var side_2_TF: UITextField!
    @IBOutlet weak var side_2_pluse_Button: UIButton!
    @IBOutlet weak var side_2_minus_Button: UIButton!
    @IBOutlet weak var side_3_TF: UITextField!
    @IBOutlet weak var side_3_pluse_Button: UIButton!
    @IBOutlet weak var side_3_minus_Button: UIButton!
    @IBOutlet weak var side_4_TF: UITextField!
    @IBOutlet weak var side_4_pluse_Button: UIButton!
    @IBOutlet weak var side_4_minus_Button: UIButton!
    @IBOutlet weak var side_5_TF: UITextField!
    @IBOutlet weak var side_5_pluse_Button: UIButton!
    @IBOutlet weak var side_5_minus_Button: UIButton!
    @IBOutlet weak var side_6_TF: UITextField!
    @IBOutlet weak var side_6_pluse_Button: UIButton!
    @IBOutlet weak var side_6_minus_Button: UIButton!
    @IBOutlet weak var table_Button: UIButton!
    @IBOutlet weak var chair_Button: UIButton!
    @IBOutlet weak var rectangle_Button: UIButton!
    @IBOutlet weak var vertical_Button: UIButton!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var horisontalButton: UIButton!
    @IBOutlet weak var addView_WidthTF: UITextField!
    @IBOutlet weak var add_Button: UIButton!
    @IBOutlet weak var add_View_hight_Constrain: NSLayoutConstraint!
    @IBOutlet weak var side_1_TF_Label: UILabel!
    @IBOutlet weak var side_2_TF_Label: UILabel!
    @IBOutlet weak var side_3_TF_Label: UILabel!
    @IBOutlet weak var side_4_TF_Label: UILabel!
    @IBOutlet weak var side_5_TF_Label: UILabel!
    @IBOutlet weak var side_6_TF_Label: UILabel!
    @IBOutlet weak var selected_squareView_Name_label: UILabel!
    @IBOutlet weak var selected_horizotal_Button: UIButton!
    @IBOutlet weak var selected_vertical_Button: UIButton!
    @IBOutlet weak var seletced_SqureView_TF: UITextField!
    @IBOutlet weak var selected_View_Constrain: NSLayoutConstraint!
    @IBOutlet weak var selected_View: UIView!
    
    
    var  subSqureDelegate:SubSqureToolDelegate?
    var isVertical = true
    var view:UIView!
    var delegate:L_Shape_Custom_View_Tool_Delegete?
    var selectedOpening:SubSqureView?
    var responderArray:[responderTFObjcet] = []
    @IBOutlet weak var areaLabel: UILabel!
    init(frame:CGRect,side1Value:CGFloat,side2Value:CGFloat,side3Value:CGFloat,side4Value:CGFloat,delegate:L_Shape_Custom_View_Tool_Delegete ) {
        super.init(frame: frame)
        setup()
        self.delegate = delegate
        self.side_1_TF.text = "\(side1Value)"
        self.side_2_TF.text = "\(side2Value)"
        self.side_3_TF.text = "\(side3Value)"
        self.side_4_TF.text = "\(side4Value)"
        self.side_5_TF.text = "\(side1Value + side3Value)"
        self.side_6_TF.text = "\(side2Value + side4Value)"
        self.side_1_TF.tag = 1
        self.side_2_TF.tag = 2
        self.side_3_TF.tag = 3
        self.side_4_TF.tag = 4
        self.side_5_TF.tag = 5
        self.side_6_TF.tag = 6
        self.selected_View.isHidden = true
        self.selected_View_Constrain.constant = 0
        self.side_1_TF.backgroundColor = .clear
        self.side_2_TF.backgroundColor = .clear
        self.side_3_TF.backgroundColor = .clear
        self.side_4_TF.backgroundColor = .clear
        self.side_5_TF.backgroundColor = .clear
        self.side_6_TF.backgroundColor = .clear
        self.seletced_SqureView_TF.backgroundColor = .clear
        self.addView_WidthTF.backgroundColor = .clear
        self.responderArray = [responderTFObjcet(textFiled: side_1_TF, label: side_1_TF_Label),responderTFObjcet(textFiled: side_2_TF, label: side_2_TF_Label),responderTFObjcet(textFiled: side_3_TF, label: side_3_TF_Label),responderTFObjcet(textFiled: side_4_TF, label: side_4_TF_Label),responderTFObjcet(textFiled: side_5_TF, label: side_5_TF_Label),responderTFObjcet(textFiled: side_6_TF, label: side_6_TF_Label)]
        self.addViewHideORVisible(true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        //custom logic goes here
    }
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        // view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        self.bringSubviewToFront(contentView)
        
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "L_Shape_CustomView_ToolBoxView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    @IBAction func add_opens_orientation(_ sender: UIButton) {
        if(vertical_Button == sender)
        {
            self.isVertical = true
            self.vertical_Button.borderWidth = 1
            self.vertical_Button.borderColor = UIColor.white
            self.horisontalButton.borderColor = .clear
            self.horisontalButton.borderWidth = 0
        }
        else
        {
            self.isVertical = false
            self.vertical_Button.borderWidth = 0
            self.vertical_Button.borderColor = UIColor.clear
            self.horisontalButton.borderColor = .white
            self.horisontalButton.borderWidth = 1
        }
    }
    
    func addViewHideORVisible(_ isHiddenView:Bool)
    {
        UIView.animate(withDuration: 0.3) {
            if(isHiddenView)
            {
                self.add_View_hight_Constrain.constant = 0
                self.rectangle_Button.borderColor = .clear
                self.rectangle_Button.borderWidth = 0
                self.table_Button.borderColor = .clear
                self.table_Button.borderWidth = 0
                self.chair_Button.borderColor = .clear
                self.chair_Button.borderWidth = 0
                self.addView.isHidden = true
            }
            else
            {
                self.add_View_hight_Constrain.constant = 160
                self.addView_WidthTF.text = "3"
                self.addView.isHidden = false
            }
            self.addView.layoutIfNeeded()
        }
        
    }
    @IBAction func add_View_addButtonAction(_ sender: Any) {
        
        
        if let value2 =  Float(self.addView_WidthTF.text ?? "")
        {
            addViewHideORVisible(true)
            delegate?.add_a_View_to_subView_Result(width: CGFloat(value2), isVertical: self.isVertical, item_tag: 0, error: nil)
        }
        else
        {
            delegate?.add_a_View_to_subView_Result(width: 0, isVertical: self.isVertical, item_tag: 0, error: "Please enter a valid width to continue")
        }
        
        
        
    }
    
    @IBAction func rectanglebuttonAction(_ sender: Any) {
        self.table_Button.borderColor = .white
        self.table_Button.borderWidth = 1
        self.isVertical = true
        self.vertical_Button.borderWidth = 1
        self.vertical_Button.borderColor = UIColor.white
        self.horisontalButton.borderColor = .clear
        self.horisontalButton.borderWidth = 0
        self.addViewHideORVisible(false)
    }
    
    @IBAction func flipButtonAction(_ sender: Any) {
        delegate?.flip_L_shape_View()
    }
    
    @IBAction func side1TextFieldDidBegen(_ sender: UITextField) {
        self.setresponderfor(textFiled: sender)
    }
    @IBAction func side2TextFieldDidBegen(_ sender: UITextField) {
        self.setresponderfor(textFiled: sender)
    }
    @IBAction func side3TextFieldDidBegen(_ sender: UITextField) {
        self.setresponderfor(textFiled: sender)
    }
    @IBAction func side4TextFieldDidBegen(_ sender: UITextField) {
        self.setresponderfor(textFiled: sender)
    }
    
    
    @IBAction func side5TextFieldDidBegen(_ sender: UITextField) {
        self.setresponderfor(textFiled: sender)
    }
    
    
    @IBAction func side6TextFieldDidBegen(_ sender: UITextField) {
        self.setresponderfor(textFiled: sender)
    }
    
    func setresponderfor(textFiled:UITextField)
    {
        for responder in responderArray
        {
            if(responder.textFiled == textFiled)
            {
                self.delegate?.side_responder(for: textFiled.tag)
                responder.textFiled.borderColor = UIColor().colorFromHexString("#292562")
                responder.textFiled.borderWidth = 1
                responder.textFiled.becomeFirstResponder()
                responder.label.textColor = UIColor().colorFromHexString("#292562")
            }
            else
            {
                responder.textFiled.borderColor = UIColor.white
                responder.textFiled.borderWidth = 1
                responder.label.textColor = UIColor.white
            }
        }
    }
    
    
    
    
    @IBAction func sidePluseButtonAction(_ sender: UIButton) {
        if(sender == side_1_pluse_Button)
        {
            if let value = Float(side_1_TF.text ?? "")
            { if let secondValue = Float(side_3_TF.text ?? "")
            {
                let newvalue = value + 1
                self.side_5_TF.text = "\(newvalue + secondValue)"
                self.side_1_TF.text = "\(newvalue)"
                delegate?.side_1_update_Value(value: CGFloat(newvalue), error: nil)
            }
            else
            {
                delegate?.side_1_update_Value(value:0, error: "Please enter a valid value for side 3")
            }
            }
            else
            {
                delegate?.side_1_update_Value(value:0, error: "Please enter a valid value for side 1")
            }
        }
        else if(sender == side_2_pluse_Button)
        {
            if let value = Float(side_2_TF.text ?? "")
            { if let secondValue = Float(side_4_TF.text ?? "")
            {
                let newvalue = value + 1
                self.side_6_TF.text = "\(newvalue + secondValue)"
                self.side_2_TF.text = "\(newvalue)"
                delegate?.side_2_update_Value(value: CGFloat(newvalue), error: nil)
            }
            else
            {
                delegate?.side_2_update_Value(value:0, error: "Please enter a valid value for side 4")
            }
            }
            else
            {
                delegate?.side_2_update_Value(value:0, error: "Please enter a valid value for side 2")
            }
        }
        else if(sender == side_3_pluse_Button || sender == side_5_pluse_Button)
        {
            if let value = Float(side_3_TF.text ?? "")
            { if let secondValue = Float(side_1_TF.text ?? "")
            {
                let newvalue = value + 1
                self.side_5_TF.text = "\(newvalue + secondValue)"
                self.side_3_TF.text = "\(newvalue)"
                delegate?.side_3_update_Value(value: CGFloat(newvalue), error: nil)
            }
            else
            {
                delegate?.side_3_update_Value(value:0, error: "Please enter a valid value for side 1")
            }
            }
            else
            {
                delegate?.side_3_update_Value(value:0, error: "Please enter a valid value for side 3")
            }
        }
        else if(sender == side_4_pluse_Button || sender == side_6_pluse_Button)
        {
            if let value = Float(side_4_TF.text ?? "")
            { if let secondValue = Float(side_2_TF.text ?? "")
            {
                let newvalue = value + 1
                self.side_6_TF.text = "\(newvalue + secondValue)"
                self.side_4_TF.text = "\(newvalue)"
                delegate?.side_4_update_Value(value: CGFloat(newvalue), error: nil)
            }
            else
            {
                delegate?.side_4_update_Value(value:0, error: "Please enter a valid value for side 2")
            }
            }
            else
            {
                delegate?.side_4_update_Value(value:0, error: "Please enter a valid value for side 4")
            }
        }
        
        
    }
    @IBAction func sideMinusButtonAction(_ sender: UIButton) {
        if(sender == side_1_minus_Button)
        {
            if let value = Float(side_1_TF.text ?? "")
            { if let secondValue = Float(side_3_TF.text ?? "")
            {
                let newvalue = value - 1
                if(newvalue > 0)
                {
                    self.side_5_TF.text = "\(newvalue + secondValue)"
                    self.side_1_TF.text = "\(newvalue)"
                    delegate?.side_1_update_Value(value: CGFloat(newvalue), error: nil)
                }
            }
            else
            {
                delegate?.side_1_update_Value(value:0, error: "Please enter a valid value for side 3")
            }
            }
            else
            {
                delegate?.side_1_update_Value(value:0, error: "Please enter a valid value for side 1")
            }
        }
        else if(sender == side_2_minus_Button)
        {
            if let value = Float(side_2_TF.text ?? "")
            { if let secondValue = Float(side_4_TF.text ?? "")
            {
                let newvalue = value - 1
                if(newvalue > 0)
                {
                    self.side_6_TF.text = "\(newvalue + secondValue)"
                    self.side_2_TF.text = "\(newvalue)"
                    delegate?.side_2_update_Value(value: CGFloat(newvalue), error: nil)
                }
            }
            else
            {
                delegate?.side_2_update_Value(value:0, error: "Please enter a valid value for side 4")
            }
            }
            else
            {
                delegate?.side_2_update_Value(value:0, error: "Please enter a valid value for side 2")
            }
        }
        else if(sender == side_3_minus_Button || sender == side_5_minus_Button)
        {
            if let value = Float(side_3_TF.text ?? "")
            { if let secondValue = Float(side_1_TF.text ?? "")
            {
                let newvalue = value - 1
                if(newvalue > 0)
                {
                    self.side_5_TF.text = "\(newvalue + secondValue)"
                    self.side_3_TF.text = "\(newvalue)"
                    delegate?.side_3_update_Value(value: CGFloat(newvalue), error: nil)
                }
            }
            else
            {
                delegate?.side_3_update_Value(value:0, error: "Please enter a valid value for side 1")
            }
            }
            else
            {
                delegate?.side_3_update_Value(value:0, error: "Please enter a valid value for side 3")
            }
        }
        else if(sender == side_4_minus_Button || sender == side_6_minus_Button)
        {
            if let value = Float(side_4_TF.text ?? "")
            { if let secondValue = Float(side_2_TF.text ?? "")
            {
                let newvalue = value - 1
                if(newvalue > 0)
                {
                    self.side_6_TF.text = "\(newvalue + secondValue)"
                    self.side_4_TF.text = "\(newvalue)"
                    delegate?.side_4_update_Value(value: CGFloat(newvalue), error: nil)
                }
            }
            else
            {
                delegate?.side_4_update_Value(value:0, error: "Please enter a valid value for side 2")
            }
            }
            else
            {
                delegate?.side_4_update_Value(value:0, error: "Please enter a valid value for side 4")
            }
        }
    }
    
    @IBAction func side1TextFiledDidFinish(_ sender: UITextField) {
        if let value = Float(side_1_TF.text ?? "")
        { if let secondValue = Float(side_3_TF.text ?? "")
        {
            let newvalue = value
            self.side_5_TF.text = "\(newvalue + secondValue)"
            self.side_1_TF.text = "\(newvalue)"
            delegate?.side_1_update_Value(value: CGFloat(newvalue), error: nil)
        }
        else
        {
            delegate?.side_1_update_Value(value:0, error: "Please enter a valid value for side 3")
        }
        }
        else
        {
            delegate?.side_1_update_Value(value:0, error: "Please enter a valid value for side 1")
        }
        
        
    }
    @IBAction func side2TextFieldDidFinish(_ sender: UITextField) {
        if let value = Float(side_2_TF.text ?? "")
        { if let secondValue = Float(side_4_TF.text ?? "")
        {
            let newvalue = value
            self.side_6_TF.text = "\(newvalue + secondValue)"
            self.side_2_TF.text = "\(newvalue)"
            delegate?.side_2_update_Value(value: CGFloat(newvalue), error: nil)
        }
        else
        {
            delegate?.side_2_update_Value(value:0, error: "Please enter a valid value for side 4")
        }
        }
        else
        {
            delegate?.side_2_update_Value(value:0, error: "Please enter a valid value for side 2")
        }
        
    }
    @IBAction func side3TextFieldDidFinish(_ sender: UITextField) {
        if let value = Float(side_3_TF.text ?? "")
        { if let secondValue = Float(side_1_TF.text ?? "")
        {
            let newvalue = value
            self.side_5_TF.text = "\(newvalue + secondValue)"
            self.side_3_TF.text = "\(newvalue)"
            delegate?.side_3_update_Value(value: CGFloat(newvalue), error: nil)
        }
        else
        {
            delegate?.side_3_update_Value(value:0, error: "Please enter a valid value for side 1")
        }
        }
        else
        {
            delegate?.side_3_update_Value(value:0, error: "Please enter a valid value for side 3")
        }
        
    }
    @IBAction func side4TextFieldDidFinish(_ sender: UITextField) {
        
        if let value = Float(side_4_TF.text ?? "")
        { if let secondValue = Float(side_2_TF.text ?? "")
        {
            let newvalue = value
            self.side_6_TF.text = "\(newvalue + secondValue)"
            self.side_4_TF.text = "\(newvalue)"
            delegate?.side_4_update_Value(value: CGFloat(newvalue), error: nil)
        }
        else
        {
            delegate?.side_4_update_Value(value:0, error: "Please enter a valid value for side 2")
        }
        }
        else
        {
            delegate?.side_4_update_Value(value:0, error: "Please enter a valid value for side 4")
        }
        
    }
    @IBAction func side5TextFieldDidFinish(_ sender: UITextField) {
        if let value = Float(sender.text ?? "")
        {
            
            
            if let last_value = Float(self.side_1_TF.text ?? "0")
            {
                
                let defrnt_value = value - last_value
                self.side_3_TF.text = "\(defrnt_value)"
                delegate?.side_3_update_Value(value: CGFloat(defrnt_value), error: nil)
                
            }
            else
            {
                delegate?.side_3_update_Value(value:0, error: "Please enter a valid value for side 1")
            }
        }
        else
        {
            delegate?.side_3_update_Value(value:0, error: "Please enter a valid value")
        }
        
    }
    @IBAction func side6TextFieldDidFinish(_ sender: UITextField) {
        
        if let value = Float(sender.text ?? "")
        {
            
            
            if let last_value = Float(self.side_2_TF.text ?? "0")
            {
                
                let defrnt_value = value - last_value
                self.side_4_TF.text = "\(defrnt_value)"
                delegate?.side_4_update_Value(value: CGFloat(defrnt_value), error: nil)
                
            }
            else
            {
                delegate?.side_4_update_Value(value:0, error: "Please enter a valid value for side 2")
            }
        }
        else
        {
            delegate?.side_4_update_Value(value:0, error: "Please enter a valid value")
        }
        
    }
    
    func side1responder()
    {
        self.setresponderfor(textFiled: side_1_TF)
    }
    func side2responder()
    {
        self.setresponderfor(textFiled: side_2_TF)
    }
    func side3responder()
    {
        self.setresponderfor(textFiled: side_3_TF)
    }
    func side4responder()
    {
        self.setresponderfor(textFiled: side_4_TF)
    }
    func side5responder()
    {
        self.setresponderfor(textFiled: side_5_TF)
    }
    func side6responder()
    {
        self.setresponderfor(textFiled: side_6_TF)
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
            subSqureDelegate?.SubSqureViewDidDeleteView(view.tag)
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
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
