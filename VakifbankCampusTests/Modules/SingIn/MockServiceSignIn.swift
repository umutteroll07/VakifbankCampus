//
//  MockServiceSignIn.swift
//  VakifbankCampusTests
//
//  Created by Umut Erol on 2.09.2024.
//

@testable import VakifbankCampus

final class MockServiceSignIn: ServiceSignInProtocol {
    var shouldReturnUserID: Bool = true
    func getUserIdWithTckNumber(for tckNumber: String, completion: @escaping (String?) -> Void) {
        if shouldReturnUserID {
            completion("mockedUserID")
        } else {
            completion(nil)
        }
    }

    func checkUserFromFirebase(tckNumber: String, password: String, completion: @escaping (String) -> Void) {
        if tckNumber == "validTCK" && password == "validPassword" {
            completion(tckNumber)
        } else {
            completion("nil")
        }
    }
}
