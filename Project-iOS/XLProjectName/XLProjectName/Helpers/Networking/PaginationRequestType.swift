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

struct EmptyFilter: FilterType {
    var parameters: [String: AnyObject]? { return nil }
}

protocol PaginationRequestType: RequestType {
    
    associatedtype Response: PaginationResponseType
    associatedtype Filter: FilterType
    
    var page: String { get }
    var query: String? { get }
    var route: RequestType { get }
    var filter: Filter? { get }
    
    var extraParameters: [String: AnyObject]? { get }
    func routeWithPage(page: String) -> Self
    func routeWithQuery(query: String) -> Self
    
    init(route: RequestType, page: String, query: String?, filter: Filter?, extraParameters: [String: AnyObject]?)
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
        return Self.init(route: route, page: page, query: query, filter: filter, extraParameters: extraParameters)
    }
    
    func routeWithQuery(query: String) -> Self {
        return Self.init(route: route, page: "1", query: query, filter: filter, extraParameters: extraParameters)
    }
    
    func routeWithFilter(filter: Filter) -> Self {
        return Self.init(route: route, page: "1", query: query, filter: filter, extraParameters: extraParameters)
    }
}

extension PaginationRequestType where Response.Element.DecodedType == Response.Element {
    
    func rx_collection() -> Observable<Response> {
        let myRequest = request
        let myPage = page
        return myRequest.rx_collection().map({ elements -> Response in
            return Response.init(elements: elements, previousPage: myRequest.response?.previousLinkPageValue, nextPage: myRequest.response?.nextLinkPageValue, page: myPage)
        })
    }
    

    private func responseCollection(completionHandler: Alamofire.Response<Response, NetworkError> -> Void) -> Request {
        let myRequest = request
        let myPage = page
        myRequest.responseCollection { (response: Alamofire.Response<[Response.Element], NetworkError>) in
            switch response.result {
            case .Failure(let error):
                completionHandler(Alamofire.Response(request: myRequest.request,
                                                    response: myRequest.response,
                                                        data: response.data,
                                                      result: .Failure(error)))
            case .Success(let elements):
                completionHandler(Alamofire.Response(request: myRequest.request,
                                                    response: myRequest.response,
                                                        data: response.data,
                    result: .Success(Response.init(elements: elements, previousPage: myRequest.response?.previousLinkPageValue, nextPage: myRequest.response?.nextLinkPageValue, page: myPage))))
            }
        }
        return myRequest
    }
}

struct PaginationRequest<Element: Decodable, Filter: FilterType where Element.DecodedType == Element>: PaginationRequestType {
    
    typealias Response = PaginationResponse<Element>
    
    var route: RequestType
    var page: String
    var query: String?
    var filter: Filter?
    var extraParameters: [String : AnyObject]?
    
    init(route: RequestType, page: String = "1", query: String? = nil, filter: Filter? = nil, extraParameters: [String: AnyObject]? = nil) {
        self.route = route
        self.page = page
        self.query = query
        self.filter = filter
    }
}
