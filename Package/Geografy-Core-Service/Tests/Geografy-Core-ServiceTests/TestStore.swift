import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import SwiftData

/// On-disk stores for tests that need a real file, such as migrations.
enum TestStore {
    static func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).store")
    }

    static func remove(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: URL(filePath: url.path() + suffix))
        }
    }

    /// Writes a store exactly as a build shipping `GeografySchemaV2` would have left it.
    static func writeVersionTwoStore(
        at url: URL,
        favoriteCode: String,
        collectionItemID: String,
        collectionName: String
    ) throws {
        let schema = Schema(versionedSchema: GeografySchemaV2.self)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        context.insert(GeografySchemaV2.FavoriteEntry(countryCode: favoriteCode))
        let item = GeografySchemaV2.CollectionItem(
            itemID: collectionItemID,
            itemType: "country",
            collectionName: collectionName
        )
        context.insert(item)
        context.insert(GeografySchemaV2.SavedCollection(name: collectionName))
        try context.save()
    }
}
