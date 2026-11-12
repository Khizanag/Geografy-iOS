import Geografy_Core_Common
import SwiftData

/// The app store's first versioned schema, identical to the unversioned store it replaces.
///
/// To change a model: copy these types into `GeografySchemaV2` as nested models, edit them there,
/// add V2 to `GeografyMigrationPlan.schemas`, and add a stage from V1 to V2.
public enum GeografySchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [
            CollectionItem.self,
            FavoriteEntry.self,
            QuizHistoryRecord.self,
            StreakRecord.self,
            UnlockedAchievement.self,
            UserProfile.self,
            XPRecord.self,
        ]
    }
}

/// Adds `SavedCollection`, so a collection can exist before anything is saved into it.
public enum GeografySchemaV2: VersionedSchema {
    public static let versionIdentifier = Schema.Version(2, 0, 0)

    public static var models: [any PersistentModel.Type] {
        GeografySchemaV1.models + [SavedCollection.self]
    }
}

// MARK: - Migration Plan
public enum GeografyMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [GeografySchemaV1.self, GeografySchemaV2.self]
    }

    public static var stages: [MigrationStage] {
        [.lightweight(fromVersion: GeografySchemaV1.self, toVersion: GeografySchemaV2.self)]
    }
}
