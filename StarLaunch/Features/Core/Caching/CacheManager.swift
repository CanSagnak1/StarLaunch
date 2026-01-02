//
//  CacheManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import CommonCrypto
import Foundation

final class CacheManager {
    nonisolated(unsafe) static let shared = CacheManager()

    private let memoryCache = NSCache<NSString, CacheEntry>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private class CacheEntry: NSObject {
        let data: Data
        let timestamp: Date
        let expirationInterval: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > expirationInterval
        }

        init(data: Data, expirationInterval: TimeInterval = 300) {
            self.data = data
            self.timestamp = Date()
            self.expirationInterval = expirationInterval
            super.init()
        }
    }

    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("StarLaunchResponseCache")

        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        memoryCache.countLimit = 50
        memoryCache.totalCostLimit = 10 * 1024 * 1024
    }

    func cache<T: Encodable>(_ object: T, for key: String, expiration: TimeInterval = 300) {
        guard let data = try? encoder.encode(object) else { return }

        let cacheKey = NSString(string: key.md5Hash)
        let entry = CacheEntry(data: data, expirationInterval: expiration)
        memoryCache.setObject(entry, forKey: cacheKey)

        let fileURL = cacheDirectory.appendingPathComponent(key.md5Hash)
        let metadata = CacheMetadata(timestamp: Date(), expiration: expiration)
        let wrapper = CacheWrapper(data: data, metadata: metadata)

        if let wrapperData = try? encoder.encode(wrapper) {
            try? wrapperData.write(to: fileURL)
        }

    }

    func cached<T: Decodable>(for key: String, as type: T.Type) -> T? {
        let cacheKey = NSString(string: key.md5Hash)

        if let entry = memoryCache.object(forKey: cacheKey), !entry.isExpired {
            return try? decoder.decode(T.self, from: entry.data)
        }

        let fileURL = cacheDirectory.appendingPathComponent(key.md5Hash)

        guard let wrapperData = try? Data(contentsOf: fileURL),
            let wrapper = try? decoder.decode(CacheWrapper.self, from: wrapperData),
            !wrapper.isExpired
        else {
            return nil
        }

        let entry = CacheEntry(data: wrapper.data, expirationInterval: wrapper.metadata.expiration)
        memoryCache.setObject(entry, forKey: cacheKey)


        return try? decoder.decode(T.self, from: wrapper.data)
    }

    func remove(for key: String) {
        let cacheKey = NSString(string: key.md5Hash)
        memoryCache.removeObject(forKey: cacheKey)

        let fileURL = cacheDirectory.appendingPathComponent(key.md5Hash)
        try? fileManager.removeItem(at: fileURL)
    }

    func clearAll() {
        memoryCache.removeAllObjects()

        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

    }

    func clearExpired() {
        guard
            let files = try? fileManager.contentsOfDirectory(
                at: cacheDirectory, includingPropertiesForKeys: nil)
        else { return }

        for file in files {
            if let data = try? Data(contentsOf: file),
                let wrapper = try? decoder.decode(CacheWrapper.self, from: data),
                wrapper.isExpired
            {
                try? fileManager.removeItem(at: file)
            }
        }
    }
}

private struct CacheMetadata: Codable {
    let timestamp: Date
    let expiration: TimeInterval
}

private struct CacheWrapper: Codable {
    let data: Data
    let metadata: CacheMetadata

    var isExpired: Bool {
        Date().timeIntervalSince(metadata.timestamp) > metadata.expiration
    }
}

extension String {
    var md5Hash: String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: 16)

        _ = data.withUnsafeBytes { buffer in
            CC_MD5(buffer.baseAddress, CC_LONG(data.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
