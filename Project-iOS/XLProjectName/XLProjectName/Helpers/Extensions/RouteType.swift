//
//  RouteType.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Opera
import Alamofire

extension RouteType {

    var baseURL: NSURL { return Constants.Network.baseUrl }
    var manager: ManagerType { return NetworkManager.singleton  }
    var retryCount: Int { return 0 }
}

extension URLRequestParametersSetup {
    public func urlRequestParametersSetup(urlRequest: NSMutableURLRequest, parameters: [String: AnyObject]?) -> [String: AnyObject]? {
        var params = parameters ?? [:]
        if let token = SessionController.sharedInstance.token {
            params[Constants.Network.AuthTokenName] = token
        }
        return params
    }
}

extension URLRequestSetup {

    func urlRequestSetup(urlRequest: NSMutableURLRequest) {
        // setup url
    }
}
