//
//  HomePageViewModelTest.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 3.09.2024.
//

import XCTest
@testable import VakifbankCampus

class HomePageViewModelTests: XCTestCase {
    
    var viewModel: HomePageViewModel!
    var mockService: MockServiceHomePage!
    var mockView: MockHomePageView!
    
    override func setUp() {
        super.setUp()
        mockService = MockServiceHomePage()
        mockView = MockHomePageView()
        
        viewModel = HomePageViewModel(view: mockView)
        viewModel.servieceHomePage = mockService
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockView = nil
        super.tearDown()
    }
    
    func testGetUserInfo() {
        let expectedUserInfo = UserInfoModel(userName: "John Doe")
        mockService.userInfoModel = expectedUserInfo
        viewModel.getUserInfo()
        XCTAssertEqual(mockView.userInfoLabel, expectedUserInfo)
    }
    
    func testGetFoodMenu() {
        let expectedFoodMenu = FoodMenuModel()
        mockService.foodMenuModel = expectedFoodMenu
        viewModel.getFoodMenu()
        XCTAssertEqual(mockView.foodMenu, expectedFoodMenu)
    }
    
    func testGetNews() {
        let expectedNews = Datas(title: "News Title",url: "url",image: "image")
        mockService.newsModel = [expectedNews]
        viewModel.getNews()
        XCTAssertEqual(viewModel.newsModelList.count, 1)
        XCTAssertEqual(viewModel.newsModelList.first?.title, "News Title")
    }
}


