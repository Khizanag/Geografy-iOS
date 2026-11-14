import SwiftUI

/// The radio-style mark in a selectable tile's corner: an empty circle, or a filled check in `color` once selected,
/// so selection never rests on the tint alone.
public struct SelectionMark: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let isSelected: Bool
    private let color: Color

    // MARK: - Init
    public init(isSelected: Bool, color: Color) {
        self.isSelected = isSelected
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(DesignSystem.Font.title3)
            .foregroundStyle(isSelected ? color : DesignSystem.Color.textTertiary)
            .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            .accessibilityHidden(true)
    }
}
