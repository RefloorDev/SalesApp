import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Fix minusBtn, plusBtn, and widthTF backgrounds
content = content.replace(
    'minusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)',
    'minusBtn.backgroundColor = UIColor().colorFromHexString("#252C354D")'
)
content = content.replace(
    'plusBtn.backgroundColor = UIColor.white.withAlphaComponent(0.1)',
    'plusBtn.backgroundColor = UIColor().colorFromHexString("#252C354D")'
)
content = content.replace(
    'widthTF.backgroundColor = UIColor.white.withAlphaComponent(0.05)',
    'widthTF.backgroundColor = UIColor().colorFromHexString("#252C354D")'
)

# 2. Fix DropdownSelectButton background (around line 2705)
content = content.replace(
    'backgroundColor = UIColor.white.withAlphaComponent(0.05)',
    'backgroundColor = UIColor().colorFromHexString("#252C354D")'
)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated interactive elements with #252C354D!")
