//
//  ViewController.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit
import SafariServices

protocol SignInViewControllerProtocol: AnyObject {
    func setSignInInfo() -> (String,String)?
    func navigateToHomePage()
    func showAlert(title: String, message: String)
}

class SignInViewController: UIViewController,UITextFieldDelegate {
    
    let vakifbankColor = UIColor(red: 246/255.0, green: 178/255.0, blue: 5/255.0, alpha: 255/255.0)
    
    lazy var backgroundView = Views(radius: 0,color: vakifbankColor)
    lazy var imageBackgroundLogo = ImageViews(imageName: "vakifbankBina")
    
    lazy var imageLogo = ImageViews(imageName: "vakifbankLogoImage")
    lazy var signInView = Views(radius: 30, color: .white)
    lazy  var lbl_title = Labels(
        textLabel: "Kampüs",
        fontLabel: .italicSystemFont(ofSize: 25),
        textColorLabel: .black
    )
    
    lazy var textField_tckNumber = TextFields(
        placeHolder: "",
        secureText: false,textType: .creditCardNumber,
        maxLength: 11
    )
    lazy var label_tckNumber = Labels(
        textLabel: "T.C Kimlik Numarası",
        fontLabel: .systemFont(ofSize: 15),
        textColorLabel: .gray
    )
    
    lazy var textField_password = TextFields(
        placeHolder: "",
        secureText: true,
        textType: .creditCardNumber,
        maxLength: 6
    )
    
    lazy var label_password = Labels(
        textLabel: "Dijital Şifre",
        fontLabel: .systemFont(ofSize: 15),
        textColorLabel: .gray
    )
    
    lazy var btn_signIn : UIButton =  {
        let button = UIButton(type: .system)
        button.backgroundColor = vakifbankColor
        button.layer.cornerRadius = 10
        button.setTitle("Giriş", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var btn_forgetPsw : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dijital Şifrem Yok/Unuttum", for: .normal)
        button.setTitleColor(vakifbankColor, for: .normal)
        return button
        
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let viewModel = SignInViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        addTargetOnButton()
        configureWithExt()
        viewModel.view = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setDelegate(){
        textField_tckNumber.delegate = self
        textField_password.delegate = self
    }
    
    func addTargetOnButton(){
        self.btn_signIn.addTarget(self, action: #selector(tapped_signInButton), for: .touchUpInside)
        self.btn_forgetPsw.addTarget(self, action: #selector(tapped_forgetPswButton), for: .touchUpInside)
    }
    
    @objc func tapped_signInButton(){
        viewModel.signIn()
    }
    
    @objc func tapped_forgetPswButton(){
        let urlVakifbankWebsite = "https://www.vakifbank.com.tr/tr/dijital-bankacilik/internet-bankaciligi/internet-bankaciligi-sifre-al"
        guard let url = URL(string: urlVakifbankWebsite ) else { return }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    
    // MaxLength for textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var currentText : String
        var maxLength : Int
        if textField == textField_tckNumber {
            // Mevcut metni al
            currentText = textField_tckNumber.text ?? ""
            maxLength = 11
        }
        else if textField == textField_password {
            // Mevcut metni al
            currentText = textField_password.text ?? ""
            maxLength = 6
        }
        else{
            currentText = ""
            maxLength = 0
        }
        
        // Yeni metni oluştur
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 6 karakteri aşmıyorsa, karakter girişine izin ver
        return updatedText.count <= maxLength
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == textField_tckNumber {
            animateLabel(label: self.label_tckNumber, moveUp: true)
            label_tckNumber.textColor = vakifbankColor
        } else if textField == textField_password {
            animateLabel(label: self.label_password, moveUp: true)
            label_password.textColor = vakifbankColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textField_tckNumber {
            if textField.text?.isEmpty == true {
                animateLabel(label: self.label_tckNumber, moveUp: false)
                label_tckNumber.textColor = .gray
            }
        } else if textField == textField_password {
            if textField.text?.isEmpty == true {
                animateLabel(label: self.label_password, moveUp: false)
                label_password.textColor = .gray
            }
        }
    }
    
    func animateLabel(label: UILabel, moveUp: Bool) {
        UIView.animate(withDuration: 0.3) {
            label.transform = moveUp ? CGAffineTransform(translationX: 0, y: -30) : .identity
            label.font = moveUp ? UIFont.systemFont(ofSize: 12) : UIFont.systemFont(ofSize: 17)
        }
    }
    
}

extension SignInViewController {
    
    func configureWithExt() {
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // Add views
        view.addViews(backgroundView,imageBackgroundLogo,imageLogo, lbl_title, signInView)
        signInView.addViews(textField_tckNumber, textField_password, btn_signIn, btn_forgetPsw, activityIndicator,label_tckNumber,label_password)
        
        backgroundView.alpha = 0.5
        backgroundView.anchor(
            top:view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            bottom: view.bottomAnchor
        )
        
        imageBackgroundLogo.alpha = 0.5
        imageBackgroundLogo.anchor(top:view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: screenHeight * 0.4
        )
        
        // SignInView constraints
        signInView.anchor(
            top: imageLogo.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            paddingTop: screenHeight * 0.08,
            paddingBottom: screenHeight * 0.07,
            paddingLeft: screenWidth * 0.1,
            paddingRight: screenWidth * 0.1
            //            height: screenHeight * 0.05
        )
        
        // ImageLogo constraints
        imageLogo.alpha = 1
        imageLogo.contentMode = .scaleAspectFill
        imageLogo.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: screenHeight * 0.050,
            paddingLeft: screenWidth * 0.12,
            paddingRight: screenWidth * 0.12,
            height: screenHeight * 0.05
        )
        
        // Title Label constraints
        lbl_title.alpha = 1
        lbl_title.anchor(
            top: imageLogo.bottomAnchor,
            right: imageLogo.rightAnchor,
            paddingTop: screenHeight * 0.005,
            paddingRight: screenWidth * 0.01,
            height: 25
        )
        
        // Ticket Number TextField constraints
        textField_tckNumber.anchor(
            top: signInView.topAnchor,
            left: signInView.leftAnchor,
            right: signInView.rightAnchor,
            paddingTop: screenHeight * 0.12,
            paddingLeft: screenWidth * 0.05,
            paddingRight: screenWidth * 0.05,
            height: 20
        )
        
        // Password TextField constraints
        textField_password.anchor(
            top: textField_tckNumber.bottomAnchor,
            left: signInView.leftAnchor,
            right: signInView.rightAnchor,
            paddingTop: screenHeight * 0.075,
            paddingLeft: screenWidth * 0.05,
            paddingRight: screenWidth * 0.05,
            height: 20
        )
        
        
        label_tckNumber.anchor(top:textField_tckNumber.topAnchor,
            left: textField_tckNumber.leftAnchor,
            bottom: textField_tckNumber.bottomAnchor,
            paddingLeft: 5
        )
        
        label_password.anchor(top:textField_password.topAnchor,
            left: textField_password.leftAnchor,
            bottom: textField_password.bottomAnchor,
            paddingLeft: 5
        )
        
        // Sign In Button constraints
        btn_signIn.anchor(
            top: textField_password.bottomAnchor,
            left: signInView.leftAnchor,
            right: signInView.rightAnchor,
            paddingTop: screenHeight * 0.2,
            paddingLeft: screenWidth * 0.1,
            paddingRight: screenWidth * 0.1,
            height: 45
        )
        
        // Forget Password Button constraints
        btn_forgetPsw.anchor(
            left: signInView.leftAnchor,
            right: signInView.rightAnchor,
            bottom: signInView.bottomAnchor,
            paddingBottom: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.1,
            paddingRight: screenWidth * 0.1,
            height: 20
        )
        
        activityIndicator.anchor(top: signInView.topAnchor,
            left: signInView.leftAnchor,
            right: signInView.rightAnchor,
            bottom: signInView.bottomAnchor
        )
    }
   
}

extension SignInViewController: SignInViewControllerProtocol {
    func setSignInInfo() -> (String, String)? {
        guard let tckNumber = textField_tckNumber.text else { return nil }
        guard let password = textField_password.text else { return nil }
        viewModel.tckNumber = tckNumber
        viewModel.password = password
        return (tckNumber,password) as? (String, String)
    }
    
    
    func navigateToHomePage() {
        print("Navigate To Home")
        let tabBarController = TabBarController()
        tabBarController.userID = viewModel.userID
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .cancel)
        alert.addAction(alertAction)
        self.present(alert, animated: true)
        
    }
}
