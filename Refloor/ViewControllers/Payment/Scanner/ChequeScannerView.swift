


// ChequeScannerView.swift
// Refloor

import ScanbotSDK
import SwiftUI

struct ChequeScannerView: UIViewControllerRepresentable {

    var completion: (ChequeData) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = ChequeHostViewController()
        vc.coordinator = context.coordinator
        let nav = RotatableNavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject, SBSDKCheckScannerViewControllerDelegate {

        let completion: (ChequeData) -> Void
        private var hasDelivered = false

        // ✅ Best result so far + retry counter for checkNumber
        private var bestData: ChequeData?
        private var checkNumberRetryCount = 0
        private let maxCheckNumberRetries = 5

        init(completion: @escaping (ChequeData) -> Void) { self.completion = completion }

        func checkScannerViewController(
            _ controller: SBSDKCheckScannerViewController,
            didScanCheck result: SBSDKCheckScanningResult,
            isHighRes: Bool
        ) {
            // ✅ Mirror demo: check status == .success
            guard result.status == .success, !hasDelivered else { return }

            let data = parseResult(result)

            // Step 1: routing or account missing → keep scanning
            guard !data.routing.isEmpty, !data.account.isEmpty else {
                print("⚠️ Missing routing/account — retrying...")
                return
            }

            // Step 2: update bestData (prefer result that also has checkNumber)
            if bestData == nil || (!data.checkNumber.isEmpty && bestData?.checkNumber.isEmpty == true) {
                bestData = data
            }

            // Step 3: checkNumber captured → deliver immediately
            if !data.checkNumber.isEmpty {
                deliver(controller: controller, data: data)
                return
            }

            // Step 4: checkNumber missing → retry up to maxCheckNumberRetries
            checkNumberRetryCount += 1
            print("⚠️ CheckNumber missing — retry \(checkNumberRetryCount)/\(maxCheckNumberRetries)")

            if checkNumberRetryCount >= maxCheckNumberRetries {
                print("ℹ️ Max retries reached — delivering without checkNumber")
                deliver(controller: controller, data: bestData ?? data)
            }
        }

        func checkScannerViewController(
            _ controller: SBSDKCheckScannerViewController,
            didFailScanning error: any Error
        ) {
            guard !hasDelivered else { return }
            hasDelivered = true
            DispatchQueue.main.async {
                controller.dismiss(animated: true) { self.completion(ChequeData()) }
            }
        }

        func checkScannerViewController(
            _ controller: SBSDKCheckScannerViewController,
            didChangeState state: SBSDKCheckScannerState
        ) {}

        // MARK: - Private

        private func deliver(controller: SBSDKCheckScannerViewController, data: ChequeData) {
            guard !hasDelivered else { return }
            hasDelivered = true
            print("✅ Cheque delivered — routing: '\(data.routing)'  account: '\(data.account)'  checkNumber: '\(data.checkNumber)'")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                controller.dismiss(animated: true) { self.completion(data) }
            }
        }

        private func parseResult(_ result: SBSDKCheckScanningResult) -> ChequeData {
            guard let jsonData = result.toJson().data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            else { return ChequeData() }

            let fields = (json["check"] as? [String: Any])?["fields"] as? [[String: Any]] ?? []

            var routing = "", account = "", checkNumber = "", auxOnUs = "", serial = ""

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

            if checkNumber.isEmpty { checkNumber = auxOnUs.isEmpty ? serial : auxOnUs }
            return ChequeData(routing: routing, account: account, checkNumber: checkNumber)
        }
    }
}

// MARK: - RotatableNavigationController

final class RotatableNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        topViewController?.supportedInterfaceOrientations ?? .landscape
    }
    override var shouldAutorotate: Bool { false }
}

// MARK: - ChequeHostViewController

final class ChequeHostViewController: UIViewController {

    weak var coordinator: ChequeScannerView.Coordinator?
    private var scannerVC: SBSDKCheckScannerViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var shouldAutorotate: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // ✅ Mirror demo: use default configuration
        scannerVC = SBSDKCheckScannerViewController(
            parentViewController: self,
            parentView: view,
            configuration: SBSDKCheckScannerConfiguration(),
            delegate: coordinator
        )

        setupCloseButton()
    }

    private func setupCloseButton() {
        let btn = UIButton(type: .system)
        btn.setTitle("✕", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            btn.widthAnchor.constraint(equalToConstant: 40),
            btn.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func closeTapped() {
        guard let scannerVC, let coordinator else { dismiss(animated: true); return }
        DispatchQueue.main.async {
            scannerVC.dismiss(animated: true) { coordinator.completion(ChequeData()) }
        }
    }
}


