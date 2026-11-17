import Foundation
import OSLog
import SwiftData

/// Opens the app's SwiftData stores the one way: versioned and migrated, never synced to CloudKit, and on a
/// temporary in-memory store when the file can't be opened, leaving the file untouched for a later build.
public enum StoreOpener {
    public struct Store {
        public let container: ModelContainer
        /// True when the file couldn't be opened and this session runs in memory.
        public let isFallback: Bool
    }

    /// - Parameters:
    ///   - name: Tells this store's file apart from others in the default location.
    ///   - storeURL: A file of its own, as tests use; nil for the default location.
    public static func open(
        _ versionedSchema: any VersionedSchema.Type,
        migrationPlan: (any SchemaMigrationPlan.Type)?,
        name: String? = nil,
        storeURL: URL? = nil,
        inMemory: Bool = false
    ) -> Store {
        let schema = Schema(versionedSchema: versionedSchema)
        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: migrationPlan,
                configurations: [configuration(schema: schema, name: name, storeURL: storeURL, inMemory: inMemory)]
            )
            return Store(container: container, isFallback: false)
        } catch {
            logger.error("Store \(name ?? "main", privacy: .public) failed to open, using memory: \(error)")
            return Store(container: inMemoryContainer(schema: schema), isFallback: true)
        }
    }
}

// MARK: - Helpers
private extension StoreOpener {
    static let logger = Logger(subsystem: "com.khizanag.geografy", category: "Database")

    static func configuration(schema: Schema, name: String?, storeURL: URL?, inMemory: Bool) -> ModelConfiguration {
        if let storeURL {
            return ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
        }
        if let name {
            return ModelConfiguration(name, schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        }
        return ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
    }

    static func inMemoryContainer(schema: Schema) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // An in-memory store with a schema that just compiled cannot fail to open.
            fatalError("In-memory store failed to open: \(error)")
        }
    }
}
