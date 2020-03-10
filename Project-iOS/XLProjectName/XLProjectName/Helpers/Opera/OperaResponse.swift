//
//  OperaResponse.swift
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

/**
 *  The response object returned by a successful request
 */
public struct OperaResponse {
    public let statusCode: Int
    public let data: Data
    public let response: HTTPURLResponse?

    // Initializer must be defined so that it is public and not internal
    public init(statusCode: Int, data: Data, response: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.response = response
    }

}

extension OperaResponse: CustomDebugStringConvertible, Equatable {
    public var description: String {
        return "Response Status Code: \(statusCode)"
    }

    public var debugDescription: String {
        return description
    }
}

public func == (lhs: OperaResponse, rhs: OperaResponse) -> Bool {
    return lhs.statusCode == rhs.statusCode
        && lhs.data == rhs.data
        && lhs.response == rhs.response
}
