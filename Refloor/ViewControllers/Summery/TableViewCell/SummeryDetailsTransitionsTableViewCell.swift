//
//  SummeryDetailsTransitionsTableViewCell.swift
//  Refloor
//
//  Created by sbek on 26/05/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SummeryDetailsTransitionsTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var nopitcturesAvailable: UILabel!
    @IBOutlet weak var transitionsLabel: UILabel!
    
    @IBOutlet weak var pitcherCollectionView: UICollectionView!
    
    var collection_tag:Int = 0
    var delegate:ExternalCollectionViewDelegateForTableView?
    //var attachment:[AttachmentDataValue] = []
    var attachment:[UIImage] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nopitcturesAvailable.isHidden = false
        // Initialization code
    }
    //func collectionViewReload(_ attachment:[AttachmentDataValue])
    func collectionViewReload(_ attachment:[UIImage])
    {
        self.pitcherCollectionView.delegate = self
        self.pitcherCollectionView.dataSource = self
        self.attachment = attachment
        if(attachment.count != 0)
        {
            self.nopitcturesAvailable.isHidden = true
        }
        else
        {
            self.nopitcturesAvailable.isHidden = false
        }
        self.pitcherCollectionView.reloadData()
    }
    
//    func collectionViewReload1(_ attachment:[AttachmentDataValue])
//    {
//        self.pitcherCollectionView.delegate = self
//        self.pitcherCollectionView.dataSource = self
//        self.attachment = attachment
//        if(attachment.count != 0)
//        {
//            self.nopitcturesAvailable.isHidden = true
//        }
//        else
//        {
//            self.nopitcturesAvailable.isHidden = false
//        }
//        self.pitcherCollectionView.reloadData()
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return attachment.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 88, height: 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransitionPhotoCollectionViewCell", for: indexPath) as! TransitionPhotoCollectionViewCell
        //cell.transitionImageView.loadImageFormWeb(URL(string: attachment[indexPath.row].url ?? ""))
        DispatchQueue.main.async {
            cell.transitionImageView.image = self.attachment[indexPath.row] //ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: self.attachment[indexPath.row].url ?? "")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.externalCollectionViewDidSelectbutton(index: indexPath.row, tag: self.collection_tag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
class TransitionPhotoCollectionViewCell:UICollectionViewCell
{
    @IBOutlet weak var transitionImageView: UIImageView!
}
