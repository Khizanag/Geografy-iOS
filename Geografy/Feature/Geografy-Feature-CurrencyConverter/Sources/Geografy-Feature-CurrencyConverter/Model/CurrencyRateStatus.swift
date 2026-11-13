import Foundation

/// Where the rate on screen came from, so the card can say how fresh it is.
enum CurrencyRateStatus: Equatable, Sendable {
    case loading
    /// No rate yet and none cached: offline on first use.
    case unavailable
    case live(updated: Date?)
    /// The last fetch failed, so these are older cached rates.
    case cached(updated: Date?)

    init(hasRate: Bool, isLoading: Bool, hasError: Bool, lastUpdated: Date?) {
        if !hasRate {
            self = isLoading ? .loading : .unavailable
        } else if hasError {
            self = .cached(updated: lastUpdated)
        } else {
            self = .live(updated: lastUpdated)
        }
    }
}
