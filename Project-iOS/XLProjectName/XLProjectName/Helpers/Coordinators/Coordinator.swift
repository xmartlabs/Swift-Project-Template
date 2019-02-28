//
//  Coordinator.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/26/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//
import UIKit
import Foundation

protocol CoordinatorProtocol {
    
    var coordinatorActions: [CoordinatorActionProtocol] { get }
    var childCoordinators: [CoordinatorProtocol] { get set }
    
    func start()
}

protocol NavCoordinatorProtocol: CoordinatorProtocol {
    var navController: UINavigationController { get set }
}

protocol TabBarCoordinatorProtocol: CoordinatorProtocol {
    var tabBarController: UITabBarController { get set }
}
