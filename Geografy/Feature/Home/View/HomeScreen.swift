import SwiftUI

private struct ComingSoonItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct HomeScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(AuthService.self) private var authService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService

    @State private var countryDataService = CountryDataService()
    @State private var selectedMapIndex = 0
    @State private var mapTarget: MapTarget?
    @State private var showQuiz = false
    @State private var showProfile = false
    @State private var showSignIn = false
    @State private var showFriends = false
    @State private var showAllOrgs = false
    @State private var selectedOrg: Organization?
    @State private var comingSoonItem: ComingSoonItem?
    @State private var showFavorites = false
    @State private var showCountries = false
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
        .toolbar {
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
        .fullScreenCover(item: $mapTarget) { target in
            NavigationStack {
                MapScreen(continentFilter: target.continentFilter)
                    .navigationDestination(for: Country.self) { country in
                        CountryDetailScreen(country: country)
                    }
            }
        }
        .sheet(isPresented: $showQuiz) {
            QuizSetupScreen()
        }
        .sheet(isPresented: $showSignIn) {
            SignInOptionsSheet()
        }
        .sheet(isPresented: $showProfile) {
            NavigationStack {
                ProfileScreen()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.automatic)
        }
        .sheet(isPresented: $showFriends) {
            ComingSoonSheet(title: "Friends", icon: "person.2.fill")
        }
        .sheet(isPresented: $showAllOrgs) {
            NavigationStack {
                OrganizationsScreen()
            }
        }
        .sheet(item: $selectedOrg) { org in
            NavigationStack {
                OrganizationDetailScreen(organization: org)
            }
        }
        .sheet(item: $comingSoonItem) { item in
            ComingSoonSheet(title: item.title, icon: item.icon)
        }
        .sheet(isPresented: $showFavorites) {
            NavigationStack { FavoritesScreen() }
        }
        .sheet(isPresented: $showCountries) {
            NavigationStack { CountryListScreen() }
        }
        .task { countryDataService.loadCountries() }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
            withAnimation(.easeOut(duration: 0.7)) {
                appeared = true
            }
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
            VStack(spacing: 0) {
                    greetingSection
                        .padding(.top, DesignSystem.Spacing.lg)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .feedSection(appeared: appeared, delay: 0.05)

                    GuestModePromptBanner()
                        .padding(.top, DesignSystem.Spacing.md)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .feedSection(appeared: appeared, delay: 0.08)

                    carouselSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .feedSection(appeared: appeared, delay: 0.10)

                    if let country = spotlightCountry {
                        spotlightSection(country)
                            .padding(.top, DesignSystem.Spacing.xl)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .feedSection(appeared: appeared, delay: 0.20)
                    }

                    streakSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .feedSection(appeared: appeared, delay: 0.22)

                    worldRecordsSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .feedSection(appeared: appeared, delay: 0.24)

                    orgsSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .feedSection(appeared: appeared, delay: 0.27)

                    progressSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .feedSection(appeared: appeared, delay: 0.30)

                    comingSoonSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .feedSection(appeared: appeared, delay: 0.35)
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
        .background { scrollableBlobs.ignoresSafeArea() }
    }
}

// MARK: - Top Bar

private extension HomeScreen {
    var profileButton: some View {
        Button { showProfile = true } label: {
            profileAvatarView
        }
    }

    var profileAvatarView: some View {
        LevelBadgeView(level: xpService.currentLevel, size: .small)
    }

    var statsButton: some View {
        Button { showProfile = true } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                xpIndicator
                divider
                currencyItem(icon: "circle.fill", color: .yellow, value: "1,250")
            }
        }
        .buttonStyle(.glass)
        .fixedSize(horizontal: false, vertical: true)
    }

    var friendsButton: some View {
        Button { showFriends = true } label: {
            Image(systemName: "person.2.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .padding(DesignSystem.Spacing.sm)
        }
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
        .frame(height: DesignSystem.Size.xs)
    }

    var divider: some View {
        Rectangle()
            .fill(DesignSystem.Color.textTertiary.opacity(0.3))
            .frame(width: DesignSystem.Size.xxs, height: DesignSystem.Size.sm)
    }

    func currencyItem(icon: String, color: Color, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
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
                Text("Explorer")
                    .font(DesignSystem.Font.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            Spacer()
            globeBadge
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
            sectionLabel("Explore Maps")
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
                            }
                            .frame(width: cardWidth, height: carouselHeight)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, sidePadding)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: .init(
                    get: { selectedMapIndex },
                    set: { if let newValue = $0 { selectedMapIndex = newValue } }
                ))
            }
        }
        .frame(height: carouselHeight + DesignSystem.Spacing.xxl * 2)
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
            sectionLabel("Discover")
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
            sectionLabel("Daily Streak")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeStreakCard(streak: streakService.currentStreak) {
                showQuiz = true
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
                onOrgTap: { selectedOrg = $0 },
                onSeeAll: { showAllOrgs = true }
            )
        }
    }
}

// MARK: - Progress Section

private extension HomeScreen {
    var progressSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionLabel("Statistics")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeProgressCard(
                favoriteCount: favoritesService.favoriteCodes.count,
                exploredContinents: exploredContinents,
                currentLevel: xpService.currentLevel.level,
                onFavoritesTap: { showFavorites = true },
                onCountriesTap: { showCountries = true },
                onProfileTap: { showProfile = true }
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
            comingSoonItem = ComingSoonItem(title: title, icon: icon)
        }
    }
}

// MARK: - Helpers

private extension HomeScreen {
    func sectionLabel(_ title: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignSystem.Color.accent)
                .frame(width: 3, height: 18)
            Text(title)
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    func openMap(named name: String) {
        mapTarget = MapTarget(continentFilter: name == "World map" ? nil : name)
    }
}

// MARK: - Feed Section Modifier

private extension View {
    func feedSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(delay), value: appeared)
    }
}
