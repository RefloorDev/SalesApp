extension LineSegmentControlView {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == inchesTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty {
                return true
            }
            
            if let intValue = Int(updatedText) {
                return intValue >= 0 && intValue <= 12
            }
            return false
        }
        return true
    }
}
