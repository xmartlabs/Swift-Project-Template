//  Error.swift
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
 Provides information about networking errors, either networking errors or parsing error when Opera tries to parse the response.

 - Networking: Networking errors, most of the time errors thrown by NSURLSession under NSURLErrorDomain domain or by Alamofire library.
 - Parsing:    Represent parsing errors normally thrown by Json parsing library such as Decodable.
 */

public protocol OperaInternalError: Error, CustomStringConvertible, CustomDebugStringConvertible {
}

public enum SerializationError: OperaInternalError {
    case jsonSerializationError(reason: String)

    public var description: String {
        switch self {
        case .jsonSerializationError(let reason):
            return reason
        }
    }

    public var debugDescription: String {
        return description
    }
}

public struct UnknownError: OperaInternalError {

    let error: Error?

    public var description: String {
        return "Unknown error"
    }

    public var debugDescription: String {
        return error?.localizedDescription ?? self.description
    }
}

public indirect enum OperaError: Error {

    case networking(error: Error, request: URLRequest?, response: HTTPURLResponse?, json: Any?)
    case parsing(error: Error, request: URLRequest?, response: HTTPURLResponse?, json: Any?)

    public var error: Error {
        switch self {
        case .networking(let error, _, _, _):
            return error
        case .parsing(let error, _, _, _):
            return error
        }
    }

    public var request: URLRequest? {
        switch self {
        case .networking(_, let request, _, _):
            return request
        case .parsing(_, let request, _, _):
            return request
        }
    }

    public var response: HTTPURLResponse? {
        switch self {
        case .networking(_, _, let response, _):
            return response
        case .parsing(_, _, let response, _):
            return response
        }
    }

    public var body: Any? {
        switch self {
        case .networking(_, _, _, let anyJson):
            return JSONFrom(data: anyJson as? Data)
        case .parsing(_, _, _, let anyJson):
            return JSONFrom(data: anyJson as? Data)
        }
    }

    public var bodyString: String? {
        var json: Any? = nil
        switch self {
        case let .networking(error: _, request: _, response: _, json: j):
            json = j
        case let .parsing(error: _, request: _, response: _, json: j):
            json = j
        }

        if let data = json as? Data {
            return String(data: data, encoding: .utf8)
        } else if let string = json as? String {
            return string
        } else {
            return nil
        }
    }

    public var statusCode: Int? {
        return response?.statusCode
    }

    public var localizedDescription: String {
        switch self {
        case .networking(let error, _, _, _):
            return "The request could not be completed because of error: \(error.localizedDescription)"
        case .parsing(let error, _, _, _):
            return "JSON could not be parsed because of error: \(error.localizedDescription)"
        }
    }

    private func toDictionaryWith(object: Any?) -> NSDictionary? {
        return try? JSONSerialization
            .jsonObject(
                with: object as? Data ?? Data(),
                options: JSONSerialization.ReadingOptions.mutableContainers
            ) as? NSDictionary ?? [:]
    }

}

extension OperaError : CustomDebugStringConvertible {

    /// A textual representation of Opera.Error instance, suitable for debugging.
    public var debugDescription: String {

        switch self {
        case .networking(let error, let request, _, let json):
            var components = [String]()

            components.append("Networking Error: \((error as CustomStringConvertible).description)")
            components.append((error as CustomDebugStringConvertible).debugDescription)

            if let method = request?.httpMethod {
                components.append(method)
            }
            if let URLString = request?.url?.absoluteString {
                components.append(URLString)
            }
            if let jsonStringify = json.map({ JSONStringify($0) }) {
                components.append("Json:")
                components.append(jsonStringify)
            }
            return components.joined(separator: " \\\n\t")
        case .parsing(let error, let request, _, let json):
            var components = ["Parsing Error"]
            components.append((error as CustomDebugStringConvertible).debugDescription)

            if let method = request?.httpMethod {
                components.append(method)
            }
            if let URLString = request?.url?.absoluteString {
                components.append("URL: \(URLString)")
            }
            if let jsonStringify = json.map({ JSONStringify($0) }) {
                components.append("Json:")
                components.append(jsonStringify)
            }
            return components.joined(separator: " \\\n\t")
        }
    }

}

extension OperaError: CustomStringConvertible {

    /// A textual representation of Error instance.
    public var description: String {
        switch self {
        case .networking(let error, let request, _, _):
            var components = [String]()
            components.append("Networking Error: \((error as CustomStringConvertible).description)")

            if let method = request?.httpMethod {
                components.append(method)
            }
            if let URLString = request?.url?.absoluteString {
                components.append(URLString)
            }

            return components.joined(separator: " ")
        case .parsing(let error, let request, _, let json):
            var components = ["Parsing Error"]
            if let method = request?.httpMethod {
                components.append(method)
            }
            if let URLString = request?.url?.absoluteURL {
                components.append("URL: \(URLString)")
            }
            components.append((error as CustomStringConvertible).description)
            components = [components.joined(separator: " ")]
            if let jsonStringify = json.map({ JSONStringify($0) }) {
                components.append("Json:\r\n")
                components.append(jsonStringify)
            }
            return components.joined(separator: " \\\n\t")
        }

    }
}
