//
//  ITBookSearchResponseModel.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation

struct ITBookSearchResponseModel: Decodable {
    let total: String
    let page: String
    let books: [Book]

    struct Book: Codable {
        let title: String
        let subtitle: String
        let isbn13: String
        let price: String
        let image: String
        let url: String
    }
}
