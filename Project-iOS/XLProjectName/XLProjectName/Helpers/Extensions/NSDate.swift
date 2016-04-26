//
//  NSDate.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import Foundation

extension NSDate {

    func dblog() -> String {
        return Constants.Formatters.debugConsoleDateFormatter.stringFromDate(self)
    }

}
