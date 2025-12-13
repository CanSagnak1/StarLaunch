//
//  Launch.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

struct LaunchesResponse: Codable {
    let next: String?
    let results: [LaunchItem]
}

struct LaunchItem: Codable, Identifiable {
    let id: String
    let name: String
    let windowStart: String
    let provider: LaunchServiceProvider
    let pad: Pad
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, pad, image
        case windowStart = "window_start"
        case provider = "launch_service_provider"
    }
}

struct LaunchServiceProvider: Codable {
    let name: String
    let type: String?
}

struct Pad: Codable {
    let name: String
    let location: Location
}

struct Location: Codable {
    let name: String
    let countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case countryCode = "country_code"
    }
}
