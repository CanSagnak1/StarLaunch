//
//  NetworkService.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    func fetch<T: Decodable>(from urlString: String, as type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                       if let httpResponse = response as? HTTPURLResponse {
                           print("BAŞARISIZ HTTP DURUM KODU: \(httpResponse.statusCode)")
                       }
                       throw NetworkError.invalidResponse
                   }
            
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
            
        } catch let error as NetworkError {
            throw error
        } catch {
            if error is Swift.DecodingError {
                throw NetworkError.decodingError(error)
            } else {
                throw NetworkError.requestFailed(error)
            }
        }
    }
}
