//
//  NSDate.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL ( http://xmartlabs.com )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation

extension NSDate {

    func dblog() -> String {
        return Constants.Formatters.debugConsoleDateFormatter.stringFromDate(self)
    }

}
