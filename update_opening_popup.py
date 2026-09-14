import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# Define the new FlowLayoutView and AddOpeningPopupView
new_classes = """
class FlowLayoutView: UIView {
    var spacing: CGFloat = 10
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            if view.isHidden { continue }
            view.sizeToFit()
            let viewWidth = view.bounds.width + 10 // extra padding
            let viewHeight = max(view.bounds.height, 30)
            
            if currentX + viewWidth > bounds.width {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            view.frame = CGRect(x: currentX, y: currentY, width: viewWidth, height: viewHeight)
            currentX += viewWidth + spacing
            rowHeight = max(rowHeight, viewHeight)
        }
        
        if self.frame.height != currentY + rowHeight {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = bounds.width > 0 ? bounds.width : 500
        
        for view in subviews {
            if view.isHidden { continue }
            view.sizeToFit()
            let viewWidth = view.bounds.width + 10
            let viewHeight = max(view.bounds.height, 30)
            
            if currentX + viewWidth > maxWidth {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            currentX += viewWidth + spacing
            rowHeight = max(rowHeight, viewHeight)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: currentY + rowHeight)
    }
}

class AddOpeningPopupView: UIView, UITextFieldDelegate {
    weak var viewController: CustomShapeLineViewController?
    
    let cardView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let mainStack = UIStackView()
    
    // Top Row
    let titleLabel = UILabel()
    let typeLabel = UILabel()
    let typeToggleStack = UIStackView()
    let verticalBtn = OpeningTypeButton(isVertical: true)
    let horizontalBtn = OpeningTypeButton(isVertical: false)
    
    // Inner Box (Name, Width, Height)
    let innerBox = UIView()
    let innerStack = UIStackView()
    
    let nameLabel = UILabel()
    let nameDropdownBtn = DropdownSelectButton()
    
    let widthLabel = UILabel()
    let minusBtn = UIButton(type: .custom)
    let widthTF = UITextField()
    let plusBtn = UIButton(type: .custom)
    
    let heightLabel = UILabel()
    let heightDropdownBtn = DropdownSelectButton()
    let heightUnitLabel = UILabel()
    
    // Room Selector
    let toLabel = UILabel()
    let roomsFlowView = FlowLayoutView()
    let roomsScrollView = UIScrollView()
    var roomButtons: [UIButton] = []
    
    // Bottom Buttons
    let cancelBtn = UIButton(type: .custom)
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
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 20
        cardView.clipsToBounds = true
        cardView.contentView.backgroundColor = UIColor().colorFromHexString("#222831")
        cardView.contentView.layer.borderColor = UIColor().colorFromHexString("#3A4553").cgColor
        cardView.contentView.layer.borderWidth = 1
        cardView.contentView.layer.cornerRadius = 20
        addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: cardView.contentView.topAnchor, constant: 25),
            mainStack.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 25),
            mainStack.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -25),
            mainStack.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor, constant: -25)
        ])
        
        // --- 1. Top Row ---
        let topRowStack = UIStackView()
        topRowStack.axis = .horizontal
        topRowStack.distribution = .equalSpacing
        
        titleLabel.text = editIndex == nil ? "Add Opening" : "Edit Opening"
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        
        let typeContainer = UIStackView()
        typeContainer.axis = .horizontal
        typeContainer.spacing = 15
        typeContainer.alignment = .center
        
        typeLabel.text = "Opening Type:"
        typeLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        typeLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        
        verticalBtn.isToolActive = true
        verticalBtn.addTarget(self, action: #selector(verticalTypeTapped), for: .touchUpInside)
        horizontalBtn.isToolActive = false
        horizontalBtn.addTarget(self, action: #selector(horizontalTypeTapped), for: .touchUpInside)
        
        typeToggleStack.axis = .horizontal
        typeToggleStack.spacing = 8
        typeToggleStack.addArrangedSubview(verticalBtn)
        typeToggleStack.addArrangedSubview(horizontalBtn)
        
        NSLayoutConstraint.activate([
            verticalBtn.widthAnchor.constraint(equalToConstant: 45),
            verticalBtn.heightAnchor.constraint(equalToConstant: 40),
            horizontalBtn.widthAnchor.constraint(equalToConstant: 45),
            horizontalBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        typeContainer.addArrangedSubview(typeLabel)
        typeContainer.addArrangedSubview(typeToggleStack)
        
        topRowStack.addArrangedSubview(titleLabel)
        topRowStack.addArrangedSubview(typeContainer)
        mainStack.addArrangedSubview(topRowStack)
        
        // --- 2. Inner Box ---
        innerBox.backgroundColor = UIColor().colorFromHexString("#2E3A45")
        innerBox.layer.cornerRadius = 15
        
        innerStack.axis = .horizontal
        innerStack.spacing = 20
        innerStack.distribution = .fillProportionally
        innerStack.alignment = .center
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        innerBox.addSubview(innerStack)
        
        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: innerBox.topAnchor, constant: 15),
            innerStack.leadingAnchor.constraint(equalTo: innerBox.leadingAnchor, constant: 20),
            innerStack.trailingAnchor.constraint(equalTo: innerBox.trailingAnchor, constant: -20),
            innerStack.bottomAnchor.constraint(equalTo: innerBox.bottomAnchor, constant: -15)
        ])
        
        // Name Block
        let nameBlock = UIStackView()
        nameBlock.axis = .horizontal
        nameBlock.spacing = 10
        nameBlock.alignment = .center
        
        nameLabel.text = "Opening Name"
        nameLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        nameLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        
        if let controller = viewController, controller.openingsList.count > 0 {
            nameDropdownBtn.setTitle(controller.openingsList[0].name, for: .normal)
            selectedOpeningIndex = 0
        }
        nameDropdownBtn.addTarget(self, action: #selector(nameDropdownTapped), for: .touchUpInside)
        nameDropdownBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameDropdownBtn.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        nameBlock.addArrangedSubview(nameLabel)
        nameBlock.addArrangedSubview(nameDropdownBtn)
        
        // Width Block
        let widthBlock = UIStackView()
        widthBlock.axis = .horizontal
        widthBlock.spacing = 8
        widthBlock.alignment = .center
        
        widthLabel.text = "Width:"
        widthLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        widthLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        
        minusBtn.setTitle("−", for: .normal)
        minusBtn.setTitleColor(.white, for: .normal)
        minusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        minusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        minusBtn.layer.cornerRadius = 15
        minusBtn.addTarget(self, action: #selector(minusWidthTapped), for: .touchUpInside)
        
        widthTF.text = "1.0"
        widthTF.textColor = .white
        widthTF.textAlignment = .center
        widthTF.font = UIFont(name: "Avenir-Medium", size: 15)
        widthTF.keyboardType = .decimalPad
        widthTF.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        widthTF.layer.cornerRadius = 8
        widthTF.delegate = self
        
        plusBtn.setTitle("+", for: .normal)
        plusBtn.setTitleColor(.white, for: .normal)
        plusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        plusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        plusBtn.layer.cornerRadius = 15
        plusBtn.addTarget(self, action: #selector(plusWidthTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            minusBtn.widthAnchor.constraint(equalToConstant: 30),
            minusBtn.heightAnchor.constraint(equalToConstant: 30),
            plusBtn.widthAnchor.constraint(equalToConstant: 30),
            plusBtn.heightAnchor.constraint(equalToConstant: 30),
            widthTF.widthAnchor.constraint(equalToConstant: 60),
            widthTF.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        widthBlock.addArrangedSubview(widthLabel)
        widthBlock.addArrangedSubview(minusBtn)
        widthBlock.addArrangedSubview(widthTF)
        widthBlock.addArrangedSubview(plusBtn)
        
        // Height Block
        let heightBlock = UIStackView()
        heightBlock.axis = .horizontal
        heightBlock.spacing = 10
        heightBlock.alignment = .center
        
        heightLabel.text = "Height:"
        heightLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        heightLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        
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
        heightDropdownBtn.widthAnchor.constraint(equalToConstant: 110).isActive = true
        heightDropdownBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        heightUnitLabel.text = "In."
        heightUnitLabel.textColor = .white
        heightUnitLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        
        heightBlock.addArrangedSubview(heightLabel)
        heightBlock.addArrangedSubview(heightDropdownBtn)
        heightBlock.addArrangedSubview(heightUnitLabel)
        
        // Add blocks to inner stack
        innerStack.addArrangedSubview(nameBlock)
        innerStack.addArrangedSubview(widthBlock)
        innerStack.addArrangedSubview(heightBlock)
        
        mainStack.addArrangedSubview(innerBox)
        
        // --- 3. Room Selector ---
        toLabel.text = "Opening to"
        toLabel.textColor = UIColor().colorFromHexString("#A7B0BA")
        toLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        mainStack.addArrangedSubview(toLabel)
        
        if let controller = viewController {
            availableRoomNames = controller.getAllAvailableRoomNames()
        }
        
        roomsScrollView.translatesAutoresizingMaskIntoConstraints = false
        roomsScrollView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        mainStack.addArrangedSubview(roomsScrollView)
        
        roomsFlowView.translatesAutoresizingMaskIntoConstraints = false
        roomsScrollView.addSubview(roomsFlowView)
        
        NSLayoutConstraint.activate([
            roomsFlowView.topAnchor.constraint(equalTo: roomsScrollView.topAnchor),
            roomsFlowView.leadingAnchor.constraint(equalTo: roomsScrollView.leadingAnchor),
            roomsFlowView.trailingAnchor.constraint(equalTo: roomsScrollView.trailingAnchor),
            roomsFlowView.bottomAnchor.constraint(equalTo: roomsScrollView.bottomAnchor),
            roomsFlowView.widthAnchor.constraint(equalTo: roomsScrollView.widthAnchor)
        ])
        
        for roomName in availableRoomNames {
            let btn = UIButton(type: .custom)
            btn.setTitle("  " + roomName + "  ", for: .normal)
            btn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 13)
            btn.layer.cornerRadius = 15
            btn.layer.borderWidth = 1
            btn.addTarget(self, action: #selector(roomTapped(_:)), for: .touchUpInside)
            styleRoomButtonUnselected(btn)
            roomsFlowView.addSubview(btn)
            roomButtons.append(btn)
        }
        
        if editIndex == nil {
            // When adding, no room selected initially
            selectedRoomName = ""
        } else {
            // Edit will pre-select in populateForEdit
        }
        
        // --- 4. Bottom Buttons ---
        let bottomStack = UIStackView()
        bottomStack.axis = .horizontal
        bottomStack.spacing = 15
        bottomStack.distribution = .fillEqually
        
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.backgroundColor = UIColor().colorFromHexString("#465261")
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        addBtn.setTitle(editIndex == nil ? "Add" : "Save", for: .normal)
        addBtn.setTitleColor(.white, for: .normal)
        addBtn.backgroundColor = UIColor().colorFromHexString("#352F75") // purple
        addBtn.layer.cornerRadius = 10
        addBtn.addTarget(self, action: #selector(addOrSaveTapped), for: .touchUpInside)
        addBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        if editIndex == nil {
            // Hide cancel when adding
            cancelBtn.isHidden = true
        }
        
        bottomStack.addArrangedSubview(cancelBtn)
        bottomStack.addArrangedSubview(addBtn)
        mainStack.addArrangedSubview(bottomStack)
        
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        cardView.contentView.addGestureRecognizer(cardTap)
    }
    
    @objc func roomTapped(_ sender: UIButton) {
        for btn in roomButtons {
            styleRoomButtonUnselected(btn)
        }
        styleRoomButtonSelected(sender)
        selectedRoomName = sender.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    func styleRoomButtonUnselected(_ btn: UIButton) {
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor().colorFromHexString("#6A7888").cgColor
        btn.setTitleColor(UIColor().colorFromHexString("#A7B0BA"), for: .normal)
    }
    
    func styleRoomButtonSelected(_ btn: UIButton) {
        btn.backgroundColor = UIColor().colorFromHexString("#352F75")
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.setTitleColor(.white, for: .normal)
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
        selectedRoomName = roomName
        for btn in roomButtons {
            let title = btn.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if title == roomName {
                styleRoomButtonSelected(btn)
            } else {
                styleRoomButtonUnselected(btn)
            }
        }
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
    
    @objc func cancelTapped() {
        self.endEditing(true)
        onCancel?()
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
    
    @objc func addOrSaveTapped() {
        self.endEditing(true)
        
        if selectedRoomName.isEmpty {
            viewController?.alert("Please select a room for 'Opening to'", nil)
            return
        }
        
        guard let widthText = widthTF.text, let widthVal = Float(widthText), widthVal > 0 else {
            viewController?.alert("Please enter a valid width", nil)
            return
        }
        
        if editIndex == nil {
            // ADD
            guard let controller = viewController else { return }
            let baseOpening = controller.openingsList[selectedOpeningIndex]
            let combinedName = "\(baseOpening.name) to \(selectedRoomName)"
            let customOpening = OpeningCustomObject(name: combinedName, color: baseOpening.color)
            
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
                addViewHeight: selectedHeight,
                transitionheightId: controller.transitionHeightId
            )
            onCancel?()
        } else {
            // SAVE (Edit)
            guard let controller = viewController, let idx = editIndex else { return }
            if idx < controller.drowingView.subSquareView.count {
                let subSquare = controller.drowingView.subSquareView[idx]
                let baseOpening = controller.openingsList[selectedOpeningIndex]
                let combinedName = "\(baseOpening.name) to \(selectedRoomName)"
                let customOpening = OpeningCustomObject(name: combinedName, color: baseOpening.color)
                
                subSquare.object = customOpening
                subSquare.addViewHeight = selectedHeight
                subSquare.isVertical = isVertical
                
                if isVertical {
                    subSquare.custom_hight = CGFloat(widthVal)
                    subSquare.custom_width = 1.0
                } else {
                    subSquare.custom_width = CGFloat(widthVal)
                    subSquare.custom_hight = 1.0
                }
                
                subSquare.custom_size_reload()
                subSquare.change_color_of_path(customOpening.color)
                subSquare.setNeedsLayout()
                controller.drowingView.setNeedsDisplay()
            }
            onCancel?()
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
"""

start_str = "class AddOpeningPopupView: UIView, UITextFieldDelegate {"
end_str = "\n}\n"

start_idx = content.find(start_str)
if start_idx != -1:
    # find the end of the class
    class_end_idx = content.find(end_str, start_idx + len(start_str))
    if class_end_idx != -1:
        new_content = content[:start_idx] + new_classes + content[class_end_idx + len(end_str):]
        with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
            f.write(new_content)
        print("Successfully replaced AddOpeningPopupView")
    else:
        print("End of class not found")
else:
    print("Class not found")
