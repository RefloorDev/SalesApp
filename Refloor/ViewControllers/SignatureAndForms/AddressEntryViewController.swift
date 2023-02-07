//
//  AddressEntryViewController.swift
//  Refloor
//
//  Created by sbek on 02/09/20.
//  Copyright © 2020 oneteamus. All rights reserved.
//

import UIKit
import MapKit
protocol AddressSelectPlaceEntryDelegate {
    func DidAddressSelectPlaceEntryDelegate(title:String,mapItem:MKMapItem?,tag:Int)
}
class AddressEntryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    static public func initialization() -> AddressEntryViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "AddressEntryViewController") as? AddressEntryViewController
    }
    @IBOutlet weak var activitiesIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noresultfounds: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    var values:[MKMapItem] = []
    var address = ""
    var selected:MKMapItem?
    var delegateTag = 0
    var delegate:AddressSelectPlaceEntryDelegate?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTF.text = address
        self.activitiesIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }
    @IBAction func textEditChange(_ sender: UITextField) {
        getMapPlaces(words: sender.text  ?? "")
    }
    
    
    func getMapPlaces(words:String)
    {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = words
        self.activitiesIndicator.startAnimating()
        self.activitiesIndicator.isHidden = true
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            
            self.activitiesIndicator.isHidden = true
            guard let response = response else {
                self.values = []
                self.noresultfounds.isHidden = false
                self.tableView.reloadData()
                return
            }
            if response.mapItems.count != 0
            {
                self.values = response.mapItems
                self.noresultfounds.isHidden = true
                self.tableView.reloadData()
            }
            else
            {
                self.noresultfounds.isHidden = false
                self.values = []
                self.tableView.reloadData()
            }
            
        }
    }
    @IBAction func okbuttonaction(_ sender: Any)
    {
        delegate?.DidAddressSelectPlaceEntryDelegate(title: searchTF.text ?? "", mapItem: selected, tag: delegateTag)
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (selected == nil) ? values.count : (values.count + 1)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggetionsTableViewCell") as! SuggetionsTableViewCell
        var index = indexPath.row
        if(selected != nil )
        {
            index -= 1
            if(indexPath.row == 0)
            {
                cell.placeName.text = "🔘 " + (selected?.placemark.title ?? "")
            }
            else
            {
                cell.placeName.text = values[index].placemark.title ?? ""
            }
        }
        else
        {
            cell.placeName.text = values[indexPath.row].placemark.title ?? ""
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(selected != nil )
        {
            let index = indexPath.row - 1
            if(indexPath.row != 0)
            {
                selected = values[index]
                self.searchTF.text = (selected?.placemark.title ?? "")
            }
            
        }
        else
        {
            selected = values[indexPath.row]
            self.searchTF.text = (selected?.placemark.title ?? "")
        }
        tableView.reloadData()
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
