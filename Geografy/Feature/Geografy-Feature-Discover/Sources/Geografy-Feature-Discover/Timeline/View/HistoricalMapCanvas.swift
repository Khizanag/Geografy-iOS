#if !os(tvOS)
import Geografy_Core_Map
import SwiftUI

/// Reads pan and zoom on its own, so a gesture redraws the map without re-running the banner and year footer.
struct HistoricalMapCanvas: View {
    // MARK: - Properties
    let mapState: MapState
    let canvasSize: CGSize

    // MARK: - Body
    var body: some View {
        MapCanvasView(
            countryShapes: mapState.countryShapes,
            scale: mapState.scale,
            offset: mapState.offset,
            selectedCountryCode: mapState.selectedCountryCode,
            showLabels: mapState.showLabels,
            canvasSize: canvasSize
        )
    }
}
#endif
