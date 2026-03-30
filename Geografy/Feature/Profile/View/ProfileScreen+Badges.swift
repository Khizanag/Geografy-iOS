import SwiftUI

// MARK: - Badge Showcase
extension ProfileScreen {
    var badgeShowcaseSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                SectionHeaderView(title: "My Badges", icon: "medal.fill")
                Spacer()
                Button {
                    hapticsService.impact(.light)
                    activeSheet = .achievements
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
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
            if featuredBadges.isEmpty {
                emptyBadgesView
            } else {
                badgesScrollRow
            }
        }
    }
}

// MARK: - Badge Subviews
private extension ProfileScreen {
    var badgesScrollRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(featuredBadges) { achievement in
                    miniBadgeCard(achievement)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.horizontal, -DesignSystem.Spacing.md)
    }

    var emptyBadgesView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "medal")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("Earn badges by playing!")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func miniBadgeCard(_ achievement: AchievementDefinition) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(achievement.category.themeColor.opacity(0.18))
                    .frame(width: 52, height: 52)

                Circle()
                    .strokeBorder(achievement.rarity.borderGradient, lineWidth: achievement.rarity.borderWidth)
                    .frame(width: 52, height: 52)

                Image(systemName: achievement.iconName)
                    .font(DesignSystem.Font.iconDefault)
                    .foregroundStyle(achievement.category.themeColor)
            }

            Text(achievement.title)
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

    var featuredBadges: [AchievementDefinition] {
        achievementService.unlockedAchievements
            .sorted { $0.unlockedAt > $1.unlockedAt }
            .prefix(6)
            .compactMap { unlocked in
                AchievementCatalog.all.first { $0.id == unlocked.id }
            }
    }
}
