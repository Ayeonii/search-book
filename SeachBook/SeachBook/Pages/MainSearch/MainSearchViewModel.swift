//
//  MainSearchViewModel.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation
import Combine

final class MainSearchViewModel: BaseViewModel<MainSearchViewModel.Action,
                                 MainSearchViewModel.State,
                                 MainSearchViewModel.Event> {
    enum Action {
        case search(String)
        case paging
    }

    struct State {
        var books = [SearchBookModel]()
        var isLoading: Bool = false
        var inputText: String?
        var currentPage: Int = 1
        var hasMorePage: Bool = true
    }

    enum Event {
        case showAlert(String)
    }

    struct Depedency {
        var api: ITBookAPIProtocol = ITBookAPI()
    }

    private let dependency: Depedency

    private var enablePaging: Bool {
        return !currentState.isLoading && currentState.hasMorePage
    }

    init(dependency: Depedency) {
        self.dependency = dependency
        super.init(initialState: .init())
    }

    override func handleAction(_ action: Action) {
        switch action {
        case let .search(text):
            searchAction(text: text, page: 1)

        case .paging:
            guard let text = currentState.inputText, enablePaging else { return }
            searchAction(text: text, page: currentState.currentPage + 1)
        }
    }
}

extension MainSearchViewModel {
    private func searchAction(text: String, page: Int) {
        let noSpaceText = text.replacingOccurrences(of: " ", with: "")
        guard !noSpaceText.isEmpty else {
            return
        }

        setState {
            $0.isLoading = true
            $0.inputText = text
        }
        
        dependency.api.searchBooks(text: noSpaceText, page: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.sendEvent(.showAlert("일시적인 에러가 발생하였습니다."))
                    self?.setState { $0.isLoading = false }
                }
            } receiveValue: { [weak self] response in
                let isFirstPage = response.page == "1"

                if isFirstPage, response.total == "0" {
                    self?.sendEvent(.showAlert("검색결과가 없습니다."))
                    self?.setState { $0.isLoading = false }
                } else {
                    self?.setState {
                        let newBooks = response.books.map { $0.toBookModel }
                        if isFirstPage {
                            $0.books = newBooks
                        } else {
                            $0.books.append(contentsOf: newBooks)
                        }

                        $0.isLoading = false
                        $0.currentPage = Int(response.page) ?? 1
                        $0.hasMorePage = Int(response.total) ?? 0 > $0.books.count
                    }
                }
            }
            .store(in: &bag)
    }
}
