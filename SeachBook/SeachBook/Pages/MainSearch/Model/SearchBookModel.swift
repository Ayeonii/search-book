//
//  SearchBookModel.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation

struct SearchBookModel: Equatable {
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let imageURL: String
    let url: String
}

extension ITBookSearchResponseModel.Book {
    var toBookModel: SearchBookModel {
        return .init(title: title,
                     subtitle: subtitle,
                     isbn13: isbn13,
                     price: price,
                     imageURL: image,
                     url: url
        )
    }
}
