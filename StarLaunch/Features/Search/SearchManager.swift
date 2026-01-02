//
//  SearchManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Combine
import Foundation

struct FilterCriteria: Equatable {
    var searchQuery: String = ""
    var provider: String?
    var startDate: Date?
    var endDate: Date?
    var location: String?
    var sortBy: SortOption = .date

    enum SortOption: String, CaseIterable {
        case date = "Launch Date"
        case name = "Name"
        case provider = "Provider"
    }

    var isEmpty: Bool {
        searchQuery.isEmpty && provider == nil && startDate == nil && endDate == nil
            && location == nil
    }

    mutating func reset() {
        searchQuery = ""
        provider = nil
        startDate = nil
        endDate = nil
        location = nil
        sortBy = .date
    }
}

final class SearchManager: ObservableObject {

    @Published var criteria = FilterCriteria()
    @Published private(set) var filteredResults: [LaunchItem] = []
    @Published private(set) var availableProviders: [String] = []
    @Published private(set) var availableLocations: [String] = []

    private var allLaunches: [LaunchItem] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        $criteria
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] criteria in
                self?.applyFilters(criteria)
            }
            .store(in: &cancellables)
    }

    func setLaunches(_ launches: [LaunchItem]) {
        allLaunches = launches
        extractFilterOptions(from: launches)
        applyFilters(criteria)
    }

    private func extractFilterOptions(from launches: [LaunchItem]) {
        let providers = Set(launches.map { $0.provider.name })
        availableProviders = providers.sorted()

        let locations = Set(launches.map { $0.pad.location.name })
        availableLocations = locations.sorted()
    }

    private func applyFilters(_ criteria: FilterCriteria) {
        var results = allLaunches

        if !criteria.searchQuery.isEmpty {
            let query = criteria.searchQuery.lowercased()
            results = results.filter { launch in
                launch.name.lowercased().contains(query)
                    || launch.provider.name.lowercased().contains(query)
                    || launch.pad.location.name.lowercased().contains(query)
                    || launch.pad.name.lowercased().contains(query)
            }
        }

        if let provider = criteria.provider {
            results = results.filter { $0.provider.name == provider }
        }

        if let location = criteria.location {
            results = results.filter { $0.pad.location.name == location }
        }

        if let startDate = criteria.startDate {
            let formatter = ISO8601DateFormatter()
            results = results.filter { launch in
                if let date = formatter.date(from: launch.windowStart) {
                    return date >= startDate
                }
                return false
            }
        }

        if let endDate = criteria.endDate {
            let formatter = ISO8601DateFormatter()
            results = results.filter { launch in
                if let date = formatter.date(from: launch.windowStart) {
                    return date <= endDate
                }
                return false
            }
        }

        switch criteria.sortBy {
        case .date:
            let formatter = ISO8601DateFormatter()
            results.sort { l1, l2 in
                let d1 = formatter.date(from: l1.windowStart) ?? .distantFuture
                let d2 = formatter.date(from: l2.windowStart) ?? .distantFuture
                return d1 < d2
            }
        case .name:
            results.sort { $0.name < $1.name }
        case .provider:
            results.sort { $0.provider.name < $1.provider.name }
        }

        filteredResults = results

    }

    func search(_ query: String) {
        criteria.searchQuery = query
    }

    func filterByProvider(_ provider: String?) {
        criteria.provider = provider
    }

    func filterByLocation(_ location: String?) {
        criteria.location = location
    }

    func filterByDateRange(start: Date?, end: Date?) {
        criteria.startDate = start
        criteria.endDate = end
    }

    func sortBy(_ option: FilterCriteria.SortOption) {
        criteria.sortBy = option
    }

    func resetFilters() {
        criteria.reset()
    }

    var activeFiltersCount: Int {
        var count = 0
        if criteria.provider != nil { count += 1 }
        if criteria.location != nil { count += 1 }
        if criteria.startDate != nil { count += 1 }
        if criteria.endDate != nil { count += 1 }
        return count
    }
}
