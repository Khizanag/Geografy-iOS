import Geografy_Core_DesignSystem
import SwiftUI

extension View {
    /// Accent fill when selected, card fill otherwise. Adds a checkmark under Differentiate Without Color
    /// and an edge at increased contrast, so selection never rests on color alone.
    func selectionChipBackground(
        isSelected: Bool,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.medium
    ) -> some View {
        modifier(SelectionChipBackground(isSelected: isSelected, cornerRadius: cornerRadius))
    }
}

private struct SelectionChipBackground: ViewModifier {
    let isSelected: Bool
    let cornerRadius: CGFloat

    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground, in: shape)
            .overlay {
                if contrast == .increased, !isSelected {
                    shape.strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelected, differentiateWithoutColor {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignSystem.Font.iconXS)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .padding(DesignSystem.Spacing.xxs)
                        .accessibilityHidden(true)
                }
            }
    }
}
