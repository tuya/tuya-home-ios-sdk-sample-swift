//
//  DeviceControlCell.swift
//  ThingAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

import Foundation
import ThingSmartDeviceKit

enum DeviceControlCell: String {
    case switchCell   = "device-switch-cell"
    case sliderCell   = "device-slider-cell"
    case enumCell     = "device-enum-cell"
    case stringCell   = "device-string-cell"
    case labelCell    = "device-label-cell"
    case textviewCell = "device-textview-cell"
    
    static func cellIdentifier(with typeStr: String?) -> Self {
        switch typeStr{
        case "bool":
            return .switchCell
        case "enum":
            return .enumCell
        case "value":
            return .sliderCell
        case "bitmap":
            return .labelCell
        case "string":
            return .stringCell
        case "raw":
            return .stringCell
        case "array":
            return .textviewCell
        case "struct":
            return .textviewCell
        default:
            return .labelCell
        }
    }
    
    static func cellIdentifier(with schema: ThingSmartSchemaModel) -> Self {
        let type = schema.type == "obj" ? schema.property.type : schema.type
        return cellIdentifier(with: type)
    }
}
