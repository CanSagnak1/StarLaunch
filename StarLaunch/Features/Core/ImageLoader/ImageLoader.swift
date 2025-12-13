//
//  ImageLoader.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 12.10.2025.
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func loadImage(from url: URL) async -> UIImage? {
        let cacheKey = url.absoluteString as NSString
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                return nil
            }
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            print("ImageLoader Error - loadImage: \(error.localizedDescription)")
            return nil
        }
    }
}
