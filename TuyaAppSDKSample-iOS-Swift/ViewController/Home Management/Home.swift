//
//  Home.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartDeviceKit

struct Home {
    static var current: ThingSmartHomeModel? {
        get {
            let defaults = UserDefaults.standard
            guard let homeID = defaults.string(forKey: "CurrentHome") else { return nil }
            guard let id = Int64(homeID)  else { return nil }
            return ThingSmartHome.init(homeId: id)?.homeModel
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue?.homeId, forKey: "CurrentHome")
        }
    }
}
