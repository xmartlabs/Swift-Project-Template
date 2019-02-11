//
//  RepositoryModel.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import SwiftDate
import RealmSwift
import OperaSwift


final class Repository: Object {
    
    @objc dynamic var id: Int = Int.min
    @objc dynamic var name: String = ""
    @objc dynamic var desc: String?
    @objc dynamic var company: String?
    @objc dynamic var language: String?
    @objc dynamic var openIssues: Int = .min
    @objc dynamic var stargazersCount: Int = .min
    @objc dynamic var forksCount: Int = .min
    @objc dynamic var urlString: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    // do not save this properties, notice that it is returned by ignoredProperties method
    @objc dynamic var tempId: String = ""
    
    convenience public init(from decoder: Decoder) throws {
        self.init()
        enum CodingKeys: String, CodingKey {
            case id
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
    
    /**
     Set the model primary key.
     Declaring a primary key allows objects to be looked up and updated efficiently and enforces uniqueness for each value.
     */
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /**
     Realm supports indexing for strings, integers, booleans and NSDate properties.
     Indexing a property will greatly speed up queries where the property is compared
     for equality (i.e. the = and IN operators), at the cost of slower insertions.
     */
    override static func indexedProperties() -> [String] {
        return ["name", "language"]
    }
    
    
    /**
     Return property names that should be ignored by Realm. Realm will not persist these properties.
     */
    override static func ignoredProperties() -> [String] {
        return ["tempId"]
    }
}

extension Repository: Decodable {
    
    
}


//static func decode(_ json: Any) throws -> Repository {
//    return try Repository(   id: json => "id",
//                             name: json => "name",
//                             desc: json =>? "description",
//                             company: json =>? ["owner", "login"],
//                             language: json =>? "language",
//                             openIssues: json => "open_issues_count",
//                             stargazersCount: json => "stargazers_count",
//                             forksCount: json => "forks_count",
//                             urlString: json => "name",
//                             createdAt: json => "created_at")
//}

extension Repository: OperaDecodable {}

