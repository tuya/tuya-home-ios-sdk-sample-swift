//
//  UIButtonExtension.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import UIKit

extension UIButton {
    func roundCorner(radius: CGFloat = 5) {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
}
