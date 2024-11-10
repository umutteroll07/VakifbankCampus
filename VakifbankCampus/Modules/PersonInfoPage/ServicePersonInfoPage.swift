//
//  ServicePersonInfoPage.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 29.08.2024.
//

import FirebaseFirestore

protocol ServicePersonInfoProtocol{
    func fetchPersonInfoFromFirestore(userID: String, complation: @escaping (UserInfoModel) -> Void)
    func fetchURL(from documentID: String, selectedWebSite: String, completion: @escaping (String?) -> Void)
}

class ServicePersonInfoPage: ServicePersonInfoProtocol{
    let firestoreDatabase = Firestore.firestore()
    func fetchPersonInfoFromFirestore(userID: String, complation: @escaping (UserInfoModel) -> Void) {
        firestoreDatabase.collection("UserStudent").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("Document does not exist or data is nil")
                return
            }
            
            let name = data["userName"] as? String ?? ""
            let surname = data["userSurname"] as? String ?? ""
            let university = data["university"] as? String ?? ""
            let password = data["userPsw"] as? String ?? ""
            let personInfo = UserInfoModel(userName: name,userSurname: surname,userPsw: password, university: university)
            complation(personInfo)
        }
    }
    
    func fetchURL(from documentID: String, selectedWebSite: String, completion: @escaping (String?) -> Void) {
        let documentRef = firestoreDatabase.collection("WebSites").document(documentID)
        
        documentRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("Document does not exist or data is missing")
                completion(nil)
                return
            }
            
            let url: String?
            switch selectedWebSite {
            case "libraryUrl":
                url = data["libraryUrl"] as? String
            case "refectoryUrl":
                url = data["refectoryUrl"] as? String
            default:
                url = nil
            }
            
            completion(url)
        }
    }
    
    
}
