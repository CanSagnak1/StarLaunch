//
//  RetryPolicy.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Foundation

struct RetryPolicy {
    let maxRetries: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval
    let retryableStatusCodes: Set<Int>

    static let `default` = RetryPolicy(
        maxRetries: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        retryableStatusCodes: [408, 429, 500, 502, 503, 504]
    )

    static let aggressive = RetryPolicy(
        maxRetries: 5,
        baseDelay: 0.5,
        maxDelay: 60.0,
        retryableStatusCodes: [408, 429, 500, 502, 503, 504]
    )

    static let none = RetryPolicy(
        maxRetries: 0,
        baseDelay: 0,
        maxDelay: 0,
        retryableStatusCodes: []
    )

    func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(2, Double(attempt))
        let jitter = Double.random(in: 0..<1) * 0.5
        return min(exponentialDelay + jitter, maxDelay)
    }

    func shouldRetry(for error: NetworkError, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }
        return error.isRetryable
    }

    func shouldRetry(for statusCode: Int) -> Bool {
        return retryableStatusCodes.contains(statusCode)
    }
}
