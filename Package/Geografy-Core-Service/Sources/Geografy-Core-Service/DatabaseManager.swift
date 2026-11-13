import Foundation
import Observation
import OSLog
import SwiftData

@Observable
public final class DatabaseManager {
    public let container: ModelContainer
    /// True when the on-disk store couldn't be opened and this session runs on a temporary
    /// in-memory store. The file on disk is left untouched so a later build can still migrate it.
    public let isUsingFallbackStore: Bool

    @MainActor
    public var mainContext: ModelContext { container.mainContext }

    public convenience init(inMemory: Bool = false) {
        self.init(storeURL: nil, inMemory: inMemory)
    }

    init(storeURL: URL?, inMemory: Bool) {
        let schema = Schema(versionedSchema: GeografySchemaV3.self)
        do {
            container = try ModelContainer(
                for: schema,
                migrationPlan: GeografyMigrationPlan.self,
                configurations: [Self.configuration(schema: schema, storeURL: storeURL, inMemory: inMemory)]
            )
            isUsingFallbackStore = false
        } catch {
            Self.logger.error("Store failed to open, using memory for this session: \(error.localizedDescription)")
            container = Self.makeInMemoryContainer(schema: schema)
            isUsingFallbackStore = true
        }
    }
}

// MARK: - Helpers
private extension DatabaseManager {
    static let logger = Logger(subsystem: "com.khizanag.geografy", category: "Database")

    static func configuration(schema: Schema, storeURL: URL?, inMemory: Bool) -> ModelConfiguration {
        if let storeURL {
            return ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
        }
        return ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
    }

    static func makeInMemoryContainer(schema: Schema) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // An in-memory store with a schema that just compiled cannot fail to open.
            fatalError("In-memory store failed to open: \(error)")
        }
    }
}
