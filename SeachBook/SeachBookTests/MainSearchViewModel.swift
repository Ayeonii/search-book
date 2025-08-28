//
//  MainSearchViewModel.swift
//  SeachBookTests
//
//  Created by 이아연 on 8/24/25.
//

import XCTest
import Combine
@testable import SeachBook

final class MainSearchViewModelTests: XCTestCase {

    private var bag: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        bag = []
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        bag = nil
    }

    func test_searchAction_발생시_정상응답일_경우_state_books에_응답값이_할당된다() {
        // given
        let mockAPI = MockITBookAPI()
        mockAPI.searchResult = .success(searchSuccessResponse)

        let vm = MainSearchViewModel(dependency: .init(api: mockAPI))
        let exp = expectation(description: "items updated")

        vm.statePublisher
            .map { $0.books }
            .dropFirst()
            .sink { books in
                XCTAssertEqual(books.count, 2)
                XCTAssertEqual(books[0].isbn13, "9781617291609")
                XCTAssertEqual(books[1].isbn13, "9781449310370")
                exp.fulfill()
            }
            .store(in: &bag)

        // when
        vm.handleAction(.search("mongodb"))

        // then
        wait(for: [exp], timeout: 1.0)
    }
}

extension MainSearchViewModelTests {
    private var searchSuccessResponse: Data {
        return """
        {
            "error": "0",
            "total": "80",
            "page": "1",
            "books": [
                {
                    "title": "MongoDB in Action, 2nd Edition",
                    "subtitle": "Covers MongoDB version 3.0",
                    "isbn13": "9781617291609",
                    "price": "$19.99",
                    "image": "https://itbook.store/img/books/9781617291609.png",
                    "url": "https://itbook.store/books/9781617291609"
                },
                {
                    "title": "MongoDB and Python",
                    "subtitle": "Patterns and processes for the popular document-oriented database",
                    "isbn13": "9781449310370",
                    "price": "$6.88",
                    "image": "https://itbook.store/img/books/9781449310370.png",
                    "url": "https://itbook.store/books/9781449310370"
                }
            ]
        }
        """.data(using: .utf8)!
    }
}
