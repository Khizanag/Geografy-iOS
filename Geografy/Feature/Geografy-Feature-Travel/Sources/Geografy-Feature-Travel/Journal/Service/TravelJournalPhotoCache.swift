import ImageIO
import UIKit

/// Journal photos scaled to the size they're drawn at, decoded off the main thread and kept in memory.
///
/// Photos are stored at camera resolution, up to 48 MP; decoding them full size on the main thread
/// to draw a 48pt thumbnail is what made the journal stutter.
@MainActor
final class TravelJournalPhotoCache {
    // MARK: - Properties
    static let shared = TravelJournalPhotoCache()

    /// Shorter-side pixel sizes a photo is scaled to; a request rounds up to the next one, so nearby sizes share an image.
    private static let pixelSides: [CGFloat] = [128, 256, 512, 1_024, 1_536, 2_048]

    private let images = NSCache<NSString, UIImage>()
    private var loads: [NSString: Task<UIImage?, Never>] = [:]

    // MARK: - Init
    private init() {
        images.totalCostLimit = 64 << 20
    }

    // MARK: - Lookup
    /// The scaled photo if it's ready, without waiting.
    func cachedImage(at url: URL, minimumPixelSide: CGFloat) -> UIImage? {
        images.object(forKey: key(for: url, minimumPixelSide: minimumPixelSide))
    }

    /// The photo scaled so its shorter side is at least `minimumPixelSide`, never above its stored size.
    func image(at url: URL, minimumPixelSide: CGFloat) async -> UIImage? {
        let cacheKey = key(for: url, minimumPixelSide: minimumPixelSide)
        if let image = images.object(forKey: cacheKey) {
            return image
        }
        if let load = loads[cacheKey] {
            return await load.value
        }
        let side = Self.bucket(for: minimumPixelSide)
        let load = Task { await Self.downsample(url: url, minimumPixelSide: side) }
        loads[cacheKey] = load
        let image = await load.value
        loads[cacheKey] = nil
        if let image {
            images.setObject(image, forKey: cacheKey, cost: Self.cost(of: image))
        }
        return image
    }

    /// Several photos at once, decoded in parallel; the result keeps the order of `urls`.
    func images(at urls: [URL], minimumPixelSide: CGFloat) async -> [UIImage?] {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let image = await self.image(at: url, minimumPixelSide: minimumPixelSide)
                    return (index, image)
                }
            }
            var results = [UIImage?](repeating: nil, count: urls.count)
            for await (index, image) in group {
                results[index] = image
            }
            return results
        }
    }

    /// A photo that isn't stored yet, scaled the same way; not kept in the cache.
    static func image(from data: Data, minimumPixelSide: CGFloat) async -> UIImage? {
        await downsample(data: data, minimumPixelSide: minimumPixelSide)
    }
}

// MARK: - Helpers
private extension TravelJournalPhotoCache {
    static func bucket(for pixelSide: CGFloat) -> CGFloat {
        pixelSides.first { $0 >= pixelSide } ?? pixelSides[pixelSides.count - 1]
    }

    static func cost(of image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }

    func key(for url: URL, minimumPixelSide: CGFloat) -> NSString {
        "\(url.lastPathComponent)-\(Int(Self.bucket(for: minimumPixelSide)))" as NSString
    }

    @concurrent
    nonisolated static func downsample(url: URL, minimumPixelSide: CGFloat) async -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return thumbnail(from: source, minimumPixelSide: minimumPixelSide)
    }

    @concurrent
    nonisolated static func downsample(data: Data, minimumPixelSide: CGFloat) async -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return thumbnail(from: source, minimumPixelSide: minimumPixelSide)
    }

    nonisolated static func thumbnail(from source: CGImageSource, minimumPixelSide: CGFloat) -> UIImage? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int,
              width > 0,
              height > 0 else {
            return nil
        }
        let scale = min(1, minimumPixelSide / CGFloat(min(width, height)))
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: (CGFloat(max(width, height)) * scale).rounded(.up),
        ] as CFDictionary
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: thumbnail)
    }
}
