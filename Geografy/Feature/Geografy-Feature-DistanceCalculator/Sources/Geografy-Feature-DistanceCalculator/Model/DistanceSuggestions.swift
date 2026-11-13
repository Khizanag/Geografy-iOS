import Foundation
import Geografy_Core_Common
import Geografy_Core_Service

/// A country worth measuring to from the one already picked, with how far its capital is.
struct DistanceSuggestion: Identifiable, Equatable {
    let country: Country
    let distanceKm: Double
    let sharesBorder: Bool

    var id: String { country.code }
}

/// Destinations for the one country picked: the closest capitals, and the farthest for contrast.
struct DistanceSuggestions: Equatable {
    let nearby: [DistanceSuggestion]
    let farAway: [DistanceSuggestion]

    // MARK: - Init
    /// - Parameter coordinate: Where a country's capital is; countries without one are skipped.
    init(
        for country: Country,
        among countries: [Country],
        excluding excludedCode: String? = nil,
        neighbors: [String: [String]] = CountryNeighbors.data,
        coordinate: (String) -> CapitalCoordinateService.Coordinate? = CapitalCoordinateService.coordinate(for:),
        nearbyLimit: Int = 4,
        farAwayLimit: Int = 2
    ) {
        guard let origin = coordinate(country.code) else {
            self.nearby = []
            self.farAway = []
            return
        }
        let neighborCodes = Set(neighbors[country.code] ?? [])

        let byDistance = countries
            .filter { $0.code != country.code && $0.code != excludedCode }
            .compactMap { candidate -> DistanceSuggestion? in
                guard let destination = coordinate(candidate.code) else { return nil }
                return DistanceSuggestion(
                    country: candidate,
                    distanceKm: RouteMetrics(from: origin, to: destination).distanceKm,
                    sharesBorder: neighborCodes.contains(candidate.code)
                )
            }
            .sorted { $0.distanceKm < $1.distanceKm }

        let nearby = Array(byDistance.prefix(nearbyLimit))
        let nearbyCodes = Set(nearby.map(\.id))
        self.nearby = nearby
        self.farAway = byDistance
            .reversed()
            .filter { !nearbyCodes.contains($0.id) }
            .prefix(farAwayLimit)
            .map(\.self)
    }
}
