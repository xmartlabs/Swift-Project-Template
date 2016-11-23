//
//  SearchRepositoriesController.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Opera

class SearchRepositoriesController: XLTableViewController {
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = ControllerConstants.NoTextMessage
        emptyStateLabel.textAlignment = .center
        return emptyStateLabel
    }()
    
    lazy var viewModel: PaginationViewModel<PaginationRequest<Repository>>  = { [unowned self] in
        return PaginationViewModel<PaginationRequest<Repository>>(paginationRequest: PaginationRequest(route: Route.Repository.Search(), collectionKeyPath: "items"))
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .onDrag
        
        rx.sentMessage(#selector(RepositoriesController.viewWillAppear(_:)))
            .skip(1)
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading
            .drive(activityIndicatorView.rx.isAnimating)
            .addDisposableTo(disposeBag)

        
        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx.text.orEmpty.asDriver()) {
            elements, loading, searchText in
                return loading || searchText.isEmpty ? [] : elements
            }
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)
        
        searchBar.rx.text.orEmpty
            .skip(1)
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)
        
        let refreshControl = UIRefreshControl()
        refreshControl.rx_valueChanged
            .filter { refreshControl.isRefreshing }
            .map { true }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        tableView.addSubview(refreshControl)
        
        viewModel.firstPageLoading
            .filter { $0 == false && refreshControl.isRefreshing }
            .drive(onNext: { _ in refreshControl.endRefreshing() })
            .addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.emptyState, searchBar.rx.text.asDriver()) {
                $0 ||  $1?.isEmpty ?? true
            }
            .drive(onNext: { [weak self] state in
                self?.emptyStateLabel.isHidden = !state
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? ControllerConstants.NoTextMessage : ControllerConstants.NoRepositoriesMessage
            })
            .addDisposableTo(disposeBag)
    }
}

extension SearchRepositoriesController {
    
    fileprivate struct ControllerConstants {
        static let NoTextMessage = "Enter text to search repositories"
        static let NoRepositoriesMessage = "No repositories found"
    }
    
}
