//
//  UIApplication.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 XLOrganizationName. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UIApplication {
    
    static var applicationVersionNumber: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static var applicationBuildNumber: String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }
    
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier!
    }
    
    static func requestPermissionToShowPushNotification() {
        
        let app = UIApplication.shared

     
        
        
        
        /*  The first time your app makes this authorization request, the system prompts the user to grant or deny the request and records the user’s response. Subsequent authorization requests don't prompt the user. */
        let unCenter = UNUserNotificationCenter.current()
        unCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            //Parse errors and track state
        }
        
        
        
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

        //app.registerUserNotificationSettings(settings)
        app.registerForRemoteNotifications()
    }
}
