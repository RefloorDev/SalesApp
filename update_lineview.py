import re

with open('Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/LineView.swift', 'r') as f:
    content = f.read()

# Update moldingDropdownButton setup
old_setup = """        moldingDropdownButton.frame = CGRect(x: 56, y: 62, width: 107, height: 28)
        moldingDropdownButton.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        moldingDropdownButton.layer.cornerRadius = 14
        moldingDropdownButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        moldingDropdownButton.layer.borderWidth = 1
        moldingDropdownButton.setTitle("No Molding", for: .normal)
        moldingDropdownButton.setTitleColor(.white, for: .normal)
        moldingDropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        if #available(iOS 13.0, *) {
            moldingDropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            moldingDropdownButton.tintColor = .white
            moldingDropdownButton.semanticContentAttribute = .forceRightToLeft
            moldingDropdownButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        self.addSubview(moldingDropdownButton)"""

new_setup = """        moldingDropdownButton.frame = CGRect(x: 56, y: 62, width: 127, height: 38)
        moldingDropdownButton.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
        moldingDropdownButton.layer.cornerRadius = 19
        moldingDropdownButton.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        moldingDropdownButton.layer.borderWidth = 1
        moldingDropdownButton.setTitle("Select Molding", for: .normal)
        moldingDropdownButton.setTitleColor(UIColor(red: 167/255, green: 176/255, blue: 186/255, alpha: 1.0), for: .normal)
        moldingDropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        if #available(iOS 13.0, *) {
            moldingDropdownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            moldingDropdownButton.tintColor = UIColor(red: 167/255, green: 176/255, blue: 186/255, alpha: 1.0)
            moldingDropdownButton.semanticContentAttribute = .forceRightToLeft
            moldingDropdownButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        moldingDropdownButton.addTarget(self, action: #selector(moldingDropdownTapped(_:)), for: .touchUpInside)
        self.addSubview(moldingDropdownButton)"""

content = content.replace(old_setup, new_setup)

# Update delegate protocol
old_delegate = """protocol LineViewDelegate {
    func LineViewArea_PerimeterResult(area:CGFloat,Perimeter:Float)
    func LineViewTempAreaResult(area:CGFloat,isClosed:Bool,Perimeter:Float)"""

new_delegate = """protocol LineViewDelegate {
    func LineViewArea_PerimeterResult(area:CGFloat,Perimeter:Float)
    func LineViewTempAreaResult(area:CGFloat,isClosed:Bool,Perimeter:Float)
    func didTapMoldingDropdown(on lineView: LineView, sender: UIButton)"""

content = content.replace(old_delegate, new_delegate)

# Add method at the bottom before last closing brace
if "@objc func closeAction()" in content:
    method_to_add = """
    @objc func moldingDropdownTapped(_ sender: UIButton) {
        delegate?.didTapMoldingDropdown(on: self, sender: sender)
    }"""
    
    # insert before the very last `}`
    last_brace_index = content.rfind('}')
    content = content[:last_brace_index] + method_to_add + "\n}" + content[last_brace_index+1:]

with open('Refloor/ViewControllers/ToolViewControllers/ToolsSupportedViews/CustomShapeWithLine/LineView.swift', 'w') as f:
    f.write(content)
