//
//  Device.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2019 XLOrganizationName. All rights reserved.
//

import Foundation
import Alamofire
import OperaSwift


extension Route {
    
    enum Device: RouteType {
        
        case Update(token: String)
        case Remove
        case Get
        
        var method: Alamofire.HTTPMethod {
            switch self {
            case .Remove:
                return .delete
            case .Get:
                return .get
            case .Update:
                return .post
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
        
        var parameters: [String: Any]? {
            switch self {
            case .Update(let token):
                var parameters = [String: Any]()
                let device = UIDevice.current
                parameters["deviceToken"] = token
                parameters["device_type"] = "iOS"
                parameters["device_name"] = device.systemName
                parameters["device_model"] = device.model
                parameters["device_description"] = "\(device.systemName) \(device.systemVersion)"
                parameters["app_version"] = UIApplication.applicationVersionNumber
                parameters["location"] = ""
                return parameters
            default:
                return nil
            }
        }
    }
}
