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

    // MARK: - Body
    var body: some View {
        modeContent
            .safeAreaInset(edge: .top) { modePicker }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
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

        var title: String {
            switch self {
            case .countries: "Countries"
            case .maps: "Maps"
            }
        }
    }
}

// MARK: - Subviews
private extension ExploreScreen {
    var modePicker: some View {
        Picker("View", selection: $mode) {
            ForEach(Mode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    @ViewBuilder
    var modeContent: some View {
        switch mode {
        case .countries: CountryListScreen()
        case .maps: AllMapsScreen()
        }
    }
}
