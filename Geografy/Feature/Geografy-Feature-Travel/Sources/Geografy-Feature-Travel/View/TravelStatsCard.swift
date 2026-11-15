import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct TravelStatsCard: View {
    // MARK: - Properties
    public let visitedCount: Int
    public let wantToVisitCount: Int
    public let totalCountries: Int
    public let continentBreakdown: [(name: String, visited: Int, total: Int)]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            CardView {
                heroStats
                    .padding(DesignSystem.Spacing.md)
            }
            .accessibilityElement(children: .combine)
            statsRow
            if !continentBreakdown.isEmpty {
                CardView {
                    continentSection
                        .padding(DesignSystem.Spacing.md)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

// MARK: - Subviews
private extension TravelStatsCard {
    var visitedFraction: Double {
        guard totalCountries > 0 else { return 0 }
        return Double(visitedCount) / Double(totalCountries)
    }

    var progressAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.8, dampingFraction: 0.7)
    }

    var heroStats: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.lg))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.xl))
        return layout {
            worldRing
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                statLine(
                    icon: TravelStatus.visited.icon,
                    color: TravelStatus.visited.color,
                    label: "Visited",
                    value: "\(visitedCount)"
                )
                statLine(
                    icon: TravelStatus.wantToVisit.icon,
                    color: TravelStatus.wantToVisit.color,
                    label: "Want to Visit",
                    value: "\(wantToVisitCount)"
                )
            }
            Spacer(minLength: 0)
        }
    }

    var worldRing: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Color.cardBackgroundHighlighted, lineWidth: 8)
                .frame(width: 96, height: 96)
            Circle()
                .trim(from: 0, to: visitedFraction)
                .stroke(
                    TravelStatus.visited.color,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 96, height: 96)
                .rotationEffect(.degrees(-90))
                .animation(progressAnimation, value: visitedFraction)
            VStack(spacing: 1) {
                Text("\(Int(visitedFraction * 100))%")
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("of world")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("World visited")
        .accessibilityValue("\(Int(visitedFraction * 100)) percent")
    }

    func statLine(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(color)
                .frame(width: 16)
                .accessibilityHidden(true)
            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            Text(value)
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var statsRow: some View {
        StatTileRow {
            StatTile(
                value: "\(visitedCount)",
                label: "Countries",
                icon: TravelStatus.visited.icon,
                color: TravelStatus.visited.color
            )
            StatTile(
                value: "\(totalCountries - visitedCount)",
                label: "Remaining",
                icon: "circle.dashed",
                color: DesignSystem.Color.textSecondary
            )
            StatTile(
                value: "\(visitedContinents)",
                label: "Continents",
                icon: "globe.europe.africa.fill",
                color: DesignSystem.Color.accent
            )
        }
    }

    var visitedContinents: Int {
        Set(continentBreakdown.filter { $0.visited > 0 }.map { $0.name }).count
    }

    var continentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            EyebrowLabel("By Continent")
            ForEach(continentBreakdown, id: \.name) { item in
                continentRow(item)
            }
        }
    }

    func continentRow(_ item: (name: String, visited: Int, total: Int)) -> some View {
        let fraction = item.total > 0 ? Double(item.visited) / Double(item.total) : 0.0
        return VStack(spacing: DesignSystem.Spacing.xxs) {
            HStack {
                Text(item.name)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                Text("\(item.visited)/\(item.total)")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    Capsule()
                        .fill(TravelStatus.visited.color)
                        .frame(width: geo.size.width * fraction)
                        .animation(
                            reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.6, dampingFraction: 0.7),
                            value: fraction
                        )
                }
            }
            .frame(height: 5)
            .accessibilityHidden(true)
        }
    }
}
