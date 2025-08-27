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
    }

    private func setupLayout() {
        
    }

    private func bindViewModel(_ viewModel: BookDetailViewModel) {

    }
}
