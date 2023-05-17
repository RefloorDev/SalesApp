//
//  PromoPopUpViewControllerNew.swift
//  Refloor
//
//  Created by Arun Rajendrababu on 02/06/22.
//  Copyright © 2022 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import DropDown

protocol DiscountProtocol{
    func discountApplied(discountAmount:Double,discountArray:[DiscountDetailStruct],isDiscountApplied:Bool)
    func promoDiscountApplied(discountAmount:Double, ispromoApplies:Bool, discountArray:[PromoDropDownStruct])
}

class PromoPopUpViewControllerNew: UIViewController,DropDownDelegate {
   
    
    static func initialization() -> PromoPopUpViewControllerNew? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "PromoPopUpViewControllerNew") as? PromoPopUpViewControllerNew
    }
    
    @IBOutlet weak var promoCodeStaticLabel: UILabel!
    @IBOutlet weak var discountDollarStaticLabel: UILabel!
    @IBOutlet weak var discountPercentageStaticLabel: UILabel!
    @IBOutlet weak var promoCodeTextField: UITextField!
    @IBOutlet weak var discountDollarTextField: UITextField!
    @IBOutlet weak var discountPercentageTextField: UITextField!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var discountTableView: UITableView!
    @IBOutlet weak var discountTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var promoSuccessView: UIView!
    @IBOutlet weak var promoSuccessViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoSuccessViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoSuccessImageView: UIImageView!
    @IBOutlet weak var promoCodeCollectionview: UICollectionView!
    @IBOutlet weak var promocodeCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoDropDownBtn: UIButton!
    @IBOutlet weak var dropDownTextfield: UITextField!
    @IBOutlet weak var promoSuccessViewDoneButton: UIButton!
    @IBOutlet weak var promoCodeDropDownView: UIView!
    let placeholderColor = UIColor().colorFromHexString("#A7B0BA")
    var newPrice: Double = 0.0
    var discountArray:[DiscountDetailStruct] = []
    var promoDiscountArray:[PromoDropDownStruct] = []
    var timer : Timer!
    var minimumFee = 0.0
    var discountDelegate: DiscountProtocol?
    var discountValue : Double = 0
    var discountPromoCode : String = ""
    var discountPercentage : Double = 0
    var totalAmount : Double = 0
    var paymentMonthlyPromo:[MonthlyPromoDataValue] = []
    var previousHeightOfDiscountView:CGFloat = 0.0
    var promoCodeArray:List<rf_master_discount>!
    var promoCodeDropDownArray:List<rf_promotionCodes_results>!
    var wrongWhenFirstItem: Bool! = false
    let screenHeight = UIScreen.main.bounds.height
    var isProgressiveDiscountApplied = false
    var isPromoDiscountApplied = false
    var oneYearPrice:Double = 0
    var SavingPrice:Double = 0
    var isPromoBtnClicked = false
    var promoCodeArrayValue:[String] = []
    var selectedPromoCodeArrayValue:[String] = []
    var selectedDropDownIndex = -1
    var msrpPrice:Double = Double()
    var promoCodeDropDownSelectedId:Int = Int()
    var promocodeDropDownSelectedDiscount:Double = Double()
    var area:Double = Double()
    var costpersqft:Double = Double()
    var stairPrice:Double = Double()
    var additionalCost:Double = Double()
    var setKeyboardHeightValue:CGFloat {
        get { return CGFloat() }
        set{
            if (newValue < (screenHeight-discountView.frame.height)){
                IQKeyboardManager.shared.keyboardDistanceFromTextField = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        discountTableView.register(UINib(nibName: "TotalPriceTableViewCell", bundle: nil), forCellReuseIdentifier: "TotalPriceTableViewCell")
        discountTableView.register(UINib(nibName: "DiscountTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscountTitleTableViewCell")
        discountTableView.register(UINib(nibName: "DiscountTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscountTableViewCell")
        //PromoCollectionViewCell
        promoCodeCollectionview.register(UINib(nibName: "PromoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PromoCollectionViewCell")
        if isPromoBtnClicked == true
        {
            promoCodeDropDownView.isHidden = false
            promoCodeStaticLabel.text = "Promotion*"
            discountDollarStaticLabel.isHidden = true
            discountPercentageStaticLabel.isHidden = true
            discountTableView.isHidden = true
           discountTableViewHeightConstraint.constant = 0
            promocodeCollectionViewHeightConstraint.constant = 71
        }
        else
        {
            promoCodeDropDownView.isHidden = true
            promoCodeStaticLabel.text = "Discount Code*"
            discountDollarStaticLabel.isHidden = false
            discountPercentageStaticLabel.isHidden = false
            discountTableView.isHidden = false
            discountTableViewHeightConstraint.constant = 71
            promocodeCollectionViewHeightConstraint.constant = 0
        }
        //
        let masterData = self.getMasterDataFromDB()
        self.minimumFee = masterData.min_sale_price
        //set sale price
        if isPromoBtnClicked == false
        {
            if !isProgressiveDiscountApplied{
                discountArray = [DiscountDetailStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
            }else{
                let titleCell = DiscountDetailStruct(cellType: .titleCell)
                let finalPriceCell = DiscountDetailStruct(cellType: .finalPriceCell)
                self.newPrice = discountArray.last?.newPrice ?? 0.0
                discountArray.insert(titleCell, at: 0)
                discountArray.append(finalPriceCell)
                reloadTableAndAnimateHeight()
            }
        }
        if !isPromoDiscountApplied
        {
            promoDiscountArray = [PromoDropDownStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
        }
        else
        {
            reloadTableAndAnimateHeight()
        }
        //
        promoCodeArray = self.getDiscountList()
        promoCodeDropDownArray = self.getPromoDropDownValue()
        promoCodeTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter here",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        discountDollarTextField.attributedPlaceholder = NSAttributedString(
            string: "$",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        discountPercentageTextField.attributedPlaceholder = NSAttributedString(
            string: "%",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        dropDownTextfield.attributedPlaceholder = NSAttributedString(
            string: "Select promotion",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        promoCodeTextField.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promoCodeTextField.borderColor = UIColor().colorFromHexString("#A7B0BA")
        discountDollarTextField.backgroundColor = UIColor().colorFromHexString("#2D343D")
        discountDollarTextField.borderColor = UIColor().colorFromHexString("#A7B0BA")
        discountPercentageTextField.backgroundColor = UIColor().colorFromHexString("#2D343D")
        discountPercentageTextField.borderColor = UIColor().colorFromHexString("#A7B0BA")
        promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promoCodeDropDownView.borderColor = UIColor().colorFromHexString("#A7B0BA")
        
        promoCodeTextField.setLeftPaddingPoints(10)
        discountDollarTextField.setLeftPaddingPoints(10)
        discountPercentageTextField.setLeftPaddingPoints(10)
        dropDownTextfield.setLeftPaddingPoints(10)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    func reloadTableAndAnimateHeight(){
        discountTableView.reloadData()
        if isPromoBtnClicked == false
        {
        let initialCount = self.discountArray.count
        let discountCount = self.discountArray.filter({$0.cellType == .discountValuCell || $0.cellType == .titleCell}).count
        let priceCellCount =  initialCount - discountCount
            UIView.animate(withDuration: 1.5) {
                self.discountTableViewHeightConstraint.constant = CGFloat( (priceCellCount * 69) + (discountCount * 54))
            }
            
        }
        else
        {
            let initialCount = self.promoDiscountArray.count
            let discountCount = self.promoDiscountArray.filter({$0.cellType == .discountValuCell || $0.cellType == .titleCell}).count
            let priceCellCount =  initialCount - discountCount
                UIView.animate(withDuration: 1.5) {
                    self.discountTableViewHeightConstraint.constant = CGFloat( (priceCellCount * 69) + (discountCount * 54))
                }
        }
    }
    
    func adjustKeyboardTextFieldHeight(){
        let initialCount = self.discountArray.count
        let discountCount = self.discountArray.filter({$0.cellType == .discountValuCell || $0.cellType == .titleCell}).count
        let priceCellCount =  initialCount - discountCount
        self.setKeyboardHeightValue = CGFloat( (priceCellCount * 69) + (discountCount * 54) + 50)
    }
    
    func setUIofApplyButton(isEnable:Bool){
        if isEnable{
            applyButton.backgroundColor = UIColor().colorFromHexString("#292562")
            applyButton.borderColor = UIColor().colorFromHexString("#A7B0BA")
            applyButton.borderWidth = 1
            applyButton.setTitleColor(UIColor.white, for: .normal)
        }else{
            applyButton.backgroundColor = UIColor().colorFromHexString("#667483")
            applyButton.setTitleColor(UIColor().colorFromHexString("#A7B0BA"), for: .normal)
            self.view.endEditing(true)
            promoCodeTextField.text = ""
            discountDollarTextField.text = ""
            discountPercentageTextField.text = ""
            promoCodeTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            promoCodeTextField.borderColor = UIColor().colorFromHexString("#646C76")
            discountDollarTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            discountDollarTextField.borderColor = UIColor().colorFromHexString("#646C76")
            discountPercentageTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            discountPercentageTextField.borderColor = UIColor().colorFromHexString("#646C76")
        }
    }
    
    func setUIofTextFields(selectedTextField:DiscountEnum){
        switch selectedTextField {
        case .promo:
            promoCodeTextField.backgroundColor = UIColor().colorFromHexString("#2D343D")
            promoCodeTextField.borderColor = UIColor().colorFromHexString("#A7B0BA")
            
            discountDollarTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            discountDollarTextField.borderColor = UIColor().colorFromHexString("#646C76")
            discountPercentageTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            discountPercentageTextField.borderColor = UIColor().colorFromHexString("#646C76")
            discountDollarTextField.text = ""
            discountPercentageTextField.text = ""
            
            break
        case .amount:
            discountDollarTextField.backgroundColor = UIColor().colorFromHexString("#2D343D")
            discountDollarTextField.borderColor = UIColor().colorFromHexString("#A7B0BA")
            
            promoCodeTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            promoCodeTextField.borderColor = UIColor().colorFromHexString("#646C76")
            discountPercentageTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            discountPercentageTextField.borderColor = UIColor().colorFromHexString("#646C76")
            promoCodeTextField.text = ""
            discountPercentageTextField.text = ""
            break
        case .percentage:
            discountPercentageTextField.backgroundColor = UIColor().colorFromHexString("#2D343D")
            discountPercentageTextField.borderColor = UIColor().colorFromHexString("#A7B0BA")
            
            promoCodeTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            promoCodeTextField.borderColor = UIColor().colorFromHexString("#646C76")
            discountDollarTextField.backgroundColor = UIColor().colorFromHexString("#46505C")
            discountDollarTextField.borderColor = UIColor().colorFromHexString("#646C76")
            promoCodeTextField.text = ""
            discountDollarTextField.text = ""
            break
        case .none:
            break
        }
    }
    
    @IBAction func dismissOnBackgroundTap(_ sender: UIControl) {
        if self.promoSuccessView.isHidden{
            self.dismiss(animated: true)
        }else{
            promoSuccessViewDoneButton.sendActions(for: .touchUpInside)
        }
    }
    
    
    @IBAction func promoCodeDropDownBtnAction(_ sender: UIButton) {
        promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promoCodeDropDownView.borderColor = UIColor().colorFromHexString("#A7B0BA")
        var value:[String] = []
        var startDate:[String] = []
        var endDate:[String] = []
        //arb
        promoCodeArrayValue.removeAll()
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
        
    }
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int)
    {
        self.selectedDropDownIndex = index
        dropDownTextfield.text = item
        setUIofApplyButton(isEnable: true)
        let selectedPromoCodeArray = promoCodeDropDownArray.filter({$0.name == item})
        selectedPromoCodeArrayValue.append(selectedPromoCodeArray.first?.name ?? "")
        self.promoCodeDropDownSelectedId = selectedPromoCodeArray.first?.promotionCodeId ?? 0
        self.promocodeDropDownSelectedDiscount = selectedPromoCodeArray.first?.discount ?? 0.0
        
    }
    
//    func DropDownDefaultfunctionForTableCell(_ view:UIView,_ width:CGFloat,_ values:[String], _ selectedIntex:Int,delegate:DropDownForTableViewCellDelegate?,tag:Int,cell:Int)
//    {
//        let dropDown = DropDown()
//        let appearance = DropDown.appearance()
//        appearance.cellHeight = 50
//        dropDown.anchorView =  view
//        dropDown.dismissMode = .onTap
//        dropDown.width = width + 15
//        dropDown.dataSource = values
//        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
//        dropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
//        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
//            guard let cell = cell as? MyCell else { return }
//            if selectedIntex == index || selectedIntex == -2 {
//
//                cell.optionLabel.textColor = UIColor.black
//            }else{
//
//                cell.optionLabel.textColor = UIColor.gray
//            }
//
//        }
//        dropDown.show()
//        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//
//            delegate?.DropDownDidSelectedAction(index: index, item: item, tag: tag, cell: cell)
//        }
//
//
//
//
//    }
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        if isPromoBtnClicked == false
        {
            self.deleteDiscountArrayFromDb()
            discountArray = [DiscountDetailStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
            self.newPrice = 0.0
            reloadTableAndAnimateHeight()
            setUIofApplyButton(isEnable: false)
            self.discountDelegate?.discountApplied(discountAmount: 0.0, discountArray: self.discountArray, isDiscountApplied: false)
        }
        else
        {
            selectedPromoCodeArrayValue.removeAll()
            promocodeCollectionViewHeightConstraint.constant = 0
            discountTableViewHeightConstraint.constant = 0
            promoCodeCollectionview.reloadData()
            self.promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
            promoDropDownBtn.isUserInteractionEnabled = true
            dropDownTextfield.text = ""
            dropDownTextfield.attributedPlaceholder = NSAttributedString(
                string: "Select promotion",
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }
    }
    
    func findWhichDiscountIsBeingApplied() -> (UITextField,DiscountEnum){
        switch true {
        case !promoCodeTextField.text!.isEmpty:
            return (promoCodeTextField,.promo)
        case !discountDollarTextField.text!.isEmpty:
            return (discountDollarTextField,.amount)
        case !discountPercentageTextField.text!.isEmpty:
            return (discountPercentageTextField,.percentage)
        default:
            return (UITextField(),.none)
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        if isPromoBtnClicked == false
        {
            let totalDiscount = discountArray.map({$0.discountValue}).reduce(0, +)
            print(totalDiscount)
            if totalDiscount > 0.0 {
            self.discountDelegate?.discountApplied(discountAmount: totalDiscount, discountArray: self.discountArray, isDiscountApplied: true)
            }
            else
            {
                self.discountDelegate?.discountApplied(discountAmount: totalDiscount, discountArray: self.discountArray, isDiscountApplied: false)
            }
            self.dismiss(animated: true)
        }
        else
        {
//            let totalDiscount = promoDiscountArray.map({$0.discountValue}).reduce(0, +)
//            print(totalDiscount)
//            // if totalDiscount > 0{
//            self.discountDelegate?.promoDiscountApplied(discountAmount: promocodeDropDownSelectedDiscount, ispromoApplies: true, discountArray: self.promoDiscountArray)
//            // }
//            self.dismiss(animated: true)
        }
    }
    
    @IBAction func promoSuccessDoneAction(_ sender: UIButton) {
        self.viewHeightConstraint.priority = .defaultLow
        self.discountView.borderColor = UIColor().colorFromHexString("707070")
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear) {
            self.promoSuccessViewWidthConstraint.constant = 482
            self.promoSuccessViewHeightConstraint.constant = 319
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.viewHeightConstraint.constant = self.previousHeightOfDiscountView
                self.viewLeadingConstraint.constant = 87
                self.viewTrailingConstraint.constant = 87
                self.promoSuccessView.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @IBAction func applyAction(_ sender: UIButton) {
        if isPromoBtnClicked == false
        {
            if promoCodeTextField.text == "" && discountDollarTextField.text == "" && discountPercentageTextField.text == ""
            {
                return
            }
            self.wrongWhenFirstItem = false
            if discountArray.filter({$0.cellType == .discountValuCell}).count == 8{
                //show max discount allowed exceeded
                self.alert("Maximum discount limit exceeded", nil)
                return
            }
            if discountArray.contains(where: {$0.cellType == .initialSalePriceCell}){
                discountArray = discountArray.filter({$0.cellType != .initialSalePriceCell})
            }
            if !discountArray.contains(where: {$0.cellType == .titleCell}){
                let discountTitle = DiscountDetailStruct(cellType: .titleCell)
                discountArray.append(discountTitle)
            }
            if discountArray.contains(where: {$0.cellType == .finalPriceCell}){
                discountArray = discountArray.filter({$0.cellType != .finalPriceCell})
            }
            let (valueEnteredDiscountTextField,discountType) = findWhichDiscountIsBeingApplied()
            switch discountType {
            case .promo:
                var discountAmtDouble :Double = Double()
                print("Promo code: " + valueEnteredDiscountTextField.text!)
                //check from db the type of discount alloted for this promo code
                let enteredPromoCode = valueEnteredDiscountTextField.text!
                if self.promoCodeArray.contains(where: {($0.code ?? "") == enteredPromoCode}){
                    var discountAmt = "0"
                    self.view.endEditing(true)
                    //1.accordlingly calculate the discount
                    let promoCodeObj = promoCodeArray.filter("code == %@",enteredPromoCode)
                    let enteredPromoCodeDisplayName = promoCodeObj.first?.displayName ?? ""
                    if (promoCodeObj.value(forKey: "type") as! NSArray)[0] as! String == "Dollars"{
                        discountAmt = (promoCodeObj.value(forKey: "amount") as! NSArray)[0] as! String
                    }else if (promoCodeObj.value(forKey: "type") as! NSArray)[0] as! String  == "Percent"{
                        let discountPercentageStr = (promoCodeObj.value(forKey: "amount") as! NSArray)[0] as! String
                        let discountPercentage = Double(discountPercentageStr) ?? 0.0
                        discountAmtDouble =  newPrice == 0 ? (totalAmount * (discountPercentage/100)) : (newPrice * (discountPercentage/100))
                        SavingPrice = SavingPrice + discountAmtDouble
                        discountAmt = String(discountAmtDouble)
                    }
                    let discountData = createDiscountDataToAddToArray(discountEntered: discountAmt, discountType:discountType ,promoCode:valueEnteredDiscountTextField.text!,promoCodeDisplayName: enteredPromoCodeDisplayName)
                    //                if SavingPrice != 0 && oneYearPrice != 0
                    //                {
                    //
                    //                    if (SavingPrice / oneYearPrice * 100 ) > 35
                    //                    {
                    //                        self.alert("Discount should not be greater than 35%", nil)
                    //                        return
                    //                    }
                    //
                    //                }
                    if discountData.newPrice < self.minimumFee{
                        //self.alert("New sale price cannot be less than $\(self.minimumFee)", nil)
                        //Updated Changes
                        self.alert(AppAlertMsg.maxDiscountAmountMessage, nil)
                        break
                    }else{
                        discountArray.append(discountData)
                        self.newPrice = discountData.newPrice
                    }
                    //2. show success popUp
                    self.previousHeightOfDiscountView = self.viewHeightConstraint.constant
                    self.viewHeightConstraint.priority = .required
                    self.discountView.borderColor = .clear
                    UIView.animate(withDuration: 0.3, animations: {
                        self.viewLeadingConstraint.constant = (self.view.frame.width-482)/2
                        self.viewTrailingConstraint.constant = (self.view.frame.width-482)/2
                        self.viewHeightConstraint.constant = 319
                        self.view.layoutIfNeeded()
                    }) { _ in
                        self.promoSuccessView.isHidden = false
                        if let savedDiscountPopupImage =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:enteredPromoCode){
                            self.promoSuccessImageView.image = savedDiscountPopupImage
                        }else{
                            self.promoSuccessImageView.image = UIImage(named: "promoSuccess")
                        }
                        self.view.layoutIfNeeded()
                        //arb***
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                            self.promoSuccessViewWidthConstraint.constant = (self.view.frame.width-200)
                            self.promoSuccessViewHeightConstraint.constant = (self.view.frame.height-200)
                        }
                    }
                    
                }else{
                    // not correct promo code
                    if discountArray.count == 1{
                        discountArray.removeAll()
                        discountArray = [DiscountDetailStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
                        self.wrongWhenFirstItem = true
                    }
                    self.alert("Please enter a valid promo code", nil)
                }
                break
            case .amount:
                print("Discount amount: " + valueEnteredDiscountTextField.text!)
                let discountAmt = Double(valueEnteredDiscountTextField.text ?? "0") ?? 0.0
                if (discountAmt > 0){
                    let discountData = createDiscountDataToAddToArray(discountEntered: valueEnteredDiscountTextField.text!, discountType: discountType)
                    SavingPrice = SavingPrice + discountAmt
                    //                if SavingPrice != 0 && oneYearPrice != 0
                    //                {
                    //
                    //                    if (SavingPrice / oneYearPrice * 100 ) > 35
                    //                    {
                    //                        self.alert("Discount should not be greater than 35%", nil)
                    //                        return
                    //                    }
                    //
                    //                }
                    if discountData.newPrice < self.minimumFee{
                        //self.alert("New sale price cannot be less than $\(Int(self.minimumFee))", nil)
                        //Updated Changes
                        self.alert(AppAlertMsg.maxDiscountAmountMessage, nil)
                    }else{
                        discountArray.append(discountData)
                        self.newPrice = discountData.newPrice
                    }
                }else{
                    self.alert("Please enter a valid discount", nil)
                }
                break
            case .percentage:
                let discountPercentage = Double(valueEnteredDiscountTextField.text!) ?? 0.0
                let discountAmount = newPrice == 0 ? (totalAmount * (discountPercentage/100)) : (newPrice * (discountPercentage/100))
                if (discountAmount > 0){
                    SavingPrice  = SavingPrice + discountAmount
                    //                if SavingPrice != 0 && oneYearPrice != 0
                    //                {
                    //
                    //                    if (SavingPrice / oneYearPrice * 100 ) > 35
                    //                    {
                    //                        self.alert("Discount should not be greater than 35%", nil)
                    //                        return
                    //                    }
                    //
                    //                }
                    let discountData = createDiscountDataToAddToArray(discountEntered:String(discountAmount) , discountType: discountType, discountPercentage:discountPercentage)
                    if discountData.newPrice < self.minimumFee{
                        //self.alert("New sale price cannot be less than $\(Int(self.minimumFee))", nil)
                        //Updated Changes
                        self.alert(AppAlertMsg.maxDiscountAmountMessage, nil)
                    }else{
                        discountArray.append(discountData)
                        self.newPrice = discountData.newPrice
                    }
                }else{
                    self.alert("Please enter a valid discount", nil)
                }
                break
            case .none:
                self.alert("Please input the discount to apply", nil)
                return
            }
            //        if SavingPrice != 0 && oneYearPrice != 0
            //        {
            //
            //            if (SavingPrice / oneYearPrice * 100 ) > 35
            //            {
            //                self.alert("Discount should not be greater than 35%", nil)
            //            }
            //        }
            promoCodeTextField.text = ""
            discountDollarTextField.text = ""
            discountPercentageTextField.text = ""
            if self.discountArray.filter({$0.cellType != .titleCell }).count == 0{
                self.wrongWhenFirstItem = true
                discountArray = [DiscountDetailStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
            }
            if !self.wrongWhenFirstItem{
                let finalPriceCell = DiscountDetailStruct(cellType: .finalPriceCell)
                discountArray.append(finalPriceCell)
                self.wrongWhenFirstItem = false
            }
            reloadTableAndAnimateHeight()
        }
        else
        {
            if dropDownTextfield.text == ""
            {
                return
            }
            else
            {
                promoDiscountArray = [PromoDropDownStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
                promocodeCollectionViewHeightConstraint.constant = 71
                // discountTableViewHeightConstraint.constant = 0
                self.promoCodeCollectionview.isHidden = false
                self.promoCodeCollectionview.reloadData()
                reloadTableAndAnimateHeight()
                self.promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#667483")
                promoDropDownBtn.isUserInteractionEnabled = false
                dropDownTextfield.attributedPlaceholder = NSAttributedString(
                    string: "Select promotion",
                    attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
                )
                setUIofApplyButton(isEnable: false)
                }
            
        }
        
    }
    func createDiscountDropDownDataToAddToArray() -> PromoDropDownStruct
    {
        let discountData = PromoDropDownStruct(salePrice: totalAmount, newPrice: newPrice,discountValue: SavingPrice,discountPromoCodeDisplayName: dropDownTextfield.text!,cellType: .discountValuCell)
        return discountData
    }
    
    func createDiscountDataToAddToArray(discountEntered:String,discountType:DiscountEnum,promoCode: String = "", discountPercentage: Double = 0.0,promoCodeDisplayName:String = "") -> DiscountDetailStruct{
        let salePrc = discountArray.filter({$0.cellType == .discountValuCell}).count == 0 ? totalAmount : self.newPrice
        switch discountType {
        case .promo:
            let discountAmountDouble = Double(discountEntered) ?? 0.0
            let newPrice = self.newPrice == 0 ? (salePrc - discountAmountDouble) : (self.newPrice - discountAmountDouble)
            let discountData = DiscountDetailStruct(salePrice:salePrc , newPrice: newPrice, discountValue: discountAmountDouble, discountPromoCode: promoCode, discountPromoCodeDisplayName: promoCodeDisplayName, discountPercentage: 0.0, discountType: .promo, cellType: .discountValuCell)
            return discountData
        case .amount:
            let discountAmountDouble = Double(discountEntered) ?? 0.0
            let newPrice = self.newPrice == 0 ? (salePrc - discountAmountDouble) : (self.newPrice - discountAmountDouble)
            let discountData = DiscountDetailStruct(salePrice:salePrc , newPrice: newPrice, discountValue: discountAmountDouble, discountPromoCode: "", discountPercentage: 0.0, discountType: .amount, cellType: .discountValuCell)
            return discountData
        case .percentage:
            let discountAmountDouble = Double(discountEntered) ?? 0.0
            let newPrice = self.newPrice == 0 ? (salePrc - discountAmountDouble) : (self.newPrice - discountAmountDouble)
            let discountData = DiscountDetailStruct(salePrice:salePrc , newPrice: newPrice, discountValue: discountAmountDouble, discountPromoCode: "", discountPercentage: discountPercentage, discountType: .percentage, cellType: .discountValuCell)
            return discountData
        case .none:
            return DiscountDetailStruct(cellType: .finalPriceCell)
        }
    }
    
}
extension PromoPopUpViewControllerNew: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
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
        return CGSize(width: label.frame.width + 30 + 46 + 20, height: 56)
        //return CGSize(width: selectedPromoCodeArrayValue[indexPath.item].size.width + 30, height: 56)
    }
    @objc func deletePromoAdded(sender:UIButton)
    {
       
        selectedPromoCodeArrayValue.removeAll()
        //promoDiscountArray.removeAll()
        promocodeCollectionViewHeightConstraint.constant = 0
        reloadTableAndAnimateHeight()
        discountTableViewHeightConstraint.constant = 0
        promoCodeCollectionview.reloadData()
        self.promoCodeDropDownView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        promoDropDownBtn.isUserInteractionEnabled = true
        dropDownTextfield.text = ""
        dropDownTextfield.attributedPlaceholder = NSAttributedString(
            string: "Select promotion",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
    }

    
    
}

extension PromoPopUpViewControllerNew: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return discountArray.count
     
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if isPromoBtnClicked == false
//        {
            if discountArray.count == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TotalPriceTableViewCell") as! TotalPriceTableViewCell
                cell.totalSavingsStackView.isHidden = true
                cell.newInitialPriceLabel.text = "$ \(Int(totalAmount))"
                cell.newPriceStackView.isHidden = true
                cell.newPriceInitialStackView.isHidden = false
                return cell
            }else{
                switch discountArray[indexPath.row].cellType {
                case .titleCell:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DiscountTitleTableViewCell") as! DiscountTitleTableViewCell
                    return cell
                case .discountValuCell:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DiscountTableViewCell") as! DiscountTableViewCell
                    let salesPrice = "$ \(Int(discountArray[indexPath.row].salePrice))"
                    cell.salePriceLabel.text = indexPath.row == 1 ? salesPrice : ""
                    let discount = "$ \(Int(discountArray[indexPath.row].discountValue.rounded()))"
                    cell.discountLabel.text = discount
                    let newPrice = "$ \(Int(discountArray[indexPath.row].newPrice.rounded()))"
                    cell.newPriceLabel.text = newPrice
                    if discountArray[indexPath.row].discountType == .promo{
                        cell.saleLabel.text = "\(discountArray[indexPath.row].discountPromoCodeDisplayName)"
                    }else if discountArray[indexPath.row].discountType == .amount{
                        cell.saleLabel.text = "$ \(Int(discountArray[indexPath.row].discountValue.rounded()))"
                    }else if discountArray[indexPath.row].discountType == .percentage{
                        cell.saleLabel.text = "\(Int(discountArray[indexPath.row].discountPercentage)) %"
                    }
                    cell.deleteDiscountButton.tag = indexPath.row
                    cell.deleteDiscountButton.addTarget(self, action: #selector(deleteDiscountAdded(sender:)), for: .touchUpInside)
                    return cell
                case .finalPriceCell:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TotalPriceTableViewCell") as! TotalPriceTableViewCell
                    cell.totalSavingsStackView.isHidden = false
                    cell.newPriceLabel.text = "$ \(Int(discountArray[discountArray.count-2].newPrice.rounded()))"
                    cell.newPriceStackView.isHidden = false
                    cell.newPriceInitialStackView.isHidden = true
                    let discountValueArray = (discountArray.filter({$0.cellType == .discountValuCell}))
                    let totalDiscountAmount = discountValueArray.reduce(0.0) { $0 + ($1.discountValue) }
                    cell.totalSavingsLabel.text = "$ \(Int(totalDiscountAmount.rounded()))"
                    return cell
                default:
                    return UITableViewCell()
                }
            }
        }
//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isPromoBtnClicked == false
        {
            return ((discountArray[indexPath.row].cellType == .initialSalePriceCell || discountArray[indexPath.row].cellType == .finalPriceCell) ? 69 : 54)
        }
        else
        {
            return ((promoDiscountArray[indexPath.row].cellType == .initialSalePriceCell || promoDiscountArray[indexPath.row].cellType == .finalPriceCell) ? 69 : 54)
        }
    }
    
    @objc func deleteDiscountAdded(sender:UIButton){
//        if isPromoBtnClicked == false
//        {
            var selectedPosition = sender.tag
            discountArray.remove(at: selectedPosition)
            if selectedPosition == 1 && discountArray.filter({$0.cellType == .discountValuCell}).count == 0{ //only one discount item was present
                discountArray = [DiscountDetailStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
                selectedPosition = 0
                newPrice = totalAmount
                setUIofApplyButton(isEnable: false)
            }else{
                if discountArray.filter({$0.cellType == .discountValuCell}).count != 0 {
                    if selectedPosition-1 > 0{
                        newPrice = discountArray[selectedPosition-1].newPrice
                    }else{
                        newPrice = totalAmount
                    }
                }else{
                    newPrice = totalAmount
                }
            }
            
            for i in selectedPosition..<discountArray.count-1 {
                let discountType = discountArray[i].discountType!
                switch discountType {
                case .promo:
                    var discountAmt = "0"
                    let enteredPromoCode = discountArray[i].discountPromoCode
                    let enteredPromoCodeDisplayName = discountArray[i].discountPromoCodeDisplayName
                    let promoCodeObj = promoCodeArray.filter("code == %@",enteredPromoCode)
                    if (promoCodeObj.value(forKey: "type") as! NSArray)[0] as! String == "Dollars"{
                        discountAmt = (promoCodeObj.value(forKey: "amount") as! NSArray)[0] as! String
                    }else if (promoCodeObj.value(forKey: "type") as! NSArray)[0] as! String  == "Percent"{
                        let discountPercentageStr = (promoCodeObj.value(forKey: "amount") as! NSArray)[0] as! String
                        let discountPercentage = Double(discountPercentageStr) ?? 0.0
                        let discountAmtDouble =  newPrice == 0 ? (totalAmount * (discountPercentage/100)) : (newPrice * (discountPercentage/100))
                        discountAmt = String(discountAmtDouble)
                    }
                    let discountData = createDiscountDataToAddToArray(discountEntered: discountAmt, discountType:discountType ,promoCode:enteredPromoCode,promoCodeDisplayName: enteredPromoCodeDisplayName)
                    if discountData.newPrice > self.minimumFee{
                        self.newPrice = discountData.newPrice
                        discountArray[i] = discountData
                    }
                    break
                case .amount:
                    let amt = String(discountArray[i].discountValue)
                    let discountData = createDiscountDataToAddToArray(discountEntered: amt , discountType: discountType)
                    if discountData.newPrice > self.minimumFee{
                        self.newPrice = discountData.newPrice
                        discountArray[i] = discountData
                    }
                    break
                case .percentage:
                    let discountPercentage = Double(discountArray[i].discountPercentage)
                    let discountAmount = newPrice == 0 ? (totalAmount * (discountPercentage/100)) : (newPrice * (discountPercentage/100))
                    let discountData = createDiscountDataToAddToArray(discountEntered:String(discountAmount) , discountType: discountType, discountPercentage:discountPercentage)
                    if discountData.newPrice > self.minimumFee{
                        self.newPrice = discountData.newPrice
                        discountArray[i] = discountData
                    }
                    break
                default:
                    break
                }
            }
       // }
//        else
//        {
//            var selectedPosition = sender.tag
//            promoDiscountArray.remove(at: selectedPosition)
//            if selectedPosition == 1 && promoDiscountArray.filter({$0.cellType == .discountValuCell}).count == 0{ //only one discount item was present
//                promoDiscountArray = [PromoDropDownStruct(cellType: .initialSalePriceCell, salePrice: totalAmount)]
//                selectedPosition = 0
//                newPrice = totalAmount
//                setUIofApplyButton(isEnable: false)
//                dropDownTextfield.attributedPlaceholder = NSAttributedString(
//                    string: "Select promotion",
//                    attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
//                )
//            }
//        }
        self.reloadTableAndAnimateHeight()
    }
}


extension PromoPopUpViewControllerNew:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setUIofApplyButton(isEnable: true)
        if textField.tag == 1{
            print("promo code textfield clicked")
            setUIofTextFields(selectedTextField: DiscountEnum.promo)
            
        }else if textField.tag == 2{
            print("discount $ textfield clicked")
            setUIofTextFields(selectedTextField: DiscountEnum.amount)
            
        }else if textField.tag == 3{
                print("discount % textfield clicked")
            setUIofTextFields(selectedTextField: DiscountEnum.percentage)
        }
        self.adjustKeyboardTextFieldHeight()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag != 1{
//            if textField.text != "" || string != "" {
//                let res = (textField.text ?? "") + string
//                return Double(res) != nil
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
            //}
        }else{
            return true
        }
    }
    
}


enum DiscountEnum{
    case promo
    case amount
    case percentage
    case none
}
        
 enum DiscountCellType{
    case initialSalePriceCell
    case titleCell
    case discountValuCell
    case finalPriceCell
}

struct DiscountDetailStruct {
    var salePrice : Double = 0
    var newPrice : Double = 0
    var discountValue : Double = 0
    var discountPromoCode : String = ""
    var discountPromoCodeDisplayName : String = ""
    var discountPercentage : Double = 0
    var discountType : DiscountEnum? = nil
    var cellType : DiscountCellType
}

struct PromoDropDownStruct {
    var salePrice : Double = 0
    var newPrice : Double = 0
    var discountValue : Double = 0
    var discountPromoCodeDisplayName : String = ""
    var cellType : DiscountCellType
}


extension DiscountDetailStruct{
        
        init(cellType: DiscountCellType ,salePrice: Double) {
            self.cellType = cellType
            self.salePrice = salePrice
        }
                
        init(cellType: DiscountCellType ) {
            self.cellType = cellType
        }
}

extension PromoDropDownStruct{
        
        init(cellType: DiscountCellType ,salePrice: Double) {
            self.cellType = cellType
            self.salePrice = salePrice
        }
                
        init(cellType: DiscountCellType ) {
            self.cellType = cellType
        }
}
