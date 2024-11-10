//
//  RefectoryViewController.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit
import Lottie

protocol RefectoryVCProtocol: AnyObject{
    func setFoodMenu(foodMenuModel: FoodMenuModel)
    func setUserID() -> String
    func makePaymentAlert(title: String, message: String)
    
}

class RefectoryViewController: UIViewController {
    
    // Settings Picker
    let days = Array(1...31)
    let months = Array(1...12)
    let years = Array(2020...2030)
    
    var selectedDay = 1
    var selectedMonth = 1
    var selectedYear = 1900
    
    
    let vakifbankColor = UIColor(red: 246/255.0, green: 178/255.0, blue: 5/255.0, alpha: 255/255.0)
    var animationView = LottieAnimationView(name: "AnimationQR")
    
    lazy var button_payFood : UIButton =  {
        let button = UIButton(type: .system)
        button.backgroundColor = vakifbankColor
        button.layer.cornerRadius = 20
        button.setTitle("QR ile Ödeme/Turnike Geçiş", for: .normal)
        button.setImage(UIImage(systemName: "qrcode.viewfinder"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .black
        let spacing: CGFloat = 8.0
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left:spacing, bottom: 0, right: -spacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        return button
    }()
    
    lazy var foodMenuView = Views(radius: 100, color: .white,corners: [.topLeft,.topRight])
    lazy var imageView_foodImage = ImageViews(imageName: "foodImage")
    lazy var lbl_dailyTitle = Labels(textLabel: "Menü", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .black)
    
    lazy var lbl_food_1 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_food_2 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_food_3 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    lazy var lbl_food_4 = Labels(textLabel: "---", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    
    
    lazy var textField_selectDate : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Bir tarih seçiniz"
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        textField.inputView = pickerView
        textField.inputAccessoryView = createPickerHeaderView()
        return textField
    }()
    
    let pickerView = UIPickerView()
    // ViewModel
    private var refectoryViewModel: RefectoryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegate()
        setup()
        configureAnimationView()
        addTargetOnButton()
        
        
        refectoryViewModel = RefectoryViewModel(view: self)
        refectoryViewModel.updateCheckPayFood()
        refectoryViewModel.getFoodMenu()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setEmptyMenuAndDate()
        self.view.endEditing(true)
        textField_selectDate.resignFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setLabelUI()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField_selectDate.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func setPickerDelegate(){
        // PickerView ayarları
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func addTargetOnButton(){
        button_payFood.addTarget(self, action: #selector(tapped_payFood), for: .touchUpInside)
    }
    
    func updateTextField() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy" // Tarih formatını ayarlama
        dateFormatter.locale = Locale(identifier: "tr_TR") // Türkçe dil ayarı
        
        let dateFormetterForFirebase = DateFormatter()
        dateFormetterForFirebase.dateFormat = "dd/MM/yyyy"
        if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)) {
            textField_selectDate.text = dateFormatter.string(from: date)
            
            guard let refectoryViewModel = refectoryViewModel else {
                print("refectoryViewModel is nil")
                return
            }
            refectoryViewModel.selectedDate = dateFormetterForFirebase.string(from: date)
            refectoryViewModel.getFoodMenu()
        }
    }
    
    func toggle(isHidden: Bool) {
        animationView.isHidden = !isHidden
        button_payFood.isHidden = isHidden
        foodMenuView.isHidden = isHidden
        textField_selectDate.isHidden = isHidden
        self.tabBarController?.tabBar.isHidden = isHidden
        tabBarController?.tabBar.isHidden = isHidden
        if isHidden{
            (tabBarController as? TabBarController)?.hideTopView()
        }
        else{
            (self.tabBarController as? TabBarController)?.showTopView()
        }
    }

    
    // @objc funcs for buttons
    @objc func tapped_payFood() {
        
        let qrVC = QRScannerController()
        qrVC.titleString = "Lütfen turnike üzerinde bulunan QR kodunu taratınız"
        toggle(isHidden: true)
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigationController?.pushViewController(qrVC, animated: true)
            qrVC.isProcessing = false
            self?.animationView.stop()
            self?.toggle(isHidden: false)
            self?.tabBarController?.tabBar.isHidden = true
            (self?.tabBarController as? TabBarController)?.hideTopView()
        }

        qrVC.getQrValueString { [weak self] qrCodeValue in
            guard let self = self else { return }
            let qrCodeUrlValue = "https://scanned.page/66b33d0a7db42"
            if qrCodeValue ==  qrCodeUrlValue{
                qrVC.isProcessing = true
                qrVC.captureSession.stopRunning()
                self.refectoryViewModel.updateToUserRemainder()
            }
            else{
                self.makePaymentAlert(title: "İşlem Başarısız", message:"Geçersiz bir tarama işleminde bulundunuz.")
            }
        }
    }
}

extension RefectoryViewController: RefectoryVCProtocol{
    
    
    func setUserID() -> String {
        let userID = (tabBarController as? TabBarController)?.userID ?? ""
        return userID
    }
    
    func setFoodMenu(foodMenuModel: FoodMenuModel) {
        lbl_food_1.text = foodMenuModel.food1
        lbl_food_2.text = foodMenuModel.food2
        lbl_food_3.text = foodMenuModel.food3
        lbl_food_4.text = foodMenuModel.food4
    }
    
    func makePaymentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Çıkış", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
            (self.tabBarController as? TabBarController)?.showTopView()
        }
        alert.addAction(alertAction)
        self.present(alert,animated: true)
        
        if let alertView = alert.view.subviews.first?.subviews.first?.subviews.first {
            alertView.backgroundColor = vakifbankColor
            alertView.layer.cornerRadius = 15
            alertView.layer.masksToBounds = true
        }
    }
    
}

extension RefectoryViewController {
    
    func setup(){
        toggle(isHidden: false)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .white
        configureWithExtension()
        addBorderColorOnView()
        settingVariables()
        setEmptyMenuAndDate()
        
        updateTextField()
        textField_selectDate.isUserInteractionEnabled = true
        
    }
    func configureWithExtension() {
        // Ekran boyutu
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        view.addViews(button_payFood, foodMenuView, textField_selectDate)
        foodMenuView.addViews(imageView_foodImage, lbl_dailyTitle, lbl_food_1, lbl_food_2, lbl_food_3, lbl_food_4)
        
        // button_payFood ayarları
        button_payFood.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: screenHeight * 0.175,
            paddingLeft: screenWidth * 0.125,
            paddingRight: screenWidth * 0.125,
            height: 50
        )
        
        // textField_selectDate ayarları
        textField_selectDate.anchor(
            top: button_payFood.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: screenHeight * 0.1,
            paddingLeft: screenWidth * 0.125,
            paddingRight: screenWidth * 0.125,
            height: 30
        )
        
        // foodMenuView ayarları
        foodMenuView.anchor(
            top: textField_selectDate.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 5,
            paddingLeft: 10,
            paddingRight: 10,
            height: screenHeight * 0.5
        )
        
        // imageView_foodImage ayarları
        imageView_foodImage.anchor(
            top: foodMenuView.topAnchor,
            left: foodMenuView.leftAnchor,
            right: foodMenuView.rightAnchor,
            paddingTop: 25,
            paddingLeft: 0,
            paddingRight: 0,
            width: 60,
            height: 75
        )
        
        // lbl_dailyTitle ayarları
        lbl_dailyTitle.anchor(
            top: imageView_foodImage.bottomAnchor,
            left: foodMenuView.leftAnchor,
            right: foodMenuView.rightAnchor,
            paddingTop: 5,
            paddingLeft: 0,
            paddingRight: 0,
            height: 25
        )
        
        // Yemek başlıklarının ayarları
        lbl_food_1.anchor(
            top: lbl_dailyTitle.bottomAnchor,
            left: foodMenuView.leftAnchor,
            right: foodMenuView.rightAnchor,
            paddingTop: screenHeight * 0.04,
            paddingLeft: screenWidth * 0.125,
            paddingRight: screenWidth * 0.125,
            height: 20
        )
        
        lbl_food_2.anchor(
            top: lbl_food_1.bottomAnchor,
            left: foodMenuView.leftAnchor,
            right: foodMenuView.rightAnchor,
            paddingTop: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.125,
            paddingRight: screenWidth * 0.125,
            height: 20
        )
        
        lbl_food_3.anchor(
            top: lbl_food_2.bottomAnchor,
            left: foodMenuView.leftAnchor,
            right: foodMenuView.rightAnchor,
            paddingTop: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.125,
            paddingRight: screenWidth * 0.125,
            height: 20
        )
        
        lbl_food_4.anchor(
            top: lbl_food_3.bottomAnchor,
            left: foodMenuView.leftAnchor,
            right: foodMenuView.rightAnchor,
            paddingTop: screenHeight * 0.03,
            paddingLeft: screenWidth * 0.125,
            paddingRight: screenWidth * 0.125,
            height: 20
        )
    }
    func settingVariables(){
        imageView_foodImage.contentMode = .scaleAspectFit
        lbl_dailyTitle.textAlignment = .center
        lbl_dailyTitle.textAlignment = .center
        lbl_food_1.textAlignment = .center
        lbl_food_2.textAlignment = .center
        lbl_food_3.textAlignment = .center
        lbl_food_4.textAlignment = .center
        
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
    
    func setEmptyMenuAndDate() {
        textField_selectDate.text = ""
        lbl_food_1.text = "---"
        lbl_food_2.text = "---"
        lbl_food_3.text = "---"
        lbl_food_4.text = "---"
    }
    func addBorderColorOnView(){
        foodMenuView.layer.borderColor = vakifbankColor.cgColor
        foodMenuView.layer.borderWidth = 2
        
        textField_selectDate.layer.borderColor = vakifbankColor.cgColor
        textField_selectDate.layer.borderWidth = 2
    }
    
    func setLabelUI(){
        addDashedUnderline(to: lbl_food_1)
        addDashedUnderline(to: lbl_food_2)
        addDashedUnderline(to: lbl_food_3)
        addDashedUnderline(to: lbl_food_4)
    }
    
    func createPickerHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray3
        let headerHeight: CGFloat = 30
        let headerWidth = pickerView.frame.width
        headerView.frame = CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight)
        
        
        let dayLabel = UILabel()
        dayLabel.text = "Gün"
        dayLabel.textAlignment = .center
        
        let monthLabel = UILabel()
        monthLabel.text = "Ay"
        monthLabel.textAlignment = .center
        
        let yearLabel = UILabel()
        yearLabel.text = "Yıl"
        yearLabel.textAlignment = .center
        
        headerView.addViews(dayLabel,monthLabel,yearLabel)
        
        dayLabel.anchor(
            top:headerView.topAnchor,
            left: headerView.leftAnchor,
            bottom: headerView.bottomAnchor,
            paddingLeft: 50
        )
        
        monthLabel.anchor(
            top: headerView.topAnchor,
            left: headerView.leftAnchor,
            right: headerView.rightAnchor,
            bottom: headerView.bottomAnchor,
            width: 30
        )
        yearLabel.anchor(
            top:headerView.topAnchor,
            right: headerView.rightAnchor,
            bottom: headerView.bottomAnchor,
            paddingRight: 50
        )
        
        
        return headerView
    }
    
    
    func configureAnimationView() {
        view.addViews(animationView)
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor,width: 200,height: 200)
    }
    


}

extension RefectoryViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    // UIPickerViewDataSource metotları
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // Gün, Ay, Yıl
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return days.count
        case 1: return months.count
        case 2: return years.count
        default: return 0
        }
    }
    
    // UIPickerViewDelegate metotları
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(days[row])"
        case 1: return "\(months[row])"
        case 2: return "\(years[row])"
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0: selectedDay = days[row]
        case 1: selectedMonth = months[row]
        case 2: selectedYear = years[row]
        default: break
        }
        
        self.lbl_food_1.text = "---"
        self.lbl_food_2.text = "---"
        self.lbl_food_3.text = "---"
        self.lbl_food_4.text = "---"
        
        updateTextField()
    }
    func setDatePicker() {
        // Bugünün tarihi ile başlangıç değerlerini ayarla
        let today = Date()
        let calendar = Calendar.current
        selectedDay = calendar.component(.day, from: today)
        selectedMonth = calendar.component(.month, from: today)
        selectedYear = calendar.component(.year, from: today)
        
        // PickerView'daki seçili satırları güncelle
        pickerView.selectRow(days.firstIndex(of: selectedDay) ?? 0, inComponent: 0, animated: false)
        pickerView.selectRow(months.firstIndex(of: selectedMonth) ?? 0, inComponent: 1, animated: false)
        pickerView.selectRow(years.firstIndex(of: selectedYear) ?? 0, inComponent: 2, animated: false)
    }
    
    
}
