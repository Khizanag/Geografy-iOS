import Foundation
import Geografy_Core_Common
import Observation

/// What the user has looked at: countries whose detail page they opened, and organizations they read about. Kept
/// per user, so explorer and continent achievements, and the Profile tab's count, read one set.
@Observable
public final class ExplorationService {
    public private(set) var exploredCountryCodes: Set<String>
    public private(set) var openedOrganizationIDs: Set<String>

    private static let countriesKey = "explored_countries"
    private static let organizationsKey = "opened_organizations"

    public init() {
        exploredCountryCodes = Self.loadCountries()
        openedOrganizationIDs = Self.load(Self.organizationsKey)
    }

    /// Loads the active user's sets; call after the user changes.
    public func reload() {
        exploredCountryCodes = Self.loadCountries()
        openedOrganizationIDs = Self.load(Self.organizationsKey)
    }

    /// Records a country's detail page as seen. Returns whether it was new to the user.
    @discardableResult
    public func markExplored(_ code: String) -> Bool {
        guard exploredCountryCodes.insert(code).inserted else { return false }
        Self.save(exploredCountryCodes, key: Self.countriesKey)
        return true
    }

    /// Records an organization's page as read. Returns whether it was new to the user.
    @discardableResult
    public func markOpened(organizationID: String) -> Bool {
        guard openedOrganizationIDs.insert(organizationID).inserted else { return false }
        Self.save(openedOrganizationIDs, key: Self.organizationsKey)
        return true
    }
}

// MARK: - Storage
private extension ExplorationService {
    static func load(_ base: String) -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: UserScope.key(base)) ?? [])
    }

    static func save(_ values: Set<String>, key base: String) {
        UserDefaults.standard.set(Array(values), forKey: UserScope.key(base))
    }

    /// Countries were once kept under `explored_countries_<user ID>`; that set is moved under the scoped key the
    /// first time it's read, so nobody's progress is lost.
    static func loadCountries() -> Set<String> {
        let defaults = UserDefaults.standard
        let legacyKey = "\(countriesKey)_\(UserScope.currentUserID)"
        let scopedKey = UserScope.key(countriesKey)
        if defaults.object(forKey: scopedKey) == nil, let legacy = defaults.stringArray(forKey: legacyKey) {
            defaults.set(legacy, forKey: scopedKey)
            defaults.removeObject(forKey: legacyKey)
        }
        return Set(defaults.stringArray(forKey: scopedKey) ?? [])
    }
}
