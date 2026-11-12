import Geografy_Core_Common
@testable import Geografy_Core_Service
import Testing

@MainActor
@Suite("CollectionService")
struct CollectionServiceTests {
    @Test("A blank name is not available")
    func blankNameIsUnavailable() {
        let service = Self.makeService()

        #expect(!service.isAvailableName(""))
    }

    @Test("A name already in use is not available, in any letter case", arguments: ["Trips", "trips", "TRIPS"])
    func takenNameIsUnavailable(name: String) {
        let service = Self.makeService()
        service.add(itemID: "FR", type: .country, to: "Trips")

        #expect(!service.isAvailableName(name))
    }

    @Test("An unused name is available")
    func unusedNameIsAvailable() {
        let service = Self.makeService()
        service.add(itemID: "FR", type: .country, to: "Trips")

        #expect(service.isAvailableName("Wishlist"))
    }
}

// MARK: - Helpers
private extension CollectionServiceTests {
    static func makeService() -> CollectionService {
        let service = CollectionService()
        service.configure(container: DatabaseManager(inMemory: true).container)
        return service
    }
}
