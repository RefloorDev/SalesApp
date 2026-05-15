//
//  CameraPermissionManager.swift
//  Refloor
//
//  Created by Looperex on 13/05/26.
//  Copyright © 2026 oneteamus. All rights reserved.
//

import UIKit
import AVFoundation
import ObjectiveC



final class CameraPermissionManager {

    static let shared = CameraPermissionManager()

    private var isAlertShowing = false

    private init() {}

    func checkCameraPermission(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)

            switch status {

            case .authorized:
                completion()

            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self, weak viewController] granted in
                    DispatchQueue.main.async {
                        guard let self = self,
                              let viewController = viewController else {
                            return
                        }

                        if granted {
                            completion()
                        } else {
                            self.showCameraPermissionAlert(from: viewController)
                        }
                    }
                }

            case .denied:
                self.showCameraPermissionAlert(from: viewController)

            case .restricted:
                self.showCameraPermissionAlert(
                    from: viewController,
                    title: "Camera Access Restricted",
                    message: "Camera access is restricted on this device. Please check Screen Time, device restrictions, or contact your administrator."
                )

            @unknown default:
                self.showCameraPermissionAlert(from: viewController)
            }
        }
    }

    private func showCameraPermissionAlert(
        from viewController: UIViewController,
        title: String = "Camera Permission Required",
        message: String = "Camera access is disabled. Please enable camera permission in Settings to continue."
    ) {
        DispatchQueue.main.async {
            guard !self.isAlertShowing else { return }

            guard viewController.view.window != nil else {
                return
            }

            if viewController.presentedViewController != nil {
                return
            }

            self.isAlertShowing = true

            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.isAlertShowing = false
            })

            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                self.isAlertShowing = false
                self.openAppSettings()
            })

            viewController.present(alert, animated: true) {
                // Alert presented successfully
            }
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        guard UIApplication.shared.canOpenURL(settingsURL) else {
            return
        }

        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}

