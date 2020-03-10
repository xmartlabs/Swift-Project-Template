//  PaginationRequest.swift
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
 *  A Generic type that adopts PaginationRequestType
 */
public struct PaginationRequest<Element: OperaDecodable>: PaginationRequestType {

    public typealias Response = PaginationResponse<Element>

    public var route: OperaRouteType
    public var page: String = ""
    public var query: String?
    public var filter: FilterType?
    public var collectionKeyPath: String?

    public init(
        route: OperaRouteType,
        page: String? = nil,
        query: String? = nil,
        filter: FilterType? = nil,
        collectionKeyPath: String? = nil
    ) {
        self.route = route
        self.page = page ?? (self as? PaginationRequestTypeSettings)?
            .firstPageParameterValue ?? Default.firstPageParameterValue
        self.query = query
        self.filter = filter
        self.collectionKeyPath = collectionKeyPath
    }
}
