import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# Change room unselected background color from #58647133 to #252C354D
content = content.replace(
    'btn.backgroundColor = UIColor().colorFromHexString("#58647133")',
    'btn.backgroundColor = UIColor().colorFromHexString("#252C354D")'
)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated room pills to use #252C354D.")
