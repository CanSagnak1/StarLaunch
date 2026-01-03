//
//  MainTabBarController.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 3.01.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - Properties
    private let factory: ViewModelFactoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    // Tab Coordinators
    private lazy var settingsNavController = createNavigationController()
    private lazy var dashboardNavController = createNavigationController()
    private lazy var launchesNavController = createNavigationController()
    private lazy var favoritesNavController = createNavigationController()

    // MARK: - Initialization
    init(
        factory: ViewModelFactoryProtocol = ViewModelFactory(),
        analyticsService: AnalyticsServiceProtocol = DependencyContainer.shared.analyticsService
    ) {
        self.factory = factory
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
        setupTabBarAppearance()
        setupLanguageObserver()

        // Default to Dashboard tab (index 0)
        selectedIndex = 0
    }

    // MARK: - Setup
    private func setupLanguageObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: LocalizationManager.languageDidChangeNotification,
            object: nil
        )
    }

    @objc private func languageDidChange() {
        updateTabBarTitles()
    }

    private func updateTabBarTitles() {
        dashboardNavController.tabBarItem.title = L10n.tabDashboard
        launchesNavController.tabBarItem.title = L10n.tabLaunches
        favoritesNavController.tabBarItem.title = L10n.tabFavorites
        settingsNavController.tabBarItem.title = L10n.tabSettings
    }

    func refreshAllTabsForLanguageChange() {
        updateTabBarTitles()

        // Refresh Dashboard
        if let dashboardVC = dashboardNavController.viewControllers.first
            as? DashboardViewController
        {
            dashboardVC.refreshForLanguageChange()
        }

        // Refresh Launches
        if let launchesVC = launchesNavController.viewControllers.first as? LaunchListViewController
        {
            launchesVC.refreshForLanguageChange()
        }

        // Refresh Favorites
        if let favoritesVC = favoritesNavController.viewControllers.first
            as? FavoritesViewController
        {
            favoritesVC.refreshForLanguageChange()
        }
    }

    private func setupTabBar() {
        delegate = self

        // Custom tab bar background
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = Colors.cardBackground.withAlphaComponent(0.95)

        // Add blur effect
        appearance.backgroundEffect = UIBlurEffect(style: .dark)

        // Tab bar item appearance
        let itemAppearance = UITabBarItemAppearance()

        // Normal state
        itemAppearance.normal.iconColor = Colors.tertiaryColor
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: Colors.tertiaryColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
        ]

        // Selected state
        itemAppearance.selected.iconColor = Colors.accentCyan
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: Colors.accentCyan,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        // Add top border
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        topBorder.backgroundColor = Colors.glassBorder.cgColor
        tabBar.layer.addSublayer(topBorder)
    }

    private func setupViewControllers() {
        // Dashboard Tab (index 0)
        let dashboardViewModel = factory.makeDashboardViewModel()
        let dashboardVC = DashboardViewController(viewModel: dashboardViewModel, coordinator: self)
        dashboardNavController.setViewControllers([dashboardVC], animated: false)
        dashboardNavController.tabBarItem = UITabBarItem(
            title: L10n.tabDashboard,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        dashboardNavController.tabBarItem.tag = 0

        // Launches Tab (index 1)
        let launchesViewModel = factory.makeLaunchListViewModel()
        let launchesVC = LaunchListViewController(viewModel: launchesViewModel, coordinator: self)
        launchesNavController.setViewControllers([launchesVC], animated: false)
        launchesNavController.tabBarItem = UITabBarItem(
            title: L10n.tabLaunches,
            image: UIImage(systemName: "calendar.badge.clock"),
            selectedImage: UIImage(systemName: "calendar.badge.clock")
        )
        launchesNavController.tabBarItem.tag = 1

        // Favorites Tab (index 2)
        let favoritesVC = FavoritesViewController(coordinator: self)
        favoritesNavController.setViewControllers([favoritesVC], animated: false)
        favoritesNavController.tabBarItem = UITabBarItem(
            title: L10n.tabFavorites,
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        favoritesNavController.tabBarItem.tag = 2

        // Settings Tab (index 3 - rightmost)
        let settingsVC = SettingsViewController(coordinator: self)
        settingsNavController.setViewControllers([settingsVC], animated: false)
        settingsNavController.tabBarItem = UITabBarItem(
            title: L10n.tabSettings,
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        settingsNavController.tabBarItem.tag = 3

        viewControllers = [
            dashboardNavController,
            launchesNavController,
            favoritesNavController,
            settingsNavController,
        ]
    }

    private func setupTabBarAppearance() {
        // TabBar appearance is fully configured in setupTabBar()
        // No additional layers needed
    }

    private func createNavigationController() -> UINavigationController {
        let navController = UINavigationController()
        navController.navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navController.navigationBar.standardAppearance = appearance
        navController.navigationBar.scrollEdgeAppearance = appearance
        navController.navigationBar.tintColor = .white

        return navController
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController, didSelect viewController: UIViewController
    ) {
        HapticManager.shared.selectionChanged()

        // Track tab selection
        let tabNames = ["Dashboard", "Launches", "Favorites", "Settings"]
        if let index = viewControllers?.firstIndex(of: viewController), index < tabNames.count {
            analyticsService.trackScreen(tabNames[index])
        }
    }
}

// MARK: - Navigation (Coordinator-like functionality)
extension MainTabBarController {
    func showLaunchDetail(launchID: String, launchName: String? = nil) {
        let viewModel = factory.makeLaunchDetailViewModel(launchID: launchID)
        let detailVC = LaunchDetailViewController(viewModel: viewModel)

        // Push on currently selected navigation controller
        if let navController = selectedViewController as? UINavigationController {
            navController.pushViewController(detailVC, animated: true)
        }

        analyticsService.trackScreen("LaunchDetail")
        analyticsService.trackEvent(
            "view_launch_detail",
            parameters: [
                "launch_id": launchID,
                "launch_name": launchName ?? "unknown",
            ]
        )
    }

    func showSearch() {
        let viewModel = factory.makeLaunchListViewModel()
        let searchVC = SearchViewController(viewModel: viewModel, coordinator: self)

        if let navController = selectedViewController as? UINavigationController {
            navController.pushViewController(searchVC, animated: true)
        }

        analyticsService.trackScreen("Search")
    }

    func showLaunchList() {
        // Switch to Launches tab (index 1)
        selectedIndex = 1
        HapticManager.shared.navigation()
    }

    func showFavorites() {
        // Switch to Favorites tab (index 2)
        selectedIndex = 2
        HapticManager.shared.navigation()
    }

    func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.modalPresentationStyle = .fullScreen
        onboardingVC.onComplete = { [weak self] in
            self?.dismiss(animated: true)
        }
        present(onboardingVC, animated: true)
    }
}
