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
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    Text("\(achievementService.unlockedAchievements.count)/\(AchievementCatalog.all.count)")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    RowChevron()
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
        }
        .scrollClipDisabled()
    }

    var emptyAchievementsView: some View {
        ContentUnavailableView(
            "No Achievements Yet",
            systemImage: "trophy",
            description: Text("Start exploring to earn achievements!")
        )
    }

    func achievementCard(_ definition: AchievementDefinition) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            IconBadge(definition.iconName, color: definition.category.themeColor, size: .large)
                .overlay {
                    Circle()
                        .strokeBorder(
                            definition.rarity.borderGradient,
                            lineWidth: definition.rarity.borderWidth
                        )
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
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
        )
    }
}

// MARK: - Helpers
private extension ProfileScreen {
    var recentUnlockedAchievements: [AchievementDefinition] {
        achievementService.unlockedAchievements
            .sorted(by: \.unlockedAt, descending: true)
            .prefix(6)
            .compactMap { unlocked in
                AchievementCatalog.all.first { $0.id == unlocked.id }
            }
    }
}
#endif
