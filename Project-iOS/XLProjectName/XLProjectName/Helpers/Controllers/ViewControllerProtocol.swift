//
//  ViewControllerProtocol.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/26/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import UIKit
import Foundation

protocol BaseViewControllerProtocol where Self: UIViewController {
    var baseCoordinator: CoordinatorProtocol? { get }
}

protocol ViewControllerProtocol {
    associatedtype CoordinatorType: CoordinatorProtocol
    var coordinator: CoordinatorType? { get set }
}

