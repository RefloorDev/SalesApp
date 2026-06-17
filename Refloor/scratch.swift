import Foundation
let path = "/var/mobile/Containers/Data/Application/Documents"
let url = NSURL(string: path)
print("URL string:", url?.absoluteString ?? "nil")
let url2 = URL(fileURLWithPath: url?.absoluteString ?? "")
print("Final:", url2.absoluteString)
