//
//  Labels.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit

class Labels: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textLabel: String, fontLabel: UIFont, textColorLabel: UIColor){
        self.init(frame: .zero)
        setLabel(textLabel: textLabel, fontLabel: fontLabel, textColorLabel: textColorLabel)
    }
    
    func configure(){
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setLabel(textLabel: String, fontLabel: UIFont , textColorLabel: UIColor){
       
        text = textLabel
        font = fontLabel
        textColor = textColorLabel
    }
    
}
