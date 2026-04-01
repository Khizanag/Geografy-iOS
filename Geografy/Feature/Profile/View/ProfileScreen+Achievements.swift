#if !os(tvOS)
import GeografyDesign
import SwiftUI

// MARK: - Achievements Preview
extension ProfileScreen {
    var achievementsPreviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                SectionHeaderView(title: "Achievements")
                Spacer()
                Button {
                    hapticsService.impact(.light)
                    coordinator.sheet(.achievements)
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
            if recentUnlockedAchievements.isEmpty {
                emptyAchievementsView
            } else {
                achievementsScrollRow
            }
        }
    }
}

// MARK: - Achievements Subviews
private extension ProfileScreen {
    var achievementsScrollRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(recentUnlockedAchievements) { definition in
                    miniAchievementCard(definition)
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func miniAchievementCard(_ definition: AchievementDefinition) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(achievementColor(for: definition.category).opacity(0.18))
                    .frame(width: 52, height: 52)
                Circle()
                    .stroke(achievementColor(for: definition.category).opacity(0.3), lineWidth: 1.5)
                    .frame(width: 52, height: 52)
                Image(systemName: definition.iconName)
                    .font(DesignSystem.Font.iconDefault)
                    .foregroundStyle(achievementColor(for: definition.category))
            }
            Text(definition.title)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 76)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var recentUnlockedAchievements: [AchievementDefinition] {
        achievementService.unlockedAchievements
            .sorted { $0.unlockedAt > $1.unlockedAt }
            .prefix(6)
            .compactMap { unlocked in AchievementCatalog.all.first { $0.id == unlocked.id } }
    }

    func achievementColor(for category: AchievementCategory) -> Color {
        category.themeColor
    }
}
#endif
