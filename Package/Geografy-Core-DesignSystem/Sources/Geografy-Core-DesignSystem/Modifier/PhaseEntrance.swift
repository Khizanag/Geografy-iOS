import SwiftUI

/// Two-phase entrance animation: hidden → settled.
/// Combines opacity and offset so views arrive with a subtle, premium feel.
/// Reduce Motion skips the animation and lands the view in its final state instantly.
public enum GeoEntrancePhase: CaseIterable, Sendable {
    case hidden
    case settled
}

public extension View {
    /// Staggered entrance animation. Child views pass a monotonically increasing
    /// `index` to offset their animation start by `index * stagger` seconds, producing
    /// a pleasing cascade. Use 0 for single elements. Indices past the first screenful
    /// share the last delay, so rows scrolled into a lazy stack never wait on the cascade.
    func phaseEntrance(index: Int = 0, stagger: Double = 0.06) -> some View {
        modifier(PhaseEntranceModifier(index: index, stagger: stagger))
    }
}

private struct PhaseEntranceModifier: ViewModifier {
    let index: Int
    let stagger: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let maxStaggeredIndex = 12

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
                .animation(
                    .spring(response: 0.55, dampingFraction: 0.82)
                        .delay(Double(min(index, maxStaggeredIndex)) * stagger),
                    value: hasAppeared
                )
                .onAppear { hasAppeared = true }
        }
    }
}
