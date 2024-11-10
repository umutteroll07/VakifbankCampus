//
//  RefectoryViewModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 22.08.2024.
//

protocol RefectoryViewModelProtocol{
    func getFoodMenu()
    func updateToUserRemainder()
    func updateCheckPayFood()
    var serviceRefectory : ServiceRefectoryProtocol {get}
    
    
}

class RefectoryViewModel: RefectoryViewModelProtocol{
    
    var selectedDate: String = ""
    var serviceRefectory: ServiceRefectoryProtocol = ServiceRefectoryPage()
    weak var view: RefectoryVCProtocol?
    
    
    var userID: String?
     init(view: RefectoryVCProtocol?) {
         self.view = view
         self.userID = view?.setUserID()
     }
    
    func getFoodMenu() {
        self.serviceRefectory.fetchFoodMenuFromFirestore(selectedDate: self.selectedDate) { foodMenuModel in
            if foodMenuModel != nil{
                self.view?.setFoodMenu(foodMenuModel: foodMenuModel ?? FoodMenuModel())
            }
            else {
                print("error fetch foodMenu")
            }
        }
    }
    
    func updateToUserRemainder() {
        self.serviceRefectory.updateUserRemainderFromFirestore(userID: userID ?? "") { response in
            if response == "update remainder is succes"{
                self.view?.makePaymentAlert(title: "Afiyet Olsun", message: "")
            }
            else if response == "Yetersiz Bakiye"{
                self.view?.makePaymentAlert(title: "Yetersiz Bakiye", message: "")
            }
        }
    }
    
    func updateCheckPayFood(){
        self.serviceRefectory.updateCheckPayFoodIfPayDateIsYesterday(userID: self.userID ?? "")
    }
    
    
    
}
