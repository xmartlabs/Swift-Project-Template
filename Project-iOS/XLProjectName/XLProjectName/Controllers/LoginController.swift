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

    fileprivate struct RowTags {
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

    fileprivate func setUpSections() {
        form +++ Section(header: "Advanced usage", footer: "Please enter your credentials for advanced usage")
                <<< NameRow(RowTags.LogInUsername) {
                    $0.title = "Username:"
                    $0.placeholder = "insert username here.."
                }
                <<< PasswordRow(RowTags.LogInPassword) {
                    $0.title = "Password:"
                    $0.placeholder = "insert password here.."
                }
                <<< ButtonRow() {
                    $0.title = "Log in"
                    }
                    .onCellSelection { [weak self] _, _ in
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
                    $0.presentationMode = PresentationMode.segueName(segueName: R.segue.loginController.pushToSearchRepositoriesController.identifier, onDismiss: nil)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destinationVC = segue.destination as? UserController {
            destinationVC.user = sender as? User
        } else if let destinationVC = segue.destination as? RepositoryController {
            destinationVC.repository = sender as? Repository
        }
    }
    
    fileprivate func getTextFromRow(_ tag: String) -> String? {
        let textRow: NameRow = form.rowBy(tag: tag)!
        let textEntered = textRow.cell.textField.text
        return textEntered
    }
    
    fileprivate func getPasswordFromRow(_ tag: String) -> String? {
        let textRow: PasswordRow = form.rowBy(tag: tag)!
        let textEntered = textRow.cell.textField.text
        return textEntered
    }
    
    // MARK: - Actions
    
    func loginTapped() {
        let writtenUsername = getTextFromRow(RowTags.LogInUsername)
        let writtenPassword = getPasswordFromRow(RowTags.LogInPassword)
        guard let username = writtenUsername, let password = writtenPassword , !username.isEmpty && !password.isEmpty else {
            showError("Please enter the username and password")
            return
        }

        LoadingIndicator.show()
        Route.User.login(username: username, password: password)
            .rx_anyObject()
            .do(onError: { [weak self] (error: Error) in
                LoadingIndicator.hide()
                self?.showError("Error", message: error.localizedDescription)
            })
            .flatMap() { _ in
                return Route.User.getInfo(username: username).rx_object()
            }
            .do(onNext: { [weak self] (user: User) in
                LoadingIndicator.hide()
                self?.showError("Great", message: "You have been successfully logged in")
            })
            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
    func seeRepoTapped() {
        let writtenOwner = getTextFromRow(RowTags.RepoOwner)
        let writtenRepo = getTextFromRow(RowTags.RepoName)
        guard let repo = writtenRepo, let owner = writtenOwner , !repo.isEmpty && !owner.isEmpty else {
            showError("Please enter the repository and organization name")
            return
        }
        
        Route.Repository.GetInfo(owner: owner, repo: repo)
            .rx_object()
            .do(onNext: { [weak self] (repository: Repository) in
                self?.performSegue(withIdentifier: R.segue.loginController.pushToRepoController, sender: repository)
            },onError:{ [weak self] error in
                self?.showError("Error", message: (error as NSError).localizedDescription)
            })

            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
    func seeProfileTapped() {
        let writtenUsername = getTextFromRow(RowTags.SeeProfileUsername)
        guard let user = writtenUsername, !user.isEmpty else {
            showError("Please enter the username")
            return
        }
        
        Route.User.getInfo(username: user)
            .rx_object()
            .do(onNext: { [weak self] (user: User) in
                self?.performSegue(withIdentifier: R.segue.loginController.pushToUserController, sender: user)
            },
            onError: { [weak self] _ in
                self?.showError("Error", message: "Sorry user login does not work correctly")
            })
            .subscribe()
            .addDisposableTo(disposeBag)
    }
}
