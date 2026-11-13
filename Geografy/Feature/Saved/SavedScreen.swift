import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Feature_Favorite
import Geografy_Feature_Travel
import SwiftUI

/// Favorites, the want-to-visit list, and named collections in one place.
struct SavedScreen: View {
    // MARK: - Properties
    @State private var tab: SavedTab

    // MARK: - Init
    init(tab: SavedTab = .favorites) {
        _tab = State(initialValue: tab)
    }

    // MARK: - Body
    var body: some View {
        tabContent
            .segmentedTabs("Saved", selection: $tab, tabs: SavedTab.allCases) { $0.title }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
    }
}

// MARK: - Subviews
private extension SavedScreen {
    @ViewBuilder
    var tabContent: some View {
        switch tab {
        case .favorites: FavoritesScreen()
        case .wantToVisit: TravelBucketListScreen()
        case .collections: CollectionsScreen()
        }
    }
}
