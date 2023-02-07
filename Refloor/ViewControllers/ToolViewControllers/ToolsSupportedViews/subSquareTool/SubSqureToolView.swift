//
//  SubSqureToolView.swift
//  RefloorEx
//
//  Created by sbek on 25/03/20.
//  Copyright © 2020 Arun Rajendrababu. All rights reserved.
//

import UIKit
protocol SubSqureToolDelegate{
    func SubSqureViewDidDeleteView(_ int:Int)
    func SubSqureViewDidCloseToolview()
    func SubSqureViewDidChangeSize(size:CGSize)
}
class SubSqureToolView: CustomView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var selected_View_Name_Label: UILabel!
    @IBOutlet weak var width_TextField: UITextField!
    @IBOutlet weak var hight_TextField: UITextField!
    
    var selected_Squre_View:CustomView?
    var delegate:SubSqureToolDelegate?
    var view:UIView!
    init(frame:CGRect,delegate:SubSqureToolDelegate?) {
        super.init(frame: frame)
        setup()
        self.delegate = delegate
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
    
    
    //    func setup() {
    //         loadViewFromNib()
    //
    //        contentView.frame = bounds
    //        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    //        self.bringSubviewToFront(contentView)
    //    }
    //
    //    func loadViewFromNib(){
    //        Bundle.main.loadNibNamed("SubSqureToolView", owner: self, options: nil)
    //
    //    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        // self.addSubview(contentView)
        //view.addSubview(selected_View_Name_Label)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "SubSqureToolView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func minusButtonAction(_ sender: UIButton) {
        if let view =  self.selected_Squre_View
        {
            if(sender.tag == 0)
            {
                if(view.custom_width > 1.0)
                {
                    view.custom_width -= 1.0
                    self.width_TextField.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight > 1.0)
                {
                    view.custom_hight -= 1.0
                    self.hight_TextField.text = "\(view.custom_hight)"
                    view.custom_size_reload()
                }
            }
            
        }
    }
    
    @IBAction func pluseButtonAction(_ sender: UIButton) {
        if let view =  self.selected_Squre_View
        {
            if(sender.tag == 0)
            {
                if(view.custom_width < 10)
                {
                    view.custom_width += 1.0
                    self.width_TextField.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight < 10)
                {
                    view.custom_hight += 1.0
                    self.hight_TextField.text = "\(view.custom_hight)"
                    view.custom_size_reload()
                }
            }
            
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        if let view =  self.selected_Squre_View
        {
            delegate?.SubSqureViewDidDeleteView(view.tag)
            no_Squre_View_In_Tool()
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.delegate?.SubSqureViewDidCloseToolview()
        self.removeFromSuperview()
    }
    
    func set_Squre_View_In_Tool(subView:CustomView)
    {
        self.selected_Squre_View = subView
        self.selected_View_Name_Label.text = "Selected Openings (\(subView.tag + 1))"
        self.width_TextField.text = "\(subView.custom_width)"
        self.hight_TextField.text = "\(subView.custom_hight)"
    }
    func no_Squre_View_In_Tool()
    {
        self.selected_Squre_View = nil
        self.selected_View_Name_Label.text = "No Selected Openings"
        self.width_TextField.text = ""
        self.hight_TextField.text = ""
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
