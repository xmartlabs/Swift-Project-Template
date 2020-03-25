//
//  RepositoryModel.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import SwiftDate


final class Repository {
    
    var id: Int = Int.min
    var name: String = ""
    var desc: String?
    var company: String?
    var language: String?
    var openIssues: Int = .min
    var stargazersCount: Int = .min
    var forksCount: Int = .min
    var urlString: String = ""
    var createdAt: Date = Date()
    
    // do not save this properties, notice that it is returned by ignoredProperties method
    var tempId: String = ""
    
    convenience public init(from decoder: Decoder) throws {
        self.init()
        enum CodingKeys: String, CodingKey {
            case id // primary key
            case name
            case desc = "description"
            case language
            case openIssues = "open_issues_count"
            case stargazersCount = "stargazers_count"
            case forksCount = "forks_count"
            case urlString = "url"
            case createdAt = "created_at"
            case owner
        }
        
        enum OwnerKeys: String, CodingKey {
            case company = "login"
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(.id)
        name = try container.decode(.name)
        desc = try container.decodeIfPresent(.desc)
        language = try container.decodeIfPresent(.language)
        openIssues = try container.decode(.openIssues)
        stargazersCount = try container.decode(.stargazersCount)
        forksCount = try container.decode(.forksCount)
        urlString = try container.decode(.urlString)
        createdAt = try container.decode(.createdAt)
        let nestedContainer = try container.nestedContainer(keyedBy: OwnerKeys.self, forKey: .owner)
        company = try nestedContainer.decodeIfPresent(.company)
    }
    
    // computed properties
    var url: NSURL {
        return NSURL(string: self.urlString)!
    }
}

extension Repository: Decodable {}

