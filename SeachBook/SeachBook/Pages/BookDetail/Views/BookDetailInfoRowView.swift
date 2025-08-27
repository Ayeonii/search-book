//
//  BookDetailInfoRowView.swift
//  SeachBook
//
//  Created by 이아연 on 8/27/25.
//

import UIKit

protocol BookDetailInfoRowViewDelegate: AnyObject {
    func didTapLink(_ view: BookDetailInfoRowView, link: String)
}

final class BookDetailInfoRowView: UIView {

    enum RowType {
        case text(String)
        case link(String)
    }

    private var type: RowType?

    private let title: String

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private weak var delegate: BookDetailInfoRowViewDelegate?

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(type: RowType, delegate: BookDetailInfoRowViewDelegate? = nil) {
        self.type = type
        self.delegate = delegate

        switch type {
        case let .text(text):
            descLabel.text = text
            descLabel.isUserInteractionEnabled = false

        case let .link(text):
            let attr = NSMutableAttributedString(string: text)
            attr.addAttributes([
                .foregroundColor: UIColor.systemBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: NSRange(location: 0, length: text.count))

            descLabel.attributedText = attr
            descLabel.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapLabel))
            descLabel.addGestureRecognizer(gesture)
        }
    }
}

extension BookDetailInfoRowView {
    private func setupUI() {
        titleLabel.text = title + ": "
        addSubview(titleLabel)
        addSubview(descLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),

            descLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            descLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 8),
            descLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc private func didTapLabel() {
        if case let .link(text) = type {
            delegate?.didTapLink(self, link: text)
        }
    }
}
