//
//  QRCodeScannerViewController.swift
//  Refloor
//
//  Created by macbook on 1/30/26.
//  Copyright © 2026 oneteamus. All rights reserved.
//

import UIKit
//import SDWebImage

class QRCodeScannerViewController: UIViewController {
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    static func initialization() -> QRCodeScannerViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeScannerViewController") as? QRCodeScannerViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarbackAndlogo3(with: "SCAN QR CODE")
//        let qrcodeReferralUrl = UserDefaults.standard.value(forKey: "QRCodeReferralURL") as? String ?? ""
//        
//        qrCodeImageView.sd_setImage(with: URL(string: qrcodeReferralUrl))
        
//        if let savedLogoImage = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage:"QRCode")
//        {
//            //            image.image = image.image?.withRenderingMode(.alwaysTemplate)
//            //image.tintColor = UIColor().colorFromHexString("#2D343D")
//            qrCodeImageView.image = savedLogoImage
//            qrCodeImageView.contentMode = .scaleAspectFit
//        }
        
        
        if let imageData = UserDefaults.standard.data(forKey: "SavedQRCodeImage"),
           let qrImage = UIImage(data: imageData) {
            qrCodeImageView.image = qrImage
            titleLbl.text = "READY TO REFER?"
            titleLbl.textColor = .white//UIColor().colorFromHexString("#A7B0BA")
            descriptionLbl.text = "Scan this code to link your recommendation directly to our sales team.\n Quick, easy, and tracks your referral status in real-time."
            qrCodeImageView.contentMode = .scaleAspectFit
        }
        else
        {
            qrCodeImageView.image = UIImage(named: "QRCodeDefault")
            titleLbl.text = "QR CODE NOT FOUND!"
            titleLbl.textColor = UIColor().colorFromHexString("#A7B0BA")
            descriptionLbl.text = "Something went wrong. Please try again."
            qrCodeImageView.contentMode = .scaleAspectFit
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    

    

}
