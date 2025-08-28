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

    func test_searchAction_발생시_정상응답일_경우_state_books에_응답값이_할당되고_reload이벤트가_방출된다() {
        // given
        let mockAPI = MockITBookAPI()
        mockAPI.searchResult = .success(searchSuccessResponse)

        let vm = MainSearchViewModel(dependency: .init(api: mockAPI))
        let exp = expectation(description: "items reload")

        vm.eventPublisher
            .sink { event in
                switch event {
                case .reload:
                    exp.fulfill()

                default:
                    return
                }
            }
            .store(in: &bag)

        // when
        vm.handleAction(.search("mongodb"))

        // then
        wait(for: [exp], timeout: 1.0)

        let currentStateBooks = vm.currentState.books
        XCTAssertEqual(currentStateBooks.count, 2)
        XCTAssertEqual(currentStateBooks[0].isbn13, "9781617291609")
        XCTAssertEqual(currentStateBooks[1].isbn13, "9781449310370")
    }

    func test_searchAction_발생시_Fail일_경우_showAlert이벤트발생_reload_이벤트는_방출되지_않는다() {
        // given
        let mockAPI = MockITBookAPI()
        mockAPI.searchResult = .failure(APIError.server(500, nil))

        let vm = MainSearchViewModel(dependency: .init(api: mockAPI))
        let expAlert = expectation(description: "show error alert")

        let expNoStateChange = expectation(description: "no state change on failure")
        expNoStateChange.isInverted = true

        vm.eventPublisher
            .sink { event in
                switch event {
                case let .showAlert(message):
                    XCTAssertEqual(message, "일시적인 에러가 발생하였습니다.")
                    expAlert.fulfill()

                case .reload:
                    expNoStateChange.fulfill()

                default:
                    return
                }
            }
            .store(in: &bag)


        // when
        vm.handleAction(.search("mongodb"))

        // then
        wait(for: [expAlert, expNoStateChange], timeout: 1.0)

        let currentStateBooks = vm.currentState.books
        XCTAssertEqual(currentStateBooks.count, 0)
    }

    func test_searchAction_발생후_Paging_action발생시_books에_추가된다() {
        // given
        let mockAPI = MockITBookAPI()
        let vm = MainSearchViewModel(dependency: .init(api: mockAPI))

        mockAPI.searchResult = .success(searchSuccessResponse)
        let expFirstPage = expectation(description: "FirstPage loaded")
        vm.eventPublisher
            .sink { event in
                switch event {
                case .reload:
                    expFirstPage.fulfill()

                default:
                    return
                }
            }
            .store(in: &bag)

        vm.handleAction(.search("mongodb"))
        wait(for: [expFirstPage], timeout: 1.0)

        mockAPI.searchResult = .success(searchSuccessPagingResponse)
        let expSecondPage = expectation(description: "SecondPage loaded")

        vm.eventPublisher
            .sink { event in
                switch event {
                case let .insertItems(indexes):
                    XCTAssertEqual(indexes, [2])
                    expSecondPage.fulfill()

                default:
                    return
                }
            }
            .store(in: &bag)

        vm.handleAction(.paging)

        // then
        wait(for: [expSecondPage], timeout: 1.0)

        let currentState = vm.currentState
        XCTAssertEqual(currentState.currentPage, 2)
        XCTAssertEqual(currentState.books.count, 3)
        XCTAssertEqual(currentState.books.last?.isbn13, "978161609")
    }

    func test_paging_Action은_isLoading이_true일_경우_무시된다() {
        // given
        let mockAPI = MockITBookAPI()
        let vm = MainSearchViewModel(dependency: .init(api: mockAPI))

        vm.setState {
            $0.inputText = "mongodb"
            $0.isLoading = true
            $0.currentPage = 1
            $0.books = []
        }

        let noChange = expectation(description: "paging ignored while loading")
        noChange.isInverted = true

        vm.statePublisher
            .dropFirst()
            .sink { _ in
                noChange.fulfill()
            }
            .store(in: &bag)
        vm.handleAction(.paging)

        // then
        wait(for: [noChange], timeout: 1.0)

        let currentState = vm.currentState
        XCTAssertTrue(currentState.isLoading)
        XCTAssertEqual(currentState.currentPage, 1)
        XCTAssertTrue(currentState.books.isEmpty)
    }

    func test_searchAction시_로딩이끝난_시점에_응답의_total값과_갱신된_books수가_같다면_hasMorePage값은_true에서_false가_된다() {
        // given
        let mockAPI = MockITBookAPI()
        mockAPI.searchResult = .success(searchSuccessLastPageResponse)

        let vm = MainSearchViewModel(dependency: .init(api: mockAPI))
        XCTAssertTrue(vm.currentState.hasMorePage)

        let exp = expectation(description: "loaded and hasMorePage updated to false")

        vm.statePublisher
            .dropFirst()
            .filter { !$0.isLoading }
            .first()
            .sink { state in
                XCTAssertEqual(state.books.count, 1)
                XCTAssertEqual(state.currentPage, 1)
                XCTAssertFalse(state.hasMorePage)
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

    private var searchSuccessPagingResponse: Data {
        return """
        {
            "error": "0",
            "total": "80",
            "page": "2",
            "books": [
                {
                    "title": "MongoDB in Action, 3nd Edition",
                    "subtitle": "Covers MongoDB version 3.0",
                    "isbn13": "978161609",
                    "price": "$19.99",
                    "image": "https://itbook.store/img/books/9781617291609.png",
                    "url": "https://itbook.store/books/9781617291609"
                }
            ]
        }
        """.data(using: .utf8)!
    }

    private var searchSuccessLastPageResponse: Data {
        return """
        {
            "error": "0",
            "total": "1",
            "page": "1",
            "books": [
                {
                    "title": "MongoDB in Action, 3nd Edition",
                    "subtitle": "Covers MongoDB version 3.0",
                    "isbn13": "978161609",
                    "price": "$19.99",
                    "image": "https://itbook.store/img/books/9781617291609.png",
                    "url": "https://itbook.store/books/9781617291609"
                }
            ]
        }
        """.data(using: .utf8)!
    }
}
