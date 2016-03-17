//
//  ExampleObject.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import Curry
import RealmSwift



class User: Object {
    
    dynamic var id: Int = Int.min
    dynamic var email: String?
    dynamic var company: String?
    dynamic var username: String?
    dynamic var avatarUrlString: String?
    
    var followers: [User]?
    
    var avatarUrl: NSURL? {
        return NSURL(string: self.avatarUrlString ?? "")
    }
    
    /**
     Return property names that should be ignored by Realm. Realm will not persist these properties.
     */
    override static func ignoredProperties() -> [String] {
        return ["followers"]
    }
    
    convenience init(id: Int, email: String?, avatarUrlString: String?, company: String?, username: String?) {
        self.init()
        self.id = id
        self.email = email
        self.avatarUrlString = avatarUrlString
        self.company = company
        self.username = username
    }
}

extension User: Decodable {

    static func decode(j: JSON) -> Decoded<User> {
        let a = curry(User.init)
            <^> j <| "id"
            <*> j <|? "email"
            <*> j <|? "avatar_url"  //>>- { NSURL.decode($0) })
        return a
            <*> j <|? "name" // Custom types that also conform to Decodable just work
            <*> j <|? "login" // Parse nested objects
            //<*> j <||? "followers" // parse arrays of objects
    }
}
