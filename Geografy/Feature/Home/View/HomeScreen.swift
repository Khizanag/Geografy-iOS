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
    @Environment(TabCoordinator.self) var coordinator

    @State var countryDataService = CountryDataService()
    @State var dailyChallengeService: DailyChallengeService?
    @State private var selectedMapIndex = 0
    @State private var blobAnimating = false
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
        ZStack {
            ambientBackground
            mainFeed
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar { toolbarContent }
        .task {
            countryDataService.loadCountries()
            loadDailyChallenge()
            startAnimations()
        }
    }
}

// MARK: - Background

private extension HomeScreen {
    var ambientBackground: some View {
        DesignSystem.Color.background.ignoresSafeArea()
    }

    var scrollableBlobs: some View {
        ZStack(alignment: .top) {
            // Section 1 — top hero
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.accent, opacity: 0.35,
                    endRadius: 280, width: 560, height: 420, blur: 40,
                    offset: (-100, 0), scale: blobAnimating ? 1.12 : 0.88
                )
            )
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.indigo, opacity: 0.28,
                    endRadius: 240, width: 480, height: 380, blur: 48,
                    offset: (180, 60), scale: blobAnimating ? 0.86 : 1.12
                )
            )
            // Section 2 — carousel
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.blue, opacity: 0.22,
                    endRadius: 220, width: 440, height: 340, blur: 44,
                    offset: (-140, 550), scale: blobAnimating ? 1.08 : 0.92
                )
            )
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.purple, opacity: 0.18,
                    endRadius: 200, width: 400, height: 360, blur: 52,
                    offset: (200, 800), scale: blobAnimating ? 0.90 : 1.10
                )
            )
            // Section 3 — quiz / discover
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.accent, opacity: 0.20,
                    endRadius: 220, width: 440, height: 340, blur: 48,
                    offset: (-80, 1200), scale: blobAnimating ? 1.06 : 0.94
                )
            )
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.indigo, opacity: 0.22,
                    endRadius: 200, width: 400, height: 320, blur: 44,
                    offset: (180, 1500), scale: blobAnimating ? 0.88 : 1.10
                )
            )
            // Section 4 — records / orgs
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.blue, opacity: 0.18,
                    endRadius: 240, width: 480, height: 360, blur: 52,
                    offset: (-120, 1900), scale: blobAnimating ? 1.07 : 0.93
                )
            )
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.purple, opacity: 0.16,
                    endRadius: 220, width: 440, height: 340, blur: 48,
                    offset: (160, 2250), scale: blobAnimating ? 0.91 : 1.09
                )
            )
            // Section 5 — stats / coming soon
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.accent, opacity: 0.16,
                    endRadius: 240, width: 480, height: 360, blur: 52,
                    offset: (-100, 2700), scale: blobAnimating ? 1.05 : 0.95
                )
            )
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.indigo, opacity: 0.18,
                    endRadius: 220, width: 440, height: 340, blur: 44,
                    offset: (140, 3100), scale: blobAnimating ? 0.92 : 1.08
                )
            )
            homeBlob(
                BlobConfig(
                    color: DesignSystem.Color.blue, opacity: 0.14,
                    endRadius: 260, width: 520, height: 380, blur: 56,
                    offset: (-80, 3500), scale: blobAnimating ? 1.06 : 0.94
                )
            )
        }
        .allowsHitTesting(false)
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

    func homeBlob(_ config: BlobConfig) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [config.color.opacity(config.opacity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: config.endRadius
                )
            )
            .frame(width: config.width, height: config.height)
            .blur(radius: config.blur)
            .offset(x: config.offset.0, y: config.offset.1)
            .scaleEffect(config.scale)
    }
}

// MARK: - Main Feed

private extension HomeScreen {
    var mainFeed: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                greetingSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.05)

                ForEach(Array(sectionOrderService.sections.enumerated()), id: \.element) { index, section in
                    sectionView(for: section)
                        .feedSection(appeared: appeared, delay: 0.08 + Double(index) * 0.04)
                }
            }
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .background(alignment: .top) {
                scrollableBlobs
            }
        }
    }
}

// MARK: - Top Bar

private extension HomeScreen {
    var profileButton: some View {
        Button { coordinator.present(.profile) } label: {
            ProfileAvatarView(
                name: authService.currentProfile?.displayName ?? "Explorer",
                size: DesignSystem.Size.md
            )
        }
        .buttonStyle(.plain)
    }

    var statsButton: some View {
        Button { coordinator.present(.coinStore) } label: {
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
            Text(coinService.formattedBalance)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
        }
    }

    var searchButton: some View {
        Button { coordinator.present(.search) } label: {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .accessibilityLabel("Search")
        }
        .buttonStyle(.plain)
    }

    var friendsButton: some View {
        Button { coordinator.present(.friends) } label: {
            Image(systemName: "person.2")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .accessibilityLabel("Friends")
        }
        .buttonStyle(.plain)
    }

    var xpIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            xpProgressBar
            Text("Lv. \(xpService.currentLevel.level)")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
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
                Text(authService.currentProfile?.displayName ?? "Explorer")
                    .font(DesignSystem.Font.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            Spacer()
            editSectionsButton
            globeBadge
        }
    }

    var editSectionsButton: some View {
        Button { coordinator.present(.sectionEditor) } label: {
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
    var isCompactHeight: Bool { UIScreen.main.bounds.height <= 812 }
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
                .scrollClipDisabled()
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
    }
}

// MARK: - Country Spotlight Section

private extension HomeScreen {
    func spotlightSection(_ country: Country) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Discover")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            Button { coordinator.push(.countryDetail(country)) } label: {
                HomeCountrySpotlightCard(
                    country: country,
                    funFact: spotlightFunFact(for: country)
                )
            }
            .buttonStyle(PressButtonStyle())
        }
    }

    var spotlightCountry: Country? {
        guard !countryDataService.countries.isEmpty else { return nil }
        let sorted = countryDataService.countries.sorted { $0.code < $1.code }
        let year = Calendar.current.component(.year, from: Date())
        let dayOfYear = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) - 1
        let shuffled = sorted.seededShuffle(seed: UInt64(year) &* 2_654_435_761)
        return shuffled[dayOfYear % shuffled.count]
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
                coordinator.present(.quizSetup)
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
                onFavoritesTap: { coordinator.present(.favorites) },
                onCountriesTap: { coordinator.present(.countries) },
                onProfileTap: { coordinator.present(.profile) }
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
        withAnimation(.easeOut(duration: 0.5)) {
            appeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
        }
    }

    func openMap(named name: String) {
        coordinator.presentFullScreen(.map(continentFilter: name == "World map" ? nil : name))
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
        if sectionNeedsPadding(section) {
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
        case .geoTrivia: geoTriviaSection
        case .spellingBee: spellingBeeSection
        case .learningPath: learningPathSection
        case .mapPuzzle: mapPuzzleSection
        case .landmarkQuiz: landmarkQuizSection
        case .geoFeed: geoFeedSection
        case .continentStats: continentStatsSection
        case .countryCompare: countryCompareSection
        case .travelBucketList: travelBucketListSection
        case .oceanExplorer: oceanExplorerSection
        case .languageExplorer: languageExplorerSection
        case .challengeRoom: challengeRoomSection
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
