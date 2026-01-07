//
//  NextLaunchProvider.swift
//  StarLaunchWidget
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import Foundation
import WidgetKit

/// Timeline provider for the Next Launch widget
struct NextLaunchProvider: AppIntentTimelineProvider {

    typealias Entry = NextLaunchEntry
    typealias Intent = ConfigurationAppIntent

    /// Placeholder entry for widget gallery
    func placeholder(in context: Context) -> NextLaunchEntry {
        NextLaunchEntry.placeholder
    }

    /// Snapshot for widget gallery preview
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async
        -> NextLaunchEntry
    {
        if context.isPreview {
            // Return sample data for preview
            return createSampleEntry(configuration: configuration)
        }

        // Return actual data
        return createEntry(configuration: configuration)
    }

    /// Timeline for widget updates
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
        NextLaunchEntry
    > {
        var entries: [NextLaunchEntry] = []
        let currentDate = Date()

        // Create entries for the next hour with updates every 15 minutes
        for minuteOffset in stride(from: 0, to: 60, by: 15) {
            let entryDate = Calendar.current.date(
                byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = createEntry(configuration: configuration, date: entryDate)
            entries.append(entry)
        }

        // Refresh timeline every 15 minutes
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        return Timeline(entries: entries, policy: .after(refreshDate))
    }

    // MARK: - Private Helpers

    private func createEntry(configuration: ConfigurationAppIntent, date: Date = Date())
        -> NextLaunchEntry
    {
        let sharedData = SharedDataManager.shared.getNextLaunch()

        return NextLaunchEntry(
            date: date,
            launchData: sharedData,
            configuration: configuration
        )
    }

    private func createSampleEntry(configuration: ConfigurationAppIntent) -> NextLaunchEntry {
        let sampleData = SharedLaunchData(
            id: "sample-001",
            name: "Starship Flight 8",
            windowStart: ISO8601DateFormatter().string(
                from: Date().addingTimeInterval(3600 * 24 * 2)),  // 2 days from now
            providerName: "SpaceX",
            padName: "Starbase",
            locationName: "Texas, USA",
            imageURL: nil,
            lastUpdated: Date()
        )

        return NextLaunchEntry(
            date: Date(),
            launchData: sampleData,
            configuration: configuration
        )
    }
}
