import Foundation
@testable import Geografy_Feature_Profile
import Testing

@Suite("StorageUsage")
struct StorageUsageTests {
    @Test("Each part adds up the files in its folders, and the total adds the parts")
    func readsEachPart() async throws {
        let folders = try TemporaryFolders()
        defer { folders.remove() }
        try folders.write(bytes: 5_000, to: folders.app, named: "Geografy")
        try folders.write(bytes: 3_000, to: folders.userData, named: "default.store")
        try folders.write(bytes: 2_000, to: folders.downloads, named: "rates.json")

        let usage = await StorageUsage.read(from: folders.locations)

        #expect(usage.app >= 5_000)
        #expect(usage.userData >= 3_000)
        #expect(usage.cache >= 2_000)
        #expect(usage.total == usage.app + usage.userData + usage.cache)
    }

    @Test("Clearing the cache empties the download folders but keeps them and the person's data")
    func clearCacheKeepsData() async throws {
        let folders = try TemporaryFolders()
        defer { folders.remove() }
        try folders.write(bytes: 3_000, to: folders.userData, named: "default.store")
        try folders.write(bytes: 2_000, to: folders.downloads, named: "rates.json")

        await StorageUsage.clearCache(in: folders.locations)

        let fileManager = FileManager.default
        #expect(fileManager.fileExists(atPath: folders.downloads.path))
        #expect(try fileManager.contentsOfDirectory(atPath: folders.downloads.path).isEmpty)
        #expect(fileManager.fileExists(atPath: folders.userData.appendingPathComponent("default.store").path))
    }
}

/// A throwaway container with an app, a data, and a download folder.
private struct TemporaryFolders {
    let root: URL
    let app: URL
    let userData: URL
    let downloads: URL

    var locations: StorageUsage.Locations {
        StorageUsage.Locations(app: [app], userData: [userData], cache: [downloads], clearable: [downloads])
    }

    init() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        app = root.appendingPathComponent("App", isDirectory: true)
        userData = root.appendingPathComponent("Data", isDirectory: true)
        downloads = root.appendingPathComponent("Downloads", isDirectory: true)
        for folder in [app, userData, downloads] {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
    }

    func write(bytes count: Int, to folder: URL, named name: String) throws {
        try Data(count: count).write(to: folder.appendingPathComponent(name))
    }

    func remove() {
        try? FileManager.default.removeItem(at: root)
    }
}
