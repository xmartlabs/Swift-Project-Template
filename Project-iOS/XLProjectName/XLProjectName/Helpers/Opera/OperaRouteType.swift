//  RouteType.swift
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

import Alamofire
import Foundation

// MARK: - RouteType

/**
 *  A type that adopts RouteType can be used to create a request. 
    It's ideal to represent an API route/request since it clearly
    defines all the parts of a request such as its http path, method,
    parameters, encoding, etc. Often we group a set of related routes/request
    by conforming this protocol from an enum type that each value represent
    a specific route/request which may have specific configuration
    hold by its associated values.
 */
public protocol OperaRouteType: URLRequestConvertible {

    /// HTTP method
    var method: HTTPMethod { get }
    /// URL path
    var path: String { get }
    /// The parameters, nil if not implemented.
    var parameters: [String: Any]? { get }
    /* Used to specify the way in which a set of parameters
        are applied to a URL request. Default implementation returns 
        .JSON when method value is either .POST, .PUT or .PATCH. Otherwise .URL.
     */
    var encoding: Alamofire.ParameterEncoding { get }
    /// Base url
    var baseURL: URL { get }
    /// Manager that creates the request.
    var manager: ManagerType { get }
    /// Used to determine how often a request should be retried if unsuccessful
    var retryCount: Int { get }
}

/**
 *  By adopting URLRequestParametersSetup a RequestType or 
    PaginationRequstType is able to make a final customization
    to request parameters dictionary before they are encoded.
 */
public protocol URLRequestParametersSetup {

    func urlRequestParametersSetup(_ urlRequest: URLRequest, parameters: [String: Any]?) -> [String: Any]?

}

extension OperaRouteType {

    /// The URL request.
    public func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        let params = (self as? URLRequestParametersSetup)?
            .urlRequestParametersSetup(urlRequest, parameters: parameters) ?? parameters
        urlRequest = try encoding.encode(urlRequest, with: params)

        return urlRequest
    }

    public var encoding: ParameterEncoding {
        switch method {
        case .post, .put, .patch:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }

    public var parameters: [String: Any]? {
        return nil
    }

    public func getJsonFromPath(path: String, bundle: Bundle? = nil) -> Data? {
        guard let path = (bundle ?? Bundle.main).path(forResource: path, ofType: "json") else {
            return nil
        }

        do {
            let jsonData = try NSData(
                contentsOfFile: path,
                options: NSData.ReadingOptions.mappedIfSafe
            ) as Data
            return jsonData
        } catch {
            return nil
        }
    }
}

public enum DecodingError: Error {

    case invalidJson(String)

}

// MARK: - HTTP route types

public protocol GetRouteType: OperaRouteType {}
public protocol PostRouteType: OperaRouteType {}
public protocol OptionsRouteType: OperaRouteType {}
public protocol HeadRouteType: OperaRouteType {}
public protocol PutRouteType: OperaRouteType {}
public protocol PatchRouteType: OperaRouteType {}
public protocol DeleteRouteType: OperaRouteType {}
public protocol TraceRouteType: OperaRouteType {}
public protocol ConnectRouteType: OperaRouteType {}

public extension GetRouteType {

    var method: HTTPMethod {
        return .get
    }

}

public extension PostRouteType {

    var method: HTTPMethod {
        return .post
    }

}

public extension OptionsRouteType {

    var method: HTTPMethod {
        return .options
    }

}

public extension HeadRouteType {

    var method: HTTPMethod {
        return .head
    }

}

public extension PutRouteType {

    var method: HTTPMethod {
        return .put
    }

}

public extension PatchRouteType {

    var method: HTTPMethod {
        return .patch
    }

}

public extension DeleteRouteType {

    var method: HTTPMethod {
        return .delete
    }

}

public extension TraceRouteType {

    var method: HTTPMethod {
        return .trace
    }

}

public extension ConnectRouteType {

    var method: HTTPMethod {
        return .connect
    }

}
