//
//  CameraPTZControlDirection.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

enum CameraPTZControlDirection: CaseIterable {
    case up
    case down
    case left
    case right

    var ptzDirection: ThingSmartPTZControlDirection {
        switch self {
        case .up:    .up
        case .down:  .down
        case .left:  .left
        case .right: .right
        }
    }

    var arc: Arc {
        switch self {
        case .up:
            Arc(startAngle: .degrees(180 + 45), endAngle: .degrees(270 + 45))
        case .down:
            Arc(startAngle: .degrees(0 + 45), endAngle: .degrees(90 + 45))
        case .left:
            Arc(startAngle: .degrees(90 + 45), endAngle: .degrees(180 + 45))
        case .right:
            Arc(startAngle: .degrees(270 + 45), endAngle: .degrees(45))
        }
    }
}

extension CameraPTZControlDirection {
    struct Arc {
        var startAngle: Angle
        var endAngle: Angle
    }
}
