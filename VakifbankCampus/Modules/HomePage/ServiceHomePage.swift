//
//  ServiceHomePage.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 21.08.2024.
//

import FirebaseFirestore

protocol ServiceHomePageProtocol{
    func fetchUserInfoFromFirestore(userID: String, completion: @escaping (UserInfoModel?) -> Void)
    func compareDateAndDeleteFood()
    func fetchFoodMenuFromFirestore(compilation: @escaping (FoodMenuModel?) -> Void)
    func fetchNewsWithAPI(completion: @escaping ([Datas]?) -> Void)
}

class ServieHomePage: ServiceHomePageProtocol {
   
    let firestoreDatabase = Firestore.firestore()

    
    func fetchUserInfoFromFirestore(userID: String, completion: @escaping (UserInfoModel?) -> Void) {
        
        var userName = String()
        var userSurname = String()
        var user_iban = String()
        var user_remainder = Double()
        
        firestoreDatabase.collection("UserStudent").document(userID).getDocument { document, error in
            
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                completion(nil)
                return
            }
            
            // Data
            let userName = document.get("userName") as? String ?? ""
            let userSurname = document.get("userSurname") as? String ?? ""
            let userIBAN = document.get("user_iban") as? String ?? ""
            let userRemainder = document.get("user_remainder") as? Double ?? 0.0
            
            // Model
            let userPersonInfoModel = UserInfoModel(
                userName: userName,
                userSurname: userSurname,
                user_iban: userIBAN,
                user_remainder: userRemainder
            )
            completion(userPersonInfoModel)
        }
    }
    
    func fetchTodayDate() -> (String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let todayDate = dateFormatter.string(from: Date())
        return todayDate
    }
    
    func compareDateAndDeleteFood() {
        var deleteDate = String()
        let todayDate = fetchTodayDate()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        firestoreDatabase.collection("Food").getDocuments { snapshot, error in
            if error != nil {
                print("error date")
            }
            else {
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("date document error")
                    return
                }
                for document in documents {
                    guard let date = document.get("date") else {
                        print("error date compare")
                        return
                    }
                    
                    
                    let dateString1 = document.get("date")
                    guard let date1 = dateFormatter.date(from: dateString1 as! String),
                          let date2 = dateFormatter.date(from: todayDate) else {
                        fatalError("Invalid date format")
                    }
                    
                    let compareBool = date1.compare(date2)
                    
                    switch compareBool {
                    case .orderedAscending:
                        
                        deleteDate = dateString1 as! String
                        self.firestoreDatabase.collection("Food").whereField("date", isEqualTo: deleteDate).getDocuments { snapshot, error in
                            if error != nil {
                                print("delete Error")
                            }
                            guard let documents = snapshot?.documents, !documents.isEmpty else {
                                print("delete document error")
                                return
                            }
                            
                            for document in documents {
                                self.firestoreDatabase.collection("Food").document(document.documentID).delete { error in
                                    guard let error = error else {return}
                                    print("documentID error")
                                }
                            }
                        }
                    case .orderedSame:
                        deleteDate = ""
                    case .orderedDescending:
                        deleteDate = ""
                    }
                }
            }
        }
    }
    
    func fetchFoodMenuFromFirestore(compilation: @escaping (FoodMenuModel?) -> Void) {
        self.compareDateAndDeleteFood()
        let baseFetchFoodExt = FetchFoodExtension()
        baseFetchFoodExt.fetchFoodFromFirebase(date: fetchTodayDate()) { foodMenuModel in
            if foodMenuModel != nil {
                compilation(foodMenuModel)
            }
            else{
                print("fetch foodMenu is failed")
            }
        }
    }

    func fetchNewsWithAPI(completion: @escaping ([Datas]?) -> Void) {
        guard let url = URL(string: "https://api.mediastack.com/v1/news?access_key=bceb5cf4385ce89de942225c230f909b&keywords=general&countries=tr")
        else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let data = data {
                let response = try? JSONDecoder().decode(NewsModel.self, from: data)
                completion(response?.data)
            }
        }.resume()
    }
}
