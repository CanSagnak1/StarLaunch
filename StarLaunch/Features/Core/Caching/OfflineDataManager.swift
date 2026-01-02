//
//  OfflineDataManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Combine
import Foundation

final class OfflineDataManager {
    nonisolated(unsafe) static let shared = OfflineDataManager()

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let launchesKey = "offline_launches"
    private let launchesDateKey = "offline_launches_date"
    private let dashboardKey = "offline_dashboard"
    private let dashboardDateKey = "offline_dashboard_date"

    @Published private(set) var hasOfflineData = false

    private init() {
        hasOfflineData = loadCachedLaunches() != nil
    }

    func saveLaunches(_ launches: [LaunchItem]) {
        if let data = try? encoder.encode(launches) {
            userDefaults.set(data, forKey: launchesKey)
            userDefaults.set(Date(), forKey: launchesDateKey)
            hasOfflineData = true

        }
    }

    func loadCachedLaunches() -> [LaunchItem]? {
        guard let data = userDefaults.data(forKey: launchesKey) else { return nil }
        return try? decoder.decode([LaunchItem].self, from: data)
    }

    var launchesLastUpdateDate: Date? {
        userDefaults.object(forKey: launchesDateKey) as? Date
    }

    var launchesOfflineInfo: String {
        guard let date = launchesLastUpdateDate else {
            return "No offline data"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Updated \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    func saveDashboardData(_ data: DashboardOfflineData) {
        if let encoded = try? encoder.encode(data) {
            userDefaults.set(encoded, forKey: dashboardKey)
            userDefaults.set(Date(), forKey: dashboardDateKey)

        }
    }

    func loadCachedDashboard() -> DashboardOfflineData? {
        guard let data = userDefaults.data(forKey: dashboardKey) else { return nil }
        return try? decoder.decode(DashboardOfflineData.self, from: data)
    }

    var dashboardLastUpdateDate: Date? {
        userDefaults.object(forKey: dashboardDateKey) as? Date
    }

    func clearAllOfflineData() {
        userDefaults.removeObject(forKey: launchesKey)
        userDefaults.removeObject(forKey: launchesDateKey)
        userDefaults.removeObject(forKey: dashboardKey)
        userDefaults.removeObject(forKey: dashboardDateKey)
        hasOfflineData = false

    }
}

struct DashboardOfflineData: Codable {
    let programName: String?
    let programDescription: String?
    let programImageUrl: String?
    let launchCount: Int
    let successRate: Int
}
