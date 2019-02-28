//
//  Storyboarded.swift
//  XLProjectName
//
//  Created by Martin Barreto on 2/26/19.
//  Copyright © 2019 'XLOrganizationName'. All rights reserved.
//

import Foundation
import UIKit
import Rswift

protocol Storyboarded where Self: UIViewController {
    var storyboard: UIStoryboard { get }
    var viewControllerIdentifier: StoryboardViewControllerResource<Self> { get }
    
    static func instantiate() -> Self
}


extension Storyboarded {
    
    static var storyboard: UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: Bundle.main)
    }
    
    static var viewControllerIdentifier: StoryboardViewControllerResource<Self> {
        return StoryboardViewControllerResource<Self>(identifier: String(describing: type(of: self)))
    }
    
    static func instantiate() -> Self {
        return storyboard.instantiateViewController(withResource: viewControllerIdentifier)!
    }
}
