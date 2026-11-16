import Geografy_Core_Navigation
import Geografy_Feature_Map
import SwiftUI

/// The Map tab: the world map, with every continent's own map one tap away.
struct MapTabScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator

    // MARK: - Body
    var body: some View {
        MapScreen()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { coordinator.push(.continents) } label: {
                        Label("Continents", systemImage: "globe.europe.africa")
                    }
                }
            }
    }
}
