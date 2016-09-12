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
    let minimumVisibleTime: NSTimeInterval
    let displayTimeThreshold: NSTimeInterval

    init(message: String?, minimumVisibleTime: NSTimeInterval, displayTimeThreshold: NSTimeInterval) {
        self.message = message
        self.minimumVisibleTime = minimumVisibleTime
        self.displayTimeThreshold = displayTimeThreshold
    }

}

class PresenterViewController: UIViewController, NVActivityIndicatorViewable { }

class LoadingIndicatorManager {

    static let sharedInstance = LoadingIndicatorManager()

    private let presenter = PresenterViewController()
    private var showActivityTimer: NSTimer?
    private var hideActivityTimer: NSTimer?
    private var userWantsToStopActivity = false

    private init() { }

    func show(message message: String? = nil, minimumVisibleTime: NSTimeInterval, displayTimeThreshold: NSTimeInterval) {
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

    @objc func hideActivityTimerFired(timer: NSTimer) {
        hideActivityTimer?.invalidate()
        hideActivityTimer = nil
        if userWantsToStopActivity {
            hideActivity()
        }
    }

    @objc func showActivityTimerFired(timer: NSTimer) {
        guard let activityData = timer.userInfo as? ActivityData else { return }
        showActivity(activityData)
    }

    // MARK: - Helpers

    private func showActivity(data: ActivityData) {
        presenter.startActivityAnimating(LoadingIndicator.size, message: data.message, type: LoadingIndicator.type, color: LoadingIndicator.color, padding: nil)
        hideActivityTimer = scheduleTimer(data.minimumVisibleTime, selector: #selector(LoadingIndicatorManager.hideActivityTimerFired(_:)), data: nil)
    }

    private func hideActivity() {
        presenter.stopActivityAnimating()
        showActivityTimer?.invalidate()
        showActivityTimer = nil
    }

    private func scheduleTimer(timeInterval: NSTimeInterval, selector: Selector, data: ActivityData?) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: selector, userInfo: data, repeats: false)
    }

}
