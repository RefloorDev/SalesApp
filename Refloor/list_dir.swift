import Foundation

let fileManager = FileManager.default
let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
let pathWithFolderName = documentDirectoryPath.appendingPathComponent("Refloor_Offline_Asset")

if fileManager.fileExists(atPath: pathWithFolderName) {
    if let files = try? fileManager.contentsOfDirectory(atPath: pathWithFolderName) {
        print("Folder contains \(files.count) files")
        for file in files {
            if file.contains("Attachment") {
                let fullPath = (pathWithFolderName as NSString).appendingPathComponent(file)
                let attr = try? fileManager.attributesOfItem(atPath: fullPath)
                let size = attr?[.size] as? Int64 ?? 0
                print("\(file) - \(size) bytes")
            }
        }
    }
} else {
    print("Folder does not exist at: \(pathWithFolderName)")
}
