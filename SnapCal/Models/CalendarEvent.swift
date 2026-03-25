//
//  CalendarEvent.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import Foundation
import EventKit

struct CalendarEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let notes: String?
    let location: String?
    let calendarIdentifier: String
    let calendarColor: String
    let recurrenceRule: EKRecurrenceRule?

    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier
        self.title = ekEvent.title ?? "Untitled"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.isAllDay = ekEvent.isAllDay
        self.notes = ekEvent.notes
        self.location = ekEvent.location
        self.calendarIdentifier = ekEvent.calendar.calendarIdentifier
        self.calendarColor = ekEvent.calendar.cgColor.toHexString()
        self.recurrenceRule = ekEvent.recurrenceRules?.first
    }

    init(id: String = UUID().uuidString,
         title: String,
         startDate: Date,
         endDate: Date,
         isAllDay: Bool = false,
         notes: String? = nil,
         location: String? = nil,
         calendarIdentifier: String = "",
         calendarColor: String = "#007AFF",
         recurrenceRule: EKRecurrenceRule? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.notes = notes
        self.location = location
        self.calendarIdentifier = calendarIdentifier
        self.calendarColor = calendarColor
        self.recurrenceRule = recurrenceRule
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}

extension CGColor {
    func toHexString() -> String {
        guard let components = components, components.count >= 3 else {
            return "#007AFF"
        }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
