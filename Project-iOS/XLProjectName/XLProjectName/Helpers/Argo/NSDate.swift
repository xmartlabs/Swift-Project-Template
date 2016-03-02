//
//  NSDate.swift
//  XLProjectName
//
//  Created by Martin Barreto on 3/1/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Argo
import Foundation
import SwiftDate

extension NSDate: Decodable {
    public typealias DecodedType = NSDate
    
    public class func decode(j: JSON) -> Decoded<NSDate> {
        switch j {
        case .String(let dateString):
            return  dateString.toDate(DateFormat.ISO8601).map(pure) ?? .typeMismatch("NSDate", actual: j)
        default: return .typeMismatch("NSDate", actual: j)
        }
    }
}