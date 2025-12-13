//
//  Agency.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import Foundation

struct AgenciesResponse: Codable {
    let results: [Agency]
}

struct Agency: Codable, Identifiable {
    let id: Int
    let name: String
    let logoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoUrl = "logo_url"
    }
}
