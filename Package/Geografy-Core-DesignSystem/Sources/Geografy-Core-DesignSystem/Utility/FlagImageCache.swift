import SwiftUI
import UIKit

/// Flags scaled to the size they're drawn at, decoded off the main thread and kept in memory.
///
/// The flag assets are 1280×960, about 5 MB each once decoded, while lists draw them 36pt tall.
/// Decoding them full size on the main thread is what made scrolling past flags stutter.
@MainActor
public final class FlagImageCache {
    // MARK: - Properties
    public static let shared = FlagImageCache()

    /// Pixel heights a flag is scaled to; a request rounds up to the next one, so nearby sizes share an image.
    /// 112 covers the 36pt list flag at 3x, the size drawn most.
    private static let pixelHeights: [CGFloat] = [48, 72, 112, 160, 256, 480, 640]

    private let images = NSCache<NSString, UIImage>()
    private var loads: [NSString: Task<UIImage?, Never>] = [:]
    private var missingCodes: Set<String> = []
    private var names: [String: String] = [:]

    // MARK: - Init
    private init() {
        images.totalCostLimit = 64 << 20
    }

    // MARK: - Lookup
    /// The scaled flag if it's ready, without waiting.
    public func cachedImage(countryCode: String, pixelHeight: CGFloat) -> UIImage? {
        images.object(forKey: key(countryCode: countryCode, pixelHeight: pixelHeight))
    }

    /// The scaled flag, decoding it off the main thread the first time.
    /// Returns nil when the app has no flag for that code.
    public func image(countryCode: String, pixelHeight: CGFloat) async -> UIImage? {
        let cacheKey = key(countryCode: countryCode, pixelHeight: pixelHeight)
        if let image = images.object(forKey: cacheKey) {
            return image
        }
        if let load = loads[cacheKey] {
            return await load.value
        }
        guard let source = sourceImage(countryCode: countryCode) else { return nil }

        let targetHeight = Self.bucket(for: pixelHeight)
        let targetSize = CGSize(
            width: (targetHeight * source.size.width / source.size.height).rounded(.up),
            height: targetHeight
        )
        let load = Task<UIImage?, Never> {
            if let thumbnail = await source.byPreparingThumbnail(ofSize: targetSize) {
                return thumbnail
            }
            return await source.byPreparingForDisplay()
        }
        loads[cacheKey] = load
        let image = await load.value
        loads[cacheKey] = nil
        if let image {
            images.setObject(image, forKey: cacheKey, cost: Int(targetSize.width * targetSize.height * 4))
        }
        return image
    }

    /// The country's name in `locale`'s language, for the flag's VoiceOver label.
    public func countryName(for countryCode: String, in locale: Locale) -> String {
        let key = "\(locale.identifier)-\(countryCode)"
        if let name = names[key] {
            return name
        }
        let name = locale.localizedString(forRegionCode: countryCode) ?? countryCode.uppercased()
        names[key] = name
        return name
    }

    // MARK: - Prewarm
    /// Decodes list-size flags ahead of time, so the first scroll through a list never waits on one.
    public func prewarm(countryCodes: [String], pointHeight: CGFloat, displayScale: CGFloat) async {
        for code in countryCodes {
            guard !Task.isCancelled else { return }
            _ = await image(countryCode: code, pixelHeight: pointHeight * displayScale)
        }
    }
}

// MARK: - Helpers
private extension FlagImageCache {
    static func bucket(for pixelHeight: CGFloat) -> CGFloat {
        pixelHeights.first { $0 >= pixelHeight } ?? pixelHeights[pixelHeights.count - 1]
    }

    func key(countryCode: String, pixelHeight: CGFloat) -> NSString {
        "\(countryCode.uppercased())-\(Int(Self.bucket(for: pixelHeight)))" as NSString
    }

    func sourceImage(countryCode: String) -> UIImage? {
        let code = countryCode.uppercased()
        guard !missingCodes.contains(code) else { return nil }
        guard let image = UIImage(named: "Flags/\(code)") else {
            missingCodes.insert(code)
            return nil
        }
        return image
    }
}
