//
//  ToastMessage.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit

class ToastMessage {
    static func showToast(message: String, in view: UIView) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        toastLabel.alpha = 1.0
        toastLabel.frame = CGRect(x: view.frame.size.width/2 - 75, y: view.frame.size.height-150, width: 150, height: 35)
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseInOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}
