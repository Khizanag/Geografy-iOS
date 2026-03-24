import SwiftUI

struct CountryDetailScreen: View {
    @Environment(TabCoordinator.self) var coordinator
    @Environment(SubscriptionService.self) var subscriptionService
    @Environment(TravelService.self) private var travelService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(HapticsService.self) var hapticsService
    @Environment(WorldBankService.self) private var worldBankService
    @Environment(PronunciationService.self) private var pronunciationService

    @Namespace private var flagNamespace

    @State private var countryDataService = CountryDataService()
    @State var profileService = CountryProfileService()
    @State var appeared = false
    @State var activeSheet: CountryDetailSheet?
    @State private var showFlagFullScreen = false
    @State private var showContinentMap = false
    @State private var flagScrolledUp = false
    @State private var selectedStatCategory: StatCategory = .economy
    @State var populationStartDate = Date()

    let country: Country

    init(country: Country) {
        self.country = country
    }

    var body: some View {
        contentScrollView
            .background(DesignSystem.Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { favoriteToolbarItem }
            .toolbar { compareToolbarItem }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: flagScrolledUp ? DesignSystem.Spacing.xs : 0) {
                        FlagView(countryCode: country.code, height: 20)
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
            .task { countryDataService.loadCountries() }
            .task { trackExploration() }
            .onAppear { appeared = true }
            .sheet(item: $activeSheet) { sheet in countryDetailSheetContent(for: sheet) }
            .fullScreenCover(isPresented: $showContinentMap) { continentMapCover }
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
    }

    enum CountryDetailSheet: Identifiable {
        case travelPicker
        case paywall
        case info(InfoItem)
        case compare
        case currencyConverter(String)
        case deepDive
        case neighborExplorer
        case organizationMap(Organization)

        var id: String {
            switch self {
            case .travelPicker: "travelPicker"
            case .paywall: "paywall"
            case .info(let item): "info-\(item.id)"
            case .compare: "compare"
            case .currencyConverter(let code): "currencyConverter-\(code)"
            case .deepDive: "deepDive"
            case .neighborExplorer: "neighborExplorer"
            case .organizationMap(let org): "orgMap-\(org.id)"
            }
        }
    }
}

// MARK: - Sheet Content

private extension CountryDetailScreen {
    @ViewBuilder
    func countryDetailSheetContent(for sheet: CountryDetailSheet) -> some View {
        switch sheet {
        case .travelPicker:
            TravelStatusPickerSheet(
                country: country,
                isPresented: Binding(
                    get: { activeSheet != nil },
                    set: { if !$0 { activeSheet = nil } }
                )
            )
        case .paywall:
            PaywallScreen()
        case .info(let item):
            propertyDetailSheet(for: item)
        case .compare:
            NavigationStack { CompareScreen(preselectedCountry: country) }
                .presentationDetents([.large])
        case .currencyConverter(let code):
            NavigationStack { CurrencyConverterScreen(preselectedCurrencyCode: code) }
                .presentationDetents([.large])
        case .deepDive:
            NavigationStack {
                CountryProfileScreen(
                    country: country,
                    profile: profileService.profile(for: country.code)
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CircleCloseButton()
                    }
                }
            }
            .presentationDetents([.large])
        case .neighborExplorer:
            NavigationStack {
                NeighborExplorerScreen(country: country)
            }
            .presentationDetents([.large])
        case .organizationMap(let organization):
            OrganizationMapScreen(organization: organization)
        }
    }
}

// MARK: - Toolbar

private extension CountryDetailScreen {
    @ToolbarContentBuilder
    var favoriteToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                hapticsService.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoritesService.toggle(code: country.code)
                }
            } label: {
                Image(systemName: favoritesService.isFavorite(code: country.code) ? "heart.fill" : "heart")
                    .foregroundStyle(
                        favoritesService.isFavorite(code: country.code)
                            ? DesignSystem.Color.error
                            : DesignSystem.Color.iconPrimary
                    )
                    .symbolEffect(.bounce, value: favoritesService.isFavorite(code: country.code))
            }
            .buttonStyle(.plain)
        }
    }

    @ToolbarContentBuilder
    var compareToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                hapticsService.impact(.light)
                activeSheet = .compare
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(DesignSystem.Color.iconPrimary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Hero

private extension CountryDetailScreen {
    var heroSection: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showFlagFullScreen = true
                    }
                } label: {
                    FlagView(countryCode: country.code, height: DesignSystem.Size.hero)
                        .matchedGeometryEffect(id: country.code, in: flagNamespace, isSource: true)
                        .opacity(showFlagFullScreen || flagScrolledUp ? 0 : 1)
                        .geoShadow(.elevated)
                        .onGeometryChange(for: Bool.self) { proxy in
                            proxy.frame(in: .scrollView).maxY < 0
                        } action: { isHidden in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                flagScrolledUp = isHidden
                            }
                        }
                }
                .buttonStyle(.plain)

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Text(country.name)
                        .font(DesignSystem.Font.title)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .multilineTextAlignment(.center)
                    SpeakerButton(text: country.name, countryCode: country.code)
                }
                .frame(maxWidth: .infinity)

                Button {
                    activeSheet = .info(
                        InfoItem(
                            icon: "globe.americas.fill",
                            title: "Continent",
                            value: country.continent.displayName,
                            supportsMap: true,
                            mapButtonTitle: "Open \(country.continent.displayName) Map"
                        )
                    )
                } label: {
                    HStack(spacing: DesignSystem.Spacing.xxs) {
                        Text(country.continent.displayName)
                        Image(systemName: "map.fill")
                            .font(DesignSystem.Font.caption2)
                            .opacity(0.7)
                    }
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
                    .background(DesignSystem.Color.accent)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.xl)
        }
    }
}

// MARK: - Quick Facts

private extension CountryDetailScreen {
    var quickFactsCard: some View {
        CardView {
            HStack(spacing: 0) {
                Button {
                    activeSheet = .info(
                        InfoItem(
                            icon: "mappin.and.ellipse",
                            title: country.allCapitals.count > 1 ? "Capitals" : "Capital",
                            value: capitalInfoValue,
                            supportsMap: false
                        )
                    )
                } label: {
                    VStack(spacing: DesignSystem.Spacing.xxs) {
                        Image(systemName: "mappin")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.accent)
                        Text(
                            country.allCapitals.count > 1
                                ? "Capitals (\(country.allCapitals.count))"
                                : "Capital"
                        )
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        HStack(spacing: DesignSystem.Spacing.xxs) {
                            Text(country.allCapitals.map(\.name).joined(separator: ", "))
                                .font(DesignSystem.Font.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            SpeakerButton(text: country.capital, countryCode: country.code)
                                .scaleEffect(0.7)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PressButtonStyle())

                Divider().frame(height: 44)

                Button {
                    activeSheet = .info(
                        InfoItem(
                            icon: "map.fill",
                            title: "Area",
                            value: country.area.formatArea(),
                            supportsMap: false
                        )
                    )
                } label: {
                    factChip(icon: "map", label: "Area", value: country.area.formatArea())
                }
                .buttonStyle(PressButtonStyle())

                Divider().frame(height: 44)

                Button {
                    activeSheet = .info(
                        InfoItem(
                            icon: "globe.americas.fill",
                            title: "Continent",
                            value: country.continent.displayName,
                            supportsMap: true,
                            mapButtonTitle: "Open \(country.continent.displayName) Map"
                        )
                    )
                } label: {
                    factChip(icon: "globe", label: "Continent", value: country.continent.displayName)
                }
                .buttonStyle(PressButtonStyle())
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
    }

    func factChip(icon: String, label: String, value: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(value)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Travel

private extension CountryDetailScreen {
    var travelSection: some View {
        let currentStatus = travelService.status(for: country.code)
        return Button {
            hapticsService.impact(.light)
            activeSheet = .travelPicker
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill((currentStatus?.color ?? DesignSystem.Color.accent).opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: currentStatus?.icon ?? "airplane.departure")
                            .font(.system(size: 16))
                            .foregroundStyle(currentStatus?.color ?? DesignSystem.Color.accent)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Travel Status")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                        Text(currentStatus?.label ?? "Not set")
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                currentStatus != nil
                                    ? DesignSystem.Color.textPrimary
                                    : DesignSystem.Color.textTertiary
                            )
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Gamification

private extension CountryDetailScreen {
    func trackExploration() {
        let key = "explored_countries_\(xpService.currentUserID)"
        var explored = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        guard !explored.contains(country.code) else { return }
        explored.insert(country.code)
        UserDefaults.standard.set(Array(explored), forKey: key)
        xpService.award(5, source: .countryExplored)
        achievementService.checkExplorerAchievements(totalExplored: explored.count)
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
    }
}

// MARK: - Locked Content

extension CountryDetailScreen {
    func lockedSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader(title)
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(height: 80)
                PremiumLockedOverlay(onUnlock: { activeSheet = .paywall })
            }
        }
    }

    func lockedPlaceholder(height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .frame(height: height)
            PremiumLockedOverlay(onUnlock: { activeSheet = .paywall })
        }
    }
}

// MARK: - Helpers

private extension CountryDetailScreen {
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
                    title: "Religion",
                    icon: "hands.sparkles",
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
                    title: "Ethnicity",
                    icon: "person.2",
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
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                heroSection
                flagSymbolismSection
                quickFactsCard
                phrasebookSection
                funFactsSection
                neighborsSection(countryDataService: countryDataService)
                travelSection
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
                if !memberOrganizations.isEmpty {
                    organizationsSection(
                        countryDataService: countryDataService,
                        hapticsService: hapticsService
                    )
                }
                unescoSection
                deepDiveSection
                continentExploreSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    func propertyDetailSheet(for item: InfoItem) -> some View {
        PropertyDetailSheet(
            icon: item.icon,
            title: item.title,
            value: item.value,
            supportsMap: item.supportsMap,
            mapButtonTitle: item.mapButtonTitle,
            onShowMap: {
                activeSheet = nil
                showContinentMap = true
            }
        )
    }

    var continentMapCover: some View {
        NavigationStack {
            MapScreen(continentFilter: country.continent.displayName)
                .navigationDestination(for: Country.self) { detailCountry in
                    CountryDetailScreen(country: detailCountry)
                }
        }
    }

    @ViewBuilder
    var flagFullScreenOverlay: some View {
        if showFlagFullScreen {
            ZoomableFlagView(countryCode: country.code, namespace: flagNamespace) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    showFlagFullScreen = false
                }
            }
        }
    }
}
