//
//  DownPaymentFromACHCollectionViewCell.swift
//  Refloor
//

import UIKit

class DownPaymentFromACHCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bankAccountNumberTF: UITextField!
    @IBOutlet weak var bankRoutingNumberTF: UITextField!
    @IBOutlet weak var acctTypeLabel: UILabel!
    @IBOutlet weak var acctTypeButton: UIButton!
    @IBOutlet weak var payButton: UIButton!

    @IBOutlet weak var oCRCameraBtn: UIButton!
    var persentage: [String] = []
    var selectedTag = 0
    var selectedItem = 0
    var delegate: ExternalCollectionViewDelegateForTableView?
    var routingNumber:String = String()
    var accountNumber:String = String()

    let infoButton = UIButton(type: .custom)

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "SubCollectionViewLabelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SubCollectionViewLabelCollectionViewCell")
        
        infoButton.setImage(UIImage(named: "iButton"), for: .normal)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(infoButton)
        NSLayoutConstraint.activate([
            infoButton.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            infoButton.leadingAnchor.constraint(equalTo: totalLabel.trailingAnchor, constant: 10),
            infoButton.widthAnchor.constraint(equalToConstant: 24),
            infoButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    @objc func infoButtonTapped() {
        if let parentVC = self.delegate as? UIViewController {
            let popupVC = InfoImagesPopupViewController()
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.modalTransitionStyle = .crossDissolve
            
            if let img = UIImage(named: "check_info") {
                popupVC.images = [img]
            }
            
            parentVC.present(popupVC, animated: true, completion: nil)
        }
    }

    func collectionViewConfigruation(collectionViewData: [String], delegate: ExternalCollectionViewDelegateForTableView?) {
        self.bankAccountNumberTF.text = accountNumber.isEmpty ? nil : accountNumber
        self.bankRoutingNumberTF.text = routingNumber.isEmpty ? nil : routingNumber
        
            
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
        return CGSize(width: collectionView.bounds.width / 3, height: 39)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persentage.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCollectionViewLabelCollectionViewCell", for: indexPath) as! SubCollectionViewLabelCollectionViewCell
        cell.label.text = persentage[indexPath.row]
        if selectedItem == indexPath.item {
            cell.bgView.backgroundColor = UIColor(displayP3Red: 201/255, green: 63/255, blue: 72/255, alpha: 1)
        } else {
            cell.bgView.backgroundColor = UIColor(displayP3Red: 88/255, green: 100/255, blue: 113/255, alpha: 1)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = indexPath.item
        collectionView.reloadData()
        delegate?.externalCollectionViewDidSelectbutton(index: indexPath.item, tag: selectedTag)
    }
}
