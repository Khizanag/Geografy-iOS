import Foundation
@testable import Geografy_Feature_Travel
import SwiftData
import Testing

@MainActor
@Suite("TravelJournalService ownership")
struct TravelJournalOwnershipTests {
    @Test("An entry one user writes doesn't show for another")
    func entriesArePerUser() {
        let url = Self.temporaryStoreURL()
        defer { Self.removeStore(at: url) }
        let firstUser = UUID().uuidString
        let first = TravelJournalService(isStoredInMemoryOnly: false, storeURL: url, userID: firstUser)
        first.addEntry(TravelJournalEntry(countryCode: "GE", title: "Tbilisi"))

        let second = TravelJournalService(isStoredInMemoryOnly: false, storeURL: url, userID: UUID().uuidString)
        let firstAgain = TravelJournalService(isStoredInMemoryOnly: false, storeURL: url, userID: firstUser)

        #expect(second.entries.isEmpty)
        #expect(firstAgain.entries.map(\.title) == ["Tbilisi"])
    }

    @Test("A version 1 journal opens as version 2 and its entries go to the first user who loads them")
    func migratesAndClaimsVersionOneJournal() throws {
        let url = Self.temporaryStoreURL()
        defer { Self.removeStore(at: url) }
        try Self.writeVersionOneStore(at: url, title: "Kyoto")

        let first = TravelJournalService(isStoredInMemoryOnly: false, storeURL: url, userID: "first")
        let second = TravelJournalService(isStoredInMemoryOnly: false, storeURL: url, userID: "second")

        #expect(first.entries.map(\.title) == ["Kyoto"])
        #expect(first.entries.map(\.userID) == ["first"])
        #expect(second.entries.isEmpty)
    }
}

// MARK: - Helpers
private extension TravelJournalOwnershipTests {
    static func temporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).store")
    }

    static func removeStore(at url: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: URL(filePath: url.path() + suffix))
        }
    }

    static func writeVersionOneStore(at url: URL, title: String) throws {
        let schema = Schema(versionedSchema: TravelJournalSchemaV1.self)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)]
        )
        let context = ModelContext(container)
        context.insert(TravelJournalSchemaV1.TravelJournalEntry(countryCode: "JP", title: title))
        try context.save()
    }
}
