//
//  AboutRoomDetailsTableViewCell.swift
//  Refloor
//
//  Created by sbek on 06/08/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class AboutRoomDetailsTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var uploadStaticTextLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryUploadButton: UIButton!
    
    @IBOutlet weak var noImageLbl: UILabel!
    @IBOutlet weak var noImageBtn: UIButton!
    var collectionViewDelegate:ExternalCollectionViewDelegate2?
    var images:[String] = []
    var protrusionImages:[String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func collectionviewReload()
    {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var value = collectionView.bounds.width/5
        if(collectionView.bounds.height < value)
        {
            value = collectionView.bounds.height
        }
        return CGSize(width: value, height: value)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 1 ? images.count : protrusionImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionView", for: indexPath) as!
            ImageViewCollectionView
        if collectionView.tag == 1{
            if(images.count == indexPath.row)
            {
                cell.upload_image_View.image = UIImage(named: "addImage")
                cell.upload_image_View.contentMode = .scaleAspectFit
            }
            else
            {
                //arb
                //cell.upload_image_View.loadImageFormWeb(URL(string: images[indexPath.row]))
                if let image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: images[indexPath.row]){
                    cell.upload_image_View.image = image
                    cell.upload_image_View.contentMode = .scaleToFill
                }
                
            }
            return cell
        }else{
            if(protrusionImages.count == indexPath.row)
            {
                cell.upload_image_View.image = UIImage(named: "addImage")
                cell.upload_image_View.contentMode = .scaleAspectFit
            }
            else
            {
                //arb
                //cell.upload_image_View.loadImageFormWeb(URL(string: images[indexPath.row]))
                if let image = ImageSaveToDirectory.SharedImage.getImageFromDocumentDirectory(rfImage: protrusionImages[indexPath.row]){
                    cell.upload_image_View.image = image
                    cell.upload_image_View.contentMode = .scaleToFill
                }
                
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionViewDelegate?.externalCollectionViewDidSelectbutton2(index: indexPath.row,tag: collectionView.tag)
    }
}
