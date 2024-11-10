//
//  MockSingInViewController.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 2.09.2024.
//

@testable import VakifbankCampus

class MockSignInViewController: SignInViewControllerProtocol {
    
    var didNavigateToHomePage = false
    var didShowAlert = false
    var alertTitle: String?
    var alertMessage: String?
    
    var signInInfoToReturn: (String, String)?

    func navigateToHomePage() {
        didNavigateToHomePage = true
    }
    
    func showAlert(title: String, message: String) {
        didShowAlert = true
        alertTitle = title
        alertMessage = message
    }
    
    func setSignInInfo() -> (String, String)? {
        return signInInfoToReturn
    }
}

