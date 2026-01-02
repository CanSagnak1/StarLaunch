//
//  APIConstants.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

struct APIConstants {

    private static let baseURL = "https://ll.thespacedevs.com/2.2.0"

    static let starshipDashboard = baseURL + "/dashboard/starship/"
    static let allLaunches = baseURL + "/launch/?limit=1000"
    static let upcomingLaunches = baseURL + "/launch/upcoming/"
    static let agencies = baseURL + "/agencies/?limit=10&featured=true"
    static let starshipVehicles = baseURL + "/spacecraft/?name__icontains=Starship&limit=5"

    static func launchDetail(id: String) -> String {
        return baseURL + "/launch/\(id)/"
    }

    static func upcomingLaunchesWithOffset(offset: Int, limit: Int = 20) -> String {
        return upcomingLaunches + "?limit=\(limit)&offset=\(offset)"
    }
}
