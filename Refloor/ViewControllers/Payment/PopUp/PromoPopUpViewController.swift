//
//  PromoPopUpViewController.swift
//  Refloor
//
//  Created by sbek on 30/10/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class PromoPopUpViewController: UIViewController,UITextFieldDelegate {
    static func initialization() -> PromoPopUpViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "PromoPopUpViewController") as? PromoPopUpViewController
    }
    @IBOutlet weak var discountPersentage: UITextField!
    @IBOutlet weak var discount: UITextField!
    @IBOutlet weak var promocode: UITextField!
    var paymentMonthlyPromo:[MonthlyPromoDataValue] = []
    var activeTextField = UITextField()
    var discountValue : Double = 0
    var discountPromoCode : String = ""
    var discountPercentage : Double = 0
    var totalAmount : Double = 0
    var delegate:PromoPopUpViewDelegate?
    
    override func viewDidLoad() {
        
        promocode.delegate = self
        discount.delegate = self
        discountPersentage.delegate = self
        
        if(discountValue > 0)
        {
            discount.text = discountValue.toString
            
        }
        if(discountPromoCode.count > 0)
        {
            
            promocode.text = discountPromoCode
        }
        if(discountPercentage > 0)
        {
            discountPersentage.text = discountPercentage.toRoundeString
            
        }
        promocode.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        discount.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        discountPersentage.setPlaceHolderWithColor(placeholder: "Enter Here", colour: UIColor.placeHolderColor)
        
        promocode.setLeftPaddingPoints(10)
        discount.setLeftPaddingPoints(10)
        discountPersentage.setLeftPaddingPoints(10)
        
        
        
        if let clearButton = promocode.value(forKey: "_clearButton") as? UIButton {
               let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
               clearButton.setImage(templateImage, for: .normal)
               clearButton.tintColor = .white
           }
        if let clearButton = discount.value(forKey: "_clearButton") as? UIButton {
               let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
               clearButton.setImage(templateImage, for: .normal)
               clearButton.tintColor = .white
           }
        if let clearButton = discountPersentage.value(forKey: "_clearButton") as? UIButton {
               let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
               clearButton.setImage(templateImage, for: .normal)
               clearButton.tintColor = .white
           }
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func cancel(_ sender: UIButton) {
        //        if(promocode.text == "")
        //        {
        //            delegate?.didApplyPromoCode(code:promocode.text ?? "")
        //        }
        //        if(discount.text == "")
        //        {
        //
        //        }
        //        if(discountPersentage.text == "")
        //        {
        //
        //        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyPromoCode(_ sender: UIButton)
    {
        // if let value = (promocode.text ?? "")
        //  {
        var promoStatus = false
        for promo in paymentMonthlyPromo
        {
            
            if(promo.code == promocode.text ?? "")
            {
                delegate?.didApplyPromoCode(code:promocode.text ?? "")
                self.dismiss(animated: true, completion: nil)
                promoStatus = true
                
            }
            
        }
        
        if(promoStatus == false)
        {
            self.alert("Please apply valid Promo Code" , nil)
        }
        
        // self.dismiss(animated: true, completion: nil)
        //  }
        //        else
        //        {
        //            delegate?.didApplyPromoCode(code:promocode.text ?? "")
        //                       self.dismiss(animated: true, completion: nil)
        //           // self.alert("Please enter valid amount", nil)
        //        }
        
    }
    @IBAction func applyDiscount(_ sender: UIButton) {
        
        if let value = Double(discount.text ?? "")
        {
            
            if (value >= totalAmount)
            {
                promocode.text = ""
                discountPersentage.text = ""
                self.alert("You can't applied discount more than sale price" , nil)
            }
            else{
                delegate?.didApplyDiscountAtCash(cash: value)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            delegate?.didApplyDiscountAtCash(cash: 0)
            self.dismiss(animated: true, completion: nil)
            // self.alert("Please enter valid amount", nil)
        }
    }
    @IBAction func applyDiscountWithPersentage(_ sender: UIButton) {
        
        
        
        
        
        if let value = Double(discountPersentage.text ?? "")
        {
            if (value >= 100.0)
            {
                promocode.text = ""
                discount.text = ""
                self.alert("You can't applied discount more than sale price" , nil)
            }
            else
            {
                
                delegate?.didApplyDiscountAtPersentage(persentage: value)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            delegate?.didApplyDiscountAtPersentage(persentage: 0)
            self.dismiss(animated: true, completion: nil)
            // self.alert("Please enter valid amount", nil)
        }
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        self.activeTextField = textField
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
