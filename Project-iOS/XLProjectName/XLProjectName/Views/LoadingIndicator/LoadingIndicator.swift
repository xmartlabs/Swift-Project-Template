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
    static let type = NVActivityIndicatorType.ballPulse
    static let color = UIColor.white
    static let minimumVisibleTime = TimeInterval(0.2)
    static let displayTimeThreshold = TimeInterval(0.1)

    static func show(
        message: String? = nil,
        minimumVisibleTime: TimeInterval = LoadingIndicator.minimumVisibleTime,
        displayTimeThreshold: TimeInterval = LoadingIndicator.displayTimeThreshold) {

        LoadingIndicatorManager.sharedInstance.show(message: message, minimumVisibleTime: minimumVisibleTime, displayTimeThreshold: displayTimeThreshold)
    }

    static func hide() {
        LoadingIndicatorManager.sharedInstance.hide()
    }

}
