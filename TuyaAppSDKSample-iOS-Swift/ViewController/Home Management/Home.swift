//
//  Home.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import TuyaSmartDeviceKit

struct Home {
    static var current: TuyaSmartHomeModel? {
        get {
            let defaults = UserDefaults.standard
            guard let homeID = defaults.string(forKey: "CurrentHome") else { return nil }
            guard let id = Int64(homeID)  else { return nil }
            return TuyaSmartHome.init(homeId: id)?.homeModel
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue?.homeId, forKey: "CurrentHome")
        }
    }
}
