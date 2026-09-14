import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Update cardView background to #3A4553 (the dark color shown in Image 2)
content = content.replace(
    'cardView.backgroundColor = UIColor().colorFromHexString("#586471")',
    'cardView.backgroundColor = UIColor().colorFromHexString("#3A4553")'
)
content = content.replace(
    'cardView.layer.borderColor = UIColor().colorFromHexString("#586471").cgColor',
    'cardView.layer.borderColor = UIColor().colorFromHexString("#3A4553").cgColor'
)

# 2. Update DropdownSelectButton to give text more room
old_dropdown_insets = 'titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 35)'
new_dropdown_insets = 'titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 25)'
content = content.replace(old_dropdown_insets, new_dropdown_insets)

old_dropdown_draw = 'let centerX = rect.width - 20'
new_dropdown_draw = 'let centerX = rect.width - 15'
content = content.replace(old_dropdown_draw, new_dropdown_draw)

old_dropdown_border = 'layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor'
new_dropdown_border = 'layer.borderColor = UIColor().colorFromHexString("#586471").cgColor'
content = content.replace(old_dropdown_border, new_dropdown_border)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated popup BG to #3A4553 and increased dropdown text space.")
