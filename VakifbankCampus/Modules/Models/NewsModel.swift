//
//  NewsModel.swift
//  VakifbankCampus
//
//  Created by Umut Erol on 21.08.2024.
//

struct NewsModel : Codable {
    let data : [Datas]
}

struct Datas : Codable {
    let title : String
    let url : String
    let image : String
}
