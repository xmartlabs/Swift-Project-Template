//
//  PaginationRequestType.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/21/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import Alamofire
import RxSwift
import Crashlytics
import WebLinking

protocol FilterType {
    var parameters: [String: AnyObject]? { get }
}

protocol PaginationRequestType: RequestType {
    
    associatedtype Response: PaginationResponseType
    
    var page: String { get }
    var query: String? { get }
    var route: RequestType { get }
    var filter: FilterType? { get }
    var collectionKeyPath: String? { get }
    
    var extraParameters: [String: AnyObject]? { get }
    func routeWithPage(page: String) -> Self
    func routeWithQuery(query: String) -> Self
    func routeWithFilter(filter: FilterType) -> Self
    
    init(route: RequestType, page: String, query: String?, filter: FilterType?, extraParameters: [String: AnyObject]?, collectionKeyPath: String?)
}

extension PaginationRequestType {
    
    var method: Alamofire.Method { return route.method }
    var path: String { return route.path }
    var parameters: [String: AnyObject]? {
        var result = route.parameters ?? [:]
        result["page"] = page
        if let q = query where q != "" {
            result["q"] = query
        }
        if let filterParam = filter?.parameters {
            result.merge(filterParam)
        }
        return result
    }
    var encoding: Alamofire.ParameterEncoding { return route.encoding }
    
    func routeWithPage(page: String) -> Self {
        return Self.init(route: route, page: page, query: query, filter: filter, extraParameters: extraParameters, collectionKeyPath: collectionKeyPath)
    }
    
    func routeWithQuery(query: String) -> Self {
        return Self.init(route: route, page: "1", query: query, filter: filter, extraParameters: extraParameters, collectionKeyPath: collectionKeyPath)
    }
    
    func routeWithFilter(filter: FilterType) -> Self {
        return Self.init(route: route, page: "1", query: query, filter: filter, extraParameters: extraParameters, collectionKeyPath: collectionKeyPath)
    }
}

extension PaginationRequestType where Response.Element: Decodable, Response.Element.DecodedType == Response.Element {
    
    func rx_collection() -> Observable<Response> {
        let myRequest = request
        let myPage = page
        return myRequest.rx_collection(collectionKeyPath).map({ elements -> Response in
            return Response.init(elements: elements, previousPage: myRequest.response?.previousLinkPageValue, nextPage: myRequest.response?.nextLinkPageValue, page: myPage)
        })
    }
    
}

struct PaginationRequest<Element: Decodable where Element.DecodedType == Element>: PaginationRequestType {
    
    typealias Response = PaginationResponse<Element>
    
    var route: RequestType
    var page: String
    var query: String?
    var filter: FilterType?
    var extraParameters: [String : AnyObject]?
    var collectionKeyPath: String?
    
    init(route: RequestType, page: String = "1", query: String? = nil, filter: FilterType? = nil, extraParameters: [String: AnyObject]? = nil, collectionKeyPath: String? = nil) {
        self.route = route
        self.page = page
        self.query = query
        self.filter = filter
        self.extraParameters = extraParameters
        self.collectionKeyPath = collectionKeyPath
    }
}
