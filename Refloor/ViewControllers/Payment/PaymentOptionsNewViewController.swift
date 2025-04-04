//
//  PaymentOptionsViewController.swift
//  Refloor
//
//  Created by sbek on 17/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift


class PaymentOptionsNewViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PromoPopUpViewDelegate,DiscountProtocol, PromoDiscoundProtocol {
    func promocodeApplied(promocodeArray: [String], promoCodeDropDownSelectedId: Int, promocodeDropDownSelectedDiscount: Double,calculationType: String)
    {
        savingsArray.removeAll()
        savingsArrayDouble.removeAll()
        salePriceDouble.removeAll()
        promoValue = promocodeDropDownSelectedDiscount
        self.promoCodeDropDownSelectedId = promoCodeDropDownSelectedId
        self.calculationType = calculationType
        promoDiscountArray = promocodeArray
        
        if promocodeArray.count > 0
        {
            self.isPromoApplied = true
            self.isPromoForPaymentRestriction = true
        }
        else
        {
            self.isPromoApplied = false
            self.isPromoForPaymentRestriction = true
        }
        self.selectedOption = -1
        paymentOptionDataValueDetail = paymentRestrictionDataValueDetail
        for index in paymentOptionDataValueDetail
        {
            index.isHidden = false
        }
        restrictedPromo.removeAll()
        restrictedDiscount.removeAll()
        isApplicableRoom()
        planCollectionView.reloadData()
        
    }
    
    
  
    
    
    
    
    static func initialization() -> PaymentOptionsNewViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentOptionsNewViewController") as? PaymentOptionsNewViewController
    }
    @IBOutlet weak var adjustmentLabel: UILabel!
    @IBOutlet weak var financeOptionHeadingLabel: UILabel!
    @IBOutlet weak var planCollectionView: UICollectionView!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    @IBOutlet weak var promoButton: UIButton!
    
    @IBOutlet weak var discountBtn: UIButton!
    
    var paymentPlanValueDetails:[PaymentPlanValue] = []
    //var availablepaymentPlanValueDetails:[PaymentPlanValue]? = nil
    var paymentOptionDataValueDetail:[PaymentOptionDataValue] = []
    var paymentRestrictionDataValueDetail:[PaymentOptionDataValue] = []
    var paymentMeterialDataValueDetails:[PaymentMeterialDataValue] = []
    var paymentMonthlyPromo:[MonthlyPromoDataValue] = []
    var imagePicker: CaptureImage!
    var stairCount:Int = 0
    var adminFee = ""
    var minimumFee = 0.0
    var selectedPlan = -1
    var IsEligibleForDiscounts = 0
    var discount_exclude_amount:Double = 0
    var selectedOption = -1
    var area:Double = 0
    var adjestmentValue:Double = 0
    var PromoCodeValue:Double = 0
    var monthlyValue:Double = 0
    var downOrFinal:Double = 0
    var amountTotel:Double = 0
    var actualSalePrice:Double = 0
    var emiAmount:Double = 0
    var paymentFactor:Double = 0
    var applyedPromoCode : String = ""
    var applyedDiscountValue  :Double = 0
    var applyediscountPercentage  :Double = 0
    var savings : String = ""
    var oneYrPrice : String = ""
    var totalUpchargeCost: Double = 0.0
    var totalExtraCost: Double = 0.0
    
    var totalMoldingPrice: Double = 0.0
    var totalExtraCostToReduce: Double = 0.0
    var totalExtraPromoCostToReduced: Double = 0.0
    var  additionalCost :Double = 0.0
    var discountArray:[DiscountDetailStruct] = []
    var isProgressiveDiscountApplied = false
    var isroomSpclPriceApplied = false
    var isStairsSpclPriceApplied = false
    var isPromoDiscountApplied = false
    var roomspecialPriceId:Int = Int()
    var stairsspecialPriceId:Int = Int()
    //var promoCodeArray:List<rf_master_discount>!
    var specialPriceTable:Results<rf_specialPrice_results>!
    var ruleList:Results<rf_ruleList_results>!
    var isDiscountApplied = false
    var isPromoApplied = false
    var isPromoForPaymentRestriction = false
    var promoCodeDropDownSelectedId:Int = Int()
    var promoValue: Double = Double()
    var promoDiscountArray:[String] = []
    var calculationType:String = String()
    var savingsArray:[String] = []
    var savingsArrayDouble:[Double] = []
    var salePriceDouble:[Double] = []
    var stairPrice:Double = Double()
    var appointmentOfficeLocationId:Int = Int()
    var appointmentDate :Date = Date()
    var productPaymentMethod = List<rf_master_payment_option>()
    var OneYearPrice:Double = Double()
    var restrictedPromo:[[Int:String]] = [[:]]
    var restrictedDiscount:[[Int:String]] = [[:]]
    var vapurBarrierValue:Double = 0.0
    override func viewWillAppear(_ animated: Bool)
    {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationPackageBarbackAndlogo(with: "Select package".uppercased())
        //arb
        let masterData = self.getMasterDataFromDB()
        specialPriceTable = specialPriceTable()
        ruleList = ruleListTable()
        var roomStartDate:Date = Date()
        var roomEndDate:Date = Date()
        var stairStartDate:Date = Date()
        var stairEndDate:Date = Date()
        var spclPriceOfficeLOcationId:Int = Int()
        var stairSpclPriceOfficeLOcationId:Int = Int()
        var successRuleListpaymentOptId = Set<Int>()
        
        
       appointmentOfficeLocationId = self.getMasterAppointmentOfficeLocationId()
        appointmentDate = (AppDelegate.appoinmentslData.appointment_date?.logDate())!

        if specialPriceTable.count > 0
        {
            
             spclPriceOfficeLOcationId = masterData.specialPrice[0].officeLocationId
            // getHoursFromGmt()
            roomStartDate = (masterData.specialPrice[0].startDate?.logDate())!
            roomEndDate = (masterData.specialPrice[0].endDate?.logDate())!
             stairSpclPriceOfficeLOcationId = masterData.specialPrice[1].officeLocationId
            stairStartDate = (masterData.specialPrice[1].startDate?.logDate())!
            stairEndDate = (masterData.specialPrice[1].endDate?.logDate())!
            
        }
        let isRoomTodaysDateQualified = appointmentDate.isBetween(date: roomStartDate, andDate: roomEndDate)
        // stairs
        
        
        let isSatirsTodaysDateQualified = appointmentDate.isBetween(date: stairStartDate, andDate: stairEndDate)
        
        //self.minimumFee = masterData.min_sale_price
        
        if (appointmentOfficeLocationId == spclPriceOfficeLOcationId) && isRoomTodaysDateQualified == true
        {
            isroomSpclPriceApplied = true
            roomspecialPriceId = specialPriceTable[0].specialPriceId
        }
        else
        {
            isroomSpclPriceApplied = false
            roomspecialPriceId = 0
        }
        if (appointmentOfficeLocationId == spclPriceOfficeLOcationId) && isSatirsTodaysDateQualified == true
        {
            isStairsSpclPriceApplied = true
            stairsspecialPriceId = specialPriceTable[1].specialPriceId
        }
        else
        {
            isStairsSpclPriceApplied = false
            stairsspecialPriceId = 0
        }
        productPaymentMethod = masterData.payment_options
        let paymentPlans = masterData.product_plans
        let discountCoupons = masterData.discount_coupons
        for paymentPlan in paymentPlans{
            self.paymentPlanValueDetails.append( PaymentPlanValue(paymentPlan: paymentPlan))
        }
        for paymentMethod in productPaymentMethod{
            self.paymentRestrictionDataValueDetail.append(PaymentOptionDataValue(paymentOption: paymentMethod))
        }
        for discount in discountCoupons{
            self.paymentMonthlyPromo.append(MonthlyPromoDataValue(discountPromo: discount))
        }
        let appointmentId = AppointmentData().appointment_id ?? 0
        let rooms = getCompletedRoomFromDB(appointmentId: appointmentId)
        for room in rooms{
            let paymentMeterial = PaymentMeterialDataValue()
            paymentMeterial.color = room.selected_room_color
            paymentMeterial.name = room.selected_room_color
            paymentMeterial.material_image_url = room.material_image_url
            self.paymentMeterialDataValueDetails.append(paymentMeterial)
        }
        //
        //self.paymentTypeApiCall()
        self.paymentCollectionView.reloadData()
        self.planCollectionView.reloadData()
        self.adjustmentLabel.startBlink()
    }
    
    func isApplicableRoom()
    {
        var isPaymentRestrict = false
        if ruleList.count > 0
        {
            for rules in ruleList
            {
                if appointmentDate.isBetween(date: (rules.start_date?.logDate())!, andDate: (rules.end_date?.logDate())!)
                {
                    for locationDetails in rules.office_location
                    {
                        if locationDetails.office_location_id == appointmentOfficeLocationId
                        {
                            let weekday = getTodayWeekDay()
                            for weekdays in rules.allowed_days
                            {
                                if weekdays.allowed_name == weekday
                                {
                                    switch rules.conditions
                                    {
                                    case "amount":
                                        if Int(OneYearPrice) <= rules.amount
                                        {
                                            isPaymentRestrict = true
                                            if rules.restricted_promotions.count > 0
                                            {
                                                for promotions in rules.restricted_promotions
                                                {
                                                    restrictedPromo.append([promotions.promotion_id : promotions.promotion_name!])
                                                }
                                            }
                                            
                                            if rules.restricted_discount.count > 0
                                            {
                                                for discounts in rules.restricted_discount
                                                {
                                                    restrictedDiscount.append([discounts.discount_id : discounts.discount_name!])
                                                }
                                            }
                                        }
                                        else
                                        {
                                            isPaymentRestrict = false
                                        }
                                    case "grade":
                                        if rules.grade == self.paymentPlanValueDetails[self.selectedPlan].grade
                                        {
                                            isPaymentRestrict = true
                                            if rules.restricted_promotions.count > 0
                                            {
                                                for promotions in rules.restricted_promotions
                                                {
                                                    restrictedPromo.append([promotions.promotion_id : promotions.promotion_name!])
                                                }
                                            }
                                            
                                            if rules.restricted_discount.count > 0
                                            {
                                                for discounts in rules.restricted_discount
                                                {
                                                    restrictedDiscount.append([discounts.discount_id : discounts.discount_name!])
                                                }
                                            }
                                         }
                                         else
                                         {
                                             isPaymentRestrict = false
                                         
                                         }
                                        
//                                    case "margin":
//                                        if OneYearPrice <= self.paymentPlanValueDetails[self.selectedPlan].minimum_Sale_price ?? 1500
//
//                                        {
//                                           isPaymentRestrict = true
//                                            if rules.restricted_promotions.count > 0
//                                            {
//                                                for promotions in rules.restricted_promotions
//                                                {
//                                                    restrictedPromo.append([promotions.promotion_id : promotions.promotion_name!])
//                                                }
//                                            }
//
//                                            if rules.restricted_discount.count > 0
//                                            {
//                                                for discounts in rules.restricted_discount
//                                                {
//                                                    restrictedDiscount.append([discounts.discount_id : discounts.discount_name!])
//                                                }
//                                            }
//                                        }
//                                        else
//                                        {
//                                            isPaymentRestrict = false
//
//                                        }
                                    case "promotions":
                                        if isPromoForPaymentRestriction
                                        {
                                            if rules.conditional_promotions.count > 0
                                            {
                                                for conditionsPromotions in rules.conditional_promotions
                                                {
                                                    if promoCodeDropDownSelectedId == conditionsPromotions.conditional_id
                                                    {
                                                        isPaymentRestrict = true
                                                        if rules.restricted_promotions.count > 0
                                                        {
                                                            for promotions in rules.restricted_promotions
                                                            {
                                                                restrictedPromo.append([promotions.promotion_id : promotions.promotion_name!])
                                                            }
                                                        }
                                                        
                                                        if rules.restricted_discount.count > 0
                                                        {
                                                            for discounts in rules.restricted_discount
                                                            {
                                                                restrictedDiscount.append([discounts.discount_id : discounts.discount_name!])
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        isPaymentRestrict = false
                                                        
                                                    }
                                                }
                                            }
                                            
                                        }
                                            
                                        
                                        
                                    
                                    default:
                                        break
                                    }
                                    if isPaymentRestrict
                                    {
                                        if rules.payment_options.count > 0
                                        {
                                            for paymentOptions in rules.payment_options
                                            {
                                                let Index = paymentOptionDataValueDetail.firstIndex(where: {$0.id == paymentOptions.paymentOption_id})
                                                //paymentOptionDataValueDetail.filter({$0.id == paymentOptions.paymentOption_id})
                                                paymentOptionDataValueDetail[Index!].isHidden = true
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        paymentCollectionView.reloadData()
    }
    
    
    @IBAction func changeAreaButtonAction(_ sender: Any) {
       // self.performSegueToReturnBack()
        if(self.selectedPlan != -1)
        {
            if(IsEligibleForDiscounts == 1)
            {
                let promo = PromoPopUpViewControllerNew.initialization()!
                promo.discountDelegate = self
                
                if self.discountArray.count > 0{
                    promo.discountArray = self.discountArray
                    promo.isProgressiveDiscountApplied = self.isProgressiveDiscountApplied
                }
                //promo.delegate = self
                promo.discountValue = applyedDiscountValue
                promo.restrictedDiscount = self.restrictedDiscount
                promo.exludedCost = self.totalExtraCostToReduce
                promo.discountPromoCode = applyedPromoCode
                promo.discountPercentage = applyediscountPercentage
                promo.minimumFee = self.paymentPlanValueDetails[self.selectedPlan].minimum_Sale_price ?? 1500.00
                var costpersqft:Double = Double()
                var msrppersqft:Double = Double()
                var stairperprice:Double = Double()
                var saleprice:Double = Double()
                if isroomSpclPriceApplied == true && (paymentPlanValueDetails[self.selectedPlan].id == specialPriceTable().first?.productTmplId)
                {
                  
                    costpersqft = specialPriceTable[0].listPrice
                    msrppersqft = specialPriceTable[0].msrp
                    
                }
                else
                {
                     costpersqft = (paymentPlanValueDetails[self.selectedPlan].cost_per_sqft ?? 0)
                     msrppersqft = (paymentPlanValueDetails[self.selectedPlan].cost_per_sqft ?? 0)
                }

                if isStairsSpclPriceApplied == true && (paymentPlanValueDetails[self.selectedPlan].stairProductId == specialPriceTable[1].productTmplId)
                {
                    stairperprice = specialPriceTable[1].msrp
                }
                else
                {
                    
                    stairperprice = (paymentPlanValueDetails[self.selectedPlan].stair_msrp ?? 0)
                }
                let stairPrice = Double(self.stairCount) * stairperprice
                var mrp = msrppersqft * area
                if calculationType == "sqft"
                {
                    saleprice = (self.isPromoApplied) ? (msrppersqft - promoValue) * area : (msrppersqft) * area
                    saleprice = saleprice + stairPrice
                    //saleprice = saleprice + Double(additional_cost)
                    saleprice = saleprice + additionalCost
                }
                else
                {
                    saleprice =  (self.isPromoApplied) ? (msrppersqft) * area : (msrppersqft) * area
//                    if self.isDiscountApplied
//                    {
//                        saleprice = msrppersqft - totalExtraCostToReduce * area
//                    }
//                    if self.isPromoApplied
//                    {
//                        saleprice = msrppersqft - totalExtraPromoCostToReduced * area
//                    }
//                    if self.isDiscountApplied == false && self.isPromoApplied == false
//                    {
//                        saleprice = msrppersqft * area
//                    }
               
                    //saleprice = saleprice + Double(additional_cost) +  stairPrice
                   saleprice = saleprice + additionalCost +  stairPrice
                    if calculationType == "fixed"
                    {
                        saleprice = saleprice - promoValue
                    }
                    else
                    {
                        //totalExtraPromoCostToReduced = totalExtraPromoCostToReduced + vapurBarrierValue
                        saleprice = saleprice - ((saleprice - (totalExtraPromoCostToReduced)) * promoValue / 100).rounded()
                    }
                }
                mrp = mrp + stairPrice
               // mrp = (mrp + Double(additional_cost)).rounded()
                mrp = (mrp + additionalCost).rounded()
                saleprice = saleprice.rounded()
                let prize = saleprice.rounded(.towardZero)
                if(prize < self.paymentPlanValueDetails[self.selectedPlan].minimum_Sale_price ?? 1500.00)
                {
                    promo.totalAmount = self.paymentPlanValueDetails[self.selectedPlan].minimum_Sale_price ?? 1500.00
                    
                }else{
                    promo.totalAmount = prize
                }
                
                promo.paymentMonthlyPromo = paymentMonthlyPromo
                if (isroomSpclPriceApplied == true || isStairsSpclPriceApplied == true) && ((paymentPlanValueDetails[self.selectedPlan].id == specialPriceTable[0].productTmplId) || paymentPlanValueDetails[self.selectedPlan].stairProductId == specialPriceTable[1].productTmplId)
                {
                    promo.oneYearPrice = mrp
                    promo.SavingPrice = mrp - saleprice
                }
                self.present(promo, animated: true, completion: nil)
            }
            else
            {
                self.alert("Discounts only apply to Smart Choice products", nil)
            }
            
            
        }
        else
        {
            self.alert("Select a package to continue", nil)
        }
    }
    
    @objc override func performSegueToReturnBack()  {
        
        if let nav = self.navigationController {
            self.deleteDiscountArrayFromDb()
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func promoDiscountApplied(discountAmount: Double, ispromoApplies: Bool, discountArray: [PromoDropDownStruct])
    {
//        isPromoDiscountApplied = ispromoApplies
//        promoValue = discountAmount
//        promoDiscountArray = discountArray
//        self.planCollectionView.reloadData()
        
    }
    
    func discountApplied(discountAmount:Double,discountArray:[DiscountDetailStruct],isDiscountApplied:Bool){
        savingsArray.removeAll()
        salePriceDouble.removeAll()
        savingsArrayDouble.removeAll()
        
        self.isDiscountApplied = isDiscountApplied
        print(discountAmount)
        if discountAmount == 0{
            self.adjestmentValue = 0
            self.discountArray = []
        }else{
            isProgressiveDiscountApplied = true
            self.discountArray = discountArray.filter({$0.cellType == .discountValuCell})
            self.adjestmentValue =  discountAmount
            self.deleteDiscountArrayFromDb()            //
            var discounts :[DiscountObject] = []
            //save discount array in db
            for discountObj in self.discountArray{
                let promoType = discountObj.discountType == .promo ? 1 : 0
                var type = ""
                var value = ""
                switch discountObj.discountType {
                case .promo:
                    let promoCode = discountObj.discountPromoCode
                    let promoCodeArray = self.getDiscountList()
                    if  promoCodeArray.contains(where: {($0.code ?? "") == promoCode}){
                        let promoCodeObj = promoCodeArray.filter("code == %@",promoCode)
                        if (promoCodeObj.value(forKey: "type") as! NSArray)[0] as! String == "Dollars"{
                            type = "amount"
                        }else{
                            type = "percentage"
                        }
                    }
                    value = discountObj.discountPromoCode
                case .amount:
                    type = "amount"
                    value = String(discountObj.discountValue)
                case .percentage:
                    type = "percentage"
                    value = String(discountObj.discountPercentage)
                default:
                    break
                }
                let discountAmount = discountObj.discountValue
                let actualPrice = discountObj.salePrice
                let salePrice = discountObj.newPrice
                let appointment_id = AppointmentData().appointment_id ?? 0
                let discount = DiscountObject(appointment_id: appointment_id, promoType: promoType, type: type, value: value, discountAmount: discountAmount, actualPrice: actualPrice, salePrice: salePrice, excluded_amount_discount: self.totalExtraCostToReduce)
                discounts.append(discount)
            }
            self.saveRealmArray(discounts)
        }
        let youSavedValue = (adjestmentValue + monthlyValue)
        if(selectedPlan != -1)
        {
            if(youSavedValue > 0)
            {
                self.adjustmentLabel.text = "YOU SAVED $\(youSavedValue).toRoundCommaString) !"
            }
        }
        else
        {
            self.adjustmentLabel.text = "YOU SAVED $0 !"
        }
        self.selectedOption = -1
        self.planCollectionView.reloadData()
    }
    
    
    @IBAction func adjustmentButtonAction(_ sender: Any)
    {
        if selectedPlan == -1
        {
            self.alert("Select a package to continue", nil)
        }
        else
        {
            
            if isDiscountApplied == true
            {
                self.alert("Discount must be removed, before promotion can be changed", nil)
                
            }
            else
            {
                let promo = PromoDropDownViewController.initialization()!
                promo.isPromoBtnClicked = true
                promo.promoCodeApplied = self
                promo.selectedPromoCodeArrayValue = promoDiscountArray
                promo.promocodeDropDownSelectedDiscount = promoValue
                promo.promoCodeDropDownSelectedId = self.promoCodeDropDownSelectedId
                promo.calculationType = self.calculationType
                promo.savingsArray = savingsArrayDouble
                promo.salePriceArray = salePriceDouble
                promo.minimumFee = self.minimumFee
                promo.area = self.area
                promo.restrictedPromo = self.restrictedPromo
                self.present(promo, animated: true, completion: nil)
            }
        }
        
        
    }
    
    func didApplyPromoCode(code: String)
    {
        
        //var code:String?
        //  var amount:String?
        // var type:String?
        var value :Double = 0
        if(code == "")
        {
            self.adjestmentValue =   self.adjestmentValue -  self.adjestmentValue
        }
        
        for promo in paymentMonthlyPromo
        {
            
            if(promo.code == code)
            {
                if(promo.type == "Percent")
                {
                    
                    value = calculatePercentage(value:amountTotel,percentageVal:Double(promo.amount ?? "0") ?? 0)
                    self.adjestmentValue = value
                }
                else
                {
                    self.adjestmentValue = Double(promo.amount ?? "0") ?? 0
                }
                
            }
            
        }
        if(value < 1.0)
        {
            self.alert("Please apply valid promo code", nil)
            // return
        }
        
        applyedPromoCode = code
        applyediscountPercentage=0
        applyedDiscountValue=0
        
        
        
        
        let youSavedValue = (adjestmentValue + monthlyValue)
        
        
        if(selectedPlan != -1)
        {
            if(youSavedValue > 0)
            {
                //self.adjustmentLabel.isHidden = false
                // self.adjustmentLabel.text = "YOU SAVED $\(youSavedValue).toRoundCommaString) !"
                
            }
            else
            {
                // self.adjustmentLabel.isHidden = true
            }
            //  self.adjustmentLabel.text = "YOU SAVED $\((adjestmentValue + monthlyValue).toRoundCommaString) !"
        }
        else
        {
            //self.adjustmentLabel.text = "YOU SAVED $0 !"
            //self.adjustmentLabel.isHidden = true
        }
        self.selectedOption = -1
        self.planCollectionView.reloadData()
        
        //        if(code == "AAAAA")
        //        {
        //             adminFee = "0"
        //        }
        //        else
        //        {
        //             adminFee = "195"
        //        }
        
    }
    
    func didApplyDiscountAtCash(cash: Double)
    {
        self.adjestmentValue = cash
        applyedDiscountValue = cash
        applyedPromoCode = ""
        applyediscountPercentage=0
        
        let youSavedValue = (adjestmentValue + monthlyValue)
        
        
        if(selectedPlan != -1)
        {
            if(youSavedValue > 0)
            {
                
                
                //self.adjustmentLabel.isHidden = false
                self.adjustmentLabel.text = "YOU SAVED $\(youSavedValue).toRoundCommaString) !"
                
            }
            else
            {
                //self.adjustmentLabel.isHidden = true
            }
            //  self.adjustmentLabel.text = "YOU SAVED $\((adjestmentValue + monthlyValue).toRoundCommaString) !"
        }
        else
        {
            self.adjustmentLabel.text = "YOU SAVED $0 !"
            //  self.adjustmentLabel.isHidden = true
        }
        self.selectedOption = -1
        self.planCollectionView.reloadData()
    }
    
    func    didApplyDiscountAtPersentage(persentage: Double)
    {
        
        applyediscountPercentage = persentage
        applyedDiscountValue = 0
        applyedPromoCode = ""
        
     //   if(discount_exclude_amount)
      //  let value = calculatePercentage(value:actualSalePrice ,percentageVal:persentage)
        let value = calculatePercentage(value:(actualSalePrice - discount_exclude_amount),percentageVal:persentage)
        
        self.adjestmentValue = value.rounded()
        let youSavedValue = (adjestmentValue + monthlyValue)
        
        
        if(selectedPlan != -1)
        {
            if(youSavedValue > 0)
            {
                //self.adjustmentLabel.isHidden = false
                self.adjustmentLabel.text = "YOU SAVED $\(youSavedValue).toRoundCommaString) !"
                
            }
            else
            {
                // self.adjustmentLabel.isHidden = true
            }
            //  self.adjustmentLabel.text = "YOU SAVED $\((adjestmentValue + monthlyValue).toRoundCommaString) !"
        }
        else
        {
            self.adjustmentLabel.text = "YOU SAVED $0 !"
            // self.adjustmentLabel.isHidden = true
        }
        self.selectedOption = -1
        self.planCollectionView.reloadData()
        
        
    }
    
    public func calculatePercentage(value:Double,percentageVal:Double)->Double{
        let val = value * percentageVal
        return val / 100.0
    }
    
    @IBAction func DownorfinalPaymentButtonAction(_ sender: Any) {
        
        if(self.selectedPlan == -1)
        {
            self.alert("Please choose a package", nil)
            return
        }
        
        
        let alert = UIAlertController(title: AppDetails.APP_NAME, message: "Please enter the down payment", preferredStyle: .alert)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor().colorFromHexString("#586471")
        alert.view.subviews.first?.subviews.first?.subviews.first?.borderColor = UIColor().colorFromHexString("#707070")
        alert.view.subviews.first?.subviews.first?.subviews.first?.borderWidth = 1
        alert.view.tintColor = UIColor.white
        var height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
        alert.view.addConstraint(height)
        var width:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 387)
        alert.view.addConstraint(width)
        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedString.Key.font : UIFont(name: "Avenir-Black", size: 25) , NSAttributedString.Key.foregroundColor : UIColor.white]), forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: alert.message!, attributes: [NSAttributedString.Key.font :UIFont(name: "Avenir-Roman", size: 16) ,NSAttributedString.Key.foregroundColor :UIColor.white]), forKey: "attributedMessage")
        alert.addTextField { (textField) in
            textField.placeholder = "Ex: $100"
           // textField.backgroundColor = UIColor().colorFromHexString("#2D343D")
            if(self.downOrFinal != 0)
            {
                textField.text = "\(self.downOrFinal.clean)"
            }
            textField.keyboardType = .decimalPad
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            if let textfield = alert.textFields?[0]
            {
                let downPaymentValue = textfield.text?.replacingOccurrences(of: ",", with: "")
                if let value = Double(downPaymentValue ?? "")
                {
                    
                    let total = self.amountTotel.noDecimal
                    
                    
                    if value <= Double(total) ?? 0
                    {
                        self.downOrFinal = value
                        if(value < Double(total) ?? 0)
                        {
                            
                            self.selectedOption = -1
                            self.paymentCollectionView.reloadData()
                            
                        }
                        else if (self.downOrFinal.clean == self.amountTotel.clean)
                        {
                            //self.selectedOption = -1
                            self.selectedOption = 0
                            self.paymentCollectionView.reloadData()
                        }
                    }
                    else
                    {
                        self.downOrFinal = 0
                        
                        self.selectedOption = -1
                        self.paymentCollectionView.reloadData()
                        
                        self.alert("Wrong amount entered", nil)
                    }
                }
                else  {
                    if (textfield.text ?? "") != ""
                    {
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        self.downOrFinal = 0
                        if(self.selectedOption == -1)
                        {
                            self.selectedOption = 0
                            self.paymentCollectionView.reloadData()
                        }
                    }
                }
            }
        }
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func nextButtonAction(_ sender: UIButton)
    {
        
        
        if(self.selectedPlan<0)
        {
            self.alert("Please choose a package", nil)
            return
        }
        
        let downpatmet = DownFinalPaymentViewController.initialization()!
        if(selectedOption != 0)
        {
            downpatmet.downOrFinal = self.downOrFinal
        }
        else
        {
            if(downOrFinal > 0 && downOrFinal != amountTotel)
            {
                downpatmet.downOrFinal = downOrFinal
            }
            else{
                downpatmet.downOrFinal = Double((self.amountTotel/2)) 
            }
            
            downpatmet.isPaymentByCash = true
        }
        downpatmet.totalAmount = self.amountTotel
        if area == 0.0
        {
            if stairPrice < self.paymentPlanValueDetails[self.selectedPlan].minimum_Sale_price ?? 1500
            {
                downpatmet.stairPrice = self.paymentPlanValueDetails[self.selectedPlan].minimum_Sale_price ?? 1500
            }
            else
            {
                downpatmet.stairPrice = stairPrice
            }
        }
        else
        {
            downpatmet.stairPrice = stairPrice
        }
        downpatmet.paymentPlan = self.paymentPlanValueDetails[self.selectedPlan]
        //arb
        packageName = self.paymentPlanValueDetails[self.selectedPlan].plan_title ?? ""
        //
        downpatmet.roomName = ""
        var savingsAmount = savingsArray[selectedPlan]
        if let index = savingsAmount.firstIndex(of: "$")
        {
            savingsAmount.remove(at: index)
        }
        savings = savingsAmount
        downpatmet.savings = Double(savings) ?? 0
        if(amountTotel < downOrFinal)
        {
            self.alert("Please enter correct down/final amount", nil)
            return
        }
        else if(amountTotel != downOrFinal)
        {
            //sath
            if (selectedOption != -1)
            {
                print("test loop")
                downpatmet.paymentOptionDataValue = self.paymentOptionDataValueDetail[self.selectedOption]
                
                //  downpatmet.paymentOptionDataValue?.id = self.selectedOption
                
            }
            else
            {
                //sss
                if(downOrFinal > 0 && downOrFinal != amountTotel)
                {
                    // self.alert("You have entered down/final amount lower than sale price So please choose a finance option", nil)
                    self.alert("Please choose a finance option", nil)
                    return
                }
                
                self.alert("Select a Payment Option", nil)
                return
            }
            
        }
        else if(amountTotel == downOrFinal)
        {
            //sath
            
            downpatmet.paymentOptionDataValue = self.paymentOptionDataValueDetail[self.selectedOption]
            
            //  downpatmet.paymentOptionDataValue?.id = self.selectedOption
            
            
        }
        if (selectedPlan != -1)
        {
            downpatmet.paymentPlanValue = self.paymentPlanValueDetails[self.selectedPlan]
        }
        else
        {
            self.alert("Select a Payment Option", nil)
            return
        }
        downpatmet.adjustmentValue = self.selectedPlan == 2 ? self.adjestmentValue : 0
       // downpatmet.paymentPlan?.additional_cost = Double(additional_cost)
       downpatmet.paymentPlan?.additional_cost = additionalCost
        
        //downpatmet.drowingImageID = self.drowingImageID
        downpatmet.area = self.area
       
            downpatmet.excluded_amount_promotion = totalExtraPromoCostToReduced
        
        downpatmet.minSalePrice = self.paymentPlanValueDetails[self.selectedPlan].minimum_Sale_price ?? 1500.00
        // downpatmet.downpayment = self.downpayment
        // downpatmet.adminFee = Double(self.adminFee) ?? 0
        downpatmet.adminFee = 0
        if selectedPlan != 2
        {
            deleteDiscountArrayFromDb()
            discountArray.removeAll()
        }
        downpatmet.specialPriceId = self.selectedPlan == 2 ? roomspecialPriceId : 0
        downpatmet.stairsSpecialPriceId = self.selectedPlan == 2 ? stairsspecialPriceId : 0 //stairsspecialPriceId
        downpatmet.promotionCodeId = promoCodeDropDownSelectedId
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "PaymentOption"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        // Q4_Change Package Selection
        if !(IsEligibleForDiscounts == 1) {
        let yes = UIAlertAction(title: "Yes", style:.default) { (_) in
            self.navigationController?.pushViewController(downpatmet, animated: true)
        }
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            DispatchQueue.main.async
            {
                self.alert("Are you sure you want to select the \(self.paymentPlanValueDetails[self.selectedPlan].plan_title ?? "" ) package?", [yes, no])

            }
        }
        if (IsEligibleForDiscounts == 1) {
          self.navigationController?.pushViewController(downpatmet, animated: true)
        }
    }
    
    func paymentTypeApiCall()
    {
        HttpClientManager.SharedHM.GetPaymentListApi { (success, message, value) in
            if(success ?? "false") == "Success"
            {
                if let data = value?.values
                {
                    self.paymentPlanValueDetails = data[0].PaymentPlanValueDetails ?? []
                    self.paymentOptionDataValueDetail = data[0].PaymentOptionDataValueDetail ?? []
                    self.paymentMeterialDataValueDetails =
                        data[0].PaymentMeterialDataValueDetails ?? []
                    self.paymentMonthlyPromo = data[0].PaymentPromoDataValueDetails ?? []
                    
                    
                    self.adminFee = String(data[0].adminFee ?? 0)
                    self.minimumFee = data[0].minimumFee ?? 1500
                    self.paymentCollectionView.reloadData()
                    // self.financeOptionHeadingLabel.isHidden = false
                    // self.adjustmentLabel.isHidden = false
                    
                    self.planCollectionView.reloadData()
                }
                else
                {
                    self.alert("No record available", nil)
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
                    
                    self.paymentTypeApiCall()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                //self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == planCollectionView)
        {
            savingsArray.removeAll()
            savingsArrayDouble.removeAll()
            salePriceDouble.removeAll()
            if(!self.paymentPlanValueDetails[indexPath.row].isNotAvailable)
            {
                
                
                if(self.selectedPlan !=  indexPath.item)
                {
                    applyediscountPercentage = 0
                    applyedDiscountValue = 0
                    applyedPromoCode = ""
                    self.selectedOption = -1
                    self.downOrFinal = 0
                }
                
                self.selectedPlan = indexPath.item
                
                let cell = collectionView.cellForItem(at: indexPath) as! PamentOptionsTopCollectionViewCell
                
                paymentOptionDataValueDetail = paymentRestrictionDataValueDetail
                for index in paymentOptionDataValueDetail
                {
                    index.isHidden = false
                }
                self.oneYrPrice = cell.mrpLabel.text!
                //self.oneYrPrice.removeFirst()
                oneYrPrice = oneYrPrice.replacingOccurrences(of: "$", with: "")
                oneYrPrice = oneYrPrice.replacingOccurrences(of: ",", with: "")
                self.OneYearPrice = Double(oneYrPrice)!
                self.savings = cell.adjustmentValue.text!
                self.savings.removeFirst()
                restrictedPromo.removeAll()
                restrictedDiscount.removeAll()
                isApplicableRoom()
                self.minimumFee = paymentPlanValueDetails[indexPath.row].minimum_Sale_price ?? 1500.00
                //self.adjestmentValue = 0
                self.monthlyValue = self.paymentPlanValueDetails[indexPath.row].monthly_promo ?? 0
                let youSavedValue = (adjestmentValue + monthlyValue)
                if(youSavedValue > 0)
                {
                    //self.adjustmentLabel.isHidden = false
                    self.adjustmentLabel.text = "YOU SAVED $\(youSavedValue.toRoundCommaString) !"
                    
                }
                else
                {
                    // self.adjustmentLabel.isHidden = true
                    
                }
                
                // self.downOrFinal = paymentPlanValueDetails[indexPath.row].monthly_promo ?? 0
                
                self.planCollectionView.reloadData()
                
                
            }
        }
        else if self.downOrFinal != self.amountTotel
        {
           
            if(indexPath.item == 0 )
            {
                
                if self.downOrFinal == 0
                {
                    self.selectedOption = indexPath.item
                    self.paymentCollectionView.reloadData()
                }
                else
                {
                    //man  self.alert("You have entered down/final amount lower than sale price So please choose a finance option", nil)
                    self.selectedOption = indexPath.item
                    self.paymentCollectionView.reloadData()
                }
            }
            else
            {
                
                self.selectedOption = indexPath.item
                self.paymentCollectionView.reloadData()
            }
            
        }
        else if self.downOrFinal == self.amountTotel
        {
            if(self.selectedPlan<0)
            {
                self.alert("Please choose a package", nil)
                return
            }
            self.selectedOption = indexPath.item
            self.paymentCollectionView.reloadData()
            
            
        }
        if(self.selectedPlan > -1)
        {
           // self.createSalesQuotation()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == planCollectionView)
        {
            return paymentPlanValueDetails.count
        }
        else
        {
            let appointment_date = appointmentDate ?? Date()
//            let formattedAppointmentDate = "2022-02-16"
            
            // Filter the payment options based on visibility and date range
            let filteredData = paymentRestrictionDataValueDetail.filter { cellData in
                // Filter based on visibility
                guard !cellData.isHidden else { return false }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                // Filter based on date range
                if let startDateString = cellData.start_date,
                   let endDateString = cellData.end_date,
                   let startDate = dateFormatter.date(from: startDateString),
                   let endDate = dateFormatter.date(from: endDateString) {
                    
                    let formattedStartDate = dateFormatter.string(from: startDate)
                    let formattedEndDate = dateFormatter.string(from: endDate)
                    let formattedAppointmentDate = dateFormatter.string(from: appointment_date)
                    return formattedAppointmentDate >= formattedStartDate && formattedAppointmentDate <= formattedEndDate
                }
                return false // Return false if start_date or end_date is nil or cannot be converted to Date
            }

            // Update paymentOptionDataValueDetail with filtered data
            paymentOptionDataValueDetail = filteredData

            // Count the visible cells
            let visibleCellsCount = paymentOptionDataValueDetail.filter { !$0.isHidden }.count
            print("paymentOptionDataValueDetail_Visible cells count: \(visibleCellsCount)")

            // Return the count of visible cells
            return visibleCellsCount

            
            //            paymentOptionDataValueDetail = paymentRestrictionDataValueDetail.filter({$0.isHidden == false})
//            paymentOptionDataValueDetail.removeLast()
           // paymentOptionDataValueDetail.removeLast()
//            print("paymentOptionDataValueDetail.count : ", paymentOptionDataValueDetail.count)
//            return paymentOptionDataValueDetail.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView == planCollectionView)
        {
            let count = CGFloat(paymentPlanValueDetails.count)
           
            let totalWidth = 320 * count
            let defferent = (collectionView.bounds.width - totalWidth)
            //return 12
            return (defferent > 70) ? (defferent/count) : 20
        }
        
        else
        {
//            let count = CGFloat(paymentOptionDataValueDetail.count)
//
//            let totalWidth = 320 * count
//            let defferent = (collectionView.bounds.width - totalWidth)
//            return (defferent > 70) ? (defferent/count) : 20
            return 20

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == planCollectionView)
        {
            let width = (collectionView.bounds.width-60)/4
            
           // let width = (collectionView.bounds.width-15)/4
            return CGSize(width: (paymentPlanValueDetails.count == 4) ? width : 290, height: collectionView.bounds.height)
            
        }
        else
        {
            let width = (collectionView.bounds.width-60)/4
            
            return CGSize(width: (paymentOptionDataValueDetail.count == 4) ? width : 290, height: collectionView.bounds.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        if paymentOptionDataValueDetail.count < 4
        {
            if collectionView == paymentCollectionView
            {
            
                let appointmentDateString = appointmentDate ?? Date()
               
                   let filteredData = paymentOptionDataValueDetail.filter { cellData in
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = "yyyy-MM-dd"
                       if let startDateString = cellData.start_date,
                          let endDateString = cellData.end_date,
                          let startDate = dateFormatter.date(from: startDateString),
                          let endDate = dateFormatter.date(from: endDateString) {
                           
                           let formattedStartDate = dateFormatter.string(from: startDate ?? Date())
                           let formattedEndDate = dateFormatter.string(from: endDate ?? Date())
                           let formattedAppointmentDate = dateFormatter.string(from: appointmentDateString)
                           return formattedAppointmentDate >= formattedStartDate && formattedAppointmentDate <= formattedEndDate
                       }
                       return false // Return false if start_date or end_date is nil or cannot be converted to Date
                   }
                
                let CellWidth = 290
                let CellCount = filteredData.count
                print("filteredData : ", filteredData.count)
//                let CellCount = paymentOptionDataValueDetail.count
                let totalCellWidth = CellWidth * CellCount
                    let totalSpacingWidth = 20 * (CellCount - 1)

                let leftInset = max(0, (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2.0)
                    let rightInset = leftInset

                    return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
            }
        }

        return UIEdgeInsets()
    }
    
    /* func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
     return 5
     }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView == planCollectionView)
        {
            let count = CGFloat(paymentPlanValueDetails.count)
            
            let totalWidth = 320 * count
            let defferent = (collectionView.bounds.width - totalWidth)
           // return 12
            return (defferent > 70) ? (defferent/count) : 20
        }
    
       
        else
        {
            return 20
//            let count = CGFloat(paymentOptionDataValueDetail.count)
//
//            let totalWidth = 320 * count
//            let defferent = (collectionView.bounds.width - totalWidth)
//            return (defferent > 70) ? (defferent/count) : 20
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(collectionView == planCollectionView)
        {
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PamentOptionsTopCollectionViewCell", for: indexPath) as! PamentOptionsTopCollectionViewCell
            if isDiscountApplied == true || isPromoApplied == true
            {
                cell.savingsLblHeightConstraint.constant = 30
                cell.savingsValueHeightConstraint.constant = 30
            }
            else
            {
                cell.savingsLblHeightConstraint.constant = 0
                cell.savingsValueHeightConstraint.constant = 0
            }
            cell.borderWidth = 1
            cell.borderColor = UIColor().colorFromHexString("#586471")
            cell.HeadingLabel.text = paymentPlanValueDetails[indexPath.row].plan_title
            cell.subHeadingLabel.text = paymentPlanValueDetails[indexPath.row].plan_subtitle
            //cell.descriptionLabel.text = paymentPlanValueDetails[indexPath.row].description
            var updatedDescriptionText = ""
//                        if (indexPath.row == 0) {
//                            updatedDescriptionText = "\n\n" + "\n1-Year limited warranty"
//                        } else if (indexPath.row == 1) {
//                            updatedDescriptionText = "\n" + "\n4-Year limited warranty"
//                        } else if (indexPath.row == 2) {
//                            if isDiscountApplied == true || isPromoApplied == true {
//                                updatedDescriptionText = "\n" + "\n4-Part Lifetime Guarantee"
//                            } else {
//                                updatedDescriptionText = "\n" + "\n4-Part Lifetime Guarantee"
//                            }
//                        } else if (indexPath.row == 3) {
//                            updatedDescriptionText = "\n" + "\n10-Year limited warranty"
//                        }
//            if indexPath.row == 0
//            {
//                updatedDescriptionText = "\n\n" + (paymentPlanValueDetails[indexPath.row].warranty ?? "")
//            }
//            else
//            {
                updatedDescriptionText = "\n\n" + (paymentPlanValueDetails[indexPath.row].warranty ?? "")
            //}
                        cell.descriptionLabel.text = (paymentPlanValueDetails[indexPath.row].description ?? "") + updatedDescriptionText
            var costpersqft:Double = Double()
            var msrppersqft:Double = Double()
            var stairperprice:Double = Double()
            var saleprice:Double = Double()
            if isroomSpclPriceApplied == true && (paymentPlanValueDetails[indexPath.row].id == specialPriceTable[0].productTmplId)
            {
              
                costpersqft = specialPriceTable[0].listPrice
                msrppersqft = specialPriceTable[0].msrp
                paymentPlanValueDetails[indexPath.row].cost_per_sqft = msrppersqft
                //_ = PaymentPlanValue(costPerSqft: msrppersqft)
                
            }
            else
            {
                costpersqft = (paymentPlanValueDetails[indexPath.row].material_cost ?? 0)
                msrppersqft = (paymentPlanValueDetails[indexPath.row].cost_per_sqft ?? 0)
            }
            if isStairsSpclPriceApplied == true && (paymentPlanValueDetails[indexPath.row].stairProductId == specialPriceTable[1].productTmplId)
            {
                stairperprice = specialPriceTable[1].msrp
                paymentPlanValueDetails[indexPath.row].stair_msrp = stairperprice
            }
            else
            {
                stairperprice = (paymentPlanValueDetails[indexPath.row].stair_msrp ?? 0)//(paymentPlanValueDetails[indexPath.row].stair_cost ?? 0)
            }
        
            //let additionalCost = (paymentPlanValueDetails[indexPath.row].additional_cost ?? 0)
            additionalCost = totalUpchargeCost + totalExtraCost + totalMoldingPrice
            print("-------additionalCost--------", additionalCost)
            let stairPrice = Double(self.stairCount) * stairperprice
            var mrp = msrppersqft * area
            self.minimumFee = paymentPlanValueDetails[indexPath.row].minimum_Sale_price ?? 1500.00
            if calculationType == "sqft"
            {
                 saleprice =  (self.isDiscountApplied || self.isPromoApplied) ? (msrppersqft - promoValue) * area : (msrppersqft) * area
            
                saleprice = saleprice + additionalCost +  stairPrice
            }
            else
            {
                saleprice =  (self.isDiscountApplied || self.isPromoApplied) ? (msrppersqft) * area : (msrppersqft) * area
//                if self.isDiscountApplied
//                {
//                    saleprice = msrppersqft * area
//                }
//                if self.isPromoApplied
//                {
//                    saleprice = msrppersqft * area
//                }
//                if self.isDiscountApplied == false && self.isPromoApplied == false
//                {
//                    saleprice = msrppersqft * area
//                }
           
                //saleprice = saleprice + Double(additional_cost) +  stairPrice
              saleprice = saleprice + additionalCost +  stairPrice
                if calculationType == "fixed"
                {
                    saleprice = saleprice - promoValue
                }
                else
                {
                    //totalExtraPromoCostToReduced = totalExtraPromoCostToReduced + vapurBarrierValue
                    saleprice = saleprice - ((saleprice - (totalExtraPromoCostToReduced))  * promoValue / 100).rounded()
                }
            }

            mrp = mrp + stairPrice
            print("self.minimumFee.clean3 : ", mrp, " stairperprice : ", stairperprice, " stairCount : ", stairCount)
            if selectedPlan == indexPath.row
            {
                self.stairPrice = stairPrice
                print("self.minimumFee.clean2 : ", stairperprice, " stairPrice : ", stairPrice, " stairCount : ", stairCount)
            }
            //mrp = (mrp + Double(additional_cost)).rounded()
            mrp = (mrp + additionalCost).rounded()
            saleprice = saleprice.rounded()
            cell.mrpLabel.text = "$\(mrp.clean)"
            print("self.minimumFee.clean1 : ", mrp.clean, "additionalCost : ", additional_cost)
            cell.warrentyLabel.text = paymentPlanValueDetails[indexPath.row].warranty
            // cell.discoutTF.tag = indexPath.row
            //cell.discoutTF.text = "\(paymentPlanValueDetails[indexPath.row].discount ?? 0)"
            //let monthly:Double = paymentPlanValueDetails[indexPath.row].monthly_promo ?? 0
            
            //  let monthly:Double = paymentPlanValueDetails[indexPath.row].monthly_promo ?? 0
            // let prize = mrp - (adjestmentValue + monthly)
            var monthly:Double = (mrp - saleprice)
//            if isDiscountApplied == true && indexPath.row == 2
//            {
//                monthly  = monthly + adjestmentValue
//            }
            // var prize = saleprice - (monthly)
            //let mrpValue:Double = self.minimumFee + monthly
            var prize = saleprice.rounded(.towardZero)
            if mrp < self.minimumFee
            {
                mrp = self.minimumFee
                cell.mrpLabel.text = "$\(self.minimumFee.clean)"
                print("self.minimumFee.clean : ", self.minimumFee.clean)
            }
            if prize == self.minimumFee
            {
                prize = self.minimumFee
                //monthly = monthly
            }
            if(prize < self.minimumFee)
            {
                prize = self.minimumFee
                
                if mrp > 1500
                {
                    monthly = mrp - prize
                }
                else
                {
                    monthly = 0.0
                }
                applyedDiscountValue = 0
                

//                    let mrpValue:Double = self.minimumFee + monthly
//                    cell.mrpLabel.text = "$\(mrpValue.clean)"
//
            }
            cell.monthlyPayment.text = "$\(monthly.clean)"
            if(indexPath.row == 2)
            {
                print("Smart Choice")
            }
            
            cell.adjustmentValue.text = "$\((monthly).clean)"
            
            //savingsArray.removeAll()
            savingsArray.append(cell.adjustmentValue.text ?? "")
            savingsArrayDouble.append(monthly)
            
            
            
            //cell.mrpLabel.text = "$\((mrpValue).clean)"
            cell.prizeLabel.text = "$\(prize.clean)"
            salePriceDouble.append(prize)
            cell.closeImage.tag = indexPath.row
            cell.closeImage.image = (paymentPlanValueDetails[indexPath.row].isNotAvailable) ? UIImage(named: "closeBG") : nil
            cell.makeVisibleButton.setImage((paymentPlanValueDetails[indexPath.row].isNotAvailable) ? UIImage(named: "graycancel") : UIImage(named: "redcancel"), for: .normal)
            cell.makeVisibleButton.tag = indexPath.row
            
            let youSavedValue = (adjestmentValue + monthly)
            if(youSavedValue > 0)
            {
                //  self.adjustmentLabel.isHidden = false
                self.adjustmentLabel.text = "YOU SAVED $\((adjestmentValue + monthlyValue).clean) !"
                
            }
            //else
           // {
                // self.adjustmentLabel.isHidden = true
         //   }
            // self.adjustmentLabel.text = "YOU SAVED $\((adjestmentValue + monthly).toDoubleString) !"
            cell.viewC = self

            
            if(selectedPlan == indexPath.row)
            {
                cell.bgView.borderWidth = 5
                cell.bgView.borderColor = UIColor().colorFromHexString("#292562")
                cell.borderWidth = 0.5
                cell.borderColor = UIColor().colorFromHexString("#A7B0BA")
                
                
                if(paymentPlanValueDetails[indexPath.row].eligible_for_discounts ?? "" == "true")
                {
                    //discount_exclude_amount = (paymentPlanValueDetails[indexPath.row].discount_exclude_amount ?? 0)
                    IsEligibleForDiscounts=1
                    cell.adjustmentValue.text = "$\((adjestmentValue.rounded() + monthly).clean)"
                    savingsArrayDouble.remove(at: indexPath.row)
                    savingsArrayDouble.insert((adjestmentValue + monthly), at: indexPath.row)
                    savingsArray.remove(at: indexPath.row)
                    savingsArray.insert(cell.adjustmentValue.text ?? "", at: indexPath.row)
                    prize = mrp - (adjestmentValue.rounded() + monthly)
                    actualSalePrice = mrp - monthly
                    if(prize < self.minimumFee)
                    {
                        cell.adjustmentValue.text = "$\((monthly).clean)"
                        applyedDiscountValue = 0
                        prize = self.minimumFee
                        
                    }
                    //var prize = saleprice.rounded()
                    cell.prizeLabel.text = "$\(prize.rounded().clean)"
                    salePriceDouble.remove(at: indexPath.row)
                    salePriceDouble.insert(prize, at: indexPath.row)
                   
                    //arb
                    if self.adjestmentValue > 0{
                        self.discountBtn.borderColor = UIColor.placeHolderColor
                        self.discountBtn.borderWidth = 2
                    }else{
                        self.discountBtn.borderColor = UIColor.clear
                        self.discountBtn.borderWidth = 0
                    }
                    //
                }
                else
                {
                    IsEligibleForDiscounts=0
                    cell.adjustmentValue.text = "$\((monthly).clean)"
                    
                }
                
                if monthly == 0
                {
                    amountTotel = stairPrice
                }
                else
                {
                    amountTotel = prize.rounded()
                }
                if monthly == 0 && selectedOption == -1 || monthly == 0 && selectedOption != -1
                {
                    amountTotel = prize
                }
                
                if(selectedOption != 0)
                {
                    self.paymentCollectionView.reloadData()
                }
            }
           
            else
            {
                
                cell.bgView.borderWidth = 0
                cell.bgView.borderColor = .clear
//                if saleprice < 1500
//                {
//                    prize = self.minimumFee
//                    cell.prizeLabel.text = "$\(prize.rounded().clean)"
//                    var monthlySavings = monthly
//                    monthlySavings = 0
//                    cell.adjustmentValue.text = "$\((monthlySavings).clean)"
//                    savingsArray.remove(at: indexPath.row)
//                    savingsArray.insert("$\((monthlySavings).clean)", at: indexPath.row)
//                }
//                cell.borderColor = .clear
//                cell.borderWidth = 0
                
            }
            if savingsArray[indexPath.row] == "$0"
            {
                cell.savingsLblHeightConstraint.constant = 0
                cell.savingsValueHeightConstraint.constant = 0
            }
            else
            {
                cell.savingsLblHeightConstraint.constant = 30
                cell.savingsValueHeightConstraint.constant = 30
            }
            print("1 year price",cell.mrpLabel.text)
            print("sale price",cell.prizeLabel.text)
            print("savings Array",savingsArray)
            print("savings array double",savingsArrayDouble)
            print("sale price double",salePriceDouble)
            //let mrpValue =
            //cell.mrpLabel.text = self.minimumFee +
            return cell
            
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentOptionsBottomCollectionViewCell", for: indexPath) as! PaymentOptionsBottomCollectionViewCell
            //let paymentRestrictionArray = paymentOptionDataValueDetail.filter({$0.isHidden == false})
            print("------appointmentDate------", appointmentDate)

//            let appointmentDateString = "2022-02-16"
            let appointmentDateString = appointmentDate ?? Date()
            let startDateString = paymentOptionDataValueDetail[indexPath.row].start_date ?? ""
            let endDateString = paymentOptionDataValueDetail[indexPath.row].end_date ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            print("appointment_date : ", dateFormatter.string(from: appointmentDateString))
            print("start_Date : ", dateFormatter.string(from: dateFormatter.date(from: startDateString) ?? Date()))
            print("end_Date : ", dateFormatter.string(from: dateFormatter.date(from: endDateString) ?? Date()))
            
            do {
//                let appointment_date = dateFormatter.string(from: dateFormatter.date(from: appointmentDateString)!)
            let appointment_date = dateFormatter.string(from: appointmentDateString)
            let start_Date = dateFormatter.string(from: dateFormatter.date(from: startDateString) ?? Date())
            let end_Date = dateFormatter.string(from: dateFormatter.date(from: endDateString) ?? Date())
            
            if appointment_date >= start_Date && appointment_date <= end_Date {
                cell.isHidden = false
                cell.borderWidth = 1
                cell.borderColor = UIColor().colorFromHexString("#586471")
                let htmlString = paymentOptionDataValueDetail[indexPath.row].Name
                let str = htmlString?.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
                cell.headingLabel.text = str
                let DownDouble = Double(self.paymentOptionDataValueDetail[indexPath.row].Down_Payment__c ?? "0") ?? 0
                let FinalDouble = Double(self.paymentOptionDataValueDetail[indexPath.row].Final_Payment__c ?? "0") ?? 0
                let Payment_Factor = Double(self.paymentOptionDataValueDetail[indexPath.row].Payment_Factor__c ?? "0") ?? 0
                let secondaryFactor = Double(self.paymentOptionDataValueDetail[indexPath.row].Secondary_Payment_Factor__c ?? "0") ?? 0
                let today = Date()
                let Balance_DueDt = Double(self.paymentOptionDataValueDetail[indexPath.row].Balance_Due__c ?? "0") ?? 0
                let modifiedDate = Calendar.current.date(byAdding: .day, value: Int(Balance_DueDt), to: today)!
                emiAmount = amountTotel
                
                let tempValue = self.emiAmount - downOrFinal
                cell.amountTitle.text = "$\((tempValue.rounded()).clean)"
                
                cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "") + "\n" + "\n \(String(describing: paymentOptionDataValueDetail[indexPath.row].down_payment_message ?? ""))"
                
                cell.paymentDescription.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String
                if(paymentOptionDataValueDetail[indexPath.row].Name == "Cash" && paymentOptionDataValueDetail[indexPath.row].isHidden == false)
                {
                    
                    // if(downOrFinal > 0)
                    //  {
                    //    self.emiAmount = downOrFinal
                    //  }
                    // var modValue = (self.emiAmount * DownDouble)
                    let temp = emiAmount.truncatingRemainder(dividingBy:2)
                    let FinalTemp = (self.emiAmount * FinalDouble) + temp
                    
                    
                    // cell.subTitle.attributedText = self.labelFormat(down: " $\((self.emiAmount * DownDouble).clean)", final: " $\(FinalTemp.clean)")
                    cell.amountTitle.text = "$\((self.emiAmount.rounded()).clean)"
                    cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "")
                    if(downOrFinal > 0)
                    {
                        let tempValue = self.emiAmount - downOrFinal
                        
                        cell.subTitle.text = "$\((self.downOrFinal).clean) Down" + " / " + "$\((tempValue).clean) Before Installation"
                    }
                    else
                    {
                        let tempdown = self.emiAmount/2
                        var tempfinal = self.emiAmount/2
                        
                        // let temp = downOrFinal % 2
                        let temp = self.emiAmount.truncatingRemainder(dividingBy:2)
                        tempfinal = tempfinal + temp
                        cell.subTitle.text = "$\((tempdown).clean) Down" + " / " + "$\((tempfinal).clean) Before Installation"
                        if(self.selectedPlan<0)
                        {
                            cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "")
                        }
                        
                    }
                    cell.paymentDescription.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String
                    
                    
                    // cell.subTitle.text = "Down Payment:" + "$\((self.emiAmount * DownDouble).toRoundeString)" + "\n\nAt Completion:" + " $\((self.emiAmount * FinalDouble).toRoundeString)"
                    //                print("Title:\(paymentOptionDataValueDetail[indexPath.row].Name ?? "")")
                    //                 print("Amount:\(self.emiAmount)")
                    //                print("Amount bottomTitle:\(paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "")")
                    //                print("Bottom Title:\(paymentOptionDataValueDetail[indexPath.row].Description__c ?? "")")
                }
                else if(paymentOptionDataValueDetail[indexPath.row].Name == "1 Year<br />No Payments<br />No Interest" && paymentOptionDataValueDetail[indexPath.row].isHidden == false)
                        
                {
                    
                    
                    
                    // cell.subTitle.attributedText = labelFormatFinanace(title: (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nPayment:", amount: " $\((self.emiAmount * Payment_Factor).toDoubleString)")
                    
                    //   cell.subTitle.attributedText = self.labelFormat(down: " $\((self.emiAmount * DownDouble).clean)", final: " $\(FinalTemp.clean)")
                    let tempValue = self.emiAmount - downOrFinal
                    cell.amountTitle.text = "$\((tempValue.rounded()).clean)"
                    
                    cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "") + "\n" + "\n \(String(describing: paymentOptionDataValueDetail[indexPath.row].down_payment_message ?? ""))"
                    
                    
                    
                    cell.paymentDescription.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String
                    
                    print("Title:\(paymentOptionDataValueDetail[indexPath.row].Name ?? "")")
                    print("Amount:\(self.emiAmount)")
                    print("Amount bottomTitle:\(paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "")")
                    print("Bottom Title:\(paymentOptionDataValueDetail[indexPath.row].Description__c ?? "")")
                    
                    
                    //  cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nPayment: $\((self.emiAmount * Payment_Factor).toRoundeString)"
                }
                else if(paymentOptionDataValueDetail[indexPath.row].Name == "Zero Interest Program" && paymentOptionDataValueDetail[indexPath.row].isHidden == false)
                        
                {
                    if(downOrFinal > 0 )
                    {
                        self.emiAmount = self.emiAmount - downOrFinal
                    }
                    if(emiAmount > 0)
                    {
                        
                        //  cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nBalance Due On:" + modifiedDate.DateFromStringMonthDate()
                        cell.subTitle.attributedText = labelFormatFinanace(title: (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nBalance Due On: ", amount: modifiedDate.DateFromStringMonthDate())
                    }
                    else
                    {
                        // cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nBalance Due On:"
                        cell.subTitle.attributedText = labelFormatFinanace(title: (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nBalance Due On: ", amount: modifiedDate.DateFromStringMonthDate())
                    }
                    if secondaryFactor == 0 ||  self.emiAmount == 0
                    {
                        cell.amountTitle.text = "$\((self.emiAmount * Payment_Factor).rounded().clean)"
                    }
                    else
                    {
                        //cell.amountTitle.text = "$\((self.emiAmount * 2569).rounded().clean) - $\((self.emiAmount * 36985).rounded().clean)"
                        cell.amountTitle.text = "$\((self.emiAmount * Payment_Factor).rounded().clean) - $\((self.emiAmount * secondaryFactor).rounded().clean)"
                    }
                    
                    cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "") + "\n" + "\n \(String(describing:paymentOptionDataValueDetail[indexPath.row].down_payment_message ?? ""))"
                    
                    cell.paymentDescription.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String
                    
                    print("Title:\(paymentOptionDataValueDetail[indexPath.row].Name ?? "")")
                    print("Amount:", "$\((self.emiAmount * Payment_Factor).toDoubleString)")
                    print("Amount bottomTitle:\(paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "")")
                    print("Bottom Title:\(paymentOptionDataValueDetail[indexPath.row].Description__c ?? "")")
                    
                    
                }
                else if(paymentOptionDataValueDetail[indexPath.row].Name == "Low Monthly Payment" && paymentOptionDataValueDetail[indexPath.row].isHidden == false)
                        
                {
                    // let Payment_Factor = Double(self.paymentOptionDataValueDetail[indexPath.row].Payment_Factor__c ?? "0") ?? 0
                    if(downOrFinal > 0 )
                    {
                        self.emiAmount = self.emiAmount - downOrFinal
                    }
                    
                    //  cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nLow Monthly Payment: $\((self.emiAmount * Payment_Factor).toRoundeString)"
                    
                    //   cell.subTitle.attributedText = labelFormatFinanace(title: (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String + "\nLow Monthly Payment:", amount: " $\((self.emiAmount * Payment_Factor).toDoubleString)")
                    if secondaryFactor == 0 ||  self.emiAmount == 0
                    {
                        cell.amountTitle.text = "$\((self.emiAmount * Payment_Factor).rounded().clean)"
                    }
                    else
                    {
                        //cell.amountTitle.text = "$\((self.emiAmount * 2569).rounded().clean) - $\((self.emiAmount * 36985).rounded().clean)"
                        cell.amountTitle.text = "$\((self.emiAmount * Payment_Factor).rounded().clean) - $\((self.emiAmount * secondaryFactor).rounded().clean)"
                    }
                    cell.subTitle.text = (paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "") + "\n" + "\n \(String(describing: paymentOptionDataValueDetail[indexPath.row].down_payment_message ?? ""))"
                    
                    cell.paymentDescription.text = (paymentOptionDataValueDetail[indexPath.row].Description__c ?? "").html2String
                    
                    print("Title:\(paymentOptionDataValueDetail[indexPath.row].Name ?? "")")
                    print("Amount:", "$\((self.emiAmount * Payment_Factor).toDoubleString)")
                    print("Amount bottomTitle:\(paymentOptionDataValueDetail[indexPath.row].Payment_Info__c ?? "")")
                    print("Bottom Title:\(paymentOptionDataValueDetail[indexPath.row].Description__c ?? "")")
                }
                else
                {
                    if(downOrFinal > 0 )
                    {
                        self.emiAmount = self.emiAmount - downOrFinal
                    }
                    if secondaryFactor == 0 ||  self.emiAmount == 0
                    {
                        cell.amountTitle.text = "$\((self.emiAmount * Payment_Factor).rounded().clean)"
                    }
                    else
                    {
                        //cell.amountTitle.text = "$\((self.emiAmount * 2569).rounded().clean) - $\((self.emiAmount * 36985).rounded().clean)"
                        cell.amountTitle.text = "$\((self.emiAmount * Payment_Factor).rounded().clean) - $\((self.emiAmount * secondaryFactor).rounded().clean)"
                    }
                    
                }
                if(selectedOption == indexPath.row)
                {
                    
                    
                    cell.bgView.borderWidth = 5
                    cell.bgView.borderColor = UIColor().colorFromHexString("#292562")
                    cell.borderColor = UIColor().colorFromHexString("#A7B0BA")
                    cell.borderWidth = 0.5
                    
                }
                else
                {
                    
                    cell.bgView.borderWidth = 0
                    cell.bgView.borderColor = .clear
                    //                cell.borderColor = .clear
                    //                cell.borderWidth = 0
                }
                return cell
            } else {
                cell.isHidden = true
                paymentOptionDataValueDetail[indexPath.row].isHidden == true
                return cell
            }
        } catch {
            return cell
         }
        }
    }
    
    func labelFormat(down:String, final:String) -> (NSMutableAttributedString)
    {
        
        let DownAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Oblique", size: 16)!
        ]
        
        let downAmountAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 16)!
        ]
        
        
        let CompletionAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Oblique", size: 16)!
        ]
        let completionAmountAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 16)!
        ]
        
        
        
        let downRegular = NSAttributedString(string: "Down Payment:", attributes: DownAttribute)
        let downAmount = NSAttributedString(string: down, attributes: downAmountAttribute)
        
        
        let completionRegular = NSAttributedString(string: "\n\nAt Completion:", attributes: CompletionAttribute)
        let completionAmount = NSAttributedString(string: final, attributes: completionAmountAttribute)
        
        let newString = NSMutableAttributedString()
        newString.append(downRegular)
        newString.append(downAmount)
        newString.append(completionRegular)
        newString.append(completionAmount)
        
        return (newString)
    }
    
    func labelFormatFinanace(title:String, amount:String) -> (NSMutableAttributedString)
    {
        
        let DownAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Oblique", size: 16)!
        ]
        
        let downAmountAttribute = [
            NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 16)!
        ]
        
        let downRegular = NSAttributedString(string: title, attributes: DownAttribute)
        let downAmount = NSAttributedString(string: amount, attributes: downAmountAttribute)
        
        
        
        
        let newString = NSMutableAttributedString()
        newString.append(downRegular)
        newString.append(downAmount)
        
        
        return (newString)
    }
    
    func createSalesQuotation()
    {
        
        
        let data = ["floor_type":self.paymentPlanValueDetails[self.selectedPlan].id ?? 0 ,"appointment_id":AppDelegate.appoinmentslData.id ?? 0,"discount":monthlyValue ,"payment_method":"","finance_option_id":0,"msrp":self.amountTotel,"installation_date":"","photo_permission":"0","adjustment":self.adjestmentValue,"price":self.amountTotel,"down_payment_amount":self.downOrFinal,"additional_cost":self.paymentPlanValueDetails[self.selectedPlan].additional_cost ?? 0,"final_payment":0,"finance_amount":0,"coapplicant_skip":0,"special_price_id": roomspecialPriceId,"stair_special_price_id":stairsspecialPriceId] as [String : Any]
        let parameter = ["token":UserData.init().token ?? "","data":data,"loan_payment":self.emiAmount] as [String : Any]
        HttpClientManager.SharedHM.CreateSalesQuotationForSatusAPi(parameter: parameter) { (result, message, valuse) in
            if(result == "Success" || result == "True")
            {
                print("API called and success")
            }
            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message ?? valuse?.message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            
            else
            {
                // self.alert( message ?? "No record available", nil)
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
extension PaymentOptionsNewViewController: ImagePickerDelegate {

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
