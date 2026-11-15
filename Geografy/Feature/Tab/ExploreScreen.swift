import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Feature_CountryList
import Geografy_Feature_Map
import SwiftUI

/// The Explore tab: every country as a list or on the map.
struct ExploreScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator

    @State private var mode: Mode = .countries
    @State private var countryListState = CountryListState()

    // MARK: - Body
    var body: some View {
        modePages
            .segmentedTabs("View", selection: $mode, tabs: Mode.allCases) { $0.title }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { coordinator.push(.search) } label: {
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
        case maps

        var id: String { rawValue }

        var title: LocalizedStringKey {
            switch self {
            case .countries: "Countries"
            case .maps: "Maps"
            }
        }
    }
}

// MARK: - Subviews
private extension ExploreScreen {
    var modePages: some View {
        SegmentedTabContent(selection: mode, tabs: Mode.allCases) { content(for: $0) }
    }

    @ViewBuilder
    func content(for mode: Mode) -> some View {
        switch mode {
        // The list's state is kept here, so switching to Maps and back keeps its search, sort, and groups.
        case .countries: CountryListScreen(state: countryListState)
        case .maps: AllMapsScreen()
        }
    }
}
