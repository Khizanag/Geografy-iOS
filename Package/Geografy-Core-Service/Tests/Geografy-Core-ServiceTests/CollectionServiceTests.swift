import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import SwiftData
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

    @Test("Another user doesn't see a user's collections, and can take the same name")
    func collectionsArePerUser() {
        let firstUser = UUID().uuidString
        let service = Self.makeService(userID: firstUser)
        service.createCollection(named: "Trips")
        service.add(itemID: "FR", type: .country, to: "Trips")

        service.switchUser(id: UUID().uuidString)

        #expect(service.collectionNames.isEmpty)
        #expect(!service.isSaved(itemID: "FR", type: .country))
        #expect(service.isAvailableName("Trips"))
        service.createCollection(named: "Trips")
        #expect(service.itemCount(in: "Trips") == 0)

        service.switchUser(id: firstUser)
        #expect(service.collectionNames == ["Trips"])
        #expect(service.itemCount(in: "Trips") == 1)
    }

    @Test("Deleting a collection leaves another user's collection of the same name")
    func deleteIsPerUser() {
        let firstUser = UUID().uuidString
        let service = Self.makeService(userID: firstUser)
        service.add(itemID: "FR", type: .country, to: "Trips")
        service.switchUser(id: UUID().uuidString)
        service.add(itemID: "JP", type: .country, to: "Trips")

        service.deleteCollection("Trips")

        service.switchUser(id: firstUser)
        #expect(service.items(in: "Trips").map(\.itemID) == ["FR"])
    }

    @Test("Collections saved before they were per user go to the first user who loads them")
    func legacyCollectionsGoToFirstUser() throws {
        let database = DatabaseManager(inMemory: true)
        let legacyItem = CollectionItem(itemID: "FR", itemType: .country, collectionName: "Trips", userID: "")
        database.mainContext.insert(legacyItem)
        database.mainContext.insert(SavedCollection(name: "Wishlist", userID: ""))
        try database.mainContext.save()

        let first = CollectionService()
        first.configure(container: database.container, userID: UUID().uuidString)
        let second = CollectionService()
        second.configure(container: database.container, userID: UUID().uuidString)

        #expect(first.collectionNames == ["Trips", "Wishlist"])
        #expect(first.itemCount(in: "Trips") == 1)
        #expect(second.collectionNames.isEmpty)
    }
}

// MARK: - Helpers
private extension CollectionServiceTests {
    static func makeService(userID: String = UUID().uuidString) -> CollectionService {
        let service = CollectionService()
        service.configure(container: DatabaseManager(inMemory: true).container, userID: userID)
        return service
    }
}
