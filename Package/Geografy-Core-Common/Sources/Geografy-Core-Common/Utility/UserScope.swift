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
        let scopedKey = "\(base).user.\(currentUserID)"
        if defaults.object(forKey: scopedKey) == nil, let legacyValue = defaults.object(forKey: base) {
            defaults.set(legacyValue, forKey: scopedKey)
            defaults.removeObject(forKey: base)
        }
        return scopedKey
    }
}
