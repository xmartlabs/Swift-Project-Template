//
//  Request+ResponseObject.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import Alamofire
import Crashlytics

extension Request {
    
    public func responseObject<T: XLDecodable>(keyPath: String? = nil, completionHandler: Response<T, NetworkError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, NetworkError> { request, response, data, error in
            return Request.serialize(request, response: response, data: data, error: error) { result, value in
                DEBUGJson(value)
                if let object = keyPath.map({ value.valueForKeyPath($0)}) ?? value {
                    do {
                        let decodedData = try T.decode(object)
                        return .Success(decodedData)
                    }
                    catch let error {
                        return .Failure(NetworkError.Parsing(error: error, request: request, response: response, json: data))
                    }
                } else {
                    let failureReason = "Json response could not be found"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(NetworkError.networkingError(error, request: request, response: response, json: data))
                }
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    
    public func responseCollection<T: XLDecodable>(collectionKeyPath: String? = nil, completionHandler: Response<[T], NetworkError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<[T], NetworkError> { request, response, data, error in
            return Request.serialize(request, response: response, data: data, error: error) { result, value in
                if let representation = (collectionKeyPath.map { value.valueForKeyPath($0) } ?? value) as? [[String: AnyObject]] {
                    DEBUGJson(value)
                    var result = [T]()
                    for userRepresentation in representation {
                        do {
                            let decodedData = try T.decode(userRepresentation)
                            result.append(decodedData)
                        }
                        catch let error {
                            Crashlytics.sharedInstance().recordError(Error.errorWithCode(.JSONSerializationFailed, failureReason: (error as? CustomStringConvertible)?.description ?? ""), withAdditionalUserInfo: ["json": JSONStringify(value)])
                            return .Failure(NetworkError.Parsing(error: error, request: request, response: response, json: data))
                        }
                    }
                    return .Success(result)
                } else {
                    let failureReason = "Json Response collection could not be found"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(NetworkError.networkingError(error, request: request, response: response, json: data))
                }
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    public func responseAnyObject(completionHandler: Response<AnyObject, NetworkError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<AnyObject, NetworkError> { request, response, data, error in
            return Request.serialize(request, response: response, data: data, error: error) { result, value in
                if let _ = response { return .Success(JSONStringify(value)) }
                let failureReason = "JSON could not be serialized into response object: \(value)"
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(NetworkError.networkingError(error, request: request, response: response, json: data))
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    // Mark: Auxiliary method
    
    private static func serialize<T>(request: NSURLRequest?,
                                    response: NSHTTPURLResponse?,
                                        data: NSData?,
                                       error: NSError?,
                                   onSuccess: (Result<AnyObject, NSError>, AnyObject) -> Result<T, NetworkError>)
                        -> Result<T, NetworkError> {
        guard error == nil else { return .Failure(NetworkError.networkingError(error!, request: request, response: response, json: data)) }
        let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
        let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
        switch result {
        case .Success(let value):
            guard let _ = response else {
                let failureReason = "JSON could not be serialized into response object: \(value)"
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(NetworkError.networkingError(error, request: request, response: response, json: data))
            }
            return onSuccess(result, value)
            
        case .Failure(let error):
            var userInfo = error.userInfo
            userInfo["responseData"] = result.value ?? data
            return .Failure(NetworkError.networkingError(NSError(domain: error.domain, code: error.code, userInfo: userInfo), request: request, response: response, json: result.value ?? data))
        }
    }
    
}
