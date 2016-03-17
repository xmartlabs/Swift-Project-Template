//
//  RepositoryController.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//


import UIKit

public class RepositoryController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var forkLabel: UILabel!
    @IBOutlet weak var forkImage: UIImageView!
    @IBOutlet weak var issueLabel: UILabel!
    @IBOutlet weak var issueImage: UIImageView!
    @IBOutlet weak var bottomLabel: UILabel!
    var repository: Repository!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = repository.name
        descriptionLabel.text = repository.description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .Center
        starImage.setImageWithURL("https://assets-cdn.github.com/images/icons/emoji/unicode/2b50.png?v5")
        forkImage.setImageWithURL("https://assets-cdn.github.com/images/icons/emoji/unicode/1f374.png?v5")
        issueImage.setImageWithURL("https://assets-cdn.github.com/images/icons/emoji/unicode/1f41b.png?v5")
        starLabel.text = String(repository.stargazersCount ?? 0)
        issueLabel.text = String(repository.openIssues ?? 0)
        forkLabel.text = String(repository.forksCount ?? 0)
        bottomLabel.text = "written in \(repository.language ?? "an unknown language"), by \(repository.company ?? "an unknown company")"
        
    }
    
    
}
