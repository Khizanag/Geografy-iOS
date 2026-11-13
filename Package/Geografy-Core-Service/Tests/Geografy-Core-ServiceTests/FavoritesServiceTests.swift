import Foundation
import Geografy_Core_Common
@testable import Geografy_Core_Service
import SwiftData
import Testing

@MainActor
@Suite("FavoritesService")
struct FavoritesServiceTests {
    @Test("A favorite one user saves doesn't show for another")
    func favoritesArePerUser() {
        let database = DatabaseManager(inMemory: true)
        let first = FavoritesService(container: database.container, userID: UUID().uuidString)
        first.toggle(code: "FR")

        let second = FavoritesService(container: database.container, userID: UUID().uuidString)
        second.fetchEntries()

        #expect(second.favoriteCodes.isEmpty)
        #expect(!second.isFavorite(code: "FR"))
    }

    @Test("Switching back to a user brings back their favorites")
    func switchingUserReloads() {
        let firstUser = UUID().uuidString
        let service = FavoritesService(container: DatabaseManager(inMemory: true).container, userID: firstUser)
        service.toggle(code: "FR")

        service.switchUser(id: UUID().uuidString)
        #expect(service.favoriteCodes.isEmpty)
        service.toggle(code: "JP")

        service.switchUser(id: firstUser)
        #expect(service.favoriteCodes == ["FR"])
    }

    @Test("Favorites saved before they were per user go to the first user who loads them")
    func legacyFavoritesGoToFirstUser() throws {
        let database = DatabaseManager(inMemory: true)
        database.mainContext.insert(FavoriteEntry(countryCode: "FR", userID: ""))
        try database.mainContext.save()

        let first = FavoritesService(container: database.container, userID: UUID().uuidString)
        first.fetchEntries()
        let second = FavoritesService(container: database.container, userID: UUID().uuidString)
        second.fetchEntries()

        #expect(first.favoriteCodes == ["FR"])
        #expect(second.favoriteCodes.isEmpty)
    }
}
