//
//  NetworkManager.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire
import Crashlytics

public class NetworkManager {
    
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
        
//        Crashlytics.sharedInstance().recordError(Error.errorWithCode(.JSONSerializationFailed, failureReason: (error as? CustomStringConvertible)?.description ?? ""), withAdditionalUserInfo: ["json": JSONStringify(value)])
    }
    
}
