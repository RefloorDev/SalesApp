//
//  ImagePicker.swift
//  Pickers
//
//  Created by Tibor Bödecs on 2019. 08. 28..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import UIKit
import Photos
public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?, imageName:String?)
}

open class CaptureImage: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    var name:String = ""
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
    
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Camera") {
            
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Photo Library") {
            alertController.addAction(action)
        }
//        if let action = self.action(for: .photoLibrary, title: "Photo library") {
//            alertController.addAction(action)
//        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?,imageName: String?) {
        controller.dismiss(animated: true, completion: nil)
        
        
        
        self.delegate?.didSelect(image: image,imageName:name)
    }
}

extension CaptureImage: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil,imageName: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      //  guard let image = info[.editedImage] as? UIImage else {
     //       return self.pickerController(picker, didSelect: nil)
    //    }
    //    self.pickerController(picker, didSelect: image)
      //  let image = info[.originalImage] as? UIImage
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            print("imageDone")
            
            let imageName = Date().toString()
            name = "Attachment" + String(imageName) + ".JPG"
            
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
            {
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
                
                self.pickerController(picker, didSelect: image,imageName: name)
            }
            else if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
            {
                let assetResources = PHAssetResource.assetResources(for: asset)
                
                let asset = assetResources.first
                if(asset != nil)
                {
                    let value = asset!.value(forKey: "filename") as? String
                    if(value != nil && value != "")
                    {
                        name  = value!
                    }
                }
                self.pickerController(picker, didSelect: image,imageName: name)
            }
            else
            {
                self.pickerController(picker, didSelect: image,imageName: name)
            }
            
        }
 
        
        
       
    }
}

extension CaptureImage: UINavigationControllerDelegate {
    
}
