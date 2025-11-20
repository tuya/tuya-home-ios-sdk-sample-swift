//
//  DemoVideoViewIndexPair.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoVideoViewIndexPair: NSObject, ThingSmartVideoViewIndexPair {
    var videoIndex: UInt

    var videoView: any UIView & ThingSmartVideoViewType

    init(videoView: UIView & ThingSmartVideoViewType, videoIndex: ThingSmartVideoIndex) {
        self.videoView = videoView
        self.videoIndex = videoIndex
    }

}
