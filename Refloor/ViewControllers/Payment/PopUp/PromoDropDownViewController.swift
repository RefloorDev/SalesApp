//
//  PromoDropDownViewController.swift
//  Refloor
//
//  Created by Bincy C A on 07/03/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift
import DropDown

protocol PromoDiscoundProtocol
{
    func promocodeApplied(promocodeArray:[String],promoCodeDropDownSelectedId:Int,promocodeDropDownSelectedDiscount:Double)
}


class PromoDropDownViewController: UIViewController,DropDownDelegate {
    
    @IBOutlet weak var dropCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownTextfield: UITextField!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var dropDownCollectionView: UICollectionView!
    @IBOutlet weak var promoCodeDropDownView: UIView!
    @IBOutlet weak var promocodeCropDownBtn: UIButton!
    var selectedPromoCodeArrayValue:[String] = []
    let placeholderColor = UIColor().colorFromHexString("#A7B0BA")
    var promoCodeDropDownArray:List<rf_promotionCodes_results>!
    var promoCodeArrayValue:[String] = []
    var promoCodeDropDownSelectedId:Int = Int()
    var promocodeDropDownSelectedDiscount:Double = Double()
    var isPromoBtnClicked = false
    var promocodeDict:[String:Any] = [:]
    var promoCodeApplied: PromoDiscoundProtocol?
    var savingsArray:[Double] = []
    var salePriceArray:[Double] = []
    var minimumFee = 0.0
    static func initialization() -> PromoDropDownViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "PromoDropDownViewController") as? PromoDropDownViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dropDownCollectionView.register(UINib(nibName: "PromoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PromoCollectionViewCell")
        dropDownTextfield.attributedPlaceholder = NSAttributedString(
            string: "Select promotion",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        dropDownTextfield.setLeftPaddingPoints(10)
        promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promoCodeDropDownView.borderColor = UIColor().colorFromHexString("#A7B0BA")
        
        promoCodeDropDownArray = self.getPromoDropDownValue()
        if isPromoBtnClicked == true && selectedPromoCodeArrayValue.count == 0
        {
            dropDownCollectionView.isHidden = true
            dropCollectionViewHeightConstraint.constant = 0
        }
        else
        {
            self.promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#667483")
            promocodeCropDownBtn.isUserInteractionEnabled = false
            dropDownCollectionView.isHidden = false
            dropCollectionViewHeightConstraint.constant = 71
        }
        setUIofApplyButton(isEnable: false)
      
    }

    
    @IBAction func cancelBtnAction(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    @IBAction func dismissOnBackgroundTap(_ sender: UIControl)
    {
            self.dismiss(animated: true)
        
    }
    
    @IBAction func doneBtnAction(_ sender: UIButton)
    {
        promoCodeApplied?.promocodeApplied(promocodeArray: selectedPromoCodeArrayValue, promoCodeDropDownSelectedId: promoCodeDropDownSelectedId, promocodeDropDownSelectedDiscount: promocodeDropDownSelectedDiscount)
        self.dismiss(animated: true)
    }
    @IBAction func resetBtnAction(_ sender: UIButton)
    {
        applyBtn.isUserInteractionEnabled = true
        dropDownCollectionView.reloadData()
        selectedPromoCodeArrayValue.removeAll()
        dropDownCollectionView.isHidden = true
        dropCollectionViewHeightConstraint.constant = 0
        setUIofApplyButton(isEnable: false)
        self.promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promocodeCropDownBtn.isUserInteractionEnabled = true
        dropDownTextfield.text = ""
        dropDownTextfield.attributedPlaceholder = NSAttributedString(
            string: "Select promotion",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        promoCodeDropDownSelectedId = 0
        promocodeDropDownSelectedDiscount = 0
        self.view.layoutSubviews()
    }
    @IBAction func applyBtnAction(_ sender: UIButton)
    {
        if dropDownTextfield.text == ""
        {
            return
        }
        else
        {
            let index = salePriceArray.count - 1
            if salePriceArray[index] == self.minimumFee
            {
                //self.alert("New sale price cannot be less than $\(self.minimumFee)", nil)
                //Updated Changes
                self.alert(AppAlertMsg.maxDiscountAmountMessage, nil)
                return
            }
            applyBtn.isUserInteractionEnabled = false
            dropDownCollectionView.reloadData()
            dropCollectionViewHeightConstraint.constant = 71
            dropDownCollectionView.isHidden = false
            selectedPromoCodeArrayValue.append(promocodeDict["name"] as! String)
            promocodeDropDownSelectedDiscount = promocodeDict["discount"] as! Double
            promoCodeDropDownSelectedId = promocodeDict["id"] as! Int
            self.view.layoutIfNeeded()
            setUIofApplyButton(isEnable: false)
            self.promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#667483")
            promocodeCropDownBtn.isUserInteractionEnabled = false
            dropDownTextfield.attributedPlaceholder = NSAttributedString(
                string: "Select promotion",
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }
    }
    
    @IBAction func dropDownBtnAction(_ sender: UIButton) {
        promoCodeArrayValue.removeAll()
        promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promoCodeDropDownView.borderColor = UIColor().colorFromHexString("#A7B0BA")
        var value:[String] = []
        var startDate:[String] = []
        var endDate:[String] = []
        //arb
        if promoCodeDropDownArray.count > 0
        {
            let appointmentDate = AppDelegate.appoinmentslData.appointment_date?.logDate()
            let  promoValue = promoCodeDropDownArray
            startDate = promoValue!.compactMap({$0.startDate})
            endDate = promoValue!.compactMap({$0.endDate})
            value = promoValue!.compactMap({$0.name})
            for index in 0...startDate.count - 1
            {
                let startDateValue = startDate[index].logDate()
                let endDateValue = endDate[index].logDate()
                let promoResult = value[index]
            
                let isPromotionTodayQualified = appointmentDate!.isBetween(date: startDateValue, andDate: endDateValue) ? true : false
                if isPromotionTodayQualified == true
                {
                    self.promoCodeArrayValue.append(promoResult)
                    //self.promoCodeArrayValue = value
                }
            }
            
            
            
            if(promoCodeArrayValue.count != 0)
            {
                self.DropDownDefaultfunction(sender, sender.bounds.width, promoCodeArrayValue, -1, delegate: self, tag: 2)
            }
            else
            {
                self.alert("Not Available", nil)
            }
        }
        else
        {
            self.alert("Not Available", nil)
        }
    }
    
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int)
    {
       // self.selectedDropDownIndex = index
        promocodeDict.removeAll()
        dropDownTextfield.text = item
        setUIofApplyButton(isEnable: true)
        let selectedPromoCodeArray = promoCodeDropDownArray.filter({$0.name == item})
        //selectedPromoCodeArrayValue.append(selectedPromoCodeArray.first?.name ?? "")
        promocodeDict["name"] = selectedPromoCodeArray.first?.name ?? ""
        promocodeDict["id"] = selectedPromoCodeArray.first?.promotionCodeId ?? 0
        promocodeDict["discount"] = selectedPromoCodeArray.first?.discount ?? 0.0
//        self.promoCodeDropDownSelectedId = selectedPromoCodeArray.first?.promotionCodeId ?? 0
//        self.promocodeDropDownSelectedDiscount = selectedPromoCodeArray.first?.discount ?? 0.0
        
    }
    func setUIofApplyButton(isEnable:Bool){
        if isEnable{
            applyBtn.backgroundColor = UIColor().colorFromHexString("#292562")
            applyBtn.borderColor = UIColor().colorFromHexString("#A7B0BA")
            applyBtn.borderWidth = 1
            applyBtn.setTitleColor(UIColor.white, for: .normal)
        }else{
            applyBtn.backgroundColor = UIColor().colorFromHexString("#667483")
            applyBtn.setTitleColor(UIColor().colorFromHexString("#A7B0BA"), for: .normal)
            self.view.endEditing(true)
        }
    }

    
}

extension PromoDropDownViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPromoCodeArrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromoCollectionViewCell", for: indexPath) as! PromoCollectionViewCell
        cell.promoBGView.addDashedBorder(size: cell.frame.size)
        cell.promoCodeDelteBtn.addTarget(self, action: #selector(deletePromoAdded(sender:)), for: .touchUpInside)
        cell.promocodeLbl.text = selectedPromoCodeArrayValue[indexPath.row]
        //cell.promocodeLbl.backgroundColor = .green
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let label = UILabel(frame: CGRect.zero)
        label.text = selectedPromoCodeArrayValue[indexPath.item]
        label.sizeToFit()
        return CGSize(width: label.frame.width + 30 + 46 + 20 + 35, height: 56)
        
    }
    @objc func deletePromoAdded(sender:UIButton)
    {
        applyBtn.isUserInteractionEnabled = true
        dropDownCollectionView.reloadData()
        selectedPromoCodeArrayValue.removeAll()
        dropDownCollectionView.isHidden = true
        dropCollectionViewHeightConstraint.constant = 0
        setUIofApplyButton(isEnable: false)
        self.promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promocodeCropDownBtn.isUserInteractionEnabled = true
        dropDownTextfield.text = ""
        dropDownTextfield.attributedPlaceholder = NSAttributedString(
            string: "Select promotion",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        promoCodeDropDownSelectedId = 0
        promocodeDropDownSelectedDiscount = 0
        self.view.layoutSubviews()
        
        
    }

    
    
}
