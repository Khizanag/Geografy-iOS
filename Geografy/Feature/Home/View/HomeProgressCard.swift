import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct HomeProgressCard: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService

    let favoriteCount: Int
    let exploredContinents: Int
    let currentLevel: Int
    let currentLevelTitle: String
    let nextLevelNumber: Int?
    let xpInCurrentLevel: Int
    let xpRequiredForNextLevel: Int
    let progressFraction: Double
    let onFavoritesTap: () -> Void
    let onCountriesTap: () -> Void
    let onProfileTap: () -> Void

    @State private var animatedProgress: Double = 0

    // MARK: - Body
    var body: some View {
        cardContent
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.15)) {
                    animatedProgress = progressFraction
                }
            }
            .onChange(of: progressFraction) { _, newValue in
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    animatedProgress = newValue
                }
            }
    }
}

// MARK: - Subviews
private extension HomeProgressCard {
    var cardContent: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                cardHeader
                xpProgressSection
                statsRow
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var cardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your Progress")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(currentLevelTitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }

    var xpProgressSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            levelLabelsRow
            xpProgressTrack
            xpCountLabel
        }
    }

    var levelLabelsRow: some View {
        HStack {
            Text("Lv. \(currentLevel)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
            Spacer()
            if let next = nextLevelNumber {
                Text("Lv. \(next)")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else {
                Text("MAX")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
    }

    var xpProgressTrack: some View {
        GeometryReader { geometry in
            let fillWidth = max(geometry.size.width * animatedProgress, 0)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                    .fill(xpProgressGradient)
                    .frame(width: fillWidth, height: 8)
                    .shadow(
                        color: DesignSystem.Color.accent.opacity(0.5),
                        radius: 6,
                        x: 4
                    )
            }
        }
        .frame(height: 8)
    }

    var xpCountLabel: some View {
        HStack {
            Spacer()
            Text("\(xpInCurrentLevel) / \(xpRequiredForNextLevel) XP")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
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

    func statTile(
        value: String,
        label: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            hapticsService.impact(.light)
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
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Helpers
private extension HomeProgressCard {
    var xpProgressGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
