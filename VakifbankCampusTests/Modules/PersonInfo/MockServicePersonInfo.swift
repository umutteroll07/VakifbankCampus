//
//  MockServicePersonInfo.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 3.09.2024.
//

@testable import VakifbankCampus

class MockServicePersonInfo: ServicePersonInfoProtocol {
    var personInfo = UserInfoModel()
    var webUrl = String()
    func fetchPersonInfoFromFirestore(userID: String, complation: @escaping (VakifbankCampus.UserInfoModel) -> Void) {
        complation(personInfo)
    }
    
    func fetchURL(from documentID: String, selectedWebSite: String, completion: @escaping (String?) -> Void) {
        completion(webUrl)
    }
    

}
