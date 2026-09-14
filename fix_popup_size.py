with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# Replace add mode popup constraints
add_mode_target = """        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 340)
        ])"""

add_mode_replacement = """        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            popup.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)
        ])"""

content = content.replace(add_mode_target, add_mode_replacement)

# Replace edit mode popup constraints
edit_mode_target = """        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 340)
        ])"""
        
edit_mode_replacement = """        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            popup.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)
        ])"""

content = content.replace(edit_mode_target, edit_mode_replacement)

# Remove the fixed height of roomsScrollView
scroll_target = "roomsScrollView.heightAnchor.constraint(equalToConstant: 120).isActive = true"
if scroll_target in content:
    content = content.replace(scroll_target, "// " + scroll_target)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated popup sizing constraints!")
