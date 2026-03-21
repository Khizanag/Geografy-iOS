import SwiftUI

struct MoreScreen: View {
    @State private var activeSheet: MoreSheet?
    @State private var blobAnimating = false

    var body: some View {
        NavigationStack {
            itemList
                .background {
                    ambientBlobs
                }
                .background(DesignSystem.Color.background.ignoresSafeArea())
                .navigationTitle("More")
                .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $activeSheet) { sheet in
            sheetContent(for: sheet)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
        }
    }
}

// MARK: - Sheet Type

private extension MoreScreen {
    enum MoreSheet: Identifiable {
        case profile, countries, orgs, favorites, travel
        case dailyChallenge, compare, travelJournal
        case quizPacks, customQuiz, multiplayer, exploreGame
        case badges, timeline
        case achievements, leaderboards, themes, settings

        var id: Self { self }

        var label: String {
            switch self {
            case .profile: "Profile"
            case .countries: "Countries"
            case .orgs: "Organizations"
            case .favorites: "Favorites"
            case .travel: "Travel Tracker"
            case .dailyChallenge: "Daily Challenge"
            case .compare: "Compare Countries"
            case .travelJournal: "Travel Journal"
            case .quizPacks: "Quiz Packs"
            case .customQuiz: "Custom Quizzes"
            case .multiplayer: "Multiplayer"
            case .exploreGame: "Mystery Country"
            case .badges: "Badge Collection"
            case .timeline: "Historical Timeline"
            case .achievements: "Achievements"
            case .leaderboards: "Leaderboards"
            case .themes: "Themes"
            case .settings: "Settings"
            }
        }

        var icon: String {
            switch self {
            case .profile: "person.fill"
            case .countries: "list.bullet"
            case .orgs: "building.2.fill"
            case .favorites: "heart.fill"
            case .travel: "airplane.departure"
            case .dailyChallenge: "calendar.badge.exclamationmark"
            case .compare: "arrow.left.arrow.right"
            case .travelJournal: "book.fill"
            case .quizPacks: "square.stack.fill"
            case .customQuiz: "pencil.and.list.clipboard"
            case .multiplayer: "person.2.fill"
            case .exploreGame: "magnifyingglass"
            case .badges: "medal.fill"
            case .timeline: "clock.arrow.circlepath"
            case .achievements: "trophy.fill"
            case .leaderboards: "list.number"
            case .themes: "paintbrush.fill"
            case .settings: "gearshape.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .profile: "View your stats and level"
            case .countries: "Browse all 197 countries"
            case .orgs: "International organizations"
            case .favorites: "Your saved countries"
            case .travel: "Track your adventures"
            case .dailyChallenge: "New puzzle every day"
            case .compare: "Side-by-side country stats"
            case .travelJournal: "Photos, notes & memories"
            case .quizPacks: "Themed quiz progression"
            case .customQuiz: "Build your own quizzes"
            case .multiplayer: "Challenge opponents"
            case .exploreGame: "Guess from clues"
            case .badges: "Collect and showcase"
            case .timeline: "Borders through history"
            case .achievements: "Unlock badges and rewards"
            case .leaderboards: "Compete with others"
            case .themes: "Customize your experience"
            case .settings: "App preferences"
            }
        }

        var color: Color {
            switch self {
            case .profile: DesignSystem.Color.accent
            case .countries: DesignSystem.Color.blue
            case .orgs: DesignSystem.Color.indigo
            case .favorites: DesignSystem.Color.error
            case .travel: Color(hex: "00C9A7")
            case .dailyChallenge: DesignSystem.Color.orange
            case .compare: DesignSystem.Color.blue
            case .travelJournal: Color(hex: "00C9A7")
            case .quizPacks: DesignSystem.Color.purple
            case .customQuiz: DesignSystem.Color.accent
            case .multiplayer: DesignSystem.Color.error
            case .exploreGame: DesignSystem.Color.warning
            case .badges: DesignSystem.Color.warning
            case .timeline: DesignSystem.Color.indigo
            case .achievements: DesignSystem.Color.warning
            case .leaderboards: DesignSystem.Color.success
            case .themes: DesignSystem.Color.indigo
            case .settings: DesignSystem.Color.textSecondary
            }
        }
    }
}

// MARK: - Subviews

private extension MoreScreen {
    var ambientBlobs: some View {
        ZStack {
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.accent, opacity: 0.28,
                endRadius: 220, width: 440, height: 320, blur: 32,
                offset: (-80, -80), scale: blobAnimating ? 1.10 : 0.90
            ))
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.indigo, opacity: 0.20,
                endRadius: 180, width: 360, height: 300, blur: 40,
                offset: (140, 80), scale: blobAnimating ? 0.88 : 1.10
            ))
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.blue, opacity: 0.14,
                endRadius: 160, width: 320, height: 260, blur: 36,
                offset: (-100, 400), scale: blobAnimating ? 1.06 : 0.94
            ))
            blobEllipse(BlobConfig(
                color: DesignSystem.Color.purple, opacity: 0.12,
                endRadius: 160, width: 320, height: 280, blur: 44,
                offset: (160, 650), scale: blobAnimating ? 0.92 : 1.08
            ))
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    struct BlobConfig {
        let color: Color
        let opacity: Double
        let endRadius: CGFloat
        let width: CGFloat
        let height: CGFloat
        let blur: CGFloat
        let offset: (CGFloat, CGFloat)
        let scale: CGFloat
    }

    func blobEllipse(_ config: BlobConfig) -> some View {
        Ellipse()
            .fill(RadialGradient(
                colors: [config.color.opacity(config.opacity), .clear],
                center: .center,
                startRadius: 0,
                endRadius: config.endRadius
            ))
            .frame(width: config.width, height: config.height)
            .blur(radius: config.blur)
            .offset(x: config.offset.0, y: config.offset.1)
            .scaleEffect(config.scale)
    }

    var itemList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                hubSection(title: "You", items: youItems)
                hubSection(title: "Play", items: playItems)
                hubSection(title: "Explore", items: exploreItems)
                hubSection(title: "Travel", items: travelItems)
                hubSection(title: "App", items: appItems)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
    }

    func hubSection(title: String, items: [MoreSheet]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: 100),
                        spacing: DesignSystem.Spacing.sm
                    ),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                ForEach(items, id: \.id) { sheet in
                    gridTile(for: sheet)
                }
            }
        }
    }

    func gridTile(for sheet: MoreSheet) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            activeSheet = sheet
        } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.small
                    )
                    .fill(sheet.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                    Image(systemName: sheet.icon)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(sheet.color)
                }
                Text(sheet.label)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
                .strokeBorder(sheet.color.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    var sheetsWithOwnCloseButton: Set<MoreSheet> {
        [
            .profile, .dailyChallenge, .customQuiz,
            .multiplayer, .exploreGame, .timeline,
        ]
    }

    var youItems: [MoreSheet] {
        [.profile, .countries, .favorites, .badges]
    }

    var playItems: [MoreSheet] {
        [
            .dailyChallenge, .exploreGame, .multiplayer,
            .quizPacks, .customQuiz,
        ]
    }

    var exploreItems: [MoreSheet] {
        [.compare, .timeline, .orgs]
    }

    var travelItems: [MoreSheet] {
        [.travel, .travelJournal]
    }

    var appItems: [MoreSheet] {
        [.achievements, .leaderboards, .themes, .settings]
    }

    @ViewBuilder
    func sheetContent(for sheet: MoreSheet) -> some View {
        NavigationStack {
            Group {
                switch sheet {
                case .profile:
                    ProfileScreen()
                case .countries:
                    CountryListScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                case .orgs:
                    OrganizationsScreen()
                case .favorites:
                    FavoritesScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                case .travel:
                    TravelTrackerScreen()
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                case .dailyChallenge:
                    DailyChallengeScreen()
                case .compare:
                    CompareScreen()
                case .travelJournal:
                    TravelJournalScreen()
                case .quizPacks:
                    QuizPackBrowserScreen()
                case .customQuiz:
                    CustomQuizLibraryScreen()
                case .multiplayer:
                    MultiplayerLobbyScreen(
                        multiplayerService: MultiplayerService()
                    )
                case .exploreGame:
                    ExploreGameScreen()
                case .badges:
                    BadgeCollectionScreen(badgeService: BadgeService())
                case .timeline:
                    TimelineScreen()
                case .achievements:
                    AchievementsScreen()
                        .navigationTitle("Achievements")
                        .navigationBarTitleDisplayMode(.large)
                case .leaderboards:
                    LeaderboardScreen()
                case .themes:
                    ThemesScreen()
                        .navigationTitle("Themes")
                        .navigationBarTitleDisplayMode(.large)
                case .settings:
                    SettingsScreen()
                }
            }
            .toolbar {
                if !sheetsWithOwnCloseButton.contains(sheet) {
                    ToolbarItem(placement: .topBarTrailing) {
                        GeoCircleCloseButton { activeSheet = nil }
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}
