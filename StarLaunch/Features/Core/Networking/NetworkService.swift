//
//  NetworkService.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 8.10.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from urlString: String, as type: T.Type) async throws -> T
    func fetchWithRetry<T: Decodable>(from urlString: String, as type: T.Type, policy: RetryPolicy)
        async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    nonisolated(unsafe) static let shared = NetworkService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let networkMonitor = NetworkMonitor.shared

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "User-Agent": "StarLaunch/1.0 iOS",
        ]

        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func fetch<T: Decodable>(from urlString: String, as type: T.Type) async throws -> T {
        guard networkMonitor.isConnected else {
            throw NetworkError.noInternetConnection
        }

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadRevalidatingCacheData


        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }


            if httpResponse.statusCode == 429 {
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    .flatMap { TimeInterval($0) }
                throw NetworkError.rateLimited(retryAfter: retryAfter)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8)
                throw NetworkError.serverError(
                    statusCode: httpResponse.statusCode, message: message)
            }

            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData

        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternetConnection
            case .timedOut:
                throw NetworkError.timeout
            case .cancelled:
                throw NetworkError.cancelled
            default:
                throw NetworkError.requestFailed(error)
            }
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    func fetchWithRetry<T: Decodable>(
        from urlString: String,
        as type: T.Type,
        policy: RetryPolicy = .default
    ) async throws -> T {
        var lastError: NetworkError?

        for attempt in 0...policy.maxRetries {
            do {
                return try await fetch(from: urlString, as: type)
            } catch let error as NetworkError {
                lastError = error


                guard policy.shouldRetry(for: error, attempt: attempt) else {
                    throw error
                }

                if attempt < policy.maxRetries {
                    let delay = policy.delay(for: attempt)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? NetworkError.requestFailed(NSError(domain: "Unknown", code: -1))
    }
}
