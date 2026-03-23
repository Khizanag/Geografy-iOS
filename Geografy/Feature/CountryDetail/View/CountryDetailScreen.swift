import SwiftUI

struct CountryDetailScreen: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(TravelService.self) private var travelService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(HapticsService.self) var hapticsService
    @Environment(WorldBankService.self) private var worldBankService
    @Environment(PronunciationService.self) private var pronunciationService

    @Namespace private var flagNamespace

    @State private var countryDataService = CountryDataService()
    @State private var appeared = false
    @State private var activeSheet: CountryDetailSheet?
    @State private var showFlagFullScreen = false
    @State private var showContinentMap = false
    @State private var flagScrolledUp = false
    @State private var selectedStatCategory: StatCategory = .economy
    @State private var populationStartDate = Date()

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
            .navigationDestination(for: Organization.self) { organization in
                OrganizationDetailScreen(organization: organization)
            }
            .navigationDestination(for: Country.self) { destination in
                CountryDetailScreen(country: destination)
            }
            .overlay { flagFullScreenOverlay }
    }
}

// MARK: - Info Item

private extension CountryDetailScreen {
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

        var id: String {
            switch self {
            case .travelPicker: "travelPicker"
            case .paywall: "paywall"
            case .info(let item): "info-\(item.id)"
            case .compare: "compare"
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
                        .matchedGeometryEffect(id: country.code, in: flagNamespace)
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
                    SpeakerButton(text: country.name, countryCode: country.code)
                }

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
                ZStack(alignment: .topTrailing) {
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
                        factChip(
                            icon: "mappin",
                            label: country.allCapitals.count > 1 ? "Capitals (\(country.allCapitals.count))" : "Capital",
                            value: country.capital
                        )
                    }
                    .buttonStyle(PressButtonStyle())

                    SpeakerButton(text: country.capital, countryCode: country.code)
                        .scaleEffect(0.75)
                        .offset(x: 4, y: -4)
                }

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

// MARK: - People

private extension CountryDetailScreen {
    var peopleSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("People")
            populationCard
            if !country.languages.isEmpty {
                if subscriptionService.isPremium {
                    LanguageBarChart(
                        languages: country.languages.sorted { $0.percentage > $1.percentage },
                        appeared: appeared
                    )
                } else {
                    lockedPlaceholder(height: 80)
                }
            }
        }
    }

    var populationCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        livePopulationTicker
                        Text("People (live estimate)")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxs) {
                        Text("\(String(format: "%.1f", country.populationDensity))/km²")
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("Density")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
                densityBar
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var livePopulationTicker: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(DesignSystem.Color.success)
                .frame(width: 6, height: 6)
                .scaleEffect(appeared ? 1.5 : 1.0)
                .opacity(appeared ? 0.4 : 1.0)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: appeared
                )
            TimelineView(.periodic(from: populationStartDate, by: 1.0)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(populationStartDate)
                let growthPerSecond = Double(country.population) * 0.009 / 31_557_600
                let estimate = country.population + Int(growthPerSecond * elapsed)
                Text(estimate.formatPopulation())
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.easeInOut(duration: 0.6), value: estimate)
            }
        }
    }

    var densityBar: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            GeometryReader { geo in
                let fraction = min(country.populationDensity / 500.0, 1.0)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignSystem.Color.cardBackgroundHighlighted)
                    Capsule()
                        .fill(densityColor(for: fraction))
                        .frame(width: geo.size.width * (appeared ? fraction : 0))
                        .animation(
                            .spring(response: 0.7, dampingFraction: 0.7).delay(0.4),
                            value: appeared
                        )
                }
            }
            .frame(height: 6)
            Text("Relative density (ref: 500/km²)")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}

// MARK: - Economy

private extension CountryDetailScreen {
    var hasEconomyData: Bool {
        country.gdp != nil || country.gdpPerCapita != nil || country.gdpPPP != nil
    }

    var economySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Economy", premium: true)
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let gdp = country.gdp {
                    economyTile(
                        icon: "chart.bar.fill",
                        label: "GDP",
                        value: gdp.formatGDP(),
                        color: DesignSystem.Color.accent
                    )
                }
                if let perCapita = country.gdpPerCapita {
                    economyTile(
                        icon: "person.crop.circle",
                        label: "Per Capita",
                        value: perCapita.formatCurrency(),
                        color: DesignSystem.Color.blue
                    )
                }
                if let ppp = country.gdpPPP {
                    economyTile(
                        icon: "chart.bar",
                        label: "GDP PPP",
                        value: ppp.formatGDP(),
                        color: DesignSystem.Color.indigo
                    )
                }
            }
        }
    }

    func economyTile(icon: String, label: String, value: String, color: Color) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(color)
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(value)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.sm)
        }
    }
}

// MARK: - Government

private extension CountryDetailScreen {
    var governmentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Government", premium: true)
            InfoTile(
                icon: "building.columns",
                title: "Form of Government",
                value: country.formOfGovernment
            ) {
                activeSheet = .info(
                    InfoItem(
                        icon: "building.columns.fill",
                        title: "Form of Government",
                        value: country.formOfGovernment,
                        supportsMap: false
                    )
                )
            }
        }
    }
}

// MARK: - Currency

private extension CountryDetailScreen {
    var currencySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Currency", premium: true)
            InfoTile(
                icon: "dollarsign.circle",
                title: country.currency.name,
                value: country.currency.code
            ) {
                activeSheet = .info(
                    InfoItem(
                        icon: "dollarsign.circle.fill",
                        title: "Currency",
                        value: "\(country.currency.name) (\(country.currency.code))",
                        supportsMap: false
                    )
                )
            }
        }
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

// MARK: - Helpers

private extension CountryDetailScreen {
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

    func densityColor(for fraction: Double) -> Color {
        if fraction > 0.7 {
            DesignSystem.Color.error
        } else if fraction > 0.4 {
            DesignSystem.Color.warning
        } else {
            DesignSystem.Color.success
        }
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
                    appeared: appeared
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
                    appeared: appeared
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
                quickFactsCard
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
                if !memberOrganizations.isEmpty, subscriptionService.isPremium {
                    organizationsSection(
                        countryDataService: countryDataService,
                        hapticsService: hapticsService
                    )
                }
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
