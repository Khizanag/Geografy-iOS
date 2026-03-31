import SwiftUI
import GeografyDesign
import GeografyCore

struct TravelStatsCard: View {
    let visitedCount: Int
    let wantToVisitCount: Int
    let totalCountries: Int
    let continentBreakdown: [(name: String, visited: Int, total: Int)]

    var body: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                heroStats
                statsPills
                if !continentBreakdown.isEmpty {
                    continentSection
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension TravelStatsCard {
    var visitedFraction: Double {
        guard totalCountries > 0 else { return 0 }
        return Double(visitedCount) / Double(totalCountries)
    }

    var heroStats: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
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
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: visitedFraction)
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
    }

    func statLine(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(color)
                .frame(width: 16)
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

    var statsPills: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            statPill(value: "\(visitedCount)", label: "Countries", color: TravelStatus.visited.color)
            statPill(
                value: "\(totalCountries - visitedCount)",
                label: "Remaining",
                color: DesignSystem.Color.textTertiary
            )
            statPill(value: "\(visitedContinents)", label: "Continents", color: DesignSystem.Color.accent)
        }
    }

    var visitedContinents: Int {
        Set(continentBreakdown.filter { $0.visited > 0 }.map { $0.name }).count
    }

    func statPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var continentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("By Continent")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .textCase(.uppercase)
                .kerning(0.8)
            ForEach(continentBreakdown, id: \.name) { item in
                continentRow(item)
            }
        }
    }

    func continentRow(_ item: (name: String, visited: Int, total: Int)) -> some View {
        let fraction = item.total > 0 ? Double(item.visited) / Double(item.total) : 0.0
        return VStack(spacing: 4) {
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
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: fraction)
                }
            }
            .frame(height: 5)
        }
    }
}
