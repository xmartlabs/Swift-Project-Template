//
//  NetworkManager.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import Crashlytics

public class NetworkManager {

    public static let networkManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        // Customize default headers, do not add authentication or content type here
//        var headers = [String: String]()
//        headers.merge(Manager.defaultHTTPHeaders)
//        cfg.HTTPAdditionalHeaders = headers
        return Alamofire.Manager(configuration: configuration)
    }()

    static func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
        let request = networkManager.request(URLRequest).validate()
        DEBUGLog(request.debugDescription)
        return request
    }
    
    static func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil) -> Alamofire.Request {
        let request = networkManager.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        DEBUGLog(request.debugDescription)
        return request
    }
    
    public static func generalErrorHandler(error: ErrorType) {
        // Trick to get the userInfo data (note that ErrorType always can be casted to NSError)
        let nserror =  ((error as Any) as? NSError) ?? (error as NSError)

        if nserror.code == NSURLErrorNotConnectedToInternet {
            // No internet connection, do something
            DEBUGLog("No internet access")
        } else if nserror.domain == Alamofire.Error.Domain {
            if nserror.code == Alamofire.Error.Code.StatusCodeValidationFailed.rawValue {
                // HTTP status code error (401, 404, etc)
                DEBUGLog("Service error")
            } else {
                // Some error with the response
                DEBUGLog("Response error")
            }
        }
        
        CLSNSLogv("Service call error: %@", getVaList([nserror]))
        Crashlytics.sharedInstance().recordError(nserror)
    }
    
}
