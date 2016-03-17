//
//  IssuesController.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import UIKit

import AlamofireImage
import RxSwift

let cellIdentifier = "cell"

public class UserController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var followersTable: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    var user: User!
    let rowHeight: CGFloat = 40.0
    
    var followerImages = [String: UIImage]()

    let disposeBag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        followersTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        guard let username = user.username else {
            return
        }
        
        NetworkUser.Followers(username: username)
            .observe()
            .subscribeNext() { [weak self] (followers: [User]) in
                self?.user.followers = followers
                self?.followersTable.reloadData()
                self?.adjustTableHeight()
            }
            .addDisposableTo(disposeBag)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = user.username
        nameLabel.text = user.company ?? "Unknown"
        emailLabel.text = user.email ?? "Not specified"
        companyLabel.text = user.company ?? "None"
        followersTable.delegate = self
        followersTable.dataSource = self
        if let avatar = user?.avatar {
            avatarImageView.af_setImageWithURL(avatar)
        }
        for label in [nameLabel, emailLabel, companyLabel] {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
        }
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user?.followers?.count ?? 0
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        guard let cell = _cell else { return UITableViewCell() }
        
        guard let follower = user?.followers?[indexPath.row] where follower.username != nil else { return cell }
        
        cell.textLabel?.text = follower.username
        
        if let image = followerImages[follower.username!] {
            cell.imageView?.image = image
        } else if let avatar = follower.avatar {
            NetworkManager.request(.GET, avatar)
                .validate()
                .rx_image()
                .observeOn(MainScheduler.instance)
                .subscribeNext() { [weak self] image in
                    self?.followerImages[follower.username!] = image
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
                .addDisposableTo(disposeBag)
        }
        return cell
    }
    
    func adjustTableHeight() {
        guard let followersCount = user?.followers?.count else { return }
        tableHeightConstraint.constant = min(view.frame.height - followersTable.frame.origin.y, CGFloat(followersCount) * rowHeight)
    }
}
