import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_CountryProfile
import Geografy_Feature_Travel
import SwiftUI

public struct CountryDetailScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) var coordinator
    @Environment(SubscriptionService.self) var subscriptionService
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

    @State var profileService = CountryProfileService()
    @State var appeared = false
    @State var activeSheet: CountryDetailSheet?
    @State var showFlagFullScreen = false
    @State var flagScrolledUp = false
    @State private var selectedStatCategory: StatCategory = .economy
    @State var populationStartDate = Date()

    public let country: Country

    // MARK: - Init
    public init(country: Country) {
        self.country = country
    }

    // MARK: - Body
    public var body: some View {
        contentScrollView
            .background(DesignSystem.Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .toolbar { toolbarContent }
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
        case info(InfoItem)
        case deepDive

        var id: String {
            switch self {
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
    var toolbarContent: some ToolbarContent {
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

        ToolbarItem(placement: .primaryAction) {
            Button {
                hapticsService.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoritesService.toggle(code: country.code)
                }
            } label: {
                Label("Favorite", systemImage: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.iconPrimary)
                    .symbolEffect(.bounce, value: isFavorite)
            }
            .buttonStyle(.plain)
        }

        ToolbarItem(placement: secondaryActionPlacement) {
            Button {
                hapticsService.impact(.light)
                coordinator.sheet(.compare(preselectedCountry: country))
            } label: {
                Label("Compare", systemImage: "arrow.left.arrow.right")
            }
            .buttonStyle(.plain)
        }

        ToolbarItem(placement: secondaryActionPlacement) {
            Button {
                hapticsService.impact(.light)
                coordinator.sheet(.saveToCollection(countryCode: country.code, countryName: country.name))
            } label: {
                Label("Save to Collection", systemImage: "folder.badge.plus")
            }
            .buttonStyle(.plain)
        }
    }

    var secondaryActionPlacement: ToolbarItemPlacement {
        #if os(tvOS)
        .primaryAction
        #else
        .secondaryAction
        #endif
    }
}

// MARK: - Section Header
extension CountryDetailScreen {
    func sectionHeader(_ title: String, premium: Bool = false) -> some View {
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
    var premiumMonthlyPriceDisplay: String? {
        subscriptionService.products.first { $0.id == SubscriptionService.ProductID.monthly }?.displayPrice
    }

    func lockedSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader(title)
            LockedSectionPeek(
                title: "Premium preview",
                subtitle: "Unlock \(title.lowercased()) + advanced stats and ad-free experience",
                price: premiumMonthlyPriceDisplay,
                onUnlock: { coordinator.sheet(.paywall) },
                content: {
                    lockedPreviewContent
                        .frame(height: 140)
                        .padding(DesignSystem.Spacing.md)
                }
            )
        }
    }

    func lockedPlaceholder(height: CGFloat) -> some View {
        LockedSectionPeek(
            title: "Premium",
            subtitle: "Unlock to reveal",
            price: premiumMonthlyPriceDisplay,
            onUnlock: { coordinator.sheet(.paywall) },
            content: {
                lockedPreviewContent
                    .frame(height: height)
                    .padding(DesignSystem.Spacing.sm)
            }
        )
    }

    /// Generic chart-like preview shown behind the blur. Hints at the kind of
    /// data that becomes visible once premium is unlocked without having to
    /// know which specific section is locked.
    private var lockedPreviewContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                lockedPreviewBar(index: index)
            }
        }
    }

    private func lockedPreviewBar(index: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Circle()
                .fill(DesignSystem.Color.mapColors[index % DesignSystem.Color.mapColors.count])
                .frame(width: DesignSystem.Size.Icon.sm, height: DesignSystem.Size.Icon.sm)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(DesignSystem.Color.Gradient.aurora)
                .frame(height: 14)
                .opacity(0.85 - Double(index) * 0.2)
        }
    }
}

// MARK: - Navigation
extension CountryDetailScreen {
    func navigateToCountry(_ country: Country) {
        coordinator.push(.countryDetail(country))
    }

    func navigateToOrganization(_ organization: Organization) {
        coordinator.push(.organizationDetail(organization))
    }

    func navigateToContinent(_ continent: Country.Continent) {
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
                    items: religionItems.sorted(by: \.percentage, descending: true),
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
                    items: ethnicityItems.sorted(by: \.percentage, descending: true),
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
        travelEssentialsSection
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
