//
//  ArgoResponseObject.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/29/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Argo
import Alamofire


extension Request {
    
    public func responseObject<T: Decodable where T == T.DecodedType>(completionHandler: Response<T, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            switch result {
            case .Success(let value):
                if let _ = response {
                    print(JSONStringify(value))
                    let decodedData = T.decode(result.value != nil ? JSON.parse(result.value!) : JSON.Null)
                    switch decodedData {
                    case let .Failure(argoError):
                        return .Failure(Error.errorWithCode(.JSONSerializationFailed, failureReason: argoError.description))
                    case let .Success(object):
                        return .Success(object)                        
                    }
                } else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

extension Request {
    public func responseCollection<T: Decodable where T == T.DecodedType >(completionHandler: Response<[T], NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                if let _ = response {
                    print(JSONStringify(value))
                    if let representation = value as? [[String: AnyObject]] {
                        var result = [T]()
                        for userRepresentation in representation {
                            let decodedData = T.decode(JSON.parse(userRepresentation))
                            
                            switch decodedData {
                            case let .Failure(argoError):
                                return .Failure(Error.errorWithCode(.JSONSerializationFailed, failureReason: argoError.description))
                            case let .Success(object):
                                result.append(object)
                            }
                        }
                        return .Success(result)
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
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

