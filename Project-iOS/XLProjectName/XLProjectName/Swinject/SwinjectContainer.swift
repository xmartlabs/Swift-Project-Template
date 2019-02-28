//
//  SwinjectContainer.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/27/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Swinject

/// Dependency injection container
class SwinjectContainer {
    static private(set) var container: Container?
    
    // swiftlint:disable function_body_length
    static func initialize() {
        Container.loggingFunction = nil
        
        container = Container { controller in


        }
    }
}
