import Geografy_Core_DesignSystem
import SwiftUI

/// A map pin whose needle tip sits on its position. Each new `dropCount` drops it from above,
/// squashes it on landing, and sends a ripple out from the tip.
struct PinDropPinView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let dropCount: Int
    var color: Color = PinDropStyle.pinColor

    /// Bumped on appearing as well as on each drop: a keyframe animator only plays when its trigger changes.
    @State private var trigger = 0

    static let headDiameter: CGFloat = 26
    static let needleLength: CGFloat = 14

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            ripple
            groundShadow
            pin
        }
        .frame(width: 80, height: Self.headDiameter + Self.needleLength)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { trigger += 1 }
        .onChange(of: dropCount) { trigger += 1 }
    }
}

// MARK: - Subviews
private extension PinDropPinView {
    @ViewBuilder
    var pin: some View {
        let body = VStack(spacing: 0) {
            head
            needle
        }
        if reduceMotion {
            body
        } else {
            body.keyframeAnimator(initialValue: Motion(), trigger: trigger) { content, motion in
                content
                    .scaleEffect(x: motion.stretchX, y: motion.stretchY, anchor: .bottom)
                    .offset(y: motion.lift)
            } keyframes: { _ in
                KeyframeTrack(\.lift) {
                    LinearKeyframe(-90, duration: 0.01)
                    CubicKeyframe(0, duration: 0.28)
                    SpringKeyframe(0, duration: 0.3, spring: .bouncy)
                }
                KeyframeTrack(\.stretchY) {
                    CubicKeyframe(1.15, duration: 0.29)
                    CubicKeyframe(0.7, duration: 0.08)
                    SpringKeyframe(1, duration: 0.35, spring: .bouncy(extraBounce: 0.2))
                }
                KeyframeTrack(\.stretchX) {
                    CubicKeyframe(0.9, duration: 0.29)
                    CubicKeyframe(1.3, duration: 0.08)
                    SpringKeyframe(1, duration: 0.35, spring: .bouncy(extraBounce: 0.2))
                }
            }
        }
    }

    var head: some View {
        Circle()
            .fill(color.gradient)
            .overlay {
                Circle()
                    .fill(DesignSystem.Color.markerOutline)
                    .frame(width: Self.headDiameter * 0.34)
            }
            .overlay {
                Circle().strokeBorder(DesignSystem.Color.markerOutline, lineWidth: 2.5)
            }
            .frame(width: Self.headDiameter, height: Self.headDiameter)
            .shadow(color: DesignSystem.Color.markerShadow, radius: 4, y: 3)
    }

    var needle: some View {
        NeedleShape()
            .fill(color.mix(with: .black, by: 0.25))
            .frame(width: 6, height: Self.needleLength)
    }

    var groundShadow: some View {
        Ellipse()
            .fill(DesignSystem.Color.markerShadow)
            .frame(width: 14, height: 5)
            .blur(radius: 1.5)
            .offset(y: 2.5)
    }

    var ripple: some View {
        Circle()
            .strokeBorder(color, lineWidth: 2)
            .frame(width: 18, height: 18)
            .offset(y: 9)
            .keyframeAnimator(initialValue: Ripple(), trigger: trigger) { content, ripple in
                content
                    .scaleEffect(ripple.scale)
                    .opacity(ripple.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(0.2, duration: 0.3)
                    CubicKeyframe(3.6, duration: 0.6)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0, duration: 0.3)
                    LinearKeyframe(reduceMotion ? 0 : 0.9, duration: 0.01)
                    CubicKeyframe(0, duration: 0.6)
                }
            }
    }
}

// MARK: - Animation Values
private extension PinDropPinView {
    struct Motion {
        var lift: CGFloat = 0
        var stretchX: CGFloat = 1
        var stretchY: CGFloat = 1
    }

    struct Ripple {
        var scale: CGFloat = 0.2
        var opacity: Double = 0
    }
}

// MARK: - Needle
private struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Burst
/// Sparks flying out from a point, for a bullseye.
struct PinDropBurstView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let color: Color

    @State private var trigger = 0

    private static let sparkCount = 14

    var body: some View {
        ZStack {
            ForEach(0..<Self.sparkCount, id: \.self) { index in
                spark(at: index)
            }
        }
        .frame(width: 1, height: 1)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { trigger += 1 }
    }

    private func spark(at index: Int) -> some View {
        let angle = Angle.degrees(Double(index) / Double(Self.sparkCount) * 360)
        let distance: CGFloat = index.isMultiple(of: 2) ? 64 : 46
        return Circle()
            .fill(index.isMultiple(of: 3) ? DesignSystem.Color.warning : color)
            .frame(width: index.isMultiple(of: 2) ? 7 : 5)
            .keyframeAnimator(initialValue: Spark(), trigger: trigger) { content, spark in
                content
                    .offset(
                        x: cos(angle.radians) * distance * spark.travel,
                        y: sin(angle.radians) * distance * spark.travel
                    )
                    .scaleEffect(spark.scale)
                    .opacity(spark.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.travel) {
                    LinearKeyframe(0, duration: 0.01)
                    CubicKeyframe(1, duration: 0.7)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(reduceMotion ? 0 : 1, duration: 0.01)
                    LinearKeyframe(reduceMotion ? 0 : 1, duration: 0.4)
                    CubicKeyframe(0, duration: 0.4)
                }
                KeyframeTrack(\.scale) {
                    LinearKeyframe(1.2, duration: 0.2)
                    CubicKeyframe(0.2, duration: 0.6)
                }
            }
    }

    private struct Spark {
        var travel: CGFloat = 0
        var opacity: Double = 0
        var scale: CGFloat = 1
    }
}
