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

protocol PaginationRequestType: RequestType {
    
    associatedtype Response: PaginationResponseType
    
    var page: String { get }
    var query: String { get }
    var route: RequestType { get }
    var pageSize: Int? { get }
    
    func routeWithPage(page: String) -> Self
    init(route: RequestType, query: String, page: String)
}

extension PaginationRequestType {
    
    var method: Alamofire.Method { return route.method }
    var path: String { return route.path }
    var parameters: [String: AnyObject]? {
        var result = route.parameters ?? [:]
        result["page"] = page
        if query != "" {
            result["q"] = query
        }
        return result
    }
    var encoding: Alamofire.ParameterEncoding { return route.encoding }
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

struct PaginationRequest<Element: Decodable where Element.DecodedType == Element>: PaginationRequestType {
    
    typealias Response = PaginationResponse<Element>
    
    var page: String
    var query: String
    var route: RequestType
    
    var pageSize: Int?
    
    init(route: RequestType, query: String = "", page: String = "1") {
        self.route = route
        self.page = page
        self.query = query
    }
    
    func routeWithPage(page: String) -> PaginationRequest<Element> {
        return PaginationRequest(route: route, page: page, query: query)
    }
    
    func routeWithQuery(query: String) -> PaginationRequest<Element> {
        return PaginationRequest(route: route, page: page, query: query)
    }
}
