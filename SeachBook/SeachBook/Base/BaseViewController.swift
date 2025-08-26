//
//  BaseViewController.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import UIKit
import Combine

// MARK: - BaseViewController SuperClass of ViewControllers In App
class BaseViewController<T: ViewModelType>: UIViewController {
    typealias ViewModelType = T

    var viewModel: T!

    var bag = Set<AnyCancellable>()

    init(viewModel: T) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
