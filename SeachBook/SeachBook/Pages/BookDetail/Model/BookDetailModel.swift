//
//  BookDetailModel.swift
//  SeachBook
//
//  Created by 이아연 on 8/26/25.
//

import Foundation

struct BookDetailModel {
    let title: String
    let subtitle: String
    let authors: String
    let publisher: String
    let language: String
    let isbn10: String
    let isbn13: String
    let totalPages: String
    let publishedyear: String
    let rating: String
    let desc: String
    let price: String
    let imageURL: String
    let webURL: String
    let pdf: [String: String]?
}

extension ITBookDetailResponseModel {
    var toBookDetailModel: BookDetailModel {
        .init(title: title,
              subtitle: subtitle,
              authors: authors,
              publisher: publisher,
              language: language,
              isbn10: isbn10,
              isbn13: isbn13,
              totalPages: pages,
              publishedyear: year,
              rating: rating,
              desc: desc,
              price: price,
              imageURL: image,
              webURL: url,
              pdf: pdf)
    }
}
