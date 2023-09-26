//
//  InstallerShedulerViewController.swift
//  Refloor
//
//  Created by Bincy C A on 22/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit

class InstallerShedulerViewController: UIViewController,installerConfirmProtocol,UICollectionViewDelegateFlowLayout {
    func installerConfirm()
    {
        installerSubmitBtnApiCall()
    }
    
    
    static func initialization() -> InstallerShedulerViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "InstallerShedulerViewController") as? InstallerShedulerViewController
    }

    @IBOutlet weak var installerRightBtn: UIButton!
    @IBOutlet weak var installerLeftBtn: UIButton!
    @IBOutlet weak var installerCollectionView: UICollectionView!
    var selectedIndex = 0
    var availableDatesdata = [AvailableDatesValues]()
    var saleOrderId:Int = Int()
    var installationId:Int = Int()
    var installationDate:String = String()
    var name:String = String()
    //let count = 7
    var currentIndex = 0
    let itemsPerPage = 5
    //var dates = ["00","01","02","03","04","05","06"]//,"07","08","09","10","11","12","13","14","15","16","17","18","19"]
    override func viewDidLoad()
    {
        super.viewDidLoad()
        installerLeftBtn.layer.cornerRadius = installerLeftBtn.frame.height / 2
        installerRightBtn.layer.cornerRadius = installerRightBtn.frame.height / 2
        //installerLeftBtn.borderWidth = 0
       
        installerRightBtn.isHidden = true
        installerLeftBtn.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Submit")
        
        installerDatesApiCall()
        
    }
    
    func installerSubmitBtnApiCall()
    {
 
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
            let parameter : [String:Any] = ["token": UserData.init().token!, "sale_order_id": saleOrderId ,"installation_id": installationId]
            
            HttpClientManager.SharedHM.installerDatesSubmitAPi(parameter: parameter) { success, message in
                if success == "Success"
                {
                    // self.installerConfirm?.installerConfirm()
                    
                    
                    let installer = InstallerSuccessViewController.initialization()!
                    installer.installationDate = self.installationDate
                    installer.customerName = self.name
                    self.navigationController?.pushViewController(installer, animated: true)
                    
                    
                }
                else if success == "Failed" && message == "Selected Date is not available now. Please select different date"
                {
                    let installerPopUp = InstallerPopUpViewController.initialization()!
                    installerPopUp.installationId = self.installationId
                    installerPopUp.saleOrderId = self.saleOrderId
                    //installerPopUp.installerConfirm = self
                    self.present(installerPopUp, animated: true, completion: nil)
                }
                else if success == "false"
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        self.installerSubmitBtnApiCall()
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
                }
                else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                {
                    
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        self.fourceLogOutbuttonAction()
                    }
                    
                    self.alert((message) ?? AppAlertMsg.serverNotReached, [yes])
                    
                }
                else{
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        self.installerSubmitBtnApiCall()
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert(message ?? AppAlertMsg.NetWorkAlertMessage, [yes,no])
                }
            }
        }
            else{
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    self.installerSubmitBtnApiCall()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
                    
                  
                
                self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
            }
        }
    
    
    func installerDatesApiCall()
    {
        if HttpClientManager.SharedHM.connectedToNetwork()
        {
        let parameter : [String:Any] = ["token": UserData.init().token!, "appointment_id": AppDelegate.appoinmentslData.id!]
        
            HttpClientManager.SharedHM.installerDatesAPi(parameter: parameter) { success, message, availableDates, saleOrderId in
                if success == "Success"
                {
                    self.saleOrderId = saleOrderId ?? 0
                    self.availableDatesdata = availableDates!
                    if self.availableDatesdata.count > 0
                    {
                        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Submit")
                    }
                    self.installerCollectionView.reloadData()
                }
                else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                {
                    
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        self.fourceLogOutbuttonAction()
                    }
                    
                    self.alert((message) ?? AppAlertMsg.serverNotReached, [yes])
                    
                }
                else if success == "Failed"
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.installerDatesApiCall()
                        
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Retry")
                    }
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                }
        
                else
                {
                    //self.alert(message ?? "", nil)
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.installerDatesApiCall()
                        
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Retry")
                    }
                    
                    self.alert( message ?? AppAlertMsg.serverNotReached, [yes,no])
                }
            }
        }
        else{
            let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                self.installerDatesApiCall()
            }
            let no = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION",submitText: "Retry")
            }
            
            self.alert(AppAlertMsg.NetWorkAlertMessage, [yes,no])
        }
    }
    
    @IBAction func installerLeftBtnAction(_ sender: UIButton)
    {
        currentIndex -= 5
        if currentIndex <= 0
        {
            currentIndex = 0
        }
       
            installerCollectionView.reloadData()
    }
    @IBAction func installerRightBtnAction(_ sender: UIButton)
    {
        var lastIndex = currentIndex
        lastIndex += 5
        if availableDatesdata.count <= lastIndex
        {
            
            return
        }
        else
        {
            currentIndex += 5
            installerCollectionView.reloadData()
        }
    }
    
    override func insallerSkipBtnAction(sender: UIButton)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func insallerSubmitBtnAction(sender: UIButton)
    {
         if sender.titleLabel?.text == "Retry"
        {
            installerDatesApiCall()
        }
        else
        {
             if installationId == 0
            {
                self.alert("Please select a date and proceed", nil)
            }
            
            else
            {
                let installerPopUp = InstallerPopUpViewController.initialization()!
                installerPopUp.installationId = installationId
                installerPopUp.saleOrderId = saleOrderId
                installerPopUp.installerConfirm = self
                self.present(installerPopUp, animated: true, completion: nil)
            }
        }

    }
    
}

extension InstallerShedulerViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if availableDatesdata.count > 5
        {
            installerRightBtn.isHidden = false
            installerLeftBtn.isHidden = false
        }
        else
        {
            installerRightBtn.isHidden = true
            installerLeftBtn.isHidden = true
        }
        let remainingItems = availableDatesdata.count - currentIndex
        return min(itemsPerPage, remainingItems)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InstallerSchedulerCollectionViewCell", for: indexPath) as! InstallerSchedulerCollectionViewCell
        //cell.dateLbl.text = dates[indexPath.row + currentIndex]
                cell.dateLbl.text = availableDatesdata[indexPath.row + currentIndex].startDate?.installerDate(installationDate: availableDatesdata[indexPath.row + currentIndex].startDate!)
                var installerWeekDayDate = availableDatesdata[indexPath.row + currentIndex].startDate?.logDate()
                cell.weekNameLbl.text = availableDatesdata[indexPath.row + currentIndex].startDate?.getInstallerWeekDay(installerDate: installerWeekDayDate!)
        
        
        if indexPath.row == selectedIndex
        {
            cell.borderColor = UIColor().colorFromHexString("#D29B3C")
            cell.borderWidth = 2
            cell.backgroundColor = UIColor().colorFromHexString("#292562")
            cell.tickImgView.isHidden = false
                            installationId = availableDatesdata[indexPath.row + currentIndex].installationId ?? 0
                            installationDate = cell.dateLbl.text!
        }
        else
        {
            cell.borderColor = UIColor().colorFromHexString("#586471")
            cell.borderWidth = 1
            cell.backgroundColor = UIColor().colorFromHexString("#2D343D")
            cell.tickImgView.isHidden = true
        }
        
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedIndex = indexPath.row
                installationId = availableDatesdata[indexPath.row + currentIndex].installationId ?? 0
                installationDate = availableDatesdata[indexPath.row + currentIndex].startDate?.installerDate(installationDate: availableDatesdata[indexPath.row].startDate!) ?? ""
        self.installerCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let yourWidth = ((collectionView.bounds.width) - (17 * 4)) / 5
        return CGSize(width: yourWidth, height: 110)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))

        if cellCount < 5 {
            let yourWidth = ((collectionView.bounds.width) - (17 * 4)) / 5
            let cellWidth = yourWidth + 17.0//flowLayout.minimumInteritemSpacing
            //let cellWidth = 163.0//flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            print("cellWidth : ",cellWidth)
            print("cellCount : ",cellCount)
            let totalCellWidth = cellWidth * cellCount
            print("totalCellWidth : ",totalCellWidth)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right - flowLayout.headerReferenceSize.width - flowLayout.footerReferenceSize.width
            print("contentWidth : ",contentWidth)
            if (totalCellWidth < contentWidth)
            {
                //let padding = (contentWidth - totalCellWidth + flowLayout.minimumInteritemSpacing) / 2.0
                let padding = (collectionView.frame.size.width - totalCellWidth + flowLayout.minimumInteritemSpacing) / 2.0 //+ flowLayout.minimumInteritemSpacing - 17
                print("Padding : ",padding)
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            }
            
            
        
        }

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 17)
    }
    
    
    
    

        

    


}





