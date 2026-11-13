import Foundation
import Geografy_Core_Common
import Geografy_Core_Service

/// Two countries as a route between their capitals, ready to show in a row or open.
struct CountryRoute: Identifiable {
    let origin: Country
    let destination: Country

    var id: String { pair.id }

    var pair: RoutePair {
        RoutePair(origin: origin, destination: destination)
    }

    /// Nil when either capital's location is unknown.
    var metrics: RouteMetrics? {
        RouteMetrics(from: origin, to: destination)
    }
}

// MARK: - Place Name
extension Country {
    /// Where a route starts or ends: the capital, or the country itself when it has none on record.
    var routePlaceName: String {
        capital.isEmpty ? name : capital
    }
}

// MARK: - Route Metrics
extension RouteMetrics {
    /// The route between two countries' capitals, or nil when either capital's location is unknown.
    init?(from origin: Country, to destination: Country) {
        guard let start = CapitalCoordinateService.coordinate(for: origin.code),
              let end = CapitalCoordinateService.coordinate(for: destination.code) else { return nil }
        self.init(from: start, to: end)
    }
}

// MARK: - Formatting
enum DistanceFormat {
    /// "5,897", grouped for the current locale.
    static func number(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }

    /// "5,897 km".
    static func kilometers(_ value: Double) -> String {
        measurement(value, unit: .kilometers)
    }

    /// "3,664 mi".
    static func miles(_ value: Double) -> String {
        measurement(value, unit: .miles)
    }

    private static func measurement(_ value: Double, unit: UnitLength) -> String {
        Measurement(value: value, unit: unit).formatted(
            .measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
        )
    }
}
