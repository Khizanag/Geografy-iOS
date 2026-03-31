import SwiftUI
import GeografyDesign
import GeografyCore

struct TravelTrackerScreen: View {
    @Environment(TravelService.self) private var travelService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedFilter: TravelStatus? = nil
    @State private var searchText = ""
    @State private var showCountryPicker = false
    @State private var showTravelMap = false
    @State private var travelMapFilter: TravelMapFilter = .visited
    @State private var selectedCountry: Country?
    @State private var appeared = false
    @State private var blobAnimating = false
    @State private var showBucketList = false

    var body: some View {
        ZStack {
            if countryDataService.countries.isEmpty {
                loadingView
            } else {
                mainContent
            }
        }
        .closeButtonPlacementLeading()
        .navigationTitle("Travel Tracker")
        .searchable(text: $searchText, prompt: "Search countries…")
        .toolbar { toolbarContent }
        .fullScreenCover(isPresented: $showTravelMap) {
            TravelMapScreen(filter: travelMapFilter)
        }
        .sheet(isPresented: $showCountryPicker) {
            TravelCountryPickerSheet(
                countries: countryDataService.countries,
                isPresented: $showCountryPicker,
                preferredStatus: selectedFilter
            )
        }
        .sheet(item: $selectedCountry) { country in
            TravelStatusPickerSheet(
                country: country,
                isPresented: Binding(
                    get: { selectedCountry != nil },
                    set: { if !$0 { selectedCountry = nil } }
                )
            )
        }
        .sheet(isPresented: $showBucketList) {
            TravelBucketListScreen()
        }
        .onAppear {
            blobAnimating = true
            appeared = true
        }
    }
}

// MARK: - Subviews
private extension TravelTrackerScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
            Button {
                hapticsService.impact(.light)
                showBucketList = true
            } label: {
                Label("Bucket List", systemImage: "list.star")
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                hapticsService.impact(.light)
                showCountryPicker = true
            } label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .tint(Color.clear)
            .buttonStyle(.glassProminent)
        }
    }

    var loadingView: some View {
        ProgressView()
            .tint(DesignSystem.Color.accent)
    }

    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                statsSection
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: appeared)

                viewOnMapSection
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.08), value: appeared)

                filterTabs
                    .padding(.top, DesignSystem.Spacing.lg)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                countryList
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
            }
            .opacity(appeared ? 1 : 0)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
        .background { ambientBlobs }
    }

    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "00C9A7").opacity(0.18), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 300).blur(radius: 40)
                .offset(x: -80, y: 40)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "845EC2").opacity(0.14), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 360, height: 300).blur(radius: 44)
                .offset(x: 140, y: 100)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.10), .clear],
                        center: .center, startRadius: 0, endRadius: 160
                    )
                )
                .frame(width: 320, height: 260).blur(radius: 36)
                .offset(x: -60, y: 600)
                .scaleEffect(blobAnimating ? 1.05 : 0.95)
        }
        .allowsHitTesting(false)
        .animation(reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true), value: blobAnimating)
    }

    var statsSection: some View {
        TravelStatsCard(
            visitedCount: travelService.visitedCodes.count,
            wantToVisitCount: travelService.wantToVisitCodes.count,
            totalCountries: countryDataService.countries.count,
            continentBreakdown: continentBreakdown
        )
    }

    var viewOnMapSection: some View {
        Button {
            travelMapFilter = currentTravelMapFilter
            showTravelMap = true
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "map.fill")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text("View on Map")
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(currentFilterLabel)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("View on Map")
        .accessibilityHint(currentFilterLabel)
    }

    var currentTravelMapFilter: TravelMapFilter {
        if let filter = selectedFilter {
            switch filter {
            case .visited: .visited
            case .wantToVisit: .wantToVisit
            }
        } else {
            .all
        }
    }

    var currentFilterLabel: String {
        if let filter = selectedFilter {
            "Show \(filter.label.lowercased()) countries on map"
        } else {
            "Show all travel countries on map"
        }
    }

    var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                filterTab(nil, icon: "globe", label: "All")
                ForEach(TravelStatus.allCases) { status in
                    filterTab(status, icon: status.icon, label: status.label)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func filterTab(_ filter: TravelStatus?, icon: String, label: String) -> some View {
        let isActive = selectedFilter == filter && !isSearching
        let activeColor: Color = filter?.color ?? DesignSystem.Color.accent
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedFilter = filter
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.caption)
                Text(label)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                if isActive, let count = filteredCount(for: filter), count > 0 {
                    Text("\(count)")
                        .font(DesignSystem.Font.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.primary.opacity(0.15), in: Capsule())
                }
            }
            .foregroundStyle(isActive ? DesignSystem.Color.onAccent : DesignSystem.Color.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                Capsule().fill(isActive ? activeColor : DesignSystem.Color.cardBackgroundHighlighted)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var countryList: some View {
        Group {
            if isSearching {
                searchResultsList
            } else {
                trackedCountryList
            }
        }
    }

    var trackedCountryList: some View {
        let countries = filteredCountries
        return Group {
            if countries.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(countries) { country in
                        if let status = travelService.status(for: country.code) {
                            TravelCountryRow(country: country, status: status)
                                .transition(.asymmetric(
                                    insertion: .push(from: .trailing),
                                    removal: .push(from: .leading)
                                ))
                        }
                    }
                    addCountryFooter
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: travelService.entries.count)
            }
        }
    }

    var addCountryFooter: some View {
        Button {
            hapticsService.impact(.light)
            showCountryPicker = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "plus.circle.fill")
                    .font(DesignSystem.Font.subheadline)
                Text("Add Country")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(PressButtonStyle())
        .padding(.top, DesignSystem.Spacing.xs)
    }

    var searchResultsList: some View {
        let results = searchResults
        return Group {
            if results.isEmpty {
                noResultsState
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    searchResultsHeader(count: results.count)
                    ForEach(results) { country in
                        searchResultRow(country)
                    }
                }
            }
        }
    }

    func searchResultsHeader(count: Int) -> some View {
        HStack {
            Text("\(count) \(count == 1 ? "country" : "countries") found")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Spacer()
        }
        .padding(.bottom, DesignSystem.Spacing.xxs)
    }

    func searchResultRow(_ country: Country) -> some View {
        let status = travelService.status(for: country.code)
        return Button {
            hapticsService.impact(.light)
            selectedCountry = country
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: country.code, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(width: 54)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(country.name)
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(country.continent.displayName)
                            .font(DesignSystem.Font.caption2)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer(minLength: 0)
                    searchRowTrailing(status)
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func searchRowTrailing(_ status: TravelStatus?) -> some View {
        Group {
            if let status {
                HStack(spacing: 4) {
                    Image(systemName: status.icon)
                        .font(DesignSystem.Font.nano)
                    Text(status.shortLabel)
                        .font(DesignSystem.Font.caption2)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(status.color)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(status.color.opacity(0.15), in: Capsule())
            } else {
                Image(systemName: "plus.circle")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent.opacity(0.7))
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: selectedFilter?.icon ?? "airplane.departure")
                .font(DesignSystem.Font.displaySmall)
                .foregroundStyle(selectedFilter?.color ?? DesignSystem.Color.textTertiary)
                .padding(.top, DesignSystem.Spacing.xxl)
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(emptyStateTitle)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(emptyStateSubtitle)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                hapticsService.impact(.medium)
                showCountryPicker = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                    Text("Add Country")
                        .fontWeight(.semibold)
                }
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(DesignSystem.Color.accent, in: Capsule())
            }
            .buttonStyle(PressButtonStyle())
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxl)
    }

    var noResultsState: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.iconXL)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.top, DesignSystem.Spacing.xl)
            Text("No countries found")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Try a different spelling or search term")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxl)
    }

    func filteredCount(for filter: TravelStatus?) -> Int? {
        guard let filter else { return travelService.entries.count }
        return switch filter {
        case .visited: travelService.visitedCodes.count
        case .wantToVisit: travelService.wantToVisitCodes.count
        }
    }
}

// MARK: - Data
private extension TravelTrackerScreen {
    var isSearching: Bool { !searchText.isEmpty }

    var emptyStateTitle: String {
        switch selectedFilter {
        case .visited: "No visited countries yet"
        case .wantToVisit: "No wishlist yet"
        case nil: "Start tracking your journey"
        }
    }

    var emptyStateSubtitle: String {
        switch selectedFilter {
        case .visited: "Search above or tap + to add countries you've visited"
        case .wantToVisit: "Search above or tap + to build your travel wishlist"
        case nil: "Search for a country above, or tap + to browse all countries"
        }
    }

    var searchResults: [Country] {
        countryDataService.countries
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.name < $1.name }
    }

    var filteredCountries: [Country] {
        let codes: Set<String>
        switch selectedFilter {
        case .visited: codes = travelService.visitedCodes
        case .wantToVisit: codes = travelService.wantToVisitCodes
        case nil: codes = Set(travelService.entries.keys)
        }
        return countryDataService.countries
            .filter { codes.contains($0.code) }
            .sorted { $0.name < $1.name }
    }

    var continentBreakdown: [(name: String, visited: Int, total: Int)] {
        let allContinents = Country.Continent.allCases
        let visitedCodes = travelService.visitedCodes
        return allContinents
            .map { continent in
                let total = countryDataService.countries.filter { $0.continent == continent }.count
                let visited = countryDataService.countries.filter {
                    $0.continent == continent && visitedCodes.contains($0.code)
                }.count
                return (name: continent.displayName, visited: visited, total: total)
            }
            .filter { $0.total > 0 }
    }
}
