import SwiftData

/// The journal store's first versioned schema, identical to the unversioned store it replaces.
/// Change the model through a new version and a migration stage, never in place.
enum TravelJournalSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [TravelJournalEntry.self]
    }
}

// MARK: - Migration Plan
enum TravelJournalMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TravelJournalSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
