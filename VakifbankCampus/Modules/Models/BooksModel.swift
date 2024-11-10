//
//  BooksModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 23.08.2024.
//

struct BooksModel {
    
    var id : String?
    var title : String
    var imageUrl : String
    var qrValue : String
    
    static func createFrom(_ data: [String: Any]) -> BooksModel? {
        let title = data["title"] as? String
        let imageUrl = data["imageUrl"] as? String
        let id = data["id"] as? String
        
        return BooksModel(id: id ?? "", title: title ?? "", imageUrl: imageUrl ?? "",qrValue: "")
    }
}

