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
    }

    struct State {
        var books = [SearchBookModel]()
    }

    enum Event {
        
    }

    struct Depedency {
        var api: ITBookAPIProtocol = ITBookAPI()
    }

    private let dependency: Depedency

    init(dependency: Depedency) {
        self.dependency = dependency
        super.init(initialState: .init())
    }

    override func handleAction(_ action: Action) {
        switch action {
        case let .search(text):
            searchAction(text: text)
        }
    }
}

extension MainSearchViewModel {
    private func searchAction(text: String) {
        let noSpaceText = text.replacingOccurrences(of: " ", with: "")

        guard !noSpaceText.isEmpty else {
            return
        }

        dependency.api.searchBooks(text: noSpaceText, page: 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    // TODO: 에러 핸들링
                }
            } receiveValue: { [weak self] response in
                if response.total == "0" {
                    // TODO: 검색 결과 없음 안내
                } else {
                    self?.setState { state in
                        var newState = state
                        newState.books = response.books.map { $0.toBookModel }
                        return newState
                    }
                }
            }
            .store(in: &bag)
    }
}
