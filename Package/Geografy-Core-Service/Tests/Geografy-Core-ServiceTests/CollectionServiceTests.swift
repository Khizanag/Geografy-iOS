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

    @Test("A created collection exists while empty and takes its name")
    func createsEmptyCollection() {
        let service = Self.makeService()

        service.createCollection(named: "Wishlist")

        #expect(service.collectionNames == ["Wishlist"])
        #expect(service.itemCount(in: "Wishlist") == 0)
        #expect(!service.isAvailableName("wishlist"))
    }

    @Test("Creating a collection with a taken name does nothing")
    func ignoresDuplicateCreate() {
        let service = Self.makeService()
        service.createCollection(named: "Wishlist")

        service.createCollection(named: "WISHLIST")

        #expect(service.savedCollections.count == 1)
    }

    @Test("Deleting an empty collection removes it")
    func deletesEmptyCollection() {
        let service = Self.makeService()
        service.createCollection(named: "Wishlist")

        service.deleteCollection("Wishlist")

        #expect(service.collectionNames.isEmpty)
    }

    @Test("Renaming moves both the collection and its items")
    func renamesCollectionAndItems() {
        let service = Self.makeService()
        service.createCollection(named: "Wishlist")
        service.add(itemID: "FR", type: .country, to: "Wishlist")

        service.renameCollection(from: "Wishlist", to: "Someday")

        #expect(service.collectionNames == ["Someday"])
        #expect(service.itemCount(in: "Someday") == 1)
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
