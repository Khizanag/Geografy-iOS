@testable import Geografy_Feature_Travel
import Testing

@MainActor
@Suite("TravelJournalService")
struct TravelJournalServiceTests {
    @Test("Starts empty without sample trips")
    func startsEmpty() {
        let service = TravelJournalService(isStoredInMemoryOnly: true)

        #expect(service.entries.isEmpty)
    }

    @Test("Edits persist after update")
    func editsPersist() throws {
        let service = TravelJournalService(isStoredInMemoryOnly: true)
        service.addEntry(TravelJournalEntry(countryCode: "GE", title: "Before"))
        let entry = try #require(service.entries.first)

        entry.title = "After"
        entry.rating = 5
        service.updateEntry(entry)

        let reloaded = try #require(service.entries.first)
        #expect(reloaded.title == "After")
        #expect(reloaded.rating == 5)
        #expect(!reloaded.hasChanges)
    }

    @Test("Deleting the last entry leaves the journal empty")
    func deleteLastEntry() throws {
        let service = TravelJournalService(isStoredInMemoryOnly: true)
        service.addEntry(TravelJournalEntry(countryCode: "JP", title: "Trip"))
        let entry = try #require(service.entries.first)

        service.deleteEntry(entry)

        #expect(service.entries.isEmpty)
    }
}
