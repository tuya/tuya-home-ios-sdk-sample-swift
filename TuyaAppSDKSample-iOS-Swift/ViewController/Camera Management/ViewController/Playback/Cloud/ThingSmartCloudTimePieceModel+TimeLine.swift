//
//  ThingSmartCloudTimePieceModel+TimeLine.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingCameraUIKit

extension ThingSmartCloudTimePieceModel: @retroactive ThingTimelineViewSource {
    public func startTimeInterval(since date: Date!) -> TimeInterval {
        startDate.timeIntervalSince(date)
    }

    public func stopTimeInterval(since date: Date!) -> TimeInterval {
        endDate.timeIntervalSince(date)
    }

    func contains(_ time: Int) -> Bool {
        time >= startTime && time <= endTime
    }
}
