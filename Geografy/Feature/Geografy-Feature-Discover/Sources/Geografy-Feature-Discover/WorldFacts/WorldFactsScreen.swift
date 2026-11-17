import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

/// Records, oceans, geography features, and landmarks in one screen.
public struct WorldFactsScreen: View {
    // MARK: - Properties
    @State private var topic: WorldFactsTopic

    // MARK: - Init
    public init(topic: WorldFactsTopic = .records) {
        _topic = State(initialValue: topic)
    }

    // MARK: - Body
    public var body: some View {
        SegmentedTabContent(selection: topic, tabs: WorldFactsTopic.allCases) { content(for: $0) }
            .segmentedTabs("World Facts", selection: $topic, tabs: WorldFactsTopic.allCases) {
                LocalizedStringKey($0.title)
            }
            .navigationTitle("World Facts")
    }
}

// MARK: - Subviews
private extension WorldFactsScreen {
    @ViewBuilder
    func content(for topic: WorldFactsTopic) -> some View {
        switch topic {
        case .records: WorldRecordsScreen()
        case .oceans: OceanExplorerScreen()
        case .features: GeographyFeaturesScreen()
        case .landmarks: LandmarkGalleryScreen()
        }
    }
}
