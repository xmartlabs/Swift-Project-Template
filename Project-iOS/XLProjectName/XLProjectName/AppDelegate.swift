//
//  AppDelegate.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import UIKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /// true if app was able to get pushn notification token
    static var didRegisteredPush = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupCrashlytics()
        setupNetworking()
        stylizeEurekaRows()
        
        // Register the supported push notifications interaction types.
        // Shows alert view askying for allowed push notification types
        // you can move this line to a more suitable point in the app.
        UIApplication.requestPermissionToShowPushNotification()
        // Register for remote notifications. Must be called after registering for supported push notifications interaction types.
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. 
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate {
    
    // MARK: Requesting A Device Token
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        // notificationSettings.types
        // notificationSettings.categories
    }
    
    /**
      Receives the device token needed to deliver remote notifications. Device tokens can change, so your app needs to 
     reregister every time it is launched and pass the received token back to your server.
     Device tokens always change when the user restores backup data to a new device or computer 
     or reinstalls the operating system.
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // pass device token to Intercom
        //Intercom.setDeviceToken(deviceToken)
//        let deviceTokenStr = "\(deviceToken)"
//        Route.Device.Update(token: deviceTokenStr).request.resume()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        /**
            you should process the error object appropriately and disable any features related to remote notifications. 
            Because notifications are not going to be arriving anyway, it is usually better to degrade gracefully and
            avoid any unnecessary work needed to process or display those notifications.
        */
        Crashlytics.sharedInstance().recordError(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        if application.applicationState == .active {
//            AppDelegate.showNotificationInForeground(userInfo)
//            IntercomHelper.sharedInstance.fetchUnreadConversationsCount()
        } else if application.applicationState == .background || application.applicationState == .inactive {
//            if let url = userInfo["navigationUrl"] as? String {
//                AppDelegate.pendingNotificationURL = NSURL(string: url)
//                AppDelegate.router.handleURL(AppDelegate.pendingNotificationURL, withCompletion: nil)
//            }
        }
        // otherwise do nothing, it should be managed by didFinishLaunchingWithOptions.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
}
