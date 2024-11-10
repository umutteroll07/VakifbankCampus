//
//  BookDetailsAlert.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 23.08.2024.
//

import UIKit

protocol BookDetailsAlertDelegate {
    func cancelButtonClicked()
    func updateAddDayBool(complation: @escaping (Bool) -> Void)
    func updateDeadline()
    func handOverBook()
    func getDeadline(complation: @escaping (String) -> Void)
    func jumpVCForHandOver()
}

class BookDetailsAlert: BookAlertViewSettingsVC {
    var delegateBookDetailsAlertVC : BookDetailsAlertDelegate? = nil
    var checkBookRemainderDayControl = Bool()
    var checkExtendTime = Bool()
    var bookModel: BooksModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelectedBookInfo()
        setCompanents()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupView()
        setCompanents()
        animatedView()
        addTargetOnButton()
    }
    
    func setCompanents() {
        button_bookActivity.setTitle("Süreyi Uzat", for: .normal)
        label.isHidden = false
    }
    
    func setSelectedBookInfo() {
        bookTitle = bookModel?.title ?? ""
        if var urlComponents = URLComponents(string: bookModel?.imageUrl ?? "") {
            urlComponents.scheme = "https"
            
            if let secureUrl = urlComponents.url {
                // Cache kontrolü
                if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: secureUrl)) {
                    if let image = UIImage(data: cachedResponse.data) {
                        self.imageView_book.image = image
                        return
                    }
                }
                
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: secureUrl), let image = UIImage(data: data) {
                        let response = URLResponse(url: secureUrl, mimeType: "image/jpeg", expectedContentLength: data.count, textEncodingName: nil)
                        let cachedData = CachedURLResponse(response: response, data: data)
                        URLCache.shared.storeCachedResponse(cachedData, for: URLRequest(url: secureUrl))
                        
                        DispatchQueue.main.async {
                            self.imageView_book.image = image
                        }
                    }
                }
            }
        }
    }
    
    func addTargetOnButton() {
        button_cancel.addTarget(self, action: #selector(clicked_cancelButton), for: .touchUpInside)
        button_bookActivity.addTarget(self, action: #selector(clicked_extendTimeButton), for: .touchUpInside)
        button_handOver.addTarget(self, action:#selector(clicked_handoverButton) , for: .touchUpInside)
        
    }
    
    // MARK : @objc func for button
    @objc func clicked_cancelButton(){
        delegateBookDetailsAlertVC?.cancelButtonClicked()
        self.dismiss(animated: true)
    }
    
    @objc func clicked_handoverButton(){
        self.makeAlertHandOverBook(title: "Kitap Teslimi", message: "Kitap teslim onayı için iade otomatında bulunan QR Kodunu okutunuz.")
    }
    
    @objc func clicked_extendTimeButton(){
        print("extendButton is tapped")
        var checkBool = self.checkExtendTime
        if self.checkBookRemainderDayControl{
            if !checkBool {
                print("check bool is show ")
                self.delegateBookDetailsAlertVC?.updateAddDayBool(complation: { checkExtensionBool in
                    if checkExtensionBool{
                        self.delegateBookDetailsAlertVC?.updateDeadline()
                        self.makeAlertDeadline(title: "Süre uzatma başarılı", message: "Ek iade süresi işleminiz başarı ile tamamlanmıştır.")
                        checkBool = true
                    }else{
                        self.makeAlertDeadline(title: "Süre uzatma işlemi başarısız.", message: "Size tanınan kitap iade süresi uzatma hakkınız son bulmuştur.")
                    }
                })
            }
            else {
                print("check bool is show but dont call")
                self.makeAlertDeadline(title: "Süre uzatma işlemi başarısız", message: "Daha önce bu kitap üzerinde bir uzatma işleminiz bulunmaktadır. İkinci bir ek süre tanımlanamamaktadır.")
            }
        }
        else {
            self.makeAlertDeadline(title: "Süre uzatma işlemi başarısız.", message: "İade süresi dolmuş kitaplar üzerinde süre uzatma işlemi yapılamamaktadır.")
        }
    }
    
    func makeAlertDeadline(title: String, message:String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .default) { action in
            self.delegateBookDetailsAlertVC?.getDeadline(complation: { deadline in
                self.label.text = "Teslim Tarihi: \(deadline)"
            })
            print("umutErol")
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
    
    func makeAlertHandOverBook(title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Tamam", style: .default) { _ in
       
            self.dismiss(animated: true)
            self.delegateBookDetailsAlertVC?.jumpVCForHandOver()
        }
        alertController.addAction(action)
        self.present(alertController, animated:true)
    }
}
    

