import re

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "r") as f:
    content = f.read()

# 1. Change text
content = content.replace('scaleSub.text = "Scale 1 Unit = 1 Ft."', 'scaleSub.text = "Scale 1 unit = 6 Inch"')

# 2. Remove scaleDropdownBtn setup
content = re.sub(
    r'scaleDropdownBtn\.setTitle\("1x".*?topBox\.addSubview\(scaleDropdownBtn\)\n\s*',
    '',
    content,
    flags=re.DOTALL
)

# 3. Fix constraints in FloatingSidePanel
content = content.replace(
    'scaleTitle.trailingAnchor.constraint(lessThanOrEqualTo: scaleDropdownBtn.leadingAnchor, constant: -5)',
    'scaleTitle.trailingAnchor.constraint(equalTo: topBox.trailingAnchor, constant: -15)'
)
content = content.replace(
    'scaleSub.trailingAnchor.constraint(lessThanOrEqualTo: scaleDropdownBtn.leadingAnchor, constant: -5)',
    'scaleSub.trailingAnchor.constraint(equalTo: topBox.trailingAnchor, constant: -15)'
)
content = re.sub(
    r'scaleDropdownBtn\.centerYAnchor\.constraint.*?scaleDropdownBtn\.heightAnchor\.constraint\(equalToConstant: 35\),\n\s*',
    '',
    content,
    flags=re.DOTALL
)

with open("Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/CustomShapeLineViewController.swift", "w") as f:
    f.write(content)
print("Updated FloatingSidePanel!")
