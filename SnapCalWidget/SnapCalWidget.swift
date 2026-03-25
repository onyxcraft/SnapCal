//
//  SnapCalWidget.swift
//  SnapCalWidget
//
//  Created by SnapCal Team
//

import WidgetKit
import SwiftUI
import EventKit

struct Provider: TimelineProvider {
    let eventKitService = EventKitService.shared

    func placeholder(in context: Context) -> EventEntry {
        EventEntry(date: Date(), events: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (EventEntry) -> ()) {
        Task {
            let events = await fetchEvents()
            let entry = EventEntry(date: Date(), events: events)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EventEntry>) -> ()) {
        Task {
            let events = await fetchEvents()
            let currentDate = Date()
            let entry = EventEntry(date: currentDate, events: events)

            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    @MainActor
    private func fetchEvents() -> [CalendarEvent] {
        eventKitService.checkAuthorizationStatus()
        if eventKitService.authorizationStatus == .fullAccess ||
           eventKitService.authorizationStatus == .authorized {
            let now = Date()
            let endDate = now.adding(days: 7)
            return eventKitService.fetchEvents(from: now, to: endDate)
                .filter { $0.startDate >= now }
                .sorted { $0.startDate < $1.startDate }
                .prefix(10)
                .map { $0 }
        }
        return []
    }
}

struct EventEntry: TimelineEntry {
    let date: Date
    let events: [CalendarEvent]
}

struct SnapCalWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: EventEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(Date().day.description)
                    .font(.system(size: 40, weight: .bold))
                VStack(alignment: .leading, spacing: 0) {
                    Text(Date().shortWeekdayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Date().shortMonthName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if entry.events.isEmpty {
                Text("No upcoming events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.events.prefix(2)) { event in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: event.calendarColor) ?? .accentColor)
                                .frame(width: 6, height: 6)
                            Text(event.title)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    let entry: EventEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().day.description)
                    .font(.system(size: 50, weight: .bold))
                Text(Date().weekdayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(Date().monthName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Upcoming")
                    .font(.headline)

                if entry.events.isEmpty {
                    Text("No events")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(entry.events.prefix(4)) { event in
                            HStack(spacing: 8) {
                                Rectangle()
                                    .fill(Color(hex: event.calendarColor) ?? .accentColor)
                                    .frame(width: 3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                    if !event.isAllDay {
                                        Text(event.startDate.timeString())
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
    }
}

struct LargeWidgetView: View {
    let entry: EventEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date().day.description)
                        .font(.system(size: 40, weight: .bold))
                    Text("\(Date().weekdayName), \(Date().monthName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            Text("Upcoming Events")
                .font(.headline)

            if entry.events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No upcoming events")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(entry.events.prefix(8)) { event in
                            HStack(spacing: 12) {
                                VStack(spacing: 2) {
                                    if event.isAllDay {
                                        Text("All")
                                            .font(.caption2)
                                        Text("Day")
                                            .font(.caption2)
                                    } else {
                                        Text(event.startDate.timeString(showAMPM: false))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                                .frame(width: 40)
                                .foregroundStyle(Color(hex: event.calendarColor) ?? .accentColor)

                                Rectangle()
                                    .fill(Color(hex: event.calendarColor) ?? .accentColor)
                                    .frame(width: 3)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)

                                    if let location = event.location {
                                        Text(location)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                Circle()
                                    .fill(Color(hex: event.calendarColor) ?? .accentColor)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct SnapCalWidget: Widget {
    let kind: String = "SnapCalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SnapCalWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("SnapCal")
        .description("View your upcoming calendar events")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    SnapCalWidget()
} timeline: {
    EventEntry(date: .now, events: [])
}

#Preview(as: .systemMedium) {
    SnapCalWidget()
} timeline: {
    EventEntry(date: .now, events: [])
}

#Preview(as: .systemLarge) {
    SnapCalWidget()
} timeline: {
    EventEntry(date: .now, events: [])
}
