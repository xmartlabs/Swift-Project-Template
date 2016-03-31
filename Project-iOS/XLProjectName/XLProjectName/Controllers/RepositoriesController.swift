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

class RepositoriesController: XLTableViewController {
    
    var user: User!
    
    lazy var viewModel: PaginationViewModel<Repository>  = { [unowned self] in
        return PaginationViewModel(route: Route.User.Repositories(username: self.user.username))
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx_sentMessage(#selector(RepositoriesController.viewWillAppear(_:)))
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading.asDriver(onErrorJustReturn: false)
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.rx_valueChanged
            .filter { refreshControl.refreshing }
            .map { false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        tableView.addSubview(refreshControl)
        viewModel.firstPageLoading.filter { $0 == false && refreshControl.refreshing }
            .subscribeNext { _ in refreshControl.endRefreshing() }
            .addDisposableTo(disposeBag)
        
        viewModel.emptyState.filter { $0 }
            .subscribeNext { [weak self] _ in
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
