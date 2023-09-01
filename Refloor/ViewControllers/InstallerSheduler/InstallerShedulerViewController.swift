//
//  InstallerShedulerViewController.swift
//  Refloor
//
//  Created by Bincy C A on 22/08/23.
//  Copyright © 2023 oneteamus. All rights reserved.
//

import UIKit

class InstallerShedulerViewController: UIViewController {
    
    static func initialization() -> InstallerShedulerViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "InstallerShedulerViewController") as? InstallerShedulerViewController
    }

    @IBOutlet weak var installerRightBtn: UIButton!
    @IBOutlet weak var installerLeftBtn: UIButton!
    @IBOutlet weak var installerCollectionView: UICollectionView!
    var selectedIndex = 0
    override func viewDidLoad()
    {
        super.viewDidLoad()
        installerLeftBtn.layer.cornerRadius = installerLeftBtn.frame.height / 2
        installerRightBtn.layer.cornerRadius = installerRightBtn.frame.height / 2
        installerLeftBtn.borderWidth = 0
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.shedulerInstallerNavBar(with: "SCHEDULE INSTALLATION")
        
    }
    
    @IBAction func installerLeftBtnAction(_ sender: UIButton)
    {
        selectedIndex -= 1
        installerCollectionView.reloadData()
    }
    @IBAction func installerRightBtnAction(_ sender: UIButton)
    {
        selectedIndex += 1
        installerCollectionView.reloadData()
    }
    
    override func insallerSkipBtnAction(sender: UIButton)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func insallerSubmitBtnAction(sender: UIButton)
    {
        let details = InstallerSuccessViewController.initialization()!
        self.navigationController?.pushViewController(details, animated: true)
    }
    
}

extension InstallerShedulerViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InstallerSchedulerCollectionViewCell", for: indexPath) as! InstallerSchedulerCollectionViewCell
        
            if indexPath.row == selectedIndex
            {
                cell.borderColor = UIColor().colorFromHexString("#D29B3C")
                cell.borderWidth = 2
                cell.backgroundColor = UIColor().colorFromHexString("#292562")
                cell.tickImgView.isHidden = false
            }
            else
            {
                cell.borderColor = UIColor().colorFromHexString("#586471")
                cell.borderWidth = 1
                cell.backgroundColor = UIColor().colorFromHexString("#2D343D")
                cell.tickImgView.isHidden = true
            }
        
       
        return cell

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedIndex = indexPath.row
        self.installerCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let yourWidth = ((collectionView.bounds.width) - 17) / 5
        return CGSize(width: yourWidth, height: 225.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }


}
