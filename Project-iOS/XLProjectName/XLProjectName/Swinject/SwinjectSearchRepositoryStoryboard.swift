//
//  SwinjectSearchRepositoryStoryboard.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/27/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Swinject

class SwinjectSearchRepositoryStoryboard {
    class func setUpDependencies(in container: Container) {
        container.storyboardInitCompleted(SearchRepositoriesController.self) { _, controller in

        }
    }
}
