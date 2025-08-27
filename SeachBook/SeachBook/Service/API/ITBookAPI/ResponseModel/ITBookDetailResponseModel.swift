//
//  ITBookDetailResponseModel.swift
//  SeachBook
//
//  Created by 이아연 on 8/26/25.
//

import Foundation

struct ITBookDetailResponseModel: Codable {
    let error: String
    let title: String
    let subtitle: String
    let authors: String
    let language: String
    let publisher: String
    let isbn10: String
    let isbn13: String
    let pages: String
    let year: String
    let rating: String
    let desc: String
    let price: String
    let image: String
    let url: String
    let pdf: [String: String]?
}
