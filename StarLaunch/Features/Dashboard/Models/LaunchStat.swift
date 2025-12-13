//
//  LaunchStat.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 10.10.2025.
//

import Foundation

struct LaunchStatResponse: Codable {
    let count: Int
    let results: [LaunchResult]
}

struct LaunchResult: Codable {
    let status: LaunchStatus
}

struct LaunchStatus: Codable {
    let id: Int
    let name: String
}
