import SwiftUI

struct SearchScreen: View {
    @State private var query = ""
    @State private var sections: [SearchResultSection] = []
    @State private var isSearching = false
    @State private var recentService = RecentSearchesService()
    @State private var countryService = CountryDataService()
    @State private var searchTask: Task<Void, Never>?

    private let trendingQueries = [
        "United States", "China", "Japan", "Brazil", "France",
        "Australia", "India", "Egypt", "United Nations", "Canada",
    ]

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.bottom, DesignSystem.Spacing.md)
                Group {
                    if query.isEmpty {
                        emptyStateContent
                    } else {
                        resultContent
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: query.isEmpty)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarItems }
        .navigationDestination(for: Country.self) { country in
            CountryDetailScreen(country: country)
        }
        .navigationDestination(for: Organization.self) { organization in
            OrganizationDetailScreen(organization: organization)
        }
        .task { countryService.loadCountries() }
    }
}

// MARK: - Search Bar

private extension SearchScreen {
    var searchBar: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            TextField("Countries, capitals, organizations…", text: $query)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .onChange(of: query) { _, newValue in
                    scheduleSearch(query: newValue)
                }
            if !query.isEmpty {
                Button {
                    query = ""
                    sections = []
                    isSearching = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
    }
}

// MARK: - Empty State

private extension SearchScreen {
    var emptyStateContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                if !recentService.queries.isEmpty {
                    recentSearchesSection
                }
                trendingSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                SectionHeaderView(title: "Recent", icon: "clock")
                Spacer()
                Button("Clear") {
                    recentService.clearAll()
                }
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.accent)
            }
            VStack(spacing: 0) {
                ForEach(recentService.queries, id: \.self) { recentQuery in
                    recentRow(recentQuery)
                }
            }
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
    }

    func recentRow(_ recentQuery: String) -> some View {
        Button {
            query = recentQuery
            scheduleSearch(query: recentQuery)
        } label: {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(width: DesignSystem.Size.md)
                Text(recentQuery)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                Button {
                    recentService.remove(recentQuery)
                } label: {
                    Image(systemName: "xmark")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .buttonStyle(.plain)
    }

    var trendingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Popular Searches", icon: "flame.fill")
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 130), spacing: DesignSystem.Spacing.xs)],
                spacing: DesignSystem.Spacing.xs
            ) {
                ForEach(trendingQueries, id: \.self) { trending in
                    Button {
                        query = trending
                        scheduleSearch(query: trending)
                    } label: {
                        Text(trending)
                            .font(DesignSystem.Font.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                            .lineLimit(1)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                            .frame(maxWidth: .infinity)
                            .background(DesignSystem.Color.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(DesignSystem.Color.accent.opacity(0.2), lineWidth: 1))
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
        }
    }
}

// MARK: - Results

private extension SearchScreen {
    @ViewBuilder
    var resultContent: some View {
        if isSearching {
            Spacer()
            ProgressView()
                .tint(DesignSystem.Color.accent)
            Spacer()
        } else if sections.isEmpty {
            noResultsView
        } else {
            resultsList
        }
    }

    var noResultsView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("No results for \"\(query)\"")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Try a different search term")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                ForEach(sections) { section in
                    resultSection(section)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    func resultSection(_ section: SearchResultSection) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: section.title, icon: section.icon)
            VStack(spacing: 0) {
                ForEach(section.rows) { row in
                    resultRow(row)
                    if row != section.rows.last {
                        Divider()
                            .padding(.leading, DesignSystem.Spacing.md + DesignSystem.Size.lg + DesignSystem.Spacing.sm)
                    }
                }
            }
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        }
    }

    @ViewBuilder
    func resultRow(_ row: SearchRow) -> some View {
        switch row {
        case .country(let country):
            NavigationLink(value: country) {
                countryRowContent(country)
            }
            .buttonStyle(PressButtonStyle())
            .simultaneousGesture(TapGesture().onEnded { recentService.add(query) })

        case .capital(let country, let capitalName):
            NavigationLink(value: country) {
                capitalRowContent(country: country, capitalName: capitalName)
            }
            .buttonStyle(PressButtonStyle())
            .simultaneousGesture(TapGesture().onEnded { recentService.add(query) })

        case .organization(let organization):
            NavigationLink(value: organization) {
                organizationRowContent(organization)
            }
            .buttonStyle(PressButtonStyle())
            .simultaneousGesture(TapGesture().onEnded { recentService.add(query) })
        }
    }
}

// MARK: - Row Content

private extension SearchScreen {
    func countryRowContent(_ country: Country) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: DesignSystem.Size.lg)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(country.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(country.continent.displayName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    func capitalRowContent(country: Country, capitalName: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.blue.opacity(0.12))
                    .frame(width: DesignSystem.Size.lg, height: DesignSystem.Size.lg)
                Image(systemName: "building.2.fill")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.blue)
            }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(capitalName)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Capital of \(country.name)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    func organizationRowContent(_ organization: Organization) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(organization.highlightColor.opacity(0.12))
                    .frame(width: DesignSystem.Size.lg, height: DesignSystem.Size.lg)
                Image(systemName: organization.icon)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(organization.highlightColor)
            }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(organization.fullName)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(organization.displayName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - Toolbar

private extension SearchScreen {
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            CircleCloseButton()
        }
    }
}

// MARK: - Search Logic

private extension SearchScreen {
    func scheduleSearch(query: String) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            sections = []
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            let results = performSearch(query: trimmed)

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    sections = results
                    isSearching = false
                }
            }
        }
    }

    func performSearch(query: String) -> [SearchResultSection] {
        let normalized = query.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        )

        let countryMatches = countryService.countries.filter {
            $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(normalized)
        }

        let capitalMatches: [(Country, String)] = countryService.countries.flatMap { country in
            guard !countryMatches.contains(where: { $0.code == country.code }) else { return [] }
            return country.allCapitals.compactMap { capital in
                let normalizedCapital = capital.name.folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )
                return normalizedCapital.contains(normalized) ? (country, capital.name) : nil
            }
        }

        let orgMatches = Organization.all.filter {
            let normalizedFull = $0.fullName.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            let normalizedDisplay = $0.displayName.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return normalizedFull.contains(normalized) || normalizedDisplay.contains(normalized)
        }

        var result: [SearchResultSection] = []

        if !countryMatches.isEmpty {
            result.append(SearchResultSection(
                id: "countries",
                title: "Countries",
                icon: "globe",
                rows: countryMatches.prefix(8).map { .country($0) }
            ))
        }

        if !capitalMatches.isEmpty {
            result.append(SearchResultSection(
                id: "capitals",
                title: "Capitals",
                icon: "building.2.fill",
                rows: capitalMatches.prefix(6).map { .capital(country: $0.0, capitalName: $0.1) }
            ))
        }

        if !orgMatches.isEmpty {
            result.append(SearchResultSection(
                id: "organizations",
                title: "Organizations",
                icon: "building.columns.fill",
                rows: orgMatches.prefix(5).map { .organization($0) }
            ))
        }

        return result
    }
}
