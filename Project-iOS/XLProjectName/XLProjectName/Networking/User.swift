//
//  NetworkUser.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

enum NetworkUser: NetworkRouteType, CustomUrlRequestSetup {

    case Login(username: String, password: String)
    case GetInfo(username: String)
    case Followers(username: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Login:
            return .GET
        case .GetInfo, .Followers:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case  .Login(_, _):
            return ""
        case .GetInfo(let user):
            return "users/\(user)"
        case .Followers(let user):
            return "users/\(user)/followers"
        }
    }
    
    // MARK: - CustomUrlRequestSetup
    
    func customUrlRequestSetup(request: NSMutableURLRequest) {
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

class UserService {

    func login(username: String, pass: String) -> Observable<User> {
        return NetworkManager.request(NetworkUser.Login(username: username, password: pass))
            .validate()
            .rx_JSON()
            .doOnError(NetworkManager.generalErrorHandler)
            .flatMap() { _ in
                return self.getInfo(username)
            }
    }
    
    func getInfo(username: String) -> Observable<User> {
        return NetworkManager.request(NetworkUser.GetInfo(username: username))
            .validate()
            .rx_object()
            .doOnError(NetworkManager.generalErrorHandler)
    }

    func getFollowers(username: String) -> Observable<[User]> {
        return NetworkManager.request(NetworkUser.Followers(username: username))
            .validate()
            .rx_objectCollection()
            .doOnError(NetworkManager.generalErrorHandler)
    }

}

extension NetworkManager {
    
    static func userService() -> UserService {
        return UserService()
    }
    
}
