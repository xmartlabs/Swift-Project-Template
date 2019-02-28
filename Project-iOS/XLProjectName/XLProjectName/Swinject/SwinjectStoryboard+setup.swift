//
//  SwinjectStoryboard+setup.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/27/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    @objc class func setup() {
        SwinjectMainStoryboard.setUpDependencies(in: defaultContainer)
        SwinjectSearchRepositoryStoryboard.setUpDependencies(in: defaultContainer)
    }
}
