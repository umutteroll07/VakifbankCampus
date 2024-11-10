//
//  PersonInfoViewModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 29.08.2024.
//

import Foundation

protocol PersonInfoViewModelProtocol{
    func getPersonInfo()
    
    var servicePersonInfo : ServicePersonInfoProtocol {get}
}

class PersonInfoViewModel: PersonInfoViewModelProtocol{
    
    var servicePersonInfo: ServicePersonInfoProtocol = ServicePersonInfoPage()
    weak var view: PersonInfoPageProtocol?
    var selectedStudentsUniversity : String?
    var oldPassword : String?
    
    var userID: String?
    init(view: PersonInfoPageProtocol?) {
        self.view = view
        self.userID = view?.setUserID()
    }
    
    func getPersonInfo() {
        self.servicePersonInfo.fetchPersonInfoFromFirestore(userID: self.userID ?? "") { personInfoModel in
            self.view?.setPersonInfoCompanent(personInfoModel: personInfoModel)
            self.selectedStudentsUniversity = personInfoModel.university
            self.oldPassword = personInfoModel.userPsw
        }
    }
    
    func getUrl(selectedWebSite: String){
        self.servicePersonInfo.fetchURL(from: selectedStudentsUniversity ?? "", selectedWebSite: selectedWebSite) { webSiteUrl in
            self.view?.goToWebsite(webSiteUrl: webSiteUrl ?? "")
        }
    }
    
}
