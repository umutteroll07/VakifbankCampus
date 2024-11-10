//
//  ServiceLibraryPage.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 23.08.2024.
//
import FirebaseFirestore

protocol ServiceLibraryProtocol{
    func fetchUserBookID(userID: String,completion: @escaping ([String], [String]) -> Void)
    func fetchAllBookFromFirestore(complation:@escaping ([BooksModel]) -> Void)
    func fetchUserBooksContents(bookIds: [String], completion: @escaping ([BooksModel]) -> Void)
    func getDeadline(userID: String, bookID: String, completion: @escaping (String?) -> Void)
    func fetchBookWithQrValue(qrCodeValue: String, completion: @escaping (BooksModel?) -> Void)
    func fetchAllBookIDFromAllStudents(completion: @escaping ([String]) -> Void)
    func fetchReservedBookID(completion: @escaping ([String]?) -> Void)
    func fetchExtendTimeControl(userID: String, bookId: String, completion: @escaping (Bool?) -> Void)
    func fetchAndAddExtensionCount(documentID: String, completion: @escaping (Bool?) -> Void)
    func updateExtendBoolOnDatabase(userID: String,bookID: String,newValue: Bool)
    func updateDeadline(userID: String, bookId: String, dateString: String)
    func handOverBookOnFirestore(documentID: String, bookID: String, completion: @escaping (Error?) -> Void)
    func fetchAllReservedBooksId(completion: @escaping ([String]?) -> Void)
    func fetchLoanedBooks(for documentID: String, completion: @escaping ([LoanedBookModel]?) -> Void)
    func updateOrCreateDebt(debt: Double, bookID: String, documentID: String, completion: @escaping (Error?) -> Void)
    func updateTotalLateFees(for documentID: String, completion: @escaping (Float?) -> Void)
    func fetchTotalLateFee(userID: String, completion : @escaping (Double) -> Void)
    func fetchUserRemainder(for documentID: String, completion: @escaping (Double?) -> Void)
    func updateUserRemainder(userID: String, with remainder: Float)
    func updateLastPayDate(userID: String,for bookID: String)
    func deleteLateFees(userID: String)
    func updateStudentBooks(complation: @escaping () -> Void)
    
    
}

class ServiceLibraryPage: ServiceLibraryProtocol{
    
    
    let firestoreDatabase = Firestore.firestore()
    var allBooksModelList = [BooksModel]()
    
    func fetchUserBookID(userID: String,completion: @escaping ([String], [String]) -> Void) {
        firestoreDatabase.collection("UserStudent").document(userID).collection("studentsBooks").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("studentsBooks bilgileri alınamadı: \(error.localizedDescription)")
                completion([], []) // Boş dizilerle hata durumu
                return
            }
            
            var userBooksId = [String]()
            var userBooksStartingDate = [String]()
            
            guard let documents = querySnapshot?.documents else { return }
            for document in documents {
                let bookId = document.documentID
                let startingDate = document.data()["startingDate"] as? String ?? ""
                
                userBooksId.append(bookId)
                userBooksStartingDate.append(startingDate)
            }
            
            completion(userBooksId, userBooksStartingDate) // Verilerle completion
        }
        
    }
    
    
    
    func fetchUserBooksContents(bookIds: [String], completion: @escaping ([BooksModel]) -> Void){
        firestoreDatabase.collection("Books").whereField(FieldPath.documentID(), in: bookIds).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Kitap bilgileri alınamadı: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var books: [BooksModel] = []
            
            for document in querySnapshot!.documents {
                
                let data = document.data()
                let id = document.documentID
                let title = data["title"] as? String ?? "No Title"
                let imageUrl = data["imageUrl"] as? String ?? "No Image URL"
                let qrValue = data["qrValue"] as? String ?? "No QR Value"
                
                let book = BooksModel(id: id, title: title, imageUrl: imageUrl,qrValue: qrValue)
                books.append(book)
            }
            
            completion(books)
        }
    }
    
    
    func fetchAllBookFromFirestore(complation: @escaping ([BooksModel]) -> Void) {
        var bookTitle = String()
        var bookImageUrl = String()
        
        firestoreDatabase.collection("Books").getDocuments { snapshot, error in
            
            if error == nil {
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    var bookList = [BooksModel]()
                    
                    for document in documents {
                        let id = document.documentID
                        let data = document.data()
                        let title = data["title"] as? String ?? "No Title"
                        let imageUrl = data["imageUrl"] as? String ?? "No Image URL"
                        let qrValue = data["qrValue"] as? String ?? "No QR Value"
                        
                        let book = BooksModel(id: id, title: title, imageUrl: imageUrl,qrValue: qrValue)
                        bookList.append(book)
                        
                    }
                    self.allBooksModelList = bookList
                    complation(self.allBooksModelList)
                }
            }else{
                print("get book info error")
            }
        }
    }
    
    
    func getDeadline(userID: String, bookID: String, completion: @escaping (String?) -> Void) {
        
        let documentRef = self.firestoreDatabase
            .collection("UserStudent")
            .document(userID)
            .collection("studentsBooks")
            .document(bookID)
        
        documentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else {
                if let document = documentSnapshot, document.exists {
                    
                    let deadline = document.get("deadline") as? String
                    completion(deadline)
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        }
    }
    
    func fetchBookWithQrValue(qrCodeValue: String, completion: @escaping (BooksModel?) -> Void) {
        firestoreDatabase.collection("Books").whereField("qrValue", isEqualTo: qrCodeValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching book info by QR code: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No book found with the given QR code")
                completion(nil)
                return
            }
            
            let data = document.data()
            let id = document.documentID
            let title = data["title"] as? String ?? "No Title"
            let imageUrl = data["imageUrl"] as? String ?? "No Image URL"
            let qrValue = data["qrValue"] as? String ?? "No QR Value"
            
            let bookModel = BooksModel(id: id, title: title, imageUrl: imageUrl, qrValue: qrValue)
            completion(bookModel)
        }
    }
    
    func fetchAllBookIDFromAllStudents(completion: @escaping ([String]) -> Void){
        let userStudentCollection = firestoreDatabase.collection("UserStudent")
        
        var allBookIdFromAllStudents = [String]()
        
        userStudentCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                let userId = document.documentID
                let studentBooksCollection = userStudentCollection.document(userId).collection("studentsBooks")
                
                dispatchGroup.enter()
                studentBooksCollection.getDocuments { (booksSnapshot, error) in
                    if let error = error {
                        print("Error getting student books: \(error)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let booksDocuments = booksSnapshot?.documents else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    for bookDocument in booksDocuments {
                        let bookId = bookDocument.documentID
                        allBookIdFromAllStudents.append(bookId)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(allBookIdFromAllStudents)
            }
        }
    }
    
    func fetchReservedBookID(completion: @escaping ([String]?) -> Void) {
        let collectionRef = firestoreDatabase.collection("ReservedBooks")
        collectionRef.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                let documentIDs = querySnapshot.documents.map { $0.documentID }
                completion(documentIDs)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchExtendTimeControl(userID: String, bookId: String, completion: @escaping (Bool?) -> Void) {
        let documentRef = firestoreDatabase.collection("UserStudent").document(userID).collection("studentsBooks").document(bookId)
        
        documentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else {
                if let document = documentSnapshot, document.exists {
                    let addDays = document.get("addDays") as? Bool
                    completion(addDays)
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        }
    }
    
    func fetchAndAddExtensionCount(documentID: String, completion: @escaping (Bool?) -> Void) {
        let collectionRef = firestoreDatabase.collection("UserStudent")
        
        collectionRef.document(documentID).getDocument { documentSnapshot, error in
            
            if let error = error {
                print("Sayım hatası: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("Belge bulunamadı")
                completion(nil)
                return
            }
            
            var extensionCount = document.data()?["extensionCount"] as? Int
            print("Mevcut sayım: \(String(extensionCount ?? 7))")
            
            if var count = extensionCount, count < 3 {
                count += 1
                collectionRef.document(documentID).updateData(["extensionCount": count]) { error in
                    if let error = error {
                        print("Güncelleme hatası: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        print("Güncelleme başarılı")
                        completion(true)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    
    func updateExtendBoolOnDatabase(userID: String,bookID: String,newValue: Bool){
        let documentRef = self.firestoreDatabase.collection("UserStudent").document(userID).collection("studentsBooks").document(bookID)
        
        documentRef.updateData([
            "addDays": newValue
        ]) { error in
            if let error = error {
                print("Belge güncelleme hatası: \(error.localizedDescription)")
            } else {
                print("addDays başarıyla güncellendi")
            }
        }
    }
    
    func updateDeadline( userID: String, bookId: String, dateString: String) {
        print("service call updatge deadlne \(dateString)")
        let deadline = dateString
        let documentRef = self.firestoreDatabase.collection("UserStudent").document(userID).collection("studentsBooks").document(bookId)
        
        documentRef.updateData([
            "deadline": deadline
        ]) { error in
            if let error = error {
                print("Belge güncelleme hatası: \(error.localizedDescription)")
            } else {
                print("Deadline başarıyla güncellendi")
            }
        }
    }
    
    func handOverBookOnFirestore(documentID: String, bookID: String, completion: @escaping (Error?) -> Void) {
        let bookRef = firestoreDatabase
            .collection("UserStudent")
            .document(documentID)
            .collection("studentsBooks")
            .document(bookID)
        
        bookRef.delete { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
    func fetchAllReservedBooksId(completion: @escaping ([String]?) -> Void) {
        let collectionRef = firestoreDatabase.collection("ReservedBooks")
        collectionRef.getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                let documentIDs = querySnapshot.documents.map { $0.documentID }
                completion(documentIDs)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateStudentBooks(complation: @escaping () -> Void) {
        let reservedBooksRef = firestoreDatabase.collection("ReservedBooks")
        
        reservedBooksRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                let data = document.data()
                let documentID = document.documentID
                
                // Check if checkLoaned is true
                if let checkLoaned = data["checkLoaned"] as? Bool, checkLoaned {
                    // Get the startingDate and studentID
                    if let startingDate = data["startingDate"] as? String, let studentID = data["studentID"] as? String {
                        // Calculate the deadline (startingDate + 15 days)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        if let startDate = dateFormatter.date(from: startingDate) {
                            let deadlineDate = Calendar.current.date(byAdding: .day, value: 15, to: startDate)!
                            let deadline = dateFormatter.string(from: deadlineDate)
                            
                            // Prepare data to add to studentsBooks subcollection
                            let studentsBooksData: [String: Any] = [
                                "addDays": false,
                                "lastPayDate": "00/00/0000",
                                "startingDate": startingDate,
                                "deadline": deadline
                            ]
                            
                            let userStudentRef = self.firestoreDatabase.collection("UserStudent").document(studentID).collection("studentsBooks").document(documentID)
                            
                            userStudentRef.setData(studentsBooksData) { error in
                                if let error = error {
                                    print("Error writing document: \(error)")
                                } else {
                                    print("Document successfully written to studentsBooks!")
                                    reservedBooksRef.document(documentID).delete { error in
                                        if let error = error {
                                            print("Error deleting document: \(error)")
                                        } else {
                                            print("Document successfully deleted from ReservedBooks!")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchLoanedBooks(for documentID: String, completion: @escaping ([LoanedBookModel]?) -> Void) {
        
        
        let booksCollection = firestoreDatabase.collection("UserStudent").document(documentID).collection("studentsBooks")
        
        booksCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil)
            } else {
                var loanedBooks: [LoanedBookModel] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let bookID = document.documentID
                    let addDays = data["addDays"] as? String
                    let deadline = data["deadline"] as? String
                    let startingDate = data["startingDate"] as? String
                    let lastPayDate = data["lastPayDate"] as? String
                    let debt = data["debt"] as? Double
                    
                    // LoanedBookModel
                    let loanedBook = LoanedBookModel(
                        bookID: bookID,
                        addDays: addDays,
                        deadline: deadline,
                        startingDate: startingDate,
                        lastPayDate: lastPayDate,
                        debt: debt
                    )
                    loanedBooks.append(loanedBook)
                }
                completion(loanedBooks)
            }
        }
        
    }
    
    func updateOrCreateDebt(debt: Double, bookID: String, documentID: String, completion: @escaping (Error?) -> Void) {
        let lateFeesCollection = firestoreDatabase.collection("UserStudent").document(documentID).collection("lateFees")
        let bookRef = lateFeesCollection.document(bookID)
        
        bookRef.setData([
            "debt": debt
        ], merge: true) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    func updateTotalLateFees(for documentID: String, completion: @escaping (Float?) -> Void) {
        
        let lateFeesCollection = firestoreDatabase.collection("UserStudent").document(documentID).collection("lateFees")
        lateFeesCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil)
                print("total is failed")
                return
            }
            
            var totalLateFees: Float = 0.0
            for document in querySnapshot!.documents {
                if let debt = document.data()["debt"] as? Float {
                    totalLateFees += debt
                }
            }
            let userDocumentRef = self.firestoreDatabase.collection("UserStudent").document(documentID)
            userDocumentRef.setData([
                "totalLateFees": totalLateFees
            ], merge: true) { error in
                if let error = error {
                    completion(nil)
                    print("total is failed")
                } else {
                    completion(totalLateFees)
                }
            }
        }
    }
    
    func fetchTotalLateFee(userID: String, completion : @escaping (Double) -> Void) {
        
        let ref = self.firestoreDatabase.collection("UserStudent").document(userID )
        ref.getDocument { snapshots, error in
            if let error = error {
                print("Belgeyi getirirken hata oluştu: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            guard let document = snapshots, document.exists, let data = document.data() else {
                print("Belge bulunamadı")
                completion(0)
                return
            }
            
            if let totalLateFee = data["totalLateFees"] as? Double {
                completion(totalLateFee)
            } else {
                print("lateFee verisi mevcut değil")
                completion(0)
            }
        }
    }
    
    func fetchUserRemainder(for documentID: String, completion: @escaping (Double?) -> Void) {
        let userStudentRef = firestoreDatabase.collection("UserStudent").document(documentID)
        
        userStudentRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(nil)
            } else if let document = document, document.exists {
                if let userRemainder = document.get("user_remainder") as? Double {
                    completion(userRemainder)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func updateUserRemainder(userID: String, with remainder: Float) {
        let userRef = firestoreDatabase.collection("UserStudent").document(userID )
        userRef.updateData([
            "user_remainder": remainder
        ]) { error in
            if let error = error {
                print("Güncelleme yapılırken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Kullanıcı remainder başarıyla güncellendi.")
            }
        }
    }
    
    func updateLastPayDate(userID: String,for bookID: String) {
        
        // Bugünün tarihi
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let todayDateString = dateFormatter.string(from: Date())
        
        let studentsBooksRef = self.firestoreDatabase.collection("UserStudent").document(userID).collection("studentsBooks").document(bookID)
        // lastPayDate değerini güncelle
        studentsBooksRef.updateData(["lastPayDate": todayDateString]) { error in
            if let error = error {
                print("lastPayDate güncellenirken hata oluştu: \(error.localizedDescription)")
            } else {
                print("lastPayDate başarıyla güncellendi.")
            }
        }
    }
    
    func deleteLateFees(userID: String){
            let userStudentRef = self.firestoreDatabase.collection("UserStudent").document(userID)
            let studentsBooksRef = userStudentRef.collection("studentsBooks")
            let lateFeesRef = userStudentRef.collection("lateFees")
            
            // lateFees delete
            lateFeesRef.getDocuments { snapshot, error in
                if let error = error {
                    print("lateFees belgeleri alınırken hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                guard let lateFeesDocuments = snapshot?.documents else {
                    print("lateFees koleksiyonunda belge bulunamadı")
                    return
                }
                
                for lateFee in lateFeesDocuments {
                    lateFee.reference.delete() { error in
                        if let error = error {
                            print("lateFees belgesi silinirken hata oluştu: \(error.localizedDescription)")
                        }
                    }
                }
            }

        }
    }
