import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Update spacing to 100
content = content.replace("constant: 50)", "constant: 100)")
content = content.replace("constant: -50)", "constant: -100)")

# 2. Add separators
inner_stack_add = """        // Add blocks to inner stack
        let sep1 = UIView()
        sep1.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sep1.widthAnchor.constraint(equalToConstant: 1).isActive = true
        sep1.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let sep2 = UIView()
        sep2.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sep2.widthAnchor.constraint(equalToConstant: 1).isActive = true
        sep2.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        innerStack.addArrangedSubview(nameBlock)
        innerStack.addArrangedSubview(sep1)
        innerStack.addArrangedSubview(widthBlock)
        innerStack.addArrangedSubview(sep2)
        innerStack.addArrangedSubview(heightBlock)"""
        
old_inner_stack_add = """        // Add blocks to inner stack
        innerStack.addArrangedSubview(nameBlock)
        innerStack.addArrangedSubview(widthBlock)
        innerStack.addArrangedSubview(heightBlock)"""

content = content.replace(old_inner_stack_add, inner_stack_add)

# 3. Add Delete Button
bottom_buttons_add = """        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.backgroundColor = UIColor().colorFromHexString("#465261")
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let deleteBtn = UIButton(type: .custom)
        deleteBtn.setTitle("Delete", for: .normal)
        deleteBtn.setTitleColor(.white, for: .normal)
        deleteBtn.backgroundColor = UIColor().colorFromHexString("#D9534F")
        deleteBtn.layer.cornerRadius = 10
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        addBtn.setTitle(editIndex == nil ? "Add" : "Save", for: .normal)
        addBtn.setTitleColor(.white, for: .normal)
        addBtn.backgroundColor = UIColor().colorFromHexString("#352F75") // purple
        addBtn.layer.cornerRadius = 10
        addBtn.addTarget(self, action: #selector(addOrSaveTapped), for: .touchUpInside)
        addBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        if editIndex == nil {
            // Hide cancel when adding
            cancelBtn.isHidden = true
            bottomStack.addArrangedSubview(addBtn)
        } else {
            bottomStack.addArrangedSubview(cancelBtn)
            bottomStack.addArrangedSubview(deleteBtn)
            bottomStack.addArrangedSubview(addBtn)
        }
        mainStack.addArrangedSubview(bottomStack)"""
        
old_bottom_buttons_add = """        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.backgroundColor = UIColor().colorFromHexString("#465261")
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        addBtn.setTitle(editIndex == nil ? "Add" : "Save", for: .normal)
        addBtn.setTitleColor(.white, for: .normal)
        addBtn.backgroundColor = UIColor().colorFromHexString("#352F75") // purple
        addBtn.layer.cornerRadius = 10
        addBtn.addTarget(self, action: #selector(addOrSaveTapped), for: .touchUpInside)
        addBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        if editIndex == nil {
            // Hide cancel when adding
            cancelBtn.isHidden = true
        }
        
        bottomStack.addArrangedSubview(cancelBtn)
        bottomStack.addArrangedSubview(addBtn)
        mainStack.addArrangedSubview(bottomStack)"""

content = content.replace(old_bottom_buttons_add, bottom_buttons_add)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated UI layout successfully.")
