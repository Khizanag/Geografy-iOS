import SwiftUI
import GeografyDesign
import GeografyCore

struct HomeScreen: View {
    @State private var countryDataService = CountryDataService()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    TVHomeFeedView(countryDataService: countryDataService)
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                }
            }

            Tab("Map", systemImage: "map.fill") {
                NavigationStack {
                    MapScreen(countryDataService: countryDataService)
                }
            }

            Tab("Countries", systemImage: "globe") {
                NavigationStack {
                    CountryBrowserScreen(countryDataService: countryDataService)
                }
            }

            Tab("Quiz", systemImage: "gamecontroller.fill") {
                NavigationStack {
                    QuizSetupScreen(countryDataService: countryDataService)
                }
            }

            Tab("Explore", systemImage: "questionmark.circle") {
                NavigationStack {
                    ExploreGameScreen(countryDataService: countryDataService)
                }
            }

            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SearchScreen(countryDataService: countryDataService)
                }
            }

            Tab("More", systemImage: "ellipsis.circle") {
                NavigationStack {
                    MoreScreen(countryDataService: countryDataService)
                        .navigationDestination(for: Country.self) { country in
                            CountryDetailScreen(country: country)
                        }
                }
            }
        }
        .task { countryDataService.loadCountries() }
    }
}

// MARK: - Home Feed
struct TVHomeFeedView: View {
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService

    let countryDataService: CountryDataService

    @State private var selectedTab = 1
    @State private var selectedTab2 = 2

    var body: some View {
        ScrollView {
            VStack(spacing: 60) {
                heroSection
                    .focusSection()

                statsRow
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Your stats")

                spotlightSection
                    .focusSection()

                quickActionsSection
                    .focusSection()
            }
            .padding(80)
        }
        .background { AmbientBlobsView(.tv) }
    }
}

// MARK: - Hero
private extension TVHomeFeedView {
    var heroSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 80))
                .foregroundStyle(DesignSystem.Color.accent)

            Text("Geografy")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Explore the world from your living room")
                .font(.system(size: 28))
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Stats
private extension TVHomeFeedView {
    var statsRow: some View {
        HStack(spacing: 40) {
            tvStatCard(
                icon: "star.fill",
                value: "Level \(xpService.currentLevel.level)",
                label: xpService.currentLevel.title,
                color: DesignSystem.Color.accent
            )

            tvStatCard(
                icon: "flame.fill",
                value: "\(streakService.currentStreak)",
                label: "Day Streak",
                color: DesignSystem.Color.orange
            )

            tvStatCard(
                icon: "globe",
                value: "\(countryDataService.countries.count)",
                label: "Countries",
                color: DesignSystem.Color.blue
            )
        }
    }

    func tvStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(label)
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Spotlight
private extension TVHomeFeedView {
    @ViewBuilder
    var spotlightSection: some View {
        if let country = spotlightCountry {
            VStack(alignment: .leading, spacing: 20) {
                Text("Country of the Day")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                NavigationLink(value: country) {
                    HStack(spacing: 32) {
                        FlagView(countryCode: country.code, height: 80)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(country.name)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(DesignSystem.Color.textPrimary)

                            Text("\(country.capital) · \(country.continent.displayName)")
                                .font(.system(size: 22))
                                .foregroundStyle(DesignSystem.Color.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 24))
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                    .padding(32)
                    .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.card)
            }
        }
    }

    var spotlightCountry: Country? {
        countryDataService.countryOfTheDay()
    }
}

// MARK: - Quick Actions
private extension TVHomeFeedView {
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick Start")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            HStack(spacing: 32) {
                NavigationLink(value: TVQuickAction.quiz) {
                    tvActionCardLabel(
                        icon: "gamecontroller.fill",
                        title: "Start Quiz",
                        subtitle: "Test your knowledge",
                        color: DesignSystem.Color.accent
                    )
                }
                .buttonStyle(.card)

                NavigationLink(value: TVQuickAction.countries) {
                    tvActionCardLabel(
                        icon: "globe",
                        title: "Browse Countries",
                        subtitle: "Explore 197 nations",
                        color: DesignSystem.Color.blue
                    )
                }
                .buttonStyle(.card)

                NavigationLink(value: TVQuickAction.randomCountry) {
                    tvActionCardLabel(
                        icon: "shuffle",
                        title: "Random Country",
                        subtitle: "Discover something new",
                        color: DesignSystem.Color.purple
                    )
                }
                .buttonStyle(.card)
            }
        }
        .navigationDestination(for: TVQuickAction.self) { action in
            switch action {
            case .quiz:
                QuizSetupScreen(countryDataService: countryDataService)
            case .countries:
                CountryBrowserScreen(countryDataService: countryDataService)
            case .randomCountry:
                if let country = countryDataService.countries.randomElement() {
                    CountryDetailScreen(country: country)
                }
            }
        }
    }

    func tvActionCardLabel(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(subtitle)
                .font(.system(size: 18))
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(DesignSystem.Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Quick Action
enum TVQuickAction: Hashable {
    case quiz
    case countries
    case randomCountry
}
