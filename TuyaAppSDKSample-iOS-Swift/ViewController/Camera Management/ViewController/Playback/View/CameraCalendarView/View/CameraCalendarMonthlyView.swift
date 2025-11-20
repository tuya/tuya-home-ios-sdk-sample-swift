//
//  CameraCalendarMonthlyView.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CameraCalendarMonthlyView: View {
    let month: CameraCalendarMonth
    var playbackDays: [Int]?
    @Binding var selectedDay: Int
    var onTapDay: ((Date) -> Void)?

    var body: some View {
        VStack {
            ForEach(month.days.indices, id: \.self) { index in
                let weekDays = month.days[index]
                HStack(spacing: 0) {
                    ForEach(weekDays) { day in
                        dayCell(for: day)
                    }
                }
            }
            Spacer()
        }
    }
    
    private func dayCell(for day: CameraCalendarDay) -> some View {
        let hasVideo = playbackDays?.contains(day.day) == true
        return VStack {
            if day.day != -1 {
                Text("\(day.day)")
            }
        }
        .frame(width: 40, height: 40)
        .background(hasVideo ? Color.blue : Color.clear)
        .contentShape(Rectangle())
        .border((selectedDay == day.day && hasVideo) ? Color.primary : Color.clear, width: 2)
        .onTapGesture {
            guard hasVideo else { return }
            var components = month.components
            components.day = day.day
            guard let date = Calendar.current.date(from: components) else { return }
            onTapDay?(date)
            selectedDay = day.day
        }
    }
}
