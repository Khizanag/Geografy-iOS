import Foundation
import Geografy_Core_Common
import SwiftData

/// The app store's first versioned schema, identical to the unversioned store it replaces.
///
/// A version must never point at a live model that later changes, or its checksum drifts and the
/// store can no longer be matched to it. To change a model: freeze its current shape as a nested
/// model in the newest version, edit the live type, add a version that lists it, and add a stage.
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

    @Model
    final class CollectionItem {
        var itemID: String
        var itemType: String
        var collectionName: String
        var addedAt: Date

        init(itemID: String, itemType: String, collectionName: String, addedAt: Date = .now) {
            self.itemID = itemID
            self.itemType = itemType
            self.collectionName = collectionName
            self.addedAt = addedAt
        }
    }

    @Model
    final class FavoriteEntry {
        var countryCode: String
        var addedAt: Date

        init(countryCode: String, addedAt: Date = .now) {
            self.countryCode = countryCode
            self.addedAt = addedAt
        }
    }
}

/// Adds `SavedCollection`, so a collection can exist before anything is saved into it.
public enum GeografySchemaV2: VersionedSchema {
    public static let versionIdentifier = Schema.Version(2, 0, 0)

    typealias CollectionItem = GeografySchemaV1.CollectionItem
    typealias FavoriteEntry = GeografySchemaV1.FavoriteEntry

    public static var models: [any PersistentModel.Type] {
        [
            CollectionItem.self,
            FavoriteEntry.self,
            QuizHistoryRecord.self,
            SavedCollection.self,
            StreakRecord.self,
            UnlockedAchievement.self,
            UserProfile.self,
            XPRecord.self,
        ]
    }

    @Model
    final class SavedCollection {
        var name: String
        var createdAt: Date

        init(name: String, createdAt: Date = .now) {
            self.name = name
            self.createdAt = createdAt
        }
    }
}

/// Gives favorites and collections an owner, so each user sees only their own.
public enum GeografySchemaV3: VersionedSchema {
    public static let versionIdentifier = Schema.Version(3, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [
            CollectionItem.self,
            FavoriteEntry.self,
            QuizHistoryRecord.self,
            SavedCollection.self,
            StreakRecord.self,
            UnlockedAchievement.self,
            UserProfile.self,
            XPRecord.self,
        ]
    }
}

// MARK: - Migration Plan
public enum GeografyMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [GeografySchemaV1.self, GeografySchemaV2.self, GeografySchemaV3.self]
    }

    public static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: GeografySchemaV1.self, toVersion: GeografySchemaV2.self),
            .lightweight(fromVersion: GeografySchemaV2.self, toVersion: GeografySchemaV3.self),
        ]
    }
}
