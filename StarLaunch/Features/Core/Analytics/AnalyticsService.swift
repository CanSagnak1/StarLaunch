//
//  AnalyticsService.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Foundation

protocol AnalyticsServiceProtocol {
    func trackEvent(_ name: String, parameters: [String: Any]?)
    func trackScreen(_ name: String)
    func trackError(_ error: Error, context: [String: Any]?)
    func setUserProperty(_ value: String?, forName name: String)
}

extension AnalyticsServiceProtocol {
    func trackEvent(_ name: String) {
        trackEvent(name, parameters: nil)
    }

    func trackError(_ error: Error) {
        trackError(error, context: nil)
    }
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    private var userProperties: [String: String] = [:]
    private let queue = DispatchQueue(label: "com.starlaunch.analytics", qos: .utility)

    private init() {}

    func trackEvent(_ name: String, parameters: [String: Any]? = nil) {
        queue.async {

            // Firebase Analytics, Mixpanel, Amplitude entegrasyonu
            // Analytics.logEvent(name, parameters: parameters)
        }
    }

    func trackScreen(_ name: String) {
        queue.async {

            // Analytics.setScreenName(name, screenClass: nil)
        }
    }

    func trackError(_ error: Error, context: [String: Any]? = nil) {
        queue.async {

            // Crashlytics, Sentry entegrasyonu
            // Crashlytics.recordError(error, userInfo: context)
        }
    }

    func setUserProperty(_ value: String?, forName name: String) {
        queue.async { [weak self] in
            if let value = value {
                self?.userProperties[name] = value
            } else {
                self?.userProperties.removeValue(forKey: name)
            }

            // Analytics.setUserProperty(value, forName: name)
        }
    }
}

enum AnalyticsEvent {
    static let appOpen = "app_open"
    static let viewLaunchList = "view_launch_list"
    static let viewLaunchDetail = "view_launch_detail"
    static let addToFavorites = "add_to_favorites"
    static let removeFromFavorites = "remove_from_favorites"
    static let enableNotification = "enable_notification"
    static let search = "search"
    static let filter = "filter"
    static let refresh = "refresh"
    static let offlineMode = "offline_mode"
    static let networkError = "network_error"
}
