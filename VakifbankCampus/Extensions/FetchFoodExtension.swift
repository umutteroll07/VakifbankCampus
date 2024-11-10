//
//  FetchFoodExtension.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 21.08.2024.
//


import FirebaseFirestore

class FetchFoodExtension{
    
    func fetchFoodFromFirebase(date:String, completion: @escaping (FoodMenuModel?) -> Void) {
        var food1 = String()
        var food2 = String()
        var food3 = String()
        var food4 = String()
        
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Food").whereField("date", isEqualTo: date).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("food error guard")
                    return
                }
                for document in documents {
                    food1 = document.get("food1") as! String
                    food2 = document.get("food2") as! String
                    food3 = document.get("food3") as! String
                    food4 = document.get("food4") as! String
                }
                let foodMenuModel = FoodMenuModel(food1: food1,food2: food2,food3: food3,food4: food4)
                completion(foodMenuModel)
            }
        }
    }
}
