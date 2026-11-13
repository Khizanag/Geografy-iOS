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
