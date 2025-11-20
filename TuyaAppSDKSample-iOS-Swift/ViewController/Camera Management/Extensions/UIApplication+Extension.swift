//
//  UIApplication+Extension.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension UIApplication {
    var tp_navigationController: UINavigationController? {
        tp_topMostViewController?.navigationController
    }
    
    var tp_topMostViewController: UIViewController? {
        tp_mainWindow()?.rootViewController?.tp_topViewController
    }

    func tp_mainWindow() -> UIWindow? {
        var mainWindow: UIWindow?
        if #available(iOS 13.0, *) {
            mainWindow = UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive && $0 is UIWindowScene }
                .flatMap { $0 as? UIWindowScene }?.windows
                .first { $0.isKeyWindow }
        }
        if mainWindow == nil {
            mainWindow = UIApplication.shared.windows.first(where: \.isKeyWindow)
        }
        return mainWindow
    }
}

extension UIViewController {
    fileprivate var tp_topViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.tp_topViewController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.tp_topViewController
        }

        if let presentedViewController = self.presentedViewController {
            return presentedViewController.tp_topViewController
        }

        return self
    }
}
