//
//  BookDetailViewModel.swift
//  SeachBook
//
//  Created by 이아연 on 8/26/25.
//

import Foundation

final class BookDetailViewModel: BaseViewModel<BookDetailViewModel.Action,
                                               BookDetailViewModel.State,
                                               BookDetailViewModel.Event> {
    enum Action {
        case setupData
    }

    struct State {
        var book: BookDetailModel?
    }

    enum Event {
        case showAlert(String)
    }

    struct Depedency {
        let isbn13: String
        var api: ITBookAPIProtocol = ITBookAPI()
    }

    private let dependency: Depedency

    init(dependency: Depedency) {
        self.dependency = dependency
        super.init(initialState: .init())
    }

    override func handleAction(_ action: Action) {
        switch action {
        case .setupData:
            setupData()
        }
    }
}

extension BookDetailViewModel {
    private func setupData() {
        dependency.api.getBookDetail(isbn13: dependency.isbn13)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.sendEvent(.showAlert("일시적인 에러가 발생하였습니다."))
                }
            } receiveValue: { [weak self] response in
                self?.setState { $0.book = response.toBookDetailModel }
            }
            .store(in: &bag)
    }
}
