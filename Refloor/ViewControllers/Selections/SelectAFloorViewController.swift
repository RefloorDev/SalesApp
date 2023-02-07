//
//  SelectAFloorViewController.swift
//  Refloor
//
//  Created by sbek on 08/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SelectAFloorViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    static func initialization() -> SelectAFloorViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SelectAFloorViewController") as? SelectAFloorViewController
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    var roomData:[RoomDataValue] = []
    var isFromNoListAvailable = false
    var floorLevelData:[FloorLevelDataValue] = []
    var appoinmentslData:AppoinmentDataValue!
    //var names = ["BASEMENT","1st FLOOR","2nd FLOOR","3rd FLOOR","4th FLOOR","OTHER"]
    var selectedno = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbaclogoAndStatus(with: "Floor Selection")
        if(isFromNoListAvailable)
        {
            if let firstViewController = self.navigationController?.viewControllers[0]
            {
                
                self.navigationController?.viewControllers = [firstViewController,self]
                
            }
        }
        //nextButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return floorLevelData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FloorDetailsCollectionViewCell", for: indexPath) as! FloorDetailsCollectionViewCell
        if selectedno == indexPath.row
        {
            cell.bGView.layer.borderColor = UIColor(displayP3Red: 201/255, green: 63/255, blue: 72/255, alpha: 1).cgColor//#rgba(201, 63, 72, 1)
            cell.bGView.layer.borderWidth = 5
        }
        else
        {
            cell.bGView.layer.borderColor = UIColor(displayP3Red: 45/255, green: 52/255, blue: 61/255, alpha: 1).cgColor//#rgba(45, 52, 61, 1)
            cell.bGView.layer.borderWidth = 0
        }
        let floorName = floorLevelData[indexPath.row].name ?? "Other"
        var name = ""
        if let subname = floorLevelData[indexPath.row].prefix
        {
            if let attach = floorLevelData[indexPath.row].superscript_symbol
            {
                name = subname + attach + " " + floorName
            }
            else
            {
                name = subname + " " + floorName
            }
        }
        else
        {
            name = floorName
        }
        cell.nameLabel.text = name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/3, height: 180)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedno == -1
        {
            nextButton.isHidden = false
            selectedno = indexPath.row
            self.collectionView.reloadItems(at: [[0,selectedno]])
        }
        else
        {
            if(selectedno != indexPath.row)
            {
                let temp = selectedno
                selectedno = indexPath.row
                self.collectionView.reloadItems(at: [[0,temp],[0,selectedno]])
            }
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        //        let room = SelectARoomViewController.initialization()!
        //        room.floorLevelData = self.floorLevelData[selectedno]
        //        room.roomData = self.roomData
        //        room.appoinmentslData = self.appoinmentslData
        //        self.navigationController?.pushViewController(room, animated: true)
        
        
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
