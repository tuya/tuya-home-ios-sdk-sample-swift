//
//  Alert.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit

struct Alert {
    static func showBasicAlert(on vc: UIViewController, with title: String, message: String, actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)]) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alertVC.addAction(action)
        }
        
        DispatchQueue.main.async {
            vc.present(alertVC, animated: true)
        }
    }
}
