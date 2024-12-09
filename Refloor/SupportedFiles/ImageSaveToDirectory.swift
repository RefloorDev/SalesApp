//
//  ImageSaveToDirectory.swift
//  Refloor
//
//  Created by Satheesh on 29/11/21.
//  Copyright © 2021 oneteamus. All rights reserved.
//

import Foundation
import UIKit

class ImageSaveToDirectory: NSObject
{
    
    static let SharedImage = ImageSaveToDirectory()
    
   
    func CreateFolderInDocumentDirectory()
    {
        let fileManager = FileManager.default
        let PathWithFolderName = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Refloor_Offline_Asset")
        
        print("Document Directory Folder Path :- ",PathWithFolderName)
        
        if !fileManager.fileExists(atPath: PathWithFolderName)
        {
            try! fileManager.createDirectory(atPath: PathWithFolderName, withIntermediateDirectories: true, attributes: nil)
        }
        else
        {
            print("Already dictionary created.")
        }
    }

    func getDirectoryPath() -> NSURL
    {
        // path is main document directory path
        
        let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        let pathWithFolderName = documentDirectoryPath.appendingPathComponent("Refloor_Offline_Asset")
        let url = NSURL(string: pathWithFolderName) // convert path in url
        
        return url!
    }

     func saveImageDocumentDirectory(rfImage:UIImage, saveImgName:String) -> String
    {
        let fileManager = FileManager.default
        let url = (getDirectoryPath() as NSURL)
        
        let imagePath = url.appendingPathComponent(saveImgName) // Here Image Saved With This Name ."MyImage.png"
        let urlString: String = imagePath!.absoluteString
        
        let ImgForSave = rfImage // here i Want To Saved This Image In Document Directory
        let imageData = UIImage.jpegData(ImgForSave)
     //   let imageData = attachments.jpegData(compressionQuality: 0.4)
        
        fileManager.createFile(atPath: urlString as String, contents: imageData(0.4), attributes: nil)
        return saveImgName
    }

    public func getImageFromDocumentDirectory(rfImage:String)->UIImage?
    {
        
        let fileManager = FileManager.default
        
        let imagePath = (getDirectoryPath() as NSURL).appendingPathComponent(rfImage) // here assigned img name who assigned to img when saved in document directory. Here I Assigned Image Name "MyImage.png"
        
        let urlString: String = imagePath!.absoluteString
        
        if fileManager.fileExists(atPath: urlString)
        {
            if let GetImageFromDirectory = UIImage(contentsOfFile: urlString){ // get this image from Document Directory And Use This Image In Show In Imageview
            
            //imgViewOutlet.image = GetImageFromDirectory
            return GetImageFromDirectory
            }
            return nil
        }
        else
        {
            print("No Image Found")
            return nil
        }
    }
    
    public func getImageFromDocumentDirectoryURL(rfImage:String)->String?
    {
        
        let fileManager = FileManager.default
        
        let imagePath = (getDirectoryPath() as NSURL).appendingPathComponent(rfImage) // here assigned img name who assigned to img when saved in document directory. Here I Assigned Image Name "MyImage.png"
        
        let urlString: String = imagePath!.absoluteString
        return urlString
        
//        if fileManager.fileExists(atPath: urlString)
//        {
//            if let GetImageFromDirectory = UIImage(contentsOfFile: urlString){ // get this image from Document Directory And Use This Image In Show In Imageview
//
//            //imgViewOutlet.image = GetImageFromDirectory
//            return GetImageFromDirectory
//            }
//            return nil
//        }
//        else
//        {
//            print("No Image Found")
//            return nil
//        }
    }

    public func deleteImageFromDocumentDirectory(rfImage:String)->Bool
    {
        let fileManager = FileManager.default
        
        let imagePath = (getDirectoryPath() as NSURL).appendingPathComponent(rfImage) // here assigned img name who assigned to img when saved in document directory. Here I Assigned Image Name "MyImage.png"

        let urlString: String = imagePath!.absoluteString
        
        
        if fileManager.fileExists(atPath: urlString)
        {
            try! fileManager.removeItem(atPath: urlString)
            return true
        }
        else
        {
            print("No Image Found")
            return false
        }
    }
}
