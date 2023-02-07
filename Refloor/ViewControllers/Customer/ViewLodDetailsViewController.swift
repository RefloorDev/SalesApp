//
//  ViewLodDetailsViewController.swift
//  Refloor
//
//  Created by Arun Rajendrababu on 07/01/22.
//  Copyright © 2022 oneteamus. All rights reserved.
//

import UIKit
import RealmSwift

class ViewLodDetailsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    static func initialization() -> ViewLodDetailsViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ViewLodDetailsViewController") as? ViewLodDetailsViewController
    }
    @IBOutlet weak var appointmentStatusLabel: UILabel!
    
    @IBOutlet weak var viewLogTableView: UITableView!
    var appointmentLogsArray:List<rf_Appointment_Log_Data>!
    var selectedAppointmentId = ""
    
    @IBOutlet weak var appointmentIdLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLogTableView.dataSource = self
        viewLogTableView.delegate = self
        setNavigationBarbackAndlogo2(with: "Log Details")
        self.appointmentIdLabel.text = selectedAppointmentId
        if self.fetchAppointmentRequest(for: Int(selectedAppointmentId) ?? 0).count > 0{
            appointmentStatusLabel.text = "Appointment Sync Pending"
            appointmentStatusLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        }else{
            appointmentStatusLabel.text = "Appointment Sync Completed"
            appointmentStatusLabel.textColor = UIColor().colorFromHexString("#72C36F")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentLogsArray.count == 0 ? 0 :  appointmentLogsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewLogDetailTableViewCell", for: indexPath) as! ViewLogDetailTableViewCell
        cell.selectionStyle = .none
        cell.appointmentLbl.textColor = .white
        cell.appointmentLbl.text = (appointmentLogsArray[indexPath.row].sync_message ?? "")
        cell.appointmentTimeLabel.text = (appointmentLogsArray[indexPath.row].sync_time ?? "").logDate().logDataAsString()
        cell.separatorLineView.isHidden = indexPath.row != appointmentLogsArray.count-1 ? false : true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70 //UITableView.automaticDimension
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

class ViewLogDetailTableViewCell:UITableViewCell{
    @IBOutlet weak var appointmentLbl: UILabel!
    @IBOutlet weak var appointmentTimeLabel: UILabel!
    @IBOutlet weak var separatorLineView: UIView!
}
