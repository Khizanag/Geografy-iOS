import SwiftUI

// MARK: - Continent Explore Section

extension CountryDetailScreen {
    var continentExploreSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Explore \(country.continent.displayName)", icon: "globe")
            continentCard
        }
    }
}

// MARK: - Subviews

private extension CountryDetailScreen {
    var continentCard: some View {
        Button { coordinator.push(.continentOverview(country.continent)) } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    continentIcon
                    continentCardText
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    var continentIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.blue.opacity(0.12))
                .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
            Image(systemName: "globe")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(DesignSystem.Color.blue)
        }
    }

    var continentCardText: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("All \(country.continent.displayName) Countries")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Stats, rankings & full country list")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}
