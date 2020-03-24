//
//  NetworkUser.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire

final class Route {}

extension Route {
    struct User {
        
        struct Login: RouteType, CustomUrlRequestSetup  {
            let username: String
            let password: String
            
            let method = Alamofire.HTTPMethod.get
            let path = ""
            
            // MARK: - CustomUrlRequestSetup
            func urlRequestSetup(_ request: inout URLRequest) {
                let utf8 = "\(username):\(password)".data(using: String.Encoding.utf8)
                let base64 = utf8?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                guard let encodedString = base64 else {
                    return
                }
                
                request.setValue("Basic \(encodedString)", forHTTPHeaderField: "Authorization")
            }
        }
        
        struct GetInfo: RouteType  {
            let username: String
            
            let method = Alamofire.HTTPMethod.get
            var path: String { return  "users/\(username)" }
        }
        
        struct Followers: RouteType {
            let username: String
            
            let method = Alamofire.HTTPMethod.get
            var path: String { return  "users/\(username)/followers" }
        }
        
        struct Repositories: RouteType {
            let username: String
            
            let method = Alamofire.HTTPMethod.get
            var path: String { return  "users/\(username)/repos" }
        }
    }
}
