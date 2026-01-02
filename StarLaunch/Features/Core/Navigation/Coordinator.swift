//
//  Coordinator.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }

    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let factory: ViewModelFactoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    init(
        navigationController: UINavigationController,
        factory: ViewModelFactoryProtocol = ViewModelFactory(),
        analyticsService: AnalyticsServiceProtocol = DependencyContainer.shared.analyticsService
    ) {
        self.navigationController = navigationController
        self.factory = factory
        self.analyticsService = analyticsService
    }

    func start() {
        showDashboard()
    }

    func showDashboard() {
        let viewModel = factory.makeDashboardViewModel()
        let vc = DashboardViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
        analyticsService.trackScreen("Dashboard")
    }

    func showLaunchList() {
        let viewModel = factory.makeLaunchListViewModel()
        let vc = LaunchListViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
        analyticsService.trackScreen("LaunchList")
    }

    func showLaunchDetail(launchID: String, launchName: String? = nil) {
        let viewModel = factory.makeLaunchDetailViewModel(launchID: launchID)
        let vc = LaunchDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
        analyticsService.trackScreen("LaunchDetail")
        analyticsService.trackEvent(
            "view_launch_detail",
            parameters: [
                "launch_id": launchID,
                "launch_name": launchName ?? "unknown",
            ])
    }

    func showFavorites() {
        let vc = FavoritesViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: true)
        analyticsService.trackScreen("Favorites")
    }

    func showSearch() {
        let viewModel = factory.makeLaunchListViewModel()
        let vc = SearchViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
        analyticsService.trackScreen("Search")
    }
}
