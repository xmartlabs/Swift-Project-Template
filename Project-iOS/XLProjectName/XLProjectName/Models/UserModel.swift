//
//  ExampleObject.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2019 XLOrganizationName. All rights reserved.
//

import Foundation
import OperaSwift

final class User {
    
    var id: Int = Int.min
    var email: String?
    var company: String?
    var username: String = ""
    var avatarUrlString: String?
    
    let followers: [User] = []
    
    var avatarUrl: URL? {
        return URL(string: self.avatarUrlString ?? "")
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
