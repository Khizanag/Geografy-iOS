import SwiftUI

/// Shows a map drawn past the view's edges and, while a gesture runs, moves that drawing instead of redrawing it.
///
/// Redrawing every country on each touch event is what made panning and pinching stutter.
/// The map is drawn at `MapState.drawnFrame` and moved to the current scale and offset with a transform,
/// so it's drawn again only when a gesture ends or runs past what was drawn.
/// Country names are the exception: they're cheap, so they're drawn at the current frame every time,
/// which keeps their size and fade smooth through a pinch. The selected country and capital pin are drawn in
/// a layer of their own, so a tap redraws one country, not the whole map.
public struct MapViewport: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let mapState: MapState
    let viewSize: CGSize
    let canvas: (MapFrame, CGSize) -> MapCanvasView

    // MARK: - Init
    /// - Parameter canvas: The map drawn at a frame, at the given canvas size.
    public init(
        mapState: MapState,
        viewSize: CGSize,
        canvas: @escaping (MapFrame, CGSize) -> MapCanvasView
    ) {
        self.mapState = mapState
        self.viewSize = viewSize
        self.canvas = canvas
    }

    // MARK: - Body
    public var body: some View {
        let drawnFrame = mapState.drawnFrame
        let (magnification, shift) = drawnFrame.transform(to: mapState.currentFrame)
        var map = canvas(drawnFrame, MapFrame.drawnSize(for: viewSize))
        let showsLabels = map.showLabels
        map.showLabels = false
        var selection = map
        selection.drawsOnlySelection = true
        let showsSelection = map.selectedCountryCode != nil || map.capitalPoint != nil
        map.selectedCountryCode = nil
        map.capitalPoint = nil

        return ZStack {
            map
                .equatable()
                .scaleEffect(magnification)
                .offset(shift)

            if showsSelection {
                selection
                    .equatable()
                    .scaleEffect(magnification)
                    .offset(shift)
                    .allowsHitTesting(false)
            }

            MapGraticuleView(
                scale: mapState.currentFrame.scale,
                offset: mapState.currentFrame.offset,
                wrapsHorizontally: map.wrapsHorizontally
            )
            .frame(width: viewSize.width, height: viewSize.height)

            if showsLabels {
                labels(for: map, drawnFrame: drawnFrame, isPanning: magnification == 1, shift: shift)
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: showsLabels)
        .frame(width: viewSize.width, height: viewSize.height)
        .clipped()
        .contentShape(Rectangle())
    }
}

// MARK: - Labels
private extension MapViewport {
    /// A pan only moves the names, so they're drawn once at the drawn frame, over the drawn map's area, and
    /// moved with it. A pinch resizes them, so they're drawn at the current frame every time.
    @ViewBuilder
    func labels(for map: MapCanvasView, drawnFrame: MapFrame, isPanning: Bool, shift: CGSize) -> some View {
        if isPanning {
            let drawnSize = MapFrame.drawnSize(for: viewSize)
            MapLabelsLayer(
                countryShapes: map.countryShapes,
                frame: drawnFrame,
                wrapsHorizontally: map.wrapsHorizontally
            )
            .equatable()
            .frame(width: drawnSize.width, height: drawnSize.height)
            .offset(shift)
        } else {
            MapLabelsLayer(
                countryShapes: map.countryShapes,
                frame: mapState.currentFrame,
                wrapsHorizontally: map.wrapsHorizontally
            )
            .frame(width: viewSize.width, height: viewSize.height)
        }
    }
}
