//
//  EventCreationView.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import SwiftUI
import EventKit

struct EventCreationView: View {
    @StateObject private var viewModel = EventViewModel()
    @ObservedObject private var calendarViewModel = CalendarViewModel()
    @Environment(\.dismiss) private var dismiss

    let eventToEdit: CalendarEvent?
    @State private var naturalLanguageInput = ""
    @State private var showAdvancedOptions = false

    init(eventToEdit: CalendarEvent? = nil) {
        self.eventToEdit = eventToEdit
    }

    var body: some View {
        NavigationView {
            Form {
                naturalLanguageSection
                basicInfoSection
                dateTimeSection
                if showAdvancedOptions {
                    advancedOptionsSection
                }
            }
            .navigationTitle(eventToEdit == nil ? "New Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(viewModel.title.isEmpty)
                }
            }
            .onAppear {
                if let event = eventToEdit {
                    viewModel.loadEvent(event)
                } else {
                    viewModel.selectedCalendar = EventKitService.shared.getDefaultCalendar()
                }
            }
        }
    }

    private var naturalLanguageSection: some View {
        Section {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
                TextField("e.g., 'Dentist Friday 3pm'", text: $naturalLanguageInput)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if !naturalLanguageInput.isEmpty {
                            viewModel.parseNaturalLanguageInput(naturalLanguageInput)
                        }
                    }
                if !naturalLanguageInput.isEmpty {
                    Button(action: {
                        viewModel.parseNaturalLanguageInput(naturalLanguageInput)
                        naturalLanguageInput = ""
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(.purple)
                    }
                }
            }
        } header: {
            Text("Quick Entry")
        } footer: {
            Text("Type naturally and we'll parse the details")
        }
    }

    private var basicInfoSection: some View {
        Section("Event Details") {
            TextField("Title", text: $viewModel.title)

            TextField("Location", text: $viewModel.location)

            if !calendarViewModel.calendars.isEmpty {
                Picker("Calendar", selection: $viewModel.selectedCalendar) {
                    ForEach(calendarViewModel.calendars, id: \.calendarIdentifier) { calendar in
                        HStack {
                            Circle()
                                .fill(Color(cgColor: calendar.cgColor))
                                .frame(width: 12, height: 12)
                            Text(calendar.title)
                        }
                        .tag(calendar as EKCalendar?)
                    }
                }
            }
        }
    }

    private var dateTimeSection: some View {
        Section("Date & Time") {
            Toggle("All Day", isOn: $viewModel.isAllDay)

            DatePicker("Starts",
                      selection: $viewModel.startDate,
                      displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute])

            DatePicker("Ends",
                      selection: $viewModel.endDate,
                      displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute])

            Button {
                withAnimation {
                    showAdvancedOptions.toggle()
                }
            } label: {
                HStack {
                    Text("Advanced Options")
                    Spacer()
                    Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
                }
            }
        }
    }

    private var advancedOptionsSection: some View {
        Section("Additional Details") {
            Toggle("Recurring Event", isOn: $viewModel.isRecurring)

            if viewModel.isRecurring {
                Picker("Frequency", selection: $viewModel.recurrenceFrequency) {
                    Text("Daily").tag(EKRecurrenceFrequency.daily as EKRecurrenceFrequency?)
                    Text("Weekly").tag(EKRecurrenceFrequency.weekly as EKRecurrenceFrequency?)
                    Text("Monthly").tag(EKRecurrenceFrequency.monthly as EKRecurrenceFrequency?)
                    Text("Yearly").tag(EKRecurrenceFrequency.yearly as EKRecurrenceFrequency?)
                }
            }

            VStack(alignment: .leading) {
                Text("Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 80)
            }
        }
    }

    private func saveEvent() {
        Task {
            do {
                if let event = eventToEdit {
                    try await viewModel.updateEvent(eventID: event.id)
                } else {
                    try await viewModel.createEvent()
                }
                dismiss()
            } catch {
                viewModel.error = error
            }
        }
    }
}

#Preview {
    EventCreationView()
}
