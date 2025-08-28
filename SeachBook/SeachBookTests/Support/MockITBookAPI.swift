//
//  MockITBookAPI.swift
//  SeachBookTests
//
//  Created by 이아연 on 8/24/25.
//

import Foundation
import Combine
@testable import SeachBook

final class MockITBookAPI: ITBookAPIProtocol {
    var searchResult: Result<Data, APIError> = .success(Data())
    var bookDetailResult: Result<Data, APIError> = .success(Data())

    func searchBooks(text: String, page: Int?) -> AnyPublisher<ITBookSearchResponseModel, APIError> {
        switch searchResult {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode(ITBookSearchResponseModel.self, from: data)
                return Just(decoded)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: APIError.decodingError(error))
                    .eraseToAnyPublisher()
            }

        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    func getBookDetail(isbn13: String) -> AnyPublisher<ITBookDetailResponseModel, APIError> {
        switch bookDetailResult {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode(ITBookDetailResponseModel.self, from: data)
                return Just(decoded)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(error: APIError.decodingError(error))
                    .eraseToAnyPublisher()
            }

        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
