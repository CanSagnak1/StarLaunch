//
//  LaunchListViewModelTests.swift
//  StarLaunchTests
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Combine
import XCTest

@testable import StarLaunch

@MainActor
final class LaunchListViewModelTests: XCTestCase {

    var sut: LaunchListViewModel!
    var mockNetworkService: MockNetworkService!
    var mockAnalyticsService: MockAnalyticsService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockAnalyticsService = MockAnalyticsService()
        cancellables = Set<AnyCancellable>()

        sut = LaunchListViewModel(
            networkService: mockNetworkService,
            offlineDataManager: OfflineDataManager.shared,
            favoritesManager: FavoritesManager.shared,
            searchManager: SearchManager(),
            analyticsService: mockAnalyticsService
        )
    }

    override func tearDown() {
        cancellables = nil
        mockNetworkService.reset()
        mockAnalyticsService.reset()
        sut = nil
        mockNetworkService = nil
        mockAnalyticsService = nil
        super.tearDown()
    }

    func test_fetchLaunches_success_updatesLaunchItems() async {
        let mockResponse = createMockLaunchesResponse(count: 5)
        mockNetworkService.setMockResponse(mockResponse)

        let expectation = XCTestExpectation(description: "Launches fetched")

        sut.$launchItems
            .dropFirst()
            .sink { items in
                if items.count == 5 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.fetchLaunches()

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(sut.launchItems.count, 5)
        XCTAssertFalse(sut.isLoading)
    }

    func test_fetchLaunches_failure_setsErrorMessage() async {
        mockNetworkService.mockError = NetworkError.noInternetConnection

        let expectation = XCTestExpectation(description: "Error received")

        sut.$errorMessage
            .dropFirst()
            .compactMap { $0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.fetchLaunches()

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_fetchLaunches_whileLoading_doesNotFetchAgain() async {
        let mockResponse = createMockLaunchesResponse(count: 5)
        mockNetworkService.setMockResponse(mockResponse)
        mockNetworkService.shouldSimulateDelay = true
        mockNetworkService.delaySeconds = 1.0

        sut.fetchLaunches()
        sut.fetchLaunches()
        sut.fetchLaunches()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockNetworkService.fetchCallCount, 1)
    }

    func test_search_updatesFilteredLaunches() async {
        let mockResponse = createMockLaunchesResponse(count: 10)
        mockNetworkService.setMockResponse(mockResponse)

        let expectation = XCTestExpectation(description: "Launches fetched")

        sut.$launchItems
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.fetchLaunches()

        await fulfillment(of: [expectation], timeout: 2.0)

        sut.search("Launch 0")

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertTrue(sut.isSearching)
    }

    func test_refreshLaunches_clearsExistingData() async {
        let initialResponse = createMockLaunchesResponse(count: 5)
        mockNetworkService.setMockResponse(initialResponse)

        sut.fetchLaunches()

        try? await Task.sleep(nanoseconds: 500_000_000)

        let refreshedResponse = createMockLaunchesResponse(count: 3)
        mockNetworkService.setMockResponse(refreshedResponse)

        let expectation = XCTestExpectation(description: "Refresh completed")

        sut.$isRefreshing
            .dropFirst()
            .filter { !$0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.refreshLaunches()

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertEqual(sut.launchItems.count, 3)
    }

    func test_toggleFavorite_callsFavoritesManager() {
        let launch = createMockLaunchItem(id: "test-123")

        let initialState = sut.isFavorite(launch.id)

        sut.toggleFavorite(launch)

        XCTAssertNotEqual(sut.isFavorite(launch.id), initialState)
    }

    func test_resetFilters_clearsSearchState() async {
        sut.search("Test Query")

        XCTAssertTrue(sut.isSearching)

        sut.resetFilters()

        XCTAssertFalse(sut.isSearching)
    }

    private func createMockLaunchesResponse(count: Int) -> LaunchesResponse {
        let launches = (0..<count).map { index in
            createMockLaunchItem(id: "launch-\(index)")
        }
        return LaunchesResponse(next: nil, results: launches)
    }

    private func createMockLaunchItem(id: String) -> LaunchItem {
        LaunchItem(
            id: id,
            name: "Test Launch \(id)",
            windowStart: "2026-01-15T12:00:00Z",
            provider: LaunchServiceProvider(name: "SpaceX", type: "Commercial"),
            pad: Pad(
                name: "LC-39A",
                location: Location(name: "Kennedy Space Center", countryCode: "US")
            ),
            image: nil
        )
    }
}
