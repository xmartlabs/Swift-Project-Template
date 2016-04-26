//
//  RepositoriesController.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa
import Opera

struct RepositoriesFilter {

    enum RepositoryType: String {
        case Owner = "owner"
        case All = "all"
        case Member = "member"
    }

    enum RepositorySort: String {

        case Created = "created"
        case Updated = "updated"
        case Pushed = "pushed"
        case FullName = "full_name"

        static let values: [RepositorySort] = [.Created, .Updated, .Pushed, .FullName]
    }

    var type = RepositoryType.Owner
    var sort = RepositorySort.FullName

}

extension RepositoriesFilter : FilterType {

    var parameters: [String : AnyObject]? {
        return ["type": type.rawValue, "sort": sort.rawValue]
    }
}


class RepositoriesController: XLTableViewController {

    @IBOutlet weak var emptyStateView: UIView!

    var user: User!

    lazy var filters: RepositoriesFilter = { [unowned self] in
        var filters = RepositoriesFilter()
        filters.sort = .Updated
        return filters
    }()

    lazy var viewModel: PaginationViewModel<PaginationRequest<Repository>>  = { [unowned self] in
        return PaginationViewModel(paginationRequest: PaginationRequest(route: Route.User.Repositories(username: self.user.username), filter: self.filters))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyStateView.hidden = true

        let searchBar = self.searchBar
        let tableView = self.tableView

        searchBar.scopeButtonTitles = ["Created", "Updated", "Pushed", "FullName"]
        searchBar.selectedScopeButtonIndex = 1

//        rx_sentMessage(#selector(RepositoriesController.viewWillAppear(_:)))
//            .map { _ in false }
//            .bindTo(viewModel.refreshTrigger)
//            .addDisposableTo(disposeBag)
        
        
    
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

        viewModel.loading
            .drive(activityIndicatorView.rx_animating)
            .addDisposableTo(disposeBag)

        viewModel.elements.asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)

        searchBar.rx_text
            .skip(1)
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)

        searchBar.rx_selectedScopeButtonIndex
            .map { [weak self] index in
                var filters = self?.filters
                filters?.sort = RepositoriesFilter.RepositorySort.values[index]
                return filters ?? RepositoriesFilter()
            }
            .bindTo(viewModel.filterTrigger)
            .addDisposableTo(disposeBag)

//    
//        tableView.rx_contentOffset.subscribeNext { _ in
//            if searchBar.isFirstResponder() {
//               searchBar.resignFirstResponder()
//            }
//        }
//        .addDisposableTo(disposeBag)

        let refreshControl = UIRefreshControl()
        refreshControl.rx_valueChanged
            .filter { refreshControl.refreshing }
            .map { true }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        tableView.addSubview(refreshControl)

        viewModel.firstPageLoading
            .filter { $0 == false && refreshControl.refreshing }
            .driveNext { _ in refreshControl.endRefreshing() }
            .addDisposableTo(disposeBag)

        viewModel.emptyState
            .filter { $0 }
            .driveNext { [weak self] _ in self?.showEmptyStateView() }
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Observable.just(false).bindTo(viewModel.refreshTrigger).addDisposableTo(disposeBag)
    }

    @IBAction func clearData(sender: AnyObject) {
        Observable.just([]).bindTo(viewModel.elements).addDisposableTo(disposeBag)
    }

    private func showEmptyStateView() {
        emptyStateView.hidden = false
        tableView.backgroundView = emptyStateView
    }
}
