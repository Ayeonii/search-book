//
//  ITBookAPI.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation
import Combine

protocol ITBookAPIProtocol {
    func searchBooks(text: String, page: Int) -> AnyPublisher<ITBookSearchResponseModel, APIError>
    func getBookDetail(isbn13: String) -> AnyPublisher<ITBookDetailResponseModel, APIError>
}

struct ITBookAPI: ITBookAPIProtocol {
    enum EndPoint {
        case searchBooks(text: String, page: Int)
        case bookDetail(isbn13: String)

        var url: String {
            let url = "https://api.itbook.store/1.0"
            switch self {
            case let .searchBooks(keyword, page):
                return url + "/search/\(keyword)/\(page)"

            case let .bookDetail(isbn13):
                return url + "/books/\(isbn13)"
            }
        }
    }
}

extension ITBookAPI {
    func searchBooks(text: String, page: Int) -> AnyPublisher<ITBookSearchResponseModel, APIError> {
        let url = EndPoint.searchBooks(text: text, page: page).url
        return HttpAPIManager.callRequest(api: url, method: .get, responseType: ITBookSearchResponseModel.self)
    }

    func getBookDetail(isbn13: String) -> AnyPublisher<ITBookDetailResponseModel, APIError> {
        let url = EndPoint.bookDetail(isbn13: isbn13).url
        return HttpAPIManager.callRequest(api: url, method: .get, responseType: ITBookDetailResponseModel.self)
    }
}
