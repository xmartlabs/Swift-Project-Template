//
//  Constants.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation

struct Constants {

	struct Network {
        static let baseUrl = NSURL(string: "https://api.github.com")!
        static let authToken = "________"
        static let authTokenName = "auth_token"
        static let statusCodeString = "statusCode"
        static let SuccessCode = 200
        static let successRange = 200..<300
        static let Unauthorized = 401
        static let NotFoundCode = 404
        static let ServerError = 500
    }
    
    struct Formatters {
        
        static let debugConsoleDateFormatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = NSTimeZone(name: "UTC")!
            return formatter
        }()
        
    }
    
    struct Debug {
        static let crashlytics = false
    }
}

func DBLog(message: String, file: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
#if DEBUG
    let fileURL = NSURL(fileURLWithPath: file)
    let fileName = fileURL.URLByDeletingPathExtension?.lastPathComponent ?? ""
    print("\(NSDate().dblog()) \(fileName)::\(function)[L:\(line)] \(message)")
#endif
    // Nothing to do if not debugging
}
