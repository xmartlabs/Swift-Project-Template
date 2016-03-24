//
//  NSDate.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Argo
import Foundation
import SwiftDate

extension NSDate: Decodable {
    public typealias DecodedType = NSDate
    
    public class func decode(j: JSON) -> Decoded<NSDate> {
        switch j {
        case .String(let dateString):
            return  dateString.toDate(DateFormat.ISO8601Format(.Full)).map(pure) ?? .typeMismatch("NSDate", actual: j)
        default: return .typeMismatch("NSDate", actual: j)
        }
    }
}
