//
//  CameraDeviceModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

struct CameraDeviceModel {
    var connectState: CameraDeviceConnectState?
    var previewState: CameraDevicePreviewState?
    var playbackState: CameraDevicePlaybackState?
    var videoTalkState, videoCaptureState, audioCaptureState: CameraDeviceTaskState?

    var isPlaybackPaused: Bool = false
    var isVideoTalkPaused: Bool = false
    var isMuteLoading: Bool = false
    var mutedForPreview: Bool = false
    var mutedForPlayback: Bool = true

    var isOnPreviewMode: Bool { previewState != .idle }

    var isTalkLoading: Bool = false
    var isTalking: Bool = false

    var isRecordLoading: Bool = false
    var isRecording: Bool = false

    var isDownloading: Bool = false

    var isHD: Bool = false

    /// device is support speaker
    var isSupportSpeaker: Bool = false

    /// device is support sound pickup
    var isSupportPickup: Bool = false

    /// if device support both speaker and sound pickup, device support both one-way talk and two-way talk, so it could change the talkback mode.
    var couldChangeTalkbackMode: Bool = false
    
    /// default talkback mode, configured in Thing backend.
    var defaultTalkbackMode: ThingSmartCameraTalkbackMode?

    /// default definition of live video, configured in Thing backend.
    var defaultDefinition: ThingSmartCameraDefinition?

    /// original config data
    var configInfoData: [AnyHashable: Any]?

    var isSupportNewRecordEvent: Bool {
        guard let configInfoData,
              let stringValue = configInfoData["skill"] as? String,
              let skills = stringValue.p_objectFromJSONString() as? [String: Any],
              let localStorage = skills["localStorage"] as? UInt else {
            return false
        }
        return (localStorage & (1 << 25)) != 0
    }

    mutating func resetCameraAbility(_ cameraAbility: ThingSmartCameraAbility) {
        isSupportSpeaker = cameraAbility.isSupportSpeaker
        isSupportPickup = cameraAbility.isSupportPickup
        defaultTalkbackMode = cameraAbility.defaultTalkbackMode
        couldChangeTalkbackMode = cameraAbility.couldChangeTalkbackMode
        defaultDefinition = cameraAbility.defaultDefinition
        configInfoData = cameraAbility.rowData
    }
}

extension CameraDeviceModel {
    enum CameraDeviceConnectState: Int {
        case disconnected
        case connecting
        case failed
        case busy
        case connected
    }

    enum CameraDevicePreviewState: Int {
        case idle
        case loading
        case previewing
        case failed
    }

    enum CameraDeviceTaskState: Int {
        case idle
        case executing
        case completed
        case failed
    }

    enum CameraDevicePlaybackState: Int {
        case idle
        case dayLoading
        case timeLineLoading
        case loading
        case playbacking
        case failed
    }
}
