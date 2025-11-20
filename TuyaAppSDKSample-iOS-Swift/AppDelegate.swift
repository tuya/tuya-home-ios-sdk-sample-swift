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



        /*
         To run the WidgetKit demo, please complete the following steps:
         1. Add both "TuyaAppSDKSample-iOS-Swift" and "TuyaAppSDKWidgetExtension" targets to the same App Group.
         2. Set the App Group ID in ThingSmartSDK.
        */
        ThingSmartSDK.sharedInstance().appGroupId = "your group id"
        
        ThingSmartSDK.sharedInstance().start(withAppKey: AppKey.appKey, secretKey: AppKey.secretKey)
        
        // ScreenIPC Call Manager, if you have a ipc device with screen. It needs to be called before ThingSmartSDK started.
        DemoCallManager.launchTwowayCallService()
        // Doorbell Observer. If you have a doorbell device
        CameraDoorBellManager.shared.addDoorbellObserver()

        // Set your Matter Group ID
        ThingSmartMatterActivatorConfig.setMatterKey("your_group_id")
        
        // Setup ThingSmartBusinessExtensionKit
        ThingSmartBusinessExtensionConfig.setupConfig()
        
        // Enable debug mode, which allows you to see logs.
        #if DEBUG
        ThingSmartSDK.sharedInstance().debugMode = true
        ThingSmartCameraSDK.sharedInstance.debugMode = true
        #endif
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        
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


    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        //weburl  https://appScheme.applink.smart321.com/share?link=appScheme://share_link?code=MN54PUQQ
        guard let webUrl = userActivity.webpageURL else { return false }

        let params = ["activityType": NSUserActivityTypeBrowsingWeb, "webUrl": webUrl.absoluteString]
        let components = NSURLComponents(string: webUrl.absoluteString)

        guard let items = components?.queryItems else {return false}

        let item = items.first {$0.name == "link"}

        guard let link = item?.value?.removingPercentEncoding else {return false}

        let linkComponents = URLComponents(string: link)
        guard let linkItems = linkComponents?.queryItems, let host = linkComponents?.host else {return false}
        
        if (host == "share_link") {
            let codeItem = linkItems.first {$0.name == "code"}
            if codeItem == nil {return false}
            
            //show share invate to user
            //...
            return true
        }

        //other logic
        return true
    }
}

    // 默认只允许竖屏
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return DemoAppOrientationManager.shared.supportedOrientations
    }
