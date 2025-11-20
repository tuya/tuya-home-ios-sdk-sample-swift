//
//  CameraCruiseMode.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

protocol RawPresentable {
    var title: String { get }
}

enum CameraCruiseMode: CaseIterable, Identifiable, RawPresentable {
    case panoramic
    case collectionPoint

    var id: UInt { mode.rawValue }

    var mode: ThingSmartPTZControlCruiseMode {
        switch self {
        case .panoramic:
            return .panoramic
        case .collectionPoint:
            return .collectionPoint
        }
    }

    var title: String {
        switch self {
        case .panoramic:
            IPCLocalizedString(key: "Panoramic")
        case .collectionPoint:
            IPCLocalizedString(key: "Collection Points")
        }
    }
}

enum CameraCruiseTimeMode: CaseIterable, Identifiable, RawPresentable {
    case custom
    case allDay

    var id: UInt { mode.rawValue }

    var mode: ThingSmartPTZControlCruiseTimeMode {
        switch self {
        case .custom:
            return .custom
        case .allDay:
            return .allDay
        }
    }

    var title: String {
        switch self {
        case .custom:
            IPCLocalizedString(key: "Custom Time")
        case .allDay:
            IPCLocalizedString(key: "All Day")
        }
    }
}

struct CameraCruiseSettingItem: Hashable {
    var cruiseMode: CameraCruiseMode
    var cruiseTimeMode: CameraCruiseTimeMode
    var startTime: String
    var endTime: String

    static var `default`: Self {
        .init(
            cruiseMode: .panoramic,
            cruiseTimeMode: .custom,
            startTime: Date().hmString,
            endTime: Date().hmString
        )
    }
}
