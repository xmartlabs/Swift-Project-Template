//
//  MainViewController.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 XLOrganizationName. All rights reserved.
//

import UIKit
import RxSwift
import Eureka

class LoginController: FormViewController {

    fileprivate struct RowTags {
        static let LogInUsername = "log in username"
        static let LogInPassword = "log in password"
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
        
            +++ Section()
                <<< ButtonRow() {
                    $0.title = "Search Repositories"
                    $0.presentationMode = PresentationMode.segueName(segueName: R.segue.loginController.pushToSearchRepositoriesController.identifier, onDismiss: nil)
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
        guard let username = writtenUsername, let password = writtenPassword, !username.isEmpty && !password.isEmpty else {
            showError("Please enter the username and password")
            return
        }

        LoadingIndicator.show()
        Route.User.login(username: username, password: password)
            .rx.any()
            .do(onError: { [weak self] (error: Error) in
                LoadingIndicator.hide()
                self?.showError("Error", message: (error as? OperaError)?.debugDescription ?? "Sorry user login does not work correctly")
            })
            .flatMap() { data -> Single<Any> in
                return Route.User.getInfo(username: username).rx.any()
            }
            .subscribe { (user) in
                LoadingIndicator.hide()
                self.showError("Great", message: "You have been successfully logged in")
            }
            .disposed(by: disposeBag)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
//        if let destinationVC = segue.destination as? UserController {
//            destinationVC.user = sender as? User
//        }
    }
}
