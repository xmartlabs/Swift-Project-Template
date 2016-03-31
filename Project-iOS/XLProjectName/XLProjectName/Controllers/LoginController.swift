//
//  LoginController.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import UIKit
import RxSwift
import XLSwiftKit

public class LoginController: UIViewController {
    
// MARK: - Outlets
    
    // TextFields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var organizationTextField: UITextField!
    @IBOutlet weak var repositoryTextField: UITextField!
    @IBOutlet weak var userToSeeTextField: UITextField!
    // Butttons
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var seeRepoButton: UIButton!
    @IBOutlet weak var seeProfileButton: UIButton!
    
    
    let disposeBag = DisposeBag()
    
// MARK: - Life cycle & iOS Framework invocations
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.secureTextEntry = true
        logInButton.addTarget(self, action: #selector(LoginController.loginTapped(_:)), forControlEvents: .TouchUpInside)
        seeRepoButton.addTarget(self, action: #selector(LoginController.seeRepoTapped(_:)), forControlEvents: .TouchUpInside)
        seeProfileButton.addTarget(self, action: #selector(LoginController.seeProfileTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let destinationVC = segue.destinationViewController as? UserController {
            destinationVC.user = sender as? User
        } else if let destinationVC = segue.destinationViewController as? RepositoryController {
            destinationVC.repository = sender as? Repository
        }
    }
    
// MARK: - Actions
    
    func loginTapped(sender: UIButton) {
        guard let username = usernameTextField.text, let password = passwordTextField.text where !username.isEmpty && !password.isEmpty else {
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
    
    func seeRepoTapped(sender: UIButton) {
        //validate
        guard let repo = repositoryTextField.text, let owner = organizationTextField.text where !repo.isEmpty && !owner.isEmpty else {
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
    
    func seeProfileTapped(sender: AnyObject) {
        guard let user = userToSeeTextField.text where !user.isEmpty else {
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
