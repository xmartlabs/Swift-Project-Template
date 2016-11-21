//
//  IssuesController.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import UIKit

import AlamofireImage
import Alamofire
import RxSwift
import RealmSwift

public class UserController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var followersTable: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var repositoriesButton: UIButton!
    
    var user: User!
    
    private let disposeBag = DisposeBag()
    private var followerImages = [String: UIImage]()
    private let cellIdentifier = "cell"
    private let rowHeight: CGFloat = 40.0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        repositoriesButton.addTarget(self, action: #selector(UserController.seeRepositories(buton:)), for: .touchUpInside)
        
        followersTable.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
//        guard let username = user.username else {
//            return
//        }
        
        Route.User.followers(username: user.username)
            .rx_collection()
            .do(onNext: { [weak self] (followers: [User]) in
                self?.user.followers.removeAll()
                self?.user.followers.append(objectsIn: followers)
                self?.followersTable.reloadData()
                self?.adjustTableHeight()
            })
            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = user.username
        nameLabel.text = user.company ?? "Unknown"
        emailLabel.text = user.email ?? "Not specified"
        companyLabel.text = user.company ?? "None"
        followersTable.delegate = self
        followersTable.dataSource = self
        if let avatar = user?.avatarUrl {
            avatarImageView.af_setImage(withURL: avatar)
        }
        for label in [nameLabel, emailLabel, companyLabel] {
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.7
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user?.followers.count ?? 0
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        guard let cell = _cell else { return UITableViewCell() }
        
        guard let follower = user?.followers[indexPath.row] else { return cell }
        
        cell.textLabel?.text = follower.username
        
        if let image = followerImages[follower.username] {
            cell.imageView?.image = image
        } else if let avatar = follower.avatarUrl {

//            NetworkManager.singleton.manager.request(.get, avatar)
//                .validate()
//                .rx_image()
//                .observeOn(MainScheduler.instance)
//                .subscribeNext() { [weak self] image in
//                    self?.followerImages[follower.username] = image
//                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                }
//                .addDisposableTo(disposeBag)
        }
        return cell
    }
    
    // Mark: Actions
    func seeRepositories(buton: UIButton) {
        self.performSegue(withIdentifier: R.segue.userController.showUserRepositories, sender: user)
    }
    
    // Mark: Helpers
    
    func adjustTableHeight() {
        guard let followersCount = user?.followers.count else { return }
        tableHeightConstraint.constant = min(view.frame.height - followersTable.frame.origin.y, CGFloat(followersCount) * rowHeight)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? RepositoriesController)?.user = sender as? User
    }
}
