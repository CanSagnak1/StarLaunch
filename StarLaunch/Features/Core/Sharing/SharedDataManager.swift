//
//  SharedDataManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import Foundation

/// Codable launch data structure for widget sharing via App Groups
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

/// Manager for sharing data between main app and widgets via App Groups
final class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let suiteName = "group.cansagnak.apps.starlaunch"
    private let nextLaunchKey = "nextLaunch"
    private let upcomingLaunchesKey = "upcomingLaunches"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    // MARK: - Next Launch
    
    /// Save the next upcoming launch for widget display
    func saveNextLaunch(_ launch: LaunchItem) {
        let sharedData = SharedLaunchData(
            id: launch.id,
            name: launch.name,
            windowStart: launch.windowStart,
            providerName: launch.provider.name,
            padName: launch.pad.name,
            locationName: launch.pad.location.name,
            imageURL: launch.image,
            lastUpdated: Date()
        )
        
        do {
            let data = try encoder.encode(sharedData)
            userDefaults?.set(data, forKey: nextLaunchKey)
        } catch {
            // Silent fail - widget will show placeholder
        }
    }
    
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
    
    // MARK: - Upcoming Launches
    
    /// Save multiple upcoming launches for widget display
    func saveUpcomingLaunches(_ launches: [LaunchItem]) {
        let sharedLaunches = launches.prefix(5).map { launch in
            SharedLaunchData(
                id: launch.id,
                name: launch.name,
                windowStart: launch.windowStart,
                providerName: launch.provider.name,
                padName: launch.pad.name,
                locationName: launch.pad.location.name,
                imageURL: launch.image,
                lastUpdated: Date()
            )
        }
        
        do {
            let data = try encoder.encode(sharedLaunches)
            userDefaults?.set(data, forKey: upcomingLaunchesKey)
        } catch {
            // Silent fail
        }
    }
    
    /// Get upcoming launches for widget display
    func getUpcomingLaunches() -> [SharedLaunchData] {
        guard let data = userDefaults?.data(forKey: upcomingLaunchesKey) else {
            return []
        }
        
        do {
            return try decoder.decode([SharedLaunchData].self, from: data)
        } catch {
            return []
        }
    }
    
    // MARK: - Clear Data
    
    func clearAllSharedData() {
        userDefaults?.removeObject(forKey: nextLaunchKey)
        userDefaults?.removeObject(forKey: upcomingLaunchesKey)
    }
}
