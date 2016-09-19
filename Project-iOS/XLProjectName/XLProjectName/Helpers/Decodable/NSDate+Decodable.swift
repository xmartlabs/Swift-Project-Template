//
//  NSDate+Decodable.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import Decodable
import SwiftDate

extension Date: Decodable {
    
    public static func decode(_ json: AnyObject) throws -> Date {
        let string = try String.decode(json)
        guard let date = string.toDate(DateFormat.ISO8601Format(.Full)) else {
            throw TypeMismatchError(expectedType: Date.self, receivedType: String.self, object: json)
        }
        return self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}
