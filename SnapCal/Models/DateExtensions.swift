//
//  DateExtensions.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfWeek: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfWeek) ?? self
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func isSameMonth(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: date) &&
               calendar.component(.month, from: self) == calendar.component(.month, from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    var shortMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }

    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    var shortWeekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    func timeString(showAMPM: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = showAMPM ? "h:mm a" : "HH:mm"
        return formatter.string(from: self)
    }

    func daysInMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)
        return range?.count ?? 30
    }

    func monthDates() -> [Date] {
        let calendar = Calendar.current
        let firstDay = startOfMonth
        let daysInMonth = daysInMonth()

        return (0..<daysInMonth).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: firstDay)
        }
    }

    func weekDates() -> [Date] {
        let calendar = Calendar.current
        let firstDay = startOfWeek

        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: firstDay)
        }
    }

    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }
}

extension Calendar {
    func generateDatesForMonthView(for date: Date) -> [Date?] {
        var dates: [Date?] = []
        let firstDayOfMonth = date.startOfMonth
        let firstWeekday = firstDayOfMonth.weekday

        let previousMonthDays = firstWeekday - 1
        for i in (0..<previousMonthDays).reversed() {
            dates.append(firstDayOfMonth.adding(days: -(i + 1)))
        }

        let daysInMonth = date.daysInMonth()
        for i in 0..<daysInMonth {
            dates.append(firstDayOfMonth.adding(days: i))
        }

        let remainingDays = 42 - dates.count
        let lastDayOfMonth = firstDayOfMonth.adding(days: daysInMonth)
        for i in 0..<remainingDays {
            dates.append(lastDayOfMonth.adding(days: i))
        }

        return dates
    }
}
