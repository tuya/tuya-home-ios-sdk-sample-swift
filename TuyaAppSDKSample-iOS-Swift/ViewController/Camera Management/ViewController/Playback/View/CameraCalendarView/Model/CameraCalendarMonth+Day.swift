//
//  CameraCalendarMonth+Day.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

struct CameraCalendarDay: Identifiable {
    var id: String { UUID().uuidString }

    let date: Date
    let day: Int
    var hasVideo: Bool = false
}

struct CameraCalendarMonth {
    let components: DateComponents
    var days: [[CameraCalendarDay]]

    var title: String {
        guard let year = components.year, let month = components.month else { return "" }
        return String(format: "%04d-%02d", year, month)
    }
}

extension CameraCalendarMonth {
    static let weekDayTitles = [
        NSLocalizedString("pps_day_sun", tableName: "IPCLocalizable"),
        NSLocalizedString("pps_day_mon", tableName: "IPCLocalizable"),
        NSLocalizedString("pps_day_tue", tableName: "IPCLocalizable"),
        NSLocalizedString("pps_day_wed", tableName: "IPCLocalizable"),
        NSLocalizedString("pps_day_thu", tableName: "IPCLocalizable"),
        NSLocalizedString("pps_day_fri", tableName: "IPCLocalizable"),
        NSLocalizedString("pps_day_sat", tableName: "IPCLocalizable")
    ]
}

extension DateComponents {
    var monthKey: String? {
        guard let year = self.year, let month = self.month else { return nil }
        return "\(year)-\(month)"
    }
}
