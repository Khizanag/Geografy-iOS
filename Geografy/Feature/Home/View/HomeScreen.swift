import GeografyCore
import GeografyDesign
import SwiftUI

struct HomeScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(AuthService.self) private var authService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService
    @Environment(CoinService.self) private var coinService
    @Environment(HomeSectionOrderService.self) private var sectionOrderService
    @Environment(FlashcardService.self) var flashcardService

    @Environment(Navigator.self) var coordinator
    @Environment(CountryDataService.self) var countryDataService
    @Environment(FeatureFlagService.self) var featureFlags

    @State var dailyChallengeService: DailyChallengeService?
    @State private var selectedMapIndex = 0
    @State private var appeared = false

    private let maps: [(name: String, icon: String)] = [
        ("World map", "globe"),
        ("Europe", "globe.europe.africa"),
        ("Asia", "globe.asia.australia"),
        ("Africa", "globe.europe.africa"),
        ("North America", "globe.americas"),
        ("South America", "globe.americas"),
        ("Oceania", "globe.asia.australia"),
    ]

    var body: some View {
        mainFeed
            .background { AmbientBlobsView(.rich) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task {
                loadDailyChallenge()
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

                ForEach(Array(sectionOrderService.sections.enumerated()), id: \.element) { index, section in
                    sectionView(for: section)
                        .feedSection(appeared: appeared, delay: 0.08 + Double(index) * 0.04)
                }
            }
            .readableContentWidth(DesignSystem.AdaptiveLayout.maxWideContentWidth)
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Top Bar
private extension HomeScreen {
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
            .fixedSize()
        }
        .buttonStyle(.glass)
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

    var searchButton: some View {
        Button { coordinator.sheet(.search) } label: {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .accessibilityLabel("Search")
        }
        .buttonStyle(.plain)
    }

    var friendsButton: some View {
        Button { coordinator.sheet(.friends) } label: {
            Image(systemName: "person.2")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .accessibilityLabel("Friends")
        }
        .buttonStyle(.borderedProminent)
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
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(DesignSystem.Color.cardBackgroundHighlighted)
                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(width: geo.size.width * xpService.progressFraction)
                    .animation(.easeInOut(duration: 0.5), value: xpService.progressFraction)
            }
        }
        .frame(width: DesignSystem.Size.hero, height: DesignSystem.Size.xs)
    }

    var divider: some View {
        Rectangle()
            .fill(DesignSystem.Color.textTertiary.opacity(0.3))
            .frame(width: DesignSystem.Size.xxs, height: DesignSystem.Size.sm)
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
            editSectionsButton
            globeBadge
                .accessibilityHidden(true)
        }
    }

    var editSectionsButton: some View {
        Button { coordinator.sheet(.sectionEditor) } label: {
            Image(systemName: "slider.horizontal.3")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .buttonStyle(.plain)
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

// MARK: - Carousel
private extension HomeScreen {
    var isLandscape: Bool { verticalSizeClass == .compact }
    var isCompactHeight: Bool { verticalSizeClass == .compact }
    var carouselHeight: CGFloat {
        if isLandscape { 200 } else if isCompactHeight { 240 } else { 300 }
    }

    var carouselSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            carouselHeader
                .padding(.horizontal, DesignSystem.Spacing.md)
            mapCarousel
            pageIndicator
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    var carouselHeader: some View {
        HStack {
            SectionHeaderView(title: "Explore Maps")
            Spacer()
            Text("\(selectedMapIndex + 1) / \(maps.count)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.trailing, DesignSystem.Spacing.xs)
            Button { coordinator.push(.allMaps) } label: {
                Text("See All")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .buttonStyle(.plain)
        }
    }

    var mapCarousel: some View {
        GeometryReader { outerGeo in
            let cardWidth = outerGeo.size.width * 0.78
            let spacing: CGFloat = DesignSystem.Spacing.sm
            let sidePadding = (outerGeo.size.width - cardWidth) / 2

            ScrollViewReader { _ in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(Array(maps.enumerated()), id: \.offset) { index, map in
                            GeometryReader { cardGeo in
                                let midX = cardGeo.frame(in: .global).midX
                                let screenMidX = outerGeo.size.width / 2
                                let distance = midX - screenMidX
                                let maxDistance = outerGeo.size.width
                                let normalized = distance / maxDistance
                                let scale = 1.0 - abs(normalized) * 0.12
                                let rotation = normalized * -5

                                MapCarouselCard(
                                    mapName: map.name,
                                    systemImage: map.icon,
                                    compact: isLandscape
                                ) {
                                    openMap(named: map.name)
                                }
                                .scaleEffect(scale)
                                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                                .opacity(1.0 - abs(normalized) * 0.3)
                                .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: normalized)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            }
                            .frame(width: cardWidth, height: carouselHeight)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, sidePadding)
                    .padding(.bottom, DesignSystem.Spacing.xs)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(
                    id: .init(
                        get: { selectedMapIndex },
                        set: { if let newValue = $0 { selectedMapIndex = newValue } }
                    )
                )
            }
        }
        .frame(height: carouselHeight + DesignSystem.Spacing.xl)
    }

    var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<maps.count, id: \.self) { i in
                Capsule()
                    .fill(selectedMapIndex == i
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textTertiary.opacity(0.35))
                    .frame(width: selectedMapIndex == i ? 18 : 6, height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedMapIndex)
            }
            Spacer()
        }
        .padding(.top, DesignSystem.Spacing.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Map carousel page \(selectedMapIndex + 1) of \(maps.count)")
        .accessibilityValue(maps[selectedMapIndex].name)
    }
}

// MARK: - Country Spotlight Section
private extension HomeScreen {
    func spotlightSection(_ country: Country) -> some View {
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

    var spotlightCountry: Country? {
        countryDataService.countryOfTheDay()
    }

    func spotlightFunFact(for country: Country) -> String? {
        let facts = CountryFunFacts.data[country.code] ?? []
        return facts.first
    }
}

// MARK: - Streak Section
private extension HomeScreen {
    var streakSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Daily Streak")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeStreakCard(
                streak: streakService.currentStreak,
                isAtRisk: streakService.currentStreak > 0 && !streakService.hasPlayedToday
            ) {
                coordinator.sheet(.quizSetup)
            }
        }
    }
}

// MARK: - Progress Section
private extension HomeScreen {
    var progressSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Statistics")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeProgressCard(
                favoriteCount: favoritesService.favoriteCodes.count,
                exploredContinents: exploredContinents,
                currentLevel: xpService.currentLevel.level,
                currentLevelTitle: xpService.currentLevel.title,
                nextLevelNumber: nextLevelNumber,
                xpInCurrentLevel: xpService.xpInCurrentLevel,
                xpRequiredForNextLevel: xpService.xpRequiredForNextLevel,
                progressFraction: xpService.progressFraction,
                onFavoritesTap: { coordinator.sheet(.favorites) },
                onCountriesTap: { coordinator.sheet(.countries) },
                onProfileTap: { coordinator.sheet(.profile) }
            )
        }
    }

    var exploredContinents: Int {
        let codes = favoritesService.favoriteCodes
        let continents = Set(
            countryDataService.countries
                .filter { codes.contains($0.code) }
                .map { $0.continent }
        )
        return continents.count
    }

    var nextLevelNumber: Int? {
        let current = xpService.currentLevel
        guard current.maxXP != Int.max else { return nil }
        return current.level + 1
    }
}

// MARK: - Coming Soon Section
private extension HomeScreen {
    var comingSoonSection: some View {
        HomeComingSoonSection()
    }
}

// MARK: - Helpers
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

    func startAnimations() {
        appeared = true
    }

    func openMap(named name: String) {
        coordinator.cover(.mapFullScreen(continentFilter: name == "World map" ? nil : name))
    }

    func loadDailyChallenge() {
        let service = DailyChallengeService(
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        service.loadChallenge()
        dailyChallengeService = service
    }

    @ViewBuilder
    func sectionView(for section: HomeSection) -> some View {
        if let flag = section.featureFlag, !featureFlags.isEnabled(flag) {
            EmptyView()
        } else if sectionNeedsPadding(section) {
            paddedSectionView(for: section)
                .padding(.horizontal, DesignSystem.Spacing.md)
        } else {
            fullWidthSectionView(for: section)
        }
    }

    @ViewBuilder
    func paddedSectionView(for section: HomeSection) -> some View {
        switch section {
        case .guestBanner: GuestModePromptBanner()
        case .spotlight:
            if let country = spotlightCountry { spotlightSection(country) }
        case .streak: streakSection
        case .dailyChallenge: dailyChallengeSection
        case .srsReview: srsReviewSection
        case .progress: progressSection
        default: gameSectionView(for: section)
        }
    }

    @ViewBuilder
    func gameSectionView(for section: HomeSection) -> some View {
        switch section {
        case .flagGame: flagGameSection
        case .trivia: triviaSection
        case .spellingBee: spellingBeeSection
        case .learningPath: learningPathSection
        case .mapPuzzle: mapPuzzleSection
        case .landmarkQuiz: landmarkQuizSection
        case .feed: feedSection
        case .continentStats: continentStatsSection
        case .countryCompare: countryCompareSection
        case .travelBucketList: travelBucketListSection
        case .oceanExplorer: oceanExplorerSection
        case .languageExplorer: languageExplorerSection
        default: newFeatureSectionView(for: section)
        }
    }

    @ViewBuilder
    func fullWidthSectionView(for section: HomeSection) -> some View {
        switch section {
        case .carousel: carouselSection
        case .worldRecords: worldRecordsSection
        case .organizations: orgsSection
        case .comingSoon: comingSoonSection
        default: EmptyView()
        }
    }

    func sectionNeedsPadding(_ section: HomeSection) -> Bool {
        switch section {
        case .carousel, .worldRecords, .organizations, .comingSoon: false
        default: true
        }
    }
}

// MARK: - Feed Section Modifier
private extension View {
    func feedSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .transaction { transaction in
                if appeared {
                    transaction.animation = .easeOut(duration: 0.4).delay(delay)
                }
            }
    }
}
