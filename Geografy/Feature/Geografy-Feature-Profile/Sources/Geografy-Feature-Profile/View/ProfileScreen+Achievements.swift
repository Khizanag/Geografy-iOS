#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Achievements Preview
extension ProfileScreen {
    public var achievementsPreviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            achievementsHeader

            if recentUnlockedAchievements.isEmpty {
                emptyAchievementsView
            } else {
                achievementsScrollRow
            }
        }
    }
}

// MARK: - Subviews
private extension ProfileScreen {
    var achievementsHeader: some View {
        HStack {
            SectionHeaderView(title: "Achievements")
            Spacer()
            Button {
                hapticsService.impact(.light)
                coordinator.push(.achievements)
            } label: {
                HStack(spacing: 4) {
                    Text("\(achievementService.unlockedAchievements.count)/\(AchievementCatalog.all.count)")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    var achievementsScrollRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(recentUnlockedAchievements) { definition in
                    Button {
                        hapticsService.impact(.light)
                        coordinator.sheet(.achievementDetail(definition))
                    } label: {
                        achievementCard(definition)
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.horizontal, -DesignSystem.Spacing.md)
    }

    var emptyAchievementsView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "trophy")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("Start exploring to earn achievements!")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    func achievementCard(_ definition: AchievementDefinition) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(definition.category.themeColor.opacity(0.18))
                    .frame(width: 52, height: 52)

                Circle()
                    .strokeBorder(
                        definition.rarity.borderGradient,
                        lineWidth: definition.rarity.borderWidth
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: definition.iconName)
                    .font(DesignSystem.Font.iconDefault)
                    .foregroundStyle(definition.category.themeColor)
            }

            Text(definition.title)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 76, height: 32, alignment: .top)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Helpers
private extension ProfileScreen {
    var recentUnlockedAchievements: [AchievementDefinition] {
        achievementService.unlockedAchievements
            .sorted { $0.unlockedAt > $1.unlockedAt }
            .prefix(6)
            .compactMap { unlocked in
                AchievementCatalog.all.first { $0.id == unlocked.id }
            }
    }
}
#endif
