import SwiftUI

public extension View {
    /// The card behind a selectable tile: a light tint and an edge in `color` when selected, the plain card fill
    /// otherwise. The tint sits on the opaque card fill, so the tile stays solid under Reduce Transparency.
    func selectableTileBackground(
        isSelected: Bool,
        color: Color,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.extraLarge
    ) -> some View {
        modifier(SelectableTileBackground(isSelected: isSelected, color: color, cornerRadius: cornerRadius))
    }
}

private struct SelectableTileBackground: ViewModifier {
    let isSelected: Bool
    let color: Color
    let cornerRadius: CGFloat

    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                shape
                    .fill(DesignSystem.Color.cardBackground)
                    .overlay {
                        if isSelected {
                            shape.fill(color.opacity(0.12))
                        }
                    }
            }
            .overlay {
                if isSelected {
                    shape.strokeBorder(color, lineWidth: 2)
                } else if contrast == .increased {
                    shape.strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
                }
            }
            .contentShape(shape)
    }
}
