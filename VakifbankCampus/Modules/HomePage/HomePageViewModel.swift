//
//  HomePageViewModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 21.08.2024.
//

protocol HomePageViewModelProtocol{
    func getUserInfo()
    func getFoodMenu()
    func getNews()
    
    var servieceHomePage : ServiceHomePageProtocol {get}
}

class HomePageViewModel : HomePageViewModelProtocol{
    
    lazy var servieceHomePage: ServiceHomePageProtocol = ServieHomePage()
    weak var view: HomePageProtocol?
    var newsModelList = [Datas]()
    
    
    var userID: String?
    init(view: HomePageProtocol?) {
        self.view = view
        self.userID = view?.setUserID()
    }
    
    func getUserInfo() {
        self.servieceHomePage.fetchUserInfoFromFirestore(userID: userID ?? "") { userInfoModel in
            self.view?.setUserInfoLabel(userInfoModel: userInfoModel ?? UserInfoModel())
        }
    }
    
    func getFoodMenu() {
        self.servieceHomePage.fetchFoodMenuFromFirestore { foodMenuModel in
            if foodMenuModel != nil{
                self.view?.setFoodMenu(foodMenuModel: foodMenuModel ?? FoodMenuModel())
            }
            else {
                print("error fetch foodMenu")
            }
        }
    }
    
    func getNews() {
        self.servieceHomePage.fetchNewsWithAPI { newsModel in
            guard let news = newsModel else { return }
            for new in news {
                self.newsModelList.append(new)
            }
        }
    }
}
