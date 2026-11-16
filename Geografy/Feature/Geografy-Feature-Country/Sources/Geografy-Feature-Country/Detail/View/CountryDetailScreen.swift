import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct CountryDetailScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) var coordinator
    @Environment(TravelService.self) var travelService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(CollectionService.self) private var collectionService
    @Environment(XPService.self) var xpService
    @Environment(AchievementService.self) var achievementService
    @Environment(HapticsService.self) var hapticsService
    @Environment(WorldBankService.self) private var worldBankService
    @Environment(PronunciationService.self) private var pronunciationService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.colorSchemeContrast) var colorSchemeContrast

    @State var content: CountryDetailContent
    @State var scrollState = CountryDetailScrollState()
    @State var activeSheet: CountryDetailSheet?
    @State var afterSheetDismiss: (() -> Void)?
    @State var showFlagFullScreen = false
    @State private var selectedStatCategory: StatCategory = .economy
    @State var populationStartDate = Date()

    public let country: Country

    // MARK: - Init
    public init(country: Country) {
        self.country = country
        _content = State(initialValue: CountryDetailContent(country: country))
    }

    // MARK: - Body
    public var body: some View {
        contentScrollView
            .screenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
            .task { trackExploration() }
            .userActivity("com.khizanag.geografy.viewCountry") { activity in
                activity.title = country.name
                activity.isEligibleForHandoff = true
                activity.userInfo = ["countryCode": country.code]
            }
            .sheet(item: $activeSheet, onDismiss: runAfterSheetDismiss) { sheet in
                countryDetailSheetContent(for: sheet)
            }
            .zoomableViewer(isPresented: $showFlagFullScreen, title: country.name) {
                ZoomableFlagView(countryCode: country.code) { showFlagFullScreen = false }
            }
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
        case info(InfoItem)
        case travelStatus

        var id: String {
            switch self {
            case .info(let item): "info-\(item.id)"
            case .travelStatus: "travelStatus"
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
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            CountryDetailNavigationTitle(country: country, scrollState: scrollState)
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                hapticsService.impact(.light)
                withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6)) {
                    favoritesService.toggle(code: country.code)
                }
            } label: {
                Label(
                    isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: isFavorite ? "heart.fill" : "heart"
                )
                .foregroundStyle(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.iconPrimary)
                .symbolEffect(.bounce, value: reduceMotion ? false : isFavorite)
            }
            .buttonStyle(.plain)
        }

        #if os(tvOS)
        ToolbarItem(placement: .primaryAction) { compareButton }
        ToolbarItem(placement: .primaryAction) { saveToCollectionButton }
        #else
        ToolbarItem(placement: .primaryAction) {
            Menu {
                compareButton
                saveToCollectionButton
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
        #endif
    }

    var compareButton: some View {
        Button {
            hapticsService.impact(.light)
            coordinator.sheet(CountryRoute.compare(preselectedCountry: country))
        } label: {
            Label("Compare", systemImage: "arrow.left.arrow.right")
        }
    }

    var saveToCollectionButton: some View {
        Button {
            hapticsService.impact(.light)
            coordinator.sheet(CountryLocalRoute.saveToCollection(countryCode: country.code, countryName: country.name))
        } label: {
            Label("Save to Collection", systemImage: "folder.badge.plus")
        }
    }
}

// MARK: - Section Header
extension CountryDetailScreen {
    func sectionHeader(_ title: String) -> some View {
        SectionHeaderView(title: title)
    }
}

// MARK: - Navigation
extension CountryDetailScreen {
    func navigateToCountry(_ country: Country) {
        coordinator.push(CountryRoute.countryDetail(country))
    }

    func navigateToOrganization(_ organization: Organization) {
        coordinator.push(DiscoverRoute.organizationDetail(organization))
    }

    func navigateToContinent(_ continent: Country.Continent) {
        coordinator.push(MapRoute.continentOverview(continent))
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

    var religionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Religion")
            PercentageBarChart(
                items: religionItems
            )
        }
    }

    var ethnicitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Ethnicity")
            PercentageBarChart(
                items: ethnicityItems
            )
        }
    }

    var statisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Statistics")
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
            heroSection
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                topSections
                bottomSections
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xxl)
        .readableContentWidth()
    }

    @ViewBuilder
    var topSections: some View {
        quickFactsCard
        travelEssentialsSection
        travelSection
        neighborsSection(countryDataService: countryDataService)
        peopleSection
        languagesSection
        if !religionItems.isEmpty {
            religionSection
        }
        if !ethnicityItems.isEmpty {
            ethnicitySection
        }
        if hasEconomyData {
            economySection
        }
        governmentSection
        currencySection
        statisticsSection
    }

    @ViewBuilder
    var bottomSections: some View {
        if !content.memberOrganizations.isEmpty {
            organizationsSection(
                countryDataService: countryDataService,
                hapticsService: hapticsService
            )
        }
        flagSymbolismSection
        cultureSection
        phrasebookSection
        funFactsSection
        unescoSection
        if let profile = content.profile {
            CountryDeepDiveSections(profile: profile)
        }
        continentExploreSection
        #if !os(tvOS)
        WikipediaSection(countryName: country.name)
        #endif
    }
}
