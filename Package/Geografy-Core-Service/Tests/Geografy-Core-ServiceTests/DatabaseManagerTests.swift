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
        let url = TestStore.temporaryURL()
        defer { TestStore.remove(at: url) }
        try Self.writeLegacyStore(at: url, streakUserID: "legacy-user")

        let manager = DatabaseManager(storeURL: url, inMemory: false)

        #expect(!manager.isUsingFallbackStore)
        let records = try manager.mainContext.fetch(FetchDescriptor<StreakRecord>())
        #expect(records.map(\.userID) == ["legacy-user"])
    }

    @Test("A version 2 store opens as version 3 with its favorites and collections intact and unowned")
    func migratesVersionTwoStore() throws {
        let url = TestStore.temporaryURL()
        defer { TestStore.remove(at: url) }
        try TestStore.writeVersionTwoStore(at: url, favoriteCode: "FR", collectionItemID: "JP", collectionName: "Trips")

        let manager = DatabaseManager(storeURL: url, inMemory: false)

        #expect(!manager.isUsingFallbackStore)
        let favorites = try manager.mainContext.fetch(FetchDescriptor<FavoriteEntry>())
        #expect(favorites.map(\.countryCode) == ["FR"])
        #expect(favorites.map(\.userID) == [""])
        let items = try manager.mainContext.fetch(FetchDescriptor<CollectionItem>())
        #expect(items.map(\.itemID) == ["JP"])
        #expect(items.map(\.collectionName) == ["Trips"])
        #expect(items.map(\.userID) == [""])
        let collections = try manager.mainContext.fetch(FetchDescriptor<SavedCollection>())
        #expect(collections.map(\.name) == ["Trips"])
        #expect(collections.map(\.userID) == [""])
    }

    @Test("After the update, the first user to load takes the version 2 favorites and collections")
    func firstUserClaimsMigratedRows() throws {
        let url = TestStore.temporaryURL()
        defer { TestStore.remove(at: url) }
        try TestStore.writeVersionTwoStore(at: url, favoriteCode: "FR", collectionItemID: "JP", collectionName: "Trips")
        let manager = DatabaseManager(storeURL: url, inMemory: false)

        let firstFavorites = FavoritesService(container: manager.container, userID: "first")
        firstFavorites.fetchEntries()
        let firstCollections = CollectionService()
        firstCollections.configure(container: manager.container, userID: "first")
        let secondFavorites = FavoritesService(container: manager.container, userID: "second")
        secondFavorites.fetchEntries()
        let secondCollections = CollectionService()
        secondCollections.configure(container: manager.container, userID: "second")

        #expect(firstFavorites.favoriteCodes == ["FR"])
        #expect(firstCollections.collectionNames == ["Trips"])
        #expect(firstCollections.items(in: "Trips").map(\.itemID) == ["JP"])
        #expect(secondFavorites.favoriteCodes.isEmpty)
        #expect(secondCollections.collectionNames.isEmpty)
    }

    @Test(
        "Earlier versions keep their own shape, so their checksums never match the current one",
        arguments: ["CollectionItem", "FavoriteEntry", "SavedCollection"]
    )
    func earlierVersionsHaveNoOwner(entityName: String) throws {
        let versionTwo = Schema(versionedSchema: GeografySchemaV2.self)
        let versionThree = Schema(versionedSchema: GeografySchemaV3.self)

        let oldEntity = try #require(versionTwo.entitiesByName[entityName])
        let newEntity = try #require(versionThree.entitiesByName[entityName])
        #expect(oldEntity.attributesByName["userID"] == nil)
        #expect(newEntity.attributesByName["userID"] != nil)
    }

    @Test("Data saved in one session is there in the next")
    func persistsAcrossSessions() throws {
        let url = TestStore.temporaryURL()
        defer { TestStore.remove(at: url) }

        let first = DatabaseManager(storeURL: url, inMemory: false)
        first.mainContext.insert(StreakRecord(userID: "user", date: .now))
        try first.mainContext.save()

        let second = DatabaseManager(storeURL: url, inMemory: false)
        #expect(try second.mainContext.fetchCount(FetchDescriptor<StreakRecord>()) == 1)
    }

    @Test("An unreadable store falls back to memory and is left on disk")
    func unreadableStoreFallsBack() throws {
        let url = TestStore.temporaryURL()
        defer { TestStore.remove(at: url) }
        let garbage = Data("not a database".utf8)
        try garbage.write(to: url)

        let manager = DatabaseManager(storeURL: url, inMemory: false)

        #expect(manager.isUsingFallbackStore)
        #expect(try Data(contentsOf: url) == garbage)
    }
}

// MARK: - Helpers
private extension DatabaseManagerTests {
    // Mirrors how the store was opened before versioning: a plain schema and no migration plan.
    static func writeLegacyStore(at url: URL, streakUserID: String) throws {
        let schema = Schema(GeografySchemaV1.models)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        context.insert(StreakRecord(userID: streakUserID, date: .now))
        try context.save()
    }
}
