//
//  SelectARoomViewController.swift
//  Refloor
//
//  Created by sbek on 08/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

class SelectARoomViewController :UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    static func initialization() -> SelectARoomViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SelectARoomViewController") as? SelectARoomViewController
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    var roomData:[RoomDataValue] = []
    var appoinmentsData:AppoinmentDataValue!
    var areaValue:CGFloat = 0
    var messurementID = -1
    var summaryData:SummeryDetailsData!
    
    var names = ["Kitchen","Master Bedroom","Living Room","Family Bedroom","Bathroom","Others"]
    var images = [UIImage(named: "kitchen"),UIImage(named: "bedroom"),UIImage(named: "living"),UIImage(named: "bathroom"),UIImage(named: "Other")]
    var selectedno = -1
    var imagePicker: CaptureImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarbaclogoAndStatus(with: "Room Selection")
        //get all master room data
        roomData = getMasterRoomFromDB()
        let appointmentId = AppointmentData().appointment_id ?? 0
        let roomExists = getCompletedRoomFromDB(appointmentId: appointmentId)
        let allExistingRoomIds = roomExists.map{$0.room_id}
        roomData.forEach{ room in
            if allExistingRoomIds.contains(room.id ?? 0){
                room.measurement_exist = "true"
            }
        }
        
        print(allExistingRoomIds)
//        let roomsInMasterThatAlreadyExist = roomData.filter { room in
//            return allExistingRoomIds.interfaces.contains(<#T##Self.Output#>)
//        }
//        let appExits = getCompletedAppointmentsFromDB(appointmentId: appoinmentsData.id ?? 0)
        
        //getroomDataDetails(nil)
        // nextButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomDetailsCollectionViewCell", for: indexPath) as! RoomDetailsCollectionViewCell
        
        if (roomData[indexPath.row].measurement_exist ?? "").lowercased() == "true"
        {
            cell.bGView.backgroundColor = UIColor().colorFromHexString("#586471")
            cell.closeImage.isHidden = false
            cell.roomView.borderColor = UIColor.clear
        }
        else
        {
            cell.closeImage.isHidden = true
            cell.bGView.backgroundColor = UIColor().colorFromHexString("#2D343D")
            cell.roomView.borderColor = UIColor.clear
        }
        if selectedno == indexPath.row
        {
            cell.bGView.borderColor = UIColor().colorFromHexString("#292562")//#rgba(201, 63, 72, 1)
            cell.roomView.borderColor = UIColor().colorFromHexString("#A7B0BA")
            cell.roomView.layer.borderWidth = 1
            
            cell.bGView.layer.borderWidth = 5
        }
        else
        {
            cell.bGView.layer.borderColor = UIColor(displayP3Red: 45/255, green: 52/255, blue: 61/255, alpha: 1).cgColor//#rgba(45, 52, 61, 1)
            cell.bGView.layer.borderWidth = 0
            cell.roomView.borderColor = UIColor.clear
        }
        
        
        let name = roomData[indexPath.row].name
        if(name ?? "").lowercased().contains("bathroom")
        {
            cell.nameLabel.text = name
            cell.iconImageView.image = images[3]
        }
        else if(name ?? "").lowercased().contains("kitchen")
        {
            cell.nameLabel.text = name
            cell.iconImageView.image = images[0]
        }
        else if(name ?? "").lowercased().contains("basement")
        {
            cell.nameLabel.text = name
            cell.iconImageView.image = UIImage(named: "basement")
        }
        else if(name ?? "").lowercased().contains("stair")
        {
            cell.nameLabel.text = name
            cell.iconImageView.image = UIImage(named: "stair")
        }
        else if(name ?? "").lowercased().contains("living")
        {
            cell.nameLabel.text = name
            cell.iconImageView.image = images[2]
        }
        else if(name ?? "").lowercased().contains("room")
        {
            cell.nameLabel.text = name
            cell.iconImageView.image = images[1]
        }
        else
        {
            cell.nameLabel.text = name
            cell.iconImageView.image = images[4]
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/5, height: 100)
    }
    
    func isThisNameisAlreadyInclude(name:String) -> Bool
    {
        var isInclude = false
        for room in roomData
        {
            if (room.name ?? "").removeUnvantedcharactoes().lowercased() == name.removeUnvantedcharactoes().lowercased()
            {
                isInclude = true
            }
        }
        return isInclude
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(roomData[indexPath.row].name ?? "").lowercased().contains("other")
        {
            let alert = UIAlertController(title: AppDetails.APP_NAME, message: "Please enter the name of the room", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Ex: Bed Room 2"
            }
            let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                if let textfield = alert.textFields?[0]
                {
                    if((textfield.text ?? "").removeUnvantedcharactoes() != "")
                    {
                        if !self.isThisNameisAlreadyInclude(name: (textfield.text ?? ""))
                        {
                            self.addRoomtolist(name: textfield.text ?? "")
                        }
                        else
                        {
                            self.alert("Room is already exist", nil)
                        }
                    }
                    else  {
                        self.alert("Invalid room name", nil)
                    }
                }
            }
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
        }
        else if (roomData[indexPath.row].measurement_exist ?? "").lowercased() != "true"
        {
            if selectedno == -1
            {
                nextButton.isHidden = false
                selectedno = indexPath.row
                self.collectionView.reloadItems(at: [[0,selectedno]])
            }
            else
            {
                if(selectedno != indexPath.row)
                {
                    let temp = selectedno
                    selectedno = indexPath.row
                    self.collectionView.reloadItems(at: [[0,temp],[0,selectedno]])
                }
            }
        }
    }
    
    func getroomDataDetails(_ name:String?)
    {
        HttpClientManager.SharedHM.RoomListDetailsApi(self.appoinmentsData.id ?? 0) { (result, message, value) in
            if(result ?? "") == "Success"
            {
                self.roomData = value ?? []
                if let room = name
                {
                    self.setCustomRoom(with: room)
                }
                self.collectionView.reloadData()
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
                    
                    self.getroomDataDetails(nil)
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func setCustomRoom(with name:String)
    {
        self.selectedno = -1
        var i = 0
        for room in self.roomData
        {
            if (room.name ?? "").lowercased() == name.lowercased()
            {
                self.selectedno = i
            }
            i += 1
        }
        if selectedno != -1
        {
            let customeShape = CustomShapeLineViewController.initialization()!
            customeShape.roomData = self.roomData[self.selectedno]
            customeShape.appoinmentslData = self.appoinmentsData
            self.navigationController?.pushViewController(customeShape, animated: true)
        }
    }
    
    func addRoomtolist(name:String)
    {
        HttpClientManager.SharedHM.AddoRommToListApi(appointment_id: self.appoinmentsData.id ?? -1, room_name: name) { (result, message, value) in
            if(result ?? "") == "Success"
            {
                self.getroomDataDetails(name)
                
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
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    //    func CheckRoomAvailabilityApiCall(_ roomData:RoomDataValue)
    //    {
    //        let parameter:[String:Any] = ["token":(UserData().token ?? ""),"appointment_id":(appoinmentslData.id ?? 0),"floor_id":floorLevelData.id ?? 0,"room_id": (roomData.id ?? 0)]
    //        HttpClientManager.SharedHM.CheckRoomAvailability(parameter: parameter) { (result, message, values) in
    //            if(result ?? "").lowercased() == "true"
    //            {
    //                self.alert("This room is already exist", nil)
    //            }
    //            else if(result ?? "").lowercased() == "false"
    //            {
    //            let customeShape = CustomShapeLineViewController.initialization()!
    //            customeShape.floorLevelData = self.floorLevelData
    //            customeShape.roomData = self.roomData[self.selectedno]
    //            customeShape.appoinmentslData = self.appoinmentslData
    //            self.navigationController?.pushViewController(customeShape, animated: true)
    //            }
    //            else
    //            {
    //                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
    //            }
    //        }
    //    }
    
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if selectedno != -1
        {
            //arb
            let appointmentId = AppointmentData().appointment_id ?? 0
            let currentClassName = String(describing: type(of: self))
            let classDisplayName = "RoomSelection"
            self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
            //
            
            let string = self.roomData[self.selectedno].name!
            if((string.contains("STAIR")) || (string.contains("stair")) || (string.contains("Stair")))
            {
                // stairDataUpload()
                let next = AboutRoomViewController.initialization()!
                next.appoinmentID = self.appoinmentsData.id ?? 0
                next.roomID = self.roomData[self.selectedno].id ?? 0
                next.roomName = self.roomData[self.selectedno].name ?? ""
                next.isStair = 1
                next.area = self.areaValue
                
                self.summaryData = self.createSummaryData(roomID: self.roomData[self.selectedno].id ?? 0, roomName: self.roomData[self.selectedno].name ?? "")
                let roomSelected = self.roomData[self.selectedno]
                let roomName = roomSelected.name ?? ""
                let appointmentId = self.appoinmentsData.id ?? 0
                let roomType = roomName.localizedCaseInsensitiveContains("Stairs") ? "Stairs" : "Floor"
                var partiallyCompletedRoomToUpdate:[String:Any] = ["room_id":roomSelected.id ?? 0,"measurement_exist":"true","appointment_id":appointmentId, "room_name":roomName ,"room_type":roomType]
                do{
                    let realm = try Realm()
                    try realm.write{
                        if let room = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)?.rooms.filter("room_id == %d", roomSelected.id ?? 0){
                            let room_attachments = room.first?.room_attachments
                            partiallyCompletedRoomToUpdate["room_attachments"] = room_attachments
                        }
                        if realm.objects(rf_completed_room.self).filter("appointment_id == %d AND room_id == %d",appointmentId,roomSelected.id ?? 0).count == 0{
                            realm.create(rf_completed_room.self, value: partiallyCompletedRoomToUpdate, update: .all)
                        }
                    }
                }catch{
                    print(RealmError.initialisationFailed)
                }
                self.navigationController?.pushViewController(next, animated: true)
            }
            
            else
            {
                let customeShape = CustomShapeLineViewController.initialization()!
                customeShape.roomData = self.roomData[self.selectedno]
                customeShape.appoinmentslData = self.appoinmentsData
                self.navigationController?.pushViewController(customeShape, animated: true)
            }
            
            
        }
        
        else
        {
                    let okAction = UIAlertAction(title: "OK", style: .cancel)
                    self.alert("Please select a room to continue", [okAction])
                }
        
    }
    
    func stairDataUpload()
    {
        
        HttpClientManager.SharedHM.StairtSubmitMapFn(floor_id: "", room: self.roomData[self.selectedno], appointment_id: "\(self.appoinmentsData.id ?? 0)") { (result, message, data, value) in
            
            if(result == "Success")
            {
                let next = AboutRoomViewController.initialization()!
                next.appoinmentID = self.appoinmentsData.id ?? 0
                next.roomID = self.roomData[self.selectedno].id ?? 0
                next.roomName = self.roomData[self.selectedno].name ?? ""
                next.isStair = 1
                next.drowingImageID = data ?? 0
                next.area = self.areaValue
                self.messurementID = data ?? 0
                
                if(value != nil)
                {
                    self.summaryData = value![0]
                    next.value = self.summaryData.attachment_comments ?? ""
                    next.uploadedImage = self.summaryData.attachments ?? []
                    next.summaryData = self.summaryData
                }
                self.navigationController?.pushViewController(next, animated: true)
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.stairDataUpload()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                //  self.alert(message ?? AppAlertMsg.serverNotReached, nil)
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
extension SelectARoomViewController: ImagePickerDelegate {

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
