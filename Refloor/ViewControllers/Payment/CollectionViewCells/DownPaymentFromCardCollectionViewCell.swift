//
//  DownPaymentFromCardCollectionViewCell.swift
//  Refloor
//
//  Created by sbek on 04/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class DownPaymentFromCardCollectionViewCell: UICollectionViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate {
    
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var accountHolderNameTF: UITextField!
    @IBOutlet weak var cardNumberTF: UITextField!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardExperyDateTF: UITextField!
    @IBOutlet weak var cardPinLabel: UILabel!
    @IBOutlet weak var cardPinTF: UITextField!
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var persentage:[String] = []
    var selectedTag = 0
    var selectedItem = 0
    var isPasswordVisble = true
    var delegate:ExternalCollectionViewDelegateForTableView?
    @IBOutlet weak var cardScanButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "SubCollectionViewLabelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SubCollectionViewLabelCollectionViewCell")
        cardNumberTF.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        cardPinTF.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        
    }
    func collectionViewConfigruation(collectionViewData:[String],delegate:ExternalCollectionViewDelegateForTableView?)
    {
        self.accountHolderNameTF.text = ""
        self.cardNumberTF.text = ""
        self.cardExperyDateTF.text = ""
        self.cardPinTF.text = ""
        self.selectedItem = 0
        self.persentage = collectionViewData
        self.delegate = delegate
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        self.cardNumberTF.delegate = self
        self.collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    @IBAction func passwordVisbleBatton(_ sender: UIButton) {
        isPasswordVisble = !isPasswordVisble
        self.cardNumberTF.isSecureTextEntry = !isPasswordVisble
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if cardNumberTF == textField {
            textField.isSecureTextEntry = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if cardNumberTF == textField {
            textField.isSecureTextEntry = false
        }
    }
    
    //satheesh
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
        return true
    }
    
    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.count > 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }
    
    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }
    
    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        // Mapping of card prefix to pattern is taken from
        // https://baymard.com/checkout-usability/credit-card-patterns
        
        // UATP cards have 4-5-6 (XXXX-XXXXX-XXXXXX) format
        let is456 = string.hasPrefix("1")
        
        // These prefixes reliably indicate either a 4-6-5 or 4-6-4 card. We treat all these
        // as 4-6-5-4 to err on the side of always letting the user type more digits.
        let is465 = [
            // Amex
            "34", "37",
            
            // Diners Club
            "300", "301", "302", "303", "304", "305", "309", "36", "38", "39"
        ].contains { string.hasPrefix($0) }
        
        // In all other cases, assume 4-4-4-4-3.
        // This won't always be correct; for instance, Maestro has 4-4-5 cards according
        // to https://baymard.com/checkout-usability/credit-card-patterns, but I don't
        // know what prefixes identify particular formats.
        let is4444 = !(is456 || is465)
        
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)
            
            if needs465Spacing || needs456Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")
                
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            
            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
    
}
