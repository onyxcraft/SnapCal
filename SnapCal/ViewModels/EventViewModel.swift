//
//  EventViewModel.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import Foundation
import EventKit

@MainActor
class EventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(3600)
    @Published var isAllDay: Bool = false
    @Published var notes: String = ""
    @Published var location: String = ""
    @Published var selectedCalendar: EKCalendar?
    @Published var recurrenceFrequency: EKRecurrenceFrequency?
    @Published var isRecurring: Bool = false
    @Published var error: Error?

    private let eventKitService = EventKitService.shared
    private let naturalLanguageParser = NaturalLanguageParser.shared

    func parseNaturalLanguageInput(_ input: String) {
        if let parsed = naturalLanguageParser.parse(input) {
            title = parsed.title
            startDate = parsed.date
            isAllDay = parsed.isAllDay

            if isAllDay {
                endDate = startDate.adding(days: 1).startOfDay
            } else if let time = parsed.time {
                endDate = startDate.addingTimeInterval(parsed.duration)
            } else {
                endDate = startDate.addingTimeInterval(3600)
            }
        } else {
            title = input.capitalized
            startDate = Date()
            endDate = Date().addingTimeInterval(3600)
            isAllDay = false
        }
    }

    func createEvent() async throws {
        guard !title.isEmpty else {
            throw EventCreationError.emptyTitle
        }

        guard startDate < endDate else {
            throw EventCreationError.invalidDateRange
        }

        var recurrenceRule: EKRecurrenceRule?
        if isRecurring, let frequency = recurrenceFrequency {
            recurrenceRule = eventKitService.createRecurrenceRule(frequency: frequency, interval: 1)
        }

        try eventKitService.createEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            notes: notes.isEmpty ? nil : notes,
            location: location.isEmpty ? nil : location,
            calendarIdentifier: selectedCalendar?.calendarIdentifier,
            recurrenceRule: recurrenceRule
        )
    }

    func updateEvent(eventID: String) async throws {
        guard !title.isEmpty else {
            throw EventCreationError.emptyTitle
        }

        guard startDate < endDate else {
            throw EventCreationError.invalidDateRange
        }

        try eventKitService.updateEvent(
            eventID: eventID,
            title: title,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            notes: notes.isEmpty ? nil : notes,
            location: location.isEmpty ? nil : location
        )
    }

    func deleteEvent(eventID: String) async throws {
        try eventKitService.deleteEvent(eventID: eventID)
    }

    func reset() {
        title = ""
        startDate = Date()
        endDate = Date().addingTimeInterval(3600)
        isAllDay = false
        notes = ""
        location = ""
        selectedCalendar = nil
        recurrenceFrequency = nil
        isRecurring = false
        error = nil
    }

    func loadEvent(_ event: CalendarEvent) {
        title = event.title
        startDate = event.startDate
        endDate = event.endDate
        isAllDay = event.isAllDay
        notes = event.notes ?? ""
        location = event.location ?? ""
        isRecurring = event.recurrenceRule != nil
        if let rule = event.recurrenceRule {
            recurrenceFrequency = rule.frequency
        }
    }
}

enum EventCreationError: Error, LocalizedError {
    case emptyTitle
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Event title cannot be empty"
        case .invalidDateRange:
            return "End date must be after start date"
        }
    }
}
