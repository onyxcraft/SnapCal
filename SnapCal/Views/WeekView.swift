//
//  WeekView.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import SwiftUI

struct WeekView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var currentWeekStart: Date = Date().startOfWeek

    private let hours = Array(0...23)
    private let hourHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            weekHeader
            ScrollView {
                ZStack(alignment: .topLeading) {
                    hourGrid
                    eventOverlay
                }
            }
        }
    }

    private var weekHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: moveToPreviousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Week")
                        .font(.headline)
                    Text(weekRangeString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: moveToNextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 0) {
                Text("")
                    .frame(width: 50)

                ForEach(currentWeekStart.weekDates(), id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(date.shortWeekdayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(date.day)")
                            .font(.system(size: 16, weight: date.isToday ? .bold : .regular))
                            .foregroundStyle(date.isToday ? .white : .primary)
                            .frame(width: 32, height: 32)
                            .background(date.isToday ? Color.accentColor : Color.clear)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.selectDate(date)
                    }
                }
            }
            .padding(.bottom, 8)

            Divider()
        }
    }

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                HStack(spacing: 0) {
                    Text(hourString(for: hour))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                        .padding(.trailing, 8)

                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                }
                .frame(height: hourHeight)
            }
        }
    }

    private var eventOverlay: some View {
        let weekDates = currentWeekStart.weekDates()
        let dayWidth = (UIScreen.main.bounds.width - 50) / 7

        return ZStack(alignment: .topLeading) {
            ForEach(weekDates.indices, id: \.self) { dayIndex in
                let date = weekDates[dayIndex]
                let dayEvents = viewModel.eventsForDate(date)

                ForEach(dayEvents) { event in
                    EventBlock(event: event)
                        .frame(width: dayWidth - 4)
                        .offset(
                            x: 50 + CGFloat(dayIndex) * dayWidth + 2,
                            y: yOffset(for: event.startDate)
                        )
                }
            }
        }
    }

    private func yOffset(for date: Date) -> CGFloat {
        let hour = CGFloat(date.hour)
        let minute = CGFloat(date.minute)
        return (hour + minute / 60) * hourHeight
    }

    private func hourString(for hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }

    private var weekRangeString: String {
        let end = currentWeekStart.endOfWeek
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: currentWeekStart)) - \(formatter.string(from: end))"
    }

    private func moveToPreviousWeek() {
        currentWeekStart = currentWeekStart.adding(weeks: -1)
        viewModel.currentMonth = currentWeekStart
    }

    private func moveToNextWeek() {
        currentWeekStart = currentWeekStart.adding(weeks: 1)
        viewModel.currentMonth = currentWeekStart
    }
}

struct EventBlock: View {
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            if !event.isAllDay {
                Text(event.startDate.timeString())
                    .font(.caption2)
            }
        }
        .foregroundStyle(.white)
        .padding(4)
        .background(Color(hex: event.calendarColor) ?? .accentColor)
        .cornerRadius(4)
    }
}

#Preview {
    WeekView(viewModel: CalendarViewModel())
}
