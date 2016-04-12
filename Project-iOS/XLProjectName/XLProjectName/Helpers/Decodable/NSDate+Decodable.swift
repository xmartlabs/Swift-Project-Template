//
//  NSDate+Decodable.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL on 4/12/16. ( http://xmartlabs.com )
//    Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Decodable
import SwiftDate

extension NSDate: Decodable  {
    
    public class func decode(json: AnyObject) throws -> Self {
        let string = try String.decode(json)
        guard let date = string.toDate(DateFormat.ISO8601Format(.Full)) else {
            throw TypeMismatchError(expectedType: NSDate.self, receivedType: String.self, object: json)
        }
        return self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}