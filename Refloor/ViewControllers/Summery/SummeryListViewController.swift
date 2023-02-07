//
//  SummeryListViewController.swift
//  Refloor
//
//  Created by sbek on 27/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

class SummeryListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,DropDownForTableViewCellDelegate {
    
    
    
    static func initialization() -> SummeryListViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SummeryListViewController") as? SummeryListViewController
    }
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var swipeLeftLbl: UILabel!
    @IBOutlet weak var MoldingTitleLbl: UILabel!
    @IBOutlet weak var MoldingView: UIView!
    var imagePicker: CaptureImage!
    var validationTileColorRoomName = ""
    var validationMoldingColorRoomName = ""
    var appoinmentID:Int = 0
    var stairCount:Int = 0
    var tableValues:[SummeryListData] = []
    var area:Double = 0
    var isFromStatus = false
    
    var isselectedColor = 0
    var isselectedMolding = 0
    var globalMeasurement_id:Int = 0
    var globalColor_id:Int = 0
    var globalMoldingName = ""
    
    var moldingNamesArray:[String] = []
    var colorNamesArray:Results<rf_master_color_list>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "Measurement Summary".uppercased())
        if !(isFromStatus)
        {
            if let firstViewController = self.navigationController?.viewControllers[0]
            {
                self.navigationController?.viewControllers = [firstViewController,self]
                
            }
        }
        else
        {
            self.addNewButton.isHidden = true
            self.nextButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    override func performSegueToReturnBack() {
        if (isFromStatus)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            let details = CustomerDetailsOneViewController.initialization()!
            details.floorLevelData = AppDelegate.floorLevelData
            details.floorShapeData = []
            details.roomData = AppDelegate.roomData
            details.appoinmentslData = AppDelegate.appoinmentslData
            self.navigationController?.pushViewController(details, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadRefreshData()
        //summertListApi()
    }
    
    func loadRefreshData(){
        tableValues = self.getRoomsSummary(appointmentId: AppointmentData().appointment_id ?? 0)
        
        if tableValues.count != 0{
            self.tableReload(tableValues)
            self.swipeLeftLbl.isHidden = false
        }else{
            self.tableReload(tableValues)
            self.swipeLeftLbl.isHidden = true
        }
    }
    
    func calculateFloorColorUpchargeAndExtraCost(rooms:[SummeryListData]) -> (totalUpcharge: Double, extraCost: Double, extraCostExclude: Double, totalStairCountOfAllRooms: Int){
            var upCharge: Double = 0.0
            var totalExtraCost: Double = 0.0
            var totalExtraCostToReduce: Double = 0.0
            var totalStairCount = 0
            for roomData in rooms{
                if ((roomData.color ?? "") != "" && (roomData.striked ?? "").lowercased() == "false"){
                    let currentRoomUpcharge = ((roomData.adjusted_area ?? 0.0) * (roomData.colorUpCharge ?? 0.0))
                    let roomId = roomData.room_id ?? 0
                    self.saveUpchargeCostPerRoomToCompletedAppointment(roomId: roomId, upChargeCost: currentRoomUpcharge)
                    totalExtraCost = totalExtraCost +  self.getExtraCostFromCompletedAppointment(roomId: roomId )
                    totalExtraCostToReduce = totalExtraCostToReduce + self.getExtraCostExcludeFromCompletedAppointment(roomId: roomId)
                    upCharge =  upCharge + currentRoomUpcharge
                    if (roomData.room_name ?? "").localizedCaseInsensitiveContains("stair") {
                        totalStairCount = totalStairCount + (roomData.stair_count ?? 0)
                    }
                }
            }
            return (upCharge, totalExtraCost,totalExtraCostToReduce,totalStairCount)
        }
    
    
    @IBAction func scheduleListAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addNewButtonAction(_ sender: Any) {
        let room = SelectARoomViewController.initialization()!
        room.appoinmentsData = AppDelegate.appoinmentslData
        self.navigationController?.pushViewController(room, animated: true)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if(validationTileColorRoomName != "")
        {
            self.alert("Please choose flooring color for \(validationTileColorRoomName)", nil)
            
        }
        else if (validationMoldingColorRoomName != "")
        {
            self.alert("Please choose molding option for \(validationMoldingColorRoomName)", nil)
            
        }
        else
        {
            if(self.area > 0 || self.stairCount > 0)
            {
                let roomsWithoutImage = tableValues.filter({$0.room_image_url == ""})
                if roomsWithoutImage.count > 0{
                    self.alert("Please add image for \(roomsWithoutImage[0].name ?? "room")", nil)
                    return
                }
                for room in tableValues{
                    if self.checkIfAnswerPendingForAnyMandatoryQuestion(appointmentId: appoinmentID, roomId: room.room_id ?? -1,roomName: room.name ?? ""){
                        self.alert("Please answer mandatory questions for \(room.name ?? "room")", nil)
                        return
                    }
                }
                //arb
                let appointmentId = AppointmentData().appointment_id ?? 0
                let currentClassName = String(describing: type(of: self))
                let classDisplayName = "MeasurementList"
                getAppointmentResultToShow(className: classDisplayName, isNextBtn: true)
                self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
                //
                let paymentOptions = PaymentOptionsNewViewController.initialization()!
                paymentOptions.area = self.area
               
                //arb
                let (totalUpchargeForAllRooms,extraCostConsideringQuestions, extraCostToExclude,totalStairCount) = self.calculateFloorColorUpchargeAndExtraCost(rooms: self.tableValues)
                print(totalUpchargeForAllRooms)
                print(extraCostConsideringQuestions)
                paymentOptions.stairCount = totalStairCount
                paymentOptions.totalUpchargeCost = totalUpchargeForAllRooms
                paymentOptions.totalExtraCost = extraCostConsideringQuestions
                //paymentOptions.totalExtraCostToReduce = extraCostToExclude
                paymentOptions.discount_exclude_amount = extraCostToExclude
                //
                self.navigationController?.pushViewController(paymentOptions, animated: true)
            }
            else
            {
                self.alert("Please choose at least one room to proceed", nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let summery = SummeryDetailsViewController.initialization()!
        let roomName = tableValues[indexPath.row].room_name ?? ""
        let roomID = tableValues[indexPath.row].room_id ?? 0
        let summaryData = self.createSummaryData(roomID: roomID, roomName: roomName) //arb
        summery.summaryData = summaryData
        summery.isADetailView = true
        
        if ((summaryData.room_name ?? "").localizedCaseInsensitiveContains("stair")) {
            summery.isStair = 1
        }
        self.navigationController?.pushViewController(summery, animated: true)
        //self.summeryDetailsDataApiCall(self.tableValues[indexPath.row].contract_measurement_id ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableValues.count //(tableValues.count - 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummeryListNewTableViewCell") as! SummeryListNewTableViewCell
        //cell.selectColorNewBgView.frame.size.width = cell.colorLabel.frame.size.width
        cell.colorLabel.setRightPaddingPoints(5)
        let floorName = tableValues[indexPath.row].room_name ?? "Other"
        
        cell.strickView.isHidden = ((tableValues[indexPath.row].striked ?? "").lowercased() == "false")
        cell.floorNameLabel.text = floorName.uppercased()
        // cell.colorView.backgroundColor = .brown
        cell.colorLabel.text = ((tableValues[indexPath.row].color ?? "") == "") ? "Select Color" : (tableValues[indexPath.row].color ?? "")
        cell.molding.text = ((tableValues[indexPath.row].moulding ?? "") == "") ? "Select Molding" : (tableValues[indexPath.row].moulding ?? "")
        //cell.summeryAttachmentView.loadImageFormWeb(URL(string: tableValues[indexPath.row].room_image_url ?? ""))
        cell.summeryAttachmentView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: tableValues[indexPath.row].room_image_url ?? "")
        cell.selectColor.tag = indexPath.row
        //cell.colorView.loadImageFormWeb(URL(string: tableValues[indexPath.row].material_image_url ?? ""))
        if tableValues[indexPath.row].material_image_url ?? "" == ""{
            cell.colorView.image = UIImage(named: "AppIcon")
        }else{
            cell.colorView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: tableValues[indexPath.row].material_image_url ?? "")
        }
        cell.selectColor.addTarget(self, action: #selector(getColorPopUpFromTableViewButton(sender:)), for: .touchUpInside)
        cell.selectMolding.tag = indexPath.row
        
        cell.areaLabel.text = "Area Measured: \((tableValues[indexPath.row].adjusted_area ?? 0).clean) Sq.Ft"
        cell.colorLabel.textColor = UIColor.white
        cell.molding.textColor = UIColor.white
        if(cell.colorLabel.text == "Select Color")
        {
            // isselectedColor=1
            // cell.colorLabel.borderWidth = 3
            cell.colorLabel.textColor = UIColor.redColor
            
        }
        if(cell.molding.text == "Select Molding")
        {
            //
            //            if((tableValues[indexPath.row].stair_count ?? 0 ) > 0)
            //            {
            //                 isselectedMolding=0
            //            }
            //            else
            //            {
            //                 isselectedMolding=1
            //            }
            
            // cell.molding.borderWidth = 1
            cell.molding.textColor = UIColor.redColor
        }
        if((tableValues[indexPath.row].stair_count ?? 0 ) > 0 || (tableValues[indexPath.row].room_name ?? "").localizedCaseInsensitiveContains("stair"))
        {
            //MoldingTitleLbl.isHidden = true
            // MoldingView.isHidden = true
            cell.areaLabel.text = "Stairs Count: \(tableValues[indexPath.row].stair_count ?? 0)"
              cell.selectMolding.isUserInteractionEnabled = false
            cell.molding.isUserInteractionEnabled = false
            cell.molding.alpha = 0.3
            cell.moldingHeader.alpha = 0.3
            cell.selectMolding.alpha = 0.3
            cell.moldingBgView.alpha = 0.3
          //  cell.selectMolding.addTarget(self, action: #selector(moldingAlert(sender:)), for: .touchUpInside)
        }
        else
        {
            // MoldingTitleLbl.isHidden = false
            // MoldingView.isHidden = false
            cell.selectMolding.isUserInteractionEnabled = true
            cell.selectMolding.alpha = 1
            cell.molding.isUserInteractionEnabled = true
            cell.molding.alpha = 1
            cell.moldingHeader.alpha = 1
            cell.selectMolding.alpha = 1
            cell.moldingBgView.alpha = 1
            cell.selectMolding.addTarget(self, action: #selector(moldingRoomAlert(sender:)), for: .touchUpInside)
            cell.selectMolding.addTarget(self, action: #selector(getmoldingPopUpFromTableViewButton(sender:)), for: .touchUpInside)
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]?
    {
        
        
        let exclude = UITableViewRowAction(style: .normal, title: (((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? "Exclude": "Include").uppercased()) { action, index in
            //self.DeleteroomMeasurement(self.tableValues[editActionsForRowAt.row], false, message: "Successfully \(((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? "Excluded": "Included")")
            //arb
            let roomId = self.tableValues[editActionsForRowAt.row].room_id ?? 0
            let isStriked = self.tableValues[editActionsForRowAt.row].striked ?? "" == "false" ? true : false
            self.includeOrExcludeRoom(roomID: roomId, isInclude: isStriked)
            self.deleteDiscountArrayFromDb() 
            let okBtn = UIAlertAction(title: "OK", style: .cancel)
            self.alert("Successfully \(((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? "Excluded": "Included")", [okBtn])
            self.loadRefreshData()
            //
            
        }
        exclude.backgroundColor = ((self.tableValues[editActionsForRowAt.row].striked ?? "").lowercased() == "false") ? UIColor().colorFromHexString("#292562"): .greenColor
        
        
        
        let edit = UITableViewRowAction(style: .normal, title: "Delete".uppercased()) { action, index in
           // self.DeleteroomMeasurement(self.tableValues[editActionsForRowAt.row], true, message: "Successfully Deleted")
            let roomId = self.tableValues[editActionsForRowAt.row].room_id ?? 0
            self.deleteRoom(roomID:roomId)
            self.deleteDiscountArrayFromDb()
            self.loadRefreshData()
        }
        edit.backgroundColor = UIColor().colorFromHexString("#A7B0BA")
        return [exclude, edit]
    }
    func tableReload(_ values:[SummeryListData])
    {
        self.tableValues = values
        var area:Double = 0
        var stairTemp:Int = 0
        var validationTempTileColorRoomName = ""
        var validationTempMoldingColorRoomName = ""
        //var validationTileColor = ""
        for value in values
        {
            if (value.striked ?? "").lowercased() == "false"
            {
                area += value.adjusted_area ?? 0
                stairTemp += value.stair_count ?? 0
                if(value.color == "Select Color")
                {
                    validationTempTileColorRoomName = value.room_name ?? ""
                }
                if(value.moulding == "")
                {
                    
                  //  if(value.room_name != "Stairs")
                    let string = value.room_name!
                    if(!((string.contains("STAIR")) || (string.contains("stair")) || (string.contains("Stair"))))
                    {
                        validationTempMoldingColorRoomName = value.room_name ?? ""
                    }
                }
            }
        }
        self.area = area
        self.stairCount = stairTemp
        self.validationTileColorRoomName = validationTempTileColorRoomName
        self.validationMoldingColorRoomName = validationTempMoldingColorRoomName
        self.headingLabel.text = "Total Area Measured - \(self.area.clean) Sq.Ft"
        self.tableView.reloadData()
    }
    @objc func getColorPopUpFromTableViewButton(sender:UIButton)
    {
        var value:[String] = []
        //arb
        let  Colorvalue = getColorList()
        self.colorNamesArray = Colorvalue
        value = Colorvalue.compactMap({$0.color_name})
         
        //
//        for val in tableValues[sender.tag].material_colors ?? []
//        {
//            value.append(val.color ?? "Unknown")
//        }
        
        if(value.count != 0)
        {
            self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 1, cell: sender.tag)
        }
        else
        {
            self.alert("Not Available", nil)
        }
        
    }
    @objc func getmoldingPopUpFromTableViewButton(sender:UIButton)
    {
        //  self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, ["VINYL WHITE","PRIMED WHITE","UNFINISHED","MATCHING"], -1, delegate: self, tag: 2, cell: sender.tag)
        
        
        var value:[String] = []
        //arb
        let  moldValue = self.getMoldList()
        value = moldValue.compactMap({$0.name})
        self.moldingNamesArray = value
        //
//        for val in tableValues[sender.tag].molding_Type ?? []
//        {
//            value.append(val.name ?? "Unknown")
//        }
        
        if(value.count != 0)
        {
            self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 2, cell: sender.tag)
        }
        else
        {
            self.alert("Not Available", nil)
        }
        
        
        
        
        
    }
//    @objc func moldingAlert(sender:UIButton)
//    {
//        self.alert("Molding option is not available for Stairs", nil)
//    }
    @objc func moldingRoomAlert(sender:UIButton)
    {
        //self.alert("Molding option is not available for Stairs", nil)
    }
    func updateTitleColorApi(measurement_id:Int,material_id:Int)
    {
        globalMeasurement_id = measurement_id
        globalColor_id = material_id
        let parameter:[String : Any] =  ["token":UserData.init().token ?? "","data": [ "measurement_id": measurement_id,"material_id":material_id]]
        
        HttpClientManager.SharedHM.UpdateTilesColorApi(parameter: parameter) { (success, message) in
            if(success ?? "").lowercased() == "success" || (success ?? "").lowercased() == "true"
            {
                // self.isselectedColor = 0
                self.summertListApi()
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.updateTitleColorApi(measurement_id: self.globalMeasurement_id,material_id: self.globalColor_id)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func updateMouldingApi(measurement_id:Int,moulding_type:String)
    {
        globalMeasurement_id = measurement_id
        globalMoldingName = moulding_type
        
        let parameter:[String : Any] =  ["token":UserData.init().token ?? "","data": [ "measurement_id": measurement_id,"moulding_type":moulding_type]]
        
        HttpClientManager.SharedHM.UpdateMoldingApi(parameter: parameter) { (success, message) in
            if(success ?? "").lowercased() == "success" || (success ?? "").lowercased() == "true"
            {
                //   self.isselectedMolding = 0
                self.summertListApi()
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.updateMouldingApi(measurement_id: self.globalMeasurement_id,moulding_type: self.globalMoldingName)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func summertListApi()
    {
        HttpClientManager.SharedHM.RoomSummeryListApi(appoinmentID) { (result, message, value) in
            if(result == "Success")
            {
                if(value ?? []).count != 0
                {
                    self.tableReload(value!)
                    self.swipeLeftLbl.isHidden = false
                }
                else
                {
                    let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                        self.tableReload(value!)
                        self.swipeLeftLbl.isHidden = true
                        //self.performSegueToReturnBack()
                    }
                    self.alert("You didn't measured any room" , [ok])
                    
                    
                }
            }
            else if ((result ?? "") == "AuthFailed" || ((result ?? "") == "authfailed"))
            {
                
                let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                    
                    self.fourceLogOutbuttonAction()
                }
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
                
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.summertListApi()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                //                let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                //                    self.performSegueToReturnBack()
                //                }
                //                self.alert(message ?? AppAlertMsg.serverNotReached , [ok])
            }
        }
        
    }
    func summeryDetailsDataApiCall(_ masuremetID:Int)
    {
        globalMeasurement_id = masuremetID
        HttpClientManager.SharedHM.RoomSummeryDetailsApi(masuremetID) { (result,message, value) in
            if(result == "Success")
            {
                if(value ?? []).count != 0
                {
                    let summery = SummeryDetailsViewController.initialization()!
                    summery.summaryData = value![0]
                    if(value![0].room_name == "Stairs")
                    {
                        summery.isStair = 1
                    }
                    summery.isADetailView = true
                    self.navigationController?.pushViewController(summery, animated: true)
                }
                else
                {
                    self.alert("No record available", nil)
                }
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.summeryDetailsDataApiCall(self.globalMeasurement_id)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                //self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func DeleteroomMeasurement(_ data:SummeryListData,_ isDelete:Bool,message:String)
    {
        let data = ["contract_measurement_id":data.contract_measurement_id ?? 0,"operation":(isDelete) ? "delete": "strike"] as [String : Any]
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        HttpClientManager.SharedHM.DeleteRoomMeasurement(parameter: parameter) { (result, errormessage, valuse) in
            if(result == "True")
            {
                //  let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.summertListApi()
                /// }
                // self.alert(message, [ok])
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.summertListApi()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                // self.alert(errormessage ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func DropDownDidSelectedAction(index: Int, item: String, tag: Int, cell: Int) {
        if(tag == 2)
        {
            //  let moudlings = ["VINYL WHITE","PRIMED WHITE","UNFINISHED","MATCHING"]
            //   updateMouldingApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, moulding_type: moudlings[index])
            
            
            //arb
            let selectedMold = self.moldingNamesArray[index]
            let roomId = self.tableValues[cell].room_id ?? 0
            self.updateRoomMoldOrColor(roomID: roomId, moldName: selectedMold)
            self.loadRefreshData()
            //
            
            //updateMouldingApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, moulding_type: self.tableValues[cell].molding_Type?[index].name ?? "")
            
            
            
        }
        else if tag == 1
        {
            //updateTitleColorApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, material_id: self.tableValues[cell].material_colors?[index].material_id ?? 0)
            //arb
            let selectedColor = self.colorNamesArray[index].color_name ?? ""
            let selectedColorUpCharge = self.colorNamesArray[index].color_upcharge
            let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
            //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
            let roomId = self.tableValues[cell].room_id ?? 0
            self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge)
            self.loadRefreshData()
            //
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
extension SummeryListViewController: ImagePickerDelegate {

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
