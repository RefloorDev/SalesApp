import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Remove opacity from cardView
content = content.replace(
    'cardView.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)',
    'cardView.backgroundColor = UIColor().colorFromHexString("#586471")'
)
content = content.replace(
    'cardView.layer.borderColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7).cgColor',
    'cardView.layer.borderColor = UIColor().colorFromHexString("#586471").cgColor'
)

# 2. Update innerStack distribution to equalSpacing
content = content.replace("innerStack.distribution = .fill", "innerStack.distribution = .equalSpacing")

# 3. Remove the spacer
old_inner_stack = """        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        innerStack.addArrangedSubview(nameBlock)
        innerStack.addArrangedSubview(sep1)
        innerStack.addArrangedSubview(widthBlock)
        innerStack.addArrangedSubview(sep2)
        innerStack.addArrangedSubview(heightBlock)
        innerStack.addArrangedSubview(spacer)"""
new_inner_stack = """        innerStack.addArrangedSubview(nameBlock)
        innerStack.addArrangedSubview(sep1)
        innerStack.addArrangedSubview(widthBlock)
        innerStack.addArrangedSubview(sep2)
        innerStack.addArrangedSubview(heightBlock)"""
if old_inner_stack in content:
    content = content.replace(old_inner_stack, new_inner_stack)
else:
    print("Could not find innerStack definition to remove spacer.")

# 4. Fix dimmer overlay to be a blur effect if they meant "make the blur 70%" 
# Wait, "make the blur 70%" might mean the dimmer shouldn't just be a color, it should be a blur.
# Currently: dimmer.backgroundColor = UIColor().colorFromHexString("#586471").withAlphaComponent(0.7)
# I will just keep it as is, since 70% opacity is there. But if they specifically want a blur, I can add a UIVisualEffectView to it.
# Actually, the user says "make the blur 70% remove the opacity for the BG opening window". 
# The "blur 70%" probably just means opacity 70% for the overlay, which is already done. Let's stick with the color opacity.

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated cardView opacity and innerStack layout.")
