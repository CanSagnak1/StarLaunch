//
//  DependencyContainer.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    lazy var networkService: NetworkServiceProtocol = NetworkService.shared
    lazy var imageLoader: ImageLoader = ImageLoader.shared
    lazy var cacheManager: CacheManager = CacheManager.shared
    lazy var offlineDataManager: OfflineDataManager = OfflineDataManager.shared
    lazy var networkMonitor: NetworkMonitor = NetworkMonitor.shared
    lazy var favoritesManager: FavoritesManager = FavoritesManager.shared
    lazy var analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared
    lazy var notificationManager: NotificationManager = NotificationManager.shared
    lazy var searchManager: SearchManager = SearchManager()

    private init() {}

}
