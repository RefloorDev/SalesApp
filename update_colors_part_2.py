import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Update unselected room button background color
old_unselected = """    func styleRoomButtonUnselected(_ btn: UIButton) {
        btn.backgroundColor = .clear"""
new_unselected = """    func styleRoomButtonUnselected(_ btn: UIButton) {
        btn.backgroundColor = UIColor().colorFromHexString("#58647133")"""
content = content.replace(old_unselected, new_unselected)

# 2. Update DropdownSelectButton background color
old_dropdown_bg = 'backgroundColor = UIColor().colorFromHexString("#3A4553")'
new_dropdown_bg = 'backgroundColor = UIColor().colorFromHexString("#252C354D")'
content = content.replace(old_dropdown_bg, new_dropdown_bg)

# 3. Update plus and minus buttons background color
old_minus_btn = 'minusBtn.backgroundColor = UIColor().colorFromHexString("#465261")'
new_minus_btn = 'minusBtn.backgroundColor = UIColor().colorFromHexString("#252C354D")'
content = content.replace(old_minus_btn, new_minus_btn)

old_plus_btn = 'plusBtn.backgroundColor = UIColor().colorFromHexString("#465261")'
new_plus_btn = 'plusBtn.backgroundColor = UIColor().colorFromHexString("#252C354D")'
content = content.replace(old_plus_btn, new_plus_btn)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated room unselected background and dropdown/plus/minus background colors.")
