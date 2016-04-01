//
//  SearchRepositoryController.swift
//  XLProjectName
//
//  Created by Diego Medina on 3/31/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import RxSwift
import RxCocoa

class SearchRepositoriesController: FormViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    private var emptyStateLabel: UILabel!
    let disposeBag = DisposeBag()
    
    lazy var viewModel: SimplePaginationViewModel<Repository>  = { [unowned self] in
        return SimplePaginationViewModel(paginationRequest: PaginationRequest<Repository, EmptyFilter>(route: Route.Repository.Search(), collectionPath: "items"))
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let table = tableView else { return }
        
        rx_sentMessage(#selector(RepositoriesController.viewWillAppear(_:)))
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        table.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading.skip(1)
            .drive(activityIndicatorView.rx_animating)
            .addDisposableTo(disposeBag)
        
        form +++ Section()
        viewModel.elements.asDriver()
            .driveNext { [weak self] repos in
                repos.forEach { repo in
                    guard let mySelf = self else { return }
                    mySelf.form.first! <<< LabelRow() { $0.title = repo.name }
                }
            }
            .addDisposableTo(disposeBag)
        
        searchBar.rx_text
            .doOnNext { [weak self] _ in self?.form.first!.removeAll() }
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)
        
        let refreshControl = UIRefreshControl()
        refreshControl.rx_valueChanged
            .filter { refreshControl.refreshing }
            .map { false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        table.addSubview(refreshControl)
        
        viewModel.firstPageLoading
            .filter { $0 == false && refreshControl.refreshing }
            .driveNext { _ in refreshControl.endRefreshing() }
            .addDisposableTo(disposeBag)
        
        viewModel.networkErrorTrigger
            .subscribeNext { _ in refreshControl.endRefreshing() }
            .addDisposableTo(disposeBag)
        
        setUpEmptyStateLabel()
        viewModel.emptyState
            .driveNext { [weak self] state in
                self?.emptyStateLabel.hidden = !state
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? ControllerConstants.NoTextMessage : ControllerConstants.NoRepositoriesMessage
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setUpEmptyStateLabel() {
        emptyStateLabel = UILabel()
        emptyStateLabel.text = ControllerConstants.NoTextMessage
        emptyStateLabel.textAlignment = .Center
        tableView?.backgroundView = emptyStateLabel
    }

}

extension SearchRepositoriesController {
    
    private struct ControllerConstants {
        static let NoTextMessage = "Enter text to search repositories"
        static let NoRepositoriesMessage = "No repositories found"
    }
    
}