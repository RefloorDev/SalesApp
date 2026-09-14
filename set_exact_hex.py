import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# Replace cardView manually added opacity with the exact requested hex code
content = content.replace(
    'cardView.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)',
    'cardView.backgroundColor = UIColor().colorFromHexString("#586471B2")'
)
content = content.replace(
    'cardView.layer.borderColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7).cgColor',
    'cardView.layer.borderColor = UIColor().colorFromHexString("#586471B2").cgColor'
)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated hex color to exactly #586471B2 without manual opacity.")
