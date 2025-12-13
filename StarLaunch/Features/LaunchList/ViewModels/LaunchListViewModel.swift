//
//  LaunchListViewModel.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation
import Combine

final class LaunchListViewModel {
    
    @Published private(set) var launchItems: [LaunchItem] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    private var nextURL: String?
    private var canLoadMorePages = true
    private let initialURL = "https://lldev.thespacedevs.com/2.2.0/launch/upcoming/"
    
    func fetchLaunches() {
        guard !isLoading, canLoadMorePages else { return }
        
        isLoading = true
        
        let urlToFetch = nextURL ?? initialURL
        
        Task {
            do {
                let response = try await NetworkService.shared.fetch(from: urlToFetch, as: LaunchesResponse.self)
                
                await MainActor.run {
                    self.launchItems.append(contentsOf: response.results)
                    
                    self.nextURL = response.next
                    
                    if response.next == nil {
                        self.canLoadMorePages = false
                    }
                    
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Fırlatma listesi alınamadı: \(error.localizedDescription)"
                    self.isLoading = false
                    print("HATA: \(error)")
                }
            }
        }
    }
}
