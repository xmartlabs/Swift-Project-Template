//
//  Device.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkDevice: RouteType {

    case Update(token: String)
    case Remove
    case Get
    
    var method: Alamofire.Method {
        switch self {
        case .Remove:
            return .DELETE
        case .Get:
            return .GET
        case .Update:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .Remove:
            return "devices/\(UIDevice.uniqueId)"
        case .Get:
            return "devices/\(UIDevice.uniqueId)"
        case .Update:
            return "devices/\(UIDevice.uniqueId)"
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .Update(let token):
            var parameters = [String: AnyObject]()
            let device = UIDevice.currentDevice()
            parameters["deviceToken"] = token
            parameters["device_type"] = "iOS"
            parameters["device_name"] = device.systemName
            parameters["device_model"] = device.model
            parameters["device_description"] = "\(device.systemName) \(device.systemVersion)"
            parameters["app_version"] = UIApplication.appVersion
            parameters["location"] = ""
            return parameters
        default:
            return nil
        }
    }
}
