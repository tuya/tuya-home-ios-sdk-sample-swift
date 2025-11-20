//
//  CameraDeviceTask.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

struct CameraDeviceTask {
    var isRunning: Bool = false
    let taskEvent: CameraDeviceTaskEvent

    enum CameraDeviceTaskEvent: Int {
        case startPreview
        case stopPreview
    }

}
