import Geografy_Core_DesignSystem
import SwiftUI

/// A continent's silhouette with its country borders, fitted into the available space.
struct ContinentOutlineView: View {
    // MARK: - Properties
    let outline: ContinentOutline
    let fill: Color

    // MARK: - Body
    var body: some View {
        Canvas { context, size in
            let transform = outline.fittingTransform(in: size)
            context.concatenate(transform)
            context.clip(to: Path(outline.viewport))
            let path = Path(outline.path)
            context.fill(path, with: .color(fill))
            context.stroke(
                path,
                with: .color(DesignSystem.Color.cardBackground),
                lineWidth: Self.borderWidth / transform.a
            )
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Helpers
private extension ContinentOutlineView {
    static let borderWidth: CGFloat = 0.6
}
