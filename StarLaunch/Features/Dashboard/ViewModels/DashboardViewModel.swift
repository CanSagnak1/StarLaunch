//
//  DashboardViewModel.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation
import Combine

final class DashboardViewModel {
    
    @Published private(set) var programInfo: StarshipProgram?
    @Published private(set) var errorMessage: String?
    @Published private(set) var launchCount: Int = 0
    @Published private(set) var successRate: Int = 0
    @Published private(set) var agencies: [Agency] = []
    @Published private(set) var starshipVehicles: [Spacecraft] = []
    @Published private(set) var isLoading: Bool = false
    
    private let starshipAPIUrl = APIConstants.starshipDashboard
    private let allLaunchesAPIUrl = APIConstants.allLaunches
    private let agenciesAPIUrl = APIConstants.agencies
    private let starshipVehiclesAPIUrl = APIConstants.starshipVehicles
    
    func fetchStarshipData() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                async let starshipResponse = NetworkService.shared.fetch(from: starshipAPIUrl, as: StarshipDashboardResponse.self)
                
                async let launchStatsResponse = NetworkService.shared.fetch(from: allLaunchesAPIUrl, as: LaunchStatResponse.self)
                
                async let agenciesResponse = try? NetworkService.shared.fetch(from: agenciesAPIUrl, as: AgenciesResponse.self)
                
                async let starshipVehiclesResponse = try? NetworkService.shared.fetch(from: starshipVehiclesAPIUrl, as: SpacecraftResponse.self)
                
                let (starshipData, launchStatsData, agenciesData, starshipVehiclesData) = try await (starshipResponse, launchStatsResponse, agenciesResponse, starshipVehiclesResponse)
                
                let totalLaunches = launchStatsData.count
                let successfulLaunches = launchStatsData.results.filter { $0.status.id == 3 }.count
                let rate = totalLaunches > 0 ? Int((Double(successfulLaunches) / Double(totalLaunches)) * 100) : 0
                
                await MainActor.run {
                    self.programInfo = starshipData.upcoming.launches.first?.program.first
                    self.launchCount = totalLaunches
                    self.successRate = rate
                    
                    if let agenciesData = agenciesData {
                        self.agencies = agenciesData.results.filter { $0.logoUrl != nil }
                    }
                    
                    if let starshipVehiclesData = starshipVehiclesData {
                        self.starshipVehicles = starshipVehiclesData.results.filter { $0.imageUrl != nil }
                    }
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ana veriler yüklenemedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin."
                    self.isLoading = false
                    print("HATA DETAYI: \(error)")
                }
            }
        }
    }
}
