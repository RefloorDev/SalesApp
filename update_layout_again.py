import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Popup Constraints: Remove top/bottom = 100, replace with centerY.
add_mode_old = """        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            popup.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
            popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 100),
            popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100)
        ])"""
add_mode_new = """        NSLayoutConstraint.activate([
            popup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            popup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 100),
            popup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100),
            popup.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: 50),
            popup.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -50)
        ])"""
content = content.replace(add_mode_old, add_mode_new)

# Edit mode constraints (there are 2 identical blocks that got replaced earlier)
content = content.replace(add_mode_old, add_mode_new) 

# 2. Rooms ScrollView to FlowView
# Remove roomsScrollView entirely from the stack
remove_scroll_1 = """        roomsScrollView.translatesAutoresizingMaskIntoConstraints = false
        // roomsScrollView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        mainStack.addArrangedSubview(roomsScrollView)
        
        roomsFlowView.translatesAutoresizingMaskIntoConstraints = false
        roomsScrollView.addSubview(roomsFlowView)
        
        NSLayoutConstraint.activate([
            roomsFlowView.topAnchor.constraint(equalTo: roomsScrollView.topAnchor),
            roomsFlowView.leadingAnchor.constraint(equalTo: roomsScrollView.leadingAnchor),
            roomsFlowView.trailingAnchor.constraint(equalTo: roomsScrollView.trailingAnchor),
            roomsFlowView.bottomAnchor.constraint(equalTo: roomsScrollView.bottomAnchor),
            roomsFlowView.widthAnchor.constraint(equalTo: roomsScrollView.widthAnchor)
        ])"""
        
new_scroll_1 = """        roomsFlowView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(roomsFlowView)"""
content = content.replace(remove_scroll_1, new_scroll_1)

# 3. Inner stack spacing and spacer to prevent nameBlock stretching
old_inner_stack = """        innerStack.addArrangedSubview(nameBlock)
        innerStack.addArrangedSubview(sep1)
        innerStack.addArrangedSubview(widthBlock)
        innerStack.addArrangedSubview(sep2)
        innerStack.addArrangedSubview(heightBlock)"""
new_inner_stack = """        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        innerStack.addArrangedSubview(nameBlock)
        innerStack.addArrangedSubview(sep1)
        innerStack.addArrangedSubview(widthBlock)
        innerStack.addArrangedSubview(sep2)
        innerStack.addArrangedSubview(heightBlock)
        innerStack.addArrangedSubview(spacer)"""
content = content.replace(old_inner_stack, new_inner_stack)

# 4. Dimmer background color
content = content.replace('dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.4)', 'dimmer.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)')
content = content.replace('dimmer.backgroundColor = UIColor.black.withAlphaComponent(0.6)', 'dimmer.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)')

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated popup layout, dimmer color, and removed scrollview!")
