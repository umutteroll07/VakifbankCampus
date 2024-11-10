//
//  TextFields.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit

class TextFields: UITextField, UITextFieldDelegate {
    
    var maxCaracterLength : Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(placeHolder : String, secureText:Bool,textType : UITextContentType,maxLength:Int){
        self.init(frame: .zero)
        maxCaracterLength = maxLength
        setTextField(textPlaceHolder: placeHolder,secureText: secureText,textType: textType,maxLength: maxLength)
        
    }
    
    func configure(){
        translatesAutoresizingMaskIntoConstraints = false
        self.delegate = self
        self.anchor()
    }
    
    func setTextField(textPlaceHolder: String, secureText: Bool, textType: UITextContentType,maxLength : Int){
        
        placeholder = textPlaceHolder
        borderStyle = .none
        isSecureTextEntry = secureText
        textContentType = textType
        self.maxCaracterLength = maxLength
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= self.maxCaracterLength
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Alt çizgiyi ekle
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: frame.height + 5, width: frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        
        // Yeni alt çizgiyi ekle
        layer.addSublayer(bottomLine)
    }
}
