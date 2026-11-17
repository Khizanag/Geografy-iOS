import SwiftUI

/// A capsule filled to a share of its width: the one bar every share, percentage, and ratio is drawn with,
/// so they all read alike. It grows in when it first appears.
public struct ShareBar: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var hasGrown = false

    private let fraction: Double
    private let color: Color
    private let delay: Double

    // MARK: - Init
    /// - Parameters:
    ///   - fraction: How much of the bar is filled, from 0 to 1.
    ///   - delay: How long it waits before growing in, to stagger a column of bars.
    public init(fraction: Double, color: Color = DesignSystem.Color.blue, delay: Double = 0.3) {
        self.fraction = fraction
        self.color = color
        self.delay = delay
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Color.cardBackgroundHighlighted)
                Capsule()
                    .fill(color)
                    .frame(width: filledWidth(in: geometry.size))
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.7).delay(delay),
                        value: hasGrown
                    )
            }
        }
        .frame(height: DesignSystem.Spacing.xs)
        .accessibilityHidden(true)
        .onAppear { hasGrown = true }
    }
}

// MARK: - Helpers
private extension ShareBar {
    // A nonzero share never shrinks below a dot, so a 1% row stays visible.
    func filledWidth(in size: CGSize) -> CGFloat {
        guard hasGrown, fraction > 0 else { return 0 }
        return max(size.width * min(fraction, 1), size.height)
    }
}
