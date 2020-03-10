//
//  AdaptedRouteType.swift
//  OperaSwift
//
//  Created by Diego Ernst on 5/12/17.
//
//

import Alamofire

public protocol AdaptedRouteType: OperaRouteType {

    var routeType: OperaRouteType { get }

}

public extension AdaptedRouteType {

    var method: HTTPMethod { return routeType.method }
    var path: String { return routeType.path }
    var parameters: [String: Any]? { return routeType.parameters }
    var encoding: Alamofire.ParameterEncoding { return routeType.encoding }
    var baseURL: URL { return routeType.baseURL }
    var manager: ManagerType { return routeType.manager }
    var retryCount: Int { return routeType.retryCount }
}

public extension AdaptedRouteType {

    var innerRouteType: OperaRouteType {
        var innerRouteType = self.routeType
        while let adapted = innerRouteType as? AdaptedRouteType {
            innerRouteType = adapted.routeType
        }
        return innerRouteType
    }

}
