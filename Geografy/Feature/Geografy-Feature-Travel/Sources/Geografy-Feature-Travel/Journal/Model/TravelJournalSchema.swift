import Foundation
import SwiftData

/// The journal store's first versioned schema, identical to the unversioned store it replaces.
///
/// A version must never point at the live model, or its checksum follows the model when it changes.
/// To change the model: freeze its current shape as a nested model in the newest version, edit the
/// live type, add a version that lists it, and add a stage.
enum TravelJournalSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [TravelJournalEntry.self]
    }

    @Model
    final class TravelJournalEntry {
        var id: String
        var countryCode: String
        var title: String
        var notes: String
        var rating: Int
        var startDate: Date
        var endDate: Date
        var photoFileNames: [String]
        var createdAt: Date

        init(id: String = UUID().uuidString, countryCode: String, title: String) {
            self.id = id
            self.countryCode = countryCode
            self.title = title
            self.notes = ""
            self.rating = 3
            self.startDate = .now
            self.endDate = .now
            self.photoFileNames = []
            self.createdAt = .now
        }
    }
}

/// Gives each journal entry an owner, so each user sees only their own trips.
enum TravelJournalSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [TravelJournalEntry.self]
    }
}

// MARK: - Migration Plan
enum TravelJournalMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TravelJournalSchemaV1.self, TravelJournalSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: TravelJournalSchemaV1.self, toVersion: TravelJournalSchemaV2.self)]
    }
}
