//
//  RouteType.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Opera
import Alamofire

extension RouteType {

    var baseURL: NSURL { return Constants.Network.baseUrl }
    var manager: ManagerType { return NetworkManager.singleton  }
    var retryCount: Int { return 0 }
}
