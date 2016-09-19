//
//  AppDelegate+XLProjectName.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Fabric
import Alamofire
import Eureka
import Crashlytics

extension AppDelegate {

    func setupCrashlytics() {
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = Constants.Debug.crashlytics
    }

    // MARK: Alamofire notifications
    func setupNetworking() {
        NotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(AppDelegate.requestDidComplete(_:)),
            name: Alamofire.Notifications.Task.DidComplete,
            object: nil)
    }

    func requestDidComplete(_ notification: Notification) {
        guard let task = notification.object as? URLSessionTask, let response = task.response as? HTTPURLResponse else {
            DEBUGLog("Request object not a task")
            return
        }
        if Constants.Network.successRange ~= response.statusCode {
            if let token = response.allHeaderFields["Set-Cookie"] as? String {
                SessionController.sharedInstance.token = token
            }
        } else if response.statusCode == Constants.Network.Unauthorized && SessionController.sharedInstance.isLoggedIn() {
            SessionController.sharedInstance.clearSession()
            // here you should implement AutoLogout: Transition to login screen and show an appropiate message
        }
    }

    /**
     Set up your Eureka default row customization here
     */
    func stylizeEurekaRows() {

        let genericHorizontalMargin = CGFloat(50)
        BaseRow.estimatedRowHeight = 58

        EmailRow.defaultRowInitializer = {
            $0.placeholder = NSLocalizedString("E-mail Address", comment: "")
            $0.placeholderColor = .grayColor()
        }

        EmailRow.defaultCellSetup = { cell, _ in
            cell.layoutMargins = UIEdgeInsetsZero
            cell.contentView.layoutMargins.left = genericHorizontalMargin
            cell.height = { 58 }
        }
    }
}
