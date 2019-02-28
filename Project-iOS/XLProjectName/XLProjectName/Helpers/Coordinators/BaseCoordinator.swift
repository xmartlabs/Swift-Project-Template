//
//  BaseCoordinator.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/26/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import UIKit
import Foundation

class BaseCoordinator: CoordinatorProtocol {
    
    var coordinatorActions: [CoordinatorActionProtocol] = []
    var childCoordinators: [CoordinatorProtocol] = []
    
    func start(){}
}

