import Geografy_Core_Common
import Geografy_Core_Service
import Geografy_Core_DesignSystem
import SwiftUI

public struct ExploreGameScreen: View {
    @Environment(CountryDataService.self) private var countryDataService

    @State private var gameService: ExploreGameService?
    @State private var activeSession: ExploreGameState?

    public init() {}

    public var body: some View {
        screenContent
            .onAppear {
                if gameService == nil {
                    gameService = ExploreGameService(countryDataService: countryDataService)
                }
            }
    }
}

// MARK: - Body Subviews
private extension ExploreGameScreen {
    @ViewBuilder
    var screenContent: some View {
        if let activeSession, let gameService {
            ExploreGameSessionScreen(
                initialState: activeSession,
                gameService: gameService,
                onDismiss: { self.activeSession = nil }
            )
        } else {
            mainContent
                .navigationTitle("Mystery Country")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                heroSection
                gameModeSection
                statisticsSection
            }
            .padding(DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background { AmbientBlobsView(.standard) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

}

// MARK: - Hero Section
private extension ExploreGameScreen {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            heroIcon
                .accessibilityHidden(true)
            Text("Mystery Country")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("Identify countries from progressive clues. Fewer clues = higher score!")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var heroIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 96, height: 96)
            Image(systemName: "globe.desk.fill")
                .font(DesignSystem.Font.displayXS)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Game Mode Section
private extension ExploreGameScreen {
    var gameModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Game Modes")
            dailyGameCard
            practiceGameCard
        }
    }

    var dailyGameCard: some View {
        Button { startDailyGame() } label: {
            CardView {
                gameModeContent(
                    icon: "calendar.circle.fill",
                    title: "Daily Challenge",
                    subtitle: "One mystery country per day. Same for everyone!",
                    color: DesignSystem.Color.accent
                )
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    var practiceGameCard: some View {
        Button { startPracticeGame() } label: {
            CardView {
                gameModeContent(
                    icon: "infinity.circle.fill",
                    title: "Practice Mode",
                    subtitle: "Random countries. Play as many as you want!",
                    color: DesignSystem.Color.indigo
                )
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func gameModeContent(
        icon: String,
        title: String,
        subtitle: String,
        color: Color
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(
                        width: DesignSystem.Size.xxl,
                        height: DesignSystem.Size.xxl
                    )
                Image(systemName: icon)
                    .font(DesignSystem.Font.iconMedium)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.md)
    }
}

// MARK: - Statistics Section
private extension ExploreGameScreen {
    var statisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Statistics")
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                statTile(
                    icon: "gamecontroller.fill",
                    title: "Games Played",
                    value: "\(gameService?.statistics.gamesPlayed)"
                )
                statTile(
                    icon: "star.fill",
                    title: "Average Score",
                    value: averageScoreFormatted
                )
                statTile(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(gameService?.statistics.currentStreak)"
                )
                statTile(
                    icon: "trophy.fill",
                    title: "Best Streak",
                    value: "\(gameService?.statistics.bestStreak)"
                )
            }
        }
    }

    func statTile(icon: String, title: String, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(title)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Actions
private extension ExploreGameScreen {
    func startDailyGame() {
        guard let state = gameService?.makeDailyGame() else { return }
        activeSession = state
    }

    func startPracticeGame() {
        guard let state = gameService?.makePracticeGame() else { return }
        activeSession = state
    }

    var averageScoreFormatted: String {
        let average = gameService?.statistics.averageScore ?? 0
        return average > 0 ? "\(Int(average))" : "—"
    }
}

// MARK: - ExploreGameState + Identifiable
extension ExploreGameState: Identifiable {
    public var id: String { targetCountry.id }
}
