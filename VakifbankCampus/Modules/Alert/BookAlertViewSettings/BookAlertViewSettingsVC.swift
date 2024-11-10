//
//  BookAlertViewSettingsVC.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 26.08.2024.
//

import UIKit

class BookAlertViewSettingsVC: UIViewController {
    
    let vakifbankColor = UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 255/255.0)
    
    var bookTitle = ""
    var bookDeadline = ""
        
    lazy var view_background = Views(radius: 30, color: .white)
    
    lazy var view_top = Views(radius: 30, color:vakifbankColor ,corners:[.topLeft,.topRight])
    
    lazy var imageView_logo = ImageViews(imageName: "vakifbankLogo")
    
    lazy var imageView_book : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.8
        imageView.layer.shadowRadius = 5
        
        return imageView
    }()
    
    
    
    lazy var label_bookTitle = Labels(textLabel: bookTitle ?? "", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .black)
    lazy var label = Labels(textLabel: "Teslim Tarihi : \(bookDeadline)", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    
    
    
    
    
    lazy var button_bookActivity : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.backgroundColor = vakifbankColor
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        
        return button
    }()
    
    lazy var button_handOver : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Teslim Et", for: .normal)
        button.backgroundColor = vakifbankColor
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        
        return button
    }()
    
    
    
    
    lazy var button_cancel : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        button.contentMode = .scaleAspectFill
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    
    func setupView(){
        configureWithExt()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
}

extension BookAlertViewSettingsVC{
    func configureWithExt() {
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        view.addViews(view_background)
        view_background.addViews(view_top, imageView_book, label_bookTitle, label, button_bookActivity, button_handOver)
        view_top.addViews(imageView_logo, button_cancel)
        
        view_background.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            bottom: view.bottomAnchor,
            paddingTop: screenHeight * 0.1,
            paddingBottom: screenHeight * 0.1,
            paddingLeft: screenWidth * 0.075,
            paddingRight: screenWidth * 0.075
        )
        view_background.layer.shadowColor = UIColor.black.cgColor
        view_background.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_background.layer.shadowOpacity = 0.8
        view_background.layer.shadowRadius = 5
        
        view_top.anchor(
            top: view_background.topAnchor,
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            paddingTop: 0,
            paddingLeft: 0,
            paddingRight: 0,
            height: screenHeight * 0.1
        )
        
        imageView_logo.anchor(
            left: view_top.leftAnchor,
            right: view_top.rightAnchor,
            bottom: view_top.bottomAnchor,
            paddingBottom: 10,
            paddingLeft: screenWidth * 0.2,
            paddingRight: screenWidth * 0.2,
            height: 30
        )
        
        imageView_book.anchor(
            top: view_top.bottomAnchor,
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            bottom: label_bookTitle.topAnchor,
            paddingTop: screenHeight * 0.015,
            paddingBottom: screenHeight * 0.01,
            paddingLeft: screenWidth * 0.25,
            paddingRight: screenWidth * 0.25,
            height: screenHeight * 0.15
        )
        
        label_bookTitle.textAlignment = .center
        label_bookTitle.anchor(
            top: imageView_book.bottomAnchor,
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            bottom: label.topAnchor,
            paddingBottom: screenHeight * 0.02,
            height: 20
        )
        
        label.textAlignment = .center
        label.anchor(
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            bottom: button_bookActivity.topAnchor,
            paddingBottom: screenHeight * 0.05,
            height: 20
        )
        
        button_bookActivity.anchor(
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            bottom: button_handOver.topAnchor,
            paddingBottom: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.2,
            paddingRight: screenWidth * 0.2,
            height: 30
        )
        
        button_handOver.anchor(
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            bottom: view_background.bottomAnchor,
            paddingBottom: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.2,
            paddingRight: screenWidth * 0.2,
            height: 30
        )
        
        button_cancel.anchor(
            top: view_top.topAnchor,
            right: view_top.rightAnchor,
            paddingTop: 0,
            paddingRight: 0,
            width: 75,
            height: 75
        )
    }
    
    func animatedView() {
        view_background.alpha = 0
        self.view_background.frame.origin.y = self.view_background.frame.origin.y + 0
        UIView.animate(withDuration: 0.0, animations: { () -> Void in
            self.view_background.alpha = 1.0
            self.view_background.frame.origin.y = self.view_background.frame.origin.y - 0
        })
    }
}

