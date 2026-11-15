import Foundation

/// How much of the device Geografy takes up, in bytes, split the way the Storage screen shows it.
struct StorageUsage: Equatable, Sendable {
    // MARK: - Properties
    /// The app itself: code, maps, flags, and sounds.
    let app: Int64
    /// What the person made: progress, favorites, the travel journal and its photos, and settings.
    let userData: Int64
    /// Downloads that come back on their own, such as statistics and exchange rates.
    let cache: Int64

    var total: Int64 { app + userData + cache }

    static let empty = StorageUsage(app: 0, userData: 0, cache: 0)
}

// MARK: - Reading
extension StorageUsage {
    /// Where each part lives in the app's container.
    struct Locations: Sendable {
        let app: [URL]
        let userData: [URL]
        let cache: [URL]
        /// The folders Clear Cache empties. They're emptied, not removed, since services keep writing into them.
        let clearable: [URL]

        static var device: Locations {
            let fileManager = FileManager.default
            let library = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            return Locations(
                app: [Bundle.main.bundleURL],
                userData: [
                    fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0],
                    fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0],
                    library.appendingPathComponent("Preferences", isDirectory: true),
                ],
                cache: [caches, fileManager.temporaryDirectory],
                clearable: [
                    caches.appendingPathComponent("WorldBank", isDirectory: true),
                    caches.appendingPathComponent("CurrencyRates", isDirectory: true),
                    fileManager.temporaryDirectory,
                ]
            )
        }
    }

    /// Adds up every file in `locations`, off the main thread: an app container holds thousands of files.
    @concurrent
    static func read(from locations: Locations = .device) async -> StorageUsage {
        StorageUsage(
            app: size(of: locations.app),
            userData: size(of: locations.userData),
            cache: size(of: locations.cache)
        )
    }

    /// Empties the downloaded caches and the system's network cache. Progress and the journal are untouched.
    @concurrent
    static func clearCache(in locations: Locations = .device) async {
        let fileManager = FileManager.default
        for folder in locations.clearable {
            let items = (try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
            for item in items {
                try? fileManager.removeItem(at: item)
            }
        }
        URLCache.shared.removeAllCachedResponses()
    }

    /// The disk space the files under `urls` take up, counting each file once.
    static func size(of urls: [URL]) -> Int64 {
        urls.reduce(0) { total, url in total + size(of: url) }
    }

    private static func size(of url: URL) -> Int64 {
        let keys: [URLResourceKey] = [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey]
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
            return 0
        }
        var total: Int64 = 0
        for case let file as URL in enumerator {
            guard let values = try? file.resourceValues(forKeys: Set(keys)), values.isRegularFile == true else {
                continue
            }
            total += Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
        }
        return total
    }
}
