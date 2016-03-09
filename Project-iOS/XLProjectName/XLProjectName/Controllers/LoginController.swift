//
//  LoginController.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
//

import UIKit
import RxSwift

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
        logInButton.addTarget(self, action: "loginTapped:", forControlEvents: .TouchUpInside)
        seeRepoButton.addTarget(self, action: "seeRepoTapped:", forControlEvents: .TouchUpInside)
        seeProfileButton.addTarget(self, action: "seeProfileTapped:", forControlEvents: .TouchUpInside)
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
            showError("Please enter the username and password", message: nil)
            return
        }

        NetworkManager.userService().login(username, pass: password)
            .observeOn(MainScheduler.instance)
            .doOnError() { [weak self] _ in
                self?.showError("Error", message: "Sorry user login does not work correctly")
            }
            .subscribeNext() { [weak self] user in
                self?.showError("Great", message: "You have been successfully logged in")
            }
            .addDisposableTo(disposeBag)
    }
    
    func seeRepoTapped(sender: UIButton) {
        //validate
        guard let repo = repositoryTextField.text, let owner = organizationTextField.text where !repo.isEmpty && !owner.isEmpty else {
            showError("Please enter the repository and organization name", message: nil)
            return
        }

        NetworkManager.repositoryService().getRepository(owner, repositoryId: repo)
            .observeOn(MainScheduler.instance)
            .doOnError() { [weak self] error in
                self?.showError("Error", message: (error as NSError).localizedDescription)
            }
            .subscribeNext() { [weak self] repository in
                self?.performSegueWithIdentifier(R.segue.loginController.pushToRepoController, sender: repository)
            }
            .addDisposableTo(disposeBag)
    }
    
    func seeProfileTapped(sender: AnyObject) {
        guard let user = userToSeeTextField.text where !user.isEmpty else {
            showError("Please enter the username", message: nil)
            return
        }

        NetworkManager.userService().getInfo(user)
            .observeOn(MainScheduler.instance)
            .doOnError() { [weak self] _ in
                self?.showError("Error", message: "Sorry user login does not work correctly")
            }
            .subscribeNext() { [weak self] user in
                self?.performSegueWithIdentifier(R.segue.loginController.pushToUserController, sender: user)
            }
            .addDisposableTo(disposeBag)
    }
        
// MARK: - Helpers
    
    func showError(title: String, message: String?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alertVC, animated: true, completion: nil)
    }

}
