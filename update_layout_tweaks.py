import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Update innerStack distribution
content = content.replace("innerStack.distribution = .fillProportionally", "innerStack.distribution = .fill")

# 2. Update room buttons
old_btn_setup = """        for roomName in availableRoomNames {
            let btn = UIButton(type: .custom)
            btn.setTitle("  " + roomName + "  ", for: .normal)
            btn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 13)
            btn.layer.cornerRadius = 15
            btn.layer.borderWidth = 1"""
new_btn_setup = """        for roomName in availableRoomNames {
            let btn = UIButton(type: .custom)
            btn.setTitle(roomName, for: .normal)
            btn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 13)
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)"""
content = content.replace(old_btn_setup, new_btn_setup)

# 3. Update FlowLayoutView widths (remove the hardcoded + 10)
old_flow_layout = """            let viewWidth = view.bounds.width + 10 // extra padding
            let viewHeight = max(view.bounds.height, 30)"""
new_flow_layout = """            let viewWidth = view.bounds.width
            let viewHeight = max(view.bounds.height, 30)"""
content = content.replace(old_flow_layout, new_flow_layout)

old_flow_layout_intrinsic = """            let viewWidth = view.bounds.width + 10
            let viewHeight = max(view.bounds.height, 30)"""
content = content.replace(old_flow_layout_intrinsic, new_flow_layout)

# 4. We also need to fix roomTapped to just get the title instead of trimming if it doesn't need to, but trimming is safe.
# It's already doing `.trimmingCharacters(in: .whitespacesAndNewlines)` so it's perfectly safe.

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated text cutting and room button styles!")
