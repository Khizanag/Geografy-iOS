import Foundation
import Geografy_Core_Common
import Observation

@Observable
public final class TravelService {
    public private(set) var entries: [String: TravelStatus] {
        didSet { updateCodeSets() }
    }
    /// Kept beside `entries` so screens reading them on every render don't filter the whole dictionary.
    public private(set) var visitedCodes: Set<String> = []
    public private(set) var wantToVisitCodes: Set<String> = []

    private let storageKey = "travel_tracker_entries"

    public init() {
        entries = Self.loadEntries(storageKey: storageKey)
        updateCodeSets()
    }

    /// Loads the active user's entries; call after the user changes.
    public func reload() {
        entries = Self.loadEntries(storageKey: storageKey)
    }

    public func set(status: TravelStatus?, for code: String) {
        if let status {
            entries[code] = status
        } else {
            entries.removeValue(forKey: code)
        }
        persist()
    }

    public func status(for code: String) -> TravelStatus? {
        entries[code]
    }
}

// MARK: - Helpers
private extension TravelService {
    func updateCodeSets() {
        visitedCodes = Set(entries.filter { $0.value == .visited }.keys)
        wantToVisitCodes = Set(entries.filter { $0.value == .wantToVisit }.keys)
    }

    func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: UserScope.key(storageKey))
    }

    static func loadEntries(storageKey: String) -> [String: TravelStatus] {
        guard let data = UserDefaults.standard.data(forKey: UserScope.key(storageKey)),
              let raw = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return raw.compactMapValues { TravelStatus(rawValue: $0) }
    }
}
