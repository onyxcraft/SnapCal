//
//  EventKitService.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import Foundation
import EventKit

@MainActor
class EventKitService: ObservableObject {
    static let shared = EventKitService()

    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var calendars: [EKCalendar] = []

    private init() {
        checkAuthorizationStatus()
    }

    func checkAuthorizationStatus() {
        if #available(iOS 17.0, *) {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        } else {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
    }

    func requestAccess() async throws {
        if #available(iOS 17.0, *) {
            let granted = try await eventStore.requestFullAccessToEvents()
            authorizationStatus = granted ? .fullAccess : .denied
        } else {
            let granted = try await eventStore.requestAccess(to: .event)
            authorizationStatus = granted ? .authorized : .denied
        }
        if authorizationStatus == .fullAccess || authorizationStatus == .authorized {
            await loadCalendars()
        }
    }

    func loadCalendars() async {
        calendars = eventStore.calendars(for: .event)
    }

    func fetchEvents(from startDate: Date, to endDate: Date) -> [CalendarEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        return ekEvents.map { CalendarEvent(from: $0) }
    }

    func createEvent(title: String,
                    startDate: Date,
                    endDate: Date,
                    isAllDay: Bool = false,
                    notes: String? = nil,
                    location: String? = nil,
                    calendarIdentifier: String? = nil,
                    recurrenceRule: EKRecurrenceRule? = nil) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.notes = notes
        event.location = location

        if let calendarIdentifier = calendarIdentifier,
           let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) {
            event.calendar = calendar
        } else {
            event.calendar = eventStore.defaultCalendarForNewEvents
        }

        if let recurrenceRule = recurrenceRule {
            event.addRecurrenceRule(recurrenceRule)
        }

        try eventStore.save(event, span: .thisEvent)
    }

    func updateEvent(eventID: String,
                    title: String? = nil,
                    startDate: Date? = nil,
                    endDate: Date? = nil,
                    isAllDay: Bool? = nil,
                    notes: String? = nil,
                    location: String? = nil) throws {
        guard let event = eventStore.event(withIdentifier: eventID) else {
            throw EventKitError.eventNotFound
        }

        if let title = title { event.title = title }
        if let startDate = startDate { event.startDate = startDate }
        if let endDate = endDate { event.endDate = endDate }
        if let isAllDay = isAllDay { event.isAllDay = isAllDay }
        if let notes = notes { event.notes = notes }
        if let location = location { event.location = location }

        try eventStore.save(event, span: .thisEvent)
    }

    func deleteEvent(eventID: String) throws {
        guard let event = eventStore.event(withIdentifier: eventID) else {
            throw EventKitError.eventNotFound
        }
        try eventStore.remove(event, span: .thisEvent)
    }

    func getDefaultCalendar() -> EKCalendar? {
        eventStore.defaultCalendarForNewEvents
    }

    func createRecurrenceRule(frequency: EKRecurrenceFrequency,
                             interval: Int = 1,
                             end: EKRecurrenceEnd? = nil) -> EKRecurrenceRule {
        EKRecurrenceRule(recurrenceWith: frequency,
                        interval: interval,
                        end: end)
    }
}

enum EventKitError: Error, LocalizedError {
    case eventNotFound
    case accessDenied
    case unknownError

    var errorDescription: String? {
        switch self {
        case .eventNotFound:
            return "Event not found"
        case .accessDenied:
            return "Calendar access denied"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}
