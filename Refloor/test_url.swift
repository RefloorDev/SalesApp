import Foundation

let rfImage = "Attachment_2026_06_15_11:32:00.JPG"
let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
let pathWithFolderName = documentDirectoryPath.appendingPathComponent("Refloor_Offline_Asset")
let url = NSURL(fileURLWithPath: pathWithFolderName)
let imagePath = url.appendingPathComponent(rfImage)
print("imagePath: \(String(describing: imagePath))")
print("urlString: \(imagePath!.path)")
