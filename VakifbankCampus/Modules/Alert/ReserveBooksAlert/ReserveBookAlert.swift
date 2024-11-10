//
//  ReserveBookAlert.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 27.08.2024.
//

import UIKit
import MessageUI

protocol ReserveBookProtocol{
    func cancel()
    func reloadCollectionView()
}

class ReserveBookAlert: BookAlertViewSettingsVC {
    
    var delegateReserveBook : ReserveBookProtocol? = nil
    let viewModel = ReserveBookViewModel()
    var bookModel: BooksModel?
    var bookSituation : String?
    var studentID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCompanents()
        addTargetOnButton()
        setSelectedBookInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
        setCompanents()
        animatedView()
    }
    
    func setCompanents() {
        button_bookActivity.setTitle("Kitap Ayırt", for: .normal)
        button_handOver.isHidden = true
        label.isHidden = false
        label.text = bookSituation
    }
    
    func setSelectedBookInfo() {
        bookTitle = bookModel?.title ?? ""
        if var urlComponents = URLComponents(string: bookModel?.imageUrl ?? "") {
            urlComponents.scheme = "https"
            if let secureUrl = urlComponents.url {
                let task = URLSession.shared.dataTask(with: secureUrl) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Failed to download image data: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView_book.image = image
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func addTargetOnButton(){
        button_cancel.addTarget(self, action: #selector(tapped_cancelButton), for: .touchUpInside)
        button_bookActivity.addTarget(self, action: #selector(tapped_reserveBook), for: .touchUpInside)
    }
    
    @objc func tapped_cancelButton(){
        delegateReserveBook?.cancel()
        delegateReserveBook?.reloadCollectionView()
        self.dismiss(animated: true)
    }
    
    @objc func tapped_reserveBook(){
        let bookId = self.bookModel?.id ?? ""
        self.viewModel.insertReservedBook(id: bookId, studentID: studentID ?? "") { result, error in
            if error != nil{
                print("errorReserveBook: \(error?.localizedDescription)")
            }
            else{
                self.makeAlert(title: "Kitap Ayırma İşleminiz Başarılı", message: "Kitabınız 3 gün süre ile Ödünç Verme Birimi'nde sizin için bekletilecektir.",bookID: bookId)
                self.button_bookActivity.backgroundColor = .systemRed
                self.label.text = "Ödünç Alınmış"
                self.button_bookActivity.isEnabled = false
            }
        }
        delegateReserveBook?.reloadCollectionView()
    }

    func sendMail(tckNumber: String, bookID: String) {
        guard MFMailComposeViewController.canSendMail() else {return}
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["umut22erol@gmail.com"])
        mailComposer.setSubject("Kitap Ayırtma Talebi")
        mailComposer.setMessageBody("\(tckNumber) TC Numaralı öğrenci \(bookID) ID'li kitap için ayırtma talebi oluşturdu.", isHTML: false)
        self.present(mailComposer,animated: true)
    }
    
    func makeAlert(title:String, message: String,bookID: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .cancel) { _ in
            self.viewModel.getTckNumber(from: self.studentID ??  "") { tckNumber in
                self.sendMail(tckNumber:tckNumber ?? "" , bookID: bookID)
            }
        }
        alertController.addAction(alertAction)
        self.present(alertController,animated: true)
    }
}

extension ReserveBookAlert : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
         
        if error != nil {
            controller.dismiss(animated: true)
        }
        
        switch result{
        case .cancelled:
            break
        case .saved:
            break
        case .sent:
            break
        case .failed:
            break
        default:
            print("default")
        }
        controller.dismiss(animated: true)
    }
}

