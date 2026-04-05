import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Flashcard
import SwiftUI

// MARK: - Main Feed
extension HomeScreen {
    var mainFeed: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                greetingSection
                    .padding(.horizontal, DesignSystem.Spacing.md)

                actionCardSection
                    .padding(.horizontal, DesignSystem.Spacing.md)

                quickStatsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)

                spotlightSection
                    .padding(.horizontal, DesignSystem.Spacing.md)

                gamesSection
                    .padding(.horizontal, DesignSystem.Spacing.md)

                exploreSection

                learnSection

                worldRecordsSection
            }
            .readableContentWidth(DesignSystem.AdaptiveLayout.maxWideContentWidth)
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Greeting
extension HomeScreen {
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
extension HomeScreen {
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
extension HomeScreen {
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
extension HomeScreen {
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
                .contextMenu {
                    Button {
                        collectionItem = (
                            id: country.code,
                            type: .country,
                            name: country.name
                        )
                    } label: {
                        Label("Save to Collection", systemImage: "folder.badge.plus")
                    }
                }
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
extension HomeScreen {
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
extension HomeScreen {
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
extension HomeScreen {
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
extension HomeScreen {
    var worldRecordsSection: some View {
        HomeWorldRecordsCard {
            coordinator.push(.worldRecords)
        }
    }
}
