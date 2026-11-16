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
        topicContent
            .safeAreaInset(edge: .top) { topicPicker }
            .navigationTitle("World Facts")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}

// MARK: - Subviews
private extension WorldFactsScreen {
    var topicPicker: some View {
        Picker("Topic", selection: $topic) {
            ForEach(WorldFactsTopic.allCases) { topic in
                Text(topic.title).tag(topic)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    @ViewBuilder
    var topicContent: some View {
        switch topic {
        case .records: WorldRecordsScreen()
        case .oceans: OceanExplorerScreen()
        case .features: GeographyFeaturesScreen()
        case .landmarks: LandmarkGalleryScreen()
        }
    }
}
