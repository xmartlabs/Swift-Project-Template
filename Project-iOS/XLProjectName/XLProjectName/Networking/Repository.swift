//
//  NetworkRepository.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkRepository: NetworkRouteType {
    
    case GetInfo(owner: String, repo: String)

    var method: Alamofire.Method {
        switch self {
        case .GetInfo:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case let .GetInfo(owner, repo):
            return "repos/\(owner)/\(repo)"
        }
    }

}
