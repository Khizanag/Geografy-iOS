import QuartzCore
import SwiftUI

/// Steps a map from one frame to another on every screen refresh, the way a pinch moves it, so the viewport can
/// redraw the map sharp whenever it's stretched too far, instead of stretching one picture across the whole flight.
@MainActor
final class MapFlight: NSObject {
    // MARK: - Properties
    private let start: MapFrame
    private let target: MapFrame
    private let duration: TimeInterval
    private let step: (MapFrame) -> Void
    private let completion: () -> Void

    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?

    // MARK: - Init
    init(
        from start: MapFrame,
        to target: MapFrame,
        duration: TimeInterval,
        step: @escaping (MapFrame) -> Void,
        completion: @escaping () -> Void
    ) {
        self.start = start
        self.target = target
        self.duration = duration
        self.step = step
        self.completion = completion
    }

    // MARK: - Running
    func run() {
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// Stops where the map is, without landing; a gesture takes over from here.
    func cancel() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        let startTime = startTime ?? link.timestamp
        self.startTime = startTime
        let progress = duration > 0 ? min(1, (link.timestamp - startTime) / duration) : 1
        step(Self.frame(from: start, to: target, at: progress))
        guard progress >= 1 else { return }
        cancel()
        completion()
    }
}

// MARK: - Interpolation
extension MapFlight {
    /// The frame `progress` of the way through a flight. The zoom changes geometrically, so each doubling takes as
    /// long as the next; the point at the view's center moves straight across the map, mostly while zoomed out,
    /// so the map never sweeps past at full zoom.
    static func frame(from start: MapFrame, to target: MapFrame, at progress: Double) -> MapFrame {
        let eased = easeInOut(progress)
        let scale = start.scale * pow(target.scale / start.scale, eased)
        let isZoomingIn = target.scale > start.scale
        let travel = isZoomingIn ? 1 - pow(1 - eased, 2) : eased * eased
        // An offset is the center's shift in screen points; divided by the scale it's a distance on the map.
        let startShift = CGSize(width: start.offset.width / start.scale, height: start.offset.height / start.scale)
        let targetShift = CGSize(width: target.offset.width / target.scale, height: target.offset.height / target.scale)
        let shift = CGSize(
            width: startShift.width + (targetShift.width - startShift.width) * travel,
            height: startShift.height + (targetShift.height - startShift.height) * travel
        )
        return MapFrame(scale: scale, offset: CGSize(width: shift.width * scale, height: shift.height * scale))
    }

    /// A sine ease: it starts and lands gently, and its fastest moment is only about 1.6 times its average, so no
    /// frame of the zoom leaps ahead of the one before.
    static func easeInOut(_ progress: Double) -> Double {
        (1 - cos(.pi * progress)) / 2
    }
}
