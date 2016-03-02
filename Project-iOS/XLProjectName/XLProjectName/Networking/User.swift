//
//  NetworkUser.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
//

import Foundation
import Alamofire
//import AlamofireObjectMapper

enum NetworkUser: NetworkRouteType, CustomUrlRequestSetup {

    case Login(username: String, password: String)
    case GetInfo(username: String)
    case Followers(username: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Login:
            return .POST
        case .GetInfo, .Followers:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case  let .Login( username, _):
            return "users/\(username)"
        case .GetInfo(let user):
            return "users/\(user)"
        case .Followers(let user):
            return "users/\(user)/followers"
        }
    }
    
//    var parameters: [String: AnyObject]? {
//        return nil
//    }
    
    //MARK: CustomUrlRequestSetup
    
    func customUrlRequestSetup(request: NSMutableURLRequest) {
        if case let .Login(username, password) = self {
            let utf8 = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
            let base64 = utf8?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            guard let encodedString = base64 else { return }
            request.setValue("Basic \(encodedString)", forHTTPHeaderField: "Authorization")
        }
        
    }
}

extension NetworkManager {
    static func login(username: String, pass: String, completionCallback: (User?, NSError?) -> Void) {
        NetworkManager.request(NetworkUser.Login(username: username, password: pass))
            .validate()
//            .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
//                print(response.result.value)
//                print(response.request?.allHTTPHeaderFields)
//                print(response.response)
//            })
            .responseObject { (response: Response<User, NSError>) in
                NetworkManager.handleResponse(response,
                    onSuccess: { user in
                        //todo: Save user to DB here
                        completionCallback(user, nil)
                    }, onFailure: { (error, urlResponse, jsonData) -> Void in
                        completionCallback(nil, error)
                    })
                }
            
    }
    
    static func getFollowers(username: String, completionCallback: ([User]?, NSError?) -> Void) {
        NetworkManager.request(NetworkUser.Followers(username: username))
            .validate()
            .responseCollection { response in
                NetworkManager.handleResponse(response,
                    onSuccess: { users in
                        //todo: Save users to DB here
                        completionCallback(users,  nil)
                    })
            }
    }
}
