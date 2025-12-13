//
//  LaunchDetailViewModel.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

@MainActor
final class LaunchDetailViewModel {
    
    private let launchID: String
    var updateUI: ((LaunchDetail) -> Void)?
    var showError: ((String) -> Void)?
    var updateLoadingStatus: ((Bool) -> Void)?
    
    init(launchID: String) {
        self.launchID = launchID
        print("LaunchDetailViewModel oluşturuldu. ID: \(launchID)")
    }
    
    func fetchLaunchDetail() {
        updateLoadingStatus?(true)
        Task {
            do {
                let urlString = APIConstants.baseURL + "/launch/\(self.launchID)/"
                let launchDetail: LaunchDetail = try await NetworkService.shared.fetch(from: urlString, as: LaunchDetail.self)
                self.updateUI?(launchDetail)
                
            } catch let error as NetworkError {
                let errorMessage: String
                switch error {
                case .invalidURL:
                    errorMessage = "Geçersiz bir URL ile istek yapıldı."
                case .invalidResponse:
                    errorMessage = "Sunucudan beklenmedik bir yanıt geldi."
                case .decodingError:
                    errorMessage = "Gelen veri anlaşılamadı. (JSON format hatası)"
                case .requestFailed(let underlyingError):
                    errorMessage = "İstek başarısız oldu: \(underlyingError.localizedDescription)"
                }
                self.showError?(errorMessage)
                
            } catch {
                self.showError?("Beklenmedik bir hata oluştu: \(error.localizedDescription)")
            }
            self.updateLoadingStatus?(false)
        }
    }
}
