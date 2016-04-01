//
//  NetworkRepository.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire

extension Route {
    
    enum Repository: RequestType {
        
        case GetInfo(owner: String, repo: String)
        case Search()

        var method: Alamofire.Method {
            switch self {
            case .GetInfo, .Search:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case let .GetInfo(owner, repo):
                return "repos/\(owner)/\(repo)"
            case .Search:
                return "search/repositories"
            }
        }

    }
}
