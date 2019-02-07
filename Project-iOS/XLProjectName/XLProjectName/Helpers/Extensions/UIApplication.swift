//
//  UIApplication.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2019 XLOrganizationName. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    static var bundleIdentifier: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static func requestPermissionToShowPushNotification() {
        
        let app = UIApplication.shared

        /**
            Starting in iOS 8, you can optionally create actionable notifications by registering custom actions for
            a notification type. When an actionable notification arrives, the system creates a button for each
            registered action and adds those buttons to the notification interface. 
            These action buttons give the user a quick way to perform tasks related to the notification. 
            For example, a remote notification for a meeting invite might offer actions to accept or decline the meeting.
            When the user taps one of your action buttons, the system notifies your app, giving you an opportunity to
            perform the corresponding task.
        */
        //  If you do not request any interaction types, the system pushes all notifications to your app silently.
        
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        
        /**
        *   The first time an app calls the registerUserNotificationSettings: method, iOS prompts the user to
            allow the specified interactions. On subsequent launches, calling this method does not prompt the user.
            After you call the method, iOS reports the results asynchronously to the
            application:didRegisterUserNotificationSettings: method of your app delegate.
            The first time you register your settings, iOS waits for the user’s response before calling this method,
            but on subsequent calls it returns the existing user settings.
        */
        
        /**
        *   The user can change the notification settings for your app at any time using the Settings app. 
            Because settings can change, always call the registerUserNotificationSettings: at launch time 
            and use the application:didRegisterUserNotificationSettings: method to get the response. 
            If the user disallows specific notification types, avoid using those types when configuring local and 
            remote notifications for your app.
        */

        app.registerUserNotificationSettings(settings)
        app.registerForRemoteNotifications()
    }
}
