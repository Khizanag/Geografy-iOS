import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The measured route: the distance itself, the route on a map, then what that distance compares to.
struct DistanceResultView: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let origin: Country
    let destination: Country
    let metrics: RouteMetrics

    @ScaledMetric(relativeTo: .body) private var factIconWidth: CGFloat = 28

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            DistanceHeroCard(origin: origin, destination: destination, metrics: metrics)
            mapCard
            SectionHeaderView(title: "In Perspective")
                .padding(.top, DesignSystem.Spacing.sm)
            factsCard
        }
    }
}

// MARK: - Subviews
private extension DistanceResultView {
    var mapCard: some View {
        CardView {
            DistanceMapView(
                origin: RouteMapView.Endpoint(countryCode: origin.code, label: origin.routePlaceName),
                destination: RouteMapView.Endpoint(countryCode: destination.code, label: destination.routePlaceName)
            )
            .id("\(origin.code)-\(destination.code)")
            .frame(height: DesignSystem.Size.Card.regular)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Map of the route from \(origin.routePlaceName) to \(destination.routePlaceName)")
        .accessibilityAddTraits(.isImage)
    }

    var factsCard: some View {
        RowListCard(facts, dividerInset: RowListCardLayout.dividerInset(after: factIconWidth)) { fact in
            factRow(fact)
        }
    }

    func factRow(_ fact: RouteFact) -> some View {
        let isStacked = dynamicTypeSize.isAccessibilitySize
        let layout = isStacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.xxs))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        return HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: fact.icon)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: factIconWidth)
                .accessibilityHidden(true)
            layout {
                Text(fact.title)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                if !isStacked {
                    Spacer(minLength: DesignSystem.Spacing.sm)
                }
                Text(fact.value)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(isStacked ? .leading : .trailing)
            }
        }
        .rowListCardRow()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Facts
private extension DistanceResultView {
    struct RouteFact: Identifiable {
        let icon: String
        let title: String
        let value: String

        var id: String { title }
    }

    var facts: [RouteFact] {
        [
            RouteFact(icon: "bolt.fill", title: "Light covers it in", value: lightTime),
            RouteFact(
                icon: "speaker.wave.3.fill",
                title: "At the speed of sound",
                value: duration(metrics.soundDuration, units: [.hours, .minutes])
            ),
            RouteFact(
                icon: "figure.walk",
                title: "Walking non-stop",
                value: duration(metrics.walkingDuration, units: [.days, .hours])
            ),
        ]
    }

    var lightTime: String {
        let milliseconds = metrics.lightMilliseconds.formatted(.number.precision(.fractionLength(1)))
        return "\(milliseconds) ms"
    }

    func duration(_ duration: Duration, units: Set<Duration.UnitsFormatStyle.Unit>) -> String {
        duration.formatted(.units(allowed: units, width: .abbreviated, maximumUnitCount: 2))
    }
}
