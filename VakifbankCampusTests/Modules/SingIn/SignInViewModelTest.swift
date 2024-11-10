//
//  HomeViewModelTest.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 2.09.2024.
//

import XCTest
@testable import VakifbankCampus

final class SignInViewModelTests: XCTestCase {
    
    var viewModel: SignInViewModel!
    var mockServiceSignIn: MockServiceSignIn!
    var mockView: MockSignInViewController!
    
    override func setUp() {
        super.setUp()
        // Test öncesinde çalıştırılan kod
        viewModel = SignInViewModel()
        mockServiceSignIn = MockServiceSignIn()
        mockView = MockSignInViewController()
        
        viewModel.serviceSignIn = mockServiceSignIn
        viewModel.view = mockView
    }
    
    override func tearDown() {
        // Test sonrasında çalıştırılan kod
        viewModel = nil
        mockServiceSignIn = nil
        mockView = nil
        super.tearDown()
    }
    
    
    func testSignInWithValidCredentials() {
        
        mockView.signInInfoToReturn = ("validTCK", "validPassword")
        
        viewModel.signIn()
        
        XCTAssertEqual(viewModel.tckNumber, "validTCK")
        XCTAssertEqual(viewModel.userID, "mockedUserID")
        XCTAssertTrue(mockView.didNavigateToHomePage)
        XCTAssertFalse(mockView.didShowAlert)
    }
    
    func testSignInWithInvalidCredentials() {
 
        
        mockServiceSignIn.shouldReturnUserID = false
        mockView.signInInfoToReturn = ("invalidTCK", "invalidPassword")
        
        viewModel.signIn()
        
        XCTAssertTrue(mockView.didShowAlert)
        XCTAssertEqual(mockView.alertTitle, "İşlem Başarısız")
        XCTAssertEqual(mockView.alertMessage, "Eksik veya hatalı giriş yaptınız")
    }
    
    func testFetchUserIDWithEmptyTckNumber() {
        viewModel.tckNumber = ""
        viewModel.fetchUserID()
        
        XCTAssertEqual(viewModel.userID, "")
        XCTAssertFalse(mockView.didNavigateToHomePage)
    }
}
