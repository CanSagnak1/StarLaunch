//
//  Starship.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

struct StarshipDashboardResponse: Codable {
    let upcoming: UpcomingInfo
}

struct UpcomingInfo: Codable {
    let launches: [Launch]
}

struct Launch: Codable {
    let program: [StarshipProgram]
}

struct StarshipProgram: Codable {
    let name: String
    let description: String
    let infoUrl: String?
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case infoUrl = "info_url"
        case imageUrl = "image_url"
    }
}
