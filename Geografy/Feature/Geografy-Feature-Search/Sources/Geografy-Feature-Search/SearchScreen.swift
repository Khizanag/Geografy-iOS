import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct SearchScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var query = ""
    @State private var scope: SearchScope = .all
    @State private var recentService = RecentSearchesService()
    @State private var hasFocusedOnOpen = false
    @FocusState private var isSearchFocused: Bool

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        content
            .animation(reduceMotion ? nil : .smooth(duration: 0.2), value: results)
            .screenBackground()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Countries, capitals, organizations"
            )
            .searchScopes($scope, activation: .onSearchPresentation) {
                ForEach(SearchScope.allCases) { scope in
                    Text(scope.title).tag(scope)
                }
            }
            .searchFocused($isSearchFocused)
            .onAppear(perform: focusSearchOnFirstOpen)
    }
}

// MARK: - Subviews
private extension SearchScreen {
    @ViewBuilder
    var content: some View {
        if trimmedQuery.isEmpty {
            SearchSuggestionsView(
                recentService: recentService,
                onSearch: { query = $0 },
                onOpen: open
            )
        } else if results.isEmpty {
            ContentUnavailableView.search(text: trimmedQuery)
        } else {
            SearchResultsView(results: results, query: trimmedQuery, onOpen: open)
        }
    }
}

// MARK: - Data
private extension SearchScreen {
    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Local data, so results update on every keystroke with no debounce or spinner.
    var results: SearchResults {
        SearchEngine(countries: countryService.countries, organizations: Organization.all)
            .results(for: trimmedQuery, scope: scope)
    }
}

// MARK: - Actions
private extension SearchScreen {
    // Opening Search means the person is about to type. Coming back from a result keeps the keyboard down.
    func focusSearchOnFirstOpen() {
        guard !hasFocusedOnOpen else { return }
        hasFocusedOnOpen = true
        isSearchFocused = true
    }

    func open(_ row: SearchRow) {
        recentService.add(trimmedQuery.isEmpty ? row.title : trimmedQuery)
        switch row {
        case .country(let country), .capital(let country, _):
            coordinator.push(.countryDetail(country))
        case .organization(let organization):
            coordinator.push(.organizationDetail(organization))
        }
    }
}
