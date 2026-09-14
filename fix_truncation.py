import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Reduce spacings
content = content.replace("innerStack.spacing = 20", "innerStack.spacing = 8")
content = content.replace("nameBlock.spacing = 10", "nameBlock.spacing = 5")
content = content.replace("widthBlock.spacing = 8", "widthBlock.spacing = 5")
content = content.replace("heightBlock.spacing = 10", "heightBlock.spacing = 5")

# 2. Add adjustsFontSizeToFitWidth and adjust widths
old_name_btn = """        nameDropdownBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameDropdownBtn.widthAnchor.constraint(equalToConstant: 180).isActive = true"""
new_name_btn = """        nameDropdownBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        nameDropdownBtn.titleLabel?.minimumScaleFactor = 0.5
        nameDropdownBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameDropdownBtn.widthAnchor.constraint(equalToConstant: 140).isActive = true"""
content = content.replace(old_name_btn, new_name_btn)

old_height_btn = """        heightDropdownBtn.widthAnchor.constraint(equalToConstant: 140).isActive = true
        heightDropdownBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true"""
new_height_btn = """        heightDropdownBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        heightDropdownBtn.titleLabel?.minimumScaleFactor = 0.5
        heightDropdownBtn.widthAnchor.constraint(equalToConstant: 120).isActive = true
        heightDropdownBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true"""
content = content.replace(old_height_btn, new_height_btn)

# 3. Ensure In. is visible by giving heightUnitLabel high compression resistance
if "heightUnitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)" not in content:
    old_unit = 'heightUnitLabel.font = UIFont(name: "Avenir-Medium", size: 14)'
    new_unit = old_unit + '\n        heightUnitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)'
    content = content.replace(old_unit, new_unit)

# 4. Room names truncation (set dummy image and adjust padding)
old_selected = """    func styleRoomButtonSelected(_ btn: UIButton) {
        btn.backgroundColor = UIColor().colorFromHexString("#352F75")
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.setTitleColor(.white, for: .normal)
        let checkImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(UIColor().colorFromHexString("#68D168") ?? UIColor.systemGreen, renderingMode: .alwaysOriginal)
        btn.setImage(checkImage, for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    }"""
new_selected = """    func styleRoomButtonSelected(_ btn: UIButton) {
        btn.backgroundColor = UIColor().colorFromHexString("#352F75")
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.setTitleColor(.white, for: .normal)
        let checkImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(UIColor().colorFromHexString("#68D168") ?? UIColor.systemGreen, renderingMode: .alwaysOriginal)
        btn.setImage(checkImage, for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 24)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.8
        
        btn.superview?.setNeedsLayout()
        btn.superview?.layoutIfNeeded()
    }"""
content = content.replace(old_selected, new_selected)

old_unselected = """    func styleRoomButtonUnselected(_ btn: UIButton) {
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor().colorFromHexString("#6A7888").cgColor
        btn.setTitleColor(UIColor().colorFromHexString("#A7B0BA"), for: .normal)
        btn.setImage(nil, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets.zero
    }"""
new_unselected = """    func styleRoomButtonUnselected(_ btn: UIButton) {
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor().colorFromHexString("#6A7888").cgColor
        btn.setTitleColor(UIColor().colorFromHexString("#A7B0BA"), for: .normal)
        let dummyImage = UIImage(systemName: "circle")?.withTintColor(.clear, renderingMode: .alwaysOriginal)
        btn.setImage(dummyImage, for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 24)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.8
    }"""
content = content.replace(old_unselected, new_unselected)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated truncations and cell sizes!")
