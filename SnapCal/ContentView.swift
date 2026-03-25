//
//  ContentView.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import SwiftUI

enum CalendarViewType: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
    case agenda = "Agenda"

    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.leading"
        case .day: return "calendar.circle"
        case .agenda: return "list.bullet"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedView: CalendarViewType = .month
    @State private var showEventCreation = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                viewPicker

                currentView
                    .transition(.slide)
            }
            .navigationTitle("SnapCal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { viewModel.moveToToday() }) {
                        Text("Today")
                            .fontWeight(.medium)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showEventCreation = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showEventCreation) {
                EventCreationView()
            }
        }
    }

    private var viewPicker: some View {
        Picker("View", selection: $selectedView) {
            ForEach(CalendarViewType.allCases, id: \.self) { viewType in
                Label(viewType.rawValue, systemImage: viewType.icon)
                    .tag(viewType)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    @ViewBuilder
    private var currentView: some View {
        switch selectedView {
        case .month:
            MonthView(viewModel: viewModel)
        case .week:
            WeekView(viewModel: viewModel)
        case .day:
            DayView(viewModel: viewModel)
        case .agenda:
            AgendaView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
