with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

labels_fix = """
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        widthLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        heightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
"""

if "innerStack.translatesAutoresizingMaskIntoConstraints = false" in content:
    content = content.replace(
        "innerStack.translatesAutoresizingMaskIntoConstraints = false", 
        "innerStack.translatesAutoresizingMaskIntoConstraints = false" + labels_fix
    )
    with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
        f.write(content)
    print("Fixed compression resistance.")
else:
    print("Could not find insertion point.")
