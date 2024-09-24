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
    @IBOutlet weak var applyAllBtn: UIButton!
    @IBOutlet weak var applyAllSelectColorImageView: UIImageView!
    @IBOutlet weak var applyAllSelectMoldingTxtFld: UITextField!
    @IBOutlet weak var applyAllSelectColorTxtFld: UITextField!
    @IBOutlet weak var vapourBarrierLbl: UILabel!
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
    var summaryDetailsData:[SummeryDetailsData] = []
    
    var isselectedColor = 0
    var isselectedMolding = 0
    var globalMeasurement_id:Int = 0
    var globalColor_id:Int = 0
    var globalMoldingName = ""
    var vaporbarrierValue:Double = 0.0
    
    var moldingNamesArray:[String] = []
    var moldingPriceArray:[Double] = []
    var floorColorNamesArray:Results<rf_floorColour_results>!
    var stairColourNamesArray:Results<rf_stairColour_results>!
    
    var applyAllSelectedColour:String = String()
    var applyAllColourUpCharge:Double = Double()
    var applyAllSelectedMaterialFileName:String = String()
    var applyAllSelectedMoldName:String = String()
    var applyAllSelectedMoldPrice:Double = Double()
    var firstLoad = 1
    
    var stairIndex = -1
    var roomIndex = -1
    var officeLocationId = AppDelegate.appoinmentslData.officeLocationId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        floorColorNamesArray = getFloorColorList()
        stairColourNamesArray = getStairColorList()
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
        applyAllSelectColorImageView.image = UIImage(named: "AppIcon")
        applyAllBtn.isUserInteractionEnabled = false
        applyAllBtn.setTitleColor(UIColor().colorFromHexString("A6AFB9"), for: .normal)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
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
    
    override func viewDidAppear(_ animated: Bool) 
    {
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
    
    func calculateFloorColorUpchargeAndExtraCost(rooms:[SummeryListData]) -> (totalUpcharge: Double, extraCost: Double, extraCostExclude: Double, totalStairCountOfAllRooms: Int, extraPromoCostExcluded: Double){
            var upCharge: Double = 0.0
            var totalExtraCost: Double = 0.0
            var totalExtraCostToReduce: Double = 0.0
            var totalExtraPromoPriceToReduce:Double = 0.0
            var totalStairCount = 0
            for roomData in rooms{
                if ((roomData.color ?? "") != "" && (roomData.striked ?? "").lowercased() == "false"){
                    let currentRoomUpcharge = ((roomData.adjusted_area ?? 0.0) * (roomData.colorUpCharge ?? 0.0))
                    let roomId = roomData.room_id ?? 0
                    self.saveUpchargeCostPerRoomToCompletedAppointment(roomId: roomId, upChargeCost: currentRoomUpcharge)
                    totalExtraCost = totalExtraCost +  self.getExtraCostFromCompletedAppointment(roomId: roomId )
                    let (discountcostReduced,promoCostreduced) = self.getExtraCostExcludeFromCompletedAppointment(roomId: roomId)
                    totalExtraCostToReduce = totalExtraCostToReduce + discountcostReduced
                    totalExtraPromoPriceToReduce = totalExtraPromoPriceToReduce + promoCostreduced
                    upCharge =  upCharge + currentRoomUpcharge
                    if (roomData.room_name ?? "").localizedCaseInsensitiveContains("stair") {
                        totalStairCount = totalStairCount + (roomData.stair_count ?? 0)
                    }
                }
            }
            return (upCharge, totalExtraCost,totalExtraCostToReduce,totalStairCount,totalExtraPromoPriceToReduce)
        }
    func calculateMoldingPrice(rooms:[SummeryListData]) -> (Double)
    {
        var totalMouldingPrice :Double = 0.0
        for roomData in rooms
        {
            let roomNameSubstr = roomData.room_name?.contains("STAIRS")
            if roomNameSubstr != true
            {
                if ((roomData.moulding ?? "") != "" && (roomData.striked ?? "").lowercased() == "false")
                {
                    let roomPerimeter = Double(roomData.room_perimeter ?? 0.0)
                    let currentRoomMoldingCharge = ((roomData.mouldingPrice ?? 0.0) * (roomPerimeter))
                    
                    totalMouldingPrice = totalMouldingPrice +  currentRoomMoldingCharge
                    
                }
            }
        }
        return totalMouldingPrice
    }
    
    
    @IBAction func scheduleListAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addNewButtonAction(_ sender: Any) {
        let room = SelectARoomViewController.initialization()!
        room.appoinmentsData = AppDelegate.appoinmentslData
        self.applyAllSelectedColour = ""
        self.applyAllSelectedMoldName = ""
        self.navigationController?.pushViewController(room, animated: true)
    }
    
    
    @IBAction func applyAllSelectMoldingdropBtnAction(_ sender: UIButton)
    {
        var value:[String] = []
        var moldingPriceValue :[Double] = []
        let  moldValue = self.getMoldList()
        value = moldValue.compactMap({$0.name})
        moldingPriceValue = moldValue.compactMap({$0.unit_price})
        self.moldingPriceArray = moldingPriceValue
        self.moldingNamesArray = value
        if(value.count != 0)
        {
            self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 4, cell: sender.tag)
        }
        else
        {
            self.alert("Not Available", nil)
        }
    }
    @IBAction func applyAllBtnAction(_ sender: UIButton)
    {
        for rooms in tableValues
        {
            
            
            if rooms.room_area != 0
            {
                if  applyAllSelectColorTxtFld.text != "Select Color"
                {
                    //                applyAllSelectedColour = rooms.color ?? ""
                    //                applyAllSelectedMaterialFileName = rooms.material_image_url ?? ""
                    //                applyAllColourUpCharge =  rooms.colorUpCharge ?? 0.0
                    self.updateRoomMoldOrColor(roomID: rooms.room_id ?? 0, moldName: "", isColor: true, colorName: applyAllSelectedColour, colorImageUrl: applyAllSelectedMaterialFileName, colorUpCharge: applyAllColourUpCharge, moldPrice: 0.0)
                }
                else
                {
                    self.updateRoomMoldOrColor(roomID: rooms.room_id ?? 0, moldName: "", isColor: true, colorName: rooms.color ?? "", colorImageUrl: rooms.material_image_url ?? "", colorUpCharge: rooms.colorUpCharge ?? 0.0, moldPrice: 0.0)
                }
                
                if applyAllSelectMoldingTxtFld.text != "" && applyAllSelectedMoldName != ""
                {
                    if rooms.room_name!.contains("STAIRS") && rooms.room_area == 0.0
                    {
                    }
                    else
                    {
                        if applyAllSelectedMoldName == ""
                        {
                            applyAllSelectedMoldName = rooms.moulding ?? ""
                            applyAllSelectedMoldPrice = rooms.mouldingPrice ?? 0.0
                        }
                        self.updateRoomMoldOrColor(roomID: rooms.room_id ?? 0, moldName: applyAllSelectedMoldName, moldPrice: applyAllSelectedMoldPrice)
                    }
                }
            }
        }
        
        self.loadRefreshData()
    }
    
    @IBAction func applyAllSelectColorDropDownBtnAction(_ sender: UIButton)
    {
        var value:[String] = []
        value = self.floorColorNamesArray.compactMap({$0.color})
        if(value.count != 0)
        {
            self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 3, cell: sender.tag,selectedIndex: roomIndex,floorColor: floorColorNamesArray)
        }
        else
        {
            self.alert("Not Available", nil)
        }
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
                    if self.checkIfAnswerPendingForAnyMandatoryQuestion(appointmentId: appoinmentID, roomId: room.room_id ?? -1,roomName: room.name ?? "",roomArea: room.room_area ?? 0.0){
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
                let (totalUpchargeForAllRooms,extraCostConsideringQuestions, extraCostToExclude,totalStairCount, extraPromoCostExcluded) = self.calculateFloorColorUpchargeAndExtraCost(rooms: self.tableValues)
                let totalMoldingPrice = calculateMoldingPrice(rooms: self.tableValues)
                print(totalUpchargeForAllRooms)
                print(extraCostConsideringQuestions)
                paymentOptions.stairCount = totalStairCount
                paymentOptions.totalUpchargeCost = totalUpchargeForAllRooms
                paymentOptions.totalExtraCost = extraCostConsideringQuestions + vaporbarrierValue
                paymentOptions.totalMoldingPrice = totalMoldingPrice
                paymentOptions.totalExtraCostToReduce = extraCostToExclude
                paymentOptions.totalExtraPromoCostToReduced = extraPromoCostExcluded + vaporbarrierValue + totalMoldingPrice 
                paymentOptions.vapurBarrierValue = vaporbarrierValue
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
        if ((tableValues[indexPath.row].color ?? "") != "Select Color")
        {
            cell.outOfStockView.clearGradient()
            cell.outOfStockView.applyGradient(colors: [UIColor().colorFromHexString("#72C36F00").cgColor,UIColor().colorFromHexString("#72C36F27").cgColor])
            cell.outOfStockLbl.text = "The selected item is available"
            cell.outOfStockLbl.textColor = UIColor().colorFromHexString("#72C36F")
        }
        
        cell.outOfStockView.layer.cornerRadius = 24
        cell.outOfStockView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMinXMinYCorner]


        let floorName = tableValues[indexPath.row].room_name ?? "Other"
        
        cell.strickView.isHidden = ((tableValues[indexPath.row].striked ?? "").lowercased() == "false")
        cell.floorNameLabel.text = floorName.uppercased()
        // cell.colorView.backgroundColor = .brown
        cell.colorLabel.text = ((tableValues[indexPath.row].color ?? "") == "") ? "Select Color" : (tableValues[indexPath.row].color ?? "")
        //((tableValues[indexPath.row].color ?? "") == "Select Color") ? cell.outOfStockView.isHidden = true : cell.outOfStockView.isHidden = false
        
        if ((tableValues[indexPath.row].color ?? "") == "Select Color")
        {
            cell.outOfStockView.isHidden = true
        }
        else
        {
            cell.outOfStockView.isHidden = false
        }
//        if !((tableValues[indexPath.row].color ?? "") == "Select Color") && tableValues[indexPath.row].room_area == 0.0
//        {
//            let index = stairColourNamesArray.firstIndex(of: stairColourNamesArray.filter({$0.color == self.tableValues[indexPath.row].color}).first ?? rf_stairColour_results()) ?? 0
//            stairIndex = index
//        }
//        else
//        {
//            let index = floorColorNamesArray.firstIndex(of: floorColorNamesArray.filter({$0.color == self.tableValues[indexPath.row].color}).first ?? rf_floorColour_results()) ?? 0
//            roomIndex = index
//        }
        cell.molding.text = ((tableValues[indexPath.row].moulding ?? "") == "") ? "Select Molding" : (tableValues[indexPath.row].moulding ?? "")
        //cell.summeryAttachmentView.loadImageFormWeb(URL(string: tableValues[indexPath.row].room_image_url ?? ""))
        cell.summeryAttachmentView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: tableValues[indexPath.row].room_image_url ?? "")
        cell.selectColor.tag = indexPath.row
        //cell.colorView.loadImageFormWeb(URL(string: tableValues[indexPath.row].material_image_url ?? ""))
        if tableValues[indexPath.row].material_image_url ?? "" == ""{
            cell.colorView.image = UIImage(named: "AppIcon")
        }else{
            print(tableValues[indexPath.row].material_image_url ?? "")
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
            validationTileColorRoomName = tableValues[indexPath.row].room_name ?? ""
            
        }
        if(cell.molding.text == "Select Molding") && tableValues[indexPath.row].room_area != 0
        {
            
            validationMoldingColorRoomName = tableValues[indexPath.row].room_name ?? ""
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
        if((tableValues[indexPath.row].stair_count ?? 0 ) > 0 || ((tableValues[indexPath.row].room_name ?? "").localizedCaseInsensitiveContains("stair")) && tableValues[indexPath.row].room_area == 0.0)
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
        //SummeryDetailsData
        summaryDetailsData.removeAll()
        self.tableValues = values
        var area:Double = 0
        var stairTemp:Int = 0
        var validationTempTileColorRoomName = ""
        var validationTempMoldingColorRoomName = ""
        var vaporArea:Double = 0
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
                if value.stair_count == 0 || value.stair_count == nil
                {
                    self.summaryDetailsData.append(self.createSummaryData(roomID: value.room_id!, roomName: value.room_name!))
                }
                if(value.moulding == "")
                {
                    
                  //  if(value.room_name != "Stairs")
                    let string = value.room_name!
                    if(!((string.contains("STAIR")) || (string.contains("stair")) || (string.contains("Stair"))) && value.room_area! > 0)
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
        if summaryDetailsData.count > 0
        {
            for summery in summaryDetailsData
            {
                if summery.questionaire!.count > 0
                {
                    
                    //let vaporBarrierQuestionIndex = summery.questionaire?.
                    for roomsAndQuestion in summery.questionaire!
                    {
                        
                        
                        if (roomsAndQuestion.name == "VaporBarrierBool" && roomsAndQuestion.answers![0].answer == "Yes" && roomsAndQuestion.calculate_order_wise == true)
                        {
                            vaporArea += summery.adjusted_area!
                        }
                    }
                }
            }
        }
        var vapourBarrierValue : Int = Int()
        let vapourValue = modf(vaporArea / 100)
        if vapourValue.1 == 0.0
        {
            vapourBarrierValue = Int(vapourValue.0)
        }
        else
        {
            vapourBarrierValue = Int(vapourValue.0) + 1
        }
        self.vapourBarrierLbl.text = "Vapor Barrier - \(vapourBarrierValue)"
        if UserDefaults.standard.value(forKey: "VaporBarrierAmount") != nil
        {
            vaporbarrierValue = UserDefaults.standard.value(forKey: "VaporBarrierAmount") as! Double
            vaporbarrierValue = vaporbarrierValue * Double(vapourBarrierValue)
        }
        self.tableView.reloadData()
    }
    @objc func getColorPopUpFromTableViewButton(sender:UIButton)
    {
        var value:[String] = []
        //arb
        if tableValues[sender.tag].room_name!.contains("STAIRS") && tableValues[sender.tag].room_area == 0.0//roomName.contains("STAIRS")
        {
            value = self.stairColourNamesArray.compactMap({$0.color})
        }
        else
        {
            
            value = self.floorColorNamesArray.compactMap({$0.color})
        }
        
        //
//        for val in tableValues[sender.tag].material_colors ?? []
//        {
//            value.append(val.color ?? "Unknown")
//        }
//        if !((tableValues[sender.tag].color ?? "") == "Select Color") && tableValues[sender.tag].room_area == 0.0
//        {
//            let index = stairColourNamesArray.firstIndex(of: stairColourNamesArray.filter({$0.color_name == self.tableValues[sender.tag].color}).first ?? rf_stairColour_results()) ?? -1
//            stairIndex = index
//        }
//        else
//        {
//            let index = floorColorNamesArray.firstIndex(of: floorColorNamesArray.filter({$0.color_name == self.tableValues[sender.tag].color}).first ?? rf_floorColour_results()) ?? -1
//            roomIndex = index
//        }
        
        if(value.count != 0)
        {
           if tableValues[sender.tag].room_area == 0.0
            {
               self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 1, cell: sender.tag,selectedIndex: stairIndex,stairColour: stairColourNamesArray)
           }
            else
            {
                self.DropDownDefaultfunctionForTableCell(sender, sender.bounds.width, value, -1, delegate: self, tag: 1, cell: sender.tag,selectedIndex: roomIndex,floorColor: floorColorNamesArray)
            }
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
        var moldingPriceValue :[Double] = []
        //arb
        let  moldValue = self.getMoldList()
        value = moldValue.compactMap({$0.name})
        moldingPriceValue = moldValue.compactMap({$0.unit_price})
        self.moldingPriceArray = moldingPriceValue
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return ((self.tableValues[indexPath.row].color ?? "") == "Select Color") ? 200 : 300
//    }
    
    func DropDownDidSelectedAction(index: Int, item: String, tag: Int, cell: Int) 
    {
        
        let masterData = getMasterDataFromDB()
        let officeLocationId = AppDelegate.appoinmentslData.officeLocationId
        if(tag == 2)
        {
            //  let moudlings = ["VINYL WHITE","PRIMED WHITE","UNFINISHED","MATCHING"]
            //   updateMouldingApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, moulding_type: moudlings[index])
            
            
            //arb
            let selectedMold = self.moldingNamesArray[index]
            let moldPrice = self.moldingPriceArray[index]
            let roomId = self.tableValues[cell].room_id ?? 0
            self.updateRoomMoldOrColor(roomID: roomId, moldName: selectedMold, moldPrice: moldPrice)
            self.loadRefreshData()
            //
            
            //updateMouldingApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, moulding_type: self.tableValues[cell].molding_Type?[index].name ?? "")
            
            
            
        }
        else if tag == 1
        {
            //updateTitleColorApi(measurement_id: self.tableValues[cell].contract_measurement_id ?? 0, material_id: self.tableValues[cell].material_colors?[index].material_id ?? 0)
            //arb
            if tableValues[cell].room_name!.contains("STAIRS") && tableValues[cell].room_area == 0.0
            {
                
                var InOfficeLocation = false
                for officeids in self.stairColourNamesArray[index].Office_location_ids
                {
                    if officeids == officeLocationId
                    {
                        InOfficeLocation = true
                    }
                }
                if self.stairColourNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */&& InOfficeLocation == true
                {
                    let installer = AppointmentPaymentSummaryViewController.initialization()!
                    installer.isOutOfstock = true
                    self.present(installer, animated: true, completion: nil)
//                    self.alert("Stock Not Available", nil)
//                    return
                }
                if self.stairColourNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */&& InOfficeLocation == false
                {
                    let installer = AppointmentPaymentSummaryViewController.initialization()!
                    installer.isOutOfstock = true
                    self.present(installer, animated: true, completion: nil)
//                    self.alert("Stock Not Available", nil)
//                    return
                }
                if (self.stairColourNamesArray[index].specialOrder == 1) && InOfficeLocation == false
                {
                    stairIndex = index
                    let selectedColor = self.stairColourNamesArray[index].color ?? ""
                    let selectedColorUpCharge = self.stairColourNamesArray[index].color_upcharge
                    let selectedMaterialFileName = self.getStairImageName(atIndex: index + 1)
                    //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
                    let roomId = self.tableValues[cell].room_id ?? 0
                    self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0)
                    self.loadRefreshData()
                }
            }
            else
            {
               
                let selectedColor = self.floorColorNamesArray[index].color ?? ""
                var InOfficeLocation = false
                for officeids in self.floorColorNamesArray[index].Office_location_ids
                {
                    if officeids == officeLocationId
                    {
                        InOfficeLocation = true
                    }
                }
                if self.floorColorNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */ && InOfficeLocation == true
                {
                    let installer = AppointmentPaymentSummaryViewController.initialization()!
                    installer.isOutOfstock = true
                    self.present(installer, animated: true, completion: nil)
                }
                else if self.floorColorNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */ && InOfficeLocation == false
                {
                    let installer = AppointmentPaymentSummaryViewController.initialization()!
                    installer.isOutOfstock = true
                    self.present(installer, animated: true, completion: nil)
                }
                else if (self.floorColorNamesArray[index].specialOrder == 1) && InOfficeLocation == false
                {
                    roomIndex = index
                    let NotOfficeLocation = self.floorColorNamesArray[index].Office_location_ids.filter({$0 == officeLocationId})
                    let selectedColorUpCharge = self.floorColorNamesArray[index].color_upcharge
                    let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
                    //let materialImageUrl = imageUrlInFile(byName: selectedMaterialFileName)
                    let roomId = self.tableValues[cell].room_id ?? 0
                    self.updateRoomMoldOrColor(roomID: roomId, moldName: "", isColor: true, colorName: selectedColor, colorImageUrl: selectedMaterialFileName, colorUpCharge: selectedColorUpCharge, moldPrice: 0.0)
                    self.loadRefreshData()
                }
            }
            //
        }
        else if tag == 3
        {
            roomIndex = index
            var InOfficeLocation = false
            for officeids in self.floorColorNamesArray[index].Office_location_ids
            {
                if officeids == officeLocationId
                {
                    InOfficeLocation = true
                }
            }
            if self.floorColorNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */ && InOfficeLocation == true
            {
                let installer = AppointmentPaymentSummaryViewController.initialization()!
                installer.isOutOfstock = true
                self.present(installer, animated: true, completion: nil)
            }
            else if self.floorColorNamesArray[index].specialOrder == 0 /*&& self.stairColourNamesArray[index].in_stock == 0 */ && InOfficeLocation == false
            {
                let installer = AppointmentPaymentSummaryViewController.initialization()!
                installer.isOutOfstock = true
                self.present(installer, animated: true, completion: nil)
            }
            
            
            if (self.floorColorNamesArray[index].specialOrder == 1) && InOfficeLocation == false
            {
                
                roomIndex = index
                applyAllBtn.isUserInteractionEnabled = true
                applyAllBtn.setTitleColor(.white, for: .normal)
                applyAllSelectColorTxtFld.text = item
                let selectedMaterialFileName = self.getFllorImageName(atIndex: index)
                applyAllSelectColorImageView.image =  ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: selectedMaterialFileName)
                self.applyAllSelectedColour = self.floorColorNamesArray[index].color ?? ""
                self.applyAllColourUpCharge = self.floorColorNamesArray[index].color_upcharge
                self.applyAllSelectedMaterialFileName = self.getFllorImageName(atIndex: index)
            }
            
        }
        else if tag == 4
        {
//            if self.floorColorNamesArray[index].specialOrder == 0 && self.floorColorNamesArray[index].in_stock == 0
//            {
//                self.alert("Stock Not Available", nil)
//                return
//            }
            applyAllBtn.isUserInteractionEnabled = true
            applyAllBtn.setTitleColor(.white, for: .normal)
            applyAllSelectMoldingTxtFld.text = item
            self.applyAllSelectedMoldName = self.moldingNamesArray[index]
            self.applyAllSelectedMoldPrice = self.moldingPriceArray[index]
//            let selectedMold = self.moldingNamesArray[index]
//            let moldPrice = self.moldingPriceArray[index]
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
