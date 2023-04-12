//
//  SceneDelegate.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit
import ThingSmartBaseKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            
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
    }
}

