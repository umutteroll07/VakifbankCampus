//
//  PersonInfoViewController.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit
import SafariServices

protocol PersonInfoPageProtocol: AnyObject{
    func setUserID() -> String
    func setPersonInfoCompanent(personInfoModel: UserInfoModel)
    func goToWebsite(webSiteUrl: String)
}

class PersonInfoViewController: UIViewController {

    let arrowIcon = UIImage(systemName: "arrow.right")
    let vakifbankColor = UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 255/255.0)
    
    lazy var button_askQuestions: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" Sıkça Sorulan Sorular", for: .normal)
        button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Soru işareti simgesinin başlığa konumlandırılması
        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        
        return button
    }()
    
    lazy var button_libraryWeb: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(arrowIcon, for: .normal)
        button.setTitle(" Kütüphane", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = vakifbankColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        
        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        return button
    }()
    
    lazy var button_refectoryWeb: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(arrowIcon, for: .normal)
        button.setTitle(" Yemekhane", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = vakifbankColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        
        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        return button
    }()
    
    
    
    lazy var view_personInfo = Views(radius: 10, color: .white)
    
    lazy var label_name = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .black)
    lazy var label_university = Labels(textLabel: "" , fontLabel: .systemFont(ofSize: 17), textColorLabel: .black)
    
    lazy var imageView_person : UIImageView = {
        
        var imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = vakifbankColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
        
    }()
    
    
    lazy var button_changePassword : UIButton =  {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 10
        button.setTitle("Şifremi Güncelle", for: .normal)
        button.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        button.setTitleColor(vakifbankColor, for: .normal)
        button.tintColor = .black
        let spacing: CGFloat = 8.0
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left:spacing, bottom: 0, right: -spacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        
        
        return button
        
        
    }()
    
    lazy var button_logOut : UIButton = {
        
        let button = UIButton()
        button.tintColor = vakifbankColor
        button.setImage(UIImage(systemName: "rectangle.righthalf.inset.filled.arrow.right"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        return button
        
    }()
    
    // ViewModel
    private var personInfoViewModel: PersonInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personInfoViewModel = PersonInfoViewModel(view: self)
        setup()
        addTargetOnButton()
        configureWithExtension()
        
    }
    
    func addTargetOnButton(){
        button_askQuestions.addTarget(self, action: #selector(tapped_askQuestionButton), for: .touchUpInside)
        button_libraryWeb.addTarget(self, action: #selector(tapped_goLibraryWebSite), for: .touchUpInside)
        button_refectoryWeb.addTarget(self, action: #selector(tapped_goRefectoryWebSite), for: .touchUpInside)
        button_changePassword.addTarget(self, action: #selector(tapped_changePassword), for: .touchUpInside)
        button_logOut.addTarget(self, action: #selector(tapped_buttonLogOut), for: .touchUpInside)
        
        
    }
    
    // MARK : @objc func for button
    
    @objc func tapped_askQuestionButton(){
        let isCurrentlyHidden = !button_libraryWeb.isHidden
        if button_libraryWeb.isHidden == true {
            button_libraryWeb.isHidden = isCurrentlyHidden
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.button_refectoryWeb.isHidden = isCurrentlyHidden
            }
        }
        else {
            self.button_refectoryWeb.isHidden = isCurrentlyHidden
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.button_libraryWeb.isHidden = isCurrentlyHidden
            }
        }
    }
    
    @objc func tapped_changePassword(){
        tabBarController?.tabBar.isHidden = true
        (self.tabBarController as? TabBarController)?.hideTopView()
        let changePswAlert = ChangePasswordAlert()
        changePswAlert.delegateChangePassword = self
        changePswAlert.modalPresentationStyle = .overCurrentContext
        changePswAlert.providesPresentationContextTransitionStyle = true
        changePswAlert.definesPresentationContext = true
        changePswAlert.modalTransitionStyle = .crossDissolve
        self.present(changePswAlert, animated: true)
    }
    
    @objc func tapped_goLibraryWebSite(){
        self.personInfoViewModel.getUrl(selectedWebSite: "libraryUrl")
    }
    
    @objc func tapped_goRefectoryWebSite(){
        self.personInfoViewModel.getUrl(selectedWebSite: "refectoryUrl")
    }
    
    @objc func tapped_buttonLogOut(){
        self.makeAlertForLogOut()
        // URLCache'deki tüm önbelleği temizle
        URLCache.shared.removeAllCachedResponses()
    }
    
    func makeAlertForLogOut() {
        let alertController = UIAlertController(title: "Oturum Sonlandırılıyor", message:"Çıkış yapmak istediğinize emin misiniz?" , preferredStyle: .alert)
        let alertActionCancel = UIAlertAction(title: "Vazgeç", style: .cancel)
        let alerActionConfirm = UIAlertAction(title: "Onayla", style: .default) { _ in
            (self.tabBarController as? TabBarController)?.hideTopView()
            self.tabBarController?.tabBar.isHidden = true
            self.view.isHidden = true
            self.navigationController?.pushViewController(SignInViewController(), animated: true)
        }
        alertController.addAction(alertActionCancel)
        alertController.addAction(alerActionConfirm)
        self.present(alertController, animated: true)
        
    }

}
extension PersonInfoViewController: PersonInfoPageProtocol{
    
    func setUserID() -> String {
        let userID = (tabBarController as? TabBarController)?.userID ?? ""
        return userID
    }
    func setPersonInfoCompanent(personInfoModel: UserInfoModel) {
        label_name.text = "\(personInfoModel.userName ?? "-") \(personInfoModel.userSurname ?? "-")"
        label_university.text = "\(personInfoModel.university ?? "-")"
    }
    
    func goToWebsite(webSiteUrl: String) {
        guard let url = URL(string: webSiteUrl) else { return }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
}
extension PersonInfoViewController: ChangePasswordAlertDelegate{
    
    func cancel() {
        tabBarController?.tabBar.isHidden = false
        (tabBarController as? TabBarController)?.showTopView()
    }
    
    func getUserID(completion: @escaping (String) -> Void) {
        completion((tabBarController as? TabBarController)?.userID ?? "")
    }
    
    
}

extension PersonInfoViewController{
    func setup(){
        self.personInfoViewModel.getPersonInfo()
        (self.tabBarController as? TabBarController)?.showTopView()
        view.backgroundColor = .systemGray6
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    func configureWithExtension() {
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        view.addViews(view_personInfo, button_askQuestions, button_libraryWeb, button_refectoryWeb)
        view_personInfo.addViews(imageView_person, label_name, label_university, button_changePassword, button_logOut)
        
        
        view_personInfo.layer.shadowColor = UIColor.black.cgColor
        view_personInfo.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_personInfo.layer.shadowOpacity = 0.8
        view_personInfo.layer.shadowRadius = 5
        
        view_personInfo.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: screenHeight * 0.175,
            paddingLeft: screenWidth * 0.05,
            paddingRight: screenWidth * 0.05,
            height: screenHeight * 0.3
        )
        
        
        imageView_person.anchor(
            top: view_personInfo.topAnchor,
            left: view_personInfo.leftAnchor,
            paddingTop: screenHeight * 0.02,
            paddingLeft: screenWidth * 0.03,
            width: screenWidth * 0.2,
            height: screenWidth * 0.2
        )
        
        label_name.numberOfLines = 0
        label_name.lineBreakMode = .byWordWrapping
        label_name.anchor(
            top: imageView_person.topAnchor,
            left: imageView_person.rightAnchor,
            right: view_personInfo.rightAnchor,
            paddingTop: screenHeight * 0.02,
            paddingLeft: screenWidth * 0.02,
            paddingRight: screenWidth * 0.02
        )
        
        label_university.numberOfLines = 0
        label_university.lineBreakMode = .byWordWrapping
        label_university.anchor(
            top: label_name.bottomAnchor,
            left: imageView_person.rightAnchor,
            right: view_personInfo.rightAnchor,
            paddingTop: screenHeight * 0.01,
            paddingLeft: screenWidth * 0.02,
            paddingRight: screenWidth * 0.02
        )
        
        button_changePassword.anchor(
            left: view_personInfo.leftAnchor,
            bottom: view_personInfo.bottomAnchor,
            paddingBottom: screenHeight * 0.02,
            paddingLeft: screenWidth * 0.03,
            width: screenWidth * 0.5,
            height: 30
        )
        
        
        button_logOut.anchor(
            right: view_personInfo.rightAnchor,
            bottom: view_personInfo.bottomAnchor,
            paddingBottom: screenHeight * 0.02,
            paddingRight: screenWidth * 0.03,
            width: 30,
            height: 30
        )
        
        button_askQuestions.anchor(
            top: view_personInfo.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: screenHeight * 0.05,
            paddingLeft: screenWidth * 0.05,
            paddingRight: screenWidth * 0.05,
            height: 50
        )
        
        button_libraryWeb.anchor(
            top: button_askQuestions.bottomAnchor,
            left: button_askQuestions.leftAnchor,
            right: button_askQuestions.rightAnchor,
            paddingTop: screenHeight * 0.02,
            height: 50
        )
        
        button_refectoryWeb.anchor(
            top: button_libraryWeb.bottomAnchor,
            left: button_libraryWeb.leftAnchor,
            right: button_libraryWeb.rightAnchor,
            paddingTop: screenHeight * 0.02,
            height: 50
        )
    }
}
