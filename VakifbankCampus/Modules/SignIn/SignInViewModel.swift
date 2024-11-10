//
//  SignInViewModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 20.08.2024.
//

import Foundation

protocol SignInViewModelProtocol {
    func signIn()
    func fetchUserID()
    
    var serviceSignIn : ServiceSignInProtocol {get}
}

final class SignInViewModel: SignInViewModelProtocol {
    var userID : String = ""
    var tckNumber : String = ""
    var password : String = ""

    lazy var serviceSignIn: ServiceSignInProtocol = ServiceSignIn()
    weak var view: SignInViewControllerProtocol?
  
    func fetchUserID() {
        guard !tckNumber.isEmpty else {
            print("tckNumber is empty")
            return
        }
        serviceSignIn.getUserIdWithTckNumber(for: self.tckNumber) { [weak self] userID in
            guard let self = self else { return }
            self.userID = userID ?? "userID not found"
            print("Fetched userID: \(self.userID)")
            self.view?.navigateToHomePage()
        }

    }
    
    func signIn() {
        let (tcknumber, password) = view?.setSignInInfo() ?? ("", "")
        print("Attempting sign in with tcknumber: \(tcknumber), password: \(password)")
        serviceSignIn.checkUserFromFirebase(tckNumber: tcknumber, password: password) { [weak self] tckNumberString in
            guard let self = self else { return }
            if tckNumberString == "nil" {
                self.view?.showAlert(title: "İşlem Başarısız", message: "Eksik veya hatalı giriş yaptınız")
            } else {
                self.tckNumber = tcknumber
                self.fetchUserID()
            }
        }
    }
}
