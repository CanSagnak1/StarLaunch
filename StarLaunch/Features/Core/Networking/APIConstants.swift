//
//  APIConstants.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

struct APIConstants {
    static let baseURL = "https://ll.thespacedevs.com/2.2.0"
    static let starshipDashboard = baseURL + "/dashboard/starship/"
    static let allLaunches = baseURL + "/launch/?limit=1000"
    static let agencies = baseURL + "/agencies/?limit=10&featured=true"
    static let starshipVehicles = baseURL + "/spacecraft/?name__icontains=Starship&limit=5"

}
