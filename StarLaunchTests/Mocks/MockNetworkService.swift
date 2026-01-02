//
//  MockNetworkService.swift
//  StarLaunchTests
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Foundation

@testable import StarLaunch

final class MockNetworkService: NetworkServiceProtocol {

    var mockData: Data?
    var mockError: Error?
    var fetchCallCount = 0
    var lastRequestedURL: String?
    var shouldSimulateDelay = false
    var delaySeconds: TimeInterval = 0.5

    func fetch<T: Decodable>(from urlString: String, as type: T.Type) async throws -> T {
        fetchCallCount += 1
        lastRequestedURL = urlString

        if shouldSimulateDelay {
            try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
        }

        if let error = mockError {
            throw error
        }

        guard let data = mockData else {
            throw NetworkError.invalidResponse
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func fetchWithRetry<T: Decodable>(from urlString: String, as type: T.Type, policy: RetryPolicy)
        async throws -> T
    {
        return try await fetch(from: urlString, as: type)
    }

    func reset() {
        mockData = nil
        mockError = nil
        fetchCallCount = 0
        lastRequestedURL = nil
        shouldSimulateDelay = false
    }

    func setMockResponse<T: Encodable>(_ response: T) {
        mockData = try? JSONEncoder().encode(response)
    }
}

final class MockFavoritesManager {
    var favoriteIDs: Set<String> = []

    func isFavorite(_ launchID: String) -> Bool {
        favoriteIDs.contains(launchID)
    }

    func addFavorite(_ launchID: String) {
        favoriteIDs.insert(launchID)
    }

    func removeFavorite(_ launchID: String) {
        favoriteIDs.remove(launchID)
    }

    func toggleFavorite(_ launchID: String) {
        if isFavorite(launchID) {
            removeFavorite(launchID)
        } else {
            addFavorite(launchID)
        }
    }
}

final class MockAnalyticsService: AnalyticsServiceProtocol {
    var trackedEvents: [(name: String, parameters: [String: Any]?)] = []
    var trackedScreens: [String] = []
    var trackedErrors: [(error: Error, context: [String: Any]?)] = []

    func trackEvent(_ name: String, parameters: [String: Any]?) {
        trackedEvents.append((name: name, parameters: parameters))
    }

    func trackScreen(_ name: String) {
        trackedScreens.append(name)
    }

    func trackError(_ error: Error, context: [String: Any]?) {
        trackedErrors.append((error: error, context: context))
    }

    func setUserProperty(_ value: String?, forName name: String) {
    }

    func reset() {
        trackedEvents.removeAll()
        trackedScreens.removeAll()
        trackedErrors.removeAll()
    }
}
