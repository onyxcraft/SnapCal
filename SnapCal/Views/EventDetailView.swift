//
//  EventDetailView.swift
//  SnapCal
//
//  Created by SnapCal Team
//

import SwiftUI

struct EventDetailView: View {
    let event: CalendarEvent
    @StateObject private var eventViewModel = EventViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    dateTimeSection
                    if let location = event.location {
                        locationSection(location: location)
                    }
                    if let notes = event.notes {
                        notesSection(notes: notes)
                    }
                    if event.recurrenceRule != nil {
                        recurrenceSection
                    }
                }
                .padding()
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EventCreationView(eventToEdit: event)
            }
            .alert("Delete Event", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        try? await eventViewModel.deleteEvent(eventID: event.id)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this event?")
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(hex: event.calendarColor) ?? .accentColor)
                    .frame(width: 12, height: 12)

                Text(event.title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
    }

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    if event.isAllDay {
                        Text("All Day Event")
                            .font(.subheadline)
                        Text(dateString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(event.startDate.timeString()) - \(event.endDate.timeString())")
                            .font(.subheadline)
                        Text(dateString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } icon: {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    private func locationSection(location: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(location)
                    .font(.subheadline)
            } icon: {
                Image(systemName: "location.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(notes)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(recurrenceText)
                    .font(.subheadline)
            } icon: {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(.purple)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: event.startDate)
    }

    private var recurrenceText: String {
        guard let rule = event.recurrenceRule else { return "" }
        switch rule.frequency {
        case .daily: return "Repeats Daily"
        case .weekly: return "Repeats Weekly"
        case .monthly: return "Repeats Monthly"
        case .yearly: return "Repeats Yearly"
        @unknown default: return "Repeats"
        }
    }
}
