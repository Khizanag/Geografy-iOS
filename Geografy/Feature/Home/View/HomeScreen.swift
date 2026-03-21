import SwiftUI

struct HomeScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(AuthService.self) private var authService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService
    @Environment(CoinService.self) private var coinService
    @Environment(HomeSectionOrderService.self) private var sectionOrderService

    @State private var countryDataService = CountryDataService()
    @State private var selectedMapIndex = 0
    @State private var mapTarget: MapTarget?
    @State private var activeSheet: HomeSheet?
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
        .fullScreenCover(item: $mapTarget) { target in
            mapFullScreenCover(for: target)
        }
        .modifier(
            HomeSheetsModifier(
                activeSheet: $activeSheet,
                sectionOrder: sectionOrderService.sections
            )
        )
        .task { countryDataService.loadCountries() }
        .onAppear { startAnimations() }
    }
}

// MARK: - Background

private extension HomeScreen {
    var ambientBackground: some View {
        DesignSystem.Color.background.ignoresSafeArea()
    }

    var scrollableBlobs: some View {
        ZStack(alignment: .top) {
            // swiftlint:disable line_length
            // Section 1 — top hero
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.accent.opacity(0.35), .clear], center: .center, startRadius: 0, endRadius: 280))
                .frame(width: 560, height: 420).blur(radius: 40)
                .offset(x: -100, y: 0)
                .scaleEffect(blobAnimating ? 1.12 : 0.88)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.indigo.opacity(0.28), .clear], center: .center, startRadius: 0, endRadius: 240))
                .frame(width: 480, height: 380).blur(radius: 48)
                .offset(x: 180, y: 60)
                .scaleEffect(blobAnimating ? 0.86 : 1.12)
            // Section 2 — carousel
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.blue.opacity(0.22), .clear], center: .center, startRadius: 0, endRadius: 220))
                .frame(width: 440, height: 340).blur(radius: 44)
                .offset(x: -140, y: 550)
                .scaleEffect(blobAnimating ? 1.08 : 0.92)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.purple.opacity(0.18), .clear], center: .center, startRadius: 0, endRadius: 200))
                .frame(width: 400, height: 360).blur(radius: 52)
                .offset(x: 200, y: 800)
                .scaleEffect(blobAnimating ? 0.90 : 1.10)
            // Section 3 — quiz / discover
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.accent.opacity(0.20), .clear], center: .center, startRadius: 0, endRadius: 220))
                .frame(width: 440, height: 340).blur(radius: 48)
                .offset(x: -80, y: 1200)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.indigo.opacity(0.22), .clear], center: .center, startRadius: 0, endRadius: 200))
                .frame(width: 400, height: 320).blur(radius: 44)
                .offset(x: 180, y: 1500)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            // Section 4 — records / orgs
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.blue.opacity(0.18), .clear], center: .center, startRadius: 0, endRadius: 240))
                .frame(width: 480, height: 360).blur(radius: 52)
                .offset(x: -120, y: 1900)
                .scaleEffect(blobAnimating ? 1.07 : 0.93)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.purple.opacity(0.16), .clear], center: .center, startRadius: 0, endRadius: 220))
                .frame(width: 440, height: 340).blur(radius: 48)
                .offset(x: 160, y: 2250)
                .scaleEffect(blobAnimating ? 0.91 : 1.09)
            // Section 5 — stats / coming soon
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.accent.opacity(0.16), .clear], center: .center, startRadius: 0, endRadius: 240))
                .frame(width: 480, height: 360).blur(radius: 52)
                .offset(x: -100, y: 2700)
                .scaleEffect(blobAnimating ? 1.05 : 0.95)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.indigo.opacity(0.18), .clear], center: .center, startRadius: 0, endRadius: 220))
                .frame(width: 440, height: 340).blur(radius: 44)
                .offset(x: 140, y: 3100)
                .scaleEffect(blobAnimating ? 0.92 : 1.08)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.blue.opacity(0.14), .clear], center: .center, startRadius: 0, endRadius: 260))
                .frame(width: 520, height: 380).blur(radius: 56)
                .offset(x: -80, y: 3500)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
            // swiftlint:enable line_length
        }
        .allowsHitTesting(false)
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
        }
        .background { scrollableBlobs.ignoresSafeArea() }
    }
}

// MARK: - Top Bar

private extension HomeScreen {
    var profileButton: some View {
        Button { activeSheet = .profile } label: {
            profileAvatar
        }
        .buttonStyle(.plain)
    }

    var profileAvatar: some View {
        ProfileAvatarView(
            name: authService.currentProfile?.displayName ?? "Explorer",
            size: DesignSystem.Size.md
        )
    }

    var statsButton: some View {
        Button { activeSheet = .coinStore } label: {
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

    var friendsButton: some View {
        Button { activeSheet = .friends } label: {
            Image(systemName: "person.2")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
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
                Text("Explorer")
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
        Button { activeSheet = .sectionEditor } label: {
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
    var carouselHeight: CGFloat { isLandscape ? 200 : 320 }

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
            SectionHeaderView(title:"Explore Maps")
            Spacer()
            Text("\(selectedMapIndex + 1) / \(maps.count)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.trailing, DesignSystem.Spacing.xs)
            NavigationLink(value: NavigationRoute.allMaps) {
                Text("See All")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
    }

    var mapCarousel: some View {
        GeometryReader { outerGeo in
            let cardWidth = outerGeo.size.width * 0.78
            let spacing: CGFloat = DesignSystem.Spacing.sm
            let sidePadding = (outerGeo.size.width - cardWidth) / 2

            ScrollViewReader { proxy in
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
                            .frame(width: cardWidth, height: carouselHeight + DesignSystem.Spacing.xxl)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, sidePadding)
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
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
        .frame(height: carouselHeight + DesignSystem.Spacing.xxl + DesignSystem.Spacing.lg)
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
        .padding(.top, DesignSystem.Spacing.xs)
    }
}

// MARK: - Country Spotlight Section

private extension HomeScreen {
    func spotlightSection(_ country: Country) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title:"Discover")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            NavigationLink(value: country) {
                HomeCountrySpotlightCard(country: country)
            }
            .buttonStyle(GeoPressButtonStyle())
        }
    }

    var spotlightCountry: Country? {
        guard !countryDataService.countries.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return countryDataService.countries[(dayOfYear - 1) % countryDataService.countries.count]
    }
}

// MARK: - Streak Section

private extension HomeScreen {
    var streakSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title:"Daily Streak")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeStreakCard(streak: streakService.currentStreak) {
                activeSheet = .quiz
            }
        }
    }
}

// MARK: - World Records Section

private extension HomeScreen {
    var worldRecordsSection: some View {
        HomeWorldRecordsCard()
    }
}

// MARK: - Organizations Section

private extension HomeScreen {
    var orgsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HomeOrgsCard(
                onOrgTap: { activeSheet = .orgDetail($0) },
                onSeeAll: { activeSheet = .allOrgs }
            )
        }
    }
}

// MARK: - Progress Section

private extension HomeScreen {
    var progressSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title:"Statistics")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeProgressCard(
                favoriteCount: favoritesService.favoriteCodes.count,
                exploredContinents: exploredContinents,
                currentLevel: xpService.currentLevel.level,
                onFavoritesTap: { activeSheet = .favorites },
                onCountriesTap: { activeSheet = .countries },
                onProfileTap: { activeSheet = .profile }
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
}

// MARK: - Coming Soon Section

private extension HomeScreen {
    var comingSoonSection: some View {
        HomeComingSoonSection { title, icon in
            activeSheet = .comingSoon(title: title, icon: icon)
        }
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
            friendsButton
        }
    }

    func mapFullScreenCover(for target: MapTarget) -> some View {
        NavigationStack {
            MapScreen(continentFilter: target.continentFilter)
                .navigationDestination(for: Country.self) { country in
                    CountryDetailScreen(country: country)
                }
        }
    }

    func startAnimations() {
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            blobAnimating = true
        }
        withAnimation(.easeOut(duration: 0.7)) {
            appeared = true
        }
    }

    func openMap(named name: String) {
        mapTarget = MapTarget(continentFilter: name == "World map" ? nil : name)
    }

    @ViewBuilder
    func sectionView(for section: HomeSection) -> some View {
        switch section {
        case .guestBanner:
            GuestModePromptBanner()
                .padding(.horizontal, DesignSystem.Spacing.md)
        case .carousel:
            carouselSection
        case .spotlight:
            if let country = spotlightCountry {
                spotlightSection(country)
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }
        case .streak:
            streakSection
                .padding(.horizontal, DesignSystem.Spacing.md)
        case .worldRecords:
            worldRecordsSection
        case .organizations:
            orgsSection
        case .progress:
            progressSection
                .padding(.horizontal, DesignSystem.Spacing.md)
        case .comingSoon:
            comingSoonSection
        }
    }
}

// MARK: - Feed Section Modifier

private extension View {
    func feedSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(delay), value: appeared)
    }
}
