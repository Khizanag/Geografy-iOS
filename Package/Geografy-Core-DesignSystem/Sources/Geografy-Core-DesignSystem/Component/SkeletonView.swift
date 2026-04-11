import SwiftUI

/// Shimmer-animated placeholder for loading states.
///
/// Use ``skeleton(isLoading:)`` to wrap any view: the view's real content
/// is rendered while `isLoading == false`; a matching-shaped shimmer shows
/// while `isLoading == true`. Reduce Motion replaces the shimmer with a
/// flat tint so users who dislike animation still see a clear placeholder.
public struct SkeletonView: View {
    public enum Shape: Sendable {
        case rectangle(cornerRadius: CGFloat)
        case circle
        case capsule
    }

    private let shape: Shape

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ shape: Shape = .rectangle(cornerRadius: 12)) {
        self.shape = shape
    }

    public var body: some View {
        if reduceMotion {
            fill(with: DesignSystem.Color.cardBackground)
                .accessibilityHidden(true)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
                let time = context.date.timeIntervalSinceReferenceDate
                fill(with: DesignSystem.Color.cardBackground)
                    .overlay {
                        fill(with: nil, gradient: shimmerGradient(time: time))
                            .blendMode(.plusLighter)
                    }
                    .accessibilityHidden(true)
            }
        }
    }
}

/// Convenience for single-line text placeholders.
public struct SkeletonLine: View {
    public var widthFraction: CGFloat
    public var height: CGFloat

    public init(widthFraction: CGFloat = 1, height: CGFloat = 14) {
        self.widthFraction = widthFraction
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            SkeletonView(.capsule)
                .frame(
                    width: geometry.size.width * widthFraction,
                    height: height
                )
        }
        .frame(height: height)
    }
}

public extension View {
    /// Hide the view and present a shimmer of the same frame when `isLoading`.
    @ViewBuilder
    func skeleton(isLoading: Bool, cornerRadius: CGFloat = 12) -> some View {
        if isLoading {
            SkeletonView(.rectangle(cornerRadius: cornerRadius))
                .overlay(self.hidden())
        } else {
            self
        }
    }
}

// MARK: - Helpers
private extension SkeletonView {
    @ViewBuilder
    func fill(with color: Color?, gradient: LinearGradient? = nil) -> some View {
        switch shape {
        case .rectangle(let radius):
            filled(RoundedRectangle(cornerRadius: radius, style: .continuous), color: color, gradient: gradient)
        case .circle:
            filled(Circle(), color: color, gradient: gradient)
        case .capsule:
            filled(Capsule(), color: color, gradient: gradient)
        }
    }

    @ViewBuilder
    func filled<S: SwiftUI.Shape>(_ shape: S, color: Color?, gradient: LinearGradient?) -> some View {
        if let gradient {
            shape.fill(gradient)
        } else if let color {
            shape.fill(color)
        } else {
            shape.fill(.clear)
        }
    }

    func shimmerGradient(time: TimeInterval) -> LinearGradient {
        let phase = CGFloat((time * 0.8).truncatingRemainder(dividingBy: 2.0)) - 0.5
        return LinearGradient(
            stops: [
                .init(color: .white.opacity(0), location: max(0, phase - 0.3)),
                .init(color: .white.opacity(0.18), location: phase),
                .init(color: .white.opacity(0), location: min(1, phase + 0.3)),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
