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

    }

    struct State {
        // todo - 모델 구성 후 변경 예정
        var items = [String]()
    }

    enum Event {

    }

    struct Depedency {

    }

    init(dependency: Depedency) {
        super.init(initialState: .init())
    }
}
