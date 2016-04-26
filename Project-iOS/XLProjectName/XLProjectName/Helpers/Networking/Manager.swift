//
//  Manager.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire

class MyManager: Alamofire.Manager {
    
    static let singleton = MyManager()
    
    override init?(session: NSURLSession, delegate: Manager.SessionDelegate, serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
        super.init(session: session, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    override init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: Alamofire.Manager.SessionDelegate = SessionDelegate(), serverTrustPolicyManager: Alamofire.ServerTrustPolicyManager? = nil)
    {
        super.init(configuration: configuration, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    override func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
        let result = super.request(URLRequest)
        debugPrint(result)
        return result
    }
    
    override func request(
                          method: Alamofire.Method,
                        _ URLString: URLStringConvertible,
                          parameters: [String: AnyObject]? = nil,
                          encoding: ParameterEncoding = .URL,
                          headers: [String: String]? = nil)
        -> Request {

        let result = super.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        debugPrint(result)
        return result
    }
}

final class Route {}

//public static func generalErrorHandler(error: ErrorType) {
//    // Trick to get the userInfo data (note that ErrorType always can be casted to NSError)
//    let nserror =  ((error as Any) as? NSError) ?? (error as NSError)
//    
//    if nserror.code == NSURLErrorNotConnectedToInternet {
//        // No internet connection, do something
//        DEBUGLog("No internet access")
//    } else if nserror.domain == Alamofire.Error.Domain {
//        if nserror.code == Alamofire.Error.Code.StatusCodeValidationFailed.rawValue {
//            // HTTP status code error (401, 404, etc)
//            DEBUGLog("Service error")
//        } else {
//            // Some error with the response
//            DEBUGLog("Response error")
//        }
//    }
//    
//    CLSNSLogv("Service call error: %@", getVaList([nserror]))
//    Crashlytics.sharedInstance().recordError(nserror)
//    
//    Crashlytics.sharedInstance().recordError(Error.errorWithCode(.JSONSerializationFailed, failureReason: (error as? CustomStringConvertible)?.description ?? ""), withAdditionalUserInfo: ["json": JSONStringify(value)])
//}
