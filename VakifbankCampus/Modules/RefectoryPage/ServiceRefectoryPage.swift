//
//  ServiceRefectoryPage.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 22.08.2024.
//
import FirebaseFirestore

protocol ServiceRefectoryProtocol{
    func fetchFoodMenuFromFirestore(selectedDate: String, compilation: @escaping (FoodMenuModel?) -> Void)
    func updateUserRemainderFromFirestore(userID: String,compilation: @escaping (String) -> Void)
    func updateCheckPayFoodIfPayDateIsYesterday(userID: String)
}

class ServiceRefectoryPage: ServiceRefectoryProtocol{
    
    let firestoreDatabase = Firestore.firestore()
    
    func fetchOldUserRemainder(userID: String, compilation: @escaping (Double?) -> Void){
        let documentRef = firestoreDatabase.collection("UserStudent").document(userID)
        
        documentRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
                compilation(nil)
            } else if let document = document, document.exists {
                let data = document.data()
                if let userRemainder = data?["user_remainder"] as? Double {
                    compilation(userRemainder)
                } else {
                    print("user_remainder field is not available or not a Double")
                    compilation(nil)
                }
            } else {
                print("Document does not exist")
                compilation(nil)
            }
        }
    }
    
    func fetchPayCheck(userID: String, completion: @escaping (Bool?) -> Void) {
        let documentRef = firestoreDatabase.collection("PayFoodControl").document(userID)
        documentRef.getDocument { (document, error) in
            if let error = error {
                completion(nil)
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    let checkPayFood = data?["checkPayFood"] as? Bool
                    completion(checkPayFood)
                } else {
                    completion(nil)
                    print("fetchCheckPayFood is failed")
                }
            }
        }
        
    }
    
    func updateUserRemainderFromFirestore(userID: String,compilation: @escaping (String) -> Void) {
        self.fetchOldUserRemainder(userID: userID) { oldRemainder in
            self.fetchPayCheck(userID: userID) { checkPayFood in
                let remainder = oldRemainder
                var newRemainder = Float()
                if checkPayFood == nil || checkPayFood == false{
                    let foodDebt = 20.0
                    if remainder ?? 0 > foodDebt {
                        newRemainder = Float((remainder ?? 0) - foodDebt)
                        self.updatePayCheck(userID: userID)
                        self.updateRemainder(userID: userID, newRemainder: Double(newRemainder))
                        compilation("update remainder is succes")
                    }
                    else {
                        compilation("Yetersiz Bakiye")
                    }
                }
                else {
                    let foodDebt = 92.0
                    if remainder ?? 0 > foodDebt {
                        newRemainder = Float((remainder ?? 0) - foodDebt)
                        self.updateRemainder(userID: userID, newRemainder: Double(newRemainder))
                        compilation("update remainder is succes")
                    }
                    else {
                        compilation("Yetersiz Bakiye")
                        
                    }
                }
            }
            
        }
    }
    
    func updateRemainder(userID: String, newRemainder: Double){
        let userRef = firestoreDatabase.collection("UserStudent").document(userID)
        
        userRef.updateData([
            "user_remainder": newRemainder
        ]) { error in
            if let error = error {
                print("Güncelleme yapılırken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Kullanıcı remainder başarıyla güncellendi.")
            }
        }
    }
    
    func updatePayCheck(userID: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let todayDateString = dateFormatter.string(from: Date())
        
        let data: [String: Any] = [
            "payDate": todayDateString,
            "checkPayFood": true
        ]
        
        firestoreDatabase.collection("PayFoodControl").document(userID).setData(data, merge: true) { error in
            if let error = error {
                print("Belge ekleme veya güncelleme hatası: \(error.localizedDescription)")
            } else {
                print("Belge başarıyla eklendi veya güncellendi!")
            }
        }
    }
    
    func fetchFoodMenuFromFirestore(selectedDate: String, compilation: @escaping (FoodMenuModel?) -> Void) {
        let baseFetchFoodExt = FetchFoodExtension()
        baseFetchFoodExt.fetchFoodFromFirebase(date: selectedDate) { foodMenuModel in
            if foodMenuModel != nil {
                compilation(foodMenuModel)
            }
            else{
                print("fetch foodMenu is failed")
            }
        }
    }
    
    func updateCheckPayFoodIfPayDateIsYesterday(userID: String) {
        let documentRef = firestoreDatabase.collection("PayFoodControl").document(userID)
        documentRef.getDocument { (document, error) in
            if let error = error {
                print("Belgeyi alma hatası: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                if let payDateString = data?["payDate"] as? String,
                   let payDate = self.date(from: payDateString),
                   let checkPayFood = data?["checkPayFood"] as? Bool {
                    
                    let today = Date()
                    
                    // Tarihler arasındaki farkı hesapla
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day], from: payDate, to: today)
                    
                    if let dayDifference = components.day, dayDifference == 1 {
                        // Eğer 1 gün fark varsa, 'checkPayFood' değerini false olarak güncelle
                        documentRef.updateData(["checkPayFood": false]) { error in
                            if let error = error {
                                print("Güncelleme hatası: \(error.localizedDescription)")
                            } else {
                                print("Güncelleme başarılı!")
                            }
                        }
                    }
                }
                else{
                    print("payDate veya checkPayFood verisi mevcut değil.")
                }
            }
            else {
                print("Belge mevcut değil.")
            }
        }
    }
    
    // Tarih string'ini `dd/MM/yyyy` formatından `Date` nesnesine dönüştüren yardımcı fonksiyon
    private func date(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: dateString)
    }
    
}
