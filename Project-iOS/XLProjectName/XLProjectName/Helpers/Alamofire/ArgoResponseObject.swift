//
//  ArgoResponseObject.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import Alamofire
import Crashlytics

public enum NetworkError: ErrorType {
    case Networking(error: NSError, code: Error.Code, request: Request, response: NSHTTPURLResponse?, json: AnyObject?)
    case Parsing(error: NSError, request: Request, response: NSHTTPURLResponse?, json: AnyObject?)
    
    static func networkingError(alamofireError: NSError,request: Request,response: NSHTTPURLResponse? = nil, json: AnyObject? = nil) -> NetworkError {
        return NetworkError.Networking(error: alamofireError, code: Error.Code(rawValue: alamofireError.code)!, request: request, response: response, json: json)
    }
}

extension Request {
    
    public func responseObject<T: Decodable where T == T.DecodedType>(completionHandler: Response<T, NetworkError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, NetworkError> { request, response, data, error in
            return self.serialize(request, response: response, data: data, error: error) { result, value in
                let json = JSONStringify(value)
                print(json)
                let decodedData = T.decode(result.value != nil ? JSON.parse(result.value!) : JSON.Null)
                switch decodedData {
                case let .Failure(argoError):
                    let nsError = Error.errorWithCode(.JSONSerializationFailed, failureReason: argoError.description)
                    return .Failure(NetworkError.Parsing(error: nsError, request: self, response: response, json: data))
                case let .Success(object):
                    return .Success(object)
                }
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    func serialize<T>(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?, onSuccess: (Result<AnyObject, NSError>, AnyObject) -> Result<T, NetworkError>) -> Result<T, NetworkError> {
        guard error == nil else { return .Failure(NetworkError.networkingError(error!, request: self, response: response, json: data)) }
        let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
        let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
        switch result {
        case .Success(let value):
            if let _ = response { return onSuccess(result, value) }
            else {
                let failureReason = "JSON could not be serialized into response object: \(value)"
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(NetworkError.Parsing(error: error, request: self, response: response, json: data))
            }
        case .Failure(let error):
            var userInfo = error.userInfo
            userInfo["responseData"] = result.value ?? data
            return .Failure(NetworkError.Parsing(error: NSError(domain: error.domain, code: error.code, userInfo: userInfo), request: self, response: response, json: data))
        }
    }
    
}

extension Request {
    
    public func responseCollection<T: Decodable where T == T.DecodedType >(completionHandler: Response<[T], NetworkError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<[T], NetworkError> { request, response, data, error in
            return self.serialize(request, response: response, data: data, error: error) { result, value in
                if let representation = value as? [[String: AnyObject]] {
                    let json = JSONStringify(value)
                    print(json)
                    var result = [T]()
                    for userRepresentation in representation {
                        let decodedData = T.decode(JSON.parse(userRepresentation))
                        
                        switch decodedData {
                        case let .Failure(argoError):
                            let nsError = Error.errorWithCode(.JSONSerializationFailed, failureReason: argoError.description)
                            Crashlytics.sharedInstance().recordError(nsError, withAdditionalUserInfo: ["json": json])
                            return .Failure(NetworkError.Parsing(error: nsError, request: self, response: response, json: data))
                        case let .Success(object):
                            result.append(object)
                        }
                    }
                    return .Success(result)
                } else {
                    let failureReason = "Response collection could not be serialized due to nil response"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(NetworkError.Parsing(error: error, request: self, response: response, json: data))
                }
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
}

extension Request {
    
    public func responseAnyObject(completionHandler: Response<AnyObject, NetworkError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<AnyObject, NetworkError> { request, response, data, error in
            return self.serialize(request, response: response, data: data, error: error) { result, value in
                if let _ = response { return .Success(JSONStringify(value)) }
                let failureReason = "JSON could not be serialized into response object: \(value)"
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(NetworkError.Parsing(error: error, request: self, response: response, json: data))
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
}
