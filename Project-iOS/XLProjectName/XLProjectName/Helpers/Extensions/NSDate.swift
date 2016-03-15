//
//  NSDate.swift
//  XLProjectName
//
//  Created by Miguel Revetria on 3/14/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation

extension NSDate {

    func dblog() -> String {
        return Constants.Formatters.debugConsoleDateFormatter.stringFromDate(self)
    }

}
