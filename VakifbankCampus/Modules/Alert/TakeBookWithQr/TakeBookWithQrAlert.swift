//
//  TakeBookWithQrAlert.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 26.08.2024.
//

import UIKit

protocol TakeLoanedBookAlertProcotol {
    func tapped_cancelButton()
    func update_bookCase()
}

class TakeBookWithQrAlert: BookAlertViewSettingsVC {
    
    var delegateBookDetailsWithQr : TakeLoanedBookAlertProcotol? = nil
    let service = ServiceTakeBookWithQr()
    
    var userID : String?
    var bookSituation : String?
    var scannedBookModel: BooksModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setCompanents()
        setScannedBookInfo()
        addTargetOnButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
        setCompanents()
        animatedView()
    }
    
    func setCompanents(){
        button_bookActivity.setTitle("Ödünç Al", for: .normal)
        button_handOver.isEnabled = false
        button_handOver.isHidden = true
        label.isHidden = false
        label.text = bookSituation
    }
    
    func setScannedBookInfo(){
        bookTitle = scannedBookModel!.title
        if var urlComponents = URLComponents(string: scannedBookModel?.imageUrl ?? "") {
            urlComponents.scheme = "https"
            if let secureUrl = urlComponents.url {
                let task = URLSession.shared.dataTask(with: secureUrl) { data, response, error in
                    if let data = data, error == nil, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView_book.image = image
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    
    func addTargetOnButton() {
        button_bookActivity.addTarget(self, action: #selector(tapped_borrowBookButton), for: .touchUpInside)
        button_cancel.addTarget(self, action: #selector(tapped_cancelButton ), for: .touchUpInside)
    }
    
    // MARK : @obcj func for button
    @objc func tapped_borrowBookButton(){
        let id = self.scannedBookModel?.id ?? ""
        let startingDate = self.getTodayDate()
        let deadline = self.getDateAfter15Days()
        self.service.addBookToStudent(userID: userID ?? "", bookID: id, startingDate: startingDate, deadline: deadline, addDays: false) { response, error in
            if error != nil {
                print("insert book on user is failed")
        
            }
            else {
                print("insert book on user is success")
                self.delegateBookDetailsWithQr?.update_bookCase()
            }
        }
        self.dismiss(animated: true)
    }

    
    @objc func tapped_cancelButton(){
        delegateBookDetailsWithQr?.tapped_cancelButton()
        self.dismiss(animated: true)
    }
    
    // MARK : book -> deadline && startingDate
    func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let todayDate = dateFormatter.string(from: Date())
        return todayDate
    }

    func getDateAfter15Days() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let calendar = Calendar.current
        let today = Date()
        if let futureDate = calendar.date(byAdding: .day, value: 15, to: today) {
            let futureDateString = dateFormatter.string(from: futureDate)
            return futureDateString
        } else {
            return "Tarih hesaplanamadı"
        }
    }

    



}
