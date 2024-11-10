//
//  GetToday.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 23.08.2024.
//

import Foundation

class GetTodayExtension{
    
    static func fetchToday() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let todayDate = dateFormatter.string(from: Date())
        return todayDate
    }
}
