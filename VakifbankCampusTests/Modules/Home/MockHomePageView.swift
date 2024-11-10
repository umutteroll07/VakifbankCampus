//
//  MockHomePageView.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 3.09.2024.
//
@testable import VakifbankCampus
class MockHomePageView: HomePageProtocol {
    var userInfoLabel: UserInfoModel?
    var foodMenu: FoodMenuModel?
    
    func setUserID() -> String? {
        return "MockUserID"
    }
    
    func setUserInfoLabel(userInfoModel: UserInfoModel) {
        self.userInfoLabel = userInfoModel
    }
    
    func setFoodMenu(foodMenuModel: FoodMenuModel) {
        self.foodMenu = foodMenuModel
    }
}
