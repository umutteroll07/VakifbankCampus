//
//  ChangePasswordAlert.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 29.08.2024.
//

import UIKit

protocol ChangePasswordAlertDelegate {
    func cancel()
    func getUserID(completion: @escaping (String) -> Void)
}


class ChangePasswordAlert: UIViewController {
    
    let changePswViewModel = ChangePasswordViewModel()
    
    var delegateChangePassword : ChangePasswordAlertDelegate? = nil
    let vakifbankColor = UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 255/255.0)
    lazy var view_background = Views(radius: 30, color: .white)
    
    lazy var view_top = Views(radius: 30, color: vakifbankColor ,corners:[.topLeft,.topRight])
    
    lazy var imageView_logo = ImageViews(imageName: "vakifbankLogo")
    
    lazy var textField_oldPsw = TextFields(placeHolder: "Eski Şifrenizi Giriniz", secureText: true, textType: .creditCardNumber, maxLength: 6)
    
    lazy var textField_newPsw = TextFields(placeHolder: "Yeni Şifrenizi Giriniz", secureText: true, textType: .creditCardNumber, maxLength: 6)
    lazy var textField_newPswAgain = TextFields(placeHolder: "Yeni Şifrenizi Tekrar Giriniz", secureText: true, textType: .creditCardNumber, maxLength: 6)
    
    
    
    lazy var button_cancel : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Vazgeç", for: .normal)
        button.backgroundColor = vakifbankColor
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        
        return button
    }()
    
    
    lazy var button_updatePsw : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Şifreyi Güncelle", for: .normal)
        button.backgroundColor = vakifbankColor
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addTargetOnButton()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        animatedView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button_updatePsw.isEnabled = false
        button_updatePsw.backgroundColor = .systemRed
        configureWithExt()
    }
    
    
    func animatedView() {
        view_background.alpha = 0
        self.view_background.frame.origin.y = self.view_background.frame.origin.y + 0
        UIView.animate(withDuration: 0.0, animations: { () -> Void in
            
            self.view_background.alpha = 1.0
            self.view_background.frame.origin.y = self.view_background.frame.origin.y - 0
            
        })
    }
    
    func addTargetOnButton(){
        button_cancel.addTarget(self, action: #selector(tapped_cancelButton), for: .touchUpInside)
        button_updatePsw.addTarget(self, action: #selector(tapped_updatePassword), for: .touchUpInside)
        textField_newPsw.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK : @objc func for button
    
    @objc func tapped_updatePassword(){
        delegateChangePassword?.getUserID(completion: {userID in
            let enteredOldPsw = self.textField_oldPsw.text
            let enteredNewPsw = self.textField_newPsw.text
            let enteredNewPswAgain = self.textField_newPswAgain.text
            self.changePswViewModel.updatePassword(userID:userID,enteredOldPsw: enteredOldPsw ?? "", enteredNewPsw: enteredNewPsw ?? "", enteredNewPswAgain: enteredNewPswAgain ?? "") { title, message, bool in
                if bool{
                    self.makeAlertChangePsw(title: title, message: message)
                }
                else {
                    self.makeAlert(title: title, message: message)
                }
            }
            
        })
    }
    
    
    @objc func tapped_cancelButton(){
        delegateChangePassword?.cancel()
        self.dismiss(animated: true)
    }
    
    @objc func textFieldDidChange() {
        guard let text = textField_newPsw.text else { return }
        
        if text.count >= 6 {
            button_updatePsw.backgroundColor = .systemGreen
            button_updatePsw.isEnabled = true
        } else {
            button_updatePsw.backgroundColor = .systemRed
            button_updatePsw.isEnabled = false
        }
    }
    
    // MARK : Create Alert
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .default)
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }

    func makeAlertChangePsw(title: String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .default) { _ in
            self.delegateChangePassword?.cancel()
            self.dismiss(animated: true)
        }
        alert.addAction(alertAction)
        self.present(alert,animated: true)
    }
}

extension ChangePasswordAlert{
    
    func configureWithExt() {
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        view.addViews(view_background)
        view_background.addViews(view_top,button_cancel,textField_oldPsw,textField_newPsw,textField_newPswAgain,button_updatePsw)
        view_top.addViews(imageView_logo)
        
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
        
        textField_oldPsw.anchor(top:view_top.bottomAnchor,left: view_background.leftAnchor,right: view_background.rightAnchor,paddingTop: 100,paddingLeft: 10,paddingRight: 10)
        
        textField_newPsw.anchor(top:textField_oldPsw.bottomAnchor,left: view_background.leftAnchor,right: view_background.rightAnchor,paddingTop: 50,paddingLeft: 10,paddingRight: 10)
        
        textField_newPswAgain.anchor(top:textField_newPsw.bottomAnchor,left: view_background.leftAnchor,right: view_background.rightAnchor,paddingTop: 50,paddingLeft: 10,paddingRight: 10)
        
        
        button_updatePsw.anchor(
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            bottom: button_cancel.topAnchor,
            paddingBottom: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.2,
            paddingRight: screenWidth * 0.2,
            height: 30
        )
        
        
        button_cancel.anchor(
            left: view_background.leftAnchor,
            right: view_background.rightAnchor,
            bottom: view_background.bottomAnchor,
            paddingBottom: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.2,
            paddingRight: screenWidth * 0.2,
            height: 30
        )
    }
}

