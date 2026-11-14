import Foundation
@testable import Geografy_Feature_Travel
import Testing
import UIKit

@MainActor
@Suite("TravelJournalPhotoCache")
struct TravelJournalPhotoCacheTests {
    @Test("Scales a stored photo so its shorter side just covers the request")
    func scalesStoredPhoto() async throws {
        let url = try Self.writePhoto(width: 1_200, height: 900)
        defer { try? FileManager.default.removeItem(at: url) }

        let image = try #require(await TravelJournalPhotoCache.shared.image(at: url, minimumPixelSide: 100))
        let size = Self.pixelSize(of: image)

        #expect(min(size.width, size.height) >= 100)
        #expect(max(size.width, size.height) < 300)
        #expect(size.width > size.height)
    }

    @Test("Never scales a photo above its stored size")
    func keepsSmallPhotoAtStoredSize() async throws {
        let url = try Self.writePhoto(width: 300, height: 200)
        defer { try? FileManager.default.removeItem(at: url) }

        let image = try #require(await TravelJournalPhotoCache.shared.image(at: url, minimumPixelSide: 2_000))

        #expect(Self.pixelSize(of: image) == CGSize(width: 300, height: 200))
    }

    @Test("A second request for a nearby size reuses the first copy")
    func reusesCachedCopy() async throws {
        let url = try Self.writePhoto(width: 800, height: 600)
        defer { try? FileManager.default.removeItem(at: url) }

        let first = try #require(await TravelJournalPhotoCache.shared.image(at: url, minimumPixelSide: 200))
        let cached = TravelJournalPhotoCache.shared.cachedImage(at: url, minimumPixelSide: 210)

        #expect(cached === first)
    }

    @Test("Loads several photos in the order asked, with nil for a missing one")
    func loadsSeveralInOrder() async throws {
        let wide = try Self.writePhoto(width: 400, height: 200)
        let tall = try Self.writePhoto(width: 200, height: 400)
        let missing = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).jpg")
        defer {
            try? FileManager.default.removeItem(at: wide)
            try? FileManager.default.removeItem(at: tall)
        }

        let images = await TravelJournalPhotoCache.shared.images(at: [wide, missing, tall], minimumPixelSide: 100)

        #expect(images.count == 3)
        #expect(images[1] == nil)
        let first = try #require(images[0])
        let last = try #require(images[2])
        #expect(Self.pixelSize(of: first).width > Self.pixelSize(of: first).height)
        #expect(Self.pixelSize(of: last).height > Self.pixelSize(of: last).width)
    }

    @Test("Scales a new pick from its data")
    func scalesData() async throws {
        let data = try #require(Self.jpegData(width: 1_000, height: 1_000))

        let image = try #require(await TravelJournalPhotoCache.image(from: data, minimumPixelSide: 128))

        #expect(Self.pixelSize(of: image).width < 1_000)
        #expect(Self.pixelSize(of: image).width >= 128)
    }
}

// MARK: - Helpers
private extension TravelJournalPhotoCacheTests {
    static func jpegData(width: CGFloat, height: CGFloat) -> Data? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        let image = renderer.image { context in
            UIColor.systemTeal.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        return image.jpegData(compressionQuality: 0.8)
    }

    static func writePhoto(width: CGFloat, height: CGFloat) throws -> URL {
        let data = try #require(jpegData(width: width, height: height))
        let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).jpg")
        try data.write(to: url)
        return url
    }

    static func pixelSize(of image: UIImage) -> CGSize {
        CGSize(width: image.cgImage?.width ?? 0, height: image.cgImage?.height ?? 0)
    }
}
