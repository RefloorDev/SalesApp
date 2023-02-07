//
//  SelectTilesViewController.swift
//  Refloor
//
//  Created by sbek on 22/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SelectTilesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate {
    
    
    
    static func initialization() -> SelectTilesViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SelectTilesViewController") as? SelectTilesViewController
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    var downOrFinal:Double = 0
    var totalAmount:Double = 0
    var paymentPlan:PaymentPlanValue?
    var adjustmentValue:Double = 0
    var selectedTilesNo = 0
    var roomName = ""
    var paymentPlanValue:PaymentPlanValue?
    var paymentOptionDataValue:PaymentOptionDataValue?
    var drowingImageID = 0
    var area:Double = 0
    var tilesMeterailsValues:[TileMeterailsData] = []
    var placeHolder = "Additional Comments.."
    var comments = ""
    var adminFee = ""
    var selectedTileID = 0
    var delegate:SummeryEditDelegate?
    var salesOrderID = 0
    var ScreenHeight = 0.0
    var downpayment = DownPaymentViewController.initialization()!
    //var tiles = [UIImage(named: "tiles1"),UIImage(named: "tiles2"),UIImage(named: "tiles3"),UIImage(named: "tiles4"),UIImage(named: "tiles5"),UIImage(named:"tiles6"),UIImage(named: "tiles7"),UIImage(named: "tiles8"),UIImage(named: "tiles9"),UIImage(named: "tiles10"),UIImage(named: "tiles11"),UIImage(named: "tiles12"),UIImage(named: "tiles13"),UIImage(named: "tiles14")]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenHeight = Double(Float(UIScreen.main.bounds.width))
        self.setNavigationBarbackAndlogo(with: "select Tile Color".uppercased())
        tilesMeterailsListApiCalll()
        self.headingLabel.text = "Total Area Measured - \(area.toRoundeString) Sq.Ft"
        collectionView.collectionViewLayout = MyLeftCustomFlowLayout()
        //sath
        
        // Do any additional setup after loading the view.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.comments = textView.text!
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == placeHolder)
        {
            textView.text = ""
            textView.textColor = .white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == "" && textView.text == placeHolder)
        {
            textView.text = placeHolder
            textView.textColor = UIColor(displayP3Red: 88/255, green: 100/255, blue: 113/255, alpha: 1)
            //rgba(88, 100, 113, 1)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any)
    {
        if(self.tilesMeterailsValues.count != self.selectedTilesNo)
        {
            self.tilesMeterialsUpdate(at: self.selectedTilesNo)
        }
    }
    
    @IBAction func payButtonAction(_ sender: Any) {
        
        //  self.navigationController?.pushViewController(self.downpayment, animated: true)
        
    }
    
    @IBAction func rejectButtonAction(_ sender: Any)
    {
        let ok = UIAlertAction(title: "Yes", style: .default) { (_) in
            
            self.rejectApiCall()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        self.alert("Are you sure want to reject this quotation ?", [ok,no])
        
        
    }
    @IBAction func proposedButtonAction(_ sender: Any)
    {
        let ok = UIAlertAction(title: "Yes", style: .default) { (_) in
            
            self.proposedApiCall()
            
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        self.alert("Are you sure want to save this quotation ?", [ok,no])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tilesMeterailsValues.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(tilesMeterailsValues.count == indexPath.item)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentsCollectionViewCell", for: indexPath) as! CommentsCollectionViewCell
            cell.textView.delegate = self
            cell.textView.text = (self.comments == "") ? placeHolder:self.comments
            cell.textView.textColor = (self.comments == "") ? UIColor(displayP3Red: 88/255, green: 100/255, blue: 113/255, alpha: 1):UIColor.white
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TilesImageCollectionViewCell", for: indexPath) as! TilesImageCollectionViewCell
            cell.imageView.loadImageFormWeb(URL(string: tilesMeterailsValues[indexPath.row].material_image_url ?? ""))
            if((indexPath.item + 1) % 7 == 0)
            {
                cell.leadingConstrain.constant = 0
            }
            else
            {
                cell.leadingConstrain.constant =  10
            }
            cell.imageView.borderColor = UIColor.redColor
            if(indexPath.item == selectedTilesNo)
            {
                cell.imageView.borderWidth = 5
            }
            else
            {
                cell.imageView.borderWidth = 0
            }
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(tilesMeterailsValues.count == indexPath.row)
        {
            return CGSize(width: collectionView.frame.width, height: 140)
        }
        else
        {
            if ScreenHeight < 1150.0
            {
                return CGSize(width: collectionView.frame.width / 7, height: collectionView.frame.width / 7)
            }
            else
            {
                return CGSize(width: collectionView.frame.width / 6, height: collectionView.frame.width / 6)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.item != tilesMeterailsValues.count)
        {
            //  let value = selectedTilesNo
            selectedTilesNo = indexPath.item
            //            if(value != selectedTilesNo)
            //            {
            //                var indexPaths = [indexPath]
            //                if(value != -1)
            //                {
            //                    indexPaths.append([0,value])
            //                }
            //                collectionView.reloadItems(at: indexPaths)
            //            }
            self.collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func editingFunction()
    {
        var i = 0
        var isIn = false
        for value in self.tilesMeterailsValues
        {
            if value.material_id == self.selectedTileID
            {
                isIn = true
            }
            if !(isIn)
            {
                i += 1
            }
        }
        if(isIn)
        {
            self.selectedTilesNo = i
        }
        self.collectionView.reloadData()
    }
    
    func tilesMeterailsListApiCalll()
    {
        HttpClientManager.SharedHM.TilesMaterialListApiviaPaymentPlan(self.paymentPlanValue?.id ?? 0) { (result, message, valuse) in
            if(result == "Success")
            {
                self.tilesMeterailsValues = valuse ?? []
                if(self.delegate == nil)
                {
                    self.collectionView.reloadData()
                }
                else
                {
                    self.editingFunction()
                }
            }
            else
            {
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
        
    }
    
    func tilesMeterialsUpdate(at Position:Int)
    {
        //  let data = ["material_id":self.tilesMeterailsValues[Position].material_id ?? 0,"appointment_id":AppDelegate.appoinmentslData.id ?? 0,"Comments":self.comments] as [String : Any]
        
        let parameter = ["token":UserData.init().token ?? "","material_id":self.tilesMeterailsValues[Position].material_id ?? 0,"Comments":self.comments,"appointment_id":AppDelegate.appoinmentslData.id ?? 0] as [String : Any]
        HttpClientManager.SharedHM.TilesMaterialUpdateApiViaPaymentPlan(parameter: parameter) { (result, message, valuse) in
            if(result == "True")
            {
                //                let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                //
                //                }
                let downpatmet = DownFinalPaymentViewController.initialization()!
                downpatmet.downOrFinal = self.downOrFinal
                downpatmet.totalAmount = self.totalAmount
                downpatmet.paymentPlan = self.paymentPlan
                downpatmet.roomName = self.roomName
                downpatmet.adjustmentValue = self.adjustmentValue
                downpatmet.paymentPlanValue = self.paymentPlanValue
                downpatmet.paymentOptionDataValue = self.paymentOptionDataValue
                downpatmet.drowingImageID = self.drowingImageID
                downpatmet.area = self.area
                downpatmet.downpayment = self.downpayment
                // downpatmet.adminFee=self.adminFee
                self.navigationController?.pushViewController(downpatmet, animated: true)
                // self.alert("Successfully updated", [ok])
            }
            else
            {
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    
    
    
    func PaymentQuotation()
    {
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func rejectApiCall()
    {
        let parameter:[String:Any] = ["token":(UserData().token ?? ""),"sale_order_id":self.salesOrderID,"status":"rejected"]
        HttpClientManager.SharedHM.rejectSalesAppointment(parameter: parameter) { (result, message) in
            if(result ?? "") == "Success"
            {
                //               let success = RejectViewControllerViewController.initialization()!
                //                success.successString = "Sales quotation rejected successfully"
                //                self.navigationController?.pushViewController(success, animated: true)
                let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                    
                    
                    self.navigationController?.popToRootViewController(animated: true)
                }
                self.alert("Sales quotation rejected successfully", [ok])
            }
            
            else
            {
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func proposedApiCall()
    {
        let parameter:[String:Any] = ["token":(UserData().token ?? ""),"sale_order_id":self.salesOrderID,"status":"proposed"]
        HttpClientManager.SharedHM.prposedSalesAppointment(parameter: parameter) { (result, message) in
            if(result ?? "") == "Success"
            {
                //                let success = RejectViewControllerViewController.initialization()!
                //                success.successString = "Sales quotation proposal uploaded successfully"
                //                self.navigationController?.pushViewController(success, animated: true)
                
                let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                    
                    
                    self.navigationController?.popToRootViewController(animated: true)
                }
                self.alert("Sales quotation proposal uploaded successfully", [ok])
            }
            
            else
            {
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
}



