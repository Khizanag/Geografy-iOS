import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
public final class FavoritesService {
    private(set) var entries: [FavoriteEntry] = []
    private let modelContext: ModelContext

    public init(container: ModelContainer) {
        self.modelContext = ModelContext(container)
    }

    public var favoriteCodes: Set<String> {
        Set(entries.map(\.countryCode))
    }

    public func toggle(code: String) {
        if let existing = entries.first(where: { $0.countryCode == code }) {
            modelContext.delete(existing)
            entries.removeAll { $0.countryCode == code }
        } else {
            let entry = FavoriteEntry(countryCode: code)
            modelContext.insert(entry)
            entries.append(entry)
        }
        save()
    }

    public func isFavorite(code: String) -> Bool {
        entries.contains { $0.countryCode == code }
    }

    public func addedAt(code: String) -> Date? {
        entries.first { $0.countryCode == code }?.addedAt
    }
}

// MARK: - Helpers
extension FavoritesService {
    public func fetchEntries() {
        let descriptor = FetchDescriptor<FavoriteEntry>()
        entries = (try? modelContext.fetch(descriptor)) ?? []
    }

    public func save() {
        try? modelContext.save()
    }
}
