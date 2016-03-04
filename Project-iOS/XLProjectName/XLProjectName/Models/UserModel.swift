//
//  ExampleObject.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
//

import Foundation
import Argo
import Curry



class User {
    
    let id: Int
    let email: String?
    let avatar: NSURL?
    let company: String?
    let username: String?
    var followers: [User]?
    
    init(id: Int, email: String?, avatar: NSURL?, company: String?, username: String?) {
        self.id = id
        self.email = email
        self.avatar = avatar
        self.company = company
        self.username = username
    }
}

extension User: Decodable {

    static func decode(j: JSON) -> Decoded<User> {
        let a = curry(User.init)
            <^> j <| "id"
            <*> j <|? "email"
            <*> (j <| "avatar_url" >>- { NSURL.decode($0) })
        return a
            <*> j <|? "name" // Custom types that also conform to Decodable just work
            <*> j <|? "login" // Parse nested objects
            //<*> j <||? "followers" // parse arrays of objects
    }
}
