//
//  ReserveBookViewModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 27.08.2024.
//


import FirebaseFirestore

class ReserveBookViewModel{
    
    // MARK : Service
    let firestoreDatabase = Firestore.firestore()
    func insertReservedBook(id: String, studentID: String, completion: @escaping (Bool, Error?) -> Void) {
        
        let startingDate = self.getCurrentDateFormatted()
        let checkLoaned = false
        let data: [String: Any] = [
            "studentID": studentID,
            "startingDate": startingDate,
            "checkLoaned": checkLoaned
        ]
        firestoreDatabase.collection("ReservedBooks").document(id).setData(data) { error in
            if let error = error {
                completion(false, error)
                print("not okey")
            } else {
                completion(true, nil)
                print("okey")
            }
        }
    }
    
    func getCurrentDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
    func getTckNumber(from documentID: String, completion: @escaping (String?) -> Void) {
        let documentRef = firestoreDatabase.collection("UserStudent").document(documentID)
        
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists, let fetchedTckNumber = document.data()?["tckNumber"] as? String {
                completion(fetchedTckNumber)
            } else {
                print("Document does not exist or an error occurred: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
}
