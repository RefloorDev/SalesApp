import Foundation
#if canImport(UIKit)
import UIKit

class DummyView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
    }
    required init?(coder: NSCoder) { fatalError() }
}

let view = DummyView(frame: CGRect(x: 0, y: 0, width: 1500, height: 1500))
let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
let drawingImage = renderer.image { rendererContext in
    view.layer.render(in: rendererContext.cgContext)
}

if let _ = drawingImage.jpegData(compressionQuality: 0.4) {
    print("jpegData SUCCESS")
} else {
    print("jpegData FAILED")
}
#else
print("UIKit not available on macOS command line, skipping")
#endif
