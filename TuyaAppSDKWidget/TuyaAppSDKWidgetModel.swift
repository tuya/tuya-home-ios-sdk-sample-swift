//
//  TuyaAppSDKWidgetModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import AppIntents
import UIKit

struct TuyaAppSDKWidgetModel {
    let name : String
    let image : UIImage?
    let isOnline : Bool
    let switchStatus : Bool? // quick switch value
    let devId: String
}
