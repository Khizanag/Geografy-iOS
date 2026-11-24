import Geografy_Core_DesignSystem
import SwiftUI

/// A popular or recent route: "Japan → Australia" with both flags, its capitals and how far apart they are.
struct RouteRow: View {
    let route: CapitalRoute
    let action: () -> Void

    var body: some View {
        FlagPairRow(
            leftFlagCode: route.origin.code,
            rightFlagCode: route.destination.code,
            title: "\(route.origin.name) → \(route.destination.name)",
            subtitle: subtitle,
            accessibilityLabel: accessibilityText,
            action: action
        )
    }
}

// MARK: - Helpers
private extension RouteRow {
    var capitals: String {
        "\(route.origin.routePlaceName) to \(route.destination.routePlaceName)"
    }

    var subtitle: String {
        guard let metrics = route.metrics else { return capitals }
        return "\(capitals) · \(DistanceFormat.kilometers(metrics.distanceKm))"
    }

    var accessibilityText: String {
        let countries = "\(route.origin.name) to \(route.destination.name)"
        guard let metrics = route.metrics else { return countries }
        return "\(countries), \(DistanceFormat.number(metrics.distanceKm)) kilometers"
    }
}

// MARK: - Menu
extension RowListMenu where Item == CapitalRoute {
    /// A route's long press: its two capitals and how far apart they are, then Open, Copy, Share, and Remove.
    static func routes(open: @escaping (CapitalRoute) -> Void, remove: ((CapitalRoute) -> Void)? = nil) -> Self {
        RowListMenu(open: open, text: shareText, remove: remove) { route in
            FlagPairPreview(
                leftFlagCode: route.origin.code,
                rightFlagCode: route.destination.code,
                title: "\(route.origin.name) → \(route.destination.name)",
                subtitle: "\(route.origin.routePlaceName) to \(route.destination.routePlaceName)",
                figure: route.metrics.map { DistanceFormat.kilometers($0.distanceKm) }
            )
        }
    }

    private static func shareText(_ route: CapitalRoute) -> String {
        let places = "\(route.origin.routePlaceName) to \(route.destination.routePlaceName)"
        guard let metrics = route.metrics else { return places }
        return "\(places): \(DistanceFormat.kilometers(metrics.distanceKm))"
    }
}
