//
//  SignViewController.swift
//  Refloor
//
//  Created by sbek on 14/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
protocol SignSignatureDelegate {
    func SignSignatureDidGetImage(with image:UIImage)
}

class SignViewController: UIViewController {
    static public func initialization() -> SignViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SignViewController") as? SignViewController
    }
    @IBOutlet weak var signatureLabel: UILabel!
    @IBOutlet weak var signatureNote: UILabel!
    @IBOutlet weak var signatureView: Canvas!
    var delegate:SignSignatureDelegate?
    var signatureName = "Applicant Signature6"
    var signatureNotetxt = "Applicant Signature3434343"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // signatureView.backgroundColor=UIColor.clear
        signatureView.borderColor=UIColor.clear
        
        self.signatureLabel.text = signatureName
        
        self.signatureNote.text = signatureNotetxt
        //  sign.signatureNote.te
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setDashedBorder()
    }
    
    func setDashedBorder(){
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.black.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = signatureView.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: signatureView.bounds).cgPath
        signatureView.layer.addSublayer(yourViewBorder)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.performSegueToReturnBack()
    }
    
    @IBAction func clearButtonAction(_ sender: Any) {
        signatureView.clear()
    }
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        if signatureView.isSigned
        {
            delegate?.SignSignatureDidGetImage(with: signatureView.getSignature())
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            self.alert("Please draw the signature and tap on 'confirm' button", nil)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

