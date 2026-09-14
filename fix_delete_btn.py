import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# Fix the delete button appearance
old_delete_btn = """        let deleteBtn = UIButton(type: .custom)
        deleteBtn.setTitle("Delete", for: .normal)
        deleteBtn.setTitleColor(.white, for: .normal)
        deleteBtn.backgroundColor = UIColor().colorFromHexString("#D9534F")
        deleteBtn.layer.cornerRadius = 10
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true"""

new_delete_btn = """        let deleteBtn = UIButton(type: .custom)
        let trashIcon = UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        deleteBtn.setImage(trashIcon, for: .normal)
        deleteBtn.backgroundColor = UIColor().colorFromHexString("#252C354D")
        deleteBtn.layer.cornerRadius = 22.5
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        deleteBtn.widthAnchor.constraint(equalToConstant: 45).isActive = true"""
content = content.replace(old_delete_btn, new_delete_btn)

# Fix the bottomStack layout
old_bottom_layout = """        if editIndex == nil {
            // Hide cancel when adding
            cancelBtn.isHidden = true
            bottomStack.addArrangedSubview(addBtn)
        } else {
            bottomStack.addArrangedSubview(cancelBtn)
            bottomStack.addArrangedSubview(deleteBtn)
            bottomStack.addArrangedSubview(addBtn)
        }
        mainStack.addArrangedSubview(bottomStack)"""

new_bottom_layout = """        let actionStack = UIStackView(arrangedSubviews: [cancelBtn, addBtn])
        actionStack.axis = .horizontal
        actionStack.spacing = 15
        actionStack.distribution = .fillEqually
        
        bottomStack.distribution = .fill
        
        if editIndex == nil {
            // Hide cancel when adding
            cancelBtn.isHidden = true
            bottomStack.addArrangedSubview(actionStack)
        } else {
            addBtn.setTitle("Update", for: .normal)
            bottomStack.addArrangedSubview(deleteBtn)
            bottomStack.addArrangedSubview(actionStack)
        }
        mainStack.addArrangedSubview(bottomStack)"""
content = content.replace(old_bottom_layout, new_bottom_layout)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated delete button appearance and bottomStack layout.")
