import Geografy_Core_Common
import SwiftUI

/// Country names drawn at the map's current scale and offset, above a map that's moved by a transform.
///
/// Drawn into the moved map, names were stretched with it during a pinch and then snapped to their
/// proper size when it was redrawn. Drawn here on every frame, they resize and fade smoothly instead.
/// A pan doesn't change their size, so `MapViewport` draws them once for it and moves them, which is why
/// the layer is `Equatable`: laying out every name is the costly part.
struct MapLabelsLayer: View {
    let countryShapes: [CountryShape]
    let frame: MapFrame
    let wrapsHorizontally: Bool

    var body: some View {
        Canvas { context, size in
            let visibleRect = CGRect(origin: .zero, size: size)
            let shifts = MapCanvasView.horizontalOffsets(scale: frame.scale, wrapsHorizontally: wrapsHorizontally)
            for horizontalShift in shifts {
                let transform = MapCanvasView.transform(
                    scale: frame.scale,
                    offset: frame.offset,
                    size: size,
                    horizontalShift: horizontalShift
                )
                MapLabelPainter.draw(countryShapes, in: &context, transform: transform, visibleRect: visibleRect)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Equatable
extension MapLabelsLayer: @MainActor Equatable {
    static func == (lhs: MapLabelsLayer, rhs: MapLabelsLayer) -> Bool {
        lhs.frame == rhs.frame
            && lhs.wrapsHorizontally == rhs.wrapsHorizontally
            && lhs.countryShapes.count == rhs.countryShapes.count
            && zip(lhs.countryShapes, rhs.countryShapes).allSatisfy { $0.id == $1.id && $0.name == $1.name }
    }
}
