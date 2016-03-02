//
//  Box.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/29/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation

class Box<T> {
    let value: T
    
    init(_ value: T){
        self.value = value
    }
}
