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

    private lazy var diskCacheURL: URL? = {
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = path.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }()

    private func safeFileName(from url: NSURL) -> String? {
        guard let urlString = url.absoluteString else { return url.lastPathComponent }
        var safeName = urlString
        let invalidChars = CharacterSet(charactersIn: "/\\:*?\"<>|")
        if var encodedString = urlString.addingPercentEncoding(withAllowedCharacters: invalidChars.inverted) {
            let extention = (url as URL).pathExtension
            if !extention.isEmpty && !encodedString.lowercased().hasSuffix(".\(extention.lowercased())") {
                encodedString += ".\(extention)"
            }

            safeName = encodedString
        }

        return safeName
    }

    private func diskCachePath(for url: NSURL) -> URL? {
        guard let diskCacheURL, let name = safeFileName(from: url) else { return nil }
        return diskCacheURL.appendingPathComponent(name)
    }

    private func loadFromDisk(for url: NSURL) -> UIImage? {
        guard let fileURL = diskCachePath(for: url),
              FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    private func storeToDisk(data: Data, for url: NSURL) {
        guard let fileURL = diskCachePath(for: url) else { return }
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Disk cache store error:", error)
        }
    }

    private final func image(url: NSURL) -> UIImage? {
        return cacheImages.object(forKey: url)
    }

    final func load(url: NSURL, targetSize: CGSize?) -> AnyPublisher<UIImage?, APIError> {
        if let cachedImage = image(url: url) {
            return Just(cachedImage)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        if let diskCachedImage = loadFromDisk(for: url) {
            cacheImages.setObject(diskCachedImage, forKey: url)
            return Just(diskCachedImage)
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
                        self?.storeToDisk(data: output.data, for: url)
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
        if let diskCacheURL = diskCacheURL {
            try? FileManager.default.removeItem(at: diskCacheURL)
            try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
        }
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
