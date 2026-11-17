import Foundation
import Observation
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
        let store = StoreOpener.open(
            GeografySchemaV3.self,
            migrationPlan: GeografyMigrationPlan.self,
            storeURL: storeURL,
            inMemory: inMemory
        )
        container = store.container
        isUsingFallbackStore = store.isFallback
    }
}
