//
//  SplitVideo+Properties.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension CameraSplitVideoView {
    enum CameraSplitVideoViewLocalizerLayoutStyle: Int {
        case hidden
        case halfLeft
        case halfRight
        case full
    }
}

extension DemoVideoInnerLocalizerView {
    static let kLocalizerInnerLineViewWidth = 1
    static let kLocalizerInnerLineViewHeight = 5
    static let kInnerLocalizerImageViewWidth = 11
}

extension DemoVideoLocalizerView {
    static let kLocalizerOuterLineViewWidth: CGFloat = 1
    static let kLocalizerOuterLineViewMargin: CGFloat = 4
}

extension DemoSplitVideoOperator {
    static let kSplitVideoLocalizerCoordinateDPCode = "ipc_multi_locate_coor" as NSString as ThingSmartCameraDPKey
}
