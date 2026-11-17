import Foundation

/// The last few things someone used, such as compared countries or converted currencies: newest first, no
/// repeats, kept per user.
public struct RecentList<Item: Codable> {
    // MARK: - Properties
    public let limit: Int
    private let storageKey: String
    private let defaults: UserDefaults
    private let isRepeat: (Item, Item) -> Bool

    // MARK: - Init
    /// - Parameters:
    ///   - storageKey: Scoped to the signed-in user when read or written.
    ///   - isRepeat: Whether two items are the same entry, such as one pair and its reverse.
    public init(
        storageKey: String,
        limit: Int,
        defaults: UserDefaults = .standard,
        isRepeat: @escaping (Item, Item) -> Bool
    ) {
        self.storageKey = storageKey
        self.limit = limit
        self.defaults = defaults
        self.isRepeat = isRepeat
    }

    // MARK: - Storage
    public func load() -> [Item] {
        defaults.decoded([Item].self, forKey: key) ?? []
    }

    public func save(_ items: [Item]) {
        defaults.setEncoded(Array(items.prefix(limit)), forKey: key)
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }

    // MARK: - Adding
    /// `items` with `item` first, any repeat of it dropped, and at most `limit` kept.
    public func adding(_ item: Item, to items: [Item]) -> [Item] {
        Array(([item] + items.filter { !isRepeat($0, item) }).prefix(limit))
    }

    private var key: String { UserScope.key(storageKey) }
}

public extension RecentList where Item: Equatable {
    init(storageKey: String, limit: Int, defaults: UserDefaults = .standard) {
        self.init(storageKey: storageKey, limit: limit, defaults: defaults, isRepeat: ==)
    }
}
