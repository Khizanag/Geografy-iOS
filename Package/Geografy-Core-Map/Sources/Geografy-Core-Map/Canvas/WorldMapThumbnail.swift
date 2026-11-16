import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// The whole world, fitted inside its frame and centered: the full Earth outline where the projection draws one,
/// otherwise all the land. For heroes and cards; it takes no touches and is hidden from VoiceOver.
public struct WorldMapThumbnail: View {
    // MARK: - Properties
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage(MapPreferences.projectionKey) private var projection = MapProjectionKind.mercator.rawValue
    @AppStorage(MapPreferences.paletteKey) private var palette = MapPalette.default.rawValue

    @State private var shapes: [CountryShape] = []

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            let fitted = fit(in: geometry.size)
            MapCanvasView(
                countryShapes: shapes,
                scale: fitted.scale,
                offset: fitted.offset,
                selectedCountryCode: nil,
                showLabels: false,
                canvasSize: geometry.size,
                wrapsHorizontally: false
            )
        }
        .opacity(shapes.isEmpty ? 0 : 1)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .task(id: "\(projection)-\(palette)") { await loadShapes() }
    }
}

// MARK: - Fitting
private extension WorldMapThumbnail {
    /// The scale and offset that fit `worldBounds` inside `size` and center it.
    func fit(in size: CGSize) -> (scale: CGFloat, offset: CGSize) {
        let bounds = worldBounds
        guard bounds.width > 0, bounds.height > 0, size.width > 0, size.height > 0 else {
            return (size.width / MapProjection.mapWidth, .zero)
        }
        let scale = min(size.width / bounds.width, size.height / bounds.height)
        // The canvas centers the map's square, so moving the bounds' center there centers the world.
        let offset = CGSize(
            width: (MapProjection.mapWidth / 2 - bounds.midX) * scale,
            height: (MapProjection.mapHeight / 2 - bounds.midY) * scale
        )
        return (scale, offset)
    }

    /// The Earth's outline where the projection draws one, so it's never cut; otherwise the land.
    var worldBounds: CGRect {
        let land = shapes.dropFirst().reduce(shapes.first?.boundingBox ?? .zero) { $0.union($1.boundingBox) }
        return MapProjection.worldBounds(around: land, kind: MapProjectionKind(rawValue: projection) ?? .mercator)
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
