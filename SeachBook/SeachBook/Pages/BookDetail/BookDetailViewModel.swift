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

    }

    struct State {

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
}

