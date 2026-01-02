//
//  LaunchDetailViewModel.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Combine
import Foundation

@MainActor
final class LaunchDetailViewModel: ObservableObject {

    private let launchID: String

    @Published private(set) var launchDetail: LaunchDetail?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isFavorite: Bool = false
    @Published private(set) var isNotificationScheduled: Bool = false

    private let networkService: NetworkServiceProtocol
    private let favoritesManager: FavoritesManager
    private let notificationManager: NotificationManager
    private let analyticsService: AnalyticsServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    var updateUI: ((LaunchDetail) -> Void)?
    var showError: ((String) -> Void)?
    var updateLoadingStatus: ((Bool) -> Void)?

    init(
        launchID: String,
        networkService: NetworkServiceProtocol = NetworkService.shared,
        favoritesManager: FavoritesManager = FavoritesManager.shared,
        notificationManager: NotificationManager = NotificationManager.shared,
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    ) {
        self.launchID = launchID
        self.networkService = networkService
        self.favoritesManager = favoritesManager
        self.notificationManager = notificationManager
        self.analyticsService = analyticsService


        setupBindings()
    }

    private func setupBindings() {
        favoritesManager.$favoriteIDs
            .map { [weak self] ids in
                guard let self = self else { return false }
                return ids.contains(self.launchID)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFavorite)

        checkNotificationStatus()
    }

    func fetchLaunchDetail() {
        isLoading = true
        updateLoadingStatus?(true)
        errorMessage = nil

        Task {
            do {
                let urlString = APIConstants.launchDetail(id: launchID)
                let detail = try await networkService.fetchWithRetry(
                    from: urlString,
                    as: LaunchDetail.self,
                    policy: .default
                )

                self.launchDetail = detail
                self.updateUI?(detail)

            } catch let error as NetworkError {
                handleError(error)
            } catch {
                handleError(NetworkError.requestFailed(error))
            }

            self.isLoading = false
            self.updateLoadingStatus?(false)
        }
    }

    private func handleError(_ error: NetworkError) {
        analyticsService.trackError(
            error, context: ["source": "LaunchDetailViewModel", "launchID": launchID])

        self.errorMessage = error.userFriendlyMessage
        self.showError?(error.userFriendlyMessage)
    }

    func toggleFavorite() {
        guard let detail = launchDetail else { return }

        let launchItem = LaunchItem(
            id: detail.id,
            name: detail.name,
            windowStart: detail.net,
            provider: detail.launchServiceProvider,
            pad: detail.pad,
            image: detail.image
        )

        favoritesManager.toggleFavorite(launchItem)

        let event = isFavorite ? AnalyticsEvent.addToFavorites : AnalyticsEvent.removeFromFavorites
        analyticsService.trackEvent(
            event,
            parameters: [
                "launch_id": launchID,
                "launch_name": detail.name,
            ])
    }

    func toggleNotification() {
        guard let detail = launchDetail else { return }

        if isNotificationScheduled {
            notificationManager.cancelNotification(for: launchID)
            isNotificationScheduled = false
        } else {
            let launchItem = LaunchItem(
                id: detail.id,
                name: detail.name,
                windowStart: detail.net,
                provider: detail.launchServiceProvider,
                pad: detail.pad,
                image: detail.image
            )

            notificationManager.scheduleNotification(for: launchItem)
            isNotificationScheduled = true

            analyticsService.trackEvent(
                AnalyticsEvent.enableNotification,
                parameters: [
                    "launch_id": launchID,
                    "launch_name": detail.name,
                ])
        }
    }

    private func checkNotificationStatus() {
        notificationManager.isNotificationScheduled(for: launchID) { [weak self] isScheduled in
            self?.isNotificationScheduled = isScheduled
        }
    }

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationManager.requestAuthorization(completion: completion)
    }

    var canScheduleNotification: Bool {
        guard let detail = launchDetail else { return false }
        let formatter = ISO8601DateFormatter()
        guard let launchDate = formatter.date(from: detail.net) else { return false }
        return launchDate > Date()
    }
}
