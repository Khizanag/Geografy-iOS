import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import SwiftData
import Testing

@MainActor
@Suite("AuthService user data")
struct AuthServiceDataTests {
    @Test("Signing in from a guest account carries every kind of record to the account")
    func migrationMovesEverything() {
        let database = DatabaseManager(inMemory: true)
        let auth = AuthService(db: database)
        let guest = UUID().uuidString
        let account = UUID().uuidString
        Self.insertRecords(for: guest, in: database)

        auth.migrateGuestData(from: guest, to: account)

        #expect(Self.recordCount(for: guest, in: database) == 0)
        #expect(Self.recordCount(for: account, in: database) == Self.recordsPerUser)
    }

    @Test("Deleting an account removes every kind of record and leaves other users' alone")
    func deletionRemovesEverything() {
        let database = DatabaseManager(inMemory: true)
        let auth = AuthService(db: database)
        let leaving = UUID().uuidString
        let staying = UUID().uuidString
        Self.insertRecords(for: leaving, in: database)
        Self.insertRecords(for: staying, in: database)
        database.mainContext.insert(UserProfile(id: leaving, displayName: "Leaving", isGuest: false))

        auth.deleteAllUserData(for: leaving)

        #expect(Self.recordCount(for: leaving, in: database) == 0)
        #expect(Self.profiles(for: leaving, in: database) == 0)
        #expect(Self.recordCount(for: staying, in: database) == Self.recordsPerUser)
    }
}

// MARK: - Helpers
private extension AuthServiceDataTests {
    static let recordsPerUser = 5

    static func insertRecords(for userID: String, in database: DatabaseManager) {
        let context = database.mainContext
        context.insert(XPRecord(userID: userID, amount: 10, source: "quiz"))
        context.insert(UnlockedAchievement(id: "explorer_5", userID: userID))
        context.insert(FavoriteEntry(countryCode: "FR", userID: userID))
        context.insert(SavedCollection(name: "Trips", userID: userID))
        context.insert(CollectionItem(itemID: "FR", itemType: .country, collectionName: "Trips", userID: userID))
        try? context.save()
    }

    static func recordCount(for userID: String, in database: DatabaseManager) -> Int {
        let context = database.mainContext
        return count(XPRecord.self, #Predicate { $0.userID == userID }, in: context)
            + count(UnlockedAchievement.self, #Predicate { $0.userID == userID }, in: context)
            + count(FavoriteEntry.self, #Predicate { $0.userID == userID }, in: context)
            + count(SavedCollection.self, #Predicate { $0.userID == userID }, in: context)
            + count(CollectionItem.self, #Predicate { $0.userID == userID }, in: context)
    }

    static func profiles(for userID: String, in database: DatabaseManager) -> Int {
        count(UserProfile.self, #Predicate { $0.id == userID }, in: database.mainContext)
    }

    static func count<Model: PersistentModel>(
        _ type: Model.Type,
        _ predicate: Predicate<Model>,
        in context: ModelContext
    ) -> Int {
        (try? context.fetchCount(FetchDescriptor(predicate: predicate))) ?? 0
    }
}
