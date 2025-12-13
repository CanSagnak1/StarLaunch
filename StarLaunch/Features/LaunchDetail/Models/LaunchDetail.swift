//
//  LaunchDetail.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

struct LaunchDetail: Decodable {
    let id: String
    let name: String
    let status: Status
    let net: String
    let launchServiceProvider: LaunchServiceProvider
    let rocket: Rocket
    let mission: Mission?
    let pad: Pad
    let image: String?
    let program: [Program]
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, net, rocket, mission, pad, image, program
        case launchServiceProvider = "launch_service_provider"
    }
}

struct Status: Decodable {
    let name: String
    let description: String?
}

struct Rocket: Decodable {
    let configuration: RocketConfiguration
}

struct RocketConfiguration: Decodable {
    let fullName: String
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
    }
}

struct Mission: Decodable {
    let name: String
    let description: String?
    let type: String?
}

struct Program: Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let crew: [CrewMember]?
}

struct CrewMember: Decodable, Identifiable {
    var id: Int { astronaut.id }
    let role: Role?
    let astronaut: Astronaut
    
    enum CodingKeys: String, CodingKey {
        case role, astronaut
    }
}

struct Role: Decodable {
    let id: Int
    let role: String
    let priority: Int?
}

struct Astronaut: Decodable, Identifiable {
    let id: Int
    let name: String
    let profileImageThumbnail: String
    let status: AstronautStatus?
    let agency: AstronautAgency?
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, agency
        case profileImageThumbnail = "profile_image_thumbnail"
    }
}

struct AstronautStatus: Decodable {
    let id: Int
    let name: String
}

struct AstronautAgency: Decodable {
    let id: Int
    let name: String
}
