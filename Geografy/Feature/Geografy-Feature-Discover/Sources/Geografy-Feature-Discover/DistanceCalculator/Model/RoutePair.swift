import Geografy_Core_Common

/// An origin and destination measured together, saved so a recent route can be reopened.
struct RoutePair: Identifiable, Codable, Equatable {
    let originCode: String
    let destinationCode: String

    var id: String { "\(originCode)-\(destinationCode)" }

    init(originCode: String, destinationCode: String) {
        self.originCode = originCode
        self.destinationCode = destinationCode
    }

    init(origin: Country, destination: Country) {
        self.init(originCode: origin.code, destinationCode: destination.code)
    }

    /// The same two countries in either direction, which are the same distance apart.
    func matches(_ other: RoutePair) -> Bool {
        Set([originCode, destinationCode]) == Set([other.originCode, other.destinationCode])
    }
}

// MARK: - Recents
extension RoutePair {
    /// `routes` with `route` moved to the front, its reverse dropped, and at most `limit` kept.
    static func recents(_ routes: [RoutePair], adding route: RoutePair, limit: Int) -> [RoutePair] {
        let others = routes.filter { !$0.matches(route) }
        return Array(([route] + others).prefix(limit))
    }
}
