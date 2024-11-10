//
//  ServiceSignIn.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import Foundation
import FirebaseFirestore


protocol ServiceSignInProtocol {
    func checkUserFromFirebase(tckNumber: String, password: String, completion: @escaping (String) -> Void)
    func getUserIdWithTckNumber(for tckNumber: String, completion: @escaping (String?) -> Void)
}

class ServiceSignIn : ServiceSignInProtocol {
    
    let firestoreDatabase = Firestore.firestore()
    
    func checkUserFromFirebase(tckNumber: String, password: String, completion: @escaping (String) -> Void) {
        if tckNumber == "" || tckNumber == "" {
            completion("nil")
        }
        else{
            firestoreDatabase.collection("UserStudent").whereField("tckNumber", isEqualTo: tckNumber).whereField("userPsw", isEqualTo: password).getDocuments { snapshot, error in
                if error != nil {
                    print("error")
                }
                else{
                    if let documents = snapshot?.documents, !documents.isEmpty{
                        
                        if let document = documents.first {
                            let tckNumber = document.get("tckNumber") as! String
                            completion(tckNumber)
                        }
                    }
                    else{
                        completion("nil")
                    }
                }
            }
        }
    }
    
    func getUserIdWithTckNumber(for tckNumber: String, completion: @escaping (String?) -> Void) {
        
        print("service check \(tckNumber)")
        let usersCollection = firestoreDatabase.collection("UserStudent")
        usersCollection.whereField("tckNumber", isEqualTo: tckNumber).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil)
            } else {
                if let document = querySnapshot?.documents.first {
                    let userId = document.documentID
                    completion(userId)
                } else {
                    print("No user found with given tckNumber")
                    completion(nil)
                }
            }
        }
    }
}
