//
//  AppDelegate.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBaseKit
import ThingSmartMatterKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize ThingSmartSDK
        ThingSmartSDK.sharedInstance().start(withAppKey: AppKey.appKey, secretKey: AppKey.secretKey)
        
        // Set your Matter Group ID
        ThingSmartMatterActivatorConfig.setMatterKey("your_group_id")
        
        // Setup ThingSmartBusinessExtensionKit
        ThingSmartBusinessExtensionConfig.setupConfig()
        
        // Enable debug mode, which allows you to see logs.
        #if DEBUG
        ThingSmartSDK.sharedInstance().debugMode = true
        #endif
        
        SVProgressHUD.setDefaultStyle(.dark)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if #available(iOS 13.0, *) {
            // Will go into scene delegate
        } else {
            if ThingSmartUser.sharedInstance().isLogin {
                // User has already logged, launch the app with the main view controller.
                let storyboard = UIStoryboard(name: "ThingSmartMain", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
            } else {
                // There's no user logged, launch the app with the login and register view controller.
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
            }
        }
        
        // load last current family info
        ThingSmartFamilyBiz.sharedInstance().launchCurrentFamily(withAppGroupName: nil)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

