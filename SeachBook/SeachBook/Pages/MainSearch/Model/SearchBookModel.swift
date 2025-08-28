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
    let image: String
}

extension ITBookSearchResponseModel.Book {
    var toBookModel: SearchBookModel {
        return .init(title: self.title,
                     subtitle: self.subtitle,
                     isbn13: self.isbn13,
                     price: self.price,
                     image: self.image)
    }
}
