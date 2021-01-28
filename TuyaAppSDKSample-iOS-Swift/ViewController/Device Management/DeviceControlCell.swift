//
//  DeviceControlCell.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import TuyaSmartDeviceKit

enum DeviceControlCell: String {
    case switchCell = "device-switch-cell"
    case sliderCell = "device-slider-cell"
    case enumCell = "device-enum-cell"
    case stringCell = "device-string-cell"
    case labelCell = "device-label-cell"
    
    static func cellIdentifier(with schema: TuyaSmartSchemaModel) -> Self {
        let type = schema.type == "obj" ? schema.property.type : schema.type
        
        switch type {
        case "bool":
            return Self.switchCell
        case "enum":
            return Self.enumCell
        case "value":
            return Self.sliderCell
        case "bitmap":
            return Self.labelCell
        case "string":
            return Self.stringCell
        case "raw":
            return Self.stringCell
        default:
            return Self.labelCell
        }
    }
}
