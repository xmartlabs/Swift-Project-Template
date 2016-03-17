//
//  ExampleRepository.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import Curry
import SwiftDate


class Repository {
    
    let id: Int
    let name: String
    let description: String?
    let company: String?
    let language: String?
    let openIssues: Int?
    let stargazersCount: Int?
    let forksCount: Int?
    let url: NSURL
    let createdAt: NSDate
    
    
    init(id: Int, name: String, description: String?, company: String?, language: String?, openIssues: Int?, stargazersCount: Int?, forksCount: Int?, url: NSURL, createdAt: NSDate) {
        self.id = id
        self.name = name
        self.description = description
        self.company = company
        self.language = language
        self.openIssues = openIssues
        self.stargazersCount = stargazersCount
        self.forksCount = forksCount
        self.url = url
        self.createdAt = createdAt
    }
}

extension Repository: Decodable {

    static func decode(j: JSON) -> Decoded<Repository> {
        let a = curry(Repository.init)
            <^> j <| "id"
            <*> j <| "name"
            <*> j <|? "description"
            <*> j <|? ["owner", "login"]
        return a
            <*> j <|? "language"
            <*> j <|? "open_issues_count"
            <*> j <|? "stargazers_count"
            <*> j <|? "forks_count"
            <*> (j <| "url" >>- { NSURL.decode($0) })
            <*> (j <| "created_at" >>- { NSDate.decode($0) })
    }
}
