//
//  NetworkUser.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire

extension Route {

    enum User: RequestType, URLRequestSetup {

        case Login(username: String, password: String)
        case GetInfo(username: String)
        case Followers(username: String)
        case Repositories(username: String)
        
        var method: Alamofire.Method {
            switch self {
            case .Login:
                return .GET
            case .GetInfo, .Followers, .Repositories:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Login(_, _):
                return ""
            case .GetInfo(let user):
                return "users/\(user)"
            case .Followers(let user):
                return "users/\(user)/followers"
            case .Repositories(let user):
                return "users/\(user)/repos"
            }
        }
        
        // MARK: - CustomUrlRequestSetup
        
        func urlRequestSetup(request: NSMutableURLRequest) {
            if case let .Login(username, password) = self {
                let utf8 = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
                let base64 = utf8?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                
                guard let encodedString = base64 else {
                    return
                }
                
                request.setValue("Basic \(encodedString)", forHTTPHeaderField: "Authorization")
            }
        }
    }
}
