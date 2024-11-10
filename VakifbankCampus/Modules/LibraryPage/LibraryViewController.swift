//
//  LibraryViewController.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import UIKit
import Lottie

protocol LibraryVCProtocol: AnyObject{
    func setUserID() -> String
    func setEmptyBookCaseSettings(value:Bool)
    func startActivityIndicator()
    func stopActivityIndicator()
    func takeLoanedBook(booksModel: BooksModel)
    func reloadDataCollectionView_reservedBook()
    func reloadDataCollectionView_bookcase()
    func setFilteredBooks(allBooksModel: [BooksModel])
    func setAllReservedBookIdList(allReservedBooks: [String])
    func setDebtLabelText(totalDebt: String, showFine:String)
    func tappedPayLateFine()
    func hiddenPayButton(isHidden: Bool)
    func makeAlert(title: String, message: String)
}

class LibraryViewController: UIViewController {
    
    // MARK : ViewControllers
    let qrVC = QRScannerController()
    private var selectedBookID = String()
    
    // MARK : BookModelList for SearchBar
    var filteredBooks = [BooksModel]()
    var allBooksModel = [BooksModel]()
    var allReservedBooks = [String]()
    
    // MARK : ViewModels
    private var libraryViewModel: LibraryViewModel!
    
    let vakifbankColor = UIColor(red: 253/255.0, green: 185/255.0, blue: 19/255.0, alpha: 255/255.0)
    var animationView = LottieAnimationView(name: "AnimationQR")
    lazy var topView = Views(radius: 0, color: vakifbankColor )
    lazy var topImageView = ImageViews(imageName: "vakifbankLogo")
    
    
    
    lazy var button_addBookLibrary : UIButton =  {
        let button = UIButton(type: .system)
        button.backgroundColor = vakifbankColor
        button.layer.cornerRadius = 20
        button.setTitle("Ödünç Kitap Al", for: .normal)
        button.setImage(UIImage(systemName: "qrcode.viewfinder"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .black
        let spacing: CGFloat = 8.0
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left:spacing, bottom: 0, right: -spacing)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        return button
    }()
    
    
    
    lazy var scrollView = UIScrollView()
    lazy var contentView = Views(radius: 0, color: .white)
    lazy var label_titleBookcase = Labels(textLabel: "Kütüphanen", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel:vakifbankColor )
    
    lazy var button_infoLibrary :  UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var view_backgroundCollectionView = Views(radius: 100, color:.white,corners:[.topLeft,.topRight])
    
    lazy var label_emptyLibrary = Labels(textLabel: "Kütüphanenizde kayıtlı kitap bulunmamaktadır", fontLabel: .boldSystemFont(ofSize: 15), textColorLabel: .black)
    
    lazy var collectionView_bookcase : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectinView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectinView.backgroundColor = .white
        collectinView.register(BooksCollectionViewCell.self, forCellWithReuseIdentifier: BooksCollectionViewCell.identifier)
        return collectinView
    }()
    
    
    
    lazy var label_titleReserveBook = Labels(textLabel: "Kitap Ayırt", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: vakifbankColor )
    
    lazy var view_reserveBook = Views(radius: 0, color: .white)
    
    lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Kitap ara"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    
    lazy var collectionView_reserveBook : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(BooksCollectionViewCell.self, forCellWithReuseIdentifier: BooksCollectionViewCell.identifier)
        return collectionView
    }()
    
    lazy var view_backgroundFine = Views(radius: 0, color: .white)
    
    lazy var label_titleFine = Labels(textLabel: "Ceza İşlemleri", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel:vakifbankColor)
    
    lazy var label_showFine = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 30), textColorLabel: .black)
    lazy var label_showFine2 = Labels(textLabel: "TL ödenmemiş borcunuz bulunmaktadır.", fontLabel: .systemFont(ofSize: 15), textColorLabel: .black)
    
    lazy var button_payFine : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setTitle("Hemen Öde", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = vakifbankColor
        return button
    }()
    
    lazy var button_infoPay  : UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "turkishMoney"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        libraryViewModel = LibraryViewModel(view: self)
        setDelegate()
        setup()
        configureActivityIndicator()
        addTargetOnButton()
        libraryViewModel.calculateDebtForBooks()
        reloadCollectionView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        libraryViewModel.getAllBookIdFromAllStudent()
        libraryViewModel.addReservedBookToBookcase()
        libraryViewModel.getUsersBooksContens()
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func setReserveCVViewDidLoad(){
        libraryViewModel.getAllBookFromFirestore { bool in
            print("fetchAllBook is succes")
            self.filteredBooks = self.allBooksModel
        }
        
    }
    
    func setup(){
        view.backgroundColor = .white
        configureWithExtension()
        addBorderColorOnView()
        configureAnimationView()
        toggle(isHidden: false)
        closeKeyBoard()
        setReserveCVViewDidLoad()
        
    }
    func setDelegate(){
        collectionView_bookcase.delegate = self
        collectionView_bookcase.dataSource = self
        
        collectionView_reserveBook.delegate = self
        collectionView_reserveBook.dataSource = self
        
        searchBar.delegate = self
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
    
    func closeKeyBoard(){
        // close keybord for searcBar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    func addTargetOnButton(){
        self.button_infoLibrary.addTarget(self, action: #selector(tapped_buttonBookLibraryInfo), for: .touchUpInside)
        self.button_addBookLibrary.addTarget(self, action: #selector(tapped_addBookButton), for: .touchUpInside)
        self.button_payFine.addTarget(self, action: #selector(tapped_payFineButton), for: .touchUpInside)
    }
    
    // MARK : @objc func for button
    @objc func tapped_addBookButton(){
        toggle(isHidden: true)
        animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigationController?.pushViewController(self?.qrVC ?? QRScannerController(), animated: true)
            self?.qrVC.isProcessing = false
            self?.qrVC.titleString = "Lütfen kitabın arka kısmında bulunan QR Kodu taratınız"
            self?.animationView.stop()
            self?.toggle(isHidden: false)
            self?.tabBarController?.tabBar.isHidden = true
            (self?.tabBarController as? TabBarController)?.hideTopView()
        }
        
        qrVC.getQrValueString { [weak self] qrCodeValue in
            guard let self = self else { return }
            self.libraryViewModel.getBookWithQrValue(qrCodeValue: qrCodeValue)
            
        }
    }
    
    @objc func tapped_payFineButton(){
        print("tappedPayFine")
        self.libraryViewModel.payLateFee()
        
    }
    
    @objc func tapped_buttonBookLibraryInfo(){
        print("tapped info button")
        tabBarController?.tabBar.isHidden = true
        (tabBarController as? TabBarController)?.hideTopView()
        let infoAlert = InfoAlert()
        infoAlert.text_greenLabel = "etiketi kitap iade süreniz için en az 5 gün kaldığını gösterir."
        infoAlert.text_yellowLabel = "etiketi kitap iade süreniz için 5 günden daha kısa bir sürenin kaldığını gösterir."
        infoAlert.text_redLabel = "etiketi kitap iade sürenizin dolduğunu gösterir. İade süresi geçmiş her kitap için geciken gün sayısı kadar gecikme ücretine tabi tutulacaksınız."
        infoAlert.delegate = self
        infoAlert.modalPresentationStyle = .overCurrentContext
        infoAlert.providesPresentationContextTransitionStyle = true
        infoAlert.definesPresentationContext = true
        infoAlert.modalTransitionStyle = .crossDissolve
        self.present(infoAlert, animated: true)
        
        
    }
    
}

extension LibraryViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            self.libraryViewModel.getAllBookFromFirestore { bool in
                self.filteredBooks = self.allBooksModel
                self.collectionView_reserveBook.reloadData()
            }
            
            return
        }
        self.libraryViewModel.getAllBookFromFirestore { bool in
            self.filteredBooks = self.allBooksModel.filter { book in
                book.title.lowercased().contains(searchText.lowercased())
            }
            self.collectionView_reserveBook.reloadData()
        }
        
    }
}

extension LibraryViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == collectionView_bookcase {
            return libraryViewModel.userBooksModelList.count
        }
        
        else if collectionView == collectionView_reserveBook {
            return filteredBooks.count
        }
        else {
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  collectionView == collectionView_bookcase{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BooksCollectionViewCell.identifier, for: indexPath) as! BooksCollectionViewCell
            cell.setBookCell(book: libraryViewModel.userBooksModelList, indexpath: indexPath.row)
            self.libraryViewModel.setColorTag(bookID: libraryViewModel.userBooksModelList[indexPath.row].id ?? "") { color in
                cell.imageview_returnStatus.tintColor = color
            }
            return cell
        }
        
        else if collectionView == collectionView_reserveBook{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BooksCollectionViewCell.identifier, for: indexPath) as! BooksCollectionViewCell
            
            cell.setBookCell(book: self.filteredBooks, indexpath: indexPath.row)
            // used or notUsed --> for books
            let currentBookId = self.filteredBooks[indexPath.row].id!
            if self.libraryViewModel.allBookIdFromAllStudent.contains(currentBookId) || allReservedBooks.contains(currentBookId) {
                cell.imageview_returnStatus.tintColor = .systemRed
            }
            else {
                cell.imageview_returnStatus.tintColor = .systemGreen
            }
            return cell
        }
        else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionView_bookcase {
            tabBarController?.tabBar.isHidden = true
            (self.tabBarController as? TabBarController)?.hideTopView()
            
            let selectedBookId = libraryViewModel.userBooksModelList[indexPath.row].id!
            self.selectedBookID = selectedBookId
            let bookDetailsAlertVC = BookDetailsAlert()
            
            self.libraryViewModel.getExtendTimeControl(bookID: selectedBookId) { checkExtendTime in
                bookDetailsAlertVC.checkExtendTime = checkExtendTime
            }
            self.libraryViewModel.getDeadline(bookID: selectedBookId) { deadline in
                bookDetailsAlertVC.bookDeadline = deadline
                bookDetailsAlertVC.bookModel = self.libraryViewModel.userBooksModelList[indexPath.row]
                self.libraryViewModel.checkBookRemainderDay(bookID: self.libraryViewModel.userBooksModelList[indexPath.row].id ?? "", complation: { timeOutValue in
                    bookDetailsAlertVC.checkBookRemainderDayControl = !timeOutValue
                })
                bookDetailsAlertVC.delegateBookDetailsAlertVC = self
                bookDetailsAlertVC.modalPresentationStyle = .overCurrentContext
                bookDetailsAlertVC.providesPresentationContextTransitionStyle = true
                bookDetailsAlertVC.definesPresentationContext = true
                bookDetailsAlertVC.modalTransitionStyle = .crossDissolve
                self.present(bookDetailsAlertVC, animated: true)
            }
        }
        else if collectionView == collectionView_reserveBook{
            tabBarController?.tabBar.isHidden = true
            (self.tabBarController as? TabBarController)?.hideTopView()
            
            let reserveBookVC = ReserveBookAlert()
            reserveBookVC.studentID = setUserID()
            // used or notUsed --> for books
            let currentBookId = self.filteredBooks[indexPath.row].id!
            
            if self.libraryViewModel.allBookIdFromAllStudent.contains(currentBookId) || allReservedBooks.contains(currentBookId) {
                reserveBookVC.bookSituation = "Ödünç Alınmış"
                reserveBookVC.button_bookActivity.isEnabled = false
                reserveBookVC.button_bookActivity.backgroundColor = .systemRed
            } else {
                reserveBookVC.bookSituation = "Kütüphanede Mevcut"
                reserveBookVC.button_bookActivity.backgroundColor = .systemGreen
            }
            
            reserveBookVC.bookModel = self.filteredBooks[indexPath.row]
            print("erollar: \(filteredBooks[indexPath.row].title)")
            reserveBookVC.delegateReserveBook = self
            reserveBookVC.modalPresentationStyle = .overCurrentContext
            reserveBookVC.providesPresentationContextTransitionStyle = true
            reserveBookVC.definesPresentationContext = true
            reserveBookVC.modalTransitionStyle = .crossDissolve
            self.present(reserveBookVC, animated: true)
        }
    }
}

// MARK : Protocol
extension LibraryViewController: LibraryVCProtocol{
    
    func reloadDataCollectionView_reservedBook() {
        DispatchQueue.main.async {
            self.collectionView_reserveBook.reloadData()
        }
    }
    func reloadDataCollectionView_bookcase() {
        DispatchQueue.main.async {
            self.collectionView_bookcase.reloadData()
        }
    }
    
    func setFilteredBooks(allBooksModel: [BooksModel]) {
        self.allBooksModel = allBooksModel
    }
    
    func setUserID() -> String {
        let userID = (tabBarController as? TabBarController)?.userID ?? ""
        return userID
    }
    
    func startActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    func stopActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    func setEmptyBookCaseSettings(value: Bool) {
        if value{
            self.label_emptyLibrary.isHidden = false
            self.activityIndicator.stopAnimating()
        }
        else {
            self.label_emptyLibrary.isHidden = true
        }
    }
    
    func takeLoanedBook(booksModel: BooksModel) {
        
        self.qrVC.captureSession.stopRunning()
        self.navigationController?.popViewController(animated: true)
        let takeBookWithQrAlert = TakeBookWithQrAlert()
        
        takeBookWithQrAlert.userID = self.setUserID()
        
        if self.libraryViewModel.allBookIdFromAllStudent.contains(booksModel.id ?? "" ) || self.libraryViewModel.reservedBookID.contains(booksModel.id ?? "") {
            takeBookWithQrAlert.bookSituation = "Ödünç Alınmış"
            takeBookWithQrAlert.button_bookActivity.isEnabled = false
            takeBookWithQrAlert.button_bookActivity.backgroundColor = .systemRed
        } else {
            takeBookWithQrAlert.bookSituation = "Kütüphanede Mevcut"
            takeBookWithQrAlert.button_bookActivity.backgroundColor = .systemGreen
        }
        
        takeBookWithQrAlert.scannedBookModel = booksModel
        takeBookWithQrAlert.delegateBookDetailsWithQr = self
        takeBookWithQrAlert.modalPresentationStyle = .overCurrentContext
        takeBookWithQrAlert.providesPresentationContextTransitionStyle = true
        takeBookWithQrAlert.definesPresentationContext = true
        takeBookWithQrAlert.modalTransitionStyle = .crossDissolve
        self.present(takeBookWithQrAlert, animated: true)
    }
    
    func setAllReservedBookIdList(allReservedBooks: [String]){
        self.allReservedBooks = allReservedBooks
    }
    
    func setDebtLabelText(totalDebt: String, showFine: String) {
        label_showFine.text = totalDebt
        label_showFine2.text = showFine
    }
    
    func hiddenPayButton(isHidden: Bool) {
        self.button_payFine.isHidden = isHidden
    }
    
    func tappedPayLateFine() {
        button_payFine.isHidden = true
        self.label_showFine.text = ""
        self.label_showFine2.text = "Borcunuz bulunmamaktadır"
        self.makeAlert(title: "İşlem Başarılı", message: "Ödemeniz için teşekkür ederiz.")
        
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .default)
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
    
    
}

// MARK : ReserveBook page
extension LibraryViewController: ReserveBookProtocol{
    
    func reloadCollectionView() {
        self.libraryViewModel.getAllReservedBookId()
        collectionView_reserveBook.reloadData()
    }
    
    func cancel() {
        print("cancel button tapped")
        tabBarController?.tabBar.isHidden = false
        (self.tabBarController as? TabBarController)?.showTopView()
    }
}

// MARK : Setting BookDetailsAlert
extension LibraryViewController: BookDetailsAlertDelegate{
    
    func cancelButtonClicked() {
        tabBarController?.tabBar.isHidden = false
        (self.tabBarController as? TabBarController)?.showTopView()
    }
    
    func updateAddDayBool(complation: @escaping (Bool) -> Void) {
        self.libraryViewModel.updateExtendBool(bookID: self.selectedBookID) { checkExtension in
            complation(checkExtension)
        }
    }
    
    func updateDeadline() {
        print("call update deadline")
        let selectedBookDeadline  = self.libraryViewModel.getDeadline(bookID: selectedBookID) { deadline in
            self.libraryViewModel.updateDeadline(bookID: self.selectedBookID, deadline: deadline)
            self.collectionView_bookcase.reloadData()
        }
    }
    
    func getDeadline(complation: @escaping (String) -> Void) {
        self.libraryViewModel.getDeadline(bookID: selectedBookID) { deadline in
            complation(deadline)
        }
    }
    
    func handOverBook() {
        self.libraryViewModel.handOverBook(bookID: selectedBookID) { error in
            print("handOver response : \(String(describing: error?.localizedDescription))")
        }
    }
    
    func jumpVCForHandOver() {
        let qrVC = QRScannerController()
        qrVC.label_qr_title.text = "İade için QR Kodunu okutunuz"
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
            
            if qrCodeValue == "https://www.handover.com"{
                handOverBook()
                self.libraryViewModel.getUsersBooksContens()
                self.libraryViewModel.getAllBookIdFromAllStudent()
                qrVC.captureSession.stopRunning()
                self.navigationController?.popViewController(animated: true)
                tabBarController?.tabBar.isHidden = false
                (tabBarController as? TabBarController)?.showTopView()
                ToastMessage.showToast(message: "İşlem Başarılı", in: view)
            }
            else {
                self.makeAlertExitQR(title: "İşlem Başarısız", message: "Geçersiz bir QR okuttunuz")
            }
        }
    }
}

// MARK : Info Alert
extension LibraryViewController : BookCaseAlertDelegate {
    
    func cancelButtonTapped() {
        print("cancel button tapped")
        tabBarController?.tabBar.isHidden = false
        (tabBarController as? TabBarController)?.showTopView()
    }
    
}

// MARK : Configure UI
extension LibraryViewController{
    
    func configureActivityIndicator() {
        view_backgroundCollectionView.addSubview(activityIndicator)
        activityIndicator.anchor(
            top: view_backgroundCollectionView.topAnchor,
            left: view_backgroundCollectionView.leftAnchor,
            right: view_backgroundCollectionView.rightAnchor,
            bottom: view_backgroundCollectionView.bottomAnchor
        )
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor,width: 200,height: 200)
    }
    
    func configureWithExtension() {
        // Ekran boyutları
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        view.addViews(topView, view_backgroundCollectionView, scrollView)
        topView.addSubview(topImageView)
        scrollView.addSubview(contentView)
        
        contentView.addViews(
            button_addBookLibrary, label_titleBookcase,
            view_backgroundCollectionView, label_titleReserveBook,
            view_reserveBook, button_infoLibrary, view_backgroundFine
        )
        
        view_backgroundCollectionView.addViews(collectionView_bookcase, label_emptyLibrary)
        view_reserveBook.addViews(searchBar, collectionView_reserveBook)
        view_backgroundFine.addViews(label_titleFine, label_showFine, label_showFine2, button_payFine, button_infoPay)
        
        // topView ayarları
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
        
        // scrollView ayarları
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.anchor(
            top: topView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            bottom: view.bottomAnchor,
            width: view.bounds.size.width
        )
        
        contentView.anchor(
            top: scrollView.topAnchor,
            left: scrollView.leftAnchor,
            right: scrollView.rightAnchor,
            bottom: scrollView.bottomAnchor,
            width: view.bounds.size.width,
            height: 1200
        )
        
        // button_addBookLibrary ayarları
        button_addBookLibrary.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: screenHeight * 0.025,
            paddingLeft: screenWidth * 0.125,
            paddingRight: screenWidth * 0.125,
            height: 50
        )
        
        label_titleBookcase.anchor(
            top: button_addBookLibrary.bottomAnchor,
            left: contentView.leftAnchor,
            paddingTop: 50,
            paddingLeft: 15,
            height: 20
        )
        
        button_infoLibrary.anchor(
            right: contentView.rightAnchor,
            bottom: view_backgroundCollectionView.topAnchor,
            paddingBottom: 10,
            paddingRight: 10,
            width: 20,
            height: 20
        )
        
        view_backgroundCollectionView.anchor(
            top: label_titleBookcase.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 10,
            paddingLeft: 10,
            paddingRight: 10,
            height: 350
        )
        
        label_emptyLibrary.isHidden = true
        label_emptyLibrary.textAlignment = .center
        label_emptyLibrary.numberOfLines = 0
        label_emptyLibrary.lineBreakMode = .byWordWrapping
        label_emptyLibrary.anchor(
            top: view_backgroundCollectionView.topAnchor,
            left: view_backgroundCollectionView.leftAnchor,
            right: view_backgroundCollectionView.rightAnchor,
            bottom: view_backgroundCollectionView.bottomAnchor
        )
        
        collectionView_bookcase.anchor(
            top: view_backgroundCollectionView.topAnchor,
            left: view_backgroundCollectionView.leftAnchor,
            right: view_backgroundCollectionView.rightAnchor,
            bottom: view_backgroundCollectionView.bottomAnchor,
            paddingTop: 5,
            paddingBottom: 5,
            paddingLeft: 10,
            paddingRight: 10,
            height: 325
        )
        
        label_titleReserveBook.anchor(
            top: view_backgroundCollectionView.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 15,
            height: 20
        )
        
        view_reserveBook.anchor(
            top: label_titleReserveBook.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 5,
            paddingLeft: 10,
            paddingRight: 10,
            height: 400
        )
        
        searchBar.anchor(
            top: view_reserveBook.topAnchor,
            left: view_reserveBook.leftAnchor,
            right: view_reserveBook.rightAnchor,
            paddingTop: 10,
            paddingLeft: 5,
            paddingRight: 5,
            height: 30
        )
        
        collectionView_reserveBook.anchor(
            top: searchBar.bottomAnchor,
            left: view_reserveBook.leftAnchor,
            right: view_reserveBook.rightAnchor,
            paddingTop: 10,
            paddingLeft: 10,
            paddingRight: 10,
            height: 325
        )
        
        view_backgroundFine.anchor(
            top: view_reserveBook.bottomAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor,
            paddingTop: 30,
            paddingLeft: 10,
            paddingRight: 10,
            height: 250
        )
        
        label_titleFine.anchor(
            top: view_backgroundFine.topAnchor,
            left: view_backgroundFine.leftAnchor,
            right: view_backgroundFine.rightAnchor,
            paddingTop: 10,
            paddingLeft: 10,
            height: 20
        )
        
        label_showFine.anchor(
            top: label_titleFine.bottomAnchor,
            left: view_backgroundFine.leftAnchor,
            paddingTop: 20,
            paddingLeft: 10,
            height: 30
        )
        
        label_showFine2.anchor(
            top: label_titleFine.bottomAnchor,
            left: label_showFine.rightAnchor,
            paddingTop: 30,
            paddingLeft: 5,
            height: 20
        )
        
        button_payFine.anchor(
            top: label_showFine2.bottomAnchor,
            left: view_backgroundFine.leftAnchor,
            right: view_backgroundFine.rightAnchor,
            paddingTop: 30,
            paddingLeft: 75,
            paddingRight: 75,
            height: 30
        )
        
        button_infoPay.anchor(
            top: view_backgroundFine.topAnchor,
            right: view_backgroundFine.rightAnchor,
            paddingTop: 10,
            paddingRight: 10,
            width: 20,
            height: 20
        )
    }
    
    func addBorderColorOnView(){
        
        view_backgroundCollectionView.layer.borderColor = vakifbankColor.cgColor
        view_backgroundCollectionView.layer.borderWidth = 2
        
        view_reserveBook.layer.borderColor = vakifbankColor.cgColor
        view_reserveBook.layer.borderWidth = 2
        
        view_backgroundFine.layer.borderColor = vakifbankColor.cgColor
        view_backgroundCollectionView.layer.borderWidth = 2
    }
}


extension LibraryViewController : TakeLoanedBookAlertProcotol {
    func update_bookCase() {
        self.libraryViewModel.getUsersBooksContens()
        self.libraryViewModel.getAllBookIdFromAllStudent()
        collectionView_bookcase.reloadData()
        collectionView_reserveBook.reloadData()
        
        tabBarController?.tabBar.isHidden = false
        (tabBarController as? TabBarController)?.showTopView()
        print("update BookCase")
        
    }
    
    func tapped_cancelButton() {
        tabBarController?.tabBar.isHidden = false
        (tabBarController as? TabBarController)?.showTopView()
    }
}

extension LibraryViewController{
    func makeAlertExitQR(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.tabBar.isHidden = false
            (self.tabBarController as? TabBarController)?.showTopView()
        }
    }
    
}

