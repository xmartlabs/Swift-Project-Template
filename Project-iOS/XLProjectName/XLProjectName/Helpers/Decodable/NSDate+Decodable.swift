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

extension Date {
    
    public static func decode(_ json: Any) throws -> Date {
        let string = try String.decode(json)
        do {
            let date = try string.date(format: .iso8601(options: .withInternetDateTimeExtended))
            return self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
        } catch {
            throw DecodingError.typeMismatch(expected: Date.self, actual: String.self, DecodingError.Metadata(object: json))
        }
    }
}
