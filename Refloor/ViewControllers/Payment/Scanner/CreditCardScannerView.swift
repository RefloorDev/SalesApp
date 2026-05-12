
// CreditCardScannerView.swift

import SwiftUI
import ScanbotSDK

struct CreditCardScannerView: UIViewControllerRepresentable {

    var completion: (CardData) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = CreditCardHostViewController()
        vc.coordinator = context.coordinator
        let nav = RotatableNavigationController(rootViewController: vc) // ← use rotatable nav
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject, SBSDKCreditCardScannerViewControllerDelegate {

        let completion: (CardData) -> Void
        private var hasDelivered = false

        init(completion: @escaping (CardData) -> Void) {
            self.completion = completion
        }

        func creditCardScannerViewController(
            _ controller: SBSDKCreditCardScannerViewController,
            didFailScanning error: any Error
        ) {}

        func creditCardScannerViewController(
            _ controller: SBSDKCreditCardScannerViewController,
            didScanCreditCard result: SBSDKCreditCardScanningResult
        ) {
            guard result.scanningStatus == .success, !hasDelivered else { return }
            hasDelivered = true

            let data = parseResult(result)
            DispatchQueue.main.async {
                controller.dismiss(animated: true) {
                    self.completion(data)
                }
            }
        }

        func creditCardScannerViewControllerDidCancel(
            _ controller: SBSDKCreditCardScannerViewController
        ) {
            guard !hasDelivered else { return }
            hasDelivered = true
            DispatchQueue.main.async {
                controller.dismiss(animated: true) {
                    self.completion(CardData())
                }
            }
        }

        private func parseResult(_ result: SBSDKCreditCardScanningResult) -> CardData {
            print("\n========== CREDIT CARD SCAN RESULT ==========")

            guard let card = result.creditCard else {
                print("❌ result.creditCard is nil")
                return CardData()
            }

            guard let model = card.wrap() as? SBSDKCreditCardDocumentModelCreditCard else {
                print("❌ wrap() did not return SBSDKCreditCardDocumentModelCreditCard")
                return CardData()
            }

            let number = model.cardNumber?.value?.text     ?? ""
            let name   = model.cardholderName?.value?.text ?? ""
            let expiry = model.expiryDate?.value?.text     ?? ""

            print("  number: '\(number)'  name: '\(name)'  expiry: '\(expiry)'")
            print("==============================================\n")

            return CardData(number: number, name: name, expiry: expiry)
        }
    }
}

// MARK: - CreditCardHostViewController

final class CreditCardHostViewController: UIViewController {

    weak var coordinator: CreditCardScannerView.Coordinator?
    private var scannerVC: SBSDKCreditCardScannerViewController?

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

        let config = SBSDKCreditCardScannerConfiguration()
        config.returnCreditCardImage = false

        scannerVC = SBSDKCreditCardScannerViewController(
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
        if let scannerVC = scannerVC {
            coordinator?.creditCardScannerViewControllerDidCancel(scannerVC)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - RotatableNavigationController
// UINavigationController blocks rotation by default unless subclassed.
// This forwards the rotation queries to whatever VC is on top.
// NOTE: RotatableNavigationController is defined once (in ChequeScannerView.swift).
//       If you get a "redeclaration" error, remove the duplicate here.

// If ChequeScannerView.swift is in the same module, RotatableNavigationController
// is already available — no need to re-declare it.

private extension SBSDKCreditCardScanningStatus {
    var name: String {
        switch self {
        case .success:           return "SUCCESS"
        case .incomplete:        return "INCOMPLETE"
        case .errorNothingFound: return "NOTHING_FOUND"
        @unknown default:        return "UNKNOWN(\(rawValue))"
        }
    }
}
