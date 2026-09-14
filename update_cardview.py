import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

content = content.replace("let cardView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))", "let cardView = UIView()")
content = content.replace("cardView.contentView.", "cardView.")

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated cardView to UIView and removed contentView references.")
