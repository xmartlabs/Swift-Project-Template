//
//  CoordinatorActionProtocol.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/26/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation
import UIKit

protocol CoordinatorActionProtocol {
    
    var actionName: String { get }
    var segue: UIStoryboardSegue { get }
    var presentingControllerType: BaseViewControllerProtocol.Type { get }
    
}
