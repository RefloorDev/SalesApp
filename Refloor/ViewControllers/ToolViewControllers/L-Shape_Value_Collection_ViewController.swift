//
//  L-Shape_Value_Collection_ViewController.swift
//  Refloor
//
//  Created by sbek on 13/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class L_Shape_Value_Collection_ViewController: UIViewController {
    
    static func initialization() -> L_Shape_Value_Collection_ViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "L_Shape_Value_Collection_ViewController") as? L_Shape_Value_Collection_ViewController
    }
    
    
    @IBOutlet weak var side_6_label: UILabel!
    @IBOutlet weak var side_6_View: UIView!
    @IBOutlet weak var shape_bg_View: UIView!
    @IBOutlet weak var side_1_View: UIView!
    @IBOutlet weak var side_1_Label: UILabel!
    @IBOutlet weak var side_1_TF_Label: UILabel!
    @IBOutlet weak var side_1_TF: UITextField!
    @IBOutlet weak var side_1_AR_Button: UIButton!
    @IBOutlet weak var side_2_View: UIView!
    @IBOutlet weak var side_2_Label: UILabel!
    @IBOutlet weak var side_2_TF_Label: UILabel!
    @IBOutlet weak var side_2_TF: UITextField!
    @IBOutlet weak var side_2_AR_Button: UIButton!
    @IBOutlet weak var side_3_View: UIView!
    @IBOutlet weak var side_3_Label: UILabel!
    @IBOutlet weak var side_3_TF_Label: UILabel!
    @IBOutlet weak var side_3_TF: UITextField!
    @IBOutlet weak var side_3_AR_Button: UIButton!
    @IBOutlet weak var side_4_View: UIView!
    @IBOutlet weak var side_4_Label: UILabel!
    @IBOutlet weak var side_4_TF_Label: UILabel!
    @IBOutlet weak var side_4_TF: UITextField!
    @IBOutlet weak var side_4_AR_Button: UIButton!
    @IBOutlet weak var side_5_View: UIView!
    @IBOutlet weak var side_5_Label: UILabel!
    var isFliped = false
    var selectedViews:[UIView]?
    let labelColor = UIColor(displayP3Red: 167/255, green: 176/255, blue: 186/255, alpha: 1) //rgba(167, 176, 186, 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.setNavigationBarbackAndlogo()
        
        let tap_side_1_gesutre = UITapGestureRecognizer(target: self, action: #selector(tap_side_1_gestiture_action))
        tap_side_1_gesutre.numberOfTapsRequired = 1
        let tap_side_2_gesutre = UITapGestureRecognizer(target: self, action: #selector(tap_side_2_gestiture_action))
        tap_side_2_gesutre.numberOfTapsRequired = 1
        let tap_side_3_gesutre = UITapGestureRecognizer(target: self, action: #selector(tap_side_3_gestiture_action))
        tap_side_3_gesutre.numberOfTapsRequired = 1
        let tap_side_4_gesutre = UITapGestureRecognizer(target: self, action: #selector(tap_side_4_gestiture_action))
        tap_side_4_gesutre.numberOfTapsRequired = 1
        
        self.side_1_View.addGestureRecognizer(tap_side_1_gesutre)
        self.side_1_Label.addGestureRecognizer(tap_side_1_gesutre)
        self.side_2_View.addGestureRecognizer(tap_side_2_gesutre)
        self.side_2_Label.addGestureRecognizer(tap_side_2_gesutre)
        self.side_3_View.addGestureRecognizer(tap_side_3_gesutre)
        self.side_3_Label.addGestureRecognizer(tap_side_3_gesutre)
        self.side_4_View.addGestureRecognizer(tap_side_4_gesutre)
        self.side_4_Label.addGestureRecognizer(tap_side_4_gesutre)
        self.side_1_View.isUserInteractionEnabled = true
        self.side_1_Label.isUserInteractionEnabled = true
        self.side_2_View.isUserInteractionEnabled = true
        self.side_2_Label.isUserInteractionEnabled = true
        self.side_3_View.isUserInteractionEnabled = true
        self.side_3_Label.isUserInteractionEnabled = true
        self.side_4_View.isUserInteractionEnabled = true
        self.side_4_Label.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    
    func setfliped()
    {
        if isFliped
        {
            shape_bg_View.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            side_1_Label.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            side_2_Label.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            side_3_Label.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            side_4_Label.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            side_5_Label.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            side_6_label.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        else
        {
            shape_bg_View.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            side_1_Label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            side_2_Label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            side_3_Label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            side_4_Label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            side_5_Label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            side_6_label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func removeSelection()
    {
        for subview in selectedViews ?? []
        {
            if(subview == side_1_TF_Label || subview == side_2_TF_Label || subview == side_3_TF_Label || subview == side_4_TF_Label)
            {
                subview.setDeSelected(.white)
            }
            else
            {
                subview.setDeSelected(labelColor)
            }
        }
        self.selectedViews = []
    }
    
    @objc func tap_side_1_gestiture_action()
    {
        UIView.animate(withDuration: 0.3) {
            self.removeSelection()
            self.side_1_View.setSelected(.red)
            self.side_1_Label.setSelected(.red)
            self.side_1_TF.setSelected(.red)
            self.side_1_TF_Label.setSelected(.red)
            var views = [UIView]()
            views.append(self.side_1_TF_Label)
            views.append(self.side_1_View)
            views.append(self.side_1_Label)
            views.append(self.side_1_TF)
            self.selectedViews = views
            self.view.layoutIfNeeded()
        }
        
        //        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
        //            self.alert("Not available", nil)
        //        }
        //        let no = UIAlertAction(title: "No", style: .cancel) { (_) in
        //             self.side_1_TF.becomeFirstResponder()
        //        }
        //        self.alert("Do you want to read messurements via our AR Technology?", [yes,no])
        self.side_1_TF.becomeFirstResponder()
        
    }
    
    @objc func tap_side_2_gestiture_action()
    {
        UIView.animate(withDuration: 0.3) {
            self.removeSelection()
            self.side_2_View.setSelected(.red)
            self.side_2_Label.setSelected(.red)
            self.side_2_TF.setSelected(.red)
            var views = [UIView]()
            self.side_2_TF_Label.setSelected(.red)
            views.append(self.side_2_TF_Label)
            views.append(self.side_2_View)
            views.append(self.side_2_Label)
            views.append(self.side_2_TF)
            self.selectedViews = views
            self.view.layoutIfNeeded()
        }
        //        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
        //                self.alert("Not available", nil)
        //            }
        //            let no = UIAlertAction(title: "No", style: .cancel) { (_) in
        //                 self.side_2_TF.becomeFirstResponder()
        //            }
        //            self.alert("Do you want to read messurements via our AR Technology?", [yes,no])
        self.side_2_TF.becomeFirstResponder()
    }
    
    @objc func tap_side_3_gestiture_action()
    {
        UIView.animate(withDuration: 0.3) {
            self.removeSelection()
            self.side_3_View.setSelected(.red)
            self.side_3_Label.setSelected(.red)
            self.side_3_TF.setSelected(.red)
            
            var views = [UIView]()
            self.side_3_TF_Label.setSelected(.red)
            views.append(self.side_3_TF_Label)
            views.append(self.side_3_View)
            views.append(self.side_3_Label)
            views.append(self.side_3_TF)
            self.selectedViews = views
            self.view.layoutIfNeeded()
        }
        //        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
        //                       self.alert("Not available", nil)
        //                   }
        //                   let no = UIAlertAction(title: "No", style: .cancel) { (_) in
        //                        self.side_3_TF.becomeFirstResponder()
        //                   }
        //                   self.alert("Do you want to read messurements via our AR Technology?", [yes,no])
        self.side_3_TF.becomeFirstResponder()
    }
    
    @objc func tap_side_4_gestiture_action()
    {
        UIView.animate(withDuration: 0.3) {
            self.removeSelection()
            self.side_4_View.setSelected(.red)
            self.side_4_Label.setSelected(.red)
            self.side_4_TF.setSelected(.red)
            var views = [UIView]()
            self.side_4_TF_Label.setSelected(.red)
            views.append(self.side_4_TF_Label)
            views.append(self.side_4_View)
            views.append(self.side_4_Label)
            views.append(self.side_4_TF)
            self.selectedViews = views
            self.view.layoutIfNeeded()
        }
        //        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
        //                       self.alert("Not available", nil)
        //                   }
        //                   let no = UIAlertAction(title: "No", style: .cancel) { (_) in
        //                        self.side_4_TF.becomeFirstResponder()
        //                   }
        //                   self.alert("Do you want to read messurements via our AR Technology?", [yes,no])
        self.side_4_TF.becomeFirstResponder()
    }
    
    @IBAction func textFieldDidBegen(_ sender: UITextField)
    {
        
        if(sender == side_1_TF)
        {
            UIView.animate(withDuration: 0.3) {
                self.removeSelection()
                self.side_1_View.setSelected(.red)
                self.side_1_Label.setSelected(.red)
                self.side_1_TF.setSelected(.red)
                
                var views = [UIView]()
                self.side_1_TF_Label.setSelected(.red)
                views.append(self.side_1_TF_Label)
                
                views.append(self.side_1_View)
                views.append(self.side_1_Label)
                views.append(self.side_1_TF)
                self.selectedViews = views
                self.view.layoutIfNeeded()
            }
        }
        else if(sender == side_2_TF)
        {
            UIView.animate(withDuration: 0.3) {
                self.removeSelection()
                self.side_2_View.setSelected(.red)
                self.side_2_Label.setSelected(.red)
                self.side_2_TF.setSelected(.red)
                var views = [UIView]()
                self.side_2_TF_Label.setSelected(.red)
                views.append(self.side_2_TF_Label)
                views.append(self.side_2_View)
                views.append(self.side_2_Label)
                views.append(self.side_2_TF)
                self.selectedViews = views
                self.view.layoutIfNeeded()
            }
        }
        else if(sender == side_3_TF)
        {
            UIView.animate(withDuration: 0.3) {
                self.removeSelection()
                self.side_3_View.setSelected(.red)
                self.side_3_Label.setSelected(.red)
                self.side_3_TF.setSelected(.red)
                var views = [UIView]()
                self.side_3_TF_Label.setSelected(.red)
                views.append(self.side_3_TF_Label)
                views.append(self.side_3_View)
                views.append(self.side_3_Label)
                views.append(self.side_3_TF)
                self.selectedViews = views
                self.view.layoutIfNeeded()
            }
        }
        else if(sender == side_4_TF)
        {
            UIView.animate(withDuration: 0.3) {
                self.removeSelection()
                self.side_4_View.setSelected(.red)
                self.side_4_Label.setSelected(.red)
                self.side_4_TF.setSelected(.red)
                var views = [UIView]()
                self.side_4_TF_Label.setSelected(.red)
                views.append(self.side_4_TF_Label)
                views.append(self.side_4_View)
                views.append(self.side_4_Label)
                views.append(self.side_4_TF)
                self.selectedViews = views
                self.view.layoutIfNeeded()
            }
        }
        
        
    }
    
    @IBAction func flipButtonAction(_ sender: Any) {
        isFliped = !isFliped
        setfliped()
    }
    
    func validateAndGo()
    {
        var side1Value:CGFloat = 0
        var side2Value:CGFloat = 0
        var side3Value:CGFloat = 0
        var side4Value:CGFloat = 0
        
        if let value = Float(self.side_1_TF.text ?? "0")
        {
            side1Value = CGFloat(value)
        }
        else
        {
            let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.side_1_TF.becomeFirstResponder()
            }
            self.alert("Please enter a valid value for Side 1", [ok])
            return
        }
        if let value = Float(self.side_2_TF.text ?? "0")
        {
            side2Value = CGFloat(value)
        }
        else
        {
            let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.side_2_TF.becomeFirstResponder()
            }
            self.alert("Please enter a valid value for Side 2", [ok])
            return
        }
        
        if let value = Float(self.side_3_TF.text ?? "0")
        {
            side3Value = CGFloat(value)
        }
        else
        {
            let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.side_3_TF.becomeFirstResponder()
            }
            self.alert("Please enter a valid value for Side 3", [ok])
            return
        }
        
        if let value = Float(self.side_4_TF.text ?? "0")
        {
            side4Value = CGFloat(value)
        }
        else
        {
            let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.side_4_TF.becomeFirstResponder()
            }
            self.alert("Please enter a valid value for Side 4", [ok])
            return
        }
        
        let l_shape = L_Shape_ViewController.initialization()!
        l_shape.L_shape_1_Rectangle_width  = side1Value
        l_shape.L_shape_1_Rectangle_hight = side2Value
        l_shape.L_shape_2_Rectangle_width  = side3Value
        l_shape.L_shape_2_Rectangle_hight = side4Value
        l_shape.isFlip = self.isFliped
        self.navigationController?.pushViewController(l_shape, animated: true)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        validateAndGo()
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
