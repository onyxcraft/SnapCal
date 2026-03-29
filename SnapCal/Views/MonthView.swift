//
//  MonthView.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import SwiftUI

struct MonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Namespace private var animation

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    var body: some View {
        VStack(spacing: 16) {
            monthHeader
            weekdayHeader
            monthGrid
        }
        .padding()
    }

    private var monthHeader: some View {
        HStack {
            Button(action: { viewModel.moveToPreviousMonth() }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.primary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(viewModel.currentMonth.monthName)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(String(viewModel.currentMonth.year))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: { viewModel.moveToNextMonth() }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.primary)
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        let dates = Calendar.current.generateDatesForMonthView(for: viewModel.currentMonth)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(dates.indices, id: \.self) { index in
                if let date = dates[index] {
                    DayCell(
                        date: date,
                        isCurrentMonth: date.isSameMonth(as: viewModel.currentMonth),
                        isSelected: date.isSameDay(as: viewModel.selectedDate),
                        isToday: date.isToday,
                        hasEvents: viewModel.hasEvents(on: date),
                        events: viewModel.eventsForDate(date)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectDate(date)
                        }
                    }
                    .matchedGeometryEffect(id: date.startOfDay, in: animation)
                }
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let events: [CalendarEvent]

    var body: some View {
        VStack(spacing: 4) {
            Text("\(date.day)")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundStyle(textColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
                )

            if hasEvents && isCurrentMonth {
                HStack(spacing: 2) {
                    ForEach(events.prefix(3)) { event in
                        Circle()
                            .fill(Color(hex: event.calendarColor) ?? .accentColor)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(height: 50)
    }

    private var textColor: Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.5)
        }
        if isSelected {
            return .white
        }
        return .primary
    }

    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        }
        return .clear
    }
}

// Color.init(hex:) is defined in Extensions/Color+Hex.swift

#Preview {
    MonthView(viewModel: CalendarViewModel())
}
