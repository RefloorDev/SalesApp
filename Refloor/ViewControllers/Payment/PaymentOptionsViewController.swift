//
//  PaymentOptionsViewController.swift
//  Refloor
//
//  Created by sbek on 17/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class PaymentOptionsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    static func initialization() -> PaymentOptionsViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentOptionsViewController") as? PaymentOptionsViewController
    }
    @IBOutlet weak var financeOptionHeadingLabel: UILabel!
    @IBOutlet weak var planCollectionView: UICollectionView!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    var paymentPlanValueDetails:[PaymentPlanValue] = []
    var paymentOptionDataValueDetail:[PaymentOptionDataValue] = []
    var paymentMeterialDataValueDetails:[PaymentMeterialDataValue] = []
    var adminFee = ""
    var selectedPlan = 0
    var selectedOption = -1
    var area:Double = 0
    var adjestmentValue:Double = 0
    var downOrFinal:Double = 0
    var amountTotel:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "Select package".uppercased())
        
        self.paymentTypeApiCall()
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func changeAreaButtonAction(_ sender: Any) {
        self.performSegueToReturnBack()
    }
    @IBAction func adjustmentButtonAction(_ sender: Any) {
        
        
        let alert = UIAlertController(title: AppDetails.APP_NAME, message: "Please enter the adjustment value", preferredStyle: .alert)
        alert.addTextField { (textField) in
            if(self.adjestmentValue != 0)
            {
                textField.text = "\(self.adjestmentValue)"
            }
            textField.placeholder = "Ex: $100"
            textField.keyboardType = .decimalPad
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            if let textfield = alert.textFields?[0]
            {
                if let value = Double(textfield.text ?? "")
                {
                    self.adjestmentValue = value
                    self.planCollectionView.reloadData()
                }
                else  {
                    self.adjestmentValue = 0
                    self.planCollectionView.reloadData()
                }
            }
        }
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func DownorfinalPaymentButtonAction(_ sender: Any) {
        
        
        let alert = UIAlertController(title: AppDetails.APP_NAME, message: "Please enter the down/final amount", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Ex: $100"
            if(self.downOrFinal != 0)
            {
                textField.text = "\(self.downOrFinal)"
            }
            textField.keyboardType = .decimalPad
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            if let textfield = alert.textFields?[0]
            {
                if let value = Double(textfield.text ?? "")
                {
                    if value <= self.amountTotel
                    {
                        self.downOrFinal = value
                        if(value < self.amountTotel)
                        {
                            if(self.selectedOption == -1)
                            {
                                self.selectedOption = 0
                                self.paymentCollectionView.reloadData()
                            }
                        }
                        else if self.downOrFinal == self.amountTotel
                        {
                            self.selectedOption = -1
                            self.paymentCollectionView.reloadData()
                        }
                    }
                    else
                    {
                        self.downOrFinal = 0
                        if(self.selectedOption == -1)
                        {
                            self.selectedOption = 0
                            self.paymentCollectionView.reloadData()
                        }
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
    
    
    
    
    
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        let tiles = SelectTilesViewController.initialization()!
        tiles.paymentPlanValue = self.paymentPlanValueDetails[self.selectedPlan]
        tiles.downOrFinal = downOrFinal
        tiles.adjustmentValue = self.adjestmentValue
        tiles.totalAmount = amountTotel
        tiles.adminFee=self.adminFee
        if(amountTotel < downOrFinal)
        {
            self.alert("Please enter correct down/final amount", nil)
            return
        }
        else if(amountTotel != downOrFinal)
        {
            if (selectedOption != -1)
            {
                tiles.paymentOptionDataValue = self.paymentOptionDataValueDetail[self.selectedOption]
            }
            else
            {
                self.alert("Please choose a finance option to proceed", nil)
                return
            }
            
        }
        tiles.area = self.area
        
        self.navigationController?.pushViewController(tiles, animated: true)
        
        
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
                    self.adminFee = String(data[0].adminFee ?? 0)
                    self.paymentCollectionView.reloadData()
                    self.financeOptionHeadingLabel.isHidden = false
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
                
                self.alert((message ?? value?.message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            else
            {
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == planCollectionView)
        {
            self.selectedPlan = indexPath.item
            self.planCollectionView.reloadData()
        }
        else if self.downOrFinal != self.amountTotel
        {
            self.selectedOption = indexPath.item
            self.paymentCollectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == planCollectionView)
        {
            return paymentPlanValueDetails.count
        }
        else
        {
            return paymentOptionDataValueDetail.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == planCollectionView)
        {
            return CGSize(width: 250, height: collectionView.bounds.height)
            
        }
        else
        {
            return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == planCollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PamentOptionsTopCollectionViewCell", for: indexPath) as! PamentOptionsTopCollectionViewCell
            cell.HeadingLabel.text = paymentPlanValueDetails[indexPath.row].plan_title
            cell.subHeadingLabel.text = paymentPlanValueDetails[indexPath.row].plan_subtitle
            cell.descriptionLabel.text = paymentPlanValueDetails[indexPath.row].description
            let costpersqft = (paymentPlanValueDetails[indexPath.row].cost_per_sqft ?? 0)
            let mrp = costpersqft * area
            cell.mrpLabel.text = "$\(mrp.toDoubleString)"
            cell.warrentyLabel.text = paymentPlanValueDetails[indexPath.row].warranty
            // cell.discoutTF.tag = indexPath.row
            //cell.discoutTF.text = "\(paymentPlanValueDetails[indexPath.row].discount ?? 0)"
            let monthly:Double = paymentPlanValueDetails[indexPath.row].monthly_promo ?? 0
            let prize = mrp - (adjestmentValue + monthly)
            cell.monthlyPayment.text = "$\(monthly.toDoubleString)"
            if(adjestmentValue == 0)
            {
                cell.adjustmentHeadingLabel.isHidden = true
                cell.adjustmentValue.isHidden = true
                cell.priceTopConstrain.constant = -32
            }
            else
            {
                cell.adjustmentHeadingLabel.isHidden = false
                cell.adjustmentValue.isHidden = false
                cell.priceTopConstrain.constant = 2
            }
            cell.adjustmentValue.text = "$\(adjestmentValue.toDoubleString)"
            cell.prizeLabel.text = "$\(prize.toDoubleString)"
            // cell.minusButton.tag = indexPath.row
            //cell.pluseButton.tag = indexPath.row
            
            if(selectedPlan == indexPath.row)
            {
                cell.bgView.borderWidth = 5
                cell.bgView.borderColor = .red
                amountTotel = prize
            }
            else
            {
                cell.bgView.borderWidth = 0
                cell.bgView.borderColor = .clear
            }
            return cell
            
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentOptionsBottomCollectionViewCell", for: indexPath) as! PaymentOptionsBottomCollectionViewCell
            cell.headingLabel.text = paymentOptionDataValueDetail[indexPath.row].title
            cell.subTitle.text = paymentOptionDataValueDetail[indexPath.row].subtitle
            if(selectedOption == indexPath.row)
            {
                cell.bgView.borderWidth = 5
                cell.bgView.borderColor = .red
            }
            else
            {
                cell.bgView.borderWidth = 0
                cell.bgView.borderColor = .clear
            }
            return cell
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
