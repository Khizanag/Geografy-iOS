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
            // Section 1 — top
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.accent.opacity(0.28), .clear], center: .center, startRadius: 0, endRadius: 220))
                .frame(width: 440, height: 320).blur(radius: 32)
                .offset(x: -80, y: 20)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.indigo.opacity(0.20), .clear], center: .center, startRadius: 0, endRadius: 180))
                .frame(width: 360, height: 300).blur(radius: 40)
                .offset(x: 140, y: 80)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            // Section 2 — mid
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.blue.opacity(0.14), .clear], center: .center, startRadius: 0, endRadius: 160))
                .frame(width: 320, height: 260).blur(radius: 36)
                .offset(x: -100, y: 600)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.purple.opacity(0.12), .clear], center: .center, startRadius: 0, endRadius: 160))
                .frame(width: 320, height: 280).blur(radius: 44)
                .offset(x: 160, y: 900)
                .scaleEffect(blobAnimating ? 0.92 : 1.08)
            // Section 3 — lower-mid
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.accent.opacity(0.12), .clear], center: .center, startRadius: 0, endRadius: 180))
                .frame(width: 360, height: 280).blur(radius: 40)
                .offset(x: -60, y: 1300)
                .scaleEffect(blobAnimating ? 1.04 : 0.96)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.indigo.opacity(0.14), .clear], center: .center, startRadius: 0, endRadius: 160))
                .frame(width: 320, height: 260).blur(radius: 36)
                .offset(x: 140, y: 1650)
                .scaleEffect(blobAnimating ? 0.90 : 1.08)
            // Section 4 — bottom
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.blue.opacity(0.10), .clear], center: .center, startRadius: 0, endRadius: 200))
                .frame(width: 400, height: 300).blur(radius: 50)
                .offset(x: -80, y: 2000)
                .scaleEffect(blobAnimating ? 1.05 : 0.95)
            Ellipse()
                .fill(RadialGradient(colors: [DesignSystem.Color.accent.opacity(0.10), .clear], center: .center, startRadius: 0, endRadius: 180))
                .frame(width: 360, height: 280).blur(radius: 44)
                .offset(x: 120, y: 2350)
                .scaleEffect(blobAnimating ? 0.93 : 1.07)
        }
        // swiftlint:enable line_length
        .allowsHitTesting(false)
    }
}

// MARK: - Main Feed

private extension HomeScreen {
    var mainFeed: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .top) {
                scrollableBlobs
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

                    quizSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .feedSection(appeared: appeared, delay: 0.15)

                    if let country = spotlightCountry {
                        spotlightSection(country)
                            .padding(.top, DesignSystem.Spacing.xl)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .feedSection(appeared: appeared, delay: 0.20)
                    }

                    orgsSection
                        .padding(.top, DesignSystem.Spacing.xl)
                        .feedSection(appeared: appeared, delay: 0.25)

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
        }
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
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
        }
    }

    var mapCarousel: some View {
        TabView(selection: $selectedMapIndex) {
            ForEach(Array(maps.enumerated()), id: \.offset) { index, map in
                MapCarouselCard(mapName: map.name, systemImage: map.icon, compact: isLandscape) {
                    openMap(named: map.name)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, 20)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: carouselHeight + 20)
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
    }
}

// MARK: - Quiz Section

private extension HomeScreen {
    var quizSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionLabel("Daily Quiz")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeQuizCard { showQuiz = true }
        }
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
