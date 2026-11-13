import SwiftUI

/// Lays children out left to right, wrapping to a new line when the row is full.
public struct FlowLayout: Layout {
    // MARK: - Properties
    public var spacing: CGFloat

    // MARK: - Init
    public init(spacing: CGFloat = DesignSystem.Spacing.xs) {
        self.spacing = spacing
    }

    // MARK: - Layout
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let result = computeLayout(
            proposal: proposal,
            subviews: subviews
        )
        return result.size
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = computeLayout(
            proposal: proposal,
            subviews: subviews
        )
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                ),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }
}

// MARK: - Helpers
private extension FlowLayout {
    struct LayoutResult {
        var positions: [CGPoint]
        var sizes: [CGSize]
        var size: CGSize
    }

    func computeLayout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = fittedSize(of: subview, maxWidth: maxWidth)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            sizes.append(size)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return LayoutResult(
            positions: positions,
            sizes: sizes,
            size: CGSize(
                width: totalWidth,
                height: currentY + lineHeight
            )
        )
    }

    // A child wider than the row gets the row's width, so long text wraps instead of running off the edge.
    func fittedSize(of subview: LayoutSubview, maxWidth: CGFloat) -> CGSize {
        let idealSize = subview.sizeThatFits(.unspecified)
        guard idealSize.width > maxWidth else { return idealSize }
        return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
    }
}
