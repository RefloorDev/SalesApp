//
//  RotatableHostingController.swift
//  Refloor
//
//  Created by Looperex on 05/05/26.
//  Copyright © 2026 oneteamus. All rights reserved.
//

import SwiftUI
 
final class RotatableHostingController<Content: View>: UIHostingController<Content> {
 
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape          // matches the iPad plist (left + right)
    }
 
    override var shouldAutorotate: Bool {
        return true
    }
}
