import Geografy_Core_Common
import SwiftUI

@MainActor
@Observable
public final class MapState {
    public var scale: CGFloat = 1.0
    public var offset: CGSize = .zero
    public var lastScale: CGFloat = 1.0
    public var lastOffset: CGSize = .zero
    public var minScale: CGFloat = 0.15
    public static let maxScale: CGFloat = 100.0
    public var selectedCountryCode: String?
    public var showLabels = false
    public var countryShapes: [CountryShape] = []
    public var contentBounds: CGRect = .zero
    /// The frame the map stays drawn at while a pan or pinch runs; nil when no gesture is in progress.
    public private(set) var gestureFrame: MapFrame?

    public var selectedShape: CountryShape? {
        countryShapes.first { $0.id == selectedCountryCode }
    }

    public init() {}
}

// MARK: - Actions
public extension MapState {
    func reset() {
        scale = 1.0
        offset = .zero
        lastScale = 1.0
        lastOffset = .zero
        selectedCountryCode = nil
        gestureFrame = nil
    }

    /// Keeps `content`, in map coordinates, on screen: a side bigger than the view pans only until its edge meets
    /// the view's edge, a smaller one stays centered. A map that wraps sideways is held only top to bottom.
    func clampOffset(to content: CGRect, in viewSize: CGSize, horizontally: Bool) {
        guard content.width > 0, content.height > 0 else { return }
        offset.height = Self.clamped(
            offset.height,
            content: content.minY...content.maxY,
            mapLength: MapProjection.mapHeight,
            viewLength: viewSize.height,
            scale: scale
        )
        guard horizontally else { return }
        offset.width = Self.clamped(
            offset.width,
            content: content.minX...content.maxX,
            mapLength: MapProjection.mapWidth,
            viewLength: viewSize.width,
            scale: scale
        )
    }
}

// MARK: - Clamping
private extension MapState {
    /// One axis of `clampOffset`. An offset moves the map's center, so it's measured from the content's center.
    static func clamped(
        _ offset: CGFloat,
        content: ClosedRange<CGFloat>,
        mapLength: CGFloat,
        viewLength: CGFloat,
        scale: CGFloat
    ) -> CGFloat {
        let maxOffset = max(0, ((content.upperBound - content.lowerBound) * scale - viewLength) / 2)
        let centerCorrection = (mapLength / 2 - (content.lowerBound + content.upperBound) / 2) * scale
        return min(max(offset - centerCorrection, -maxOffset), maxOffset) + centerCorrection
    }
}

// MARK: - Gesture Frame
public extension MapState {
    var currentFrame: MapFrame { MapFrame(scale: scale, offset: offset) }

    /// What the map is drawn at: the gesture frame while a gesture runs, otherwise the current scale and offset.
    var drawnFrame: MapFrame { gestureFrame ?? currentFrame }

    /// Keeps the map drawn where it is, so the gesture moves the drawn map instead of redrawing it.
    func beginGesture() {
        guard gestureFrame == nil else { return }
        gestureFrame = currentFrame
    }

    /// Draws the map at the current scale and offset again, once the gesture is over.
    func endGesture() {
        gestureFrame = nil
    }

    /// Whether the drawn map no longer covers the view, or is enlarged enough to blur,
    /// so it must be redrawn mid-gesture.
    func needsRedraw(in viewSize: CGSize) -> Bool {
        guard let gestureFrame else { return false }
        return !MapFrame.drawnMap(gestureFrame, covers: viewSize, at: currentFrame)
    }

    func redrawGestureFrame() {
        guard gestureFrame != nil else { return }
        gestureFrame = currentFrame
    }
}

// MARK: - MapFrame
/// A scale and offset the map is drawn at.
public struct MapFrame: Equatable, Sendable {
    // MARK: - Properties
    /// How far past each edge of the view the map is drawn, as a fraction of the view's size,
    /// so a pan has map to reveal before it needs a redraw.
    public static let overscan: CGFloat = 0.5
    /// How much a pinch may enlarge the drawn map before it's redrawn sharp.
    public static let maxMagnification: CGFloat = 2

    public var scale: CGFloat
    public var offset: CGSize

    // MARK: - Init
    public init(scale: CGFloat, offset: CGSize) {
        self.scale = scale
        self.offset = offset
    }

    // MARK: - Geometry
    /// The size the map is drawn at for a view of `viewSize`, centered on the view.
    public static func drawnSize(for viewSize: CGSize) -> CGSize {
        CGSize(
            width: viewSize.width * (1 + 2 * overscan),
            height: viewSize.height * (1 + 2 * overscan)
        )
    }

    /// The magnification and shift that move a map drawn at `self` to where `target` puts it.
    /// Scale about the view's center first, then shift.
    public func transform(to target: MapFrame) -> (magnification: CGFloat, shift: CGSize) {
        let magnification = target.scale / scale
        let shift = CGSize(
            width: target.offset.width - magnification * offset.width,
            height: target.offset.height - magnification * offset.height
        )
        return (magnification, shift)
    }

    /// Whether a map drawn at `drawn` still fills a view of `viewSize` once moved to `target`, without blurring.
    public static func drawnMap(_ drawn: MapFrame, covers viewSize: CGSize, at target: MapFrame) -> Bool {
        let (magnification, shift) = drawn.transform(to: target)
        guard magnification <= maxMagnification else { return false }

        let halfDrawn = CGSize(
            width: drawnSize(for: viewSize).width / 2,
            height: drawnSize(for: viewSize).height / 2
        )
        // The view's edges, measured from its center in the drawn map's coordinates, must stay inside the drawn map.
        let reachX = (viewSize.width / 2 + abs(shift.width)) / magnification
        let reachY = (viewSize.height / 2 + abs(shift.height)) / magnification
        return reachX <= halfDrawn.width && reachY <= halfDrawn.height
    }
}
