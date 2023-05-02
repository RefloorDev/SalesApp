//
//  TransactionViewController.swift
//  Refloor
//
//  Created by sbek on 27/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import MobileCoreServices
import PhotosUI

class TransactionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ExternalCollectionViewDelegate,ExternalCollectionViewDelegateForTableView,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImageViewAndRemoveDelegate,UITextViewDelegate {
    
    
    
    
    static func initialization() -> TransactionViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewController
    }
    
    
    var user = UserData.init()
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var tableView: UITableView!
    var removeObjcets:[TransitionDataValue] = []
    var uploadedImage:[AttachmentDataValue] = []
    var isAddNew = true
    var widthNo:Float = 0
    var drowingImageID = 0
    var roomName = ""
    var roomID = 0
    var floorID = 0
    var appoinmentID = 0
    var area:CGFloat = 0
    var about = ""
    var delegate:SummeryEditDelegate?
    var placeHolder = "About Transition"
    var popOver:UIPopoverController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(delegate == nil)
        {
            self.setNavigationBarbaclogoAndStatus(with: "Transition details - \(self.roomName)")
        }
        else
        {
            self.setNavigationBarbackAndlogo(with: "Transition details - \(self.roomName)")
        }
        imagePicker.delegate = self
        
        transitionListApi()
        // Do any additional setup after loading the view.
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(placeHolder == (textView.text ?? ""))
        {
            textView.text = ""
            textView.textColor = .white
            about = textView.text ?? ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        about = textView.text ?? ""
        if(about).removeUnvantedcharactoes() == ""
        {
            textView.text = placeHolder
            textView.textColor = UIColor.placeHolderColor
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        about = textView.text ?? ""
        return true
    }
    
    
    @IBAction func EditChangedTextFiled(_ sender: UITextField) {
        if let num = Float(sender.text ?? "")
        {
            widthNo = num
        }
        else
        {
            sender.text = "\(widthNo)"
            self.alert("Please Enter a valid value", nil)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if(delegate == nil)
        {
            
            
            let next = FurnitureQustionsViewController.initialization()!
            next.appoinmentID = self.appoinmentID
            next.roomName = self.roomName
            next.roomID = self.roomID
            next.drowingImageID = self.drowingImageID
            self.navigationController?.pushViewController(next, animated: true)
        }
        else
        {
            self.delegate?.SummeryEditDelegateInTransitionEditingDone()
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBAction func editDidBeginTexField(_ sender: UITextField) {
        if let num = Float(sender.text ?? "")
        {
            widthNo = num
        }
        else
        {
            sender.text = "\(widthNo)"
            self.alert("Please Enter a valid value", nil)
        }
    }
    
    
    @IBAction func addButtonAction(_ sender: Any) {
        isAddNew = true
        self.widthNo = 0
        self.about = ""
        self.uploadedImage = []
        
        tableView.reloadData()
        
    }
    
    
    
    @IBAction func mikeButtonAction(_ sender: Any) {
    }
    
    @IBAction func minusButtonAction(_ sender: Any) {
        
        if let cell = tableView.cellForRow(at: [0,1]) as? TrasitionFormTableViewTableViewCell
        {
            let value  = widthNo - 1
            if(value >= 0)
            {
                widthNo = value
                cell.widthTextField.text = "\(widthNo)"
            }
        }
        
    }
    @IBAction func pluseButtonAction(_ sender: Any) {
        if let cell = tableView.cellForRow(at: [0,1]) as? TrasitionFormTableViewTableViewCell
        {
            let value  = widthNo + 1
            if(value >= 0)
            {
                widthNo = value
                cell.widthTextField.text = "\(widthNo)"
            }
        }
    }
    @IBAction func saveButtonAction(_ sender: Any) {
        if let cell = tableView.cellForRow(at: [0,1]) as? TrasitionFormTableViewTableViewCell
        {
            if !((cell.aboutTransactionLabel.text ?? "") == "" || (cell.aboutTransactionLabel.text ?? "") == placeHolder)
            {
                var imageids:[Int] = []
                for attach in uploadedImage
                {
                    imageids.append(attach.id ?? 0)
                }
                let data:[String:Any] = ["name":(cell.aboutTransactionLabel.text ?? ""),"room_id":roomID,"floor_id":floorID,"appointment_id":appoinmentID,"transition_width":widthNo,"image_ids":imageids,"room_measurement_id":drowingImageID]
                
                let parameter:[String:Any] = ["token":(user.token ?? ""),"data":data]
                self.addTransacationApi(parameter)
            }
        }
        else
        {
            self.alert("Please enter about transition for continue", nil)
        }
        
        
    }
    @IBAction func removeButtonAction(_ sender: UIButton) {
        removeTransaction(at: sender.tag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  removeObjcets.count + 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (indexPath.row - 2)
        if(indexPath.row == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrasitionHeadingTableViewTableViewCell") as! TrasitionHeadingTableViewTableViewCell
            cell.aereaLabel.text = "\(self.roomName) > Total Area: \(area.toString) Sq.Ft"
            //            if(delegate == nil)
            //            {
            //                cell.nextButton.setTitle("Next", for: .normal)
            //            }
            //            else
            //            {
            //                cell.nextButton.setTitle("Done", for: .normal)
            //            }
            // cell.transactionDetailsLabl.text = "Transition details - \((self.roomData.name ?? "Unknown"))"
            return cell
        }
        else if(indexPath.row == 1 )
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrasitionFormTableViewTableViewCell") as! TrasitionFormTableViewTableViewCell
            cell.transactionNameLabel.text = "Transition \(removeObjcets.count + 1)"
            cell.aboutTransactionLabel.textColor = (about.removeUnvantedcharactoes() == "") ? UIColor.placeHolderColor :UIColor.white
            cell.aboutTransactionLabel.text = (about.removeUnvantedcharactoes() == "") ? placeHolder : about
            cell.widthTextField.text = "\(widthNo)"
            cell.widthTextField.keyboardType = .decimalPad
            cell.collectionViewDelegate = self
            var imagenames:[String] = []
            for attach in uploadedImage
            {
                imagenames.append(attach.url ?? "")
            }
            cell.images = imagenames
            cell.collectionviewReload()
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrasitionSavedTableViewTableViewCell") as! TrasitionSavedTableViewTableViewCell
            cell.uploadCollectionView.delegate = cell
            cell.uploadCollectionView.dataSource = cell
            cell.removeButton.tag = index
            cell.delegate = self
            cell.select_tag = index
            cell.transactionNameLabel.text = "Transition \(removeObjcets.count - index )"
            cell.aboutTransactionLabel.text = removeObjcets[index].name ?? ""
            cell.widthTextField.text = "\(removeObjcets[index].transition_width ?? 0)"
            cell.widthTextField.isUserInteractionEnabled = false
            var imagenames:[String] = []
            for attach in removeObjcets[index].attachment ?? []
            {
                imagenames.append(attach.url ?? "")
            }
            cell.images = imagenames
            if(imagenames.count == 0)
            {
                cell.noImageLabel.isHidden = false
            }
            else
            {
                cell.noImageLabel.isHidden = true
            }
            cell.collectionviewReload()
            return cell
        }
    }
    
    func externalCollectionViewDidSelectbutton(index: Int) {
        if uploadedImage.count == index
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
            imagePresent.attachments = self.uploadedImage
            self.present(imagePresent, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    func imageRemoveDelegate(at position: Int) {
        removeImage(at: position)
    }
    
    
    
    func openCameraToPickImage(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes =  [kUTTypeImage as String]//UIImagePickerController.availableMediaTypes(for: .camera)!
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.popOver = UIPopoverController(contentViewController: imagePicker)
            self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY - 150, width: 300, height: 300), in: self.view, permittedArrowDirections: .any, animated: true)
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
            self.popOver?.present(from: CGRect(x: self.view.frame.midX + 150, y: self.view.frame.midY - 150, width: 300, height: 300), in: self.view, permittedArrowDirections: .any, animated: true)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var name = "Attachment " + String(uploadedImage.count + 1)
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            print("imageDone")
            
            
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                let asset = result.firstObject
                if(asset != nil)
                {
                    let value = asset!.value(forKey: "filename") as? String
                    if(value != nil && value != "")
                    {
                        name  = value!
                    }
                }
                dismiss(animated: true, completion: nil)
                self.imageUpload(originalImage ,name)
                imagecount += 1
                
            }
            else
            {
                dismiss(animated: true, completion: nil)
                self.imageUpload(originalImage ,name)
                imagecount += 1
            }
            
        }
        else
        {
            dismiss(animated: true, completion: nil)
            self.alert("Something Went Wrong, Image Uploading Failed", nil)
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
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func addTransacationApi(_ parameter:[String:Any])
    {
        HttpClientManager.SharedHM.AddTransitionApi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {  let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.isAddNew = false
                self.transitionListApi()
            }
            
            self.alert("Transition is saved",[ok])
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
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    func transitionListApi()
    {
        let parameter:[String:Any] = ["token":(user.token ?? ""),"appointment_id":appoinmentID,"floor_id":floorID,"room_id":roomID,"room_measurement_id":drowingImageID]
        HttpClientManager.SharedHM.TransitionListsApi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {
                self.removeObjcets = value ?? []
                
                self.widthNo = 0
                self.uploadedImage = []
                self.about = ""
                
                self.tableView.reloadData()
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
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
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
                self.alert("Image is removed", [ok])
                
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
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    func removeTransaction(at position:Int)
    {
        let data:[String:Any] = ["transition_ids":[removeObjcets[position].id ?? 0]]
        let parameter:[String:Any] = ["token":(user.token ?? ""),"data":data]
        HttpClientManager.SharedHM.DeleteTransactionApi(parameter: parameter) { (success, message, value) in
            if(success ?? "") == "Success"
            {  let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
                self.isAddNew = false
                self.transitionListApi()
            }
            
            self.alert("Transition is removed",[ok])
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
                self.alert(message ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    
    func externalCollectionViewDidSelectbutton(index: Int, tag: Int) {
        if let attach = removeObjcets[tag].attachment
        {
            let imagePresent = ImageViewAndRemoveViewController.initialization()!
            
            imagePresent.position = index
            imagePresent.attachments = attach
            imagePresent.isNoRemved = true
            self.present(imagePresent, animated: true, completion: nil)
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
