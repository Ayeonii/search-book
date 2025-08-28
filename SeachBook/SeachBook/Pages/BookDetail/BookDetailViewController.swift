//
//  BookDetailViewController.swift
//  SeachBook
//
//  Created by 이아연 on 8/26/25.
//

import UIKit
import Combine
import SafariServices

final class BookDetailViewController: BaseViewController<BookDetailViewModel> {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleView = BookDetailInfoRowView(title: "제목")

    private let subtitleView = BookDetailInfoRowView(title: "부제목")

    private let descriptionView = BookDetailInfoRowView(title: "설명")

    private let authorsAndPublisherView = BookDetailInfoRowView(title: "저자/출판사")

    private let languageView = BookDetailInfoRowView(title: "언어")

    private let isbn10View = BookDetailInfoRowView(title: "isbn10")

    private let isbn13View = BookDetailInfoRowView(title: "isbn13")

    private let totalPagesView = BookDetailInfoRowView(title: "총 페이지수")

    private let publishedyearView = BookDetailInfoRowView(title: "출판연도")

    private let ratingsView = BookDetailInfoRowView(title: "평점")

    private let priceView = BookDetailInfoRowView(title: "가격")

    private let webURLView = BookDetailInfoRowView(title: "웹")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        bindViewModel(viewModel)
        viewModel.handleAction(.setupData)
    }

    private func setupLayout() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        scrollView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let imageContainer = UIView()
        imageContainer.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.2)
        ])

        [imageContainer, titleView, subtitleView, descriptionView, authorsAndPublisherView,
         languageView, isbn10View, isbn13View, totalPagesView, publishedyearView, ratingsView,
         priceView, webURLView].forEach {
            contentStackView.addArrangedSubview($0)
        }
    }

    private func bindViewModel(_ viewModel: BookDetailViewModel) {
        viewModel.statePublisher
            .compactMap { $0.book }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] book in
                self?.updateViews(model: book)
            })
            .store(in: &bag)

        viewModel.statePublisher
            .compactMap { $0.isLoading }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                guard let self else { return }
                if isLoading {
                    LoadingView.shared.addProgressView(to: view)
                } else {
                    LoadingView.shared.removeProgressView(from: view)
                }
            })
            .store(in: &bag)

        viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .showAlert(message):
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alertController, animated: true)
                }
            }
            .store(in: &bag)
    }

    private func updateViews(model: BookDetailModel) {
        imageView.setImage(url: model.imageURL)?
            .store(in: &bag)

        titleView.configure(type: .text(model.title))
        subtitleView.configure(type: .text(model.subtitle))
        descriptionView.configure(type: .text(model.desc))
        authorsAndPublisherView.configure(type: .text(model.authors + "/" + model.publisher))
        languageView.configure(type: .text(model.language))
        isbn10View.configure(type: .text(model.isbn10))
        isbn13View.configure(type: .text(model.isbn13))
        totalPagesView.configure(type: .text(model.totalPages))
        publishedyearView.configure(type: .text(model.publishedyear))
        ratingsView.configure(type: .text(model.rating))
        priceView.configure(type: .text(model.price))
        webURLView.configure(type: .link(model.webURL), delegate: self)

        if let pdfDict = model.pdf {
            for pdf in pdfDict {
                let pdfView = BookDetailInfoRowView(title: pdf.key)
                pdfView.configure(type: .link(pdf.value), delegate: self)
                contentStackView.addArrangedSubview(pdfView)
            }
        }
    }
}

extension BookDetailViewController: BookDetailInfoRowViewDelegate {
    func didTapLink(_ view: BookDetailInfoRowView, link: String) {
        let url: URL?

        if #available(iOS 17.0, *) {
            url = URL(string: link, encodingInvalidCharacters: false)

        } else {
            url = URL(string: link)
        }

        guard let url else { return }
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true)
    }
}
