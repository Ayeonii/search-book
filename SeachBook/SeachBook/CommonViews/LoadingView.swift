//
//  LoadingView.swift
//  SeachBook
//
//  Created by 이아연 on 8/28/25.
//

import UIKit

final class LoadingView: NSObject {

    static let shared: LoadingView = LoadingView()

    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        indicator.color = .gray
        return indicator
    }()

    private override init() {}

    func addProgressView(to superview: UIView) {
        superview.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])

        indicator.startAnimating()
    }

    func removeProgressView(from superview: UIView) {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
}
