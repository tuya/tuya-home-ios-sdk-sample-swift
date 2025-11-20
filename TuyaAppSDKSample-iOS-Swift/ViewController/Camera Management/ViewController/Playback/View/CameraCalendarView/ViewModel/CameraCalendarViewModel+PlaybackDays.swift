//
//  CameraCalendarViewModel+PlaybackDays.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

extension CameraCalendarViewModel {
    func fetchPlaybackDaysIfNeed(){
        guard let year = currentMonth.year, let month = currentMonth.month else { return }
        let monthKey = "\(year)-\(month)"
        guard playbackDays[monthKey] == nil else { return }
        cameraDevice?.queryRecordDays(year: UInt(year), month: UInt(month))
    }
    
    func savePlaybackDays(_ days: [Int]) {
        guard let monthKey = currentMonth.monthKey else { return }
        playbackDays[monthKey] = days
    }
}
