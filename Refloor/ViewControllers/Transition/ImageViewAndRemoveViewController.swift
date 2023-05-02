//
//  ImageViewAndRemoveViewController.swift
//  Refloor
//
//  Created by sbek on 28/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import SDWebImage
protocol ImageViewAndRemoveDelegate {
    func imageRemoveDelegate(at position:Int)
}
class ImageViewAndRemoveViewController: UIViewController {
    static func initialization() -> ImageViewAndRemoveViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewAndRemoveViewController") as? ImageViewAndRemoveViewController
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var isNoRemved = false
    var delegate:ImageViewAndRemoveDelegate?
    var attachments:[AttachmentDataValue] = []
    var position = 0
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var toolViewHightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let value:Float = 5.678434
        let roundedValue = roundf(value * 100) / 100
        print(roundedValue) //5.68
        self.removeButton.isHidden = isNoRemved
        if(isNoRemved)
        {
            if self.attachments.count == 1
            {
                self.toolView.isHidden = true
                self.toolViewHightConstraint.constant = 0
            }
        }
        loadImage()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    func loadImage()
    {   //arb
       // self.imageView.loadImageFormWeb(URL(string: attachments[position].url ?? ""))
        self.imageView.image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: attachments[position].url ?? "")
    }
    @IBAction func previousButtonAction(_ sender: UIButton) {
        
        if(position != 0)
        { position -= 1
            loadImage()
        }
    }
    @IBAction func nextButtonAction(_ sender: UIButton) {
        
        if(position != (attachments.count - 1))
        {
            position += 1
            loadImage()
        }
    }
    @IBAction func removeImage(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.imageRemoveDelegate(at: self.position)
        }
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.performSegueToReturnBack()
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
