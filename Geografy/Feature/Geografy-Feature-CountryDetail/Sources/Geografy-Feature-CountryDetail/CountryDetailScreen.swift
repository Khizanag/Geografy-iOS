import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_CountryProfile
import Geografy_Feature_Travel
import SwiftUI

public struct CountryDetailScreen: View {
    @Environment(Navigator.self) var coordinator
    @Environment(SubscriptionService.self) var subscriptionService
    @Environment(TravelService.self) var travelService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) var xpService
    @Environment(AchievementService.self) var achievementService
    @Environment(HapticsService.self) var hapticsService
    @Environment(WorldBankService.self) private var worldBankService
    @Environment(PronunciationService.self) private var pronunciationService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State var profileService = CountryProfileService()
    @State var appeared = false
    @State var activeSheet: CountryDetailSheet?
    @State var showFlagFullScreen = false
    @State var flagScrolledUp = false
    @State private var selectedStatCategory: StatCategory = .economy
    @State var populationStartDate = Date()

    public let country: Country

    public init(country: Country) {
        self.country = country
    }

    public var body: some View {
        contentScrollView
            .background(DesignSystem.Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .toolbar { favoriteToolbarItem }
            .toolbar { compareToolbarItem }
            .toolbar { principalToolbarItem }
            .task { trackExploration() }
            .onAppear { appeared = true }
            .userActivity("com.khizanag.geografy.viewCountry") { activity in
                activity.title = country.name
                activity.isEligibleForHandoff = true
                activity.userInfo = ["countryCode": country.code]
            }
            .sheet(item: $activeSheet) { sheet in countryDetailSheetContent(for: sheet) }
            .overlay { flagFullScreenOverlay }
    }
}

// MARK: - Info Item
extension CountryDetailScreen {
    struct InfoItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let value: String
        let supportsMap: Bool
        var mapButtonTitle: String = "Show on the map"
        var actionButtonTitle: String?
        var actionButtonIcon: String?
        var onAction: (() -> Void)?
    }

    enum CountryDetailSheet: Identifiable {
        case travelPicker
        case info(InfoItem)
        case deepDive

        var id: String {
            switch self {
            case .travelPicker: "travelPicker"
            case .info(let item): "info-\(item.id)"
            case .deepDive: "deepDive"
            }
        }
    }
}

// MARK: - Toolbar
private extension CountryDetailScreen {
    var isFavorite: Bool {
        favoritesService.isFavorite(code: country.code)
    }

    @ToolbarContentBuilder
    var favoriteToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                hapticsService.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoritesService.toggle(code: country.code)
                }
            } label: {
                Label("Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                    .symbolEffect(.bounce, value: isFavorite)
            }
            .tint(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.iconPrimary)
            .buttonStyle(.plain)
        }
    }

    @ToolbarContentBuilder
    var compareToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
            Button {
                hapticsService.impact(.light)
                coordinator.sheet(.compare(preselectedCountry: country))
            } label: {
                Label("Compare", systemImage: "arrow.left.arrow.right")
            }
            .tint(DesignSystem.Color.iconPrimary)
            .buttonStyle(.plain)
        }
    }

    @ToolbarContentBuilder
    var principalToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: flagScrolledUp ? DesignSystem.Spacing.xs : 0) {
                FlagView(countryCode: country.code, height: 20, fixedWidth: true)
                    .opacity(flagScrolledUp ? 1 : 0)
                    .scaleEffect(flagScrolledUp ? 1 : 0.5)
                    .frame(width: flagScrolledUp ? nil : 0, height: 20)
                    .clipped()
                Text(country.name)
                    .font(DesignSystem.Font.headline)
            }
            .animation(.easeInOut(duration: 0.2), value: flagScrolledUp)
        }
    }
}

// MARK: - Section Header
extension CountryDetailScreen {
    public func sectionHeader(_ title: String, premium: Bool = false) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
            if premium, subscriptionService.isPremium {
                PremiumBadge()
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Locked Content
extension CountryDetailScreen {
    public func lockedSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader(title)
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(height: 80)
                PremiumLockedOverlay(onUnlock: { coordinator.sheet(.paywall) })
            }
        }
    }

    public func lockedPlaceholder(height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .frame(height: height)
            PremiumLockedOverlay(onUnlock: { coordinator.sheet(.paywall) })
        }
    }
}

// MARK: - Navigation
extension CountryDetailScreen {
    public func navigateToCountry(_ country: Country) {
        coordinator.push(.countryDetail(country))
    }

    public func navigateToOrganization(_ organization: Organization) {
        coordinator.push(.organizationDetail(organization))
    }

    public func navigateToContinent(_ continent: Country.Continent) {
        coordinator.push(.continentOverview(continent))
    }
}

// MARK: - Helpers
extension CountryDetailScreen {
    var capitalInfoValue: String {
        country.allCapitals
            .map { capital in
                if let role = capital.role {
                    "\(capital.name) (\(role))"
                } else {
                    capital.name
                }
            }
            .joined(separator: "\n")
    }

    var religionItems: [PercentageItem] {
        ReligionData.data[country.code] ?? []
    }

    var ethnicityItems: [PercentageItem] {
        EthnicityData.data[country.code] ?? []
    }

    @ViewBuilder
    var religionSection: some View {
        if subscriptionService.isPremium {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Religion", premium: true)
                PercentageBarChart(
                    items: religionItems.sorted { $0.percentage > $1.percentage },
                    appeared: true
                )
            }
        } else {
            lockedSection(title: "Religion")
        }
    }

    @ViewBuilder
    var ethnicitySection: some View {
        if subscriptionService.isPremium {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Ethnicity", premium: true)
                PercentageBarChart(
                    items: ethnicityItems.sorted { $0.percentage > $1.percentage },
                    appeared: true
                )
            }
        } else {
            lockedSection(title: "Ethnicity")
        }
    }

    var statisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Statistics", premium: true)
            CountryStatisticsView(countryCode: country.code)
        }
    }

    var contentScrollView: some View {
        ScrollView {
            contentStack
        }
    }

    var contentStack: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            topSections
            bottomSections
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xxl)
        .readableContentWidth()
    }

    @ViewBuilder
    var topSections: some View {
        heroSection
        quickFactsCard
        travelSection
        neighborsSection(countryDataService: countryDataService)
        peopleSection
        if !religionItems.isEmpty {
            religionSection
        }
        if !ethnicityItems.isEmpty {
            ethnicitySection
        }
        if hasEconomyData {
            if subscriptionService.isPremium {
                economySection
            } else {
                lockedSection(title: "Economy")
            }
        }
        if subscriptionService.isPremium {
            governmentSection
            currencySection
            statisticsSection
        }
    }

    @ViewBuilder
    var bottomSections: some View {
        if !memberOrganizations.isEmpty {
            organizationsSection(
                countryDataService: countryDataService,
                hapticsService: hapticsService
            )
        }
        flagSymbolismSection
        phrasebookSection
        funFactsSection
        unescoSection
        deepDiveSection
        #if !os(tvOS)
        WikipediaSection(countryName: country.name)
        #endif
        continentExploreSection
    }

    @ViewBuilder
    var flagFullScreenOverlay: some View {
        if showFlagFullScreen {
            ZoomableFlagView(countryCode: country.code) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showFlagFullScreen = false
                }
            }
            .transition(.opacity)
        }
    }
}
