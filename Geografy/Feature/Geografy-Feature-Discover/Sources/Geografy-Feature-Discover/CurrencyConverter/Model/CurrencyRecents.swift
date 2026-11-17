import Foundation
import Geografy_Core_Common

/// The last few pairs the person converted, kept per user.
enum CurrencyRecents {
    /// The same two currencies in either direction count as one entry.
    static func list(defaults: UserDefaults = .standard, limit: Int = 5) -> RecentList<CurrencyPair> {
        RecentList(storageKey: "currency_recent_pairs", limit: limit, defaults: defaults) { $0.matches($1) }
    }
}
