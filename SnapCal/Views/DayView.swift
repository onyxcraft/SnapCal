//
//  DayView.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import SwiftUI

struct DayView: View {
    @ObservedObject var viewModel: CalendarViewModel

    private let hours = Array(0...23)
    private let hourHeight: CGFloat = 80

    var body: some View {
        VStack(spacing: 0) {
            dayHeader
            ScrollViewReader { proxy in
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        hourGrid
                        eventOverlay
                        currentTimeIndicator
                    }
                    .onAppear {
                        scrollToCurrentTime(proxy: proxy)
                    }
                }
            }
        }
    }

    private var dayHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: moveToPreviousDay) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text(viewModel.selectedDate.weekdayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(viewModel.selectedDate.monthName) \(viewModel.selectedDate.day), \(viewModel.selectedDate.year)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: moveToNextDay) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding(.horizontal)

            Divider()
        }
    }

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                HStack(alignment: .top, spacing: 0) {
                    Text(hourString(for: hour))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .padding(.trailing, 12)
                        .padding(.top, -8)

                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }

    private var eventOverlay: some View {
        let events = viewModel.eventsForDate(viewModel.selectedDate)
        let dayWidth = UIScreen.main.bounds.width - 72

        return ZStack(alignment: .topLeading) {
            ForEach(events) { event in
                EventCard(event: event)
                    .frame(width: dayWidth)
                    .offset(
                        x: 72,
                        y: yOffset(for: event.startDate)
                    )
            }
        }
    }

    @ViewBuilder
    private var currentTimeIndicator: some View {
        if viewModel.selectedDate.isToday {
            let now = Date()
            HStack(spacing: 0) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: 68)

                Rectangle()
                    .fill(Color.red)
                    .frame(height: 2)
            }
            .offset(y: yOffset(for: now))
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

    private func scrollToCurrentTime(proxy: ScrollViewProxy) {
        if viewModel.selectedDate.isToday {
            let currentHour = Date().hour
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    proxy.scrollTo(max(0, currentHour - 1), anchor: .top)
                }
            }
        }
    }

    private func moveToPreviousDay() {
        viewModel.selectDate(viewModel.selectedDate.adding(days: -1))
    }

    private func moveToNextDay() {
        viewModel.selectDate(viewModel.selectedDate.adding(days: 1))
    }
}

struct EventCard: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color(hex: event.calendarColor) ?? .accentColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if !event.isAllDay {
                    Text("\(event.startDate.timeString()) - \(event.endDate.timeString())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("All Day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let location = event.location {
                    Label(location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color(hex: event.calendarColor)?.opacity(0.1) ?? Color.accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    DayView(viewModel: CalendarViewModel())
}
