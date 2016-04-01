//
//  RepositoriesController.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/21/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

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
    
    var user: User!
    
    lazy var filters: RepositoriesFilter = { [unowned self] in
        var filters = RepositoriesFilter()
        filters.sort = .Updated
        return filters
    }()
    
    lazy var viewModel: PaginationViewModel<Repository, RepositoriesFilter>  = { [unowned self] in
        return PaginationViewModel(route: Route.User.Repositories(username: self.user.username), filter: self.filters)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = self.searchBar
        let tableView = self.tableView
    
        searchBar.scopeButtonTitles = ["Created", "Updated", "Pushed", "FullName"]
        searchBar.selectedScopeButtonIndex = 1
        
        rx_sentMessage(#selector(RepositoriesController.viewWillAppear(_:)))
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
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
        
        tableView.rx_contentOffset.subscribeNext { _ in
            if searchBar.isFirstResponder() {
               searchBar.resignFirstResponder()
            }
        }
        .addDisposableTo(disposeBag)
        
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
            .driveNext { [weak self] _ in
                self?.showAlertViewForEmptyState()
            }
            .addDisposableTo(disposeBag)
    }
    
    @IBAction func clearData(sender: AnyObject) {
        Observable.just([]).bindTo(viewModel.elements).addDisposableTo(disposeBag)
    }
    
    private func showAlertViewForEmptyState() {
        let alert = UIAlertController(title: "Error", message: "No repositories found", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: UIAlertActionStyle.Default, handler: { [weak self] _ in
            self?.navigationController?.popViewControllerAnimated(true)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
