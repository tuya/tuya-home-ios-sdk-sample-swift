//
//  DemoSplitVideoInfo.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoSplitVideoInfo: thing_ipc_split_video_info {
    private(set) var isLocalizer: Bool = false
    private(set) var isFirstIndex: Bool = false

    init(video_info: thing_ipc_split_video_info, isLocalizer: Bool, isFirstIndex: Bool) {
        super.init()
        index = video_info.index
        type = video_info.type
        res_pos = video_info.res_pos
        self.isLocalizer = isLocalizer
        self.isFirstIndex = isFirstIndex
    }
}
