//
//  CameraControlButtonItem.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

struct CameraControlButtonItem: Codable {
    let imagePath: String?
    let title: String?
    let identifier: ControlConstants?
    private var hidden: Int

    var isEnabled: Bool = false

    var isHidden: Bool {
        get {
            hidden == 1 ? true : false
        } set {
            hidden = newValue ? 1 : 0
        }
    }

    private enum CodingKeys: CodingKey {
        case imagePath
        case title
        case identifier
        case hidden
    }
}

extension CameraControlButtonItem {
    enum ControlConstants: String, Codable {
        case kControlTalk       = "talk"
        case kControlVideoTalk  = "videoTalk"
        case kControlRecord     = "record"
        case kControlPhoto      = "photo"
        case kControlPlayback   = "playback"
        case kControlCloud      = "Cloud"
        case kControlMessage    = "message"
        case kControlCloudDebug = "CloudDebug"
    }
}
