import Foundation
import GeografyCore
import Observation

@Observable
final class TravelService {
    private(set) var entries: [String: TravelStatus]

    private let storageKey = "travel_tracker_entries"

    init() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let raw = try? JSONDecoder().decode([String: String].self, from: data) else {
            entries = [:]
            return
        }
        entries = raw.compactMapValues { TravelStatus(rawValue: $0) }
    }

    func set(status: TravelStatus?, for code: String) {
        if let status {
            entries[code] = status
        } else {
            entries.removeValue(forKey: code)
        }
        persist()
    }

    func status(for code: String) -> TravelStatus? {
        entries[code]
    }

    var visitedCodes: Set<String> {
        Set(entries.filter { $0.value == .visited }.keys)
    }

    var wantToVisitCodes: Set<String> {
        Set(entries.filter { $0.value == .wantToVisit }.keys)
    }
}

// MARK: - Helpers
private extension TravelService {
    func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
