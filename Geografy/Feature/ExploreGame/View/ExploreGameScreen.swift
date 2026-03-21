import SwiftUI

/// Landing screen for the Explore Game — daily challenge and practice mode.
struct ExploreGameScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var gameService = ExploreGameService()
    @State private var activeSession: ExploreGameState?
    @State private var lastResult: ExploreGameResult?
    @State private var blobAnimating = false

    var body: some View {
        NavigationStack {
            mainContent
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .onAppear { startBlobAnimation() }
                .fullScreenCover(item: $activeSession) { state in
                    ExploreGameSessionScreen(
                        initialState: state,
                        gameService: gameService
                    ) { result in
                        lastResult = result
                    }
                }
        }
    }
}

// MARK: - Body Subviews

private extension ExploreGameScreen {
    var mainContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                heroSection
                gameModeSection
                statisticsSection
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Explore")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        ToolbarItem(placement: .topBarTrailing) {
            GeoCircleCloseButton()
        }
    }
}

// MARK: - Hero Section

private extension ExploreGameScreen {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            heroIcon

            Text("Country Explorer")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Identify countries from progressive clues. Fewer clues = higher score!")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }

    var heroIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: 96, height: 96)

            Image(systemName: "globe.desk.fill")
                .font(.system(size: 44))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Game Mode Section

private extension ExploreGameScreen {
    var gameModeSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
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
        .buttonStyle(GeoPressButtonStyle())
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
        .buttonStyle(GeoPressButtonStyle())
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
                    .font(.system(size: 24))
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

            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(DesignSystem.Spacing.md)
    }
}

// MARK: - Statistics Section

private extension ExploreGameScreen {
    var statisticsSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Statistics", icon: "chart.bar.fill")

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                GeoInfoTile(
                    icon: "gamecontroller.fill",
                    title: "Games Played",
                    value: "\(gameService.statistics.gamesPlayed)"
                )
                GeoInfoTile(
                    icon: "star.fill",
                    title: "Average Score",
                    value: averageScoreFormatted
                )
                GeoInfoTile(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(gameService.statistics.currentStreak)"
                )
                GeoInfoTile(
                    icon: "trophy.fill",
                    title: "Best Streak",
                    value: "\(gameService.statistics.bestStreak)"
                )
            }
        }
    }
}

// MARK: - Background

private extension ExploreGameScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        DesignSystem.Color.accent.opacity(0.2),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                ))
                .frame(width: 420, height: 320)
                .blur(radius: 36)
                .offset(x: -80, y: -100)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        DesignSystem.Color.indigo.opacity(0.16),
                        .clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 300)
                .blur(radius: 44)
                .offset(x: 140, y: 200)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    func startBlobAnimation() {
        withAnimation(
            .easeInOut(duration: 6)
                .repeatForever(autoreverses: true)
        ) {
            blobAnimating = true
        }
    }
}

// MARK: - Actions

private extension ExploreGameScreen {
    func startDailyGame() {
        guard let state = gameService.makeDailyGame() else { return }
        activeSession = state
    }

    func startPracticeGame() {
        guard let state = gameService.makePracticeGame() else { return }
        activeSession = state
    }
}

// MARK: - Helpers

private extension ExploreGameScreen {
    var averageScoreFormatted: String {
        let average = gameService.statistics.averageScore
        guard average > 0 else { return "—" }
        return String(format: "%.0f", average)
    }
}

// MARK: - ExploreGameState + Identifiable

extension ExploreGameState: @retroactive Identifiable {
    var id: String { targetCountry.id }
}
