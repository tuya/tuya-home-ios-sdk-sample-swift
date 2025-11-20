//
//  Date+Extension.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension Date {
    init(from hmString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current

        if let date = formatter.date(from: hmString) {
            self = date
            return
        }
        self = Date(timeIntervalSince1970: 0)
    }
}

extension Date {
    var hmString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        dateFormat = format
        locale = Locale(identifier: "en_US_POSIX")
        timeZone = .current
    }
}
