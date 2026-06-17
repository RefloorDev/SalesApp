import Foundation

let fileManager = FileManager.default
let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
let pathWithFolderName = documentDirectoryPath.appendingPathComponent("Refloor_Offline_Asset")
if !fileManager.fileExists(atPath: pathWithFolderName) {
    try? fileManager.createDirectory(atPath: pathWithFolderName, withIntermediateDirectories: true, attributes: nil)
}

let fileName = "Attachment_2026_06_15_11:32:00.JPG"
let filePath = (pathWithFolderName as NSString).appendingPathComponent(fileName)

let data = "test".data(using: .utf8)!
let success = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
print("Create file with colon success: \(success)")
if fileManager.fileExists(atPath: filePath) {
    print("File EXISTS")
} else {
    print("File does NOT exist")
}
