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
        case showAlert(String)
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
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.sendEvent(.showAlert("일시적인 에러가 발생하였습니다."))
                }
            } receiveValue: { [weak self] response in
                if response.total == "0" {
                    self?.sendEvent(.showAlert("검색결과가 없습니다."))
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
