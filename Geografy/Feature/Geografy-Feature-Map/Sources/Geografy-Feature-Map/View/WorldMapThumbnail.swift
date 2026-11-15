import Geografy_Core_Common
import Geografy_Core_Service
import SwiftUI

/// The whole world map drawn to fit its frame's width, with the countries the person visited lit up.
/// For heroes and cards; it takes no touches and is hidden from VoiceOver.
public struct WorldMapThumbnail: View {
    // MARK: - Properties
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(TravelService.self) private var travelService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var shapes: [CountryShape] = []

    private let northwardShift: CGFloat

    // MARK: - Init
    /// - Parameter northwardShift: How far below center the map sits, as a share of its height,
    ///   so a short frame shows the northern lands where most countries are.
    public init(northwardShift: CGFloat = 0.1) {
        self.northwardShift = northwardShift
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / MapProjection.mapWidth
            MapCanvasView(
                countryShapes: shapes,
                scale: scale,
                offset: CGSize(width: 0, height: MapProjection.mapHeight * scale * northwardShift),
                selectedCountryCode: nil,
                showLabels: false,
                canvasSize: geometry.size,
                highlightedCodes: travelService.visitedCodes,
                wrapsHorizontally: false
            )
        }
        .opacity(shapes.isEmpty ? 0 : 1)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task { await loadShapes() }
    }
}

// MARK: - Loading
private extension WorldMapThumbnail {
    func loadShapes() async {
        let loaded = await geoJSONCache.loadShapes()
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
            shapes = loaded
        }
    }
}
