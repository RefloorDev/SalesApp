
// ChequeScannerView.swift

import ScanbotSDK
import SwiftUI

struct ChequeScannerView: UIViewControllerRepresentable {

    var completion: (ChequeData) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = ChequeHostViewController()
        vc.coordinator = context.coordinator
        let nav = RotatableNavigationController(rootViewController: vc) // ← use rotatable nav
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject, SBSDKCheckScannerViewControllerDelegate {

        let completion: (ChequeData) -> Void
        private var hasDelivered = false

        init(completion: @escaping (ChequeData) -> Void) {
            self.completion = completion
        }

        func checkScannerViewController(
            _ controller: SBSDKCheckScannerViewController,
            didScanCheck result: SBSDKCheckScanningResult,
            isHighRes: Bool
        ) {
            guard result.status == .success, !hasDelivered else { return }
            hasDelivered = true

            print(result.toJson())
            let data = parseResult(result)

            DispatchQueue.main.async {
                controller.dismiss(animated: true) {
                    self.completion(data)
                }
            }
        }

        func checkScannerViewController(
            _ controller: SBSDKCheckScannerViewController,
            didFailScanning error: any Error
        ) {
            guard !hasDelivered else { return }
            hasDelivered = true
            DispatchQueue.main.async {
                controller.dismiss(animated: true) {
                    self.completion(ChequeData())
                }
            }
        }

        func checkScannerViewController(
            _ controller: SBSDKCheckScannerViewController,
            didChangeState state: SBSDKCheckScannerState
        ) {}

        private func parseResult(_ result: SBSDKCheckScanningResult) -> ChequeData {
            guard let jsonString = result.toJson().data(using: .utf8) else {
                return ChequeData()
            }
            do {
                let json = try JSONSerialization.jsonObject(with: jsonString) as? [String: Any]
                let document = json?["check"] as? [String: Any]
                let fields = document?["fields"] as? [[String: Any]] ?? []

                var routing = ""
                var account = ""
                var checkNumber = ""
                var auxOnUs = ""
                var serial = ""

                for field in fields {
                    let type  = (field["type"]  as? [String: Any])?["name"] as? String ?? ""
                    let value = (field["value"] as? [String: Any])?["text"] as? String ?? ""
                    let name  = type.lowercased()

                    if routing.isEmpty && !value.isEmpty &&
                       (name.contains("routing") || name.contains("transit") || name.contains("sort")) {
                        routing = value
                    } else if account.isEmpty && !value.isEmpty && name.contains("account") {
                        account = value
                    } else if name.contains("check") && !value.isEmpty {
                        checkNumber = value
                    } else if name.contains("auxiliary") && !value.isEmpty {
                        auxOnUs = value
                    } else if name.contains("serial") && !value.isEmpty {
                        serial = value
                    }
                }

                if checkNumber.isEmpty {
                    checkNumber = !auxOnUs.isEmpty ? auxOnUs : serial
                }

                return ChequeData(routing: routing, account: account, checkNumber: checkNumber)
            } catch {
                print("JSON parsing failed:", error)
                return ChequeData()
            }
        }
    }
}

// MARK: - Rotatable UINavigationController
// Allows the nav controller (and all its children) to rotate freely.
// This is the key fix — UINavigationController by default blocks rotation
// unless you subclass it and forward the queries to the top child.

final class RotatableNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }

    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? true
    }
}

// MARK: - ChequeHostViewController

final class ChequeHostViewController: UIViewController {

    weak var coordinator: ChequeScannerView.Coordinator?
    private var scannerVC: SBSDKCheckScannerViewController?

    // ✅ FIX: tell UIKit this VC supports all orientations
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let config = SBSDKCheckScannerConfiguration(
            documentDetectionMode: .detectAndCropDocument,
            acceptedCheckStandards: [.usa, .fra, .kwt, .aus, .ind, .isr, .uae, .can]
        )

        scannerVC = SBSDKCheckScannerViewController(
            parentViewController: self,
            parentView: view,
            configuration: config,
            delegate: coordinator
        )

        setupCloseButton()
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func closeTapped() {
        guard let scannerVC = scannerVC, let coordinator = coordinator else {
            dismiss(animated: true)
            return
        }
        DispatchQueue.main.async {
            scannerVC.dismiss(animated: true) {
                coordinator.completion(ChequeData())
            }
        }
    }
}
