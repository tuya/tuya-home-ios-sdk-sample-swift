//
//  DemoSplitVideoViewContext.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

class DemoSplitVideoViewContext: DemoSplitVideoViewContextProtocol {
    weak var videoOperator: DemoSplitVideoOperatorProtocol?

    weak var viewSizeCounter: DemoSplitVideoViewSizeCounterProtocol?

    init(videoOperator: DemoSplitVideoOperatorProtocol, viewSizeCounter: DemoSplitVideoViewSizeCounterProtocol) {
        self.videoOperator = videoOperator
        self.viewSizeCounter = viewSizeCounter
    }
}
