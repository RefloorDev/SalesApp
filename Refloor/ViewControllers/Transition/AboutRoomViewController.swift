//
//  AboutRoomViewController.swift
//  Refloor
//
//  Created by sbek on 06/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import MobileCoreServices
import PhotosUI
class AboutRoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,ExternalCollectionViewDelegate2,ExternalCollectionViewDelegateForTableView,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImageViewAndRemoveDelegate,UITextViewDelegate {
    
    static func initialization() -> AboutRoomViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "AboutRoomViewController") as? AboutRoomViewController
    }
    var user = UserData.init()
    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    var originalUploadImage = UIImage()
    var value = ""
    var roomName = ""
    var area:CGFloat = 0
    var drowingImageID = 0
    var isStair = 0
    var appoinmentID = 0
    var roomID = 0
    var delegate:SummeryEditDelegate?
    var uploadedImage:[AttachmentDataValue] = []
    var name = ""
    var placeHolder = "About Room"
    var popOver:UIPopoverController?
    var summaryData:SummeryDetailsData!
    var imagePickerUpload: CaptureImage!
    //arb
    var imageNames:[String] = []
    var protrusionImageNames:[String] = []
    var isRoomImage: Bool!
    var isRoomCollectionViewTapped: Bool!
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbaclogoAndStatus(with: "Room details - \(self.roomName)")
        imagePicker.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //arb
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let appointmentId = AppointmentData().appointment_id ?? 0
        let savedRoomImages = self.loadRoomImage(appointmentId: appointmentId, roomId: roomID)
        imageNames = savedRoomImages.map{"\($0)"}
        self.uploadedImage.removeAll()
        for i in 0..<savedRoomImages.count{
            self.uploadedImage.append(AttachmentDataValue(savedImageUrl: savedRoomImages[i], savedImageName: name, id: i))
        }
        self.tableView.reloadRows(at:[IndexPath(row: 1, section: 0)], with: .automatic)
        self.tableView.reloadRows(at:[IndexPath(row: 2, section: 0)], with: .automatic)
        
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
        //
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(placeHolder == (textView.text ?? ""))
        {
            textView.text = ""
            textView.textColor = .white
            value = textView.text ?? ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        value = textView.text ?? ""
        if(value).removeUnvantedcharactoes() == ""
        {
            textView.text = placeHolder
            textView.textColor = UIColor.placeHolderColor
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        value = textView.text ?? "" + text
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0
        {
            let a = Double(area)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutRoomHeaderTableViewCell") as! AboutRoomHeaderTableViewCell
            cell.headingLabel.text = "Area: \(a.rounded(.awayFromZero).clean) Sq.Ft"
            if(isStair == 1)
            {
                cell.headingLabel.isHidden = true;
                
            }
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutRoomDetailsTableViewCell") as! AboutRoomDetailsTableViewCell
            //arb
            cell.uploadStaticTextLabel.text = indexPath.row == 1 ? "Upload Room Images" : "Upload Protrusion Images (Optional)"
            cell.cameraButton.tag = indexPath.row
            cell.galleryUploadButton.tag = indexPath.row
            cell.cameraButton.addTarget(self, action: #selector(cameraUploadButtonAction(sender:)), for: .touchUpInside)
            cell.galleryUploadButton.addTarget(self, action: #selector(galleryUploadButtonAction(sender: )), for: .touchUpInside)
            //
            var imagenames:[String] = []
            var protrusionImagenames:[String] = []
            if indexPath.row == 1{
               let uploadedImage = uploadedImage.filter({$0.url?.contains("Attachment") ?? false})
                if uploadedImage.count == 0
                {
                    cell.noImageBtn.isHidden = false
                    cell.noImageLbl.isHidden = false
                }
                else
                {
                    cell.noImageBtn.isHidden = true
                    cell.noImageLbl.isHidden = true
                }
                for attach in uploadedImage
                {
                    imagenames.append(attach.url ?? "")
                }
                if uploadedImage.count == 0
                {
                    cell.noImageBtn.isHidden = false
                    cell.noImageLbl.isHidden = false
                }
                cell.images = imagenames//imagenames
            }else{
                let uploadedProtrusionImage = uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})
                if uploadedProtrusionImage.count == 0
                {
                    cell.noImageBtn.isHidden = false
                    cell.noImageLbl.isHidden = false
                }
                else
                {
                    cell.noImageBtn.isHidden = true
                    cell.noImageLbl.isHidden = true
                }
                for attach in uploadedProtrusionImage
                {
                    protrusionImagenames.append(attach.url ?? "")
                }
                cell.protrusionImages = protrusionImagenames
            }
            cell.collectionView.tag = indexPath.row
            cell.collectionViewDelegate = self
            cell.collectionviewReload()
            return cell
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        var imageids:[Int] = []
        let uploadedImageTemp = uploadedImage.filter({($0.url ?? "").contains("Attachment")})
        for attach in uploadedImageTemp
        {
            imageids.append(attach.id ?? 0)
        }
        if(imageids.count < 2)
        {
            self.alert("Please select two room images to proceed", nil)
            return
        }
        //arb
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "RoomImageUploading"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        //
        if self.delegate == nil{
            let next = FurnitureQustionsViewController.initialization()!
            next.appoinmentID = self.appoinmentID
            next.roomName = self.roomName
            next.roomID = self.roomID
            next.drowingImageID = self.drowingImageID
            next.area = self.area
            if(self.isStair == 1)
            {
                next.isStair = self.isStair
                //do that here
            }
            if(self.summaryData != nil)
            {
                next.isUpdated = false
                next.floorID = self.summaryData.floor_id ?? 0
                next.summaryQustions = self.summaryData.questionaire ?? []
            }
            next.isUpdated = false
            self.navigationController?.pushViewController(next, animated: true)
        }else
        {
            self.delegate?.SummeryEditDelegateInTransitionEditingDone()
            self.performSegueToReturnBack()
        }
        //submitAPICall()
        
    }
    
    //arb
     @objc override func performSegueToReturnBack()  {
        //delete room already
         if isStair == 1{
             self.deleteRoomById(appointmentId: self.appoinmentID, roomId: self.roomID)
         }
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    //
    
    @IBAction func cameraUploadButton(_ sender: UIButton) {
        isRoomImage = sender.tag == 1 ? true : false
        if isRoomImage{
            if((uploadedImage.filter({$0.url?.contains("Attachment") ?? false})).count < 8)
            {
                self.openCameraToPickImage()
            }
            else
            {
                self.alert("No more than 8 images are allowed per room", nil)
            }
        }else{
            if((uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})).count < 8)
            {
                self.openCameraToPickImage()
            }
            else
            {
                self.alert("No more than 8 protrusion images are allowed per room", nil)
            }
        }
        
    }
    
    @IBAction func galleryUploadButton(_ sender: UIButton) {
        isRoomImage = sender.tag == 1 ? true : false
        if isRoomImage{
            if((uploadedImage.filter({$0.url?.contains("Attachment") ?? false})).count < 8)
            {
                self.openPhotoLibraryToPickImage()
            }
            else
            {
                self.alert("No more than 8 images are allowed per room", nil)
            }
        }else{
            if((uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})).count < 8)
            {
                self.openPhotoLibraryToPickImage()
            }
            else
            {
                self.alert("No more than 8 protrusion images are allowed per room", nil)
            }
        }
    }
    
    //arb
    @objc func cameraUploadButtonAction( sender: UIButton) {
        isRoomImage = sender.tag == 1 ? true : false
        if isRoomImage{
            if((uploadedImage.filter({$0.url?.contains("Attachment") ?? false})).count < 8)
            {
                self.openCameraToPickImage()
            }
            else
            {
                self.alert("No more than 8 images are allowed per room", nil)
            }
        }else{
            if((uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})).count < 8)
            {
                self.openCameraToPickImage()
            }
            else
            {
                self.alert("No more than 8 protrusion images are allowed per room", nil)
            }
        }
    }
    
    @objc func galleryUploadButtonAction( sender: UIButton) {
        isRoomImage = sender.tag == 1 ? true : false
        
        if isRoomImage{
            if((uploadedImage.filter({$0.url?.contains("Attachment") ?? false})).count < 8)
            {
                self.openPhotoLibraryToPickImage()
            }
            else
            {
                self.alert("No more than 8 images are allowed per room", nil)
            }
        }else{
            if((uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})).count < 8)
            {
                self.openPhotoLibraryToPickImage()
            }
            else
            {
                self.alert("No more than 8 protrusion images are allowed per room", nil)
            }
        }
    }
    //
    
    
    
    func externalCollectionViewDidSelectbutton(index: Int, tag: Int) {
        let imagePresent = ImageViewAndRemoveViewController.initialization()!
        imagePresent.position = index
        imagePresent.attachments = self.uploadedImage
        imagePresent.isNoRemved = true
        self.present(imagePresent, animated: true, completion: nil)
        
    }
    
    func externalCollectionViewDidSelectbutton2(index: Int,tag: Int) {
        var uploadImageArray:[AttachmentDataValue] = []
        if tag == 1{
            isRoomCollectionViewTapped = true
            uploadImageArray = uploadedImage.filter({$0.url?.contains("Attachment") ?? false})
        }else{
            isRoomCollectionViewTapped = false
            uploadImageArray = uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})
        }
        if uploadImageArray.count == index
        {
            let selectImageAlert = UIAlertController(title: AppDetails.APP_NAME, message: "Please select an image.", preferredStyle: .alert)
            let cameraAct = UIAlertAction(title: "Camera", style: .default) { (_) in
                self.openCameraToPickImage()
            }
            let photoLibraryAct = UIAlertAction(title: "Photo Library", style: .default) { (_) in
                self.openPhotoLibraryToPickImage()
            }
            let cancelAct = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                
            }
            selectImageAlert.addAction(cameraAct)
            selectImageAlert.addAction(photoLibraryAct)
            selectImageAlert.addAction(cancelAct)
            
            self.present(selectImageAlert, animated: true, completion: nil)
        }
        else
        {
            let imagePresent = ImageViewAndRemoveViewController.initialization()!
            imagePresent.delegate = self
            imagePresent.position = index
            imagePresent.attachments = uploadImageArray
            self.present(imagePresent, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    func imageRemoveDelegate(at position: Int) {
        //arb
        var uploadedImageArray:[AttachmentDataValue] = []
        if isRoomCollectionViewTapped{
            uploadedImageArray = self.uploadedImage.filter({$0.url?.contains("Attachment") ?? false})
        }else{
            uploadedImageArray = self.uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})
        }
        if ImageSaveToDirectory.SharedImage.deleteImageFromDocumentDirectory(rfImage: uploadedImageArray[position].url ?? ""){
            let appointmentId = AppointmentData().appointment_id ?? 0
            if self.deleteRoomImage(savedImageUrlString: uploadedImageArray[position].url ?? "", appointmentId: appointmentId, roomId: self.roomID){
                let savedRoomImages = self.loadRoomImage(appointmentId: appointmentId, roomId: roomID)
                imageNames = savedRoomImages.map{"\($0)"}
                self.uploadedImage.removeAll()
                for i in 0..<savedRoomImages.count{
                    self.uploadedImage.append(AttachmentDataValue(savedImageUrl: savedRoomImages[i], savedImageName: name, id: i))
                }
                self.tableView.reloadData()
            }
           
        }
        //removeImage(at: position)
        
    }
    
    
    
    func openCameraToPickImage(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes =  [kUTTypeImage as String]//UIImagePickerController.availableMediaTypes(for: .camera)!
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.popOver = UIPopoverController(contentViewController: imagePicker)
            if isRoomImage{
                self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY - 300, width: 300, height: 300), in: self.view, permittedArrowDirections: .any, animated: true)
            }else{
                self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY , width: 300, height: 300), in: self.view, permittedArrowDirections: .any, animated: true)
            }
        }
        else
        {
            present(imagePicker, animated: true, completion: {
                self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
                self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
            })
        }
    }
    
    func openPhotoLibraryToPickImage(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]//UIImagePickerController.availableMediaTypes(for: .camera)!
        imagePicker.modalPresentationStyle = .popover
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.popOver = UIPopoverController(contentViewController: imagePicker)
            if isRoomImage{
                self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY - 300, width: 300, height: 300), in: self.view, permittedArrowDirections: .any, animated: true)
            }else{
                self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY  , width: 300, height: 300), in: self.view, permittedArrowDirections: .any, animated: true)
            }
            
            
        }
        else
        {
            present(imagePicker, animated: true, completion: {
                self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
                self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
            })
        }
        //present(imagePicker, animated: true, completion: nil)
        //imagePicker.popoverPresentationController?.barButtonItem = sender
        
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        
        
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
        
    }
    
    
    var imagecount = 1
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        let appointment_id = AppointmentData().appointment_id ?? 0
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            print("imageDone")
            if isRoomImage {
            name = "Attachment" + randomString(length: 10) + ".JPG"
            }else{
                name = "Protrusion" + randomString(length: 10) + ".JPG"
            }
            
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                let asset = result.firstObject
                if(asset != nil)
                {
                    let value = asset!.value(forKey: "filename") as? String
                    if(value != nil && value != "")
                    {
                        //name  = value!
                    }
                }
                dismiss(animated: true, completion: nil)
                originalUploadImage = originalImage
                //self.imageUpload(originalImage ,name)
                
                let savedImages = self.saveRoomImage(savedImageName: ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: originalImage, saveImgName: name), appointmentId: appointment_id, roomId: self.roomID)
                self.uploadedImage.removeAll()
                for i in 0..<savedImages.count{
                    self.uploadedImage.append(AttachmentDataValue(savedImageUrl: savedImages[i], savedImageName: name, id: i))
                }
                if isRoomImage{
                    let uploadedImage = self.uploadedImage.filter({$0.url?.contains("Attachment") ?? false})
                    self.imageNames = uploadedImage.map({$0.url ?? ""})
                    self.tableView.reloadRows(at: [[0,1]], with: .automatic)
                }else{
                    let uploadedImage = self.uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})
                    self.protrusionImageNames = uploadedImage.map({$0.url ?? ""})
                    self.tableView.reloadRows(at: [[0,2]], with: .automatic)
                }
                imagecount += 1
                
            }
            else if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
                let assetResources = PHAssetResource.assetResources(for: asset)
                
                let asset = assetResources.first
                if(asset != nil)
                {
                    let value = asset!.value(forKey: "filename") as? String
                    if(value != nil && value != "")
                    {
                       // name  = value!
                    }
                }
                dismiss(animated: true, completion: nil)
                originalUploadImage = originalImage
                //self.imageUpload(originalImage ,name)
                let savedImages = self.saveRoomImage(savedImageName: ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: originalImage, saveImgName: name), appointmentId: appointment_id, roomId: self.roomID)
                self.uploadedImage.removeAll()
                for i in 0..<savedImages.count{
                    self.uploadedImage.append(AttachmentDataValue(savedImageUrl: savedImages[i], savedImageName: name, id: i))
                }
                if isRoomImage{
                    let uploadedImage = self.uploadedImage.filter({$0.url?.contains("Attachment") ?? false})
                    self.imageNames = uploadedImage.map({$0.url ?? ""})
                    self.tableView.reloadRows(at: [[0,1]], with: .automatic)
                }else{
                    let uploadedImage = self.uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})
                    self.protrusionImageNames = uploadedImage.map({$0.url ?? ""})
                    self.tableView.reloadRows(at: [[0,2]], with: .automatic)
                }
                imagecount += 1
            }
            else
            {
                dismiss(animated: true, completion: nil)
                originalUploadImage = originalImage
                //imageUpload(originalImage ,name)
                let savedImages = self.saveRoomImage(savedImageName: ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: originalImage, saveImgName: name), appointmentId: appointment_id, roomId: self.roomID)
                self.uploadedImage.removeAll()
                for i in 0..<savedImages.count{
                    self.uploadedImage.append(AttachmentDataValue(savedImageUrl: savedImages[i], savedImageName: name, id: i))
                }
                if isRoomImage{
                    let uploadedImage = self.uploadedImage.filter({$0.url?.contains("Attachment") ?? false})
                    self.imageNames = uploadedImage.map({$0.url ?? ""})
                    self.tableView.reloadRows(at: [[0,1]], with: .automatic)
                }else{
                    let uploadedImage = self.uploadedImage.filter({$0.url?.contains("Protrusion") ?? false})
                    self.protrusionImageNames = uploadedImage.map({$0.url ?? ""})
                    self.tableView.reloadRows(at: [[0,2]], with: .automatic)
                }
                imagecount += 1
            }
            
        }
        else
        {
            dismiss(animated: true, completion: nil)
            self.alert("Something Went Wrong, Image Uploading Faild", nil)
        }
    }
    
    
    func imageUpload(_ image:UIImage,_ name:String )
    {
        HttpClientManager.SharedHM.AttachmentsMapFn(image, name) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                if (value ?? []).count != 0
                {
                    self.uploadedImage.append(value![0])
                    self.tableView.reloadRows(at: [[0,1]], with: .automatic)
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
                    
                    self.imageUpload(self.originalUploadImage,self.name)
                    
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func removeImage(at position:Int)
    {
        let data:[String:Any] = ["attachment_ids":[uploadedImage[position].id ?? 0]]
        let parameter:[String:Any] = ["token":(user.token ?? ""),"data":data]
        HttpClientManager.SharedHM.DeleteImageApi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                let ok =   UIAlertAction(title: "OK", style: .cancel) { (_) in
                    self.uploadedImage.remove(at: position)
                    self.tableView.reloadData()
                }
                //  self.alert("Selected image has been removed", [ok])
                
                self.alert("Please add at least 2 photos of each room", [ok])
                
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
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    
    func submitAPICall()
    {
        var imageids:[Int] = []
        for attach in uploadedImage
        {
            imageids.append(attach.id ?? 0)
        }
        if(imageids.count < 2)
        {
            self.alert("Please select two images to proceed", nil)
            return
        }
        let data:[String:Any] = ["comments":value,"contract_measurement_id":drowingImageID,"appointment_id":appoinmentID,"image_ids":imageids]
        let parameter:[String:Any] = ["token":(user.token ?? ""),"data":data]
        HttpClientManager.SharedHM.RoomDetailsUpdateApi(parameter: parameter) { (result, message,value) in
            if (result ?? "").lowercased() == "true" ||  (result ?? "").lowercased() == "success"
            {
                if self.delegate == nil
                {
                    
                    if(value != nil)
                    {
                        if(value![0].questionaire?.count ?? 0 > 0)
                        {
                            self.summaryData = value![0]
                        }
                        
                    }
                    //                    let next = TransactionViewController.initialization()!
                    //                               next.appoinmentID =  self.appoinmentID
                    //                               next.roomID =  self.roomID
                    //                               next.roomName = self.roomName
                    //                               next.drowingImageID = self.drowingImageID
                    //                               next.area = self.area
                    //                           self.navigationController?.pushViewController(next, animated: true)
                    
                    let next = FurnitureQustionsViewController.initialization()!
                    next.appoinmentID = self.appoinmentID
                    next.roomName = self.roomName
                    next.roomID = self.roomID
                    next.drowingImageID = self.drowingImageID
                    if(self.isStair == 1)
                    {
                        next.isStair = self.isStair
                    }
                    if(self.summaryData != nil)
                    {
                        
                        next.isUpdated = false
                        next.floorID = self.summaryData.floor_id ?? 0
                        next.summaryQustions = self.summaryData.questionaire ?? []
                        
                    }
                    self.navigationController?.pushViewController(next, animated: true)
                    
                }
                else
                {
                    self.delegate?.SummeryEditDelegateInTransitionEditingDone()
                    self.performSegueToReturnBack()
                }
            }
            else
            {
                let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                    
                    self.submitAPICall()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                
                // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }

    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePickerUpload = CaptureImage(presentationController: self, delegate: self)
            self.imagePickerUpload.present(from: sender)
            
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
extension AboutRoomViewController: ImagePickerDelegate {

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
