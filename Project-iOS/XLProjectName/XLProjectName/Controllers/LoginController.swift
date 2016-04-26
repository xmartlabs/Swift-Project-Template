//
//  MainViewController.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import UIKit
import RxSwift
import XLSwiftKit
import Eureka
import Opera

class LoginController: FormViewController {

    private struct RowTags {
        static let LogInUsername = "log in username"
        static let LogInPassword = "log in password"
        static let RepoOwner = "see repository owner"
        static let RepoName = "see repository name"
        static let SeeProfileUsername = "see profile username"
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSections()
    }

    private func setUpSections() {
        form +++ Section(header: "Advanced usage", footer: "Please enter your credentials for advanced usage")
                <<< NameRow() {
                    $0.title = "Username:"
                    $0.placeholder = "insert username here.."
                    $0.tag = RowTags.LogInUsername
                }
                <<< PasswordRow() {
                    $0.title = "Password:"
                    $0.placeholder = "insert password here.."
                    $0.tag = RowTags.LogInPassword
                }
                <<< ButtonRow() {
                    $0.title = "Log in"
                    }
                    .onCellSelection { [weak self] _,_ in
                        self?.loginTapped()
                    }
            +++ Section(header: "Repositories", footer: "Enter repository url")
                <<< NameRow() {
                    $0.title = "User:"
                    $0.placeholder = "Xmartlabs"
                    $0.tag = RowTags.RepoOwner
                }
                <<< NameRow() {
                    $0.title = "Repository:"
                    $0.placeholder = "Eureka"
                    $0.tag = RowTags.RepoName
                }
                <<< ButtonRow() {
                    $0.title = "See repo"
                    }
                    .onCellSelection { [weak self] _,_ in
                        self?.seeRepoTapped()
                    }
            +++ Section()
                <<< ButtonRow() {
                    $0.title = "Search Repositories"
                    $0.presentationMode = PresentationMode.SegueName(segueName: R.segue.loginController.pushToSearchRepositoriesController.identifier, completionCallback: nil)
                }
            
            
            
            +++ Section(header: "Github users", footer: "Enter a github username to see its repositories")
                <<< NameRow() {
                    $0.title = "Username:"
                    $0.placeholder = "Xmartlabs"
                    $0.tag = RowTags.SeeProfileUsername
                }
                <<< ButtonRow() {
                    $0.title = "See profile"
                }
                .onCellSelection { [weak self] _,_ in
                   self?.seeProfileTapped()
                }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let destinationVC = segue.destinationViewController as? UserController {
            destinationVC.user = sender as? User
        } else if let destinationVC = segue.destinationViewController as? RepositoryController {
            destinationVC.repository = sender as? Repository
        }
    }
    
    private func getTextFromRow(tag: String) -> String? {
        let textRow : NameRow = form.rowByTag(tag)!
        let textEntered = textRow.cell.textField.text
        return textEntered
    }
    
    private func getPasswordFromRow(tag: String) -> String? {
        let textRow : PasswordRow = form.rowByTag(tag)!
        let textEntered = textRow.cell.textField.text
        return textEntered
    }
    
    // MARK: - Actions
    
    func loginTapped() {
        let writtenUsername = getTextFromRow(RowTags.LogInUsername)
        let writtenPassword = getPasswordFromRow(RowTags.LogInPassword)
        guard let username = writtenUsername, let password = writtenPassword where !username.isEmpty && !password.isEmpty else {
            showError("Please enter the username and password")
            return
        }
        
        Route.User.Login(username: username, password: password).request
            .rx_anyObject()
            .doOnError() { [weak self] error in
                 self?.showError("Error", message: (error as? NetworkError).debugDescription ?? "Sorry user login does not work correctly")
            }
            .flatMap() { _ in
                return Route.User.GetInfo(username: username).request.rx_object()
            }
            .subscribeNext() { [weak self] (user: User) in
                self?.showError("Great", message: "You have been successfully logged in")
            }
            .addDisposableTo(disposeBag)
    }
    
    func seeRepoTapped() {
        let writtenOwner = getTextFromRow(RowTags.RepoOwner)
        let writtenRepo = getTextFromRow(RowTags.RepoName)
        guard let repo = writtenRepo, let owner = writtenOwner where !repo.isEmpty && !owner.isEmpty else {
            showError("Please enter the repository and organization name")
            return
        }
        
        Route.Repository.GetInfo(owner: owner, repo: repo).request
            .rx_object()
            .doOnError() { [weak self] error in
                self?.showError("Error", message: (error as NSError).localizedDescription)
            }
            .subscribeNext() { [weak self] (repository: Repository) in
                self?.performSegueWithIdentifier(R.segue.loginController.pushToRepoController, sender: repository)
            }
            .addDisposableTo(disposeBag)
    }
    
    func seeProfileTapped() {
        let writtenUsername = getTextFromRow(RowTags.SeeProfileUsername)
        guard let user = writtenUsername where !user.isEmpty else {
            showError("Please enter the username")
            return
        }
        
        Route.User.GetInfo(username: user).request
            .rx_object()
            .doOnError() { [weak self] _ in
                self?.showError("Error", message: "Sorry user login does not work correctly")
            }
            .subscribeNext() { [weak self] (user: User) in
                self?.performSegueWithIdentifier(R.segue.loginController.pushToUserController, sender: user)
            }
            .addDisposableTo(disposeBag)
    }
}
