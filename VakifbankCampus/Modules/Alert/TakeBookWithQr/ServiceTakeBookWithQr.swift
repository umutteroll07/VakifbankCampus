//
//  ServiceTakeBookWithQr.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 26.08.2024.
//

import Foundation
import FirebaseFirestore

class ServiceTakeBookWithQr{
    
    let firestoreDatabse = Firestore.firestore()
    
    func addBookToStudent(userID: String, bookID: String, startingDate: String,deadline:String,addDays: Bool, completion: @escaping (Bool, Error?) -> Void) {
        
        let documentRef = firestoreDatabse
            .collection("UserStudent")
            .document(userID)
            .collection("studentsBooks")
            .document(bookID)
        // Veri
        let bookData: [String: Any] = [
            "startingDate": startingDate,
            "addDays": addDays,
            "deadline": deadline,
            "lastPayDate": "00/00/0000"
        ]
        // Insert
        documentRef.setData(bookData) { error in
            if let error = error {
                print("Error adding book to student: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Book successfully added to student!")
                completion(true, nil)
            }
        }
    }
}
