//
//  TabBarController.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    var userID : String?
    
    let vakifbankColor = UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 255/255.0)
    lazy var topView = Views(radius: 0, color: vakifbankColor )
    lazy var topImageView = ImageViews(imageName: "vakifbankLogo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupTabs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    func configureWithExt() {
        // Ekran boyutları
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        view.addSubview(topView)
        topView.addSubview(topImageView)
        
        topView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height:screenHeight * 0.15
        )
        topImageView.anchor(
            left: topView.leftAnchor,
            right: topView.rightAnchor,
            bottom:topView.bottomAnchor,
            paddingBottom: 10,
            paddingLeft: screenWidth * 0.25 ,
            paddingRight: screenWidth * 0.25 ,
            height: 30
        )
    }
    
    func setup() {
        configureWithExt()
        self.tabBar.backgroundColor = .white
        self.tabBar.tintColor = vakifbankColor
    }
    
    private func setupTabs(){
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = true
        
        let home = self.createNav(with: "Anasayfa", and: UIImage(systemName: "house"), vc: HomeViewController())
        let refectory = self.createNav(with: "Yemekhane", and: UIImage(systemName: "fork.knife"), vc: RefectoryViewController())
        let library = self.createNav(with: "Kütüphane", and: UIImage(systemName: "book.closed"), vc: LibraryViewController())
        let personInfo = self.createNav(with: "Bilgilerim", and: UIImage(systemName: "person"), vc: PersonInfoViewController())
        self.setViewControllers([home,refectory,library,personInfo], animated: true)
    }
    
    private func createNav(with title: String, and image:UIImage? , vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        return nav
    }
    
    func hideTopView() {
        topView.isHidden = true
    }
    
    func showTopView() {
        topView.isHidden = false
    }
}
