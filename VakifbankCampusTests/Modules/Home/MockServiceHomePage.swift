//
//  MockServiceHomePage.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 3.09.2024.
//
@testable import VakifbankCampus
import Foundation
class MockServiceHomePage: ServiceHomePageProtocol {
    func compareDateAndDeleteFood() {
        
    }
    
    var userInfoModel: UserInfoModel?
    var foodMenuModel: FoodMenuModel?
    var newsModel: [Datas]?
    
    func fetchUserInfoFromFirestore(userID: String, completion: @escaping (UserInfoModel?) -> Void) {
        completion(userInfoModel)
    }
    
    func fetchFoodMenuFromFirestore(compilation: @escaping (FoodMenuModel?) -> Void) {
        compilation(foodMenuModel)
    }
    
    func fetchNewsWithAPI(completion: @escaping ([Datas]?) -> Void) {
        completion(newsModel)
    }
}
