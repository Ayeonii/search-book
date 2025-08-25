//
//  MainSearchListCell.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import UIKit
import Combine

final class MainSearchListCell: UITableViewCell {

    static let reuseIdentifier = "MainSearchListCell"

    private var bag = Set<AnyCancellable>()

    private let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .secondarySystemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        bag.removeAll()
        thumbnailView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        priceLabel.text = nil
    }

    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, priceLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(thumbnailView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            thumbnailView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            thumbnailView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailView.heightAnchor.constraint(equalToConstant: 80),

            textStack.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with item: SearchBookModel) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        priceLabel.text = item.price
        thumbnailView.setImage(url: item.image, size: CGSize(width: 80, height: 80))?
            .store(in: &bag)
    }
}
