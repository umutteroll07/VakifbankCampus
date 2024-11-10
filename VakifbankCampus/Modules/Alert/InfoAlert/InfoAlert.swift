//
//  InfoAlert.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 30.08.2024.
//

import UIKit

protocol BookCaseAlertDelegate {
    func cancelButtonTapped()
}

class InfoAlert: UIViewController {
    
    lazy var view_background = Views(radius: 30, color: .white)
    
    lazy var view_top = Views(radius: 30, color:UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 255/255.0) ,corners:[.topLeft,.topRight])
    
    lazy var imageView_logo = ImageViews(imageName: "vakifbankLogo")
    
    lazy var imageView_greenTag : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var imageView_yellowTag : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    lazy var imageView_redTag : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var imageView_blackTag : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    lazy var label_greenTag = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 15), textColorLabel: .systemGreen)
    lazy var label_yellowTag = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 15), textColorLabel: .systemYellow)
    lazy var label_redTag = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 15), textColorLabel: .systemRed)
    
    lazy var label_infoText = Labels(textLabel: "Kitap iade süresi uzatma işlemi ile teslim tarihiniz 15 gün ileriye alınmaktadır. Lisans ve önlisans öğrenciler her kitap için 1, toplamda ise 3 kitap uzatma hakkına sahiptir. İade süresi dolmuş kitaplar üzerinde süre uzatma işlemi yapılamamaktadır.", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    

    
    lazy var button_cancel : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tamam", for: .normal)
        button.backgroundColor = UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 255/255.0)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        
        return button
    }()

    var text_greenLabel = ""
    var text_yellowLabel = ""
    var text_redLabel = ""
    
    
    var delegate : BookCaseAlertDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
        animatedView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    

    
    func setupView(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addTargetOnButton()
        configureWithExt()
    }
    
    func addTargetOnButton(){
        button_cancel.addTarget(self, action: #selector(tapped_cancelButton), for: .touchUpInside)
    }
    
   
    func setLabelText() {
        label_greenTag.text = text_greenLabel
        label_yellowTag.text = text_yellowLabel
        label_redTag.text = text_redLabel
    }
    
    func animatedView() {
        view_background.alpha = 0
        self.view_background.frame.origin.y = self.view_background.frame.origin.y + 0
        UIView.animate(withDuration: 0.0, animations: { () -> Void in
            
            self.view_background.alpha = 1.0
            self.view_background.frame.origin.y = self.view_background.frame.origin.y - 0
            
        })
    }
    
    
    @objc func tapped_cancelButton() {
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
        
    }

   

}
extension InfoAlert{
    
    func configureWithExt() {
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        view.addViews(view_background)
        view_background.addViews(view_top, imageView_greenTag, label_greenTag, imageView_yellowTag, label_yellowTag, imageView_redTag, imageView_blackTag,label_redTag, button_cancel, label_infoText)
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

        imageView_greenTag.anchor(
            top: label_greenTag.topAnchor,
            left: view_background.leftAnchor,
            paddingTop: screenHeight * 0,
            paddingLeft: screenWidth * 0.02,
            width: 20,
            height: 20
        )

        label_greenTag.numberOfLines = 0
        label_greenTag.lineBreakMode = .byWordWrapping
        label_greenTag.anchor(
            top: view_top.bottomAnchor,
            left: imageView_greenTag.rightAnchor,
            right: view_background.rightAnchor,
            paddingTop: screenHeight * 0.07,
            paddingLeft: screenWidth * 0.02,
            paddingRight: screenWidth * 0.02
        )

        imageView_yellowTag.anchor(
            top: label_yellowTag.topAnchor,
            left: view_background.leftAnchor,
            paddingTop: screenHeight * 0,
            paddingLeft: screenWidth * 0.02,
            width: 20,
            height: 20
        )

        label_yellowTag.numberOfLines = 0
        label_yellowTag.lineBreakMode = .byWordWrapping
        label_yellowTag.anchor(
            top: label_greenTag.bottomAnchor,
            left: imageView_yellowTag.rightAnchor,
            right: view_background.rightAnchor,
            paddingTop: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.02,
            paddingRight: screenWidth * 0.02
        )

        imageView_redTag.anchor(
            top: label_redTag.topAnchor,
            left: view_background.leftAnchor,
            paddingTop: screenHeight * 0,
            paddingLeft: screenWidth * 0.02,
            width: 20,
            height: 20
        )

        label_redTag.numberOfLines = 0
        label_redTag.lineBreakMode = .byWordWrapping
        label_redTag.anchor(
            top: label_yellowTag.bottomAnchor,
            left: imageView_redTag.rightAnchor,
            right: view_background.rightAnchor,
            paddingTop: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.02,
            paddingRight: screenWidth * 0.02
        )
        
        imageView_blackTag.anchor(
            top: label_infoText.topAnchor,
            left: view_background.leftAnchor,
            paddingTop: screenHeight * 0,
            paddingLeft: screenWidth * 0.02,
            width: 20,
            height: 20
            
        )

        label_infoText.numberOfLines = 0
        label_infoText.lineBreakMode = .byWordWrapping
        label_infoText.anchor(
            top: label_redTag.topAnchor,
            left: imageView_blackTag.rightAnchor,
            right: view_background.rightAnchor,
            paddingTop: screenHeight * 0.13,
            paddingLeft: screenWidth * 0.02,
            paddingRight: screenWidth * 0.02
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
