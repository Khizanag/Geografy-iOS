import Geografy_Core_DesignSystem
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
        Button { navigateToContinent(country.continent) } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    IconBadge("globe", color: DesignSystem.Color.blue)
                    continentCardText
                    Spacer(minLength: 0)
                    RowChevron()
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
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
