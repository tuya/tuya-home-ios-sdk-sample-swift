//
//  CameraCalendarViewModel.swift
//  TuyaAppSDKSample-iOS-Swift
//
//  Copyright (c) 2014-2025 Tuya Inc. (https://developer.tuya.com/)

import Combine

class CameraCalendarViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var months: [CameraCalendarMonth] = []
    @Published var playbackDays:[String: [Int]] = [:] // ["1234-5": [1,2,3,4,5]]
    @Published var selectedDay: Int = -1
    @Published var selection: Int = 2
    @Published var animate: Bool = false

    weak var cameraDevice: CameraDevice?
    var onSelectDay: ((Date) -> Void)?
    var onSelectMonth: ((_ year: Int, _ month: Int) -> Void)?

    var currentMonth: DateComponents {
        monthForDate(currentDate)
    }

    private let calendar: Calendar = .current
    private var initialDate: DateComponents
    private var subscription: AnyCancellable?
    private var cachedMonth: [String: CameraCalendarMonth] = [:]

    private var currentDate = Date() {
        didSet {
            title = month(for: currentDate).title
            fetchPlaybackDaysIfNeed()
            let month = currentMonth
            if let year = month.year, let month = month.month {
                onSelectMonth?(year, month)
            }
        }
    }

    enum Direction {
        case prev
        case next
    }

    init() {
        initialDate = calendar.dateComponents([.year, .month], from: Date())
        setCalendar(by: currentDate)
        observeSelection()
    }

    deinit {
        print("----- canlendar viewModel deinit")
    }

    func jumpToMonth(for direction: Direction) {
        guard !animate else { return }
        if (selection == 2 && direction == .next) || (selection == 0 && direction == .prev) { return }
        animate = true
        selection += direction == .next ? 1 : -1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.animate = false
        }
    }

    // set the first page's month
    func setCalendar(by date: Date) {
        currentDate = date

        if !isSame(monthForDate(date), initialDate) {
            months = [
                month(for: dateForPrevMonth(date)),
                month(for: currentDate),
                month(for: dateForNextMonth(date))
            ]
            selection = 1
            return
        }

        months = [
            month(for: date),
            month(for: dateForPrevMonth(date)),
            month(for: dateForPrevMonth(dateForPrevMonth(date)))
        ].reversed()
    }

    func onDisAppera() {
        currentDate = Date()
    }

    private func observeSelection() {
        subscription = $selection
            .receive(on: RunLoop.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self else { return }
                print("------ newValue: ", newValue)

                // 当前显示的日期是系统当前日期, 此时只能滑动到 selection == 1
                if isSame(monthForDate(currentDate), initialDate) {
                    currentDate = dateForPrevMonth(currentDate)
                    return
                }

                if selection == 0 { // 滑到当前日期的之前
                    resetToCircular(for: .prev)
                    return
                }

                if selection == 2 { // 滑到当前日期之后，需要同时判断是否到达末尾
                    if isSame(monthForDate(dateForNextMonth(currentDate)), initialDate) {
                        currentDate = dateForNextMonth(currentDate)
                    } else {
                        resetToCircular(for: .next)
                    }
                }
            }
    }

    private func resetToCircular(for direction: Direction) {
        let delay: TimeInterval = animate ? 0.35 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.updateMonth(for: direction)
            self.selection = 1
        }
    }

    private func updateMonth(for direction: Direction) {
        let newDate = direction == .prev ? dateForPrevMonth(currentDate) : dateForNextMonth(currentDate)
        currentDate = newDate

        if direction == .prev {
            months = [
                month(for: dateForPrevMonth(newDate)),
                month(for: newDate),
                month(for: dateForNextMonth(newDate))
            ]
            return
        }

        let nextMonth = month(for: dateForNextMonth(newDate))
        let prevMonth = month(for: dateForPrevMonth(newDate))
        let currMonth = month(for: newDate)
        months = isSame(currMonth.components, initialDate)
            ? [month(for: dateForPrevMonth(dateForPrevMonth(newDate))), prevMonth, currMonth]
            : [prevMonth, currMonth, nextMonth]
    }

    private func monthForDate(_ date: Date) -> DateComponents {
        calendar.dateComponents([.year, .month], from: date)
    }

    private func month(for date: Date) -> CameraCalendarMonth {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components), let monthKey = components.monthKey else {
            fatalError("Invalid date")
        }

        if let month = cachedMonth[monthKey] {
            return month
        }

        let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        let weekdayOffset = calendar.component(.weekday, from: startOfMonth) - calendar.firstWeekday

        var days: [CameraCalendarDay] = []
        range?.forEach { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return }
            days.append(CameraCalendarDay(date: date, day: day))
        }

        let weeks = generateWeeks(days, byOffset: weekdayOffset)
        let month = CameraCalendarMonth(components: components, days: weeks)
        cachedMonth[monthKey] = month
        return month
    }

    private func dateForPrevMonth(_ date: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: date)!
    }

    private func dateForNextMonth(_ date: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: date)!
    }

    // 构造日历二维网格数组
    private func generateWeeks(_ days: [CameraCalendarDay], byOffset weekdayOffset: Int) -> [[CameraCalendarDay]] {
        var weeks:[[CameraCalendarDay]] = []
        var currentWeek: [CameraCalendarDay] = Array(
            repeating: CameraCalendarDay(date: Date.distantPast, day: -1),
            count: (weekdayOffset + 7) % 7
        )

        days.forEach { day in
            currentWeek.append(day)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }

        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(CameraCalendarDay(date: Date.distantPast, day: -1))
            }
            weeks.append(currentWeek)
        }

        return weeks
    }

    private func isSame(_ month1: DateComponents, _ month2: DateComponents) -> Bool {
        month1.year == month2.year && month1.month == month2.month
    }
}
