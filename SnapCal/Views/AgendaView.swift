//
//  AgendaView.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import SwiftUI

struct AgendaView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if upcomingEvents.isEmpty {
                    emptyState
                } else {
                    ForEach(groupedEvents.keys.sorted(), id: \.self) { date in
                        Section {
                            ForEach(groupedEvents[date] ?? []) { event in
                                AgendaEventRow(event: event)
                            }
                        } header: {
                            SectionHeader(date: date)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var upcomingEvents: [CalendarEvent] {
        viewModel.upcomingEvents(limit: 50)
    }

    private var groupedEvents: [Date: [CalendarEvent]] {
        Dictionary(grouping: upcomingEvents) { event in
            event.startDate.startOfDay
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Upcoming Events")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create an event to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

struct SectionHeader: View {
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(headerText)
                .font(.title3)
                .fontWeight(.bold)

            Text(date.monthName + " " + String(date.day))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var headerText: String {
        if date.isToday {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return date.weekdayName
        }
    }
}

struct AgendaEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                if event.isAllDay {
                    Text("All")
                        .font(.caption2)
                    Text("Day")
                        .font(.caption2)
                } else {
                    Text(event.startDate.timeString(showAMPM: false))
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(amPmString)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 50)
            .foregroundStyle(Color(hex: event.calendarColor) ?? .accentColor)

            Rectangle()
                .fill(Color(hex: event.calendarColor) ?? .accentColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if !event.isAllDay {
                    Text("\(event.startDate.timeString()) - \(event.endDate.timeString())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let location = event.location {
                    Label(location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if event.recurrenceRule != nil {
                    Label("Recurring", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Circle()
                .fill(Color(hex: event.calendarColor) ?? .accentColor)
                .frame(width: 8, height: 8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: event.calendarColor)?.opacity(0.08) ?? Color.accentColor.opacity(0.08))
        )
    }

    private var amPmString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: event.startDate).lowercased()
    }
}

#Preview {
    AgendaView(viewModel: CalendarViewModel())
}
