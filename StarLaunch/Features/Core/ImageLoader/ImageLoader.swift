//
//  ImageLoader.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache: URLCache
    private let session: URLSession

    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024

        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache")

        diskCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024,
            directory: cacheDirectory
        )

        let config = URLSessionConfiguration.default
        config.urlCache = diskCache
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30

        session = URLSession(configuration: config)
    }

    func loadImage(from url: URL, size: CGSize? = nil) async -> UIImage? {
        let cacheKey = url.absoluteString as NSString

        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }

        do {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            let (data, _) = try await session.data(for: request)

            guard var image = UIImage(data: data) else {
                return nil
            }

            if let targetSize = size {
                image = resizeImage(image, to: targetSize)
            }

            let cost = Int(image.size.width * image.size.height * 4)
            memoryCache.setObject(image, forKey: cacheKey, cost: cost)

            return image
        } catch {
            return nil
        }
    }

    func loadImage(from urlString: String, size: CGSize? = nil) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        return await loadImage(from: url, size: size)
    }

    func prefetchImages(urls: [URL]) {
        Task {
            for url in urls {
                _ = await loadImage(from: url)
            }
        }
    }

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let scale = UIScreen.main.scale
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }

    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }

    func clearDiskCache() {
        diskCache.removeAllCachedResponses()
    }

    func clearAllCache() {
        clearMemoryCache()
        clearDiskCache()
    }

    func cachedImage(for url: URL) -> UIImage? {
        let cacheKey = url.absoluteString as NSString
        return memoryCache.object(forKey: cacheKey)
    }
}

extension UIImageView {
    func loadImage(from url: URL?, placeholder: UIImage? = nil) {
        self.image = placeholder

        guard let url = url else { return }

        Task { @MainActor in
            if let image = await ImageLoader.shared.loadImage(from: url) {
                UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
                    self.image = image
                }
            }
        }
    }

    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        loadImage(from: url, placeholder: placeholder)
    }
}
