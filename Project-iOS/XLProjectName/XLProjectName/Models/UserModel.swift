//
//  ExampleObject.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2019 XLOrganizationName. All rights reserved.
//

import Foundation
import RealmSwift
import OperaSwift

final class User: Object {
    
    @objc dynamic var id: Int = Int.min
    @objc dynamic var email: String?
    @objc dynamic var company: String?
    @objc dynamic var username: String = ""
    @objc dynamic var avatarUrlString: String?
    
    let followers = List<User>()
    
    var avatarUrl: URL? {
        return URL(string: self.avatarUrlString ?? "")
    }
    
    /**
     Return property names that should be ignored by Realm. Realm will not persist these properties.
     */
    override static func ignoredProperties() -> [String] {
        return []
    }

    convenience init(id: Int, email: String?, avatarUrlString: String?, company: String?, username: String) {
        self.init()
        self.id = id
        self.email = email
        self.avatarUrlString = avatarUrlString
        self.company = company
        self.username = username
    }
}

extension User: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case avatarUrlString = "avatar_url"
        case company = "name"
        case username = "login"
    }
}
