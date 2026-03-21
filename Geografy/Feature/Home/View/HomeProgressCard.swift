import SwiftUI

struct HomeProgressCard: View {
    let favoriteCount: Int
    let exploredContinents: Int
    let currentLevel: Int
    let onFavoritesTap: () -> Void
    let onCountriesTap: () -> Void
    let onProfileTap: () -> Void

    var body: some View {
        GeoCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                cardHeader
                statsRow
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension HomeProgressCard {
    var cardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your Progress")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Keep exploring the world!")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statTile(
                value: "\(favoriteCount)",
                label: "Favorites",
                icon: "heart.fill",
                color: DesignSystem.Color.error,
                action: onFavoritesTap
            )
            statTile(
                value: "\(exploredContinents)/7",
                label: "Continents",
                icon: "globe.americas.fill",
                color: DesignSystem.Color.accent,
                action: onCountriesTap
            )
            statTile(
                value: "Lv. \(currentLevel)",
                label: "Level",
                icon: "star.fill",
                color: .yellow,
                action: onProfileTap
            )
        }
    }

    func statTile(value: String, label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(color)
                Text(value)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            // swiftlint:disable:next line_length
            .background(DesignSystem.Color.cardBackgroundHighlighted, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
        .buttonStyle(GeoPressButtonStyle())
    }
}
