//
//  NetworkError.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case noInternetConnection
    case timeout
    case rateLimited(retryAfter: TimeInterval?)
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL adresi."
        case .requestFailed(let error):
            return "İstek başarısız: \(error.localizedDescription)"
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt alındı."
        case .decodingError(let error):
            return "Veri işlenemedi: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Sunucu hatası (\(statusCode)): \(message ?? "Bilinmeyen hata")"
        case .noInternetConnection:
            return "İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin."
        case .timeout:
            return "İstek zaman aşımına uğradı."
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Çok fazla istek gönderildi. \(Int(seconds)) saniye sonra tekrar deneyin."
            }
            return "Çok fazla istek gönderildi. Lütfen bekleyin."
        case .cancelled:
            return "İstek iptal edildi."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .invalidURL, .decodingError, .serverError(statusCode: 400..<500, _), .cancelled:
            return false
        case .requestFailed, .invalidResponse, .serverError, .noInternetConnection, .timeout, .rateLimited:
            return true
        }
    }
    
    var userFriendlyMessage: String {
        switch self {
        case .noInternetConnection:
            return "İnternet bağlantınızı kontrol edin ve tekrar deneyin."
        case .timeout:
            return "Bağlantı zaman aşımına uğradı. Tekrar deneyin."
        case .serverError:
            return "Sunucu şu anda yanıt vermiyor. Daha sonra tekrar deneyin."
        case .rateLimited:
            return "Çok fazla istek yaptınız. Biraz bekleyin."
        default:
            return "Bir hata oluştu. Lütfen tekrar deneyin."
        }
    }
}
