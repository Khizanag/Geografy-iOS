import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

/// Favorites, the want-to-visit list, and named collections in one place.
public struct SavedScreen: View {
    // MARK: - Properties
    @State private var tab: SavedTab

    // MARK: - Init
    public init(tab: SavedTab = .favorites) {
        _tab = State(initialValue: tab)
    }

    // MARK: - Body
    public var body: some View {
        tabPages
            .segmentedTabs("Saved", selection: $tab, tabs: SavedTab.allCases) { $0.title }
            .navigationTitle("Saved")
            .closeButtonPlacementLeading()
    }
}

// MARK: - Subviews
private extension SavedScreen {
    var tabPages: some View {
        SegmentedTabContent(selection: tab, tabs: SavedTab.allCases) { content(for: $0) }
    }

    @ViewBuilder
    func content(for tab: SavedTab) -> some View {
        switch tab {
        case .favorites: FavoritesScreen()
        case .wantToVisit: TravelBucketListScreen()
        case .collections: CollectionsScreen()
        }
    }
}
