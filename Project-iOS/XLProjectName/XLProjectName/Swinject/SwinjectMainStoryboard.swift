//
//  SwinjectMainStoryboard.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/27/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Swinject


class SwinjectMainStoryboard {
    class func setUpDependencies(in container: Container) {
        container.storyboardInitCompleted(LoginController.self) { _, controller in
            
        }
    }
}
