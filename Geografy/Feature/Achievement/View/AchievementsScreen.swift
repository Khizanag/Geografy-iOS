import SwiftUI

struct AchievementsScreen: View {
    @Environment(AchievementService.self) private var achievementService
    @Environment(XPService.self) private var xpService

    @State private var selectedAchievement: AchievementDefinition?

    @State private var appeared = false

    private let categories: [(AchievementCategory, String, String)] = [
        (.explorer, "Explorer", "globe"),
        (.quizMaster, "Quiz Master", "gamecontroller.fill"),
        (.travelTracker, "Travel Tracker", "airplane"),
        (.streak, "Streak", "flame.fill"),
        (.knowledge, "Knowledge", "book.fill"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                progressSection
                achievementSections
            }
            .padding(DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background { AmbientBlobsView(.subtle) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(
                definition: achievement,
                isUnlocked: achievementService.isUnlocked(achievement.id),
                unlockedAt: achievementService.unlockedAchievements.first { $0.id == achievement.id }?.unlockedAt
            )
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension AchievementsScreen {
    var progressSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    LevelBadgeView(level: xpService.currentLevel, size: .small)
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(xpService.currentLevel.title)
                            .font(DesignSystem.Font.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        let unlocked = achievementService.unlockedAchievements.count
                        let total = AchievementCatalog.all.count
                        Text("\(unlocked) / \(total) unlocked")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                    totalXPBadge
                }
                XPProgressBar(
                    currentLevelNumber: xpService.currentLevel.level,
                    nextLevelNumber: xpService.currentLevel.level < 10 ? xpService.currentLevel.level + 1 : nil,
                    xpInCurrentLevel: xpService.xpInCurrentLevel,
                    xpRequiredForNextLevel: xpService.xpRequiredForNextLevel,
                    progressFraction: xpService.progressFraction
                )
            }
            .padding(DesignSystem.Spacing.md)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    var totalXPBadge: some View {
        VStack(spacing: 2) {
            Text("\(xpService.totalXP)")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Total XP")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var achievementSections: some View {
        ForEach(categories, id: \.0.rawValue) { category, title, icon in
            categorySection(category: category, title: title, icon: icon)
        }
    }

    func categorySection(category: AchievementCategory, title: String, icon: String) -> some View {
        let definitions = AchievementCatalog.all.filter { $0.category == category }
        let unlockedCount = definitions.filter { achievementService.isUnlocked($0.id) }.count
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            categoryHeader(title: title, icon: icon, unlocked: unlockedCount, total: definitions.count)
            achievementGrid(for: definitions)
        }
    }

    func categoryHeader(title: String, icon: String, unlocked: Int, total: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(title)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Text("\(unlocked)/\(total)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func achievementGrid(for definitions: [AchievementDefinition]) -> some View {
        let columns = [GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
            ForEach(definitions) { definition in
                AchievementCard(
                    definition: definition,
                    isUnlocked: achievementService.isUnlocked(definition.id),
                    unlockedAt: achievementService.unlockedAchievements.first { $0.id == definition.id }?.unlockedAt,
                    onTap: { selectedAchievement = definition }
                )
            }
        }
    }

}
