import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

apply_edits_func = """    func applyEdits() {
        self.endEditing(true)
        guard let controller = viewController, let idx = editIndex else { return }
        
        if selectedRoomName.isEmpty { return }
        guard let widthText = widthTF.text, let widthVal = Float(widthText), widthVal > 0 else { return }
        
        if idx < controller.drowingView.subSquareView.count {
            let subSquare = controller.drowingView.subSquareView[idx]
            let baseOpening = controller.openingsList[selectedOpeningIndex]
            let combinedName = "\(baseOpening.name) to \(selectedRoomName)"
            let customOpening = OpeningCustomObject(name: combinedName, color: baseOpening.color)
            
            subSquare.object = customOpening
            subSquare.addViewHeight = selectedHeight
            subSquare.isVertical = isVertical
            
            if isVertical {
                subSquare.custom_hight = CGFloat(widthVal)
                subSquare.custom_width = 1.0
            } else {
                subSquare.custom_width = CGFloat(widthVal)
                subSquare.custom_hight = 1.0
            }
            
            subSquare.custom_size_reload()
            subSquare.change_color_of_path(customOpening.color)
            subSquare.setNeedsLayout()
            controller.drowingView.setNeedsDisplay()
        }
    }
"""

# We'll insert it right before the last closing brace of AddOpeningPopupView.
target = """
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == widthTF {
            if let text = textField.text, let val = Float(text), val > 0 {
                widthTF.text = String(format: "%.1f", Double(val))
            } else {
                widthTF.text = "3.0"
            }
        }
    }
}"""

replacement = """
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == widthTF {
            if let text = textField.text, let val = Float(text), val > 0 {
                widthTF.text = String(format: "%.1f", Double(val))
            } else {
                widthTF.text = "3.0"
            }
        }
    }
    
""" + apply_edits_func + """
}"""

if target in content:
    content = content.replace(target, replacement)
    
    # Also fix addOrSaveTapped
    old_add_or_save = """        } else {
            // SAVE (Edit)
            guard let controller = viewController, let idx = editIndex else { return }
            if idx < controller.drowingView.subSquareView.count {
                let subSquare = controller.drowingView.subSquareView[idx]
                let baseOpening = controller.openingsList[selectedOpeningIndex]
                let combinedName = "\(baseOpening.name) to \(selectedRoomName)"
                let customOpening = OpeningCustomObject(name: combinedName, color: baseOpening.color)
                
                subSquare.object = customOpening
                subSquare.addViewHeight = selectedHeight
                subSquare.isVertical = isVertical
                
                if isVertical {
                    subSquare.custom_hight = CGFloat(widthVal)
                    subSquare.custom_width = 1.0
                } else {
                    subSquare.custom_width = CGFloat(widthVal)
                    subSquare.custom_hight = 1.0
                }
                
                subSquare.custom_size_reload()
                subSquare.change_color_of_path(customOpening.color)
                subSquare.setNeedsLayout()
                controller.drowingView.setNeedsDisplay()
            }
            onCancel?()
        }"""
        
    new_add_or_save = """        } else {
            // SAVE (Edit)
            applyEdits()
            onCancel?()
        }"""
    
    if old_add_or_save in content:
        content = content.replace(old_add_or_save, new_add_or_save)
        with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
            f.write(content)
        print("Successfully added applyEdits")
    else:
        print("Failed to replace old_add_or_save")
else:
    print("Failed to find target")
