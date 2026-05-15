


// RotatableHostingController.swift
// Refloor

import SwiftUI

/// UIHostingController subclass that allows landscape rotation.
/// Required because the default UIHostingController blocks rotation regardless
/// of what the inner VCs declare.
/// iPad plist only has landscape-left + landscape-right → use .landscape.
final class RotatableHostingController<Content: View>: UIHostingController<Content> {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return false
    }
}

