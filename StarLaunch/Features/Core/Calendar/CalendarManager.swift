//
//  CalendarManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import EventKit
import Foundation

/// Reminder time options for calendar events
enum CalendarReminderOption: CaseIterable {
    case fifteenMinutes
    case oneHour
    case oneDay
    case none

    var minutes: Int? {
        switch self {
        case .fifteenMinutes: return 15
        case .oneHour: return 60
        case .oneDay: return 1440
        case .none: return nil
        }
    }

    var displayTitle: String {
        switch self {
        case .fifteenMinutes: return L10n.calendarReminder15Min
        case .oneHour: return L10n.calendarReminder1Hour
        case .oneDay: return L10n.calendarReminder1Day
        case .none: return L10n.calendarNoReminder
        }
    }
}

/// Result of adding a launch to calendar
struct CalendarEventResult {
    let eventIdentifier: String
    let success: Bool
    let error: Error?
}

/// Manager for calendar operations using EventKit
final class CalendarManager {
    static let shared = CalendarManager()

    private let eventStore = EKEventStore()
    private let userDefaultsKey = "savedCalendarEvents"

    private init() {}

    // MARK: - Authorization

    /// Check current calendar authorization status
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    /// Request calendar access
    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToEvents()
            } else {
                return try await eventStore.requestAccess(to: .event)
            }
        } catch {
            return false
        }
    }

    /// Check if we have calendar permission
    var hasCalendarPermission: Bool {
        let status = authorizationStatus
        if #available(iOS 17.0, *) {
            return status == .fullAccess
        } else {
            return status == .authorized
        }
    }

    // MARK: - Add Event

    /// Add a launch to the calendar
    func addLaunchToCalendar(
        _ launch: LaunchItem,
        reminderOption: CalendarReminderOption = .fifteenMinutes
    ) async throws -> CalendarEventResult {
        if !hasCalendarPermission {
            let granted = await requestAccess()
            if !granted {
                throw CalendarError.accessDenied
            }
        }

        let formatter = ISO8601DateFormatter()
        guard let launchDate = formatter.date(from: launch.windowStart) else {
            throw CalendarError.invalidDate
        }

        // Create event
        let event = EKEvent(eventStore: eventStore)
        event.title = "🚀 \(launch.name)"
        event.startDate = launchDate
        event.endDate = launchDate.addingTimeInterval(3600)  // 1 hour duration
        event.notes = createEventNotes(for: launch)
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.location = launch.pad.location.name

        // Add alarm if selected
        if let reminderMinutes = reminderOption.minutes {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60))
            event.addAlarm(alarm)
        }

        do {
            try eventStore.save(event, span: .thisEvent)

            // Save reference for later removal
            saveEventReference(launchID: launch.id, eventIdentifier: event.eventIdentifier)

            return CalendarEventResult(
                eventIdentifier: event.eventIdentifier, success: true, error: nil)
        } catch {
            throw CalendarError.saveFailed(error)
        }
    }

    /// Add a launch detail to the calendar
    func addLaunchDetailToCalendar(
        _ launch: LaunchDetail,
        reminderOption: CalendarReminderOption = .fifteenMinutes
    ) async throws -> CalendarEventResult {
        if !hasCalendarPermission {
            let granted = await requestAccess()
            if !granted {
                throw CalendarError.accessDenied
            }
        }

        let formatter = ISO8601DateFormatter()
        guard let launchDate = formatter.date(from: launch.net) else {
            throw CalendarError.invalidDate
        }

        // Create event
        let event = EKEvent(eventStore: eventStore)
        event.title = "🚀 \(launch.name)"
        event.startDate = launchDate
        event.endDate = launchDate.addingTimeInterval(3600)  // 1 hour duration
        event.notes = createEventNotes(for: launch)
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.location = launch.pad.location.name

        // Add alarm if selected
        if let reminderMinutes = reminderOption.minutes {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60))
            event.addAlarm(alarm)
        }

        do {
            try eventStore.save(event, span: .thisEvent)

            // Save reference for later removal
            saveEventReference(launchID: launch.id, eventIdentifier: event.eventIdentifier)

            return CalendarEventResult(
                eventIdentifier: event.eventIdentifier, success: true, error: nil)
        } catch {
            throw CalendarError.saveFailed(error)
        }
    }

    // MARK: - Remove Event

    /// Remove a launch from the calendar
    func removeLaunchFromCalendar(launchID: String) async throws {
        guard let eventIdentifier = getEventIdentifier(for: launchID) else {
            throw CalendarError.eventNotFound
        }

        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            // Event may have been deleted by user
            removeEventReference(launchID: launchID)
            return
        }

        do {
            try eventStore.remove(event, span: .thisEvent)
            removeEventReference(launchID: launchID)
        } catch {
            throw CalendarError.deleteFailed(error)
        }
    }

    // MARK: - Check Status

    /// Check if a launch is already in calendar
    func isLaunchInCalendar(launchID: String) -> Bool {
        guard let eventIdentifier = getEventIdentifier(for: launchID) else {
            return false
        }

        // Verify event still exists
        return eventStore.event(withIdentifier: eventIdentifier) != nil
    }

    // MARK: - Private Helpers

    private func createEventNotes(for launch: LaunchItem) -> String {
        """
        Provider: \(launch.provider.name)
        Location: \(launch.pad.location.name)
        Pad: \(launch.pad.name)

        Added via StarLaunch 🚀
        """
    }

    private func createEventNotes(for launch: LaunchDetail) -> String {
        var notes = """
            Provider: \(launch.launchServiceProvider.name)
            Rocket: \(launch.rocket.configuration.fullName)
            Location: \(launch.pad.location.name)
            Pad: \(launch.pad.name)
            Status: \(launch.status.name)
            """

        if let mission = launch.mission {
            notes += "\n\nMission: \(mission.name)"
            if let description = mission.description {
                notes += "\n\(description)"
            }
        }

        notes += "\n\nAdded via StarLaunch 🚀"
        return notes
    }

    // MARK: - Storage

    private func saveEventReference(launchID: String, eventIdentifier: String) {
        var events = getSavedEvents()
        events[launchID] = eventIdentifier
        UserDefaults.standard.set(events, forKey: userDefaultsKey)
    }

    private func removeEventReference(launchID: String) {
        var events = getSavedEvents()
        events.removeValue(forKey: launchID)
        UserDefaults.standard.set(events, forKey: userDefaultsKey)
    }

    private func getEventIdentifier(for launchID: String) -> String? {
        getSavedEvents()[launchID]
    }

    private func getSavedEvents() -> [String: String] {
        UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] ?? [:]
    }
}

// MARK: - Calendar Errors

enum CalendarError: LocalizedError {
    case accessDenied
    case invalidDate
    case saveFailed(Error)
    case deleteFailed(Error)
    case eventNotFound

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return L10n.calendarErrorAccessDenied
        case .invalidDate:
            return L10n.calendarErrorInvalidDate
        case .saveFailed(let error):
            return "\(L10n.calendarErrorSaveFailed): \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "\(L10n.calendarErrorDeleteFailed): \(error.localizedDescription)"
        case .eventNotFound:
            return L10n.calendarErrorNotFound
        }
    }
}
