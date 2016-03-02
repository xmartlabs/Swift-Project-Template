//
//  NSURL.swift
//  XLProjectName
//
//  Created by Martin Barreto on 3/1/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Argo
import Foundation

extension NSURL: Decodable {
    public typealias DecodedType = NSURL
    
    public class func decode(j: JSON) -> Decoded<NSURL> {
        switch j {
        case .String(let urlString):
            return NSURL(string: String(urlString)).map(pure) ?? .typeMismatch("URL", actual: j)
        default: return .typeMismatch("URL", actual: j)
        }
    }
}
