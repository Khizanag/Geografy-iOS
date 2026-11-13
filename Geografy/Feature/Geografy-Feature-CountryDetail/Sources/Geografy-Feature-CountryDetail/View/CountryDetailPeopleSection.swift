import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - People
extension CountryDetailScreen {
    var peopleSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("People")
            populationCard
            if !country.languages.isEmpty {
                PercentageBarChart(
                    title: "Languages",
                    icon: "globe",
                    items: country.languages.map { PercentageItem(name: $0.name, percentage: $0.percentage) },
                    appeared: true
                )
            }
        }
    }
}

// MARK: - Helpers
extension CountryDetailScreen {
    func densityColor(for fraction: Double) -> Color {
        if fraction > 0.7 {
            DesignSystem.Color.error
        } else if fraction > 0.4 {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.success
        }
    }

    func densityLevel(for fraction: Double) -> String {
        if fraction > 0.7 {
            "High"
        } else if fraction > 0.4 {
            "Moderate"
        } else {
            "Low"
        }
    }
}

// MARK: - Subviews
private extension CountryDetailScreen {
    var populationCard: some View {
        Button {
            activeSheet = .info(
                InfoItem(
                    icon: "person.3.fill",
                    title: "Population",
                    value: "\(country.population.formatPopulation()) people\n"
                        + "\(String(format: "%.1f", country.populationDensity))/km² density",
                    supportsMap: false
                )
            )
        } label: {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        livePopulationTicker
                        Text("People (live estimate)")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxs) {
                        Text("\(String(format: "%.1f", country.populationDensity))/km²")
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("Density")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
                densityBar
            }
            .padding(DesignSystem.Spacing.md)
        }
        }
        .buttonStyle(PressButtonStyle())
    }

    var livePopulationTicker: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(DesignSystem.Color.success)
                .frame(width: 6, height: 6)
                .scaleEffect(appeared && !reduceMotion ? 1.5 : 1.0)
                .opacity(appeared && !reduceMotion ? 0.4 : 1.0)
                .accessibilityHidden(true)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: appeared
                )
            TimelineView(.periodic(from: populationStartDate, by: 1.0)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(populationStartDate)
                let growthPerSecond = Double(country.population) * 0.009 / 31_557_600
                let estimate = country.population + Int(growthPerSecond * elapsed)
                Text(estimate.formatPopulation())
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText(countsDown: false))
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.6), value: estimate)
            }
        }
    }

    var densityFraction: Double {
        min(country.populationDensity / 500.0, 1.0)
    }

    var densityBar: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            GeometryReader { geometryReader in
                let fraction = densityFraction
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    Capsule()
                        .fill(densityColor(for: fraction))
                        .frame(width: geometryReader.size.width * (appeared ? fraction : 0))
                        .animation(
                            reduceMotion ? nil : .spring(response: 0.7, dampingFraction: 0.7).delay(0.4),
                            value: appeared
                        )
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)
            HStack(alignment: .firstTextBaseline) {
                Text("Relative density (ref: 500/km²)")
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer(minLength: DesignSystem.Spacing.xs)
                Text("\(densityLevel(for: densityFraction)) density")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .font(DesignSystem.Font.caption2)
        }
    }
}
