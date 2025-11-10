//
//  CameraScannerViewController.swift
//  WeScan (fixed for landscape-only apps)
//

import UIKit
import AVFoundation

/// Delegate for camera output
public protocol CameraScannerViewOutputDelegate: AnyObject {
    func captureImageFailWithError(error: Error)
    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?)
}

public final class CameraScannerViewController: UIViewController {

    // MARK: - Public API
    public var isAutoScanEnabled: Bool = CaptureSession.current.isAutoScanEnabled {
        didSet { CaptureSession.current.isAutoScanEnabled = isAutoScanEnabled }
    }
    public weak var delegate: CameraScannerViewOutputDelegate?

    // MARK: - Private
    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer() // single instance - add once
    private var focusRectangle: FocusRectangleView!
    private let quadView = QuadrilateralView()
    private var flashEnabled = false

    // MARK: - Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureCaptureSessionManager()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        // Start via manager (manager will use the preview layer we passed)
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Force landscape orientation for preview (landscape-only app)
        forceLandscapePreview()

        // Make sure preview fills the view
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        videoPreviewLayer.frame = view.layer.bounds
        CATransaction.commit()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        captureSessionManager?.stop()
        if let device = AVCaptureDevice.default(for: .video), device.torchMode == .on {
            toggleFlash()
        }
    }

    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .darkGray

        // Configure preview layer once and add as sublayer
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)

        // Quad view overlay
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        view.addSubview(quadView)
        setupConstraints()

        // Instantiate the manager passing the preview layer (manager controls the session)
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer)
        captureSessionManager?.delegate = self

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                               object: nil)
    }

    private func setupConstraints() {
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
            quadView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]
        NSLayoutConstraint.activate(quadViewConstraints)
    }

    /// Ensure CaptureSessionManager is ready. We don't create another AVCaptureSession here.
    private func configureCaptureSessionManager() {
        // Force orientation on preview layer BEFORE starting session to avoid initial tilt
        forceLandscapePreview()
        // The CaptureSessionManager will start the session when you call start()
    }

    // MARK: - Orientation Helpers
    private func forceLandscapePreview() {
        guard let connection = videoPreviewLayer.connection else {
            // If there is no connection yet, still try to set orientation on the layer's connection once available.
            // We also set the video orientation on the manager's session connections when manager starts.
            return
        }
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .landscapeRight // change to .landscapeLeft if UI expects that
        }
        videoPreviewLayer.frame = view.layer.bounds
    }

    // MARK: - Focus / Touch
    @objc private func subjectAreaDidChange() {
        do {
            try CaptureSession.current.resetFocusToAuto()
        } catch {
            let error = ImageScannerControllerError.inputDevice
            captureSessionManager?.delegate?.captureSessionManager(captureSessionManager!, didFailWithError: error)
            return
        }
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: true)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: view)
        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)

        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)
        focusRectangle = FocusRectangleView(touchPoint: touchPoint)
        focusRectangle.setBorder(color: UIColor.white.cgColor)
        view.addSubview(focusRectangle)

        do {
            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
        } catch {
            let error = ImageScannerControllerError.inputDevice
            captureSessionManager?.delegate?.captureSessionManager(captureSessionManager!, didFailWithError: error)
            return
        }
    }

    // MARK: - Actions
    public func capture() { captureSessionManager?.capturePhoto() }

    public func toggleFlash() {
        let state = CaptureSession.current.toggleFlash()
        switch state {
        case .on: flashEnabled = true
        case .off: flashEnabled = false
        case .unknown, .unavailable: flashEnabled = false
        }
    }

    public func toggleAutoScan() { isAutoScanEnabled.toggle() }
}

// MARK: - RectangleDetectionDelegateProtocol
extension CameraScannerViewController: RectangleDetectionDelegateProtocol {
    

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        delegate?.captureImageFailWithError(error: error)
    }

    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        captureSessionManager.stop()
    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager,
                               didCapturePicture picture: UIImage,
                               withQuad quad: Quadrilateral?) {
        delegate?.captureImageSuccess(image: picture, withQuad: quad)
    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager,
                               didDetectQuad quad: Quadrilateral?,
                               _ imageSize: CGSize) {
        guard let quad = quad else {
            quadView.removeQuadrilateral()
            return
        }

        // Scale + rotate quad for landscape-only app.
        // If overlay is mirrored/wrong, flip the rotation sign (.pi/2 -> -.pi/2)
        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize,
                                                              aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)

        let rotationAngle: CGFloat = .pi / 2 // try -.pi/2 if it appears mirrored
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        let imageBounds = CGRect(origin: .zero, size: scaledImageSize)//.applying(rotationTransform)
        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds,
                                                                        toCenterOfRect: quadView.bounds)
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        let transformedQuad = quad.applyTransforms(transforms)
        quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
    }
}
