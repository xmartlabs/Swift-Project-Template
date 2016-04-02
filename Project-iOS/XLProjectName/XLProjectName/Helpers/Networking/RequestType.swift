//
//  RequestType.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import Argo

protocol RequestType: URLRequestConvertible {
    var method: Alamofire.Method { get }
    var path: String { get }
    var parameters: [String: AnyObject]? { get }
    var encoding: Alamofire.ParameterEncoding { get }
}

protocol URLRequestSetup {
    func urlRequestSetup(urlRequest: NSMutableURLRequest)
}

protocol URLRequestParametersSetup {
    func urlRequestParametersSetup(urlRequest: NSMutableURLRequest, parameters: [String: AnyObject]?) -> [String: AnyObject]?
}

extension RequestType {
    
    var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: Constants.Network.baseUrl.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        let params = (self as? URLRequestParametersSetup)?.urlRequestParametersSetup(mutableURLRequest, parameters: parameters) ?? parameters
        let urlRequest = encoding.encode(mutableURLRequest, parameters: params).0
        (self as? URLRequestSetup)?.urlRequestSetup(mutableURLRequest)
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
        
    var request: Alamofire.Request {
        return NetworkManager.request(URLRequest).validate()
    }
}
