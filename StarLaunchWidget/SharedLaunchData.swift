//
//  SharedLaunchData.swift
//  StarLaunchWidget
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import Foundation

/// Codable launch data structure for widget sharing via App Groups
/// This is a copy of the shared data structure for the widget extension
struct SharedLaunchData: Codable {
    let id: String
    let name: String
    let windowStart: String
    let providerName: String
    let padName: String
    let locationName: String
    let imageURL: String?
    let lastUpdated: Date

    var launchDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: windowStart)
    }

    var timeUntilLaunch: TimeInterval? {
        guard let launchDate = launchDate else { return nil }
        return launchDate.timeIntervalSinceNow
    }

    var countdownComponents: (days: Int, hours: Int, minutes: Int, seconds: Int)? {
        guard let timeUntilLaunch = timeUntilLaunch, timeUntilLaunch > 0 else { return nil }

        let totalSeconds = Int(timeUntilLaunch)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return (days, hours, minutes, seconds)
    }
}

/// Manager for accessing shared data from App Groups
final class SharedDataManager {
    static let shared = SharedDataManager()

    private let suiteName = "group.cansagnak.apps.starlaunch"
    private let nextLaunchKey = "nextLaunch"

    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private let decoder = JSONDecoder()

    private init() {}

    /// Get the next upcoming launch for widget display
    func getNextLaunch() -> SharedLaunchData? {
        guard let data = userDefaults?.data(forKey: nextLaunchKey) else {
            return nil
        }

        do {
            return try decoder.decode(SharedLaunchData.self, from: data)
        } catch {
            return nil
        }
    }
}
