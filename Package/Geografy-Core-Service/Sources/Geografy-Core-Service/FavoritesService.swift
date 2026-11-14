import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
public final class FavoritesService {
    private(set) var entries: [FavoriteEntry] = [] {
        didSet {
            addedDates = Dictionary(entries.map { ($0.countryCode, $0.addedAt) }) { first, _ in first }
            favoriteCodes = Set(addedDates.keys)
        }
    }
    /// Kept beside `entries` so a list asking about every row never reads the database objects.
    public private(set) var favoriteCodes: Set<String> = []
    private var addedDates: [String: Date] = [:]
    public private(set) var currentUserID: String
    private let modelContext: ModelContext

    public init(container: ModelContainer, userID: String = UserScope.currentUserID) {
        self.modelContext = ModelContext(container)
        self.currentUserID = userID
    }

    public func switchUser(id: String) {
        currentUserID = id
        fetchEntries()
    }

    public func toggle(code: String) {
        if let existing = entries.first(where: { $0.countryCode == code }) {
            modelContext.delete(existing)
            entries.removeAll { $0.countryCode == code }
        } else {
            let entry = FavoriteEntry(countryCode: code, userID: currentUserID)
            modelContext.insert(entry)
            entries.append(entry)
        }
        save()
    }

    public func isFavorite(code: String) -> Bool {
        favoriteCodes.contains(code)
    }

    public func addedAt(code: String) -> Date? {
        addedDates[code]
    }
}

// MARK: - Helpers
extension FavoritesService {
    /// Loads the current user's favorites, first giving them any saved before favorites were per user.
    public func fetchEntries() {
        claimUnownedEntries()
        let userID = currentUserID
        let descriptor = FetchDescriptor<FavoriteEntry>(predicate: #Predicate { $0.userID == userID })
        entries = (try? modelContext.fetch(descriptor)) ?? []
    }

    public func save() {
        try? modelContext.save()
    }
}

// MARK: - Ownership
private extension FavoritesService {
    func claimUnownedEntries() {
        guard !currentUserID.isEmpty else { return }
        let descriptor = FetchDescriptor<FavoriteEntry>(predicate: #Predicate { $0.userID.isEmpty })
        guard let unowned = try? modelContext.fetch(descriptor), !unowned.isEmpty else { return }
        for entry in unowned {
            entry.userID = currentUserID
        }
        save()
    }
}
