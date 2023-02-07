//
//  ViewController.swift
//  PayCardsRecognizerExample
//
//  Created by Vitaliy Kuzmenko on 12/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit
import PayCardsRecognizer

protocol PayCardsRecognizerDelegate {
    func PayCardsRecognizerDidRecive(the result:PayCardsRecognizerResult)
}
final class RecognizerViewController: UIViewController {
    
    static func initialization() -> RecognizerViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "RecognizerViewController") as? RecognizerViewController
    }
    private var recognizer: PayCardsRecognizer!
    var delegate:PayCardsRecognizerDelegate?
    @IBOutlet weak var recognizerContainer: UIView!
    
    lazy var activityView: UIBarButtonItem = {
        let activityView = UIActivityIndicatorView(style: .gray)
        activityView.startAnimating()
        let item = UIBarButtonItem(customView: activityView)
        return item
    }()
    
    // MARK: - VC Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbackAndlogo(with: "")
        recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: recognizerContainer, frameColor: .green)
        
        
        recognizer.setOrientation(.landscapeRight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCapturing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopCapturing()
        navigationItem.rightBarButtonItem = nil
    }
    
    
    
}

// MARK: - Camera capturing
extension RecognizerViewController {
    private func startCapturing() {
        recognizer.startCamera()
    }
    
    private func stopCapturing() {
        recognizer.stopCamera()
    }
}

// MARK: - PayCardsRecognizerPlatformDelegate
extension RecognizerViewController: PayCardsRecognizerPlatformDelegate {
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
        #if DEBUG
        print(result)
        print(result.dictionary as NSDictionary)
        #endif
        
        if result.isCompleted {
            self.performSegueToReturnBack()
            self.delegate?.PayCardsRecognizerDidRecive(the: result)
        } else {
            navigationItem.rightBarButtonItem = activityView
        }
    }
}


