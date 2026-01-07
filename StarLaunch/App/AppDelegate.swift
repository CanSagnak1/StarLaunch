//
//  AppDelegate.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        setupAppearance()
        setupNotifications()

        _ = NetworkMonitor.shared
        _ = CacheManager.shared
        _ = OfflineDataManager.shared

        return true
    }

    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = Colors.titleColor
        UITabBar.appearance().tintColor = Colors.titleColor

        UIRefreshControl.appearance().tintColor = Colors.titleColor
    }

    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = NotificationManager.shared

        NotificationManager.shared.checkAuthorizationStatus { isAuthorized in
        }
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Token can be used for push notifications in the future
        _ = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    }

    func application(
        _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
    }
}
