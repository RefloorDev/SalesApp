import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Revert Dimmer to Black
content = content.replace(
    'dimmer.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)',
    'dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.4)'
)

# 2. Add Opacity back to cardView
content = content.replace(
    'cardView.backgroundColor = UIColor().colorFromHexString("#586471")',
    'cardView.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)'
)
content = content.replace(
    'cardView.layer.borderColor = UIColor().colorFromHexString("#586471").cgColor',
    'cardView.layer.borderColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7).cgColor'
)

# 3. Increase dropdown widths to prevent truncation
content = content.replace(
    'nameDropdownBtn.widthAnchor.constraint(equalToConstant: 140).isActive = true',
    'nameDropdownBtn.widthAnchor.constraint(equalToConstant: 200).isActive = true'
)
content = content.replace(
    'heightDropdownBtn.widthAnchor.constraint(equalToConstant: 120).isActive = true',
    'heightDropdownBtn.widthAnchor.constraint(equalToConstant: 160).isActive = true'
)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated UI background colors and button sizes.")
