//
//  Views.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit

class Views: UIView {
    var cornerRadii: CGFloat = 0
    var roundedCorners: UIRectCorner = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(radius: CGFloat, color: UIColor, corners: UIRectCorner = []) {
        self.init(frame: .zero)
        setView(radius: radius, color: color, corners: corners)
    }
    
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setView(radius: CGFloat, color: UIColor, corners: UIRectCorner = []) {
        self.cornerRadii = radius
        self.roundedCorners = corners
        backgroundColor = color
        layer.cornerRadius = corners.isEmpty ? radius : 0 // Eğer köşeler belirtilmemişse, normal radius ayarla
    }
       
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundedCorners()
    }
    
    func applyRoundedCorners() {
        guard !roundedCorners.isEmpty else {
            layer.mask = nil
            return
        }
        
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: roundedCorners,
            cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)
        )
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}
