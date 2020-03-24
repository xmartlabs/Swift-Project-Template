//
//  RequestAdapter.swift
//  XLProjectName
//
//  Created by Martin Barreto on 3/24/20.
//  Copyright © 2020 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Alamofire

class XLProjectNameRequestAdapter: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(Constants.Network.BASE_URL.absoluteString), let token = SessionController.sharedInstance.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: Constants.Network.AuthTokenName)
        }
        completion(Result.success(urlRequest))
    }
}

