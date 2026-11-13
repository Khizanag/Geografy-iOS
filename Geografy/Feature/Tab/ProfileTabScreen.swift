import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

/// The Profile tab: a greeting and progress stats, then everything that belongs to the user.
struct ProfileTabScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(AuthService.self) private var authService
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService
    @Environment(FavoritesService.self) private var favoritesService

    // MARK: - Body
    var body: some View {
        HubScreen(title: "Profile", sections: Self.sections) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                greeting
                QuickStatsRow(
                    streakDays: streakService.currentStreak,
                    level: xpService.currentLevel.level,
                    countriesExplored: favoritesService.favoriteCodes.count,
                    onStreakTap: { coordinator.push(.profile) },
                    onLevelTap: { coordinator.push(.profile) },
                    onCountriesTap: { coordinator.push(.saved(.favorites)) }
                )
            }
        }
    }
}

// MARK: - Sections
private extension ProfileTabScreen {
    static let sections = [
        HubSection(title: "You", items: [.profile, .favorites, .travel]),
        HubSection(title: "Progress", items: [.achievements, .leaderboards, .friends]),
        HubSection(title: "App", items: [.settings]),
    ]
}

// MARK: - Greeting
private extension ProfileTabScreen {
    var greeting: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            EyebrowLabel(greetingLabel, color: DesignSystem.Color.accent)
            Text(authService.currentProfile?.displayName ?? "Explorer")
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }

    var greetingLabel: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 0..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }
}
