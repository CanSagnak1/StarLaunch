//
//  CompareViewModel.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import Combine
import Foundation

/// Comparison row data structure
struct ComparisonRow: Identifiable {
    let id = UUID()
    let title: String
    let values: [String]
    let iconSystemName: String
}

/// ViewModel for launch comparison feature
@MainActor
final class CompareViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var selectedLaunches: [LaunchItem] = []
    @Published private(set) var comparisonRows: [ComparisonRow] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Constants

    static let maxComparisons = 3

    // MARK: - Computed Properties

    var canAddMore: Bool {
        selectedLaunches.count < Self.maxComparisons
    }

    var hasLaunches: Bool {
        !selectedLaunches.isEmpty
    }

    var launchCount: Int {
        selectedLaunches.count
    }

    // MARK: - Public Methods

    /// Add a launch to comparison
    func addLaunch(_ launch: LaunchItem) {
        guard canAddMore else { return }
        guard !selectedLaunches.contains(where: { $0.id == launch.id }) else { return }

        selectedLaunches.append(launch)
        generateComparisonRows()
    }

    /// Remove a launch from comparison
    func removeLaunch(_ launch: LaunchItem) {
        selectedLaunches.removeAll { $0.id == launch.id }
        generateComparisonRows()
    }

    /// Remove launch by index
    func removeLaunch(at index: Int) {
        guard index >= 0 && index < selectedLaunches.count else { return }
        selectedLaunches.remove(at: index)
        generateComparisonRows()
    }

    /// Clear all selections
    func clearAll() {
        selectedLaunches.removeAll()
        comparisonRows.removeAll()
    }

    /// Check if launch is selected
    func isSelected(_ launch: LaunchItem) -> Bool {
        selectedLaunches.contains { $0.id == launch.id }
    }

    // MARK: - Private Methods

    private func generateComparisonRows() {
        guard !selectedLaunches.isEmpty else {
            comparisonRows = []
            return
        }

        var rows: [ComparisonRow] = []

        // Provider row
        rows.append(
            ComparisonRow(
                title: L10n.detailProvider,
                values: selectedLaunches.map { $0.provider.name },
                iconSystemName: "building.2.fill"
            ))

        // Launch Date row
        rows.append(
            ComparisonRow(
                title: L10n.detailWindow,
                values: selectedLaunches.map { formatDate($0.windowStart) },
                iconSystemName: "calendar"
            ))

        // Countdown row
        rows.append(
            ComparisonRow(
                title: L10n.detailCountdown,
                values: selectedLaunches.map { calculateCountdown($0.windowStart) },
                iconSystemName: "timer"
            ))

        // Location row
        rows.append(
            ComparisonRow(
                title: L10n.detailLocation,
                values: selectedLaunches.map { $0.pad.location.name },
                iconSystemName: "location.fill"
            ))

        // Pad row
        rows.append(
            ComparisonRow(
                title: "Pad",
                values: selectedLaunches.map { $0.pad.name },
                iconSystemName: "airplane.departure"
            ))

        comparisonRows = rows
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return L10n.detailTbd
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        let identifier = LocalizationManager.shared.currentLanguage == .turkish ? "tr_TR" : "en_US"
        displayFormatter.locale = Locale(identifier: identifier)
        return displayFormatter.string(from: date)
    }

    private func calculateCountdown(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let launchDate = formatter.date(from: dateString) else {
            return L10n.detailTbd
        }

        let timeInterval = launchDate.timeIntervalSinceNow
        guard timeInterval > 0 else {
            return L10n.launchStatusLaunched
        }

        let totalSeconds = Int(timeInterval)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600

        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            let minutes = (totalSeconds % 3600) / 60
            return "\(hours)h \(minutes)m"
        } else {
            let minutes = totalSeconds / 60
            return "\(minutes)m"
        }
    }
}
