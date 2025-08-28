//
//  MainSearchViewController.swift
//  SeachBook
//
//  Created by 이아연 on 8/24/25.
//

import UIKit
import Combine

final class MainSearchViewController: BaseViewController<MainSearchViewModel> {

    private let searchController = UISearchController(searchResultsController: nil)

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MainSearchListCell.self, forCellReuseIdentifier: MainSearchListCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        setupLayout()
        setupSearchController()
        bindViewModel(viewModel)
    }

    private func setupLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색어 입력해주세요"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func bindViewModel(_ viewModel: MainSearchViewModel) {
        viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .showAlert(message):
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alertController, animated: true)

                case .reload:
                    self?.tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
                    self?.tableView.reloadData()

                case let .insertItems(indexes):
                    let indexPaths = indexes.map { IndexPath(row: $0, section: 0) }
                    self?.tableView.performBatchUpdates {
                        self?.tableView.insertRows(at: indexPaths, with: .none)
                    }
                }
            }
            .store(in: &bag)
    }
}

extension MainSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.sendAction(.search(searchBar.text ?? ""))
        searchBar.resignFirstResponder()
    }
}

extension MainSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentState.books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.currentState.books[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainSearchListCell.reuseIdentifier, for: indexPath) as? MainSearchListCell else {
            return UITableViewCell()
        }
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - 아이템 클릭 Action
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let translation = tableView.panGestureRecognizer.translation(in: tableView.superview)
        guard translation.y < 0, !viewModel.currentState.books.isEmpty else { return }

        if indexPath.item > max(viewModel.currentState.books.count - 3, 0) {
            viewModel.sendAction(.paging)
        }
    }
}

