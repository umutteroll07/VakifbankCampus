//
//  ImageViews.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit

class ImageViews: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(imageName: String){
        self.init(frame: .zero)
        setImage(imageName: imageName)
    }
    
    func configure(imageName : String) {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleToFill
        
    }
    
    func setImage(imageName : String){
        image = UIImage(named: imageName)
    }
    
}

