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
    case Parsing(error: DecodeError, request: NSURLRequest?, response: NSHTTPURLResponse?, json: AnyObject?)
    
    static func networkingError(alamofireError: NSError, request: NSURLRequest?, response: NSHTTPURLResponse? = nil, json: AnyObject? = nil) -> NetworkError {
        return NetworkError.Networking(error: alamofireError, code: alamofireError.code, request: request, response: response, json: json)
    }
}
