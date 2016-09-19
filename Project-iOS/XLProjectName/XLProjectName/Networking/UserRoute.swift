//
//  NetworkUser.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire
import Opera

extension Route {

    enum User: RouteType, URLRequestSetup {

        case login(username: String, password: String)
        case getInfo(username: String)
        case followers(username: String)
        case repositories(username: String)
        
        var method: Alamofire.Method {
            switch self {
            case .login:
                return .GET
            case .getInfo, .followers, .repositories:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .login(_, _):
                return ""
            case .getInfo(let user):
                return "users/\(user)"
            case .followers(let user):
                return "users/\(user)/followers"
            case .repositories(let user):
                return "users/\(user)/repos"
            }
        }
        
        // MARK: - CustomUrlRequestSetup
        
        func urlRequestSetup(_ request: NSMutableURLRequest) {
            if case let .login(username, password) = self {
                let utf8 = "\(username):\(password)".data(using: String.Encoding.utf8)
                let base64 = utf8?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                guard let encodedString = base64 else {
                    return
                }
                
                request.setValue("Basic \(encodedString)", forHTTPHeaderField: "Authorization")
            }
        }
    }
}
