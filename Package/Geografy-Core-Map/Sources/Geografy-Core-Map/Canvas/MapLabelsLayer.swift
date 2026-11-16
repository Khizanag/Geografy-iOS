import Geografy_Core_Common
import SwiftUI

/// Country names drawn at the map's current scale and offset, above a map that's moved by a transform.
///
/// Drawn into the moved map, names were stretched with it during a pinch and then snapped to their
/// proper size when it was redrawn. Drawn here on every frame, they resize and fade smoothly instead.
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
