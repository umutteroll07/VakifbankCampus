//
//  LibraryViewModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 23.08.2024.
//

import Foundation
import UIKit

protocol LibraryViewModelProtocol{
    func getUsersBooksContens()
    func getAllBookFromFirestore(complation:@escaping (Bool) -> Void)
    func getDeadline(bookID: String, completion: @escaping (String) -> Void)
    func setColorTag(bookID: String, completion: @escaping (UIColor) -> Void)
    func getBookWithQrValue(qrCodeValue: String)
    func getAllBookIdFromAllStudent()
    func getReservedBookID()
    func getExtendTimeControl(bookID: String,complation: @escaping (Bool) -> Void)
    func getAndAddExtensionCount( completion: @escaping (Bool?) -> Void)
    func updateExtendBool(bookID: String,complation: @escaping (Bool) -> Void)
    func updateDeadline(bookID: String,deadline: String)
    func handOverBook(bookID: String, completion: @escaping (Error?) -> Void)
    func getAllReservedBookId()
    func addReservedBookToBookcase()
    var serviceLibrary: ServiceLibraryProtocol {get}
}

class LibraryViewModel: LibraryViewModelProtocol{
    
    lazy var serviceLibrary: ServiceLibraryProtocol = ServiceLibraryPage()
    weak var view: LibraryVCProtocol?
    var userBooksModelList = [BooksModel]()
    var allBookIdFromAllStudent = [String]()
    var reservedBookID = [String]()
    var totalLateFee = Float()
    
    var userID: String?
    init(view: LibraryVCProtocol?) {
        self.view = view
        self.userID = view?.setUserID()
    }

    func getUsersBooksContens(){
        view?.startActivityIndicator()
        
        let startTime = Date()
        
        serviceLibrary.fetchUserBookID(userID: self.userID ?? "") { booksID, booksStartingDate in
            if booksID.isEmpty {
                self.view?.setEmptyBookCaseSettings(value: true)
                self.userBooksModelList = []
                self.ensureMinimumActivityIndicatorDuration(since: startTime)
            } else {
                self.view?.setEmptyBookCaseSettings(value: false)
                self.serviceLibrary.fetchUserBooksContents(bookIds: booksID) { userBooksModelList in
                    self.userBooksModelList = userBooksModelList
                    self.view?.reloadDataCollectionView_bookcase()
                    self.ensureMinimumActivityIndicatorDuration(since: startTime)
                }
            }
        }
    }
    
    private func ensureMinimumActivityIndicatorDuration(since startTime: Date) {
        let elapsedTime = Date().timeIntervalSince(startTime)
        let remainingTime = max(1.0 - elapsedTime, 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
            self.view?.stopActivityIndicator()
        }
    }
    
    
    func getAllBookFromFirestore(complation:@escaping (Bool) -> Void) {
        view?.startActivityIndicator()
        self.serviceLibrary.fetchAllBookFromFirestore { allBooksModel in
            self.view?.setFilteredBooks(allBooksModel: allBooksModel)
            self.view?.stopActivityIndicator()
            complation(true)
        }
    }
    
    func getDeadline(bookID: String, completion: @escaping (String) -> Void) {
        self.serviceLibrary.getDeadline(userID: userID ?? "", bookID: bookID) { deadline in
            completion(deadline ?? "")
        }
    }
    
    func getRemainderDay(bookID:String, completion: @escaping (Int) -> Void){
        self.getDeadline(bookID: bookID) { deadline in
            let remainderDay = self.daysBetweenDates(endDateString: deadline)
            completion(remainderDay ?? 0)
        }
    }
    
    func setColorTag(bookID: String, completion: @escaping (UIColor) -> Void){
        self.getRemainderDay(bookID: bookID) { remainderDay in
            var cellTagColor: UIColor
            if remainderDay > 5 {
                cellTagColor = .systemGreen
            } else if remainderDay > 0 {
                cellTagColor = .systemYellow
            } else {
                cellTagColor = .systemRed
            }
            completion(cellTagColor)
        }
    }
    
    func checkBookRemainderDay(bookID: String, complation: @escaping (Bool) -> Void){
        self.getRemainderDay(bookID: bookID) { remainderDay in
            var timeoutValue = Bool()
            if remainderDay <= 0 {
                timeoutValue = true
                complation(timeoutValue)
            }
            else {
                timeoutValue = false
                complation(timeoutValue)
            }
        }
    }
    
    func daysBetweenDates(endDateString: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let endDate = dateFormatter.date(from: endDateString) else {
            print("Invalid date format")
            return nil
        }
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: currentDate, to: endDate)
        return components.day! + 1
    }
    
    func getBookWithQrValue(qrCodeValue: String) {
        self.serviceLibrary.fetchBookWithQrValue(qrCodeValue: qrCodeValue) { booksModel in
            if let bookModel = booksModel, bookModel.title != nil{
                self.view?.takeLoanedBook(booksModel: bookModel)
            }
        }
    }
    
    func getAllBookIdFromAllStudent() {
        self.serviceLibrary.fetchAllBookIDFromAllStudents { allBookIdFromAllStudent in
            self.allBookIdFromAllStudent = allBookIdFromAllStudent
            self.view?.reloadDataCollectionView_reservedBook()
        }
    }
    
    func getReservedBookID() {
        self.serviceLibrary.fetchReservedBookID { reservedBookID in
            self.reservedBookID = reservedBookID ?? [String]()
            self.view?.reloadDataCollectionView_reservedBook()
        }
    }
    
    func getExtendTimeControl(bookID: String,complation: @escaping (Bool) -> Void) {
        self.serviceLibrary.fetchExtendTimeControl(userID: userID ?? "", bookId: bookID) { boolExtendTime in
            complation(boolExtendTime ?? false)
        }
    }
    
    
    func getAndAddExtensionCount(completion: @escaping (Bool?) -> Void) {
        self.serviceLibrary.fetchAndAddExtensionCount(documentID: userID ?? "") { checkExtension in
            print("extensionCountViewModel : \(String(describing: checkExtension))")
            completion(checkExtension)
        }
    }
    
    
    
    func updateExtendBool(bookID: String,complation: @escaping (Bool) -> Void) {
        getExtendTimeControl(bookID: bookID) { boolExtendTime in
            if !boolExtendTime {
                self.getAndAddExtensionCount { checkExtension in
                    if let checkExtension = checkExtension{
                        if checkExtension {
                            self.serviceLibrary.updateExtendBoolOnDatabase(userID: self.userID ?? "", bookID: bookID, newValue: !boolExtendTime)
                        }
                        complation(checkExtension)
                    }
                }
            }
        }
    }
    func updateDeadline(bookID: String,deadline: String) {
        print("update call deadline vm \(deadline)")
        let newDeadline = calculateFutureDate(from: deadline) ?? "00/00/0000"
        self.serviceLibrary.updateDeadline(userID: userID ?? "", bookId: bookID, dateString: newDeadline)
    }
    
    func calculateFutureDate(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 15, to: date)!
        return dateFormatter.string(from: futureDate)
    }
    
    func handOverBook(bookID: String, completion: @escaping (Error?) -> Void) {
        self.serviceLibrary.handOverBookOnFirestore(documentID: userID ?? "", bookID: bookID) { error in
            if error != nil {
                print("handOver is failed")
            }
            else {
                print("handOver is succes")
                self.getUsersBooksContens()
                self.getAllBookIdFromAllStudent()
                self.view?.reloadDataCollectionView_reservedBook()
                self.view?.reloadDataCollectionView_bookcase()
            }
        }
    }
    
    func getAllReservedBookId() {
        self.serviceLibrary.fetchAllReservedBooksId { allReservedBookId in
            self.view?.setAllReservedBookIdList(allReservedBooks: allReservedBookId ?? [])
        }
    }
    
    func addReservedBookToBookcase() {
        self.serviceLibrary.updateStudentBooks {
            self.getUsersBooksContens()
            self.view?.reloadDataCollectionView_bookcase()
        }
        
    }
    
    func calculateDebtForBooks(){
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: today)
        self.serviceLibrary.fetchLoanedBooks(for: userID ?? "") { loanedBookModel in
            for book in loanedBookModel ?? [] {
                
                if let deadlineDate = dateFormatter.date(from: book.deadline ?? "") {
                    // Bugün ile deadline arasındaki gün farkını hesapla
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day], from: today, to: deadlineDate)
                    if let days = components.day {
                        
                        if days < 0 {
                            print("Deadline: \(book.deadline), Gün Sayısı: \(days)")
                            if book.lastPayDate != "00/00/0000"{
                                if let lastPayDate = dateFormatter.date(from: book.lastPayDate ?? "") {
                                    let companentsWithLastPayDate = calendar.dateComponents([.day], from: today,to: lastPayDate)
                                    
                                    let daysWithLastPay = companentsWithLastPayDate.day
                                    
                                    if daysWithLastPay ?? 0 < 0 {
                                        let debt = -(Double(daysWithLastPay ?? 0)) * 2.5
                                        self.totalLateFee += Float(debt)
                                        self.serviceLibrary.updateOrCreateDebt(debt: debt, bookID: book.bookID ?? "", documentID: self.userID ?? "") { error in
                                            if error != nil {
                                                print("update debt is failed")
                                            }
                                            else {
                                                print("update debt is success")
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                }
                            }
                            else {
                                let debt = (-Double(days)) * 2.5
                                self.totalLateFee += Float(debt)
                                self.serviceLibrary.updateOrCreateDebt(debt: debt, bookID: book.bookID ?? "", documentID: self.userID ?? "") { error in
                                    if error != nil {
                                        print("update debt is failed")
                                    }
                                    else {
                                        print("update debt is success")
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            
            self.serviceLibrary.updateTotalLateFees(for: self.userID ?? "") { totalDebt in
                if totalDebt == 0 {
                    self.view?.setDebtLabelText(totalDebt: "", showFine: "Borcunuz bulunmamaktadır")
                    self.view?.hiddenPayButton(isHidden: true)
                }
                else {
                    print("total debt not equal zero")
                    self.view?.setDebtLabelText(totalDebt: String(totalDebt ?? 0), showFine: "TL borcunuz bulunmaktadır.")
                    self.view?.hiddenPayButton(isHidden: false)
                }
            }
        }
    }
    
    func payLateFee(){
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: today)
        
        self.serviceLibrary.fetchTotalLateFee(userID: self.userID ?? "") { totalLateFees in
            
            self.serviceLibrary.fetchUserRemainder(for: self.userID ?? ""  ) { userRemainder in
                guard let remainder = userRemainder else {
                    return
                }
                
                if remainder >= totalLateFees {
                    let newRemainder = remainder - totalLateFees
                    self.serviceLibrary.updateUserRemainder(userID: self.userID ?? "", with: Float(newRemainder))
                    self.serviceLibrary.fetchLoanedBooks(for: self.userID ?? "") { loanedBookModel in
                        for book in loanedBookModel ?? [] {
                            if let deadlineDate = dateFormatter.date(from: book.deadline ?? "") {
                                // Bugün ile deadline arasındaki gün farkını hesapla
                                let calendar = Calendar.current
                                let components = calendar.dateComponents([.day], from: today, to: deadlineDate)
                                
                                if let days = components.day {
                                    if days < 0 {
                                        
                                        self.serviceLibrary.updateLastPayDate(userID: self.userID ?? "", for: book.bookID ?? "")
                                    }
                                }
                            }
                        }
                        self.serviceLibrary.deleteLateFees(userID: self.userID ?? "")
                        self.view?.tappedPayLateFine()
                    }
                }
                else
                {
                    print("yetersiz bakiye")
                    self.view?.makeAlert(title: "Yetersiz Bakiye", message: "Bakiye yetersizliğinden dolayı işleminizi şu anda gerçekleştiremiyoruz")
                }
            }
        }
    }
}

