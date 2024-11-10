//
//  ChangePasswordViewModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 29.08.2024.
//

import Foundation
import FirebaseFirestore

class ChangePasswordViewModel{
    let firestoreDatabase = Firestore.firestore()
    
    func updatePassword(userID: String, enteredOldPsw: String, enteredNewPsw: String, enteredNewPswAgain: String,complation: @escaping (String,String,Bool) -> Void){
        self.fetchUserPassword(documentID: userID) { oldPsw in
            if enteredOldPsw != "" {
                if enteredNewPswAgain != "" {
                    if enteredOldPsw == oldPsw {
                        if enteredNewPsw == enteredNewPswAgain {
                            self.updateUserPassword(userID: userID, newPsw: enteredNewPsw) { result in
                                switch result {
                                case .success():
                                    print("Şifre başarıyla güncellendi.")
                                case .failure(let error):
                                    print("Şifre güncellenirken bir hata oluştu: \(error.localizedDescription)")
                                }
                            }
                            complation("İşlem Başarılı", "",true)
                            
                        }
                        else {
                            complation("İşlem Gerçekleştirilemedi", "Yeni şifreniz tekrarı ile eşleşmiyor",false)
                        }
                    }
                    else{
                        complation("İşlem gerçekleştirilemedi", "Eski şifreniz yanlış girilmiştir",false)
                    }
                }
                else{
                    complation("İşlem gerçekleştirilemedi","Bilgilerinizi eksik girdiniz",false)
                }
            }
            else{
                complation("İşlem gerçekleştirilemedi","Bilgilerinizi eksik girdiniz",false)
            }
        }
        
    }
    
    func updateUserPassword(userID: String, newPsw: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = firestoreDatabase.collection("UserStudent").document(userID)
        userRef.updateData([
            "userPsw": newPsw
        ]) { error in
            if let error = error {
                // Failed
                completion(.failure(error))
            } else {
                // Success
                completion(.success(()))
            }
        }
    }
    
    
    func fetchUserPassword(documentID: String, completion: @escaping (String?) -> Void) {
        let userStudentRef = firestoreDatabase.collection("UserStudent").document(documentID)
        
        userStudentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let userPassword = document.data()?["userPsw"] as? String {
                    completion(userPassword)
                } else {
                    completion(nil)
                }
            } else {
                print("Document does not exist: \(error?.localizedDescription ?? "No error message available.")")
                completion(nil)
            }
        }
    }
    
    
}

