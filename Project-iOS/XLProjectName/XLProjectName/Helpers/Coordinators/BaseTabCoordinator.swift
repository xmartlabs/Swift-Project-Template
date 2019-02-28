//
//  BaseTabCoordinator.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/26/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import UIKit
import Foundation

class BaseTabCoordinator: BaseCoordinator, NavCoordinatorProtocol {
    
    var navController: UINavigationController
    
    init(navController: UINavigationController) {
        self.navController = navController
    }
}
