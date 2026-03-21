import SwiftUI

struct CountryDetailScreen: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(TravelService.self) private var travelService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService

    @Namespace private var flagNamespace

    @State private var countryDataService = CountryDataService()
    @State private var appeared = false
    @State private var selectedInfo: InfoItem?
    @State private var showFlagFullScreen = false
    @State private var showContinentMap = false
    @State private var showTravelPicker = false
    @State private var showPaywall = false

    private let country: Country

    init(country: Country) {
        self.country = country
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                heroSection
                quickFactsCard
                travelSection
                peopleSection
                if hasEconomyData {
                    if subscriptionService.isPremium {
                        economySection
                    } else {
                        lockedSection(title: "Economy", icon: "chart.bar.fill")
                    }
                }
                if subscriptionService.isPremium {
                    governmentSection
                    currencySection
                }
                if !memberOrganizations.isEmpty, subscriptionService.isPremium {
                    organizationsSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle(country.name)
        .toolbar { favoriteToolbarItem }
        .task { countryDataService.loadCountries() }
        .task { trackExploration() }
        .onAppear { appeared = true }
        .sheet(isPresented: $showTravelPicker) {
            TravelStatusPickerSheet(country: country, isPresented: $showTravelPicker)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallScreen()
        }
        .sheet(item: $selectedInfo) { item in
            PropertyDetailSheet(
                icon: item.icon,
                title: item.title,
                value: item.value,
                supportsMap: item.supportsMap,
                mapButtonTitle: item.mapButtonTitle,
                onShowMap: {
                    selectedInfo = nil
                    showContinentMap = true
                }
            )
        }
        .fullScreenCover(isPresented: $showContinentMap) {
            NavigationStack {
                MapScreen(continentFilter: country.continent.displayName)
                    // swiftlint:disable:next identifier_name
                    .navigationDestination(for: Country.self) { c in
                        CountryDetailScreen(country: c)
                    }
            }
        }
        .navigationDestination(for: Organization.self) { org in
            OrganizationDetailScreen(organization: org)
        }
        .overlay {
            if showFlagFullScreen {
                ZoomableFlagView(countryCode: country.code, namespace: flagNamespace) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showFlagFullScreen = false
                    }
                }
            }
        }
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
}

// MARK: - Toolbar

private extension CountryDetailScreen {
    @ToolbarContentBuilder
    var favoriteToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favoritesService.toggle(code: country.code)
                }
            } label: {
                Image(systemName: favoritesService.isFavorite(code: country.code) ? "heart.fill" : "heart")
                    // swiftlint:disable:next line_length
                    .foregroundStyle(favoritesService.isFavorite(code: country.code) ? DesignSystem.Color.error : DesignSystem.Color.iconPrimary)
                    .symbolEffect(.bounce, value: favoritesService.isFavorite(code: country.code))
            }
        }
    }
}

// MARK: - Hero

private extension CountryDetailScreen {
    var heroSection: some View {
        GeoCard(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showFlagFullScreen = true
                    }
                } label: {
                    FlagView(countryCode: country.code, height: DesignSystem.Size.hero)
                        .matchedGeometryEffect(id: country.code, in: flagNamespace)
                        .opacity(showFlagFullScreen ? 0 : 1)
                        .geoShadow(.elevated)
                }
                .buttonStyle(.plain)

                Text(country.name)
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Button {
                    selectedInfo = InfoItem(
                        icon: "globe.americas.fill",
                        title: "Continent",
                        value: country.continent.displayName,
                        supportsMap: true,
                        mapButtonTitle: "Open \(country.continent.displayName) Map"
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
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }
}

// MARK: - Quick Facts

private extension CountryDetailScreen {
    var quickFactsCard: some View {
        GeoCard {
            HStack(spacing: 0) {
                Button {
                    selectedInfo = InfoItem(
                        icon: "mappin.fill",
                        title: country.allCapitals.count > 1 ? "Capitals" : "Capital",
                        value: capitalInfoValue,
                        supportsMap: false
                    )
                } label: {
                    factChip(
                        icon: "mappin",
                        label: country.allCapitals.count > 1 ? "Capitals (\(country.allCapitals.count))" : "Capital",
                        value: country.capital
                    )
                }
                .buttonStyle(GeoPressButtonStyle())

                Divider().frame(height: 44)

                Button {
                    selectedInfo = InfoItem(
                        icon: "map.fill",
                        title: "Area",
                        value: country.area.formatArea(),
                        supportsMap: false
                    )
                } label: {
                    factChip(icon: "map", label: "Area", value: country.area.formatArea())
                }
                .buttonStyle(GeoPressButtonStyle())

                Divider().frame(height: 44)

                Button {
                    selectedInfo = InfoItem(
                        icon: "globe.americas.fill",
                        title: "Continent",
                        value: country.continent.displayName,
                        supportsMap: true,
                        mapButtonTitle: "Open \(country.continent.displayName) Map"
                    )
                } label: {
                    factChip(icon: "globe", label: "Continent", value: country.continent.displayName)
                }
                .buttonStyle(GeoPressButtonStyle())
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.08), value: appeared)
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
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showTravelPicker = true
        } label: {
            GeoCard {
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
                            // swiftlint:disable:next line_length
                            .foregroundStyle(currentStatus != nil ? DesignSystem.Color.textPrimary : DesignSystem.Color.textTertiary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(GeoPressButtonStyle())
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.12), value: appeared)
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
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.16), value: appeared)
    }

    var populationCard: some View {
        GeoCard {
            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text(country.population.formatPopulation())
                            .font(DesignSystem.Font.title2)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("People")
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
                    // swiftlint:disable:next line_length
                    economyTile(icon: "chart.bar.fill", label: "GDP", value: gdp.formatGDP(), color: DesignSystem.Color.accent)
                }
                if let perCapita = country.gdpPerCapita {
                    // swiftlint:disable:next line_length
                    economyTile(icon: "person.crop.circle", label: "Per Capita", value: perCapita.formatCurrency(), color: DesignSystem.Color.blue)
                }
                if let ppp = country.gdpPPP {
                    // swiftlint:disable:next line_length
                    economyTile(icon: "chart.bar", label: "GDP PPP", value: ppp.formatGDP(), color: DesignSystem.Color.indigo)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.24), value: appeared)
    }

    func economyTile(icon: String, label: String, value: String, color: Color) -> some View {
        GeoCard {
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
            GeoInfoTile(
                icon: "building.columns",
                title: "Form of Government",
                value: country.formOfGovernment
            ) {
                selectedInfo = InfoItem(
                    icon: "building.columns.fill",
                    title: "Form of Government",
                    value: country.formOfGovernment,
                    supportsMap: false
                )
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.32), value: appeared)
    }
}

// MARK: - Currency

private extension CountryDetailScreen {
    var currencySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Currency", premium: true)
            GeoInfoTile(
                icon: "dollarsign.circle",
                title: country.currency.name,
                value: country.currency.code
            ) {
                selectedInfo = InfoItem(
                    icon: "dollarsign.circle.fill",
                    title: "Currency",
                    value: "\(country.currency.name) (\(country.currency.code))",
                    supportsMap: false
                )
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.40), value: appeared)
    }
}

// MARK: - Organizations

private extension CountryDetailScreen {
    var memberOrganizations: [Organization] {
        country.organizations.compactMap { Organization.find($0) }
    }

    var organizationsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader("Member Of", premium: true)
            GeoCard {
                VStack(spacing: 0) {
                    ForEach(Array(memberOrganizations.enumerated()), id: \.element.id) { index, org in
                        NavigationLink(value: org) {
                            orgRow(org)
                        }
                        .buttonStyle(GeoPressButtonStyle())
                        .simultaneousGesture(TapGesture().onEnded {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        })

                        if index < memberOrganizations.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.48), value: appeared)
    }

    func orgRow(_ org: Organization) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(org.highlightColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: org.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(org.highlightColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(org.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                if org.fullName != org.displayName {
                    Text(org.fullName)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            let memberCount = countryDataService.countries.filter { $0.organizations.contains(org.id) }.count
            if memberCount > 0 {
                Text("\(memberCount) members")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
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

// MARK: - Helpers

private extension CountryDetailScreen {
    func lockedSection(title: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionHeader(title)
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(height: 80)
                PremiumLockedOverlay(onUnlock: { showPaywall = true })
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.24), value: appeared)
    }

    func lockedPlaceholder(height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.cardBackground)
                .frame(height: height)
            PremiumLockedOverlay(onUnlock: { showPaywall = true })
        }
    }

    func sectionHeader(_ title: String, premium: Bool = false) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignSystem.Color.accent)
                .frame(width: 3, height: 18)
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if premium, subscriptionService.isPremium {
                PremiumBadge()
            }
        }
    }

    var capitalInfoValue: String {
        // swiftlint:disable statement_position
        country.allCapitals.map { cap in
            if let role = cap.role { "\(cap.name) (\(role))" }
            else { cap.name }
        }.joined(separator: "\n")
        // swiftlint:enable statement_position
    }

    // swiftlint:disable statement_position
    func densityColor(for fraction: Double) -> Color {
        if fraction > 0.7 { DesignSystem.Color.error }
        else if fraction > 0.4 { DesignSystem.Color.warning }
        else { DesignSystem.Color.success }
    }
    // swiftlint:enable statement_position
}
