import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import SwiftData
import Testing

@MainActor
@Suite("DatabaseManager")
struct DatabaseManagerTests {
    @Test("A store created before versioning opens with its data intact")
    func opensUnversionedStore() throws {
        let url = Self.temporaryStoreURL()
        defer { Self.removeStore(at: url) }
        try Self.writeLegacyStore(at: url, streakUserID: "legacy-user")

        let manager = DatabaseManager(storeURL: url, inMemory: false)

        #expect(!manager.isUsingFallbackStore)
        let records = try manager.mainContext.fetch(FetchDescriptor<StreakRecord>())
        #expect(records.map(\.userID) == ["legacy-user"])
    }

    @Test("Data saved in one session is there in the next")
    func persistsAcrossSessions() throws {
        let url = Self.temporaryStoreURL()
        defer { Self.removeStore(at: url) }

        let first = DatabaseManager(storeURL: url, inMemory: false)
        first.mainContext.insert(StreakRecord(userID: "user", date: .now))
        try first.mainContext.save()

        let second = DatabaseManager(storeURL: url, inMemory: false)
        #expect(try second.mainContext.fetchCount(FetchDescriptor<StreakRecord>()) == 1)
    }

    @Test("An unreadable store falls back to memory and is left on disk")
    func unreadableStoreFallsBack() throws {
        let url = Self.temporaryStoreURL()
        defer { Self.removeStore(at: url) }
        let garbage = Data("not a database".utf8)
        try garbage.write(to: url)

        let manager = DatabaseManager(storeURL: url, inMemory: false)

        #expect(manager.isUsingFallbackStore)
        #expect(try Data(contentsOf: url) == garbage)
    }
}

// MARK: - Helpers
private extension DatabaseManagerTests {
    static func temporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).store")
    }

    static func removeStore(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: URL(filePath: url.path() + suffix))
        }
    }

    // Mirrors how the store was opened before versioning: a plain schema and no migration plan.
    static func writeLegacyStore(at url: URL, streakUserID: String) throws {
        let schema = Schema([
            CollectionItem.self,
            FavoriteEntry.self,
            QuizHistoryRecord.self,
            StreakRecord.self,
            UnlockedAchievement.self,
            UserProfile.self,
            XPRecord.self,
        ])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        context.insert(StreakRecord(userID: streakUserID, date: .now))
        try context.save()
    }
}
