//
//  LaunchListViewModel.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Combine
import Foundation

@MainActor
final class LaunchListViewModel: ObservableObject {

    @Published private(set) var launchItems: [LaunchItem] = []
    @Published private(set) var filteredLaunches: [LaunchItem] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isRefreshing: Bool = false
    @Published private(set) var isOfflineMode: Bool = false
    @Published private(set) var isSearching: Bool = false

    private let networkService: NetworkServiceProtocol
    private let offlineDataManager: OfflineDataManager
    private let favoritesManager: FavoritesManager
    private let searchManager: SearchManager
    private let analyticsService: AnalyticsServiceProtocol
    private let networkMonitor = NetworkMonitor.shared

    private var nextURL: String?
    private var canLoadMorePages = true
    private var cancellables = Set<AnyCancellable>()

    var currentSortOption: FilterCriteria.SortOption {
        searchManager.criteria.sortBy
    }

    var activeFiltersCount: Int {
        searchManager.activeFiltersCount
    }

    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        offlineDataManager: OfflineDataManager = OfflineDataManager.shared,
        favoritesManager: FavoritesManager = FavoritesManager.shared,
        searchManager: SearchManager = SearchManager(),
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    ) {
        self.networkService = networkService
        self.offlineDataManager = offlineDataManager
        self.favoritesManager = favoritesManager
        self.searchManager = searchManager
        self.analyticsService = analyticsService

        setupBindings()
    }

    private func setupBindings() {
        searchManager.$filteredResults
            .receive(on: DispatchQueue.main)
            .assign(to: &$filteredLaunches)

        networkMonitor.$isConnected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                if isConnected && self?.isOfflineMode == true {
                    self?.refreshLaunches()
                }
            }
            .store(in: &cancellables)
    }

    func fetchLaunches() {
        guard !isLoading, canLoadMorePages else { return }

        isLoading = true
        errorMessage = nil

        let urlToFetch = nextURL ?? APIConstants.upcomingLaunches

        Task {
            do {
                let response = try await networkService.fetchWithRetry(
                    from: urlToFetch,
                    as: LaunchesResponse.self,
                    policy: .default
                )

                self.launchItems.append(contentsOf: response.results)
                self.searchManager.setLaunches(self.launchItems)
                self.nextURL = response.next
                self.canLoadMorePages = response.next != nil
                self.isOfflineMode = false

                offlineDataManager.saveLaunches(self.launchItems)

                self.isLoading = false

            } catch let error as NetworkError {
                handleError(error)
            } catch {
                handleError(NetworkError.requestFailed(error))
            }
        }
    }

    func refreshLaunches() {
        guard !isRefreshing else { return }

        isRefreshing = true
        launchItems = []
        filteredLaunches = []
        nextURL = nil
        canLoadMorePages = true
        errorMessage = nil

        analyticsService.trackEvent(AnalyticsEvent.refresh)

        Task {
            do {
                let response = try await networkService.fetchWithRetry(
                    from: APIConstants.upcomingLaunches,
                    as: LaunchesResponse.self,
                    policy: .default
                )

                self.launchItems = response.results
                self.searchManager.setLaunches(self.launchItems)
                self.nextURL = response.next
                self.canLoadMorePages = response.next != nil
                self.isOfflineMode = false

                offlineDataManager.saveLaunches(self.launchItems)

            } catch let error as NetworkError {
                handleError(error)
            } catch {
                handleError(NetworkError.requestFailed(error))
            }

            self.isRefreshing = false
            self.isLoading = false
        }
    }

    private func handleError(_ error: NetworkError) {
        analyticsService.trackError(error, context: ["source": "LaunchListViewModel"])

        if case .noInternetConnection = error {
            loadOfflineData()
        } else {
            self.errorMessage = error.userFriendlyMessage
            self.isLoading = false
        }
    }

    private func loadOfflineData() {
        if let cachedLaunches = offlineDataManager.loadCachedLaunches(), !cachedLaunches.isEmpty {
            self.launchItems = cachedLaunches
            self.searchManager.setLaunches(cachedLaunches)
            self.isOfflineMode = true
            self.canLoadMorePages = false

            analyticsService.trackEvent(AnalyticsEvent.offlineMode)

        } else {
            self.errorMessage = NetworkError.noInternetConnection.userFriendlyMessage
        }
        self.isLoading = false
    }

    func search(_ query: String) {
        isSearching = !query.isEmpty
        searchManager.search(query)

        if !query.isEmpty {
            analyticsService.trackEvent(AnalyticsEvent.search, parameters: ["query": query])
        }
    }

    func sortBy(_ option: FilterCriteria.SortOption) {
        searchManager.sortBy(option)
        analyticsService.trackEvent(AnalyticsEvent.filter, parameters: ["sort_by": option.rawValue])
    }

    func filterByProvider(_ provider: String?) {
        searchManager.filterByProvider(provider)
    }

    func resetFilters() {
        searchManager.resetFilters()
        isSearching = false
    }

    func isFavorite(_ launchID: String) -> Bool {
        favoritesManager.isFavorite(launchID)
    }

    func toggleFavorite(_ launch: LaunchItem) {
        favoritesManager.toggleFavorite(launch)

        let event =
            favoritesManager.isFavorite(launch.id)
            ? AnalyticsEvent.addToFavorites
            : AnalyticsEvent.removeFromFavorites
        analyticsService.trackEvent(event, parameters: ["launch_id": launch.id])
    }

    var offlineInfo: String {
        offlineDataManager.launchesOfflineInfo
    }
}
