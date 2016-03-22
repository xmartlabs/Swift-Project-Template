//
//  NetworkRepository.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkRepository: RouteType {
    
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
