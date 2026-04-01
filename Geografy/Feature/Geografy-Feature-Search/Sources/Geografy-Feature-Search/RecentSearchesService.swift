import Foundation

@Observable
public final class RecentSearchesService {
    private(set) var queries: [String] = []

    private let storageKey = "recent_searches"
    private let maxCount = 10

    public init() {
        queries = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
    }

    public func add(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        var updated = queries.filter { $0.lowercased() != trimmed.lowercased() }
        updated.insert(trimmed, at: 0)
        queries = Array(updated.prefix(maxCount))
        persist()
    }

    public func remove(_ query: String) {
        queries.removeAll { $0 == query }
        persist()
    }

    public func clearAll() {
        queries = []
        persist()
    }
}

// MARK: - Persistence
private extension RecentSearchesService {
    func persist() {
        UserDefaults.standard.set(queries, forKey: storageKey)
    }
}
