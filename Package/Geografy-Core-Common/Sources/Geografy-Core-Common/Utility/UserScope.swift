import Foundation
import Synchronization

/// Who the app's saved data belongs to. Stores key their data by the active user, so signing in
/// or switching accounts shows that person's own progress.
public enum UserScope {
    // MARK: - Properties
    private static let activeUserID = Mutex("")

    public static var currentUserID: String {
        activeUserID.withLock { $0 }
    }

    // MARK: - Activation
    /// Call at launch, before any store loads, and again whenever the user changes.
    public static func activate(_ userID: String) {
        activeUserID.withLock { $0 = userID }
    }

    // MARK: - Keys
    /// The `UserDefaults` key for `base` under the active user.
    ///
    /// Data saved before storage was per user sits under the bare `base` key; the first user to read it
    /// takes it over, so nobody loses progress when they update.
    public static func key(_ base: String, defaults: UserDefaults = .standard) -> String {
        let scopedKey = base + suffix(for: currentUserID)
        if defaults.object(forKey: scopedKey) == nil, let legacyValue = defaults.object(forKey: base) {
            defaults.set(legacyValue, forKey: scopedKey)
            defaults.removeObject(forKey: base)
        }
        return scopedKey
    }

    // MARK: - Moving and Removing
    /// Hands everything `oldUserID` stored to `newUserID`, as when a guest signs in. A key the new user already
    /// has keeps their own value, so signing in on a second device never overwrites the account's progress.
    public static func moveData(from oldUserID: String, to newUserID: String, defaults: UserDefaults = .standard) {
        let oldSuffix = suffix(for: oldUserID)
        for (key, value) in defaults.dictionaryRepresentation() where key.hasSuffix(oldSuffix) {
            let newKey = String(key.dropLast(oldSuffix.count)) + suffix(for: newUserID)
            if defaults.object(forKey: newKey) == nil {
                defaults.set(value, forKey: newKey)
            }
            defaults.removeObject(forKey: key)
        }
    }

    /// Removes everything `userID` stored, as when the account is deleted.
    public static func removeData(of userID: String, defaults: UserDefaults = .standard) {
        let userSuffix = suffix(for: userID)
        for key in defaults.dictionaryRepresentation().keys where key.hasSuffix(userSuffix) {
            defaults.removeObject(forKey: key)
        }
    }

    private static func suffix(for userID: String) -> String {
        ".user.\(userID)"
    }
}
