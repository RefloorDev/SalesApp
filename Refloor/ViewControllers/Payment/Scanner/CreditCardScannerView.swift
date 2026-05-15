

// CreditCardScannerView.swift
// Refloor

import ScanbotSDK
import SwiftUI

struct CreditCardScannerView: UIViewControllerRepresentable {

    var completion: (CardData) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = CreditCardHostViewController()
        vc.coordinator = context.coordinator
        let nav = RotatableNavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject,
        SBSDKCreditCardScannerViewControllerDelegate
    {

        let completion: (CardData) -> Void
        private var hasDelivered = false

        // ✅ Holds the best result so far (number + expiry confirmed)
        private var bestData: CardData?
        // ✅ How many more scans to attempt after number+expiry found but name missing
        private var nameRetryCount = 0
        private let maxNameRetries = 3  //

        init(completion: @escaping (CardData) -> Void) {
            self.completion = completion
        }

        func creditCardScannerViewController(
            _ controller: SBSDKCreditCardScannerViewController,
            didFailScanning error: any Error
        ) {
            guard !hasDelivered else { return }
            hasDelivered = true
            DispatchQueue.main.async {
                controller.dismiss(animated: true) {
                    self.completion(CardData())
                }
            }
        }

        func creditCardScannerViewController(
            _ controller: SBSDKCreditCardScannerViewController,
            didScanCreditCard result: SBSDKCreditCardScanningResult
        ) {
            guard result.creditCard != nil, !hasDelivered else { return }

            let data = parseResult(result)

            // Step 1: number or expiry still missing → keep scanning, don't count retries
            guard !data.number.isEmpty, !data.expiry.isEmpty else {
                print("⚠️ Missing number/expiry — retrying...")
                return
            }

            // Step 2: number + expiry confirmed. Update bestData (prefer scan that also has name)
            if bestData == nil
                || (!data.name.isEmpty && bestData?.name.isEmpty == true)
            {
                bestData = data
            }

            // Step 3: name already captured → deliver immediately
            if !data.name.isEmpty {
                deliver(controller: controller, data: data)
                return
            }

            // Step 4: name still missing → retry up to maxNameRetries
            nameRetryCount += 1
            print("⚠️ Name missing — retry \(nameRetryCount)/\(maxNameRetries)")

            if nameRetryCount >= maxNameRetries {
                // Deliver best result we have (without name)
                print("ℹ️ Max name retries reached — delivering without name")
                deliver(controller: controller, data: bestData ?? data)
            }
            // else: return without delivering, scanner keeps running automatically
        }

        func creditCardScannerViewControllerDidCancel(
            _ controller: SBSDKCreditCardScannerViewController
        ) {
            guard !hasDelivered else { return }
            hasDelivered = true
            DispatchQueue.main.async {
                // Deliver best captured data if any, else empty
                controller.dismiss(animated: true) {
                    self.completion(self.bestData ?? CardData())
                }
            }
        }

        // MARK: - Private

        private func deliver(
            controller: SBSDKCreditCardScannerViewController,
            data: CardData
        ) {
            guard !hasDelivered else { return }
            hasDelivered = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                controller.dismiss(animated: true) { self.completion(data) }
            }
        }

        private func parseResult(_ result: SBSDKCreditCardScanningResult)
            -> CardData
        {
            guard let card = result.creditCard,
                let model = card.wrap()
                    as? SBSDKCreditCardDocumentModelCreditCard
            else { return CardData() }

            let number = (model.cardNumber?.value?.text ?? "")
                .replacingOccurrences(of: " ", with: "")
            let name = model.cardholderName?.value?.text ?? ""
            let expiry = model.expiryDate?.value?.text ?? ""

            print(
                "📷 Scan — number: '\(number)'  name: '\(name)'  expiry: '\(expiry)'"
            )
            return CardData(number: number, name: name, expiry: expiry)
        }
    }
}

// MARK: - CreditCardHostViewController

final class CreditCardHostViewController: UIViewController {

    weak var coordinator: CreditCardScannerView.Coordinator?
    private var scannerVC: SBSDKCreditCardScannerViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }
    override var shouldAutorotate: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // ✅ Mirror demo: use default configuration, no custom flags
        scannerVC = SBSDKCreditCardScannerViewController(
            parentViewController: self,
            parentView: view,
            configuration: SBSDKCreditCardScannerConfiguration(),
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
            btn.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            btn.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            btn.widthAnchor.constraint(equalToConstant: 40),
            btn.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    @objc private func closeTapped() {
        if let scannerVC {
            coordinator?.creditCardScannerViewControllerDidCancel(scannerVC)
        } else {
            dismiss(animated: true)
        }
    }
}


