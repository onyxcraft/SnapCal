//
//  CalendarViewModel.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import Foundation
import EventKit
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var events: [CalendarEvent] = []
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var calendars: [EKCalendar] = []

    private let eventKitService = EventKitService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        Task {
            await checkAuthorization()
        }
    }

    private func setupBindings() {
        eventKitService.$calendars
            .assign(to: &$calendars)

        $selectedDate
            .sink { [weak self] _ in
                Task { await self?.fetchEvents() }
            }
            .store(in: &cancellables)

        $currentMonth
            .sink { [weak self] _ in
                Task { await self?.fetchEvents() }
            }
            .store(in: &cancellables)
    }

    func checkAuthorization() async {
        eventKitService.checkAuthorizationStatus()
        if eventKitService.authorizationStatus == .notDetermined {
            do {
                try await eventKitService.requestAccess()
                await fetchEvents()
            } catch {
                self.error = error
            }
        } else if eventKitService.authorizationStatus == .fullAccess ||
                  eventKitService.authorizationStatus == .authorized {
            await eventKitService.loadCalendars()
            await fetchEvents()
        }
    }

    func fetchEvents() async {
        isLoading = true
        defer { isLoading = false }

        let startDate = currentMonth.startOfMonth.adding(days: -7)
        let endDate = currentMonth.endOfMonth.adding(days: 7)

        events = eventKitService.fetchEvents(from: startDate, to: endDate)
    }

    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        events.filter { event in
            if event.isAllDay {
                return event.startDate.isSameDay(as: date)
            } else {
                return event.startDate.isSameDay(as: date) ||
                       (event.startDate <= date && event.endDate >= date)
            }
        }.sorted { $0.startDate < $1.startDate }
    }

    func eventsForWeek(_ weekStartDate: Date) -> [CalendarEvent] {
        let weekEndDate = weekStartDate.endOfWeek
        return events.filter { event in
            event.startDate >= weekStartDate && event.startDate <= weekEndDate
        }.sorted { $0.startDate < $1.startDate }
    }

    func upcomingEvents(limit: Int = 10) -> [CalendarEvent] {
        let now = Date()
        return events.filter { $0.startDate >= now }
            .sorted { $0.startDate < $1.startDate }
            .prefix(limit)
            .map { $0 }
    }

    func selectDate(_ date: Date) {
        selectedDate = date
        if !date.isSameMonth(as: currentMonth) {
            currentMonth = date
        }
    }

    func moveToNextMonth() {
        currentMonth = currentMonth.adding(months: 1)
    }

    func moveToPreviousMonth() {
        currentMonth = currentMonth.adding(months: -1)
    }

    func moveToToday() {
        let today = Date()
        selectedDate = today
        currentMonth = today
    }

    func hasEvents(on date: Date) -> Bool {
        !eventsForDate(date).isEmpty
    }
}
