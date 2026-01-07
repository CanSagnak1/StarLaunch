//
//  NextLaunchEntry.swift
//  StarLaunchWidget
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import Foundation
import WidgetKit

/// Timeline entry for the Next Launch widget
struct NextLaunchEntry: TimelineEntry {
    let date: Date
    let launchData: SharedLaunchData?
    let configuration: ConfigurationAppIntent

    var isPlaceholder: Bool {
        launchData == nil
    }

    /// Countdown text for display
    var countdownText: String {
        guard let launchData = launchData,
            let components = launchData.countdownComponents
        else {
            return "T-00:00:00"
        }

        if components.days > 0 {
            return "T-\(components.days)d \(components.hours)h"
        } else {
            return String(
                format: "T-%02d:%02d:%02d", components.hours, components.minutes, components.seconds
            )
        }
    }

    /// Short countdown for small widgets
    var shortCountdownText: String {
        guard let launchData = launchData,
            let components = launchData.countdownComponents
        else {
            return "--:--"
        }

        if components.days > 0 {
            return "\(components.days)d \(components.hours)h"
        } else if components.hours > 0 {
            return "\(components.hours)h \(components.minutes)m"
        } else {
            return "\(components.minutes)m \(components.seconds)s"
        }
    }

    /// Days until launch
    var daysUntilLaunch: Int {
        guard let launchData = launchData,
            let components = launchData.countdownComponents
        else {
            return 0
        }
        return components.days
    }

    /// Hours until launch (within current day)
    var hoursUntilLaunch: Int {
        guard let launchData = launchData,
            let components = launchData.countdownComponents
        else {
            return 0
        }
        return components.hours
    }

    /// Launch name truncated for widget display
    var launchName: String {
        launchData?.name ?? "No Upcoming Launch"
    }

    /// Provider name
    var providerName: String {
        launchData?.providerName ?? "Unknown"
    }

    /// Location name
    var locationName: String {
        launchData?.locationName ?? "Unknown Location"
    }

    /// Formatted launch date
    var formattedLaunchDate: String {
        guard let launchData = launchData,
            let launchDate = launchData.launchDate
        else {
            return "TBD"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: launchDate)
    }

    /// Static placeholder entry
    static var placeholder: NextLaunchEntry {
        NextLaunchEntry(
            date: Date(),
            launchData: nil,
            configuration: ConfigurationAppIntent()
        )
    }
}
