//
//  CustomShapeLineViewController.swift
//  Refloor
//
//  Created by sbek on 03/06/20.
//  Copyright © 2020 oneteamus. All rights reserved.


import UIKit
import RealmSwift
import IQKeyboardManagerSwift
@MainActor
class CustomShapeLineViewController: UIViewController,CustomViewDelegate,LineViewDelegate,DropDownDelegate,UITextFieldDelegate,UIScrollViewDelegate {
    
    
    
    @IBOutlet weak var masterView: UIView!
    
    static func initialization() -> CustomShapeLineViewController? {
        return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "CustomShapeLineViewController") as? CustomShapeLineViewController
    }
    
    
    @IBOutlet weak var tempAreaLabel: UILabel!
    @IBOutlet weak var graphMoodLabel: UILabel!
    @IBOutlet weak var drowingContentView: UIView!
    @IBOutlet weak var bottomToolView: UIView!
    @IBOutlet weak var bottomToolViewWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var areaTF: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rectangle_Button: UIButton!
    @IBOutlet weak var graphMode_Selection_Button: UIButton!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var horisontalButton: UIButton!
    @IBOutlet weak var verticalButton: UIButton!
    @IBOutlet weak var addView_WidthTF: UITextField!
    @IBOutlet weak var addView_HeightTF: UITextField!
    @IBOutlet weak var add_Button: UIButton!
    @IBOutlet weak var add_View_hight_Constrain: NSLayoutConstraint!
    @IBOutlet weak var bottomLineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selected_squareView_Name_label: UILabel!
    @IBOutlet weak var selected_horizotal_Button: UIButton!
    @IBOutlet weak var selected_vertical_Button: UIButton!
    @IBOutlet weak var seletced_SqureView_TF: UITextField!
    @IBOutlet weak var selected_View_Constrain: NSLayoutConstraint!
    @IBOutlet weak var selected_SquareView_Height_TF: UITextField!
    @IBOutlet weak var selected_View: UIView!
    var isResponder = false
    var drowingView:LineView!
    var canvasScrollView: UIScrollView!
    var labels:[UILabel] = []
    var respondeTag = -1
    var isVertical = true
    var areaValue:CGFloat = 0
    var perimeter:Float = 0
    var isAreaManuallyEdited = false
    var selectedOpening:SubSqureView?
    var orginalgraphXvalue = 0
    var intWidth:CGFloat = 0
    var width:CGFloat = 0
    var intHight:Int = 0
    var hight:CGFloat = 0
    var selectedPostion = 0
    var areaSquareFt = 0
    var yAxisLayerSharae:CAShapeLayer!
    var xAxisLayerSharae:CAShapeLayer!
    var roomData:RoomDataValue!
    var addData:CustomeShapeViewController!
    var messurementID = -1
    var imagePicker: CaptureImage!
    var transitionHeightDropDownArray:List<rf_transitionHeights_results>!
    var capturedConfirmationImage: UIImage?
    
    
 //   var openingsList:[OpeningCustomObject] = [OpeningCustomObject(name: "No Transition", color: .white),OpeningCustomObject(name: "Reducer", color: .yellow),OpeningCustomObject(name: "Square Edge", color: .blue),OpeningCustomObject(name: "Stair Nose", color: .green),OpeningCustomObject(name: "Carpet", color: .red)]
    
    var openingsList:[OpeningCustomObject] = [OpeningCustomObject(name: "No Transition", color: .white),OpeningCustomObject(name: "Reducer", color: .yellow),OpeningCustomObject(name: "Square Edge", color: .blue),OpeningCustomObject(name: "Stair Nose", color: .green),OpeningCustomObject(name: "Carpet", color: .red),OpeningCustomObject(name: "Metal T", color: .cyan)]//,OpeningCustomObject(name: "Rubber", color: .magenta)]
     
  
    var currentOpening:Int = -1
    var appoinmentslData:AppoinmentDataValue!
    var path: UIBezierPath!
    var graph_minimunValue = minimumValue
    var summaryData:SummeryDetailsData!
    var transitionHeightvalue:[String] = []
    var transitionHeightId:Int = Int()
    var sidePanel: FloatingSidePanelView!
    var bottomToolbar: DrawingToolbar!
    var bottomToolbarWidthConstraint: NSLayoutConstraint!
    var bottomToolbarCenterXConstraint: NSLayoutConstraint!
    var bottomToolbarCenterYConstraint: NSLayoutConstraint!
    weak var activeCustomPopup: AddOpeningPopupView?
    weak var popupDimmerView: UIView?
    var relocateButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        minimumValue = 40
        addView_WidthTF.delegate = self
        addView_HeightTF.delegate = self
        bottomLineViewTopConstraint.constant = 35
        addView_HeightTF.setLeftPaddingPoints(10)
        selected_SquareView_Height_TF.setLeftPaddingPoints(10)
        //
        //seletced_SqureView_TF.delegate = self
        
        transitionHeightDropDownArray = self.getTransitionheightDropDownValue()
        if transitionHeightDropDownArray.count > 0
        {
            transitionHeightvalue = transitionHeightDropDownArray!.compactMap({$0.name})
            //        var transitionHeightValueCopy = transitionHeightvalue
            //        transitionHeightvalue.removeAll()
            //        for index in 0...transitionHeightValueCopy.count - 1
            //        {
            //            var value = transitionHeightValueCopy[index]
            //            value = value.replacingOccurrences(of: "\"", with: "")
            //            transitionHeightvalue.append(value)
            //        }
            transitionHeightId = transitionHeightDropDownArray[0].transitionHeightId
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Commented out to prevent the scroll view content view from collapsing to 0 width.
            /*
            if let rightContainer = self.addView?.superview {
                rightContainer.isHidden = true
                for constraint in rightContainer.constraints {
                    if constraint.firstAttribute == .width {
                        constraint.constant = 0
                    }
                }
                if let superview = rightContainer.superview {
                    for constraint in superview.constraints {
                        if (constraint.firstItem as? UIView) == rightContainer && constraint.firstAttribute == .width {
                            constraint.constant = 0
                        }
                        if (constraint.secondItem as? UIView) == rightContainer && constraint.secondAttribute == .width {
                            constraint.constant = 0
                        }
                    }
                }
            }
            */
            let canvasSize = CGSize(width: 10000, height: 10000)
            self.canvasScrollView = UIScrollView(frame: self.masterView.bounds)
            self.canvasScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.canvasScrollView.contentSize = canvasSize
            self.canvasScrollView.backgroundColor = .clear
            self.canvasScrollView.delegate = self
            self.canvasScrollView.minimumZoomScale = 0.5
            self.canvasScrollView.maximumZoomScale = 5.0
            self.canvasScrollView.bounces = false
            self.canvasScrollView.showsHorizontalScrollIndicator = false
            self.canvasScrollView.showsVerticalScrollIndicator = false
            self.canvasScrollView.isMultipleTouchEnabled = true
            self.canvasScrollView.panGestureRecognizer.minimumNumberOfTouches = 2
            self.canvasScrollView.panGestureRecognizer.maximumNumberOfTouches = 2
            
            self.drowingView = LineView(frame: CGRect(origin: .zero, size: canvasSize))
            self.drowingView.delegate = self
            self.drowingView.backgroundColor = .clear
            self.drowingView.isMultipleTouchEnabled = true
            self.canvasScrollView.addSubview(self.drowingView)
            
            let offsetX = (canvasSize.width - self.masterView.bounds.width) / 2
            let offsetY = (canvasSize.height - self.masterView.bounds.height) / 2
            self.canvasScrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
            
            self.setgraphView(self.drowingView)
            self.drowingContentView.addSubview(self.canvasScrollView)
            self.scrollView.isHidden = true
            self.addViewHideORVisible(true)
            self.no_Squre_View_In_Tool()
            self.setNavigationBarbacklogoResetAndNext(name: self.roomData.name ?? "")
            self.setupNewUI()
            self.setupRelocateButton()
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
     
        if self.drowingView != nil {
            self.drowingView.isConfirmed = false
        }
        
        checkWhetherToAutoLogoutOrNot(isRefreshBtnPressed: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        logScreenEvent(screen: ScreenNames.roomDrawing) {
            var networkMessage = ""
            let speedTest = NetworkSpeedTest()
            speedTest.testUploadSpeed { speed in
                print("Upload speed: \(speed) Mbps")
                networkMessage = String(format: "%.2f", speed)
                networkMessage += "Mbps"
                //DispatchQueue.main.async {
                
                let (_,timeZone) = Date().getCompletedDateStringAndTimeZone()
                let parameters:[String:Any] = ["appointment_id": AppointmentData().appointment_id ?? 0,"screen_name":ScreenNames.roomDrawing,"screen_entry_date":Date().getSyncDateAsString(),"network_strength":networkMessage,"timezone":timeZone]
                HttpClientManager.SharedHM.liveScreenLogsAPi(parameter: parameters)
            }
        }
            
        }
    
    override func resetButtonAction() {
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.resetAllThing()
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        self.alert("Are you sure you want to reset the current shape?", [yes,no])
        
    }
    override func performSegueToReturnBack() {
        let ok = UIAlertAction(title: "Yes", style: .default) { (_) in
//            if(self.messurementID == -1)
//            {
//                self.navigationController?.popViewController(animated: true)
//            }
//            else
//            {
                //self.DeleteroomMeasurement()
                let appointmentId = AppointmentData().appointment_id ?? 0
                let room_id = self.roomData.id ?? 0
                //delete images from document directory
                //1. drawing drawing
            let drawingPath = self.getDrawingPath(appointmentId: appointmentId, roomId: room_id)
                if drawingPath.count > 0{
                    _ = ImageSaveToDirectory.SharedImage.deleteImageFromDocumentDirectory(rfImage: drawingPath)
                }
                //2. Delete saved room images from document directory
                self.deleteRoomAttachmentImagesFromDirectory(appointmentId: appointmentId, roomId: room_id)
                
                //delete row from DB , this also delete room from appointment
                
                self.deleteRoomById(appointmentId: appointmentId, roomId: room_id)
                self.navigationController?.popViewController(animated: true)
           // }
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        // self.alert("Are you sure you want to go back? Selected room measurements will be deleted if you navigate back.", [ok,no])
        self.alert("Your current drawing will be lost. Are you sure?", [ok,no])
        
        
    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == seletced_SqureView_TF
//        {
//            if let text = textField.text {
//
//                    let newStr = (text as NSString)
//                    .replacingCharacters(in: range, with: string)
//                    if newStr.isEmpty {
//                        return true
//                    }
//                    let intvalue = Int(newStr)
//                return (intvalue! >= 0 && intvalue! <= 12)
//                }
//                return true
//        }
//        return true
//    }
    
    @IBAction func areaTFDidEndAction(_ sender: UITextField) {
        if let value2 =  Float(sender.text ?? "")
        {
            if value2 <= 0 {
                self.alert("We cannot enter 0 as a measurement", nil)
                let a = Double(self.areaValue)
                self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
                self.sidePanel?.areaValueLabel.text = "\(a.rounded(.awayFromZero).clean)"
                return
            }
            let a = Double(value2)
            
            self.areaValue = roundTheValue(CGFloat(value2))
            self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
            self.sidePanel?.areaValueLabel.text = "\(a.rounded(.awayFromZero).clean)"
            self.isAreaManuallyEdited = true
        }
        else
        {
            self.alert("Wrong Value", nil)
        }
    }
    func roundTheValue(_ value:CGFloat) -> CGFloat
    {
        return CGFloat(Float(value * 100).rounded()/100)
    }
    @IBAction func AreaTFDidBegen(_ sender: UITextField) {
        
    }
    @IBAction func areaMinusButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if areaValue <= 1 {
            self.alert("We cannot enter 0 as a measurement", nil)
            let a = Double(self.areaValue)
            self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
            self.sidePanel?.areaValueLabel.text = "\(a.rounded(.awayFromZero).clean)"
            return
        }
        areaValue -= 1
        
        let a = Double(areaValue)
        self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
        self.sidePanel?.areaValueLabel.text = "\(a.rounded(.awayFromZero).clean)"
        self.isAreaManuallyEdited = true
    }
    
    @IBAction func areaPluseButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        areaValue += 1
        let a = Double(areaValue)
        self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
        self.sidePanel?.areaValueLabel.text = "\(a.rounded(.awayFromZero).clean)"
        self.isAreaManuallyEdited = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == addView_WidthTF
        {
            let searchString = (addView_WidthTF.text as NSString?)?.replacingCharacters(in: range, with: string)
            if (searchString?.count)! > 1 {
                
                let inverseSet = CharacterSet(charactersIn: ".0123456789").inverted
                
                return ((string as NSString).rangeOfCharacter(from: inverseSet).location == NSNotFound)
                
            } else {
                
                let inverseSet = CharacterSet(charactersIn: ".123456789").inverted
                
                return ((string as NSString).rangeOfCharacter(from: inverseSet).location == NSNotFound)
            }
        }
        return true
    }
    override func nextAction() {
        //q4 changes // kavya
        var isSelected = addData?.add_Button.isSelected
        if(!self.drowingView.isClosed) {
            self.alert("Close the room drawing before proceeding", nil)
        } else {
            // Ensure path is evaluated for closed state so line values are updated
            _ = self.drowingView.getPath(true)
            
            // Always synchronously update area before validation to avoid async race conditions
            if !self.isAreaManuallyEdited {
                let calculatedArea = self.drowingView.getarea()
                if calculatedArea > 0 {
                    let roundedArea = Double(calculatedArea).rounded(.awayFromZero)
                    self.areaValue = CGFloat(roundedArea)
                    self.areaTF.text = "\(roundedArea.clean)"
                    self.sidePanel?.areaValueLabel.text = "\(roundedArea.clean)"
                }
            }
            
            // Validation: Measurement should not be less than 0.5 ft
            var hasInvalidLine = false
            var hasAnyValidLine = false
            
            for point in self.drowingView.pointPath {
                if !point.label.isHidden {
                    if point.lineValue > 0 {
                        hasAnyValidLine = true
                    }
                    if point.lineValue < 0.5 {
                        hasInvalidLine = true
                        break
                    }
                }
            }
            
            let area = Float(self.areaTF.text ?? "0") ?? 0
            
            if hasInvalidLine {
                self.alert("All line measurements must be at least 0.5 ft.", nil)
                return
            }
            
            if !hasAnyValidLine && area <= 0 {
                self.alert("The estimated area must be greater than 0.", nil)
                return
            }
            
            if self.drowingView.subSquareView.isEmpty {     // Q4_Change Add Openings Popup
                self.alert("Please select add openings", nil)
            } else {
                self.showConfirmationPopup()
            }
        }
    }
    
    private var confirmationDimmerView: UIView?
    private var confirmationPopupContainer: UIView?
    
    func showConfirmationPopup() {
        self.view.endEditing(true)
        
        let dimmer = UIView()
        dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dimmer)
        self.confirmationDimmerView = dimmer
        
        let container = UIView()
        container.backgroundColor = UIColor(red: 0x58/255.0, green: 0x64/255.0, blue: 0x71/255.0, alpha: 0.8)
        container.layer.cornerRadius = 0
        container.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(container)
        self.confirmationPopupContainer = container
        
        let titleLabel = UILabel()
        titleLabel.text = "Confirmation Required"
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Are you sure you want to continue with this drawing?"
        subtitleLabel.font = UIFont(name: "Avenir-Medium", size: 24) ?? UIFont.systemFont(ofSize: 24)
        subtitleLabel.textColor = UIColor(red: 0xA7/255.0, green: 0xB0/255.0, blue: 0xBA/255.0, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)
        
        let contentPanel = UIView()
        contentPanel.backgroundColor = UIColor(red: 0x2D/255.0, green: 0x34/255.0, blue: 0x3D/255.0, alpha: 1.0)
        contentPanel.layer.cornerRadius = 10
        contentPanel.clipsToBounds = true
        contentPanel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(contentPanel)
        
        self.drowingView.configureForPreview(true)
        self.drowingView.layoutIfNeeded()
        
        var contentRect = self.drowingView.bounds
            var boundingBox = CGRect.null
            for pt in self.drowingView.pointPath {
                let ptRect = CGRect(x: pt.point.x, y: pt.point.y, width: 0, height: 0)
                boundingBox = boundingBox.isNull ? ptRect : boundingBox.union(ptRect)
            }
            for subview in self.drowingView.subviews {
                if subview is LineSegmentControlView || subview is SubSqureView || subview is UILabel {
                    boundingBox = boundingBox.isNull ? subview.frame : boundingBox.union(subview.frame)
                    if let sq = subview as? SubSqureView, let tooltip = sq.tooltipView {
                        let tooltipFrame = tooltip.convert(tooltip.bounds, to: self.drowingView)
                        boundingBox = boundingBox.union(tooltipFrame)
                    }
                }
            }
            
            let padding: CGFloat = 40
            if !boundingBox.isNull {
                let rawRect = CGRect(x: boundingBox.minX - padding, y: boundingBox.minY - padding, width: boundingBox.width + 2*padding, height: boundingBox.height + 2*padding)
                contentRect = rawRect.intersection(self.drowingView.bounds)
                if contentRect.width <= 0 || contentRect.height <= 0 {
                    contentRect = self.drowingView.bounds
                }
            }
        
        let originalOpaque = self.drowingView.isOpaque
        self.drowingView.isOpaque = false
        
        let wasGridHidden = self.yAxisLayerSharae?.isHidden ?? false
        self.yAxisLayerSharae?.isHidden = true
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentPanel.addSubview(imageView)
        
        let areaTitleLabel = UILabel()
        areaTitleLabel.text = "Estimated Area:"
        areaTitleLabel.font = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        areaTitleLabel.textColor = UIColor(red: 0xA7/255.0, green: 0xB0/255.0, blue: 0xBA/255.0, alpha: 1.0)
        areaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPanel.addSubview(areaTitleLabel)
        
        let areaValueText = self.areaTF.text ?? ""
        let areaValueLbl = UILabel()
        areaValueLbl.text = "\(areaValueText) Sq. Ft."
        areaValueLbl.font = UIFont(name: "Avenir-Heavy", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        areaValueLbl.textColor = .white
        areaValueLbl.translatesAutoresizingMaskIntoConstraints = false
        contentPanel.addSubview(areaValueLbl)
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.backgroundColor = UIColor(red: 88/255, green: 100/255, blue: 113/255, alpha: 1.0)
        cancelBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        cancelBtn.layer.cornerRadius = 0
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.addTarget(self, action: #selector(hideConfirmationPopup), for: .touchUpInside)
        contentPanel.addSubview(cancelBtn)
        
        let confirmBtn = UIButton(type: .system)
        confirmBtn.setTitle("Confirm Measurement", for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.backgroundColor = UIColor(red: 41/255.0, green: 37/255.0, blue: 98/255.0, alpha: 1.0)
        confirmBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        confirmBtn.layer.cornerRadius = 0
        confirmBtn.layer.borderWidth = 1
        confirmBtn.layer.borderColor = UIColor(red: 0xA7/255.0, green: 0xB0/255.0, blue: 0xBA/255.0, alpha: 1.0).cgColor
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.addTarget(self, action: #selector(performMeasurementUpload), for: .touchUpInside)
        contentPanel.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            dimmer.topAnchor.constraint(equalTo: self.view.topAnchor),
            dimmer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            dimmer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimmer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
            container.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.7),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            contentPanel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            contentPanel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            contentPanel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            contentPanel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: contentPanel.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentPanel.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentPanel.trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: cancelBtn.topAnchor, constant: -20),
            
            cancelBtn.bottomAnchor.constraint(equalTo: contentPanel.bottomAnchor, constant: -20),
            cancelBtn.trailingAnchor.constraint(equalTo: confirmBtn.leadingAnchor, constant: -15),
            cancelBtn.widthAnchor.constraint(equalToConstant: 157),
            cancelBtn.heightAnchor.constraint(equalToConstant: 54),
            
            confirmBtn.bottomAnchor.constraint(equalTo: contentPanel.bottomAnchor, constant: -20),
            confirmBtn.trailingAnchor.constraint(equalTo: contentPanel.trailingAnchor, constant: -20),
            confirmBtn.widthAnchor.constraint(equalToConstant: 303),
            confirmBtn.heightAnchor.constraint(equalToConstant: 54),
            
            areaTitleLabel.leadingAnchor.constraint(equalTo: contentPanel.leadingAnchor, constant: 20),
            areaTitleLabel.bottomAnchor.constraint(equalTo: areaValueLbl.topAnchor, constant: -2),
            
            areaValueLbl.leadingAnchor.constraint(equalTo: contentPanel.leadingAnchor, constant: 20),
            areaValueLbl.bottomAnchor.constraint(equalTo: contentPanel.bottomAnchor, constant: -20)
        ])
        
        self.view.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(contentRect.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: -contentRect.origin.x, y: -contentRect.origin.y)
            self.drowingView.layer.render(in: context)
        }
        let drawingImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        self.yAxisLayerSharae?.isHidden = wasGridHidden
        self.capturedConfirmationImage = drawingImage
        self.drowingView.isOpaque = originalOpaque
        self.drowingView.configureForPreview(false)
        
        imageView.image = drawingImage
    }
    
    @objc func hideConfirmationPopup() {
        self.confirmationDimmerView?.removeFromSuperview()
        self.confirmationPopupContainer?.removeFromSuperview()
        self.confirmationDimmerView = nil
        self.confirmationPopupContainer = nil
    }
    
    @objc func performMeasurementUpload() {
        hideConfirmationPopup()
        if !self.drowingView.isConfirmed {
            self.drowingView.isConfirmed = true
            self.drowingView.drowShape(true)
        }
        let appointmentId = AppointmentData().appointment_id ?? 0
        let currentClassName = String(describing: type(of: self))
        let classDisplayName = "RoomDrawing"
        self.saveScreenCompletionTimeToDb(appointmentId: appointmentId, className: currentClassName, displayName: classDisplayName, time: Date())
        
        // Allow the UI to render the confirmed shape before capturing the image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.messurementUpload()
        }
    }
    func setgraphForMoodView(_ sender :UIView)
    {
        var graphValue = minimumValue
        if(graphValue == 30)
        {
            graphValue *= 2
            //self.graphMood.setTitle("2x", for: .normal)
            //self.graphMood.tag = 1
            
        }
        else if(graphValue == 20)
        {
            graphValue *= 3
            // self.graphMood.setTitle("3x", for: .normal)
            // self.graphMood.tag = 2
            
        }
        else if(graphValue == 10)
        {
            graphValue *= 4
            // self.graphMood.setTitle("4x", for: .normal)
            //self.graphMood.tag = 3
            
        }
        else if(graphValue == 5)
        {
            graphValue *= 10
            // self.graphMood.setTitle("10x", for: .normal)
            // self.graphMood.tag = 4
            
        }
        else if graphValue == 1
        {
            graphValue *= 50
            // self.graphMood.setTitle("50x", for: .normal)
            //self.graphMood.tag = 5
            
        }
        else if graphValue != 40
        {
            graphValue *= 100
            //   self.graphMood.setTitle("100x", for: .normal)
            //  self.graphMood.tag = 6
            
        }
        else
        {
            //   self.graphMood.setTitle("1x", for: .normal)
            //  self.graphMood.tag = 0
            
        }
        
        let xAxispath = UIBezierPath()
        let tmpwidth = sender.frame.width
        intWidth = tmpwidth / graphValue
        width = ((intWidth ) * graphValue) + graphValue
        
        let tmphight = sender.frame.height
        intHight = Int(tmphight / graphValue)
        hight = CGFloat((intHight - 1) * Int(graphValue))
        // xAxis creattion
        for i in 0...(Int(intWidth) + 2)
        {
            let xvalue =  (Int(graphValue) * i)
            xAxispath.move(to: CGPoint(x: xvalue, y: 0))
            xAxispath.addLine(to: CGPoint(x:xvalue, y: Int(hight)))
            xAxispath.close()
            
        }
        
        
        
        // yAxis creattion
        for i in 0...(intHight + 3)
        {
            if( i != 0)
            {
                let yvalue =  (Int(graphValue) * i)
                xAxispath.move(to: CGPoint(x: 0, y: yvalue))
                xAxispath.addLine(to: CGPoint(x:Int(width), y: yvalue))
                xAxispath.close()
            }
            
        }
        
        if(yAxisLayerSharae == nil)
        {
            
            yAxisLayerSharae = CAShapeLayer()
            
            yAxisLayerSharae.backgroundColor = UIColor.clear.cgColor
            yAxisLayerSharae.path = xAxispath.cgPath
            yAxisLayerSharae.fillColor = UIColor.clear.cgColor
            yAxisLayerSharae.strokeColor = UIColor.lightGray.cgColor
            yAxisLayerSharae.lineWidth = 1.0
            sender.layer.addSublayer(yAxisLayerSharae)
        }
        else
        {
            yAxisLayerSharae.path = xAxispath.cgPath
        }
        
        
        
    }
    
    func setgraphView(_ sender :UIView)
    {
        graph_minimunValue = minimumValue
        
        if(graph_minimunValue == 30)
        {
            graph_minimunValue *= 2
            //               self.graphMood.setTitle("2x", for: .normal)
            //               self.graphMood.tag = 1
            orginalgraphXvalue = 1
        }
        else if(graph_minimunValue == 20)
        {
            graph_minimunValue *= 3
            //               self.graphMood.setTitle("3x", for: .normal)
            //               self.graphMood.tag = 2
            orginalgraphXvalue = 2
        }
        else if(graph_minimunValue == 10)
        {
            graph_minimunValue *= 4
            //               self.graphMood.setTitle("4x", for: .normal)
            //               self.graphMood.tag = 3
            orginalgraphXvalue = 3
        }
        else if(graph_minimunValue == 5)
        {
            graph_minimunValue *= 10
            //               self.graphMood.setTitle("10x", for: .normal)
            //               self.graphMood.tag = 4
            orginalgraphXvalue = 4
        }
        else if graph_minimunValue == 1
        {
            graph_minimunValue *= 50
            //               self.graphMood.setTitle("50x", for: .normal)
            //               self.graphMood.tag = 5
            orginalgraphXvalue = 5
        }
        else if graph_minimunValue != 40
        {
            graph_minimunValue *= 100
            //               self.graphMood.setTitle("100x", for: .normal)
            //               self.graphMood.tag = 6
            orginalgraphXvalue = 6
        }
        else
        {
            //               self.graphMood.setTitle("1x", for: .normal)
            //               self.graphMood.tag = 0
            orginalgraphXvalue = 0
        }
        
        let xAxispath = UIBezierPath()
        let tmpwidth: CGFloat = 10000.0
        intWidth = tmpwidth / graph_minimunValue
        width = ((intWidth ) * graph_minimunValue) + graph_minimunValue
        
        let tmphight: CGFloat = 10000.0
        intHight = Int(tmphight / graph_minimunValue)
        hight = CGFloat((intHight + 1) * Int(graph_minimunValue))
        // Draw horizontal lines with a dashed pattern to create dots
        for i in 0...(intHight + 2)
        {
            let yvalue =  (Int(graph_minimunValue) * i)
            xAxispath.move(to: CGPoint(x: 0, y: yvalue))
            xAxispath.addLine(to: CGPoint(x:Int(width), y: yvalue))
        }
        
        if(yAxisLayerSharae == nil)
        {
            yAxisLayerSharae = CAShapeLayer()
            yAxisLayerSharae.backgroundColor = UIColor.clear.cgColor
            yAxisLayerSharae.path = xAxispath.cgPath
            yAxisLayerSharae.fillColor = UIColor.clear.cgColor
            yAxisLayerSharae.strokeColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            yAxisLayerSharae.lineWidth = 3.5 // Larger single point size
            yAxisLayerSharae.lineCap = .round
            yAxisLayerSharae.lineDashPattern = [0, NSNumber(value: Double(graph_minimunValue))]
            sender.layer.insertSublayer(yAxisLayerSharae, at: 0)
        }
        else
        {
            yAxisLayerSharae.path = xAxispath.cgPath
            yAxisLayerSharae.lineWidth = 3.5
            yAxisLayerSharae.lineCap = .round
            yAxisLayerSharae.lineDashPattern = [0, NSNumber(value: Double(graph_minimunValue))]
        }
        
        
        
    }
    
    
    @IBAction func graphMoodButtonAction(_ sender: UIButton)
    {
        self.DropDownDefaultfunction(sender, sender.bounds.width, ["1x","2x","3x","4x","10x","50x","100x"], self.orginalgraphXvalue, delegate: self, tag: 0)
        
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        
        if !(drowingView.isConfirmed)
        {
            drowingView.removeLastLine()
        }
    }
    
    @IBAction func clearAllButtonAction(_ sender: Any) {
        if !(drowingView.isConfirmed)
        {
            self.graphMode_Selection_Button.isUserInteractionEnabled = true
            
            drowingView.clearAllLine()
            self.tempAreaLabel.text = "Area: ?"
            self.updateUndoRedoButtonsState()
        }
    }
    
    @IBAction func confirmButton(_ sender: UIButton) {
        if(drowingView.isClosed)
        {
            drowingView.isConfirmed = true
            drowingView.drowShape(true)
        }
        else
        {
            //  self.alert("Please join your shape by connecting the starting point and ending point", nil)
            self.alert("Please connect all points to complete the measurement", nil)
        }
    }
    
    
    
    
    
    
    
    @IBAction func rectanglebuttonAction(_ sender: UIButton)
    {
        let masterData = self.getMasterDataFromDB()
        let maximumOpenings = masterData.max_no_transitions 
        if let openings = self.drowingView?.subSquareView,(openings.count >= maximumOpenings)
        {
            self.alert("You have added maximum number of transitions", nil)
        }
        else
        {
            let strings = openingsList.map { (opening) -> String in
                opening.name
            }
            self.DropDownDefaultfunction(sender, 200, strings, currentOpening, delegate: self, tag: 2)
            bottomLineViewTopConstraint.constant = 25
        }
        
       
        
        
       
//        self.rectangle_Button.borderColor = .white
//        self.rectangle_Button.borderWidth = 1
//        self.isVertical = true
//        self.rectangle_Button.borderWidth = 1
//        self.rectangle_Button.borderColor = UIColor.white
//        self.horisontalButton.borderColor = .clear
//        self.horisontalButton.borderWidth = 0
//        self.addViewHideORVisible(false)
        
    }
    func addViewHideORVisible(_ isHiddenView:Bool)
    {
        UIView.animate(withDuration: 0.3) {
            if(isHiddenView)
            {
                self.add_View_hight_Constrain.constant = 0
                self.rectangle_Button.borderColor = .clear
                self.rectangle_Button.borderWidth = 0
                self.addView.isHidden = true
            }
            else
            {
                self.add_View_hight_Constrain.constant = 330
                self.isVertical = true
                self.verticalButton.borderWidth = 1
                self.verticalButton.borderColor = self.openingsList[self.currentOpening].color
                self.horisontalButton.borderColor = .clear
                self.horisontalButton.borderWidth = 0
                self.addView_WidthTF.text = "1"
                self.addView_HeightTF.text = "0"
                self.addView.isHidden = false
            }
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    
    @IBAction func add_opens_orientation(_ sender: UIButton) {
        if(verticalButton == sender)
        {
            self.isVertical = true
            self.verticalButton.borderWidth = 1
            self.verticalButton.borderColor = self.openingsList[self.currentOpening].color
            self.horisontalButton.borderColor = .clear
            self.horisontalButton.borderWidth = 0
        }
        else
        {
            self.isVertical = false
            self.verticalButton.borderWidth = 0
            self.verticalButton.borderColor = UIColor.clear
            self.horisontalButton.borderColor = .white
            self.horisontalButton.borderWidth = 1
        }
    }
    
    @IBAction func add_View_addButtonAction(_ sender: Any) {
        if !drowingView.isClosed {
            self.alert("Please close the drawing before adding openings", nil)
            return
        }
        if let value2 =  Float(self.addView_WidthTF.text ?? ""),currentOpening != -1
        {
            var addViewHeight = addView_HeightTF.text ?? "0"
           //addViewHeight = addViewHeight.replacingOccurrences(of: "\", with: "")
            if value2 == 0
            {
                self.alert("Please enter a valid value in width field.", nil)

            }
            if addView_HeightTF.text == ""
            {
                self.alert("Please enter a valid value in height field.", nil)
            }
            else
            {
                let hight = (!self.isVertical) ? 1 : CGFloat(value2 * 100) / 100
                let width = (!self.isVertical) ? CGFloat(value2 * 100) / 100 : 1
                
                addViewHideORVisible(true)
                drowingView.add_Sub_Square_View(xAsis: self.drowingView.buzierpath.bounds.maxX/2, yAxis: self.drowingView.buzierpath.bounds.maxY/2, width: width, hight: hight, delegate: self, isVertical: self.isVertical, objc: openingsList[currentOpening], addViewHeight: addViewHeight,transitionheightId: self.transitionHeightId)
                currentOpening = -1
                bottomLineViewTopConstraint.constant = 35
            }
        }
        else
        {
            self.alert("Please enter a correct width to continue", nil)
            
        }
        
        
        
    }
    
    
    
    
    
    func setSelectedSubSqureView(_ subView:SubSqureView)
    {
        if subView.custom_hight == 0.0
        {
            self.alert("Please enter a valid value in width field.", nil)
        }
        else
        {
            self.selected_View.isHidden = false
            self.selected_View_Constrain.constant = 350
            self.selectedOpening = subView
            // self.selected_squareView_Name_label.text = "Selected \(subView.object?.name ?? "")(\(subView.tag + 1))"
            self.selected_squareView_Name_label.text = "Selected \(subView.object?.name ?? "")"
            
            if !(subView.isVertical)
            {
                
                self.selected_vertical_Button.borderWidth = 1
                self.selected_vertical_Button.borderColor = UIColor.white
                self.selected_horizotal_Button.borderColor = .clear
                self.selected_horizotal_Button.borderWidth = 0
                self.seletced_SqureView_TF.text = String(format: "%.1f", Double(subView.custom_width))//"\(subView.custom_width)"
                self.selected_SquareView_Height_TF.text = "\(subView.addViewHeight)" //addView_HeightTF.text
            }
            else
            {
                
                self.selected_vertical_Button.borderWidth = 0
                self.selected_vertical_Button.borderColor = UIColor.clear
                self.selected_horizotal_Button.borderColor = .white
                self.selected_horizotal_Button.borderWidth = 1
                self.seletced_SqureView_TF.text = String(format: "%.1f", Double(subView.custom_hight))//"\(subView.custom_hight)"
                self.selected_SquareView_Height_TF.text = "\(subView.addViewHeight)" //addView_HeightTF.text
            }
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: UIButton)
    {
        if let view =  self.selectedOpening
        {
            drowingView.remove_Sub_Square_View(at: view.tag)
            no_Squre_View_In_Tool()
        }
    }
    
    //MARK:- Reset All
    func resetAllThing()
    {
        self.drowingView.clear_All_Sub_Square_View()
        self.drowingView.isConfirmed = false
        self.drowingView.isClosed = false
        self.graphMode_Selection_Button.isUserInteractionEnabled = true
        self.drowingView.clearAllLine()
        self.tempAreaLabel.text = "Area: ?"
        self.drowingView.removeAllPoints()
        self.drowingView.subSquareView = []
        self.scrollView.isHidden = true
        self.addViewHideORVisible(true)
        self.no_Squre_View_In_Tool()
        self.updateUndoRedoButtonsState()
        UIView.animate(withDuration: 0.2) {
            self.bottomToolView.isHidden = false
            self.bottomToolViewWidthConstrain.constant = 250
            self.view.layoutIfNeeded()
        }
    }
    
    
    func no_Squre_View_In_Tool()
    {
        self.selected_View.isHidden = true
        
        self.selected_View_Constrain.constant = 0
        self.selected_squareView_Name_label.text  = "No Selected Openings"
        self.seletced_SqureView_TF.text = ""
        self.selected_SquareView_Height_TF.text = ""
        self.selected_vertical_Button.borderWidth = 0
        self.selected_vertical_Button.borderColor = UIColor.clear
        self.selected_horizotal_Button.borderColor = .clear
        self.selected_horizotal_Button.borderWidth = 0
    }
    
    @IBAction func selectedVeritcalOrinationButtonAction(_ sender: UIButton) {
        if let view = self.selectedOpening
        {
            if !(view.isVertical)
            {
                self.drowingView.saveState()
                view.changeOriantation(true)
                setSelectedSubSqureView(view)
            }
        }
    }
    @IBAction func selectedHorizontalOrinationButtonAction(_ sender: UIButton) {
        if let view = self.selectedOpening
        {
            if(view.isVertical)
            {
                self.drowingView.saveState()
                view.changeOriantation(false)
                setSelectedSubSqureView(view)
            }
        }
    }
    @IBAction func HeightdropDownBtnClicked(_ sender: UIButton)
    {
        if transitionHeightvalue.count > 0
        {
            if sender.tag == 0
            {
                print("transition heights",transitionHeightvalue)
                self.DropDownDefaultfunction(sender, 200, transitionHeightvalue, 1, delegate: self, tag: 1)
            }
            else
            {
                print("transition heights",transitionHeightvalue)
                self.DropDownDefaultfunction(sender, 200, transitionHeightvalue, 1, delegate: self, tag: 3)
            }
        }
        else
        {
            self.alert("Not Available", nil)
        }
    }
    
    @IBAction func selectedViewpluseButtonAction(_ sender: UIButton) {
        if let view =  self.selectedOpening
        {
            if !(view.isVertical)
            {
                if(view.custom_width < 20)
                {
                    self.drowingView.saveState()
                    view.custom_hight = 1
                    view.custom_width += 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight < 20)
                {
                    self.drowingView.saveState()
                    view.custom_width = 1
                    view.custom_hight += 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_hight)"
                    view.custom_size_reload()
                }
            }
        }
    }
    @IBAction func selectedViewminusButtonAction(_ sender: UIButton) {
        if let view =  self.selectedOpening
        {
            if !(view.isVertical)
            {
                if(view.custom_width > 1.0)
                {
                    self.drowingView.saveState()
                    view.custom_hight = 1
                    view.custom_width -= 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_width)"
                    view.custom_size_reload()
                }
            }
            else
            {
                if(view.custom_hight > 1.0)
                {
                    self.drowingView.saveState()
                    view.custom_width = 1
                    view.custom_hight -= 1.0
                    self.seletced_SqureView_TF.text = "\(view.custom_hight)"
                    view.custom_size_reload()
                }
            }
        }
    }
    
    
    func customViewDelegateResult(_ tag: Int) {
        self.drowingView.setSubSelectedView(at: tag)
        if let existingPopup = activeCustomPopup {
            if existingPopup.editIndex == tag {
                return
            }
            existingPopup.removeFromSuperview()
            popupDimmerView?.removeFromSuperview()
            activeCustomPopup = nil
            popupDimmerView = nil
        }
        
        let dimmer = UIView()
        dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dimmer)
        self.popupDimmerView = dimmer
        
        NSLayoutConstraint.activate([
            dimmer.topAnchor.constraint(equalTo: self.view.topAnchor),
            dimmer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimmer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dimmer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCustomPopup))
        dimmer.addGestureRecognizer(tap)
        
        let popup = AddOpeningPopupView(viewController: self, editIndex: tag)
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)
        self.activeCustomPopup = popup
        
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 340)
        ])
        
        popup.onCancel = { [weak self] in
            self?.dismissCustomPopup()
        }
        
        self.view.bringSubviewToFront(popup)
        
        popup.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        popup.alpha = 0.0
        dimmer.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            popup.transform = .identity
            popup.alpha = 1.0
            dimmer.alpha = 1.0
        }, completion: nil)
    }
    
    
    func customeLabelDelegateResult(label: UILabel) {
        let value = self.respondeTag - 1
        isResponder = true
        if(value != (label.tag - 1))
        {
            if(value == -1 )
            {
                self.respondeTag = label.tag
                
                // self.side_TableView.reloadRows(at: [[0,self.respondeTag - 1]], with: .automatic)
            }
            else
            {
                self.respondeTag = label.tag
                //  self.side_TableView.reloadRows(at: [[0,value],[0,self.respondeTag - 1]], with: .automatic)
            }
        }
        
    }
    
    
    func LineViewArea_PerimeterResult(area:CGFloat,Perimeter:Float) {
        if !self.isAreaManuallyEdited {
            let a = Double(area)
            self.areaValue = CGFloat(a.rounded(.awayFromZero))
            self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
            self.sidePanel?.areaValueLabel.text = "\(a.rounded(.awayFromZero).clean)"
        }
        self.perimeter = Perimeter.rounded()
        UIView.animate(withDuration: 0.2) {
            self.bottomToolView.isHidden = true
            self.bottomToolViewWidthConstrain.constant = 0
            self.scrollView.isHidden = false
            self.view.layoutIfNeeded()
        }
        
    }
    func LineDrawingStarted()
    {
        self.graphMode_Selection_Button.isUserInteractionEnabled = false
        self.updateUndoRedoButtonsState()
    }
    
    func didAutoSwitchDrawingMode(to mode: DrawingMode) {
        if mode == .horizontal {
            self.bottomToolbar.horizontalLineTapped()
        } else if mode == .vertical {
            self.bottomToolbar.verticalLineTapped()
        }
    }
    
    func LineViewTempAreaResult(area:CGFloat,isClosed:Bool,Perimeter:Float)
    {
        self.isAreaManuallyEdited = false
        self.sidePanel?.setAreaControlsEnabled(isClosed)
        if(isClosed)
        {
            let a = Double(area)
            self.perimeter = Perimeter.rounded()
            self.tempAreaLabel.text = "Area: \(a.rounded(.awayFromZero).clean) Sq.ft"
            self.areaTF.text = "\(a.rounded(.awayFromZero).clean)"
            self.sidePanel?.areaValueLabel.text = "\(a.rounded(.awayFromZero).clean)"
            self.areaValue = CGFloat(a.rounded(.awayFromZero))
        }
        else
        {
            self.tempAreaLabel.text = "Area: ?"
            self.sidePanel?.areaValueLabel.text = "0"
        }
        self.updateUndoRedoButtonsState()
    }
    
    func updateUndoRedoButtonsState() {
        guard let toolbar = self.bottomToolbar, let drawing = self.drowingView else { return }
        toolbar.undoBtn.isEnabled = drawing.pointPath.count > 0 || drawing.isDrawingNow
        toolbar.redoBtn.isEnabled = drawing.redoStack.count > 0
    }
    
    
    
    
    func DropDownDidSelectedAction(_ index: Int, _ item: String, _ tag: Int) {
        if tag == 100 {
            self.activeCustomPopup?.updateOpeningName(item)
        }
        else if tag == 101 {
            self.activeCustomPopup?.updateOpeningTo(item)
        }
        else if tag == 102 {
            self.activeCustomPopup?.updateHeight(item)
            if let selectedValue = transitionHeightDropDownArray?.filter({$0.name == item}) {
                transitionHeightId = selectedValue.first?.transitionHeightId ?? 0
            }
        }
        else if tag == 1
       {
           addView_HeightTF.text = item
           //selected_SquareView_Height_TF.text = item
            let selectedValue = transitionHeightDropDownArray.filter({$0.name == item})
            transitionHeightId = selectedValue.first?.transitionHeightId ?? 0
       }
        else if tag == 3
        {
            self.drowingView.saveState()
            selected_SquareView_Height_TF.text = item
            let selectedValue = transitionHeightDropDownArray.filter({$0.name == item})
            transitionHeightId = selectedValue.first?.transitionHeightId ?? 0
            let view =  self.selectedOpening
            view?.addViewHeight = item
        }
       else if tag != 2
        {
        switch index {
        case 0:
            minimumValue = 40
            self.graphMoodLabel.text = "1X"
        case 1:
            minimumValue = 30
            self.graphMoodLabel.text = "2X"
        case 2:
            minimumValue = 20
            self.graphMoodLabel.text = "3X"
        case 3:
            minimumValue = 10
            self.graphMoodLabel.text = "4X"
        case 4:
            minimumValue = 5
            self.graphMoodLabel.text = "10X"
        case 5:
            minimumValue = 1
            self.graphMoodLabel.text = "50X"
        case 6:
            minimumValue = 0.5
            self.graphMoodLabel.text = "100X"
        default:
            minimumValue = 40
            self.graphMoodLabel.text = "1X"
        }
        self.sidePanel?.scaleDropdownBtn.setTitle(self.graphMoodLabel.text, for: .normal)
        if let text = self.graphMoodLabel.text {
            let scaleFt = text.replacingOccurrences(of: "X", with: "")
            self.sidePanel?.scaleSub.text = "Scale 1 Unit = \(scaleFt) Ft."
        }
        setgraphView(self.drowingView)
        if self.drowingView!.pointPath.count != 0
        {
        self.drowingView.drowShape(self.drowingView.isClosed)
        }
        }
         
        else
        {
            self.currentOpening = index
            //self.rectangle_Button.borderColor = openingsList[currentOpening].color
            //self.rectangle_Button.borderWidth = 1
            self.isVertical = true
            self.rectangle_Button.borderWidth = 1
            //self.rectangle_Button.borderColor = openingsList[currentOpening].color
            //self.horisontalButton.borderColor = .clear
            self.horisontalButton.borderWidth = 0
            if index == 0
            {
                self.addViewHideORVisible(true)
            }
            else
            {
                self.addViewHideORVisible(false)
                self.view.bringSubviewToFront(addView)
            }
        }
       }
    
    
    
    func messurementUpload()
    {
        var transArray:[TransitionData] = []
        if let openings = self.drowingView?.subSquareView,openings.count != 0
        {
            
            for opng in openings
            {
                if #available(iOS 14.0, *) {
                    print("item:\(opng.object?.name ?? "") color:\(opng.object?.color.accessibilityName ?? "") size: \(opng.getSize)")
                    let transData = TransitionData.init(name: opng.object?.name ?? "", color: opng.object?.color.accessibilityName ?? "", transsquarefeet: Float(opng.getSize),transHeight: opng.addViewHeight,transitionHeightId: opng.transitionHeightId)
                    transArray.append(transData)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        if let area  = Float(self.areaTF.text?.replacingOccurrences(of: ",", with: "") ?? "")
        {
            self.areaValue = CGFloat(area)
            var tempPerimeter = Double(self.perimeter).clean
            tempPerimeter = tempPerimeter.replacingOccurrences(of: ",", with: "")
            //arb
            //let appointment = getCompletedAppointmentsFromDB(appointmentId: appoinmentslData.id ?? 0)
            let customerId = appoinmentslData.customer_id ?? 0
            let appointmentId = appoinmentslData.id ?? 0
            let roomName = roomData.name ?? ""
            let roomType = roomName == "Stairs" ? "Stairs" : "Floor"
            var finalDrawingImage: UIImage
            if let captured = self.capturedConfirmationImage {
                UIGraphicsBeginImageContextWithOptions(captured.size, true, 0.0)
                if let context = UIGraphicsGetCurrentContext() {
                    context.setFillColor(UIColor.black.cgColor)
                    context.fill(CGRect(origin: .zero, size: captured.size))
                    captured.draw(in: CGRect(origin: .zero, size: captured.size))
                }
                finalDrawingImage = UIGraphicsGetImageFromCurrentImageContext() ?? captured
                UIGraphicsEndImageContext()
            } else {
                var contentRect = self.drowingView.bounds
                var boundingBox = CGRect.null
                for pt in self.drowingView.pointPath {
                    let ptRect = CGRect(x: pt.point.x, y: pt.point.y, width: 0, height: 0)
                    boundingBox = boundingBox.isNull ? ptRect : boundingBox.union(ptRect)
                }
                for subview in self.drowingView.subviews {
                    if subview is LineSegmentControlView || subview is SubSqureView || subview is UILabel {
                        boundingBox = boundingBox.isNull ? subview.frame : boundingBox.union(subview.frame)
                        if let sq = subview as? SubSqureView, let tooltip = sq.tooltipView {
                            let tooltipFrame = tooltip.convert(tooltip.bounds, to: self.drowingView)
                            boundingBox = boundingBox.union(tooltipFrame)
                        }
                    }
                }
                
                let padding: CGFloat = 40
                if !boundingBox.isNull {
                    let rawRect = CGRect(x: boundingBox.minX - padding, y: boundingBox.minY - padding, width: boundingBox.width + 2*padding, height: boundingBox.height + 2*padding)
                    contentRect = rawRect.intersection(self.drowingView.bounds)
                    if contentRect.width <= 0 || contentRect.height <= 0 {
                        contentRect = self.drowingView.bounds
                    }
                }
                
                UIGraphicsBeginImageContextWithOptions(contentRect.size, true, 0.0)
                if let context = UIGraphicsGetCurrentContext() {
                    context.setFillColor(UIColor.black.cgColor)
                    context.fill(CGRect(origin: .zero, size: contentRect.size))
                    
                    context.translateBy(x: -contentRect.origin.x, y: -contentRect.origin.y)
                    self.drowingView.layer.render(in: context)
                }
                finalDrawingImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
                UIGraphicsEndImageContext()
            }
            
            if let jpeg = finalDrawingImage.jpegData(compressionQuality: 1.0) {
                let desktopURL = URL(fileURLWithPath: "/Users/bincycaliyar/Desktop/drawing_debug.jpg")
                do {
                    try jpeg.write(to: desktopURL)
                } catch {
                }
            }
            let imageNamewithDate = Date().toString()
            let drawingImageName = "Attachment_\(imageNamewithDate).JPG"
            let drawingImageSavedToFile = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: finalDrawingImage, saveImgName: drawingImageName)
            
            let transDataArray = List<rf_transitionData>()
            transArray.forEach{ transData in
                transDataArray.append(rf_transitionData(transData: transData))
            }
            
//            let completedRoom:rf_completed_room = rf_completed_room()
//            completedRoom.room_id = self.roomData.id ?? 0
//            //completedRoom.ofAppointment = appointment
//            completedRoom.measurement_exist = "true"
//            completedRoom.customer_id = customerId
//            completedRoom.appointment_id = appointmentId
//            completedRoom.transArray = transDataArray
//            completedRoom.room_area = self.areaValue.toString
//            completedRoom.room_perimeter = Float(tempPerimeter) ?? 0
//            completedRoom.room_name = roomName
//            completedRoom.room_type = roomType
//            completedRoom.draw_image_name = drawingImageSavedToFile
            let (isRoomAlreadyExist,room) = self.checkIfRoomExist(appointmentId:appointmentId, roomId: self.roomData.id ?? 0)
            let isCustomRoomExists = self.checkIfCustomRoomExists(appointmentId: appointmentId, roomId: String(self.roomData.id ?? 0))
            var roomUniqueId = ""
            if isRoomAlreadyExist{
                roomUniqueId = room?.first?.id ?? ""
            }
            var partiallyCompletedRoomToUpdate:[String:Any] = ["room_id":self.roomData.id ?? 0,"measurement_exist":"true","customer_id":customerId,"appointment_id":appointmentId,"transArray":transDataArray,"room_area":self.areaValue.toString,"room_perimeter":Float(tempPerimeter) ?? 0,"room_name":roomName ,"room_type":roomType,"draw_image_name":drawingImageSavedToFile,"draw_area_adjusted":self.areaValue.toString]
            if roomUniqueId != ""{
                partiallyCompletedRoomToUpdate["id"] = roomUniqueId
            }
            if isCustomRoomExists
            {
                partiallyCompletedRoomToUpdate["is_custom_room"] = 1
                //partiallyCompletedRoomToUpdate["room_id"] = 0
            }
            //self.deleteRoomFromAppointment(appointmentId: appointmentId,roomId:self.roomData.id ?? 0)
            let next = AboutRoomViewController.initialization()!
            do{
                let realm = try Realm()
                try realm.write{
                    //////////////////
                    if let room = realm.object(ofType: rf_completed_appointment.self, forPrimaryKey: appointmentId)?.rooms.filter("room_id == %d", self.roomData.id ?? 0){
                        let room_attachments = room.first?.room_attachments
                        partiallyCompletedRoomToUpdate["room_attachments"] = room_attachments
                        
                    }
                   
                    realm.create(rf_completed_room.self, value: partiallyCompletedRoomToUpdate, update: .all)
                    
                    ////////////////////
                    
                    next.appoinmentID = self.appoinmentslData.id ?? 0
                    next.roomID = self.roomData.id ?? 0
                    next.roomName = self.roomData.name ?? ""
//                    next.drowingImageID = data ?? 0
                    next.area = self.areaValue
                    next.perimeter = Double(tempPerimeter)!
//                    //
//                    next.value = self.summaryData.attachment_comments ?? ""
//                    next.uploadedImage = self.summaryData.attachments ?? []
//                    next.summaryData = self.summaryData
//                    //
                    
                }
                self.deleteDiscountArrayFromDb() 
                self.navigationController?.pushViewController(next, animated: true)
            }
            catch{
                print(RealmError.writeFailed)
            }
            
            //save room details under appointment
            self.saveCreatedRoomToAppointment(appointmentId: appointmentId,roomId: self.roomData.id ?? 0)
            //
            
            //
//            HttpClientManager.SharedHM.MesurementSubmitMapFn(room_area: "\(self.areaValue.toString)",perimeter:Float(tempPerimeter) ?? 0, attachments: UIImage(view: self.drowingView), imagename: "messurementImage.jpeg", floor_id: "", room: self.roomData, appointment_id: "\(appoinmentslData.id ?? 0)",trasData:transArray) { (result, message, data, value) in
//
//                if(result == "Success")
//                {
//                    let next = AboutRoomViewController.initialization()!
//                    next.appoinmentID = self.appoinmentslData.id ?? 0
//                    next.roomID = self.roomData.id ?? 0
//                    next.roomName = self.roomData.name ?? ""
//                    next.drowingImageID = data ?? 0
//                    next.area = self.areaValue
//                    self.messurementID = data ?? 0
//                    if(value != nil)
//                    {
//                        self.summaryData = value![0]
//                        next.value = self.summaryData.attachment_comments ?? ""
//                        next.uploadedImage = self.summaryData.attachments ?? []
//                        next.summaryData = self.summaryData
//                    }
//                    self.navigationController?.pushViewController(next, animated: true)
//                }
//                else
//                {
//                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
//
//                                        self.messurementUpload()
//                                    }
//                                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//                                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
//                    //self.alert(message ?? AppAlertMsg.serverNotReached, nil)
//                }
//
//            }
        }
        else
        {
            self.alert("Please enter correct value for area", nil)
        }
    }
    
    func DeleteroomMeasurement()
    {
        let data = ["contract_measurement_id":self.messurementID,"operation":"delete"] as [String : Any]
        let parameter = ["token":UserData.init().token ?? "","data":data] as [String : Any]
        HttpClientManager.SharedHM.DeleteRoomMeasurement(parameter: parameter) { (result, errormessage, valuse) in
            if(result == "True")
            {
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                self.alert(errormessage ?? AppAlertMsg.serverNotReached, nil)
            }
        }
    }
    
    override func screenShotBarButtonAction(sender:UIButton)
        {
            self.imagePicker = CaptureImage(presentationController: self, delegate: self)
            self.imagePicker.present(from: sender)
            
        }
        
        func imageUploadScreenShot(_ image:UIImage,_ name:String )
        {
            HttpClientManager.SharedHM.AttachmentScreenShotsFn(image, name) { (success, message, value) in
                if(success ?? "") == "Success"
                {
                  
                    
                    self.alert(message ?? "", nil)
                }
                else if ((success ?? "") == "AuthFailed" || ((success ?? "") == "authfailed"))
                {
                    
                    let yes = UIAlertAction(title: "OK", style:.default) { (_) in
                        
                        self.fourceLogOutbuttonAction()
                    }
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes])
                    
                }
                else
                {
                    let yes = UIAlertAction(title: "Retry", style:.default) { (_) in
                        
                        self.imageUploadScreenShot(image,name)
                    }
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    self.alert((message ?? message) ?? AppAlertMsg.serverNotReached, [yes,no])
                    
                    // self.alert(message ?? AppAlertMsg.serverNotReached, nil)
                }
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
    
    func setupNewUI() {
        // Hide existing unused UI elements from storyboard
        self.scrollView?.isHidden = true
        self.bottomToolView?.isHidden = true
        self.contentView?.isHidden = true
        self.areaLabel?.isHidden = true
        self.tempAreaLabel?.isHidden = true
        self.addView?.isHidden = true
        self.selected_View?.isHidden = true
        
        self.masterView?.backgroundColor = UIColor(red: 35/255.0, green: 43/255.0, blue: 53/255.0, alpha: 1.0)
        self.drowingContentView?.backgroundColor = .clear
        self.view.backgroundColor = UIColor(red: 35/255.0, green: 43/255.0, blue: 53/255.0, alpha: 1.0)
        self.areaTF?.textColor = UIColor().colorFromHexString("#FFFFFF")
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        for subview in self.view.subviews {
            if subview.tag == 9999 || subview is UINavigationBar { 
                subview.isHidden = true
            }
        }
        

        
        // Bottom Toolbar
        self.bottomToolbar = DrawingToolbar()
        self.bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        self.bottomToolbar.delegate = self
        self.view.addSubview(self.bottomToolbar)
        
        self.bottomToolbarWidthConstraint = self.bottomToolbar.widthAnchor.constraint(equalToConstant: 440)
        self.bottomToolbarCenterXConstraint = self.bottomToolbar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        self.bottomToolbarCenterYConstraint = self.bottomToolbar.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        
        NSLayoutConstraint.activate([
            self.bottomToolbarCenterYConstraint,
            self.bottomToolbarCenterXConstraint,
            self.bottomToolbar.heightAnchor.constraint(equalToConstant: 80),
            self.bottomToolbarWidthConstraint
        ])
        
        self.bottomToolbar.onPanGesture = { [weak self] translation, state in
            guard let self = self else { return }
            if state == .began {
                self.view.layoutIfNeeded()
            } else if state == .changed {
                self.bottomToolbarCenterXConstraint.constant += translation.x
                self.bottomToolbarCenterYConstraint.constant += translation.y
                
                if !self.bottomToolbar.isCollapsed {
                    let currentCenter = self.bottomToolbar.center
                    let sw = self.view.bounds.width
                    let sh = self.view.bounds.height
                    
                    let hDx = max(0, 220 - currentCenter.x) + min(0, sw - 220 - currentCenter.x)
                    let hDy = max(0, 40 - currentCenter.y) + min(0, sh - 40 - currentCenter.y)
                    let hCost = abs(hDx) + abs(hDy)
                    
                    let vDx = max(0, 40 - currentCenter.x) + min(0, sw - 40 - currentCenter.x)
                    let vDy = max(0, 220 - currentCenter.y) + min(0, sh - 220 - currentCenter.y)
                    let vCost = abs(vDx) + abs(vDy)
                    
                    UIView.animate(withDuration: 0.15) {
                        if hCost <= vCost {
                            self.bottomToolbar.transform = .identity
                            self.bottomToolbar.setButtonsTransform(.identity)
                        } else {
                            if currentCenter.x < sw / 2 {
                                self.bottomToolbar.transform = CGAffineTransform(rotationAngle: .pi/2)
                                self.bottomToolbar.setButtonsTransform(CGAffineTransform(rotationAngle: -.pi/2))
                            } else {
                                self.bottomToolbar.transform = CGAffineTransform(rotationAngle: -.pi/2)
                                self.bottomToolbar.setButtonsTransform(CGAffineTransform(rotationAngle: .pi/2))
                            }
                        }
                    }
                }
            } else if state == .ended || state == .cancelled {
                if !self.bottomToolbar.isCollapsed {
                    let currentCenter = self.bottomToolbar.center
                    let sw = self.view.bounds.width
                    let sh = self.view.bounds.height
                    
                    let hDx = max(0, 220 - currentCenter.x) + min(0, sw - 220 - currentCenter.x)
                    let hDy = max(0, 40 - currentCenter.y) + min(0, sh - 40 - currentCenter.y)
                    let hCost = abs(hDx) + abs(hDy)
                    
                    let vDx = max(0, 40 - currentCenter.x) + min(0, sw - 40 - currentCenter.x)
                    let vDy = max(0, 220 - currentCenter.y) + min(0, sh - 220 - currentCenter.y)
                    let vCost = abs(vDx) + abs(vDy)
                    
                    if hCost <= vCost {
                        self.bottomToolbarCenterXConstraint.constant += hDx
                        self.bottomToolbarCenterYConstraint.constant += hDy
                        UIView.animate(withDuration: 0.3) {
                            self.bottomToolbar.transform = .identity
                            self.bottomToolbar.setButtonsTransform(.identity)
                            self.view.layoutIfNeeded()
                        }
                    } else {
                        self.bottomToolbarCenterXConstraint.constant += vDx
                        self.bottomToolbarCenterYConstraint.constant += vDy
                        UIView.animate(withDuration: 0.3) {
                            if currentCenter.x < sw / 2 {
                                self.bottomToolbar.transform = CGAffineTransform(rotationAngle: .pi/2)
                                self.bottomToolbar.setButtonsTransform(CGAffineTransform(rotationAngle: -.pi/2))
                            } else {
                                self.bottomToolbar.transform = CGAffineTransform(rotationAngle: -.pi/2)
                                self.bottomToolbar.setButtonsTransform(CGAffineTransform(rotationAngle: .pi/2))
                            }
                            self.view.layoutIfNeeded()
                        }
                    }
                } else {
                    let minX: CGFloat = 40
                    let maxX: CGFloat = self.view.bounds.width - 40
                    let minY: CGFloat = 40
                    let maxY: CGFloat = self.view.bounds.height - 40
                    
                    var currentX = self.bottomToolbar.center.x
                    var currentY = self.bottomToolbar.center.y
                    
                    if currentX < minX { currentX = minX }
                    if currentX > maxX { currentX = maxX }
                    if currentY < minY { currentY = minY }
                    if currentY > maxY { currentY = maxY }
                    
                    if currentX != self.bottomToolbar.center.x || currentY != self.bottomToolbar.center.y {
                        let diffX = currentX - self.bottomToolbar.center.x
                        let diffY = currentY - self.bottomToolbar.center.y
                        self.bottomToolbarCenterXConstraint.constant += diffX
                        self.bottomToolbarCenterYConstraint.constant += diffY
                        UIView.animate(withDuration: 0.3) {
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
        }
        
        self.bottomToolbar.onToggleCollapse = { [weak self] isCollapsed in
            guard let self = self else { return }
            
            if !isCollapsed {
                let currentCenter = self.bottomToolbar.center
                let sw = self.view.bounds.width
                let sh = self.view.bounds.height
                
                let hDx = max(0, 220 - currentCenter.x) + min(0, sw - 220 - currentCenter.x)
                let hDy = max(0, 40 - currentCenter.y) + min(0, sh - 40 - currentCenter.y)
                let hCost = abs(hDx) + abs(hDy)
                
                let vDx = max(0, 40 - currentCenter.x) + min(0, sw - 40 - currentCenter.x)
                let vDy = max(0, 220 - currentCenter.y) + min(0, sh - 220 - currentCenter.y)
                let vCost = abs(vDx) + abs(vDy)
                
                if hCost <= vCost {
                    self.bottomToolbarCenterXConstraint.constant += hDx
                    self.bottomToolbarCenterYConstraint.constant += hDy
                    self.bottomToolbar.transform = .identity
                    self.bottomToolbar.setButtonsTransform(.identity)
                } else {
                    self.bottomToolbarCenterXConstraint.constant += vDx
                    self.bottomToolbarCenterYConstraint.constant += vDy
                    if currentCenter.x < sw / 2 {
                        self.bottomToolbar.transform = CGAffineTransform(rotationAngle: .pi/2)
                        self.bottomToolbar.setButtonsTransform(CGAffineTransform(rotationAngle: -.pi/2))
                    } else {
                        self.bottomToolbar.transform = CGAffineTransform(rotationAngle: -.pi/2)
                        self.bottomToolbar.setButtonsTransform(CGAffineTransform(rotationAngle: .pi/2))
                    }
                }
            }
            
            self.bottomToolbarWidthConstraint.constant = isCollapsed ? 80 : 440
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        self.bottomToolbar.updateActive(self.bottomToolbar.verticalLineBtn)
        self.updateUndoRedoButtonsState()
        
        // Floating Side Panel
        sidePanel = FloatingSidePanelView()
        sidePanel.translatesAutoresizingMaskIntoConstraints = false
        sidePanel.delegate = self
        self.view.addSubview(sidePanel)
        
        NSLayoutConstraint.activate([
            sidePanel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100),
            sidePanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            sidePanel.heightAnchor.constraint(equalToConstant: 240),
            sidePanel.widthAnchor.constraint(equalToConstant: 280) // Initial width when closed is handled by the view itself
        ])
    }
}
class OpeningCustomObject:NSObject
{
     var name:String
    var color:UIColor
    init(name: String, color: UIColor) {
       self.name = name
       self.color = color
   }
}
extension CustomShapeLineViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?,imageName:String?)
    {
        guard let image = image
                
        else
        {
            return
        }
        let imageNameStr = Date().toString()
        let name = "Snapshot" + String(imageNameStr) + ".JPG"
        let snapShotImageName = ImageSaveToDirectory.SharedImage.saveImageDocumentDirectory(rfImage: image, saveImgName: name)
        let appointmentId = AppointmentData().appointment_id ?? 0
        _ = self.saveSnapshotImage(savedImageName: snapShotImageName, appointmentId: appointmentId)
        //self.imageUploadScreenShot(image,imageName ?? name)
        
    }
}


protocol DrawingToolbarDelegate: AnyObject {
    func didTapUndo()
    func didTapRedo()
    func didTapLineMode()
    func didTapCurveMode()
    func didTapVerticalLineMode()
    func didTapHorizontalLineMode()
    func didTapDimension()
}

class ToolbarIconButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            setNeedsDisplay()
            alpha = isEnabled ? 1.0 : 0.4
        }
    }
    var isToolActive: Bool = false {
        didSet { setNeedsDisplay() }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        if isToolActive {
            let bgPath = UIBezierPath(ovalIn: rect)
            UIColor(red: 70/255.0, green: 76/255.0, blue: 85/255.0, alpha: 1.0).setFill()
            bgPath.fill()
        }
        let color = isEnabled ? UIColor.white : UIColor.white.withAlphaComponent(0.3)
        color.setStroke()
        color.setFill()
    }
}

class UndoButton: ToolbarIconButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "custom_undo"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        // Image renders automatically
    }
}

class RedoButton: ToolbarIconButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "custom_redo"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        // Image renders automatically
    }
}

class VerticalLineModeButton: ToolbarIconButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let p1 = CGPoint(x: rect.width*0.5, y: rect.height*0.85)
        let p2 = CGPoint(x: rect.width*0.5, y: rect.height*0.15)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.lineWidth = 2
        path.stroke()
        
        UIBezierPath(arcCenter: p1, radius: 3, startAngle: 0, endAngle: .pi*2, clockwise: true).fill()
        UIBezierPath(arcCenter: p2, radius: 3, startAngle: 0, endAngle: .pi*2, clockwise: true).fill()
    }
}

class HorizontalLineModeButton: ToolbarIconButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let p1 = CGPoint(x: rect.width*0.15, y: rect.height*0.5)
        let p2 = CGPoint(x: rect.width*0.85, y: rect.height*0.5)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.lineWidth = 2
        path.stroke()
        
        UIBezierPath(arcCenter: p1, radius: 3, startAngle: 0, endAngle: .pi*2, clockwise: true).fill()
        UIBezierPath(arcCenter: p2, radius: 3, startAngle: 0, endAngle: .pi*2, clockwise: true).fill()
    }
}

class LineModeButton: ToolbarIconButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let p1 = CGPoint(x: rect.width*0.25, y: rect.height*0.75)
        let p2 = CGPoint(x: rect.width*0.75, y: rect.height*0.25)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.lineWidth = 2
        path.stroke()
        
        UIBezierPath(arcCenter: p1, radius: 3, startAngle: 0, endAngle: .pi*2, clockwise: true).fill()
        UIBezierPath(arcCenter: p2, radius: 3, startAngle: 0, endAngle: .pi*2, clockwise: true).fill()
    }
}

class CurveModeButton: ToolbarIconButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "curveWall"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

class DimensionButton: ToolbarIconButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "openingIcon"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

class DrawingToolbar: UIView {
    weak var delegate: DrawingToolbarDelegate?
    
    let undoBtn = UndoButton()
    let redoBtn = RedoButton()
    let verticalLineBtn = VerticalLineModeButton()
    let horizontalLineBtn = HorizontalLineModeButton()
    let lineBtn = LineModeButton()
    let curveBtn = CurveModeButton()
    let dimBtn = DimensionButton()
    let notchButton = UIButton()
    let overlayBtn = UIButton()
    
    private let stackView = UIStackView()
    private let shapeLayer = CAShapeLayer()
    private let handleLayer = CAShapeLayer()
    
    var isCollapsed: Bool = false
    var activeBtn: ToolbarIconButton?
    var onToggleCollapse: ((Bool) -> Void)?
    var onPanGesture: ((CGPoint, UIGestureRecognizer.State) -> Void)?
    
    private var panGesture: UIPanGestureRecognizer!
    private let divider = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        undoBtn.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        redoBtn.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
        verticalLineBtn.addTarget(self, action: #selector(verticalLineTapped), for: .touchUpInside)
        horizontalLineBtn.addTarget(self, action: #selector(horizontalLineTapped), for: .touchUpInside)
        lineBtn.addTarget(self, action: #selector(lineTapped), for: .touchUpInside)
        curveBtn.addTarget(self, action: #selector(curveTapped), for: .touchUpInside)
        dimBtn.addTarget(self, action: #selector(dimTapped), for: .touchUpInside)
        
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let buttons = [undoBtn, redoBtn, verticalLineBtn, horizontalLineBtn, lineBtn, curveBtn, dimBtn]
        for btn in buttons {
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        stackView.addArrangedSubview(undoBtn)
        stackView.addArrangedSubview(redoBtn)
        stackView.addArrangedSubview(divider)
        stackView.addArrangedSubview(verticalLineBtn)
        stackView.addArrangedSubview(horizontalLineBtn)
        stackView.addArrangedSubview(lineBtn)
        stackView.addArrangedSubview(curveBtn)
        stackView.addArrangedSubview(dimBtn)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        notchButton.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(notchButton, belowSubview: stackView)
        notchButton.addTarget(self, action: #selector(notchTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            notchButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            notchButton.topAnchor.constraint(equalTo: topAnchor),
            notchButton.widthAnchor.constraint(equalToConstant: 40),
            notchButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
        
        overlayBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayBtn)
        NSLayoutConstraint.activate([
            overlayBtn.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayBtn.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayBtn.topAnchor.constraint(equalTo: topAnchor),
            overlayBtn.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        overlayBtn.addTarget(self, action: #selector(notchTapped), for: .touchUpInside)
        overlayBtn.isHidden = true
        layer.insertSublayer(shapeLayer, at: 0)
        shapeLayer.fillColor = UIColor(red: 40/255.0, green: 45/255.0, blue: 52/255.0, alpha: 1.0).cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.4
        shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
        shapeLayer.shadowRadius = 8
        
        layer.addSublayer(handleLayer)
        handleLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
        handleLayer.lineWidth = 3
        handleLayer.lineCap = .round
    }
    
    @objc func notchTapped() {
        isCollapsed.toggle()
        overlayBtn.isHidden = !isCollapsed
        
        UIView.animate(withDuration: 0.3) {
            if self.isCollapsed {
                for view in self.stackView.arrangedSubviews {
                    if let btn = view as? ToolbarIconButton {
                        btn.isHidden = (btn != self.activeBtn)
                    } else if view == self.undoBtn || view == self.redoBtn || view == self.divider {
                        view.isHidden = true
                    }
                }
            } else {
                for view in self.stackView.arrangedSubviews {
                    view.isHidden = false
                }
            }
            self.layoutIfNeeded()
        }
        
        onToggleCollapse?(isCollapsed)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }
        let translation = gesture.translation(in: superview)
        
        onPanGesture?(translation, gesture.state)
        
        gesture.setTranslation(.zero, in: superview)
    }
    
    func setButtonsTransform(_ transform: CGAffineTransform) {
        for view in self.stackView.arrangedSubviews {
            if let btn = view as? ToolbarIconButton {
                btn.transform = transform
            } else if view == self.undoBtn || view == self.redoBtn {
                view.transform = transform
            }
        }
    }
    
    @objc func undoTapped() { delegate?.didTapUndo() }
    @objc func redoTapped() { delegate?.didTapRedo() }
    @objc func verticalLineTapped() { delegate?.didTapVerticalLineMode() }
    @objc func horizontalLineTapped() { delegate?.didTapHorizontalLineMode() }
    @objc func lineTapped() { delegate?.didTapLineMode() }
    @objc func curveTapped() { delegate?.didTapCurveMode() }
    @objc func dimTapped() { delegate?.didTapDimension() }
    
    func updateActive(_ activeBtn: ToolbarIconButton) {
        self.activeBtn = activeBtn
        for btn in [verticalLineBtn, horizontalLineBtn, lineBtn, curveBtn, dimBtn] {
            btn.isToolActive = (btn == activeBtn)
        }
        if isCollapsed {
            for view in self.stackView.arrangedSubviews {
                if let btn = view as? ToolbarIconButton {
                    btn.isHidden = (btn != self.activeBtn)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let pillHeight: CGFloat = 60
        let bumpSize: CGFloat = 40
        let bumpHeight: CGFloat = 20
        
        let pillRect = CGRect(x: 0, y: bumpHeight, width: bounds.width, height: pillHeight)
        let bumpRect = CGRect(x: bounds.width/2 - bumpSize/2, y: 0, width: bumpSize, height: bumpSize)
        
        let path = UIBezierPath(roundedRect: pillRect, cornerRadius: pillHeight/2)
        path.append(UIBezierPath(ovalIn: bumpRect))
        shapeLayer.path = path.cgPath
        
        let handlePath = UIBezierPath()
        handlePath.move(to: CGPoint(x: bounds.width/2 - 12, y: 12))
        handlePath.addLine(to: CGPoint(x: bounds.width/2 + 12, y: 12))
        handleLayer.path = handlePath.cgPath
    }
}

extension CustomShapeLineViewController: DrawingToolbarDelegate {
    func didTapUndo() {
        self.undoButtonAction(self)
    }
    func didTapRedo() {
        if !(drowingView.isConfirmed) {
            drowingView.redoLastLine()
        }
    }
    func didTapLineMode() {
        drowingView.currentDrawingMode = .line
        self.bottomToolbar.updateActive(self.bottomToolbar.lineBtn)
    }
    func didTapCurveMode() {
        drowingView.currentDrawingMode = .curve
        self.bottomToolbar.updateActive(self.bottomToolbar.curveBtn)
    }
    func didTapVerticalLineMode() {
        if drowingView.pointPath.count >= 2 {
            let lastPoint = drowingView.pointPath.last!.point
            let secondLastPoint = drowingView.pointPath[drowingView.pointPath.count - 2].point
            if abs(lastPoint.x - secondLastPoint.x) < 0.1 {
                self.alert("Cannot draw consecutive vertical lines", nil)
                return
            }
        }
        drowingView.currentDrawingMode = .vertical
        self.bottomToolbar.updateActive(self.bottomToolbar.verticalLineBtn)
    }
    func didTapHorizontalLineMode() {
        if drowingView.pointPath.count >= 2 {
            let lastPoint = drowingView.pointPath.last!.point
            let secondLastPoint = drowingView.pointPath[drowingView.pointPath.count - 2].point
            if abs(lastPoint.y - secondLastPoint.y) < 0.1 {
                self.alert("Cannot draw consecutive horizontal lines", nil)
                return
            }
        }
        drowingView.currentDrawingMode = .horizontal
        self.bottomToolbar.updateActive(self.bottomToolbar.horizontalLineBtn)
    }
    func didTapDimension() {
        if !drowingView.isClosed {
            self.alert("Please close the drawing before adding openings", nil)
            return
        }
        self.bottomToolbar.updateActive(self.bottomToolbar.dimBtn)
        // Dismiss if already showing
        self.dismissCustomPopup()
        
        // Create dimmer view
        let dimmer = UIView()
        dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(dimmer)
        self.popupDimmerView = dimmer
        
        NSLayoutConstraint.activate([
            dimmer.topAnchor.constraint(equalTo: self.view.topAnchor),
            dimmer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimmer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dimmer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // Add tap gesture to dismiss dimmer
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCustomPopup))
        dimmer.addGestureRecognizer(tap)
        
        // Create popup view
        let popup = AddOpeningPopupView(viewController: self)
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)
        self.activeCustomPopup = popup
        
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 340)
        ])
        
        popup.onCancel = { [weak self] in
            self?.dismissCustomPopup()
        }
        
        self.view.bringSubviewToFront(popup)
        
        // Animate appearance
        popup.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        popup.alpha = 0.0
        dimmer.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            popup.transform = .identity
            popup.alpha = 1.0
            dimmer.alpha = 1.0
        }, completion: nil)
    }
    
    @objc func dismissCustomPopup() {
        guard let popup = self.activeCustomPopup, let dimmer = self.popupDimmerView else { return }
        
        if popup.editIndex != nil {
            popup.applyEdits()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            popup.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            popup.alpha = 0.0
            dimmer.alpha = 0.0
        }) { _ in
            popup.removeFromSuperview()
            dimmer.removeFromSuperview()
        }
    }
    
    func getAllAvailableRoomNames() -> [String] {
        let appID = self.appoinmentslData?.id ?? AppointmentData().appointment_id ?? 0
        let masterRooms = self.getMasterRoomFromDB()
        let customRooms = self.getcustomRoomNameByApt(appointmentId: appID)
        
        var allRooms = customRooms
        allRooms.append(contentsOf: masterRooms)
        
        var uniqueNames: [String] = []
        let currentRoomName = self.roomData?.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        for room in allRooms {
            if let name = room.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
                if name != currentRoomName && !uniqueNames.contains(name) {
                    uniqueNames.append(name)
                }
            }
        }
        return uniqueNames
    }
}

@MainActor
protocol FloatingSidePanelDelegate: AnyObject {
    func didTapScaleDropdown(sender: UIButton)
    func didTapAreaMinus()
    func didTapAreaPlus()
    func didEditAreaValue(_ textField: UITextField)
}

class ScaleDropdownButton: UIButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.width - 20, y: rect.height/2 - 2))
        path.addLine(to: CGPoint(x: rect.width - 15, y: rect.height/2 + 3))
        path.addLine(to: CGPoint(x: rect.width - 10, y: rect.height/2 - 2))
        UIColor.lightGray.setStroke()
        path.lineWidth = 1.5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
    }
}

class FloatingSidePanelView: UIView {
    weak var delegate: FloatingSidePanelDelegate?
    
    private let containerView = UIView()
    private let handleView = UIImageView()
    
    let scaleDropdownBtn = ScaleDropdownButton(type: .custom)
    let scaleLabel = UILabel()
    let scaleSub = UILabel()
    let areaValueLabel = UITextField()
    let minusBtn = UIButton(type: .custom)
    let plusBtn = UIButton(type: .custom)
    
    var isDrawerOpen = true {
        didSet {
            updateDrawerPosition()
            handleView.transform = isDrawerOpen ? .identity : CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    private var containerTrailingConstraint: NSLayoutConstraint!
    private var handleTrailingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        containerView.backgroundColor = UIColor().colorFromHexString("#2D343D")
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 10
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        addSubview(containerView)
        
        handleView.image = UIImage(named: "drawer_handle")
        handleView.contentMode = .scaleToFill
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.isUserInteractionEnabled = true
        handleView.transform = isDrawerOpen ? .identity : CGAffineTransform(scaleX: -1, y: 1)
        addSubview(handleView)
        
        let handleTap = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        handleView.addGestureRecognizer(handleTap)
        
        let topBox = UIView()
        topBox.backgroundColor = UIColor().colorFromHexString("#252C35")
        topBox.layer.cornerRadius = 10
        topBox.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topBox)
        
        let scaleTitle = UILabel()
        scaleTitle.text = "Graph Scale:"
        scaleTitle.font = UIFont(name: "Avenir-Heavy", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        scaleTitle.textColor = UIColor().colorFromHexString("#A7B0BA")
        scaleTitle.translatesAutoresizingMaskIntoConstraints = false
        scaleTitle.adjustsFontSizeToFitWidth = true
        scaleTitle.minimumScaleFactor = 0.5
        topBox.addSubview(scaleTitle)
        
        scaleSub.text = "Scale 1 Unit = 1 Ft."
        scaleSub.font = UIFont(name: "Avenir-Roman", size: 14) ?? UIFont.systemFont(ofSize: 14)
        scaleSub.textColor = UIColor().colorFromHexString("#A7B0BA")
        scaleSub.translatesAutoresizingMaskIntoConstraints = false
        scaleSub.adjustsFontSizeToFitWidth = true
        scaleSub.minimumScaleFactor = 0.5
        topBox.addSubview(scaleSub)
        
        scaleDropdownBtn.setTitle("1x", for: .normal)
        scaleDropdownBtn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        scaleDropdownBtn.setTitleColor(UIColor().colorFromHexString("#FFFFFF"), for: .normal)
        scaleDropdownBtn.layer.cornerRadius = 8
        scaleDropdownBtn.layer.borderWidth = 1
        scaleDropdownBtn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        scaleDropdownBtn.backgroundColor = UIColor().colorFromHexString("#58647133")
        scaleDropdownBtn.translatesAutoresizingMaskIntoConstraints = false
        scaleDropdownBtn.addTarget(self, action: #selector(scaleBtnTapped(_:)), for: .touchUpInside)
        scaleDropdownBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        topBox.addSubview(scaleDropdownBtn)
        
        let bottomBox = UIView()
        bottomBox.backgroundColor = UIColor().colorFromHexString("#252C35")
        bottomBox.layer.cornerRadius = 10
        bottomBox.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bottomBox)
        
        let areaTitle = UILabel()
        areaTitle.text = "Estimated Area in Sq.Ft."
        areaTitle.font = UIFont(name: "Avenir-Heavy", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        areaTitle.textColor = UIColor().colorFromHexString("#A7B0BA")
        areaTitle.translatesAutoresizingMaskIntoConstraints = false
        bottomBox.addSubview(areaTitle)
        
        minusBtn.setTitle("−", for: .normal)
        minusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        minusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        minusBtn.layer.cornerRadius = 20
        minusBtn.translatesAutoresizingMaskIntoConstraints = false
        minusBtn.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        bottomBox.addSubview(minusBtn)
        
        plusBtn.setTitle("+", for: .normal)
        plusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        plusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        plusBtn.layer.cornerRadius = 20
        plusBtn.translatesAutoresizingMaskIntoConstraints = false
        plusBtn.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        bottomBox.addSubview(plusBtn)
        
        areaValueLabel.text = "0"
        areaValueLabel.textAlignment = .center
        areaValueLabel.font = UIFont(name: "Avenir-Roman", size: 14) ?? UIFont.systemFont(ofSize: 14)
        areaValueLabel.textColor = UIColor().colorFromHexString("#FFFFFF")
        areaValueLabel.layer.borderWidth = 1
        areaValueLabel.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        areaValueLabel.layer.cornerRadius = 8
        areaValueLabel.layer.masksToBounds = true
        areaValueLabel.backgroundColor = UIColor().colorFromHexString("#58647133")
        areaValueLabel.keyboardType = .decimalPad
        areaValueLabel.translatesAutoresizingMaskIntoConstraints = false
        areaValueLabel.addTarget(self, action: #selector(areaValueChanged(_:)), for: .editingDidEnd)
        bottomBox.addSubview(areaValueLabel)
        
        containerTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        handleTrailingConstraint = handleView.trailingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: isDrawerOpen ? 22 : 0)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerTrailingConstraint,
            
            handleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            handleTrailingConstraint,
            handleView.widthAnchor.constraint(equalToConstant: 22),
            handleView.heightAnchor.constraint(equalToConstant: 161),
            
            topBox.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            topBox.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 37),
            topBox.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            topBox.heightAnchor.constraint(equalToConstant: 80),
            
            scaleTitle.topAnchor.constraint(equalTo: topBox.topAnchor, constant: 15),
            scaleTitle.leadingAnchor.constraint(equalTo: topBox.leadingAnchor, constant: 15),
            scaleTitle.trailingAnchor.constraint(lessThanOrEqualTo: scaleDropdownBtn.leadingAnchor, constant: -5),
            
            scaleSub.topAnchor.constraint(equalTo: scaleTitle.bottomAnchor, constant: 5),
            scaleSub.leadingAnchor.constraint(equalTo: topBox.leadingAnchor, constant: 15),
            scaleSub.trailingAnchor.constraint(lessThanOrEqualTo: scaleDropdownBtn.leadingAnchor, constant: -5),
            
            scaleDropdownBtn.centerYAnchor.constraint(equalTo: topBox.centerYAnchor),
            scaleDropdownBtn.trailingAnchor.constraint(equalTo: topBox.trailingAnchor, constant: -15),
            scaleDropdownBtn.widthAnchor.constraint(equalToConstant: 70),
            scaleDropdownBtn.heightAnchor.constraint(equalToConstant: 35),
            
            bottomBox.topAnchor.constraint(equalTo: topBox.bottomAnchor, constant: 15),
            bottomBox.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 37),
            bottomBox.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            bottomBox.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            
            areaTitle.topAnchor.constraint(equalTo: bottomBox.topAnchor, constant: 15),
            areaTitle.leadingAnchor.constraint(equalTo: bottomBox.leadingAnchor, constant: 15),
            
            minusBtn.leadingAnchor.constraint(equalTo: bottomBox.leadingAnchor, constant: 15),
            minusBtn.bottomAnchor.constraint(equalTo: bottomBox.bottomAnchor, constant: -15),
            minusBtn.widthAnchor.constraint(equalToConstant: 40),
            minusBtn.heightAnchor.constraint(equalToConstant: 40),
            
            plusBtn.trailingAnchor.constraint(equalTo: bottomBox.trailingAnchor, constant: -15),
            plusBtn.bottomAnchor.constraint(equalTo: bottomBox.bottomAnchor, constant: -15),
            plusBtn.widthAnchor.constraint(equalToConstant: 40),
            plusBtn.heightAnchor.constraint(equalToConstant: 40),
            
            areaValueLabel.centerYAnchor.constraint(equalTo: minusBtn.centerYAnchor),
            areaValueLabel.leadingAnchor.constraint(equalTo: minusBtn.trailingAnchor, constant: 10),
            areaValueLabel.trailingAnchor.constraint(equalTo: plusBtn.leadingAnchor, constant: -10),
            areaValueLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Default to disabled until room is closed
        setAreaControlsEnabled(false)
    }
    
    func setAreaControlsEnabled(_ enabled: Bool) {
        areaValueLabel.isEnabled = enabled
        areaValueLabel.alpha = enabled ? 1.0 : 0.5
        minusBtn.isEnabled = enabled
        minusBtn.alpha = enabled ? 1.0 : 0.5
        plusBtn.isEnabled = enabled
        plusBtn.alpha = enabled ? 1.0 : 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 { return nil }
        
        let convertedPoint = handleView.convert(point, from: self)
        if handleView.bounds.contains(convertedPoint) {
            return handleView
        }
        
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        return hitView
    }
    
    @objc func handleTapped() {
        isDrawerOpen.toggle()
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func updateDrawerPosition() {
        containerTrailingConstraint.constant = isDrawerOpen ? 0 : 280
        handleTrailingConstraint.constant = isDrawerOpen ? 22 : 0
        setNeedsLayout()
    }
    
    @objc func scaleBtnTapped(_ sender: UIButton) {
        delegate?.didTapScaleDropdown(sender: sender)
    }
    
    @objc func minusTapped() { delegate?.didTapAreaMinus() }
    @objc func plusTapped() { delegate?.didTapAreaPlus() }
    
    @objc func areaValueChanged(_ sender: UITextField) {
        delegate?.didEditAreaValue(sender)
    }
}

extension CustomShapeLineViewController: FloatingSidePanelDelegate {
    func didTapScaleDropdown(sender: UIButton) {
        self.graphMoodButtonAction(sender)
    }
    
    func didTapAreaMinus() {
        self.areaMinusButtonAction(UIButton())
    }
    
    func didTapAreaPlus() {
        self.areaPluseButtonAction(UIButton())
    }
    
    func didEditAreaValue(_ textField: UITextField) {
        self.areaTFDidEndAction(textField)
    }
}

class DropdownSelectButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "Avenir-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15)
        contentHorizontalAlignment = .left
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 35)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        let size: CGFloat = 5
        let centerX = rect.width - 20
        let centerY = rect.height / 2
        path.move(to: CGPoint(x: centerX - size, y: centerY - size/2))
        path.addLine(to: CGPoint(x: centerX, y: centerY + size/2))
        path.addLine(to: CGPoint(x: centerX + size, y: centerY - size/2))
        
        UIColor.white.withAlphaComponent(0.6).setStroke()
        path.lineWidth = 1.5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
    }
}

class OpeningTypeButton: UIButton {
    let isVerticalStyle: Bool
    
    var isToolActive: Bool = false {
        didSet {
            backgroundColor = isToolActive ? UIColor(red: 25/255, green: 28/255, blue: 33/255, alpha: 1.0) : .clear
            layer.borderColor = isToolActive ? UIColor.clear.cgColor : UIColor.lightGray.withAlphaComponent(0.3).cgColor
            setNeedsDisplay()
        }
    }
    
    init(isVertical: Bool) {
        self.isVerticalStyle = isVertical
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        if isVerticalStyle {
            // Draw a vertical dash block representation
            path.move(to: CGPoint(x: rect.width * 0.45, y: rect.height * 0.25))
            path.addLine(to: CGPoint(x: rect.width * 0.45, y: rect.height * 0.75))
            path.move(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.25))
            path.addLine(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.75))
            path.lineWidth = 2.5
            path.setLineDash([3, 3], count: 2, phase: 0)
        } else {
            // Draw a horizontal dash block representation
            path.move(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.45))
            path.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.45))
            path.move(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.55))
            path.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.55))
            path.lineWidth = 2.5
            path.setLineDash([3, 3], count: 2, phase: 0)
        }
        UIColor.white.setStroke()
        path.stroke()
    }
}

class AddOpeningPopupView: UIView, UITextFieldDelegate {
    weak var viewController: CustomShapeLineViewController?
    
    // Background card view (glassmorphism/dark card)
    let cardView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    // Content stack view
    let mainStack = UIStackView()
    
    // Rows
    // 1. Opening Type Row
    let typeRow = UIStackView()
    let typeLabel = UILabel()
    let typeToggleStack = UIStackView()
    let verticalBtn = OpeningTypeButton(isVertical: true)
    let horizontalBtn = OpeningTypeButton(isVertical: false)
    
    // 2. Opening Name Row
    let nameStack = UIStackView()
    let nameLabel = UILabel()
    let nameDropdownBtn = DropdownSelectButton()
    
    // 3. Opening to Row
    let toStack = UIStackView()
    let toLabel = UILabel()
    let toDropdownBtn = DropdownSelectButton()
    
    // 4. Width Row
    let widthRow = UIStackView()
    let widthLabel = UILabel()
    let widthStepperStack = UIStackView()
    let minusBtn = UIButton(type: .custom)
    let widthTF = UITextField()
    let plusBtn = UIButton(type: .custom)
    let widthUnitLabel = UILabel()
    
    // 5. Height Row
    let heightRow = UIStackView()
    let heightLabel = UILabel()
    let heightDropdownBtn = DropdownSelectButton()
    let heightUnitLabel = UILabel()
    
    // 6. Add button
    let addBtn = UIButton(type: .custom)
    
    var isVertical: Bool = true
    var selectedOpeningIndex: Int = 0
    var selectedRoomName: String = ""
    var selectedHeight: String = ""
    
    var availableRoomNames: [String] = []
    var onCancel: (() -> Void)?
    var editIndex: Int?
    
    init(viewController: CustomShapeLineViewController, editIndex: Int? = nil) {
        self.viewController = viewController
        self.editIndex = editIndex
        super.init(frame: .zero)
        setup()
        
        if let idx = editIndex {
            populateForEdit(index: idx)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        // Blur card configuration
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 20
        cardView.clipsToBounds = true
        // Add a subtle border
        cardView.contentView.backgroundColor = UIColor().colorFromHexString("#586471B2")
        cardView.contentView.layer.borderColor = UIColor().colorFromHexString("#6B7987").cgColor
        cardView.contentView.layer.borderWidth = 1
        cardView.contentView.layer.cornerRadius = 20
        addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Add drop shadow to self
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 15
        
        // Configure main stack
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: cardView.contentView.topAnchor, constant: 25),
            mainStack.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 25),
            mainStack.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -25),
            mainStack.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor, constant: -25)
        ])
        
        // --- 1. Opening Type Row ---
        typeLabel.text = "Opening Type:"
        typeLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        typeLabel.font = UIFont(name: "Avenir-Heavy", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        
        verticalBtn.isToolActive = true
        verticalBtn.addTarget(self, action: #selector(verticalTypeTapped), for: .touchUpInside)
        horizontalBtn.isToolActive = false
        horizontalBtn.addTarget(self, action: #selector(horizontalTypeTapped), for: .touchUpInside)
        
        typeToggleStack.axis = .horizontal
        typeToggleStack.spacing = 10
        typeToggleStack.addArrangedSubview(verticalBtn)
        typeToggleStack.addArrangedSubview(horizontalBtn)
        
        typeRow.axis = .horizontal
        typeRow.distribution = .equalSpacing
        typeRow.alignment = .center
        typeRow.addArrangedSubview(typeLabel)
        typeRow.addArrangedSubview(typeToggleStack)
        mainStack.addArrangedSubview(typeRow)
        typeRow.isHidden = true // Hide Opening Type as requested
        
        // Constraints for toggle buttons
        NSLayoutConstraint.activate([
            verticalBtn.widthAnchor.constraint(equalToConstant: 45),
            verticalBtn.heightAnchor.constraint(equalToConstant: 40),
            horizontalBtn.widthAnchor.constraint(equalToConstant: 45),
            horizontalBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // --- 2. Opening Name Row ---
        let nameTitleLabel = UILabel()
        nameTitleLabel.text = "Opening Name"
        nameTitleLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        nameTitleLabel.font = UIFont(name: "Avenir-Heavy", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        mainStack.addArrangedSubview(nameTitleLabel)
        
        if let controller = viewController, controller.openingsList.count > 0 {
            nameDropdownBtn.setTitle(controller.openingsList[0].name, for: .normal)
            selectedOpeningIndex = 0
        }
        nameDropdownBtn.addTarget(self, action: #selector(nameDropdownTapped), for: .touchUpInside)
        mainStack.addArrangedSubview(nameDropdownBtn)
        nameDropdownBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        // --- 3. Opening to Row ---
        let toTitleLabel = UILabel()
        toTitleLabel.text = "Opening to"
        toTitleLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        toTitleLabel.font = UIFont(name: "Avenir-Heavy", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        mainStack.addArrangedSubview(toTitleLabel)
        
        if let controller = viewController {
            availableRoomNames = controller.getAllAvailableRoomNames()
        }
        if availableRoomNames.count > 0 {
            toDropdownBtn.setTitle(availableRoomNames[0], for: .normal)
            selectedRoomName = availableRoomNames[0]
        } else {
            toDropdownBtn.setTitle("Select Room", for: .normal)
        }
        toDropdownBtn.addTarget(self, action: #selector(toDropdownTapped), for: .touchUpInside)
        mainStack.addArrangedSubview(toDropdownBtn)
        toDropdownBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        // --- 4. Width Row ---
        widthLabel.text = "Width:"
        widthLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        widthLabel.font = UIFont(name: "Avenir-Heavy", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        widthLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        minusBtn.setTitle("−", for: .normal)
        minusBtn.setTitleColor(.white, for: .normal)
        minusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        minusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        minusBtn.layer.cornerRadius = 18
        minusBtn.addTarget(self, action: #selector(minusWidthTapped), for: .touchUpInside)
        
        widthTF.text = "1.0"
        widthTF.textColor = .white
        widthTF.textAlignment = .center
        widthTF.font = UIFont(name: "Avenir-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15)
        widthTF.keyboardType = .decimalPad
        widthTF.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        widthTF.layer.cornerRadius = 10
        widthTF.layer.masksToBounds = true
        widthTF.layer.borderWidth = 1
        widthTF.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        widthTF.delegate = self
        
        plusBtn.setTitle("+", for: .normal)
        plusBtn.setTitleColor(.white, for: .normal)
        plusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        plusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        plusBtn.layer.cornerRadius = 18
        plusBtn.addTarget(self, action: #selector(plusWidthTapped), for: .touchUpInside)
        
        widthUnitLabel.text = "Ft."
        widthUnitLabel.textColor = .white
        widthUnitLabel.font = UIFont.systemFont(ofSize: 16)
        
        widthStepperStack.axis = .horizontal
        widthStepperStack.spacing = 8
        widthStepperStack.alignment = .center
        widthStepperStack.addArrangedSubview(minusBtn)
        widthStepperStack.addArrangedSubview(widthTF)
        widthStepperStack.addArrangedSubview(plusBtn)
        widthStepperStack.addArrangedSubview(widthUnitLabel)
        
        widthRow.axis = .horizontal
        widthRow.distribution = .fill
        widthRow.alignment = .center
        widthRow.addArrangedSubview(widthLabel)
        widthRow.addArrangedSubview(widthStepperStack)
        mainStack.addArrangedSubview(widthRow)
        
        NSLayoutConstraint.activate([
            minusBtn.widthAnchor.constraint(equalToConstant: 36),
            minusBtn.heightAnchor.constraint(equalToConstant: 36),
            plusBtn.widthAnchor.constraint(equalToConstant: 36),
            plusBtn.heightAnchor.constraint(equalToConstant: 36),
            widthTF.widthAnchor.constraint(equalToConstant: 75),
            widthTF.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // --- 5. Height Row ---
        heightLabel.text = "Height:"
        heightLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        heightLabel.font = UIFont(name: "Avenir-Heavy", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        heightLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        if let controller = viewController, controller.transitionHeightvalue.count > 0 {
            heightDropdownBtn.setTitle(controller.transitionHeightvalue[0], for: .normal)
            selectedHeight = controller.transitionHeightvalue[0]
            if let selectedValue = controller.transitionHeightDropDownArray?.filter({$0.name == self.selectedHeight}) {
                controller.transitionHeightId = selectedValue.first?.transitionHeightId ?? 0
            }
        } else {
            heightDropdownBtn.setTitle("Select Height", for: .normal)
        }
        heightDropdownBtn.addTarget(self, action: #selector(heightDropdownTapped), for: .touchUpInside)
        
        heightUnitLabel.text = "In."
        heightUnitLabel.textColor = .white
        heightUnitLabel.font = UIFont.systemFont(ofSize: 16)
        
        let heightRightStack = UIStackView()
        heightRightStack.axis = .horizontal
        heightRightStack.spacing = 10
        heightRightStack.alignment = .center
        heightRightStack.addArrangedSubview(heightDropdownBtn)
        heightRightStack.addArrangedSubview(heightUnitLabel)
        
        heightRow.axis = .horizontal
        heightRow.distribution = .fill
        heightRow.alignment = .center
        heightRow.addArrangedSubview(heightLabel)
        heightRow.addArrangedSubview(heightRightStack)
        mainStack.addArrangedSubview(heightRow)
        
        NSLayoutConstraint.activate([
            heightDropdownBtn.widthAnchor.constraint(equalToConstant: 163),
            heightDropdownBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // --- Spacer Removed ---
        
        // --- 6. Add Button / Delete Button ---
        if editIndex == nil {
            addBtn.setTitle("Add", for: .normal)
            addBtn.setTitleColor(.white, for: .normal)
            addBtn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15)
            addBtn.backgroundColor = UIColor(red: 41/255.0, green: 37/255.0, blue: 98/255.0, alpha: 1.0)
            addBtn.layer.cornerRadius = 10
            addBtn.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
            mainStack.addArrangedSubview(addBtn)
            addBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            let deleteBtn = UIButton(type: .custom)
            deleteBtn.setImage(UIImage(named: "openingDelete"), for: .normal)
            deleteBtn.backgroundColor = UIColor(red: 43/255.0, green: 48/255.0, blue: 56/255.0, alpha: 1.0)
            deleteBtn.layer.cornerRadius = 25
            deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            
            let deleteWrapper = UIView()
            deleteWrapper.translatesAutoresizingMaskIntoConstraints = false
            deleteWrapper.addSubview(deleteBtn)
            deleteBtn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                deleteBtn.centerXAnchor.constraint(equalTo: deleteWrapper.centerXAnchor),
                deleteBtn.centerYAnchor.constraint(equalTo: deleteWrapper.centerYAnchor),
                deleteBtn.widthAnchor.constraint(equalToConstant: 50),
                deleteBtn.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            mainStack.addArrangedSubview(deleteWrapper)
            deleteWrapper.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        // Add card tap gesture to dismiss keyboard
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        cardView.contentView.addGestureRecognizer(cardTap)
    }
    
    @objc func cardTapped() {
        self.endEditing(true)
    }
    
    @objc func verticalTypeTapped() {
        isVertical = true
        verticalBtn.isToolActive = true
        horizontalBtn.isToolActive = false
    }
    
    @objc func horizontalTypeTapped() {
        isVertical = false
        verticalBtn.isToolActive = false
        horizontalBtn.isToolActive = true
    }
    
    @objc func nameDropdownTapped(_ sender: UIButton) {
        guard let controller = viewController else { return }
        let strings = controller.openingsList.map { $0.name }
        controller.DropDownDefaultfunction(sender, sender.bounds.width, strings, selectedOpeningIndex, delegate: controller, tag: 100)
    }
    
    @objc func toDropdownTapped(_ sender: UIButton) {
        guard let controller = viewController else { return }
        let selectedIdx = availableRoomNames.firstIndex(of: selectedRoomName) ?? -1
        controller.DropDownDefaultfunction(sender, sender.bounds.width, availableRoomNames, selectedIdx, delegate: controller, tag: 101)
    }
    
    @objc func heightDropdownTapped(_ sender: UIButton) {
        guard let controller = viewController else { return }
        let selectedIdx = controller.transitionHeightvalue.firstIndex(of: selectedHeight) ?? -1
        controller.DropDownDefaultfunction(sender, 200, controller.transitionHeightvalue, selectedIdx, delegate: controller, tag: 102)
    }
    
    @objc func minusWidthTapped() {
        self.endEditing(true)
        if let text = widthTF.text, var val = Float(text) {
            val -= 0.5
            if val < 0.5 { val = 0.5 }
            widthTF.text = String(format: "%.1f", Double(val))
        }
    }
    
    @objc func plusWidthTapped() {
        self.endEditing(true)
        if let text = widthTF.text, var val = Float(text) {
            val += 0.5
            if val > 50 { val = 50 }
            widthTF.text = String(format: "%.1f", Double(val))
        }
    }
    
    func updateOpeningName(_ name: String) {
        nameDropdownBtn.setTitle(name, for: .normal)
        if let idx = viewController?.openingsList.firstIndex(where: { $0.name == name }) {
            selectedOpeningIndex = idx
        }
    }
    
    func updateOpeningTo(_ roomName: String) {
        toDropdownBtn.setTitle(roomName, for: .normal)
        selectedRoomName = roomName
    }
    
    func updateHeight(_ heightStr: String) {
        heightDropdownBtn.setTitle(heightStr, for: .normal)
        selectedHeight = heightStr
    }
    
    func populateForEdit(index: Int) {
        guard let controller = viewController, index < controller.drowingView.subSquareView.count else { return }
        let subSquare = controller.drowingView.subSquareView[index]
        
        if subSquare.isVertical {
            verticalTypeTapped()
        } else {
            horizontalTypeTapped()
        }
        
        if let obj = subSquare.object as? OpeningCustomObject {
            let nameParts = obj.name.components(separatedBy: " to ")
            if nameParts.count > 0 {
                updateOpeningName(nameParts[0])
            }
            if nameParts.count > 1 {
                updateOpeningTo(nameParts[1])
            }
        }
        
        let widthVal = subSquare.isVertical ? subSquare.custom_hight : subSquare.custom_width
        widthTF.text = String(format: "%.1f", Double(widthVal))
        
        let h = subSquare.addViewHeight
        updateHeight(h)
    }
    
    @objc func deleteTapped() {
        self.endEditing(true)
        guard let controller = viewController, let idx = editIndex else { return }
        if idx < controller.drowingView.subSquareView.count {
            controller.drowingView.saveState()
            let subSquare = controller.drowingView.subSquareView[idx]
            subSquare.removeFromSuperview()
            controller.drowingView.subSquareView.remove(at: idx)
            for i in 0..<controller.drowingView.subSquareView.count {
                controller.drowingView.subSquareView[i].tag = i
            }
            controller.drowingView.setNeedsDisplay()
            if controller.selectedOpening == subSquare {
                controller.selectedOpening = nil
            }
        }
        onCancel?()
    }
    

    
    @objc func addTapped() {
        self.endEditing(true)
        guard let widthText = widthTF.text, let widthVal = Float(widthText), widthVal > 0 else {
            viewController?.alert("Please enter a valid width", nil)
            return
        }
        
        guard let controller = viewController else { return }
        
        let baseOpening = controller.openingsList[selectedOpeningIndex]
        let combinedName = "\(baseOpening.name) to \(selectedRoomName)"
        let customOpening = OpeningCustomObject(name: combinedName, color: baseOpening.color)
        let heightStr = selectedHeight
        
        let hValue = (!isVertical) ? 1 : CGFloat(widthVal * 100) / 100
        let wValue = (!isVertical) ? CGFloat(widthVal * 100) / 100 : 1
        
        let xCenter = controller.drowingView.buzierpath.bounds.isEmpty ? controller.drowingView.bounds.midX : controller.drowingView.buzierpath.bounds.midX
        let yCenter = controller.drowingView.buzierpath.bounds.isEmpty ? controller.drowingView.bounds.midY : controller.drowingView.buzierpath.bounds.midY
        
        controller.drowingView.add_Sub_Square_View(
            xAsis: xCenter,
            yAxis: yCenter,
            width: wValue,
            hight: hValue,
            delegate: controller,
            isVertical: isVertical,
            objc: customOpening,
            addViewHeight: heightStr,
            transitionheightId: controller.transitionHeightId
        )
        
        onCancel?()
    }
    
    func applyEdits() {
        self.endEditing(true)
        guard let controller = viewController, let idx = editIndex else { return }
        if idx < controller.drowingView.subSquareView.count {
            let subSquare = controller.drowingView.subSquareView[idx]
            
            let baseOpening = controller.openingsList[selectedOpeningIndex]
            let combinedName = "\(baseOpening.name) to \(selectedRoomName)"
            let customOpening = OpeningCustomObject(name: combinedName, color: baseOpening.color)
            
            subSquare.object = customOpening
            subSquare.addViewHeight = selectedHeight
            subSquare.isVertical = isVertical
            
            if let widthText = widthTF.text, let widthVal = Float(widthText), widthVal > 0 {
                if isVertical {
                    subSquare.custom_hight = CGFloat(widthVal)
                    subSquare.custom_width = 1.0
                } else {
                    subSquare.custom_width = CGFloat(widthVal)
                    subSquare.custom_hight = 1.0
                }
                
                subSquare.custom_size_reload()
            }
            
            subSquare.change_color_of_path(customOpening.color)
            subSquare.setNeedsLayout()
            controller.drowingView.setNeedsDisplay()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: ".0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == widthTF {
            if let text = textField.text, let val = Float(text), val > 0 {
                widthTF.text = String(format: "%.1f", Double(val))
            } else {
                widthTF.text = "3.0"
            }
        }
    }
}

extension CustomShapeLineViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.drowingView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        checkRelocateButtonVisibility(scrollView: scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkRelocateButtonVisibility(scrollView: scrollView)
    }
    
    func setupRelocateButton() {
        relocateButton = UIButton(type: .custom)
        relocateButton.setImage(UIImage(named: "relocateDrawing"), for: .normal)
        relocateButton.translatesAutoresizingMaskIntoConstraints = false
        relocateButton.isHidden = true
        relocateButton.addTarget(self, action: #selector(relocateButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(relocateButton)
        
        NSLayoutConstraint.activate([
            relocateButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            relocateButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            relocateButton.widthAnchor.constraint(equalToConstant: 50),
            relocateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func relocateButtonTapped() {
        guard let scrollView = self.canvasScrollView, let drawingView = self.drowingView else { return }
        
        UIView.animate(withDuration: 0.3) {
            scrollView.zoomScale = 1.0
            
            if drawingView.pointPath.count > 0 {
                var minX: CGFloat = .greatestFiniteMagnitude
                var minY: CGFloat = .greatestFiniteMagnitude
                var maxX: CGFloat = -.greatestFiniteMagnitude
                var maxY: CGFloat = -.greatestFiniteMagnitude
                
                for point in drawingView.pointPath {
                    if point.point.x < minX { minX = point.point.x }
                    if point.point.y < minY { minY = point.point.y }
                    if point.point.x > maxX { maxX = point.point.x }
                    if point.point.y > maxY { maxY = point.point.y }
                }
                
                let rectWidth = maxX - minX
                let rectHeight = maxY - minY
                let centerX = minX + rectWidth / 2
                let centerY = minY + rectHeight / 2
                
                let offsetX = centerX - scrollView.bounds.width / 2
                let offsetY = centerY - scrollView.bounds.height / 2
                
                scrollView.contentOffset = CGPoint(x: max(0, min(offsetX, scrollView.contentSize.width - scrollView.bounds.width)),
                                                   y: max(0, min(offsetY, scrollView.contentSize.height - scrollView.bounds.height)))
            } else {
                let offsetX = (scrollView.contentSize.width - scrollView.bounds.width) / 2
                let offsetY = (scrollView.contentSize.height - scrollView.bounds.height) / 2
                scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
            }
            
            self.relocateButton.isHidden = true
        }
    }
    
    func checkRelocateButtonVisibility(scrollView: UIScrollView) {
        guard relocateButton != nil else { return }
        let isZoomNormal = abs(scrollView.zoomScale - 1.0) < 0.05
        if !isZoomNormal {
            relocateButton.isHidden = false
        } else {
            if let drawingView = self.drowingView, drawingView.pointPath.count > 0 {
                var minX: CGFloat = .greatestFiniteMagnitude
                var minY: CGFloat = .greatestFiniteMagnitude
                var maxX: CGFloat = -.greatestFiniteMagnitude
                var maxY: CGFloat = -.greatestFiniteMagnitude
                
                for point in drawingView.pointPath {
                    if point.point.x < minX { minX = point.point.x }
                    if point.point.y < minY { minY = point.point.y }
                    if point.point.x > maxX { maxX = point.point.x }
                    if point.point.y > maxY { maxY = point.point.y }
                }
                
                let drawingRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
                
                if !visibleRect.intersects(drawingRect) {
                    relocateButton.isHidden = false
                } else {
                    relocateButton.isHidden = true
                }
            } else {
                relocateButton.isHidden = true
            }
        }
    }
}
