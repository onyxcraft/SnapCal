//
//  NaturalLanguageParser.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import Foundation

struct ParsedEvent {
    let title: String
    let date: Date
    let time: Date?
    let duration: TimeInterval
    let isAllDay: Bool
}

class NaturalLanguageParser {
    static let shared = NaturalLanguageParser()

    private let calendar = Calendar.current
    private let weekdayKeywords = [
        "monday": 2, "mon": 2,
        "tuesday": 3, "tue": 3, "tues": 3,
        "wednesday": 4, "wed": 4,
        "thursday": 5, "thu": 5, "thur": 5, "thurs": 5,
        "friday": 6, "fri": 6,
        "saturday": 7, "sat": 7,
        "sunday": 1, "sun": 1
    ]

    private let relativeKeywords = [
        "today", "tomorrow", "tonight",
        "next week", "next month"
    ]

    func parse(_ input: String) -> ParsedEvent? {
        let lowercased = input.lowercased()
        var components = lowercased.components(separatedBy: " ")

        guard !components.isEmpty else { return nil }

        var parsedDate: Date?
        var parsedTime: Date?
        var title = ""
        var isAllDay = false
        var duration: TimeInterval = 3600

        var usedIndices = Set<Int>()

        parsedDate = parseRelativeDate(from: components, usedIndices: &usedIndices)

        if parsedDate == nil {
            parsedDate = parseWeekday(from: components, usedIndices: &usedIndices)
        }

        if parsedDate == nil {
            parsedDate = parseSpecificDate(from: components, usedIndices: &usedIndices)
        }

        parsedTime = parseTime(from: components, usedIndices: &usedIndices)

        if let timeKeywordIndex = components.firstIndex(where: { $0.contains("all") && components.indices.contains(components.firstIndex(of: $0)! + 1) && components[components.firstIndex(of: $0)! + 1].contains("day") }) {
            isAllDay = true
            usedIndices.insert(timeKeywordIndex)
            if components.indices.contains(timeKeywordIndex + 1) {
                usedIndices.insert(timeKeywordIndex + 1)
            }
        }

        let titleWords = components.enumerated().filter { !usedIndices.contains($0.offset) }.map { $0.element }
        title = titleWords.joined(separator: " ").capitalized

        if title.isEmpty {
            title = "New Event"
        }

        let finalDate = parsedDate ?? Date()

        if let time = parsedTime, !isAllDay {
            let hour = calendar.component(.hour, from: time)
            let minute = calendar.component(.minute, from: time)
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: finalDate)
            dateComponents.hour = hour
            dateComponents.minute = minute
            if let combinedDate = calendar.date(from: dateComponents) {
                return ParsedEvent(title: title, date: combinedDate, time: time, duration: duration, isAllDay: false)
            }
        }

        if isAllDay {
            return ParsedEvent(title: title, date: finalDate.startOfDay, time: nil, duration: 86400, isAllDay: true)
        }

        return ParsedEvent(title: title, date: finalDate, time: parsedTime, duration: duration, isAllDay: isAllDay)
    }

    private func parseRelativeDate(from components: [String], usedIndices: inout Set<Int>) -> Date? {
        let now = Date()

        for (index, component) in components.enumerated() {
            switch component {
            case "today", "tonight":
                usedIndices.insert(index)
                return now.startOfDay
            case "tomorrow":
                usedIndices.insert(index)
                return now.adding(days: 1).startOfDay
            default:
                break
            }
        }

        if components.count >= 2 {
            for i in 0..<components.count - 1 {
                let phrase = "\(components[i]) \(components[i + 1])"
                if phrase == "next week" {
                    usedIndices.insert(i)
                    usedIndices.insert(i + 1)
                    return now.adding(weeks: 1).startOfWeek
                } else if phrase == "next month" {
                    usedIndices.insert(i)
                    usedIndices.insert(i + 1)
                    return now.adding(months: 1).startOfMonth
                }
            }
        }

        return nil
    }

    private func parseWeekday(from components: [String], usedIndices: inout Set<Int>) -> Date? {
        for (index, component) in components.enumerated() {
            if let weekday = weekdayKeywords[component] {
                usedIndices.insert(index)
                return nextDate(for: weekday)
            }
        }
        return nil
    }

    private func parseSpecificDate(from components: [String], usedIndices: inout Set<Int>) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let formats = [
            "MM/dd/yyyy",
            "MM/dd/yy",
            "MM/dd",
            "M/d",
            "MMMM dd",
            "MMM dd",
            "dd MMMM",
            "dd MMM"
        ]

        for format in formats {
            dateFormatter.dateFormat = format
            for i in 0..<components.count {
                let possibleDateStrings = [
                    components[i],
                    i + 1 < components.count ? "\(components[i]) \(components[i + 1])" : "",
                    i + 2 < components.count ? "\(components[i]) \(components[i + 1]) \(components[i + 2])" : ""
                ]

                for (offset, dateString) in possibleDateStrings.enumerated() where !dateString.isEmpty {
                    if let date = dateFormatter.date(from: dateString) {
                        for j in 0...offset {
                            usedIndices.insert(i + j)
                        }
                        return date
                    }
                }
            }
        }

        return nil
    }

    private func parseTime(from components: [String], usedIndices: inout Set<Int>) -> Date? {
        let timeRegex = try? NSRegularExpression(pattern: #"(\d{1,2}):?(\d{2})?\s?(am|pm|a|p)?"#, options: .caseInsensitive)

        for (index, component) in components.enumerated() {
            let range = NSRange(component.startIndex..<component.endIndex, in: component)
            if let match = timeRegex?.firstMatch(in: component, options: [], range: range) {
                let hourRange = match.range(at: 1)
                let minuteRange = match.range(at: 2)
                let ampmRange = match.range(at: 3)

                guard hourRange.location != NSNotFound else { continue }

                let hourString = (component as NSString).substring(with: hourRange)
                var hour = Int(hourString) ?? 0

                var minute = 0
                if minuteRange.location != NSNotFound {
                    let minuteString = (component as NSString).substring(with: minuteRange)
                    minute = Int(minuteString) ?? 0
                }

                if ampmRange.location != NSNotFound {
                    let ampmString = (component as NSString).substring(with: ampmRange).lowercased()
                    if (ampmString == "pm" || ampmString == "p") && hour < 12 {
                        hour += 12
                    } else if (ampmString == "am" || ampmString == "a") && hour == 12 {
                        hour = 0
                    }
                } else if hour < 8 {
                    hour += 12
                }

                if hour >= 0 && hour < 24 && minute >= 0 && minute < 60 {
                    usedIndices.insert(index)
                    var components = DateComponents()
                    components.hour = hour
                    components.minute = minute
                    return calendar.date(from: components)
                }
            }
        }

        return nil
    }

    private func nextDate(for weekday: Int) -> Date {
        let today = Date()
        let currentWeekday = calendar.component(.weekday, from: today)

        var daysToAdd = weekday - currentWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7
        }

        return calendar.date(byAdding: .day, value: daysToAdd, to: today.startOfDay) ?? today
    }
}
