import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Search Results
extension TravelTrackerScreen {
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
            Text("\(count) countries found")
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

    @ViewBuilder
    func searchRowTrailing(_ status: TravelStatus?) -> some View {
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

// MARK: - Empty States
extension TravelTrackerScreen {
    var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            emptyStateIcon
            emptyStateText
            emptyStateButton
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxl)
    }

    var emptyStateIcon: some View {
        Image(systemName: selectedFilter?.icon ?? "airplane.departure")
            .font(DesignSystem.Font.displaySmall)
            .foregroundStyle(selectedFilter?.color ?? DesignSystem.Color.textTertiary)
            .padding(.top, DesignSystem.Spacing.xxl)
    }

    var emptyStateText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(emptyStateTitle)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(emptyStateSubtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var emptyStateButton: some View {
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
}

// MARK: - Helpers
extension TravelTrackerScreen {
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
