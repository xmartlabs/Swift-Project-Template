//
//  RequestType.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Opera
import Alamofire

extension RouteType {

    var baseURL: NSURL { return Constants.Network.baseUrl }
    var manager: Alamofire.Manager { return MyManager.singleton  }

}
