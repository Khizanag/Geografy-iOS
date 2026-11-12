import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

/// The countries you've visited or want to visit, and your journal of trips.
public struct TravelScreen: View {
    // MARK: - Properties
    @State private var tab: Tab = .countries

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        tabContent
            .safeAreaInset(edge: .top) { tabPicker }
            .navigationTitle("Travel")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .closeButtonPlacementLeading()
    }
}

// MARK: - Tab
private extension TravelScreen {
    enum Tab: String, CaseIterable, Identifiable {
        case countries
        case journal

        var id: String { rawValue }

        var title: String {
            switch self {
            case .countries: "Countries"
            case .journal: "Journal"
            }
        }
    }
}

// MARK: - Subviews
private extension TravelScreen {
    var tabPicker: some View {
        Picker("Travel", selection: $tab) {
            ForEach(Tab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    @ViewBuilder
    var tabContent: some View {
        switch tab {
        case .countries: TravelTrackerScreen()
        case .journal: TravelJournalScreen()
        }
    }
}
