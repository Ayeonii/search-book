//
//  SearchDetailViewModelTests.swift
//  SeachBookTests
//
//  Created by 이아연 on 8/28/25.
//

import XCTest
import Combine
@testable import SeachBook

final class SearchDetailViewModelTests: XCTestCase {

    private var bag: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        bag = []
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        bag = nil
    }

    func test_setupData_Action_발생시_정상응답일_경우_state_book에_응답값이_할당된다() {
        // given
        let mockAPI = MockITBookAPI()
        mockAPI.bookDetailResult = .success(bookSuccessResponse)

        let vm = BookDetailViewModel(dependency: .init(isbn13: "9781617294136", api: mockAPI))
        let exp = expectation(description: "item updated")

        vm.statePublisher
            .compactMap { $0.book }
            .sink { book in
                XCTAssertEqual(book.title, "Securing DevOps")
                XCTAssertEqual(book.authors, "Julien Vehent")
                exp.fulfill()
            }
            .store(in: &bag)

        // when
        vm.handleAction(.setupData)

        // then
        wait(for: [exp], timeout: 1.0)
    }

}

extension SearchDetailViewModelTests {
    private var bookSuccessResponse: Data {
        return """
        {
          "error": "0",
          "title": "Securing DevOps",
          "subtitle": "Security in the Cloud",
          "authors": "Julien Vehent",
          "publisher": "Manning",
          "language": "English",
          "isbn10": "1617294136",
          "isbn13": "9781617294136",
          "pages": "384",
          "year": "2018",
          "rating": "4",
          "desc": "An application running in the cloud can benefit from incredible efficiencies, but they come with unique security threats too. A DevOps team&#039;s highest priority is understanding those risks and hardening the system against them.Securing DevOps teaches you the essential techniques to secure your c...",
          "price": "$39.65",
          "image": "https://itbook.store/img/books/9781617294136.png",
          "url": "https://itbook.store/books/9781617294136",
          "pdf": {
            "Chapter 2": "https://itbook.store/files/9781617294136/chapter2.pdf",
            "Chapter 5": "https://itbook.store/files/9781617294136/chapter5.pdf"
          }
        }
        """.data(using: .utf8)!
    }
}
