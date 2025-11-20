//
//  CameraDeviceOutlineProperty.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

struct CameraDeviceOutlineProperty: Encodable {
    //0 表示之前版本的框, 1表示越线警告框
    //0 means object outline, 1 means out of bounds
    var type: Int?

    // 框的索引
    // index
    var index: Int?

    // RGB值
    // color RGB value
    var rgb: Double?

    // 框形状
    // shape
    var shape: CameraDeviceOutlineShapeStyle?

    // 宽度
    // width
    var brushWidth: CameraDeviceOutlineWidth?

    // 闪动频率
    // flash FPS
    var flashFps: CameraDeviceOutlineFlashFps?

    enum CameraDeviceOutlineWidth: Int, Encodable {
        case thin
        case middle
        case wide
        case illegal = 100
    }

    enum CameraDeviceOutlineShapeStyle: Int, Encodable {
        case full
        case horn
        case illegal = 100
    }
}

// 闪动频率
// flash FPS
struct CameraDeviceOutlineFlashFps: Encodable {
    //画几帧
    //draw frames interval
    var drawKeepFrames: CameraDeviceOutlineFlashType?

    //停几帧
    //stop draw frames interval
    var stopKeepFrames: CameraDeviceOutlineFlashType?

    enum CameraDeviceOutlineFlashType: Int, Encodable {
        case notAllow
        case fast
        case middle
        case slow
        case illegal = 100
    }
}
