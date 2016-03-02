//
//  NetworkManager.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/19/16
//  Copyright (c) 2016 Xmartlabs SRL. All rights reserved.
//

import Foundation
import Alamofire
import Argo

public class NetworkManager {

    public static let networkManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        // Customize default headers, do not add authentication or content type here
//        var headers = [String: String]()
//        headers.merge(Manager.defaultHTTPHeaders)
//        cfg.HTTPAdditionalHeaders = headers
        return Alamofire.Manager(configuration: configuration)
    }()

    static func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
        let request = networkManager.request(URLRequest)
        debugPrint(request)
        return request
    }
    
    static func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil) -> Alamofire.Request {
        let request = networkManager.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        debugPrint(request)
        return request
    }
    
    
    
    public static func handleResponse<T: Decodable where T == T.DecodedType>(response: Response<T, NSError>, onSuccess: ((T) -> Void)? = nil, onFailure: ((NSError, NSHTTPURLResponse?, AnyObject?) -> Void)? = nil) {
        switch response.result {
        case .Success(let value):
            onSuccess?(value)
        case .Failure(let error):
            onFailure?(error, response.response, response.data?.toJSON())
        }
    }
    
    public static func handleResponse<T: Decodable where T == T.DecodedType>(response: Response<[T], NSError>, onSuccess: (([T]) -> Void)? = nil, onFailure: ((NSError, NSHTTPURLResponse?, AnyObject?) -> Void)? = nil) {
        switch response.result {
        case .Success(let value):
            onSuccess?(value)
        case .Failure(let error):
            onFailure?(error, response.response, response.data?.toJSON())
        }
    }
    
}
