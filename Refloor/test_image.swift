import Foundation

let path = "/Users/bincycaliyar/Desktop/Project/Refloor Kavya 3.3.7/SalesApp 2/Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift"
let content = try! String(contentsOfFile: path)

if content.contains("UIGraphicsImageRenderer") {
    print("Has UIGraphicsImageRenderer")
} else {
    print("Does NOT have UIGraphicsImageRenderer")
}
