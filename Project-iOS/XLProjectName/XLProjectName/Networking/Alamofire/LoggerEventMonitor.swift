//
//  LoggerEventMonitor.swift
//  XLProjectName
//
//  Created by Martin Barreto on 3/24/20.
//  Copyright © 2020 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Alamofire

class LoggerEventMonitor: EventMonitor {
    
    func requestDidResume(_ request: Request) {
        debugPrint(request)
    }
    
    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
        if Constants.Debug.crashlytics {
            error?.errorDescription.map { debugPrint($0) } 
        }
    }
}
