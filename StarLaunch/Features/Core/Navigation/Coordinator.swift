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

    private var tabBarController: MainTabBarController?

    func start() {
        let tabBarController = MainTabBarController(
            factory: factory, analyticsService: analyticsService)
        self.tabBarController = tabBarController
        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func showDashboard() {
        tabBarController?.selectedIndex = 0
    }

    func showLaunchList() {
        tabBarController?.selectedIndex = 1
    }

    func showFavorites() {
        tabBarController?.selectedIndex = 2
    }

    func showLaunchDetail(launchID: String, launchName: String? = nil) {
        tabBarController?.showLaunchDetail(launchID: launchID, launchName: launchName)
    }

    func showSearch() {
        tabBarController?.showSearch()
    }
}
