import SwiftUI

/// Shows a map drawn past the view's edges and, while a gesture runs, moves that drawing instead of redrawing it.
///
/// Redrawing every country on each touch event is what made panning and pinching stutter.
/// The map is drawn at `MapState.drawnFrame` and moved to the current scale and offset with a transform,
/// so it's drawn again only when a gesture ends or runs past what was drawn.
public struct MapViewport: View {
    // MARK: - Properties
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

        canvas(drawnFrame, MapFrame.drawnSize(for: viewSize))
            .equatable()
            .scaleEffect(magnification)
            .offset(shift)
            .frame(width: viewSize.width, height: viewSize.height)
            .clipped()
            .contentShape(Rectangle())
    }
}
