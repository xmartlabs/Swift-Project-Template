//
//  AppDelegate.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright (c) 2016 XLOrganizationName. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import RxSwift
//import Intercom

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var disposeBag = DisposeBag()
    
    /// true if app was able to get pushn notification token
    static var didRegisteredPush = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setupCrashlytics()
        
        
        // Register the supported push notifications interaction types.
        // Shows alert view askying for allowed push notification types
        // you can move this line to a more suitable point in the app.
        UIApplication.requestPermissionToShowPushNotification()
        // Register for remote notifications. Must be called after registering for supported push notifications interaction types.
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. 
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    
    func setupCrashlytics() {
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = Constants.Debug.crashlytics
    }
    
}

extension AppDelegate {
    
    // MARK: Requesting A Device Token
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        // notificationSettings.types
        // notificationSettings.categories
    }
    
    /**
      Receives the device token needed to deliver remote notifications. Device tokens can change, so your app needs to 
     reregister every time it is launched and pass the received token back to your server.
     Device tokens always change when the user restores backup data to a new device or computer 
     or reinstalls the operating system.
     */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // pass device token to Intercom
        //Intercom.setDeviceToken(deviceToken)
        let deviceTokenStr = "\(deviceToken)"
        Route.Device.Update(token: deviceTokenStr).rx_anyObject().subscribe().addDisposableTo(disposeBag)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        /**
            you should process the error object appropriately and disable any features related to remote notifications. 
            Because notifications are not going to be arriving anyway, it is usually better to degrade gracefully and
            avoid any unnecessary work needed to process or display those notifications.
        */
        Crashlytics.sharedInstance().recordError(error)
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        
        if application.applicationState == .Active {
//            AppDelegate.showNotificationInForeground(userInfo)
//            IntercomHelper.sharedInstance.fetchUnreadConversationsCount()
        } else if application.applicationState == .Background || application.applicationState == .Inactive {
//            if let url = userInfo["navigationUrl"] as? String {
//                AppDelegate.pendingNotificationURL = NSURL(string: url)
//                AppDelegate.router.handleURL(AppDelegate.pendingNotificationURL, withCompletion: nil)
//            }
        }
        // otherwise do nothing, it should be managed by didFinishLaunchingWithOptions.
    }

    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
    }
}
