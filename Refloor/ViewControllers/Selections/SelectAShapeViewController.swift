//
//  SelectAShapeViewController.swift
//  Refloor
//
//  Created by sbek on 09/04/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit

class SelectAShapeViewController : UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    static func initialization() -> SelectAShapeViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "SelectAShapeViewController") as? SelectAShapeViewController
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    var roomData:RoomDataValue!
    var floorShapeData:[FloorShapeDataValue] = []
    var floorLevelData:FloorLevelDataValue!
    var appoinmentslData:AppoinmentDataValue!
    var names = ["RECTANGLE","L - SHAPE","Z - SHAPE","R - SHAPE","T - SHAPE","CUSTOM SHAPE"]
    var images = [UIImage(named: "rectangle_shape"),UIImage(named: "l_shape"),UIImage(named: "z_shape"),UIImage(named: "r_shape"),UIImage(named: "t_shape"),UIImage(named: "custom_shape")]
    var selectedno = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarbaclogoAndStatus(with: "Floor shape Selection")
        //nextButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return floorShapeData.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShapeDetailCollectionViewCell", for: indexPath) as! ShapeDetailCollectionViewCell
        
        
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
        if(indexPath.row == floorShapeData.count)
        {
            cell.iconImageView.image = images[5]
            cell.nameLabel.text = names[5]
            return cell
        }
        let name = floorShapeData[indexPath.row].name ?? ""
        
        if name.lowercased().contains("rectangle")
        {
            cell.iconImageView.image = images[0]
            cell.nameLabel.text = name
        }
        else if name.lowercased().contains("shape")
        {
            if name.lowercased().contains("t")
            {
                cell.iconImageView.image = images[4]
                cell.nameLabel.text = name
            }
            else if name.lowercased().contains("z")
            {
                cell.iconImageView.image = images[2]
                cell.nameLabel.text = name
            }
            else if name.lowercased().contains("r")
            {
                cell.iconImageView.image = images[3]
                cell.nameLabel.text = name
            }
            else
            {
                cell.iconImageView.image = images[1]
                cell.nameLabel.text = name
            }
        }
        else
        {
            cell.iconImageView.image = images[5]
            cell.nameLabel.text = name
        }
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
    @IBAction func nextButtonAction(_ sender: UIButton) {
        if( self.floorShapeData.count != self.selectedno)
        {
            if( self.floorShapeData[self.selectedno].id ?? 0) == ShapeID.l_shape
            {
                let l_shape = L_Shape_ViewController.initialization()!
                l_shape.L_shape_1_Rectangle_width  = 20
                l_shape.L_shape_1_Rectangle_hight = 20
                l_shape.L_shape_2_Rectangle_width  = 20
                l_shape.L_shape_2_Rectangle_hight = 20
                l_shape.isFlip = false
                l_shape.appoinmentslData = self.appoinmentslData
                l_shape.floorLevelData = self.floorLevelData
                l_shape.roomData = self.roomData
                l_shape.floorShapeData = self.floorShapeData[self.selectedno]
                self.navigationController?.pushViewController(l_shape, animated: true)
                
                //            self.navigationController?.pushViewController(L_Shape_Value_Collection_ViewController.initialization()!, animated: true)
            }
            else
            {
                self.alert("Not Available", nil)
            }
        }
        else
        {
            let custom_shape = CustomShapeLineViewController.initialization()!
            custom_shape.appoinmentslData = self.appoinmentslData
            // custom_shape.floorLevelData = self.floorLevelData
            custom_shape.roomData = self.roomData
            //custom_shape.floorShapeData = self.floorShapeData[0]
            self.navigationController?.pushViewController(custom_shape, animated: true)
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

