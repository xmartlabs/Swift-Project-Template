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

protocol PaginationRequestType: RouteType {
    
    associatedtype Response: PaginationResponseType
    
    var page: String { get }
    var route: RouteType { get }
    var pageSize: Int? { get }
    
    func routeWithPage(page: String) -> Self
    init(route: RouteType, page: String)
}

extension PaginationRequestType {
    
    var method: Alamofire.Method { return route.method }
    var path: String { return route.path }
    //var parameters: [String: AnyObject]? { return route.parameters?.merge(["page": page]) }
    var encoding: Alamofire.ParameterEncoding { return route.encoding }
}

extension PaginationRequestType where Response.Element.DecodedType == Response.Element {
    
    func rx_paginationCollection() -> Observable<Response> {
        return Observable.create { subscriber in
            let request =  self.responsePaginationCollection() { (response: Alamofire.Response<Response, NSError>) in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let entity):
                    subscriber.onNext(entity)
                    subscriber.onCompleted()
                    break
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
    
    func responsePaginationCollection(completionHandler: Alamofire.Response<Response, NSError> -> Void) -> Request {
        let responseSerializer = ResponseSerializer<Response, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                if let _ = response {
                    let json = JSONStringify(value)
                    print(json)
                    if let representation = value as? [[String: AnyObject]] {
                        var result = Array<Response.Element>()
                        for userRepresentation in representation {
                            let decodedData = Response.Element.decode(JSON.parse(userRepresentation))
                            
                            
                            
                            switch decodedData {
                            case let .Failure(argoError):
                                let nsError = Error.errorWithCode(.JSONSerializationFailed, failureReason: argoError.description)
                                Crashlytics.sharedInstance().recordError(nsError, withAdditionalUserInfo: ["json": json])
                                return .Failure(nsError)
                            case let .Success(object):
                                result.append(object)
                            }
                        }
                        let resp = Response.init(elements: result, previousPage: "", nextPage: "")
                        return .Success(resp)
                    }
                    let failureReason = "Response collection could not be serialized due to nil array"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                } else {
                    let failureReason = "Response collection could not be serialized due to nil response"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
        return NetworkManager.request(self).response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

}

struct PaginationRequest<Element: Decodable where Element.DecodedType == Element>: PaginationRequestType {
    
    typealias Response = PaginationResponse<Element>
    
    var page: String
    var pageSize: Int?
    var route: RouteType
    
    init(route: RouteType, page: String) {
        self.route = route
        self.page = page
    }
    
    func routeWithPage(page: String) -> PaginationRequest<Element> {
        return PaginationRequest(route: route, page: page)
    }
}
