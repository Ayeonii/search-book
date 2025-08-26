//
//  BaseViewModel.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import Foundation
import Combine

//MARK: - ViewModelType protocol
protocol ViewModelType: AnyObject {
    associatedtype Action
    associatedtype State
    associatedtype Event

    var statePublisher: AnyPublisher<State, Never> { get }
    var eventPublisher: AnyPublisher<Event, Never> { get }

    func sendAction(_ action: Action)
}

//MARK: - BaseViewModel
class BaseViewModel<A, S, E>: ViewModelType {
    typealias Action = A
    typealias State = S
    typealias Event = E

    private let actionSubject = PassthroughSubject<Action, Never>()
    private let stateSubject: CurrentValueSubject<State, Never>
    private let eventSubject = PassthroughSubject<Event, Never>()

    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    var eventPublisher: AnyPublisher<Event, Never> { eventSubject.eraseToAnyPublisher() }

    var currentState: State { stateSubject.value }

    var bag = Set<AnyCancellable>()

    init(initialState: State) {
        self.stateSubject = .init(initialState)
        bindActions()
    }

    private func bindActions() {
        actionSubject
            .sink { [weak self] in self?.handleAction($0) }
            .store(in: &bag)
    }

    func sendAction(_ action: Action) {
        actionSubject.send(action)
    }

    func handleAction(_ action: Action) { }

    // MARK: - Protected helpers
    func setState(_ update: @escaping (State) -> State) {
        if Thread.isMainThread {
            stateSubject.send(update(stateSubject.value))
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.stateSubject.send(update(self.stateSubject.value))
            }
        }
    }

    func sendEvent(_ event: Event) {
        if Thread.isMainThread {
            eventSubject.send(event)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.eventSubject.send(event)
            }
        }
    }
}
