import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Update cardView and innerBox colors
old_card_view = """        cardView.contentView.backgroundColor = UIColor().colorFromHexString("#222831")
        cardView.contentView.layer.borderColor = UIColor().colorFromHexString("#3A4553").cgColor"""
new_card_view = """        cardView.contentView.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)
        cardView.contentView.layer.borderColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7).cgColor"""
content = content.replace(old_card_view, new_card_view)

old_inner_box = """        innerBox.backgroundColor = UIColor().colorFromHexString("#2E3A45")
        innerBox.layer.cornerRadius = 15"""
new_inner_box = """        innerBox.backgroundColor = UIColor().colorFromHexString("#586471")
        innerBox.layer.borderColor = UIColor().colorFromHexString("#586471").cgColor
        innerBox.layer.borderWidth = 1
        innerBox.layer.cornerRadius = 15"""
content = content.replace(old_inner_box, new_inner_box)

# 2. Update Dropdown widths
content = content.replace('nameDropdownBtn.widthAnchor.constraint(equalToConstant: 140)', 'nameDropdownBtn.widthAnchor.constraint(equalToConstant: 180)')
content = content.replace('heightDropdownBtn.widthAnchor.constraint(equalToConstant: 110)', 'heightDropdownBtn.widthAnchor.constraint(equalToConstant: 140)')

# 3. Update room button styling
old_style_selected = """    func styleRoomButtonSelected(_ btn: UIButton) {
        btn.backgroundColor = UIColor().colorFromHexString("#352F75")
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.setTitleColor(.white, for: .normal)
    }"""
new_style_selected = """    func styleRoomButtonSelected(_ btn: UIButton) {
        btn.backgroundColor = UIColor().colorFromHexString("#352F75")
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.setTitleColor(.white, for: .normal)
        let checkImage = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(UIColor().colorFromHexString("#68D168") ?? UIColor.systemGreen, renderingMode: .alwaysOriginal)
        btn.setImage(checkImage, for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
    }"""
content = content.replace(old_style_selected, new_style_selected)

old_style_unselected = """    func styleRoomButtonUnselected(_ btn: UIButton) {
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor().colorFromHexString("#6A7888").cgColor
        btn.setTitleColor(UIColor().colorFromHexString("#A7B0BA"), for: .normal)
    }"""
new_style_unselected = """    func styleRoomButtonUnselected(_ btn: UIButton) {
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor().colorFromHexString("#6A7888").cgColor
        btn.setTitleColor(UIColor().colorFromHexString("#A7B0BA"), for: .normal)
        btn.setImage(nil, for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets.zero
    }"""
content = content.replace(old_style_unselected, new_style_unselected)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated UI colors and room button logic.")
