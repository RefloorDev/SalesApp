//
//  DownPaymentFromCheckCollectionViewCell.swift
//  Refloor
//
//  Created by sbek on 19/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class DownPaymentFromCheckCollectionViewCell: UICollectionViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var persentage:[String] = []
    var selectedTag = 0
    @IBOutlet weak var accountNumberTF: UITextField!
    var selectedItem = 0
    var delegate:ExternalCollectionViewDelegateForTableView?
    @IBOutlet weak var checkNumberTF: UITextField!
    @IBOutlet weak var routingNumberTF: UITextField!
    @IBOutlet weak var payButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "SubCollectionViewLabelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SubCollectionViewLabelCollectionViewCell")
    }
    func collectionViewConfigruation(collectionViewData:[String],delegate:ExternalCollectionViewDelegateForTableView?)
    {
        self.accountNumberTF.text = ""
        self.checkNumberTF.text = ""
        self.routingNumberTF.text = ""
        self.selectedItem = 0
        self.persentage = collectionViewData
        self.delegate = delegate
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/3, height: 39)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persentage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCollectionViewLabelCollectionViewCell", for: indexPath) as! SubCollectionViewLabelCollectionViewCell
        cell.label.text = persentage[indexPath.row]
        if(selectedItem == indexPath.item)
        {
            cell.bgView.backgroundColor = UIColor(displayP3Red: 201/255, green:  63/255, blue:  72/255, alpha: 1)
        }
        else
        {
            cell.bgView.backgroundColor = UIColor(displayP3Red: 88/255, green:  100/255, blue:  113/255, alpha: 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = indexPath.item
        collectionView.reloadData()
        delegate?.externalCollectionViewDidSelectbutton(index: indexPath.item, tag: selectedTag)
    }
}
