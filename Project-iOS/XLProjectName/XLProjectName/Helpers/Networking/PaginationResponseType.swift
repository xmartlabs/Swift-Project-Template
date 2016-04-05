//
//  PaginationResponseType.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 3/21/16. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation

protocol PaginationResponseType {
    
    associatedtype Element
    
    var elements: [Element] { get }
    var previousPage: String? { get }
    var nextPage: String? { get }
    
    init(elements: [Element], previousPage: String?, nextPage: String?, page: String?)
}

extension PaginationResponseType {
    
    var hasPreviousPage: Bool {
        return previousPage != nil
    }
    var hasNextPage: Bool {
        return nextPage != nil
    }
}

struct PaginationResponse<E>: PaginationResponseType {
    
    let elements: [E]
    var previousPage: String?
    var nextPage: String?
    var page: String?
}
