import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Fix whitish shadow/corners by setting self.backgroundColor = .clear
setup_target = "private func setup() {"
setup_replacement = """private func setup() {
        self.backgroundColor = .clear"""
content = content.replace(setup_target, setup_replacement)

# 2. Fix the innerStack spacing and distribution
old_inner_stack = """        innerStack.axis = .horizontal
        innerStack.spacing = 8
        innerStack.distribution = .equalSpacing"""
new_inner_stack = """        innerStack.axis = .horizontal
        innerStack.spacing = 20
        innerStack.distribution = .fill"""
content = content.replace(old_inner_stack, new_inner_stack)

# 3. Disable font size scaling so text never changes size
content = content.replace("nameDropdownBtn.titleLabel?.adjustsFontSizeToFitWidth = true", "nameDropdownBtn.titleLabel?.adjustsFontSizeToFitWidth = false")
content = content.replace("heightDropdownBtn.titleLabel?.adjustsFontSizeToFitWidth = true", "heightDropdownBtn.titleLabel?.adjustsFontSizeToFitWidth = false")

# 4. Modify popup constraints to allow expansion if content is too large (lowering priority of 100 margins)
old_constraints = """        NSLayoutConstraint.activate([
            popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 100),
            popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100),
            popup.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: 50),
            popup.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -50)
        ])"""

new_constraints = """        let lead = popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 100)
        lead.priority = .defaultHigh
        let trail = popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100)
        trail.priority = .defaultHigh
        let minWidth = popup.widthAnchor.constraint(greaterThanOrEqualToConstant: 750)
        
        NSLayoutConstraint.activate([
            popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            lead,
            trail,
            minWidth,
            popup.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: 50),
            popup.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -50)
        ])"""

content = content.replace(old_constraints, new_constraints)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated UI properties successfully.")
