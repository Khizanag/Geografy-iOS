import Geografy_Core_Navigation
import Geografy_Core_Common
import Geografy_Core_Service
import Geografy_Core_DesignSystem
import SwiftUI

public struct SearchScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryService

    @AppStorage("search_topAligned") private var topAligned = false

    @State private var query = ""
    @State private var sections: [SearchResultSection] = []
    @State private var isSearching = false
    @State private var recentService = RecentSearchesService()
    @State private var searchTask: Task<Void, Never>?

    private let trendingQueries = [
        "United States", "China", "Japan", "Brazil", "France",
        "Australia", "India", "Egypt", "United Nations", "Canada",
    ]

    public init() {}

    public var body: some View {
        mainContent
            .animation(.easeInOut(duration: 0.2), value: query.isEmpty)
            .background(DesignSystem.Color.background)
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Countries, capitals, organizations…")
            .onChange(of: query) { _, newValue in
                scheduleSearch(query: newValue)
            }
    }
}

// MARK: - Subviews
private extension SearchScreen {
    @ViewBuilder
    var mainContent: some View {
        if query.isEmpty {
            emptyStateContent
        } else {
            resultContent
        }
    }
}

// MARK: - Empty State
private extension SearchScreen {
    var emptyStateContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                if !topAligned {
                    Spacer(minLength: 0)
                }
                if !recentService.queries.isEmpty {
                    recentSearchesSection
                }
                trendingSection
                if topAligned {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
            .containerRelativeFrame(.vertical, alignment: topAligned ? .top : .bottom)
        }
        .defaultScrollAnchor(topAligned ? .top : .bottom)
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
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(recentService.queries, id: \.self) { recentQuery in
                    recentRow(recentQuery)
                }
            }
        }
    }

    func recentRow(_ recentQuery: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Button {
                query = recentQuery
                scheduleSearch(query: recentQuery)
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    Text(recentQuery)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    DesignSystem.Color.cardBackground,
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(PressButtonStyle())

            Button {
                recentService.remove(recentQuery)
            } label: {
                Image(systemName: "xmark")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .padding(DesignSystem.Spacing.xs)
            }
            .glassEffect(.regular.interactive(), in: .circle)
        }
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
                .font(DesignSystem.Font.displaySmall)
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
                if !topAligned {
                    Spacer(minLength: 0)
                }
                ForEach(sections) { section in
                    resultSection(section)
                }
                if topAligned {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .containerRelativeFrame(.vertical, alignment: topAligned ? .top : .bottom)
        }
        .defaultScrollAnchor(topAligned ? .top : .bottom)
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
            Button {
                recentService.add(query)
                coordinator.push(.countryDetail(country))
            } label: {
                countryRowContent(country)
            }
            .buttonStyle(PressButtonStyle())

        case .capital(let country, let capitalName):
            Button {
                recentService.add(query)
                coordinator.push(.countryDetail(country))
            } label: {
                capitalRowContent(country: country, capitalName: capitalName)
            }
            .buttonStyle(PressButtonStyle())

        case .organization(let organization):
            Button {
                recentService.add(query)
                coordinator.push(.organizationDetail(organization))
            } label: {
                organizationRowContent(organization)
            }
            .buttonStyle(PressButtonStyle())
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
        .contentShape(Rectangle())
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
        .contentShape(Rectangle())
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
        .contentShape(Rectangle())
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

        let countryMatches = matchingCountries(normalized: normalized)
        let capitalMatches = matchingCapitals(normalized: normalized, excludingCountries: countryMatches)
        let orgMatches = matchingOrganizations(normalized: normalized)

        return buildSections(
            countries: countryMatches,
            capitals: capitalMatches,
            organizations: orgMatches
        )
    }

    func matchingCountries(normalized: String) -> [Country] {
        countryService.countries.filter {
            $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .contains(normalized)
        }
    }

    func matchingCapitals(normalized: String, excludingCountries: [Country]) -> [(Country, String)] {
        countryService.countries.flatMap { country in
            guard !excludingCountries.contains(where: { $0.code == country.code }) else {
                return [(Country, String)]()
            }
            return country.allCapitals.compactMap { capital in
                let normalizedCapital = capital.name.folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )
                return normalizedCapital.contains(normalized) ? (country, capital.name) : nil
            }
        }
    }

    func matchingOrganizations(normalized: String) -> [Organization] {
        Organization.all.filter {
            let foldingOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            let normalizedFull = $0.fullName.folding(options: foldingOptions, locale: .current)
            let normalizedDisplay = $0.displayName.folding(options: foldingOptions, locale: .current)
            return normalizedFull.contains(normalized) || normalizedDisplay.contains(normalized)
        }
    }

    func buildSections(
        countries: [Country],
        capitals: [(Country, String)],
        organizations: [Organization]
    ) -> [SearchResultSection] {
        var result: [SearchResultSection] = []

        if !countries.isEmpty {
            result.append(
                SearchResultSection(
                    id: "countries",
                    title: "Countries",
                    icon: "globe",
                    rows: countries.prefix(8).map { .country($0) }
                )
            )
        }

        if !capitals.isEmpty {
            result.append(
                SearchResultSection(
                    id: "capitals",
                    title: "Capitals",
                    icon: "building.2.fill",
                    rows: capitals.prefix(6).map { .capital(country: $0.0, capitalName: $0.1) }
                )
            )
        }

        if !organizations.isEmpty {
            result.append(
                SearchResultSection(
                    id: "organizations",
                    title: "Organizations",
                    icon: "building.columns.fill",
                    rows: organizations.prefix(5).map { .organization($0) }
                )
            )
        }

        return result
    }
}
