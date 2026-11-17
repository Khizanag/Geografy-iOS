import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Country
import SwiftUI

/// The Explore tab: every country in a list, and a Discover page with the country of the day, facts, and tools.
struct ExploreScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.displayScale) private var displayScale

    @State private var mode: Mode = .countries
    @State private var countryListState = CountryListState()

    // MARK: - Body
    var body: some View {
        modePages
            .segmentedTabs("View", selection: $mode, tabs: Mode.allCases) { $0.title }
            .navigationTitle("Explore")
            .task(id: countryDataService.countries.count, priority: .utility) { await prewarmListFlags() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { coordinator.push(CountryRoute.search) } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            }
    }
}

// MARK: - Mode
private extension ExploreScreen {
    enum Mode: String, CaseIterable, Identifiable {
        case countries
        case discover

        var id: String { rawValue }

        var title: LocalizedStringKey {
            switch self {
            case .countries: "Countries"
            case .discover: "Discover"
            }
        }
    }

    static let discoverSections = [
        HubSection(title: "Reference", items: [.worldFacts, .timeline, .orgs, .compare]),
        HubSection(title: "Tools", items: [.timeZones, .currencyConverter, .distanceCalculator]),
    ]
}

// MARK: - Subviews
private extension ExploreScreen {
    var modePages: some View {
        SegmentedTabContent(selection: mode, tabs: Mode.allCases) { content(for: $0) }
    }

    @ViewBuilder
    func content(for mode: Mode) -> some View {
        switch mode {
        // The list's state is kept here, so switching to Discover and back keeps its search, sort, and groups.
        case .countries: CountryListScreen(state: countryListState)
        case .discover: HubGrid(sections: Self.discoverSections) { countryOfTheDay }
        }
    }

    @ViewBuilder
    var countryOfTheDay: some View {
        if let country = countryDataService.countryOfTheDay() {
            Button { coordinator.push(CountryRoute.countryDetail(country)) } label: {
                CountrySpotlightCard(
                    country: country,
                    funFact: CountryFunFacts.data[country.code]?.first
                )
            }
            .buttonStyle(PressButtonStyle())
        }
    }
}

// MARK: - Flags
private extension ExploreScreen {
    /// The country list draws every flag at row size, so decoding them when Explore first opens keeps the first
    /// scroll smooth without slowing launch, which opens on the map.
    func prewarmListFlags() async {
        await FlagImageCache.shared.prewarm(
            countryCodes: countryDataService.countries.map(\.code),
            pointHeight: DesignSystem.Size.Flag.row,
            displayScale: displayScale
        )
    }
}
