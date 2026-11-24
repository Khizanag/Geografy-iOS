import SwiftUI

/// A map the reader pans, pinches, and taps: every map in the app, so they all move the same way and none
/// redraws the world on each touch.
///
/// It draws through `MapViewport`, which moves the drawn map during a gesture and redraws it only when the
/// gesture ends or runs past what was drawn. A pinch zooms around where the fingers started.
public struct InteractiveMapViewport: View {
    // MARK: - Properties
    let mapState: MapState
    let viewSize: CGSize
    let bounds: CGRect
    let wrapsHorizontally: Bool
    let onTap: ((CGPoint) -> Void)?
    let canvas: (MapFrame, CGSize) -> MapCanvasView

    // MARK: - Init
    /// - Parameters:
    ///   - bounds: The part of the map panning keeps on screen.
    ///   - wrapsHorizontally: Whether the world repeats sideways, so panning that way never stops.
    ///   - onTap: Called with the tapped point in the view.
    ///   - canvas: The map drawn at a frame, at the given canvas size.
    public init(
        mapState: MapState,
        viewSize: CGSize,
        bounds: CGRect,
        wrapsHorizontally: Bool = false,
        onTap: ((CGPoint) -> Void)? = nil,
        canvas: @escaping (MapFrame, CGSize) -> MapCanvasView
    ) {
        self.mapState = mapState
        self.viewSize = viewSize
        self.bounds = bounds
        self.wrapsHorizontally = wrapsHorizontally
        self.onTap = onTap
        self.canvas = canvas
    }

    // MARK: - Body
    public var body: some View {
        MapViewport(mapState: mapState, viewSize: viewSize, canvas: canvas)
            #if !os(tvOS)
            .gesture(dragGesture)
            .gesture(magnifyGesture)
            .onTapGesture(count: 1) { location in
                onTap?(location)
            }
            #endif
    }
}

// MARK: - Gestures
#if !os(tvOS)
private extension InteractiveMapViewport {
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                mapState.cancelFlight()
                mapState.beginGesture()
                let newScale = min(max(mapState.lastScale * value.magnification, mapState.minScale), MapState.maxScale)
                let scaleRatio = newScale / mapState.scale
                let anchorOffset = CGSize(
                    width: value.startLocation.x - viewSize.width / 2,
                    height: value.startLocation.y - viewSize.height / 2
                )
                mapState.offset = CGSize(
                    width: mapState.offset.width * scaleRatio - anchorOffset.width * (scaleRatio - 1),
                    height: mapState.offset.height * scaleRatio - anchorOffset.height * (scaleRatio - 1)
                )
                mapState.scale = newScale
                clampOffset()
                redrawIfNeeded()
            }
            .onEnded { _ in
                finishGesture()
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                mapState.cancelFlight()
                mapState.beginGesture()
                mapState.offset = CGSize(
                    width: mapState.lastOffset.width + value.translation.width,
                    height: mapState.lastOffset.height + value.translation.height
                )
                clampOffset()
                redrawIfNeeded()
            }
            .onEnded { _ in
                finishGesture()
            }
    }
}
#endif

// MARK: - Helpers
private extension InteractiveMapViewport {
    func clampOffset() {
        mapState.clampOffset(to: bounds, in: viewSize, horizontally: !wrapsHorizontally)
    }

    /// Redraws mid-gesture only once the moved map would show an edge or blur.
    /// A wrapping world moves to its nearest copy first, so the redraw lands on the copy in view.
    func redrawIfNeeded() {
        guard mapState.needsRedraw(in: viewSize) else { return }
        if wrapsHorizontally {
            mapState.wrapHorizontalOffset()
        }
        mapState.redrawGestureFrame()
    }

    func finishGesture() {
        if wrapsHorizontally {
            mapState.wrapHorizontalOffset()
        }
        mapState.lastScale = mapState.scale
        mapState.lastOffset = mapState.offset
        mapState.endGesture()
    }
}
