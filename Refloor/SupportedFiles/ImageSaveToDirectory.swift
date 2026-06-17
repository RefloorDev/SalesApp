//
//  ImageSaveToDirectory.swift
//  Refloor
//
//  Created by Satheesh on 29/11/21.
//  Copyright © 2021 oneteamus. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

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
        let url = NSURL(fileURLWithPath: pathWithFolderName) // convert path in url
        
        return url
    }

    func saveImageDocumentDirectory(rfImage:UIImage, saveImgName:String) -> String
    {
        CreateFolderInDocumentDirectory()
        let fileManager = FileManager.default
        let url = (getDirectoryPath() as NSURL)
        
        let imagePath = url.appendingPathComponent(saveImgName) // Here Image Saved With This Name ."MyImage.png"
        let urlString: String = imagePath!.path
        
        if let imageData = rfImage.jpegData(compressionQuality: 0.4) {
            fileManager.createFile(atPath: urlString, contents: imageData, attributes: nil)
        }
        
        return saveImgName
    }

    public func getImageFromDocumentDirectory(rfImage:String)->UIImage?
    {
        
        let fileManager = FileManager.default
        
        let imagePath = (getDirectoryPath() as NSURL).appendingPathComponent(rfImage) // here assigned img name who assigned to img when saved in document directory. Here I Assigned Image Name "MyImage.png"
        
        let urlString: String = imagePath!.path
        
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
    
    public func getDownsampledImageFromDocumentDirectory(rfImage: String, maxSize: CGFloat = 300.0) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = (getDirectoryPath() as NSURL).appendingPathComponent(rfImage)
        guard let urlString = imagePath?.path else { return nil }
        
        if fileManager.fileExists(atPath: urlString) {
            let url = URL(fileURLWithPath: urlString)
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            if let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions) {
                let downsampleOptions = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceShouldCacheImmediately: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxSize as NSNumber
                ] as CFDictionary
                
                if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) {
                    return UIImage(cgImage: downsampledImage)
                }
            }
        }
        return nil
    }
    
    public func getImageFromDocumentDirectoryURL(rfImage:String)->String?
    {
        
        let fileManager = FileManager.default
        
        let imagePath = (getDirectoryPath() as NSURL).appendingPathComponent(rfImage) // here assigned img name who assigned to img when saved in document directory. Here I Assigned Image Name "MyImage.png"
        
        let urlString: String = imagePath!.path
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

        let urlString: String = imagePath!.path
        
        
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
