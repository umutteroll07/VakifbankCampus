//
//  PersonInfoViewModelTest.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 3.09.2024.
//

import XCTest
@testable import VakifbankCampus

final class PersonInfoViewModelTest : XCTestCase{
    
    var viewModel: PersonInfoViewModel!
    var mockServicePersonInfo: MockServicePersonInfo!
    var mockView: MockPersonInfoView!
    
    override func setUp() {
        mockServicePersonInfo = MockServicePersonInfo()
        mockView = MockPersonInfoView()
        
        viewModel = PersonInfoViewModel(view: mockView)
        viewModel.servicePersonInfo = mockServicePersonInfo

    }

    override func tearDown() {
        viewModel = nil
        mockServicePersonInfo = nil
        mockView = nil
        super.tearDown()
    }
    
    func testGetUserInfo() {
        let userName = UserInfoModel(userName: "umuterol")
        mockServicePersonInfo.personInfo = userName
        viewModel.getPersonInfo()
        XCTAssertEqual(mockView.userInfoModel, userName)
    }
    
}
