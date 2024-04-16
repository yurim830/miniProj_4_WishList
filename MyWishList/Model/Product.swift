//
//  Products.swift
//  MyWishList
//
//  Created by 유림 on 4/16/24.
//

import Foundation

struct Product: Codable {
    let id: Int
    let title: String
    let description: String
    let factoryPrice: Int
    let discountPercentage: Float
    let catagory: String
    let thumbnail: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case factoryPrice = "price"
        case discountPercentage
        case catagory
        case thumbnail
    }
}
