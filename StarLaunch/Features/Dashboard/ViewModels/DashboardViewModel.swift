//
//  DashboardViewModel.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {

    @Published private(set) var programInfo: StarshipProgram?
    @Published private(set) var errorMessage: String?
    @Published private(set) var launchCount: Int = 0
    @Published private(set) var successRate: Int = 0
    @Published private(set) var agencies: [Agency] = []
    @Published private(set) var starshipVehicles: [Spacecraft] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isOfflineMode: Bool = false

    private let networkService: NetworkServiceProtocol
    private let offlineDataManager: OfflineDataManager
    private let analyticsService: AnalyticsServiceProtocol
    private let networkMonitor = NetworkMonitor.shared

    private var cancellables = Set<AnyCancellable>()

    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        offlineDataManager: OfflineDataManager = OfflineDataManager.shared,
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    ) {
        self.networkService = networkService
        self.offlineDataManager = offlineDataManager
        self.analyticsService = analyticsService

        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                if isConnected && self?.isOfflineMode == true {
                    self?.refreshData()
                }
            }
            .store(in: &cancellables)
    }

    func fetchStarshipData() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                async let starshipResponse = networkService.fetchWithRetry(
                    from: APIConstants.starshipDashboard,
                    as: StarshipDashboardResponse.self,
                    policy: .default
                )

                async let launchStatsResponse = networkService.fetchWithRetry(
                    from: APIConstants.allLaunches,
                    as: LaunchStatResponse.self,
                    policy: .default
                )

                async let agenciesResponse: AgenciesResponse? = try? networkService.fetch(
                    from: APIConstants.agencies,
                    as: AgenciesResponse.self
                )

                async let starshipVehiclesResponse: SpacecraftResponse? = try? networkService.fetch(
                    from: APIConstants.starshipVehicles,
                    as: SpacecraftResponse.self
                )

                let (starshipData, launchStatsData, agenciesData, starshipVehiclesData) = try await
                    (
                        starshipResponse,
                        launchStatsResponse,
                        agenciesResponse,
                        starshipVehiclesResponse
                    )

                let totalLaunches = launchStatsData.count
                let successfulLaunches = launchStatsData.results.filter { $0.status.id == 3 }.count
                let rate =
                    totalLaunches > 0
                    ? Int((Double(successfulLaunches) / Double(totalLaunches)) * 100) : 0

                self.programInfo = starshipData.upcoming.launches.first?.program.first
                self.launchCount = totalLaunches
                self.successRate = rate

                if let agenciesData = agenciesData {
                    self.agencies = agenciesData.results.filter { $0.logoUrl != nil }
                }

                if let starshipVehiclesData = starshipVehiclesData {
                    self.starshipVehicles = starshipVehiclesData.results.filter {
                        $0.imageUrl != nil
                    }
                }

                self.isOfflineMode = false
                self.isLoading = false

                saveOfflineData()

            } catch let error as NetworkError {
                handleError(error)
            } catch {
                handleError(NetworkError.requestFailed(error))
            }
        }
    }

    func refreshData() {
        isLoading = false
        fetchStarshipData()
    }

    private func handleError(_ error: NetworkError) {
        analyticsService.trackError(error, context: ["source": "DashboardViewModel"])

        if case .noInternetConnection = error {
            loadOfflineData()
        } else {
            self.errorMessage = error.userFriendlyMessage
            self.isLoading = false
        }
    }

    private func saveOfflineData() {
        let offlineData = DashboardOfflineData(
            programName: programInfo?.name,
            programDescription: programInfo?.description,
            programImageUrl: programInfo?.imageUrl,
            launchCount: launchCount,
            successRate: successRate
        )
        offlineDataManager.saveDashboardData(offlineData)
    }

    private func loadOfflineData() {
        if let cached = offlineDataManager.loadCachedDashboard() {
            if let name = cached.programName, let desc = cached.programDescription,
                let imgUrl = cached.programImageUrl
            {
                self.programInfo = StarshipProgram(
                    name: name,
                    description: desc,
                    infoUrl: nil,
                    imageUrl: imgUrl
                )
            }
            self.launchCount = cached.launchCount
            self.successRate = cached.successRate
            self.isOfflineMode = true

            analyticsService.trackEvent(AnalyticsEvent.offlineMode)

        } else {
            self.errorMessage = NetworkError.noInternetConnection.userFriendlyMessage
        }
        self.isLoading = false
    }

    func clearError() {
        errorMessage = nil
    }
}
