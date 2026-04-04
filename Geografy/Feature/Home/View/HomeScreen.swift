import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Auth
import Geografy_Feature_DailyChallenge
import Geografy_Feature_Flashcard
import SwiftUI

struct HomeScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(AuthService.self) private var authService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService
    @Environment(CoinService.self) private var coinService
    @Environment(FlashcardService.self) var flashcardService

    @Environment(Navigator.self) var coordinator
    @Environment(CountryDataService.self) var countryDataService
    @Environment(FeatureFlagService.self) var featureFlags

    @State var dailyChallengeService: DailyChallengeService?
    @State private var appeared = false

    var body: some View {
        mainFeed
            .background { AmbientBlobsView(.rich) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                await loadDailyChallenge()
                startAnimations()
            }
    }
}

// MARK: - Main Feed
private extension HomeScreen {
    var mainFeed: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                greetingSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.05)

                actionCardSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.10)

                quickStatsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.15)

                spotlightSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.20)

                gamesSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.25)

                exploreSection
                    .feedSection(appeared: appeared, delay: 0.30)

                learnSection
                    .feedSection(appeared: appeared, delay: 0.35)

                worldRecordsSection
                    .feedSection(appeared: appeared, delay: 0.40)
            }
            .readableContentWidth(DesignSystem.AdaptiveLayout.maxWideContentWidth)
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Toolbar
private extension HomeScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            profileButton
        }
        ToolbarItem(placement: .principal) {
            statsButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            searchButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            friendsButton
        }
    }

    var profileButton: some View {
        Button { coordinator.sheet(.profile) } label: {
            ProfileAvatarView(
                name: authService.currentProfile?.displayName ?? "Explorer",
                size: DesignSystem.Size.md
            )
        }
        .buttonStyle(.plain)
    }

    var statsButton: some View {
        Button { coordinator.sheet(.coinStore) } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                xpIndicator
                divider
                coinIndicator
            }
        }
        .buttonStyle(.glass)
    }

    var xpIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            xpProgressBar
            Text("Lv. \(xpService.currentLevel.level)")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Level \(xpService.currentLevel.level)")
        .accessibilityValue("\(Int(xpService.progressFraction * 100)) percent to next level")
    }

    var xpProgressBar: some View {
        GeometryReader { geometryReader in
            ZStack(alignment: .leading) {
                Capsule().fill(DesignSystem.Color.cardBackgroundHighlighted)
                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(width: geometryReader.size.width * xpService.progressFraction)
                    .animation(.easeInOut(duration: 0.5), value: xpService.progressFraction)
            }
        }
        .frame(width: 120, height: DesignSystem.Size.xs)
    }

    var coinIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "dollarsign.circle.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.warning)
                .accessibilityHidden(true)
            Text(coinService.formattedBalance)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(coinService.formattedBalance) coins")
    }

    var divider: some View {
        Rectangle()
            .fill(DesignSystem.Color.textTertiary.opacity(0.3))
            .frame(width: DesignSystem.Size.xxs, height: DesignSystem.Size.sm)
    }

    var searchButton: some View {
        Button { coordinator.sheet(.search) } label: {
            Label("Search", systemImage: "magnifyingglass")
        }
    }

    var friendsButton: some View {
        Button { coordinator.sheet(.friends) } label: {
            Label("Friends", systemImage: "person.2")
        }
    }
}

// MARK: - Greeting
private extension HomeScreen {
    var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(greetingLabel)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .textCase(.uppercase)
                    .kerning(1.2)
                    .accessibilityAddTraits(.isHeader)
                Text(authService.currentProfile?.displayName ?? "Explorer")
                    .font(DesignSystem.Font.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            Spacer()
            globeBadge
                .accessibilityHidden(true)
        }
    }

    var greetingLabel: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return switch hour {
        case 0..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    var globeBadge: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: DesignSystem.Size.xxxl, height: DesignSystem.Size.xxxl)
            Image(systemName: "globe.americas.fill")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Action Card
private extension HomeScreen {
    var actionCardSection: some View {
        HomeActionCard(
            dailyChallengeCompleted: dailyChallengeService?.hasCompletedToday ?? false,
            srsCardsDue: dueReviewCount,
            onDailyChallenge: { coordinator.sheet(.dailyChallenge) },
            onReviewCards: { coordinator.sheet(.srsStudy) },
            onStartQuiz: { coordinator.sheet(.quizSetup) }
        )
    }

    var dueReviewCount: Int {
        let allCards = countryDataService.countries.map {
            FlashcardItem.make(from: $0, type: .countryToCapital)
        }
        return flashcardService.dueCards(from: allCards).count
    }
}

// MARK: - Quick Stats
private extension HomeScreen {
    var quickStatsSection: some View {
        HomeQuickStatsRow(
            streakDays: streakService.currentStreak,
            level: xpService.currentLevel.level,
            countriesExplored: favoritesService.favoriteCodes.count,
            onStreakTap: { coordinator.sheet(.quizSetup) },
            onLevelTap: { coordinator.sheet(.profile) },
            onCountriesTap: { coordinator.sheet(.countries) }
        )
    }
}

// MARK: - Spotlight
private extension HomeScreen {
    @ViewBuilder
    var spotlightSection: some View {
        if let country = spotlightCountry {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: "Discover")
                    .padding(.bottom, DesignSystem.Spacing.xxs)
                Button { coordinator.sheet(.countryDetail(country)) } label: {
                    HomeCountrySpotlightCard(
                        country: country,
                        funFact: spotlightFunFact(for: country)
                    )
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }

    var spotlightCountry: Country? {
        countryDataService.countryOfTheDay()
    }

    func spotlightFunFact(for country: Country) -> String? {
        let facts = CountryFunFacts.data[country.code] ?? []
        return facts.first
    }
}

// MARK: - Games Grid
private extension HomeScreen {
    var gamesSection: some View {
        HomeGamesGrid(
            onGameTap: { handleGameTap($0) },
            onSeeAll: { coordinator.sheet(.quizSetup) }
        )
    }

    func handleGameTap(_ game: HomeGamesGrid.GameItem) {
        switch game {
        case .quiz: coordinator.sheet(.quizSetup)
        case .flagGame: coordinator.sheet(.flagGame)
        case .trivia: coordinator.sheet(.trivia)
        case .mapPuzzle: coordinator.push(.mapPuzzle)
        case .borderChallenge: coordinator.sheet(.borderChallenge)
        case .wordSearch: coordinator.sheet(.wordSearch)
        }
    }
}

// MARK: - Explore Carousel
private extension HomeScreen {
    var exploreSection: some View {
        HomeExploreCarousel { handleExploreTap($0) }
    }

    func handleExploreTap(_ item: HomeExploreCarousel.ExploreItem) {
        switch item {
        case .countries: coordinator.sheet(.countries)
        case .compare: coordinator.sheet(.compare())
        case .travel: coordinator.sheet(.travelTracker)
        case .organizations: coordinator.sheet(.organizations)
        case .timeline: coordinator.push(.independenceTimeline)
        case .continentStats: coordinator.push(.continentPicker)
        }
    }
}

// MARK: - Learn Carousel
private extension HomeScreen {
    var learnSection: some View {
        HomeLearnCarousel(srsCardsDue: dueReviewCount) { handleLearnTap($0) }
    }

    func handleLearnTap(_ item: HomeLearnCarousel.LearnItem) {
        switch item {
        case .learningPath: coordinator.sheet(.learningPath)
        case .flashcards: coordinator.sheet(.srsStudy)
        case .oceanExplorer: coordinator.push(.oceanExplorer)
        case .languageExplorer: coordinator.push(.languageExplorer)
        case .economy: coordinator.push(.economyExplorer)
        case .culture: coordinator.push(.cultureExplorer)
        case .geographyFeatures: coordinator.push(.geographyFeatures)
        case .landmarks: coordinator.push(.landmarkGallery)
        }
    }
}

// MARK: - World Records
private extension HomeScreen {
    var worldRecordsSection: some View {
        HomeWorldRecordsCard {
            coordinator.push(.worldRecords)
        }
    }
}

// MARK: - Helpers
private extension HomeScreen {
    func startAnimations() {
        appeared = true
    }

    func loadDailyChallenge() async {
        let service = DailyChallengeService(
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        await service.loadChallenge()
        dailyChallengeService = service
    }
}

// MARK: - Feed Section Modifier
private extension View {
    func feedSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(delay), value: appeared)
    }
}
