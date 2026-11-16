import Foundation
import Geografy_Core_Common

/// The last few pairs the person converted, kept per user.
enum CurrencyRecents {
    static let limit = 5
    static let storageKey = "currency_recent_pairs"

    /// Puts `pair` first, dropping an earlier entry for the same two currencies in either direction.
    static func inserting(
        _ pair: CurrencyPair,
        into recents: [CurrencyPair],
        limit: Int = CurrencyRecents.limit
    ) -> [CurrencyPair] {
        let others = recents.filter { !$0.matches(pair) }
        return Array(([pair] + others).prefix(limit))
    }

    static func load(
        from defaults: UserDefaults = .standard,
        key: String = UserScope.key(CurrencyRecents.storageKey)
    ) -> [CurrencyPair] {
        guard let data = defaults.data(forKey: key),
              let pairs = try? JSONDecoder().decode([CurrencyPair].self, from: data) else {
            return []
        }
        return pairs
    }

    static func save(
        _ pairs: [CurrencyPair],
        to defaults: UserDefaults = .standard,
        key: String = UserScope.key(CurrencyRecents.storageKey)
    ) {
        guard let data = try? JSONEncoder().encode(pairs) else { return }
        defaults.set(data, forKey: key)
    }
}
