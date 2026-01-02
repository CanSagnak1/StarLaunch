//
//  NetworkServiceTests.swift
//  StarLaunchTests
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import XCTest

@testable import StarLaunch

final class NetworkServiceTests: XCTestCase {

    var sut: MockNetworkService!

    override func setUp() {
        super.setUp()
        sut = MockNetworkService()
    }

    override func tearDown() {
        sut.reset()
        sut = nil
        super.tearDown()
    }

    func test_fetch_success_decodesResponse() async throws {
        let mockLaunches = LaunchesResponse(
            next: nil,
            results: [
                LaunchItem(
                    id: "test-123",
                    name: "Test Launch",
                    windowStart: "2026-01-15T12:00:00Z",
                    provider: LaunchServiceProvider(name: "SpaceX", type: "Commercial"),
                    pad: Pad(
                        name: "LC-39A",
                        location: Location(name: "Kennedy Space Center", countryCode: "US")
                    ),
                    image: nil
                )
            ]
        )
        sut.setMockResponse(mockLaunches)

        let result = try await sut.fetch(from: "https://test.com", as: LaunchesResponse.self)

        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results.first?.id, "test-123")
        XCTAssertEqual(result.results.first?.name, "Test Launch")
        XCTAssertEqual(sut.fetchCallCount, 1)
    }

    func test_fetch_failure_throwsError() async {
        sut.mockError = NetworkError.noInternetConnection

        do {
            _ = try await sut.fetch(from: "https://test.com", as: LaunchesResponse.self)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(
                error.localizedDescription, NetworkError.noInternetConnection.localizedDescription)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetch_invalidData_throwsDecodingError() async {
        sut.mockData = "invalid json".data(using: .utf8)

        do {
            _ = try await sut.fetch(from: "https://test.com", as: LaunchesResponse.self)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DecodingError || error is NetworkError)
        }
    }

    func test_fetch_tracksLastRequestedURL() async throws {
        let mockLaunches = LaunchesResponse(next: nil, results: [])
        sut.setMockResponse(mockLaunches)

        _ = try await sut.fetch(from: "https://api.test.com/launches", as: LaunchesResponse.self)

        XCTAssertEqual(sut.lastRequestedURL, "https://api.test.com/launches")
    }

    func test_fetch_incrementsCallCount() async throws {
        let mockLaunches = LaunchesResponse(next: nil, results: [])
        sut.setMockResponse(mockLaunches)

        _ = try await sut.fetch(from: "https://test.com", as: LaunchesResponse.self)
        _ = try await sut.fetch(from: "https://test.com", as: LaunchesResponse.self)
        _ = try await sut.fetch(from: "https://test.com", as: LaunchesResponse.self)

        XCTAssertEqual(sut.fetchCallCount, 3)
    }
}

final class NetworkErrorTests: XCTestCase {

    func test_isRetryable_noInternetConnection_returnsTrue() {
        let error = NetworkError.noInternetConnection
        XCTAssertTrue(error.isRetryable)
    }

    func test_isRetryable_timeout_returnsTrue() {
        let error = NetworkError.timeout
        XCTAssertTrue(error.isRetryable)
    }

    func test_isRetryable_invalidURL_returnsFalse() {
        let error = NetworkError.invalidURL
        XCTAssertFalse(error.isRetryable)
    }

    func test_isRetryable_decodingError_returnsFalse() {
        let underlyingError = NSError(domain: "Test", code: 0)
        let error = NetworkError.decodingError(underlyingError)
        XCTAssertFalse(error.isRetryable)
    }

    func test_userFriendlyMessage_noInternetConnection() {
        let error = NetworkError.noInternetConnection
        XCTAssertEqual(
            error.userFriendlyMessage, "İnternet bağlantınızı kontrol edin ve tekrar deneyin.")
    }

    func test_userFriendlyMessage_timeout() {
        let error = NetworkError.timeout
        XCTAssertEqual(error.userFriendlyMessage, "Bağlantı zaman aşımına uğradı. Tekrar deneyin.")
    }
}

final class RetryPolicyTests: XCTestCase {

    func test_defaultPolicy_hasCorrectValues() {
        let policy = RetryPolicy.default
        XCTAssertEqual(policy.maxRetries, 3)
        XCTAssertEqual(policy.baseDelay, 1.0)
        XCTAssertEqual(policy.maxDelay, 30.0)
    }

    func test_nonePolicy_hasZeroRetries() {
        let policy = RetryPolicy.none
        XCTAssertEqual(policy.maxRetries, 0)
    }

    func test_delay_increasesExponentially() {
        let policy = RetryPolicy.default

        let delay0 = policy.delay(for: 0)
        let delay1 = policy.delay(for: 1)
        let delay2 = policy.delay(for: 2)

        XCTAssertLessThan(delay0, delay1)
        XCTAssertLessThan(delay1, delay2)
    }

    func test_delay_doesNotExceedMaxDelay() {
        let policy = RetryPolicy.default

        let delay = policy.delay(for: 10)

        XCTAssertLessThanOrEqual(delay, policy.maxDelay)
    }

    func test_shouldRetry_withinMaxRetries_returnsTrue() {
        let policy = RetryPolicy.default
        let error = NetworkError.timeout

        XCTAssertTrue(policy.shouldRetry(for: error, attempt: 0))
        XCTAssertTrue(policy.shouldRetry(for: error, attempt: 1))
        XCTAssertTrue(policy.shouldRetry(for: error, attempt: 2))
    }

    func test_shouldRetry_exceedsMaxRetries_returnsFalse() {
        let policy = RetryPolicy.default
        let error = NetworkError.timeout

        XCTAssertFalse(policy.shouldRetry(for: error, attempt: 3))
    }

    func test_shouldRetry_nonRetryableError_returnsFalse() {
        let policy = RetryPolicy.default
        let error = NetworkError.invalidURL

        XCTAssertFalse(policy.shouldRetry(for: error, attempt: 0))
    }
}
