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
}

struct ITBookAPI: ITBookAPIProtocol {
    enum EndPoint {
        case searchBooks(text: String, page: Int)

        var url: String {
            let url = "https://api.itbook.store/1.0"
            switch self {
            case let .searchBooks(keyword, page):
                return url + "/search/\(keyword)/\(page)"
            }
        }
    }
}

extension ITBookAPI {
    func searchBooks(text: String, page: Int) -> AnyPublisher<ITBookSearchResponseModel, APIError> {
        let url = EndPoint.searchBooks(text: text, page: page).url
        return HttpAPIManager.callRequest(api: url, method: .get, responseType: ITBookSearchResponseModel.self)
    }
}
