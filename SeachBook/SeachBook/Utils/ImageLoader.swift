//
//  ImageLoader.swift
//  SeachBook
//
//  Created by 이아연 on 8/25/25.
//

import UIKit
import Combine

public class ImageLoader {
    public static let shared = ImageLoader()

    private init() { }

    private let cacheImages: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()

    private final func image(url: NSURL) -> UIImage? {
        return cacheImages.object(forKey: url)
    }

    final func load(url: NSURL, targetSize: CGSize?) -> AnyPublisher<UIImage?, APIError> {
        if let cachedImage = image(url: url) {
            return Just(cachedImage)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        let urlSession = URLSession(configuration: .ephemeral)
        return urlSession.dataTaskPublisher(for: url as URL)
            .tryMap { [weak self] output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw APIError.imageFetchFail("Invalid response")
                }

                switch response.statusCode {
                case (200..<300):
                    var image: UIImage?

                    if let targetSize, targetSize.width > 0, targetSize.height > 0 {
                        image = self?.downsampling(data: output.data, to: targetSize, scale: UIScreen.main.scale)
                    } else {
                        image = UIImage(data: output.data)
                    }

                    if let image {
                        self?.cacheImages.setObject(image, forKey: url, cost: output.data.count)
                        return image
                    } else {
                        throw APIError.convertImageFail
                    }
                default:
                    throw APIError.imageFetchFail("HTTP \(response.statusCode)")
                }
            }
            .mapError { error -> APIError in
                if let error = error as? APIError { return error }
                return APIError.imageFetchFail(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    final func clearCache() {
        cacheImages.removeAllObjects()
    }

    private func downsampling(data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * max(scale, 1)

        let cfData = data as CFData
        guard let source = CGImageSourceCreateWithData(cfData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimensionInPixels),
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
