//
//  FavoritesManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Combine
import Foundation

final class FavoritesManager {
    nonisolated(unsafe) static let shared = FavoritesManager()

    private let userDefaultsKey = "favorite_launches"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published private(set) var favoriteIDs: Set<String> = []
    @Published private(set) var favoriteLaunches: [LaunchItem] = []

    private init() {
        loadFavorites()
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let ids = try? decoder.decode(Set<String>.self, from: data)
        {
            favoriteIDs = ids
        }
        loadFavoriteLaunches()
    }

    private func saveFavorites() {
        if let data = try? encoder.encode(favoriteIDs) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
        loadFavoriteLaunches()
    }

    private func loadFavoriteLaunches() {
        let launchesKey = "favorite_launches_objects"
        if let data = UserDefaults.standard.data(forKey: launchesKey),
            let launches = try? decoder.decode([LaunchItem].self, from: data)
        {
            favoriteLaunches = launches.filter { favoriteIDs.contains($0.id) }
        }
    }

    private func saveFavoriteLaunches() {
        let launchesKey = "favorite_launches_objects"
        if let data = try? encoder.encode(favoriteLaunches) {
            UserDefaults.standard.set(data, forKey: launchesKey)
        }
    }

    func isFavorite(_ launchID: String) -> Bool {
        favoriteIDs.contains(launchID)
    }

    func addFavorite(_ launch: LaunchItem) {
        guard !favoriteIDs.contains(launch.id) else { return }

        favoriteIDs.insert(launch.id)

        if !favoriteLaunches.contains(where: { $0.id == launch.id }) {
            favoriteLaunches.append(launch)
            saveFavoriteLaunches()
        }

        saveFavorites()

    }

    func removeFavorite(_ launchID: String) {
        guard favoriteIDs.contains(launchID) else { return }

        favoriteIDs.remove(launchID)
        favoriteLaunches.removeAll { $0.id == launchID }
        saveFavoriteLaunches()
        saveFavorites()

    }

    func toggleFavorite(_ launch: LaunchItem) {
        if isFavorite(launch.id) {
            removeFavorite(launch.id)
        } else {
            addFavorite(launch)
        }
    }

    func clearAllFavorites() {
        favoriteIDs.removeAll()
        favoriteLaunches.removeAll()
        saveFavorites()
        saveFavoriteLaunches()

    }

    var favoritesCount: Int {
        favoriteIDs.count
    }
}
