//
//  OperaResult.swift
//  Opera ( https://github.com/xmartlabs/Opera )
//
//  Copyright (c) 2019 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire

/**
 *  The result of a network request. Contains the request and the response object or an error
 */
public struct OperaResult {

    public var result: Result<OperaResponse>
    public var requestConvertible: URLRequestConvertible

    // Initializer must be defined so that it is public and not internal
    public init(result: Result<OperaResponse>, requestConvertible: URLRequestConvertible) {
        self.result = result
        self.requestConvertible = requestConvertible
    }

}

extension OperaResult {
    
    public var operaResponse: OperaResponse? {
        switch self.result {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var httpResponse: HTTPURLResponse? {
        return operaResponse?.response
    }

    /**
     Generic response object serialization that returns a OperaDecodable instance.
     
     - parameter keyPath:           keyPath to look up json object to serialize. 
     Ignore parameter or pass nil when json object is the json root item.
     
     - returns: The serialized object or an error.
     */
    public func serializeObject<T: OperaDecodable>(_ keyPath: String? = nil) -> DataResponse<T> {
        switch result {
        case let .success(value):
            let result = OperaResult.serialize(
                nil,
                response: value.response,
                data: value.data,
                error: nil,
                onsuccess: { (_, json) -> Result<T> in
                    let object = keyPath.map({ (json as AnyObject).value(forKeyPath: $0) as Any}) ?? json
                    do {
                        let decodedData = try T.decode(object as AnyObject)
                        return .success(decodedData)
                    } catch let error {
                        return .failure(
                            OperaError.parsing(
                                error: error,
                                request: try? self.requestConvertible.asURLRequest(),
                                response: value.response,
                                json: json
                            )
                        )
                    }
                }
            )
            return DataResponse(
                request: try? requestConvertible.asURLRequest(),
                response: value.response,
                data: value.data,
                result: result
            )
        case let .failure(error):
            return DataResponse(
                request: try? requestConvertible.asURLRequest(),
                response: nil,
                data: nil,
                result: .failure(error)
            )
        }
    }

    /**
     Generic response object serialization that returns an Array of OperaDecodable instances.
     
     - parameter collectionKeyPath: keyPath to look up json array to serialize.
     Ignore parameter or pass nil when json array is the json root item.
     
     - returns: The serialized objects or an error.
     */
    public func serializeCollection<T: OperaDecodable>
        (_ collectionKeyPath: String? = nil) -> DataResponse<[T]> {
        switch result {
        case let .success(value):
            let result = OperaResult.serialize(
                nil,
                response: value.response,
                data: value.data,
                error: nil,
                onsuccess: { (result, json) -> Result<[T]> in
                if let representation = (
                    collectionKeyPath.map {
                        (json as AnyObject).value(forKeyPath: $0) as Any
                    } ?? json) as? [[String: AnyObject]] {
                    var result = [T]()
                    for userRepresentation in representation {
                        do {
                            let decodedData = try T.decode(userRepresentation as AnyObject)
                            result.append(decodedData)
                        } catch let error {
                            return .failure(
                                OperaError.parsing(
                                    error: error,
                                    request: try? self.requestConvertible.asURLRequest(),
                                    response: value.response,
                                    json: json
                                )
                            )
                        }
                    }
                    return .success(result)
                } else {
                    let failureReason = "Json Response collection could not be found"
                    let error = SerializationError.jsonSerializationError(reason: failureReason)
                    return .failure(
                        OperaError.networking(
                            error: error,
                            request: try? self.requestConvertible.asURLRequest(),
                            response: value.response, json: json
                        )
                    )
                }
            })
            return DataResponse(
                request: try? requestConvertible.asURLRequest(),
                response: value.response,
                data: value.data,
                result: result
            )
        case let .failure(error):
            return DataResponse(
                request: try? requestConvertible.asURLRequest(),
                response: nil,
                data: nil,
                result: .failure(error)
            )
        }
    }

    /**
     Generic response object serialization. Notice that Response Error type is Opera.Error.
     
     - returns: The json object from the response or an error
     */
    public func serializeAny() -> DataResponse<Any> {
        switch result {
        case let .success(value):
            let result = OperaResult.serialize(
                nil,
                response: value.response,
                data: value.data,
                error: nil,
                onsuccess: { (_, json) -> Result<Any> in
                    if let _ = value.response { return .success(json) }
                    let failureReason = "JSON could not be serialized into response object"
                    let error = SerializationError.jsonSerializationError(reason: failureReason)
                    return .failure(
                        OperaError.networking(
                            error: error,
                            request: try? self.requestConvertible.asURLRequest(),
                            response: value.response,
                            json: json
                        )
                    )
                }
            )
            return DataResponse(
                request: try? requestConvertible.asURLRequest(),
                response: value.response,
                data: value.data,
                result: result
            )
        case let .failure(error):
            return DataResponse(
                request: try? requestConvertible.asURLRequest(),
                response: nil,
                data: nil,
                result: .failure(error)
            )
        }
    }

    fileprivate static func serialize<T>(_ request: URLRequest?,
                                  response: HTTPURLResponse?,
                                  data: Data?,
                                  error: NSError?,
                                  onsuccess: (Result<Any>, Any) -> Result<T>)
        -> Result<T> {
            guard error == nil else {
                return .failure(
                    OperaError.networking(
                        error: error!,
                        request: request,
                        response: response,
                        json: data as AnyObject
                    )
                )
            }
            let JSONResponseSerializer = DataRequest
                .jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .success(let value):
                guard response != nil else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let error = SerializationError.jsonSerializationError(reason: failureReason)
                    return .failure(
                        OperaError.networking(
                            error: error,
                            request: request,
                            response: response,
                            json: data as AnyObject
                        )
                    )
                }
                return onsuccess(result, value)

            case .failure(let error):
                return .failure(
                    OperaError.networking(
                        error: error,
                        request: request,
                        response: response,
                        json: result.value ?? data
                    )
                )
            }
    }
}
