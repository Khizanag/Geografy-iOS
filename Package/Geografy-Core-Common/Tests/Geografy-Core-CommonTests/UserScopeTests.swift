import Foundation
@testable import Geografy_Core_Common
import Testing

@Suite("UserScope", .serialized)
struct UserScopeTests {
    @Test("Each user gets their own key for the same data")
    func keysDifferPerUser() {
        UserScope.activate("alice")
        let aliceKey = UserScope.key("trips", defaults: Self.makeDefaults())
        UserScope.activate("bob")
        let bobKey = UserScope.key("trips", defaults: Self.makeDefaults())

        #expect(aliceKey != bobKey)
    }

    @Test("Device-wide data from before moves to the first user who reads it")
    func legacyDataMovesToFirstReader() {
        let defaults = Self.makeDefaults()
        defaults.set(["FR"], forKey: "trips")
        UserScope.activate("alice")

        let aliceKey = UserScope.key("trips", defaults: defaults)

        #expect(defaults.stringArray(forKey: aliceKey) == ["FR"])
        #expect(defaults.object(forKey: "trips") == nil)
    }

    @Test("A second user starts empty instead of inheriting the moved data")
    func secondUserStartsEmpty() {
        let defaults = Self.makeDefaults()
        defaults.set(["FR"], forKey: "trips")
        UserScope.activate("alice")
        _ = UserScope.key("trips", defaults: defaults)
        UserScope.activate("bob")

        let bobKey = UserScope.key("trips", defaults: defaults)

        #expect(defaults.object(forKey: bobKey) == nil)
    }

    @Test("Moving data hands a guest's keys to the account and keeps what the account already had")
    func moveData() {
        let defaults = Self.makeDefaults()
        defaults.set("guest trips", forKey: "trips.user.guest")
        defaults.set("guest cards", forKey: "cards.user.guest")
        defaults.set("account cards", forKey: "cards.user.account")
        defaults.set("someone else", forKey: "trips.user.other")

        UserScope.moveData(from: "guest", to: "account", defaults: defaults)

        #expect(defaults.string(forKey: "trips.user.account") == "guest trips")
        #expect(defaults.string(forKey: "cards.user.account") == "account cards")
        #expect(defaults.object(forKey: "trips.user.guest") == nil)
        #expect(defaults.object(forKey: "cards.user.guest") == nil)
        #expect(defaults.string(forKey: "trips.user.other") == "someone else")
    }

    @Test("Removing data clears only that user's keys")
    func removeData() {
        let defaults = Self.makeDefaults()
        defaults.set(1, forKey: "trips.user.leaving")
        defaults.set(2, forKey: "cards.user.leaving")
        defaults.set(3, forKey: "trips.user.staying")

        UserScope.removeData(of: "leaving", defaults: defaults)

        #expect(defaults.object(forKey: "trips.user.leaving") == nil)
        #expect(defaults.object(forKey: "cards.user.leaving") == nil)
        #expect(defaults.integer(forKey: "trips.user.staying") == 3)
    }
}

// MARK: - Helpers
private extension UserScopeTests {
    static func makeDefaults() -> UserDefaults {
        let name = "UserScopeTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? .standard
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
