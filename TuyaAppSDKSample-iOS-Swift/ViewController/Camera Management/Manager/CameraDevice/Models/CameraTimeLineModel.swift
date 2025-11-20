//
//  CameraTimeLineModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import ThingCameraUIKit

class CameraTimeLineModel: NSObject, Codable {
    var startTime: Int?
    var stopTime: Int?

    var startDate: Date? {
        guard let startTime else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(startTime))
    }

    var stopDate: Date? {
        guard let stopTime else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(stopTime))
    }

    override var description: String {
        "<CameraTimeLineModel: startTime = \(String(describing: startTime)), stopTime = \(String(describing: stopTime))>"
    }

    private enum CodingKeys: String, CodingKey {
        case startTime
        case stopTime = "endTime"
    }
}

extension CameraTimeLineModel {
    func containsPlayTime(_ playTime: Int) -> Bool {
        if let startTime, let stopTime {
            return playTime >= startTime && playTime < stopTime
        }
        return false
    }
}

extension CameraTimeLineModel: ThingTimelineViewSource {
    func startTimeInterval(since date: Date!) -> TimeInterval {
        guard let startDate else { return 0 }
        return startDate.timeIntervalSince(date)
    }

    func stopTimeInterval(since date: Date!) -> TimeInterval {
        guard let stopDate else { return 0 }
        return stopDate.timeIntervalSince(date)
    }
}
