//
//  MockPersonInfoView.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 3.09.2024.
//

@testable import VakifbankCampus

class MockPersonInfoView: PersonInfoPageProtocol {
    var userInfoModel: UserInfoModel?
    var webSiteUrl : String?
    func setUserID() -> String {
        return "MockUserID"
    }
    
    func setPersonInfoCompanent(personInfoModel: VakifbankCampus.UserInfoModel) {
        self.userInfoModel = personInfoModel
    }
    
    func goToWebsite(webSiteUrl: String) {
        self.webSiteUrl = webSiteUrl
    }
    
}

