import SwiftUI

struct TVProfileScreen: View {
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService
    @Environment(AchievementService.self) private var achievementService
    @Environment(TravelService.self) private var travelService

    var body: some View {
        List {
            Section {
                levelRow
            }

            Section("Stats") {
                statRow(label: "Total XP", value: "\(xpService.totalXP)", icon: "star.fill")
                statRow(label: "Current Streak", value: "\(streakService.currentStreak) days", icon: "flame.fill")
                statRow(label: "Countries Visited", value: "\(travelService.visitedCodes.count)", icon: "airplane.departure")
                statRow(label: "Want to Visit", value: "\(travelService.wantToVisitCodes.count)", icon: "mappin.and.ellipse")
                statRow(
                    label: "Achievements",
                    value: "\(achievementService.unlockedAchievements.count) / \(AchievementCatalog.all.count)",
                    icon: "medal.fill"
                )
            }
        }
        .navigationTitle("Profile")
    }
}

// MARK: - Subviews

private extension TVProfileScreen {
    var levelRow: some View {
        HStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(xpService.currentLevel.level)")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(xpService.currentLevel.title)
                    .font(.system(size: 20))
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: xpService.progressFraction)
                    .tint(DesignSystem.Color.accent)

                Text("\(xpService.xpInCurrentLevel) / \(xpService.xpRequiredForNextLevel) XP")
                    .font(.system(size: 18))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func statRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 36)

            Text(label)
                .font(.system(size: 20))

            Spacer()

            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}
