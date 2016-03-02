//
//  NSData.swift
//  XLProjectName
//
//  Created by Martin Barreto on 3/2/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation

extension NSData {

    func toJSON() -> AnyObject? {
        return try? NSJSONSerialization.JSONObjectWithData(self, options: .AllowFragments)
    }
}
