//
//  Spacecraft.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import Foundation

struct SpacecraftResponse: Codable {
    let results: [Spacecraft]
}

struct Spacecraft: Codable, Identifiable {
    let id: Int
    let name: String
    let spacecraftConfig: SpacecraftConfig

    var imageUrl: String? {
        return spacecraftConfig.imageUrl
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case spacecraftConfig = "spacecraft_config"
    }
}

struct SpacecraftConfig: Codable {
    let id: Int
    let name: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case imageUrl = "image_url"
    }
}
