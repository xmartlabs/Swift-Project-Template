//
//  LoadingIndicator.swift
//  XLProjectName
//
//  Created by Diego Ernst on 9/2/16.
//  Copyright © 2016 'XLOrganizationName'. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import UIKit

class LoadingIndicator {

    static let size = CGSize(width: 30, height: 30)
    static let type = NVActivityIndicatorType.BallPulse
    static let color = UIColor.whiteColor()
    static let minimumVisibleTime = NSTimeInterval(0.2)
    static let displayTimeThreshold = NSTimeInterval(0.1)

    static func show(
        message message: String? = nil,
        minimumVisibleTime: NSTimeInterval = LoadingIndicator.minimumVisibleTime,
        displayTimeThreshold: NSTimeInterval = LoadingIndicator.displayTimeThreshold) {

        LoadingIndicatorManager.sharedInstance.show(message: message, minimumVisibleTime: minimumVisibleTime, displayTimeThreshold: displayTimeThreshold)
    }

    static func hide() {
        LoadingIndicatorManager.sharedInstance.hide()
    }

}
