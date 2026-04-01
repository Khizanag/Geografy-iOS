import Foundation
import GeografyCore
import Observation
import SwiftData

@Observable
final class FavoritesService {
    private(set) var entries: [FavoriteEntry] = []
    private let modelContext: ModelContext

    init(container: ModelContainer) {
        self.modelContext = ModelContext(container)
    }

    var favoriteCodes: Set<String> {
        Set(entries.map(\.countryCode))
    }

    func toggle(code: String) {
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

    func isFavorite(code: String) -> Bool {
        entries.contains { $0.countryCode == code }
    }

    func addedAt(code: String) -> Date? {
        entries.first { $0.countryCode == code }?.addedAt
    }
}

// MARK: - Helpers
private extension FavoritesService {
    func fetchEntries() {
        let descriptor = FetchDescriptor<FavoriteEntry>()
        entries = (try? modelContext.fetch(descriptor)) ?? []
    }

    func save() {
        try? modelContext.save()
    }
}
