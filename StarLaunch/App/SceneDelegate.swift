//
//  SceneDelegate.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: MainCoordinator?
    private var cancellables = Set<AnyCancellable>()

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = SplashViewController()
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()

        setupNetworkStatusBanner()
        setupNotificationObservers()
    }

    private func setupNetworkStatusBanner() {
        guard let window = window else { return }

        NetworkMonitor.shared.$isConnected
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { isConnected in
                if isConnected {
                    NetworkStatusBanner.shared.showOnline(in: window)
                } else {
                    NetworkStatusBanner.shared.showOffline(in: window)
                }
            }
            .store(in: &cancellables)
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenLaunchDetail(_:)),
            name: .openLaunchDetail,
            object: nil
        )
    }

    @objc private func handleOpenLaunchDetail(_ notification: Notification) {
        guard let launchID = notification.userInfo?["launchID"] as? String else { return }
        coordinator?.showLaunchDetail(launchID: launchID)
    }

    func setupMainApp() {
        guard let window = window else { return }

        let navigationController = UINavigationController()
        coordinator = MainCoordinator(navigationController: navigationController)
        coordinator?.start()

        window.rootViewController = navigationController

        UIView.transition(
            with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)

        DependencyContainer.shared.analyticsService.trackEvent(AnalyticsEvent.appOpen)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        CacheManager.shared.clearExpired()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CacheManager.shared.clearExpired()
    }
}
