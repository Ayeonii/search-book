//
//  BookDetailViewController.swift
//  SeachBook
//
//  Created by 이아연 on 8/26/25.
//

import UIKit
import Combine

final class BookDetailViewController: BaseViewController<BookDetailViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        bindViewModel(viewModel)
        viewModel.handleAction(.setupData)
    }

    private func setupLayout() {
        
    }

    private func bindViewModel(_ viewModel: BookDetailViewModel) {
        viewModel.statePublisher
            .map { $0.book }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { book in
                // 화면 구성
            })
            .store(in: &bag)
    }
}
