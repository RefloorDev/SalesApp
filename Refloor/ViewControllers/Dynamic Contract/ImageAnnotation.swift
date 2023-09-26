//
//  ImageAnnotation.swift
//  Refloor
//
//  Created by Anju on 01.09.2023.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import Foundation
import PDFKit

class ImageStampAnnotation: PDFAnnotation {
var image: UIImage!
// A custom init that sets the type to Stamp on default and assigns our Image variable
init(with image: UIImage!, forBounds bounds: CGRect, withProperties properties: [AnyHashable : Any]?) {
  super.init(bounds: bounds, forType: PDFAnnotationSubtype.stamp,  withProperties: properties)
  self.image = image
}
required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
}

override func draw(with box: PDFDisplayBox, in context: CGContext)   {
  // Get the CGImage of our image
  guard let cgImage = self.image?.cgImage else { return }
  // Draw our CGImage in the context of our PDFAnnotation bounds
  context.draw(cgImage, in: self.bounds)
}
}
