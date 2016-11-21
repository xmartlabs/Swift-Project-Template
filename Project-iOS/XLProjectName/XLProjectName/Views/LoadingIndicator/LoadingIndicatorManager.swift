//
//  LoadingIndicatorManager.swift
//  XLProjectName
//
//  Created by Diego Ernst on 9/2/16.
//  Copyright © 2016 'XLOrganizationName'. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import UIKit

class ActivityData {

    let message: String?
    let minimumVisibleTime: TimeInterval
    let displayTimeThreshold: TimeInterval

    init(message: String?, minimumVisibleTime: TimeInterval, displayTimeThreshold: TimeInterval) {
        self.message = message
        self.minimumVisibleTime = minimumVisibleTime
        self.displayTimeThreshold = displayTimeThreshold
    }

}

class PresenterViewController: UIViewController, NVActivityIndicatorViewable { }

class LoadingIndicatorManager {

    static let sharedInstance = LoadingIndicatorManager()

    fileprivate let presenter = PresenterViewController()
    fileprivate var showActivityTimer: Timer?
    fileprivate var hideActivityTimer: Timer?
    fileprivate var userWantsToStopActivity = false

    fileprivate init() { }

    func show(message: String? = nil, minimumVisibleTime: TimeInterval, displayTimeThreshold: TimeInterval) {
        let data = ActivityData(message: message, minimumVisibleTime: minimumVisibleTime, displayTimeThreshold: displayTimeThreshold)
        guard showActivityTimer == nil else { return }
        userWantsToStopActivity = false
        showActivityTimer = scheduleTimer(data.displayTimeThreshold, selector: #selector(LoadingIndicatorManager.showActivityTimerFired(_:)), data: data)
    }

    func hide() {
        userWantsToStopActivity = true
        guard hideActivityTimer == nil else { return }
        hideActivity()
    }

    // MARK: - Timer events

    @objc func hideActivityTimerFired(_ timer: Timer) {
        hideActivityTimer?.invalidate()
        hideActivityTimer = nil
        if userWantsToStopActivity {
            hideActivity()
        }
    }

    @objc func showActivityTimerFired(_ timer: Timer) {
        guard let activityData = timer.userInfo as? ActivityData else { return }
        showActivity(activityData)
    }

    // MARK: - Helpers

    fileprivate func showActivity(_ data: ActivityData) {
        presenter.startAnimating(LoadingIndicator.size, message: data.message, type: LoadingIndicator.type, color: LoadingIndicator.color, padding: nil)
        hideActivityTimer = scheduleTimer(data.minimumVisibleTime, selector: #selector(LoadingIndicatorManager.hideActivityTimerFired(_:)), data: nil)
    }

    fileprivate func hideActivity() {
        presenter.stopAnimating()
        showActivityTimer?.invalidate()
        showActivityTimer = nil
    }

    fileprivate func scheduleTimer(_ timeInterval: TimeInterval, selector: Selector, data: ActivityData?) -> Timer {
        return Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: selector, userInfo: data, repeats: false)
    }

}
