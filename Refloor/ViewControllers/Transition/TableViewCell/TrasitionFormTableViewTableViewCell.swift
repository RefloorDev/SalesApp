//
//  TrasitionFormTableViewTableViewCell.swift
//  Refloor
//
//  Created by sbek on 27/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import SDWebImage
class TrasitionFormTableViewTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var pluseButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var uploadCollectionView: UICollectionView!
    @IBOutlet weak var transactionNameLabel: UILabel!
    @IBOutlet weak var aboutTransactionLabel: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var widthTextField: UITextField!
    var collectionViewDelegate:ExternalCollectionViewDelegate?
    var images:[String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func collectionviewReload()
    {
        uploadCollectionView.delegate = self
        uploadCollectionView.dataSource = self
        uploadCollectionView.reloadData()
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
        return (images.count < 5) ? (images.count + 1) : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionView", for: indexPath) as!
            ImageViewCollectionView
        if(images.count == indexPath.row)
        {
            cell.upload_image_View.image = UIImage(named: "addImage")
            cell.upload_image_View.contentMode = .scaleAspectFit
        }
        else
        {
            cell.upload_image_View.loadImageFormWeb(URL(string: images[indexPath.row]))
            cell.upload_image_View.contentMode = .scaleToFill
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionViewDelegate?.externalCollectionViewDidSelectbutton(index: indexPath.row)
    }
    
}
class ImageViewCollectionView:UICollectionViewCell
{
    
    @IBOutlet weak var upload_image_View: UIImageView!
}
class TrasitionSavedTableViewTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var uploadCollectionView: UICollectionView!
    @IBOutlet weak var transactionNameLabel: UILabel!
    @IBOutlet weak var aboutTransactionLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    var select_tag = 0
    var images:[String] = []
    var delegate:ExternalCollectionViewDelegateForTableView?
    @IBOutlet weak var widthTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionviewReload()
    {
        uploadCollectionView.delegate = self
        uploadCollectionView.dataSource = self
        uploadCollectionView.reloadData()
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
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCollectionView", for: indexPath) as!
            ImageViewCollectionView
        if(images.count == indexPath.row)
        {
            cell.upload_image_View.image = UIImage(named: "addImage")
            cell.upload_image_View.contentMode = .scaleAspectFit
        }
        else
        {
            cell.upload_image_View.loadImageFormWeb(URL(string: images[indexPath.row]))
            cell.upload_image_View.contentMode = .scaleToFill
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.externalCollectionViewDidSelectbutton(index: indexPath.item, tag: select_tag)
    }
}
class TrasitionHeadingTableViewTableViewCell: UITableViewCell{
    @IBOutlet weak var aereaLabel: UILabel!
    @IBOutlet weak var transactionDetailsLabl: UILabel!
    @IBOutlet weak var nextButton: UIButton!
}
