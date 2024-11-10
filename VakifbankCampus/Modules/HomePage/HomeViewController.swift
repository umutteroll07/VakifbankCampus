//
//  HomeViewController.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit
import Lottie
import SafariServices

protocol HomePageProtocol : AnyObject{
    func setUserInfoLabel(userInfoModel: UserInfoModel)
    func setUserID() -> String?
    func setFoodMenu(foodMenuModel: FoodMenuModel)
}

final class HomeViewController: UIViewController{
    
    // MARK: - Properties
    
    // Colors
    let vakifbankColor = UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 1.0)
    
    // Lottie Animation
    var animationView = LottieAnimationView(name: "Loading")
    
    // Views
    lazy var topView = Views(radius: 0, color: vakifbankColor)
    lazy var topImageView = ImageViews(imageName: "vakifbankLogo")
    lazy var scrollView = UIScrollView()
    lazy var contentView = Views(radius: 0, color: .white)
    lazy var remainderView = Views(radius: 15, color: vakifbankColor)
    lazy var dailyMenuView = Views(radius: 100, color: .white, corners: [.topLeft, .topRight])
    
    // Labels
    lazy var labelRefectory = Labels(textLabel: "Yemekhane", fontLabel: .boldSystemFont(ofSize: 15), textColorLabel: vakifbankColor)
    lazy var lbl_dailyTitle = Labels(textLabel: "Bugünün Menüsü", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .black)
    lazy var lbl_food_1 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_food_2 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_food_3 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_food_4 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_name = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .black)
    lazy var lbl_iban = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_remainderText = Labels(textLabel: "Kullanılabilir Bakiye", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_remainderFloat = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 25), textColorLabel: .black)
    lazy var label_newsTitle = Labels(textLabel: "Haber Kampüste", fontLabel: .boldSystemFont(ofSize: 15), textColorLabel: vakifbankColor)
    
    // ImageViews
    lazy var imageView_foodImage = ImageViews(imageName: "foodImage")
    
    // CollectionView
    lazy var collectionView_news: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // ViewModel
    private var homePageViewModel: HomePageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureWithExtension()
        setDelegate()
        
        autoScrollCollectionView()
        configureAnimationView()
        
        homePageViewModel = HomePageViewModel(view: self)
        homePageViewModel.getNews()
        homePageViewModel.getUserInfo()
        homePageViewModel.getFoodMenu()
        
        setNewsView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        homePageViewModel.getUserInfo()
    }
    
    func setDelegate(){
        collectionView_news.dataSource = self
        collectionView_news.delegate = self
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(top: view.topAnchor,
                             left: view.leftAnchor,
                             right: view.rightAnchor,
                             bottom: view.bottomAnchor,
                             width: 200,
                             height: 200
        )
    }
    
    func setup(){
        addBorderColorOnView()
        toggle(isHidden: true)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .white
    }
    func setNewsView(){
        self.animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.collectionView_news.reloadData()
            self?.animationView.stop()
            self?.toggle(isHidden: false)
        }
    }
    
    
    func toggle(isHidden: Bool) {
        animationView.isHidden = !isHidden
        contentView.isHidden = isHidden
        contentView.isHidden = isHidden
        topView.isHidden = isHidden
        self.tabBarController?.tabBar.isHidden = isHidden
        tabBarController?.tabBar.isHidden = isHidden
        if isHidden{
            (tabBarController as? TabBarController)?.hideTopView()
        }
        else{
            (self.tabBarController as? TabBarController)?.showTopView()
        }
    }
    
    @objc func autoScroll() {
        guard let indexPath = collectionView_news.indexPathsForVisibleItems.first else {return}
        var nextIndex = indexPath.item + 1
        if nextIndex >= homePageViewModel.newsModelList.count {
            nextIndex = 0
        }
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        collectionView_news.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    func autoScrollCollectionView() {
        collectionView_news.isPagingEnabled = false
        let timer  = Timer(timeInterval: 3, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func configureWithExtension() {
        // Ekran boyutları
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        settingVariables()
        
        view.addViews(scrollView)
        scrollView.addSubview(contentView)
        contentView.addViews(remainderView, labelRefectory, dailyMenuView, collectionView_news, label_newsTitle)
        remainderView.addViews(lbl_name, lbl_iban, lbl_remainderText, lbl_remainderFloat)
        dailyMenuView.addViews(imageView_foodImage, lbl_dailyTitle, lbl_food_1, lbl_food_2, lbl_food_3, lbl_food_4)
        
        // Top view ve topImageView
        view.addSubview(topView)
        topView.addSubview(topImageView)
        
        topView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            height: screenHeight * 0.15
        )
        
        topImageView.anchor(
            left: topView.leftAnchor,
            right: topView.rightAnchor,
            bottom: topView.bottomAnchor,
            paddingBottom: 10,
            paddingLeft: screenWidth * 0.25,
            paddingRight: screenWidth * 0.25,
            height: 30
        )
        
        // ScrollView
        view.bringSubviewToFront(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.anchor(
            top: topView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            bottom: view.bottomAnchor,
            paddingTop: screenHeight * 0.001
        )
        
        // ContentView
        contentView.anchor(
            top: scrollView.topAnchor,
            left: scrollView.leftAnchor,
            right: scrollView.rightAnchor,
            bottom: scrollView.bottomAnchor,
            paddingTop: 0,
            paddingBottom: 0,
            paddingLeft: 0,
            paddingRight: 0,
            width: view.bounds.size.width,
            height: 1035
        )
        
        // RemainderView
        remainderView.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 20,
            paddingLeft: 10,
            paddingRight: 10,
            height: 150
        )
        
        lbl_name.anchor(
            top: remainderView.topAnchor,
            left: remainderView.leftAnchor,
            right: remainderView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 30,
            height: 20
        )
        
        lbl_iban.anchor(
            top: lbl_name.bottomAnchor,
            left: remainderView.leftAnchor,
            right: remainderView.rightAnchor,
            paddingTop: 10,
            paddingLeft: 30,
            height: 20
        )
        
        lbl_remainderText.anchor(
            left: remainderView.leftAnchor,
            right: remainderView.rightAnchor,
            bottom: remainderView.bottomAnchor,
            paddingBottom: 20,
            paddingLeft: 30,
            height: 20
        )
        
        lbl_remainderFloat.anchor(
            right: remainderView.rightAnchor,
            bottom: remainderView.bottomAnchor,
            paddingBottom: 20,
            paddingRight: 20,
            height: 20
        )
        
        // Label refectory ve daily menu view
        labelRefectory.anchor(
            top: remainderView.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 15,
            height: 20
        )
        
        dailyMenuView.anchor(
            top: labelRefectory.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 0,
            paddingLeft: 10,
            paddingRight: 10,
            height: 350
        )
        
        // Daily menu view içindeki öğeler
        imageView_foodImage.anchor(
            top: dailyMenuView.safeAreaLayoutGuide.topAnchor,
            left: dailyMenuView.leftAnchor,
            right: dailyMenuView.rightAnchor,
            paddingTop: 10,
            paddingLeft: 0,
            paddingRight: 0,
            width: 60,
            height: 75
        )
        
        lbl_dailyTitle.anchor(
            top: imageView_foodImage.bottomAnchor,
            left: dailyMenuView.leftAnchor,
            right: dailyMenuView.rightAnchor,
            paddingTop: 5,
            paddingLeft: 0,
            paddingRight: 0,
            height: 25
        )
        
        lbl_food_1.anchor(
            top: lbl_dailyTitle.bottomAnchor,
            left: dailyMenuView.leftAnchor,
            right: dailyMenuView.rightAnchor,
            paddingTop: 50,
            paddingLeft: 50,
            paddingRight: 50,
            height: 20
        )
        
        lbl_food_2.anchor(
            top: lbl_food_1.bottomAnchor,
            left: dailyMenuView.leftAnchor,
            right: dailyMenuView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 50,
            paddingRight: 50,
            height: 20
        )
        
        lbl_food_3.anchor(
            top: lbl_food_2.bottomAnchor,
            left: dailyMenuView.leftAnchor,
            right: dailyMenuView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 50,
            paddingRight: 50,
            height: 20
        )
        
        lbl_food_4.anchor(
            top: lbl_food_3.bottomAnchor,
            left: dailyMenuView.leftAnchor,
            right: dailyMenuView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 50,
            paddingRight: 50,
            height: 20
        )
        
        // News label ve collection view konumlandırma
        label_newsTitle.anchor(
            top: dailyMenuView.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 15,
            height: 20
        )
        
        collectionView_news.translatesAutoresizingMaskIntoConstraints = false
        collectionView_news.anchor(
            top: label_newsTitle.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 0,
            paddingLeft: 10,
            paddingRight: 10,
            height: 325
        )
    }
    
    func settingVariables(){
        imageView_foodImage.contentMode = .scaleAspectFit
        lbl_dailyTitle.textAlignment = .center
        lbl_food_1.textAlignment = .center
        lbl_food_2.textAlignment = .center
        lbl_food_3.textAlignment = .center
        lbl_food_4.textAlignment = .center
    }
    func addBorderColorOnView(){
        remainderView.layer.borderColor = UIColor.black.cgColor
        remainderView.layer.borderWidth = 1.0
        
        dailyMenuView.layer.borderColor = vakifbankColor.cgColor
        dailyMenuView.layer.borderWidth = 2
        
        collectionView_news.layer.borderColor = vakifbankColor.cgColor
        collectionView_news.layer.borderWidth = 2
        
    }
    
    func addDashedUnderline(to label: UILabel) {
        let border = CAShapeLayer()
        let frameSize = label.frame.size
        let shapeRect = CGRect(x: 0, y: frameSize.height - 1, width: frameSize.width, height: 1)
        
        border.bounds = shapeRect
        border.position = CGPoint(x: frameSize.width / 2, y: frameSize.height)
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor = UIColor.gray.cgColor
        border.lineWidth = 0.5
        border.lineJoin = CAShapeLayerLineJoin.round
        border.lineDashPattern = [10, 10] // [çizgi uzunluğu, boşluk uzunluğu]
        
        let path = UIBezierPath(rect: shapeRect)
        border.path = path.cgPath
        
        label.layer.addSublayer(border)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addDashedUnderline(to: lbl_food_1)
        addDashedUnderline(to: lbl_food_2)
        addDashedUnderline(to: lbl_food_3)
        addDashedUnderline(to: lbl_food_4)
    }
    
}

extension HomeViewController: HomePageProtocol {

    func setUserID() -> String? {
        let userID = (tabBarController as? TabBarController)?.userID ?? ""
        return userID
    }
    
    func setFoodMenu(foodMenuModel: FoodMenuModel) {
        lbl_food_1.text = foodMenuModel.food1
        lbl_food_2.text = foodMenuModel.food2
        lbl_food_3.text = foodMenuModel.food3
        lbl_food_4.text = foodMenuModel.food4
    }
    
    func setUserInfoLabel(userInfoModel: UserInfoModel) {
        let name = userInfoModel.userName ?? ""
        let surname = userInfoModel.userSurname ?? ""
        let iban = userInfoModel.user_iban ?? ""
        let remainder = String(format: "%.2f", userInfoModel.user_remainder ?? 0.0)
        
        lbl_name.text = "\(name) \(surname)"
        lbl_iban.text = iban
        lbl_remainderFloat.text = "\(remainder) TL"
    }
    
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homePageViewModel.newsModelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView_news.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.identifier, for: indexPath) as! NewsCollectionViewCell
        let news = homePageViewModel.newsModelList[indexPath.row]
        cell.setCell(news: news)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let news = homePageViewModel.newsModelList[indexPath.row]
        let urlAddress = news.url
        
        guard let url = URL(string: urlAddress ) else { return }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
}


extension HomeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Ekran boyutları
        let screenWidth = UIScreen.main.bounds.width
        let height = collectionView_news.frame.height
        
        return CGSize(width: screenWidth , height: height)
    }
}
