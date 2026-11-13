import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// The answer: how far apart the two capitals are, in a big number, with flight time and heading under it.
struct DistanceHeroCard: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let origin: Country
    let destination: Country
    let metrics: RouteMetrics

    @ScaledMetric(relativeTo: .largeTitle) private var heroFontSize: CGFloat = 56
    @ScaledMetric(relativeTo: .subheadline) private var endpointDotSize: CGFloat = 8

    // MARK: - Body
    var body: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                routeLine
                distanceBlock
                Divider()
                statsRow
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Subviews
private extension DistanceHeroCard {
    var isStacked: Bool { dynamicTypeSize.isAccessibilitySize }

    /// The two capitals in their side colors, tying the card to the slots above and the map below.
    var routeLine: some View {
        let layout = isStacked
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.xxs))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.xs))
        return layout {
            endpoint(origin, side: .left)
            Image(systemName: isStacked ? "arrow.down" : "arrow.right")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            endpoint(destination, side: .right)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("From \(origin.routePlaceName) to \(destination.routePlaceName)")
    }

    func endpoint(_ country: Country, side: PairSide) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Circle()
                .fill(side.color)
                .frame(width: endpointDotSize, height: endpointDotSize)
            Text(country.routePlaceName)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }

    var distanceBlock: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                Text(DistanceFormat.number(metrics.distanceKm))
                    .font(DesignSystem.Font.system(size: heroFontSize, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("km")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Text(DistanceFormat.miles(metrics.distanceMiles))
                .font(DesignSystem.Font.subheadline)
                .monospacedDigit()
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .contentTransition(.numericText())
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.4), value: metrics.distanceKm)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Distance between capitals")
        .accessibilityValue(spokenDistance)
    }

    var statsRow: some View {
        let layout = isStacked
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.md))
            : AnyLayout(HStackLayout(alignment: .top, spacing: DesignSystem.Spacing.xs))
        return layout {
            ResultStatItem(
                icon: "airplane",
                value: flightTime,
                label: "Flight time",
                color: DesignSystem.Color.textSecondary
            )
            ResultStatItem(
                icon: "safari",
                value: metrics.direction.abbreviation,
                label: "Heading",
                color: DesignSystem.Color.textSecondary
            )
            .accessibilityLabel("Heading \(metrics.direction.name), \(Int(metrics.initialBearing.rounded())) degrees")
            ResultStatItem(
                icon: "globe.europe.africa.fill",
                value: earthShare,
                label: "Of the equator",
                color: DesignSystem.Color.textSecondary
            )
        }
    }
}

// MARK: - Helpers
private extension DistanceHeroCard {
    var spokenDistance: String {
        let kilometers = DistanceFormat.number(metrics.distanceKm)
        let miles = DistanceFormat.number(metrics.distanceMiles)
        return "\(kilometers) kilometers, \(miles) miles"
    }

    var flightTime: String {
        metrics.flightDuration.formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }

    var earthShare: String {
        guard metrics.earthFraction >= 0.01 else { return "<1%" }
        return metrics.earthFraction.formatted(.percent.precision(.fractionLength(0)))
    }
}
