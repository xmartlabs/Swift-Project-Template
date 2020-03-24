//
//  SearchRepositoryController.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SearchRepositoriesController: XLTableViewController {
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = ControllerConstants.NoTextMessage
        emptyStateLabel.textAlignment = .center
        return emptyStateLabel
    }()
    
    lazy var viewModel: PaginationViewModel<PaginationRequest<Repository>>  = { [unowned self] in
        return PaginationViewModel<PaginationRequest<Repository>>(paginationRequest: PaginationRequest(route: Route.Repository.Search))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .onDrag
        
        tableView.rx.reachedBottom
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)
        
        viewModel.loading.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        
        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx.text.asDriver()) { elements, loading, searchText in
            return loading || searchText?.isEmpty ?? true ? [] : elements
        }
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text.asDriver()
            .map{ $0 ?? ""}
            .filter { !$0.isEmpty }
            .debounce(0.5)
            .drive(viewModel.queryTrigger)
            .disposed(by: disposeBag)
        
        let refreshControl = UIRefreshControl()
        refreshControl.rx.valueChanged
            .filter { refreshControl.isRefreshing }
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)
        tableView.addSubview(refreshControl)
        
        viewModel.firstPageLoading
            .filter { $0 == false && refreshControl.isRefreshing }
            .drive(onNext: { _ in refreshControl.endRefreshing() })
            .disposed(by: disposeBag)
        
        Driver.combineLatest(viewModel.emptyState, searchBar.rx.text.asDriver()) { $0 ||  $1?.isEmpty ?? true }
            .drive(onNext: { [weak self] state in
                self?.emptyStateLabel.isHidden = !state
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? ControllerConstants.NoTextMessage : ControllerConstants.NoRepositoriesMessage
            })
            .disposed(by: disposeBag)
    }
}

extension SearchRepositoriesController {
    
    fileprivate struct ControllerConstants {
        static let NoTextMessage = "Enter text to search repositories"
        static let NoRepositoriesMessage = "No repositories found"
    }
    
}
