//
//  ViewModelFactory.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Foundation

protocol ViewModelFactoryProtocol {
    func makeDashboardViewModel() -> DashboardViewModel
    func makeLaunchListViewModel() -> LaunchListViewModel
    func makeLaunchDetailViewModel(launchID: String) -> LaunchDetailViewModel
}

final class ViewModelFactory: ViewModelFactoryProtocol {
    private let container: DependencyContainer

    init(container: DependencyContainer = .shared) {
        self.container = container
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(
            networkService: container.networkService,
            offlineDataManager: container.offlineDataManager,
            analyticsService: container.analyticsService
        )
    }

    func makeLaunchListViewModel() -> LaunchListViewModel {
        return LaunchListViewModel(
            networkService: container.networkService,
            offlineDataManager: container.offlineDataManager,
            favoritesManager: container.favoritesManager,
            searchManager: container.searchManager,
            analyticsService: container.analyticsService
        )
    }

    func makeLaunchDetailViewModel(launchID: String) -> LaunchDetailViewModel {
        return LaunchDetailViewModel(
            launchID: launchID,
            networkService: container.networkService,
            favoritesManager: container.favoritesManager,
            notificationManager: container.notificationManager,
            analyticsService: container.analyticsService
        )
    }
}
