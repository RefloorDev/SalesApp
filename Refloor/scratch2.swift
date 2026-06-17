import Foundation
import CoreGraphics
import ImageIO

let maxDim: CGFloat = 200.0
let dict = [
    kCGImageSourceThumbnailMaxPixelSize: maxDim
] as CFDictionary

print(dict)
