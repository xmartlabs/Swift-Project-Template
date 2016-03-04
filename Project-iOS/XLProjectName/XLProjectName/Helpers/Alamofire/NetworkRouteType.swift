//
//  NetworkRouteType.swift
//  XLProjectName
//
//  Created by Martin Barreto on 3/1/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkRouteType: URLRequestConvertible {
    var method: Alamofire.Method { get }
    var path: String { get }
    var parameters: [String: AnyObject]? { get }
    var encoding: Alamofire.ParameterEncoding { get }
}

protocol CustomUrlRequestSetup {
    func customUrlRequestSetup(urlRequest: NSMutableURLRequest)
}

extension NetworkRouteType {
    
    var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: Constants.Network.baseUrl.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        //        mutableURLRequest.setValue(<#T##value: AnyObject?##AnyObject?#>, forKey: <#T##String#>)
        
        
        //        public static func addAuthHeader(request: NSMutableURLRequest, username: String, password: String) {
        //            let utf8 = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
        //            let base64 = utf8?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        //            guard let encodedString = base64 else { return }
        //            request.setValue("Basic \(encodedString)", forHTTPHeaderField: "Authorization")
        //        }
        let urlRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        (self as? CustomUrlRequestSetup)?.customUrlRequestSetup(urlRequest)
        return urlRequest
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch method {
        case .POST, .PUT, .PATCH:
            return .JSON
        default:
            return .URL
        }
    }
    
    var parameters: [String: AnyObject]? {
        return nil
    }
}
