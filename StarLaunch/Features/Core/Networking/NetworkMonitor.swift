//
//  NetworkMonitor.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Combine
import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.starlaunch.networkmonitor", qos: .utility)

    @Published private(set) var isConnected = true
    @Published private(set) var connectionType: ConnectionType = .unknown
    @Published private(set) var isExpensive = false
    @Published private(set) var isConstrained = false

    private var cancellables = Set<AnyCancellable>()

    enum ConnectionType: String {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case unknown = "Unknown"

        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .unknown: return "questionmark.circle"
            }
        }
    }

    private init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
                self?.isConstrained = path.isConstrained
                self?.connectionType = self?.getConnectionType(path) ?? .unknown

            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .unknown
    }

    func waitForConnection(timeout: TimeInterval = 10) async -> Bool {
        if isConnected { return true }

        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?

            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                cancellable?.cancel()
                continuation.resume(returning: false)
            }

            cancellable =
                $isConnected
                .filter { $0 }
                .first()
                .sink { _ in
                    timeoutTask.cancel()
                    continuation.resume(returning: true)
                }
        }
    }
}
