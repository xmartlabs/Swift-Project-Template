//
//  NetworkError.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/24/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import Alamofire

public enum NetworkError: ErrorType {
    
    case Networking(error: NSError, code: Int, request: NSURLRequest?, response: NSHTTPURLResponse?, json: AnyObject?)
    case Parsing(error: ErrorType, request: NSURLRequest?, response: NSHTTPURLResponse?, json: AnyObject?)
    
    static func networkingError(alamofireError: NSError, request: NSURLRequest?, response: NSHTTPURLResponse? = nil, json: AnyObject? = nil) -> NetworkError {
        return NetworkError.Networking(error: alamofireError, code: alamofireError.code, request: request, response: response, json: json)
    }
    
}

extension NetworkError : CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .Networking(let error, let code, _, _, let json):
            return "\(error.debugDescription) Code: \(code) \(json.map { JSONStringify($0)} ?? "")"
        case .Parsing(let error, _, _, let json):
            return "\((error as? CustomStringConvertible)?.description ?? "")) \(json.map { JSONStringify($0)} ?? "")"
        }
    }

}
