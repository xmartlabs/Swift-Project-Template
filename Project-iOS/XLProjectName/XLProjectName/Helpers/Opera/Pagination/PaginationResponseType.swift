//  PaginationResponseType.swift
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
 *  PaginationResponseType represent the relevant data within a 
    PaginationRequestType response such as its serialized elements,
    previous and next page information, 
    and the page used as parameter to fetch the elements.
 */
public protocol PaginationResponseType {

    associatedtype Element

    /// Elements fetched by PaginationRequestType
    var elements: [Element] { get }

    /// previous page info gotten from prev relation Link.
    var previousPage: String? { get }
    /// next page gotten from next relation Link.
    var nextPage: String? { get }
    /// current page, value passed as a parameter in the related PaginationRequestType request
    var page: String? { get }

    /**
     PaginationResponseType initializer
     
     - parameter elements:     elements
     - parameter previousPage: previous page
     - parameter nextPage:     next page
     - parameter page:         current page
     
     - returns: PaginationResponseType instance
     */
    init(elements: [Element], previousPage: String?, nextPage: String?, page: String?)
}

extension PaginationResponseType {

    /// indicates if there are any items in a previous page.
    public var hasPreviousPage: Bool {
        return previousPage != nil
    }

    /// indicates if the server has more items that can be fetched using the `nextPage` value.
    public var hasNextPage: Bool {
        return nextPage != nil
    }
}
