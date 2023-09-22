//
//  CustomMenuModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

import UIKit

class CustomMenuModel: NSObject {
    var title: String
    var detail: String
    
    init(title: String, detail: String) {
        self.title = title
        self.detail = detail
    }
}
