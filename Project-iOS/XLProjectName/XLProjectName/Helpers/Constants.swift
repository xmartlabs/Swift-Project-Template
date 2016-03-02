//
//  Constants.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
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
    
    struct Debug {
        static let crashlytics = false
    }
}



