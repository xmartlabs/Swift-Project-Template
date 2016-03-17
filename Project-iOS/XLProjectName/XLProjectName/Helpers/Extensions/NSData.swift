//
//  NSData.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation

extension NSData {

    func toJSON() -> AnyObject? {
        return try? NSJSONSerialization.JSONObjectWithData(self, options: .AllowFragments)
    }
}
